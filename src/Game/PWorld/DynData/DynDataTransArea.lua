--
-- Author: ashyuan
-- Date: 2024-3-4
-- Description:野外传送区域,同步端游ExitRange
--
local ProtoRes = require ("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local LuaClass = require("Core/LuaClass")
local DynDataTriggerBase = require("Game/PWorld/DynData/DynDataTriggerBase")
local DynDataCommon = require("Game/PWorld/DynData/DynDataCommon")
local ProtoCS = require("Protocol/ProtoCS")
local GameNetMsgRegister = require("Register/GameNetMsgRegister")
local MajorUtil = require("Utils/MajorUtil")

local EDynDataTriggerShapeType = DynDataCommon.EDynDataTriggerShapeType
-- 收到传送失败的消息时重新发包
local ErrorCodeTrans = 101071
local CS_CMD = ProtoCS.CS_CMD
local CS_PWORLD_CMD = ProtoCS.CS_PWORLD_CMD

local Tolerance = 70 --胶囊体宽1米，这里做误差容错

---@class DynDataTransArea : DynDataTriggerBase
local DynDataTransArea = LuaClass(DynDataTriggerBase, true)

function DynDataTransArea:Ctor()
    self.RecentTransTime = 0
    self.MinIntervalTime = 1.0
    self.CheckIntervalTime = 1
    self.DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_AREA
end

function DynDataTransArea:Destroy()
    self.Super:Destroy()
    -- 防一下因为其他原因EndOverlap没有正确触发的情况
    self:UnRegisterMsgError()
    self:RemoveTransCheckTimer()
end

function DynDataTransArea:UpdateState(NewState)
    self.Super:UpdateState(NewState)
end

function DynDataTransArea:CreateBoxTrigger(Box)
    self.Extent = _G.UE.FVector(Box.Extent.X - Tolerance, Box.Extent.Y - Tolerance, Box.Extent.Z)
    self.Location = _G.UE.FVector(Box.Center.X, Box.Center.Y, Box.Center.Z)
    self.Rotator = _G.UE.FRotator(Box.Rotator.Y, Box.Rotator.Z, Box.Rotator.X)
    self:CreateTrigger(EDynDataTriggerShapeType.TriggerShapeType_Box)
end

function DynDataTransArea:OnTriggerBeginOverlap(Trigger, Target)
    local NowTimeSeconds = _G.TimeUtil.GetLocalTime()
    if (NowTimeSeconds - self.RecentTransTime >= self.MinIntervalTime) then
        self.bIsTriggering = false
    end

    -- 先判断是不是Major进入传送区域
    if (not self:IsNeedTrigger(Trigger, Target)) then
        return
    end
    -- 如果是多人骑乘状态就不触发传送请求
    local bIsInOtherRide = self:IsInOtherRide()
    if bIsInOtherRide then
        return
    end
    self.RecentTransTime = _G.TimeUtil.GetLocalTime()
    self.bIsTriggering = true
    -- 进入传送区域后先发一次包
    self:SendPWorldTrans()
    -- 监听各种传送错误的事件
    self:RegisterMsgError()
end

function DynDataTransArea:IsInOtherRide()
    local Major = MajorUtil:GetMajor()
    -- Major还没创建的情况下判断不了是否处于多人坐骑上
    if Major == nil then
        return false
    end
    local RideComp = Major:GetRideComponent()
    if RideComp == nil then
        return false
    end
    return RideComp:IsInOtherRide()
end

function DynDataTransArea:OnTriggerEndOverlap(Trigger, Target)
    local NowTimeSeconds = _G.TimeUtil.GetLocalTime()
    if (NowTimeSeconds - self.RecentTransTime >= self.MinIntervalTime) then
        self.bIsTriggering = false
    end
    self:UnRegisterMsgError()
    self:RemoveTransCheckTimer()
end

function DynDataTransArea:SendPWorldTrans()
    if self:IsForbidUse() then
        return
    end

    -- 显示黑屏渐隐
    local Params = {}
    Params.FadeColorType = 3
    Params.Duration = 0.6
    Params.bAutoHide = false
    _G.UIViewMgr:ShowView(UIViewID.CommonFadePanel, Params)

    _G.PWorldMgr:SendTrans(ProtoCS.PWORLD_TRANS_TYPE.PWORLD_TRANS_TYPE_EXIT_RANGE, self.ID)
end

function DynDataTransArea:AddTransCheckTimer(Count)
    self:RemoveTransCheckTimer()
    self.TransCheckTimer = _G.TimerMgr:AddTimer(self, self.SendPWorldTrans, self.CheckIntervalTime, self.CheckIntervalTime, Count)
end

function DynDataTransArea:RemoveTransCheckTimer()
    if self.TransCheckTimer then
        _G.TimerMgr:CancelTimer(self.TransCheckTimer)
        self.TransCheckTimer = nil
    end
end

function DynDataTransArea:OnNetMsgError(MsgBody)
    local Msg = MsgBody
	if nil == Msg then
		return
	end
    local ErrorCode = Msg.ErrCode
    -- 目前只处理离传送距离太远导致传送失败
    if ErrorCode ~= ErrorCodeTrans then
        return
    end
    -- 检查错误提示信息
    if Msg.Cmd ~= CS_CMD.CS_CMD_PWORLD or Msg.SubCmd ~= CS_PWORLD_CMD.CS_PWORLD_CMD_TRANS then
        return
    end
    -- 接到错误提示后延迟1秒重新发包
    self:AddTransCheckTimer(1)
end

function DynDataTransArea:RegisterMsgError()
    local Register = self.GameNetMsgRegister
	if nil == Register then
		Register = GameNetMsgRegister.New()
		self.GameNetMsgRegister = Register
	end
	if nil ~= Register then
		Register:Register(CS_CMD.CS_CMD_ERR, 0, self, self.OnNetMsgError)
	end
end

function DynDataTransArea:UnRegisterMsgError()
    if not self.GameNetMsgRegister then
        return
    end
    self.GameNetMsgRegister:UnRegisterAll()
end

return DynDataTransArea