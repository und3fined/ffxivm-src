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
local GameEventRegister = require("Register/GameEventRegister")
local MajorUtil = require("Utils/MajorUtil")
local MapUtil = require("Game/Map/MapUtil")
local PWorldCfg = require("TableCfg/PworldCfg")

local EDynDataTriggerShapeType = DynDataCommon.EDynDataTriggerShapeType
-- 收到传送失败的消息时重新发包
local ErrorCodeTrans = 101071
local CS_CMD = ProtoCS.CS_CMD
local CS_PWORLD_CMD = ProtoCS.CS_PWORLD_CMD

local Tolerance = 70 --胶囊体宽1米，这里做误差容错

---@class DynDataTransArea : DynDataTriggerBase
local DynDataTransArea = LuaClass(DynDataTriggerBase, true)

function DynDataTransArea:Ctor()
    self.LastTriggerTime = 0 -- 上一次触发的时间
    self.MinIntervalTime = 1.0 -- 进入区域的最小间隔, 防止短时间内频繁进出
    self.CheckIntervalTime = 1 -- 多次发送传送包的间隔时间
    self.DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_AREA
    self.DestPWorldID = 0 -- 目标副本ID
    self.bIsToHousing = false -- 目标副本是否为房屋
    self.CurrPWorldID = 0 -- 当前副本ID
    self.bIsFromHousing = false -- 当前副本是否为房屋
end

function DynDataTransArea:InitData(Area)
    self.ID = Area.ID
    self.State = 1
    self.DestPWorldID = Area.Exit and Area.Exit.DestPWorldID or 0
    self.DestMapID = PWorldCfg:GetFirstMapID(self.DestPWorldID)
    self.bIsToHousing = self:CheckIsHousingPWorld(self.DestPWorldID)
    self.CurrPWorldID = _G.PWorldMgr:GetCurrPWorldResID()
    self.CurrMapID = _G.PWorldMgr:GetCurrMapResID()
    self.bIsFromHousing = self:CheckIsHousingPWorld(self.CurrPWorldID)
end

function DynDataTransArea:Destroy()
    self.Super:Destroy()
    -- 防一下因为其他原因EndOverlap没有正确触发的情况
    self:CancelCommonTrans()
    self:CancelHousingTrans()
end

function DynDataTransArea:IsHousingRelevant()
    return self.bIsToHousing or self.bIsFromHousing
end

function DynDataTransArea:CheckIsHousingPWorld(PWorldID)
    if PWorldID <= 0 then
        return false
    end
    local Cfg = PWorldCfg:FindCfgByKey(PWorldID)
    if Cfg then
        -- 根据副本配置判断是否传送到房屋
        return (Cfg.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_MAIN_CITY) and (Cfg.SubType == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_HOUSE_PUBLIC)
    end
    return false
end

function DynDataTransArea:UpdateState(NewState)
    self.Super:UpdateState(NewState)
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

function DynDataTransArea:CreateBoxTrigger(Box)
    self.Extent = _G.UE.FVector(Box.Extent.X - Tolerance, Box.Extent.Y - Tolerance, Box.Extent.Z)
    self.Location = _G.UE.FVector(Box.Center.X, Box.Center.Y, Box.Center.Z)
    self.Rotator = _G.UE.FRotator(Box.Rotator.Y, Box.Rotator.Z, Box.Rotator.X)
    self:CreateTrigger(EDynDataTriggerShapeType.TriggerShapeType_Box)
end

function DynDataTransArea:OnTriggerBeginOverlap(Trigger, Target)
    -- 先判断是不是Major进入传送区域
    if (not self:IsNeedTrigger(Trigger, Target)) then
        return
    end
    -- 如果是多人骑乘状态就不触发传送请求
    local bIsInOtherRide = self:IsInOtherRide()
    if bIsInOtherRide then
        return
    end
    self.bIsTriggering = true
    -- 重复进入传送区域的间隔太短, 不需要重复处理
    local NowTimeSeconds = _G.TimeUtil.GetLocalTime()
    if (NowTimeSeconds - self.LastTriggerTime < self.MinIntervalTime) then
        return
    end
    self.LastTriggerTime = _G.TimeUtil.GetLocalTime()
    -- 根据副本类型判断是不是房屋传送带，自动寻路的话就正常触发
    if not self:IsHousingRelevant() or _G.AutoPathMoveMgr:IsAutoPathMovingState() then
        self:RequireCommonTrans()
    else
        self:RequireHousingTrans()
    end
end

function DynDataTransArea:OnTriggerEndOverlap(Trigger, Target)
    -- 已经销毁了的传送带
    if self:IsForbidUse() then
        return
    end
    -- 主角没有进入传送带
    if self.bIsTriggering == false then
        return
    end
    -- 无效的触发对象
    if Target == nil or Target:Cast(_G.UE.AMajorCharacter) == nil then
        return
    end
    self.bIsTriggering = false
    -- 根据副本类型判断是不是房屋传送带
    if not self:IsHousingRelevant() then
        self:CancelCommonTrans()
    else
        self:CancelHousingTrans()
    end
end

function DynDataTransArea:RequireCommonTrans()
    -- 进入传送区域后先发一次包
    self:SendPWorldTrans()
    -- 监听各种传送错误的事件
    self:RegisterMsgError()
end

function DynDataTransArea:CancelCommonTrans()
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
    _G.UIViewMgr:ShowView(_G.UIViewID.CommonFadePanel, Params)

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

function DynDataTransArea:RequireHousingTrans()
    -- 打开交互界面
    self:OnEnterInteractive()
end

function DynDataTransArea:CancelHousingTrans()
    -- 关闭交互界面
    self:OnExitInteractive()
end

function DynDataTransArea:OnEnterInteractive()
    -- 触发交互
    -- 这里需要直接触发2级菜单，先处理一下交互前的状态
    local CombatComponent = MajorUtil.GetMajorCombatComponent()
    if CombatComponent then
        CombatComponent:BreakSkill()
    end
   local MajorController = MajorUtil.GetMajorController()
    if nil ~= MajorController then
        MajorController:SetStopMoveTime(0.5)
    end
    _G.InteractiveMgr:SetIsTransAreaTrigger(true)
    self:SetHousingFunctionList()
end

function DynDataTransArea:OnExitInteractive()
    -- 退出交互
    _G.InteractiveMgr:ShowOrHideMainPanel(true)
    _G.InteractiveMgr:SetIsTransAreaTrigger(false)
end

function DynDataTransArea:SetHousingFunctionList()
    local QueryMapID = self.bIsToHousing and self.DestMapID or self.CurrMapID
    local RegionID = MapUtil.GetHouseRegionID(QueryMapID)
    local HousingPortalFuncs = {}

    -- 个人
    if _G.HouseLandMgr:IsCurAreaHasMajorPersonalHouse() then
        table.insert(HousingPortalFuncs, { FuncValue = 500200, ResidenceNumber = RegionID, AreaNumber = 1 })
    end

    -- 部队
    if _G.HouseLandMgr:IsCurAreaHasMajorArmyHouse() then
        table.insert(HousingPortalFuncs, { FuncValue = 500201, ResidenceNumber = RegionID, AreaNumber = 1 })
    end

    -- 移动到指定小区
    table.insert(HousingPortalFuncs, { FuncValue = 500202, HouseRegionID = RegionID })

    -- 离开住宅区
    if self.bIsFromHousing then
        table.insert(HousingPortalFuncs, { FuncValue = 500204, TransAreaID = self.ID })
    end

    _G.InteractiveMgr:SetHousingPortalFunctionList(HousingPortalFuncs)
end

return DynDataTransArea