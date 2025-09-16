--- 用于控制赐福下发等
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCommon = require("Protocol/ProtoCommon")
local GoldSaucerBlessingDefine = require("Game/GoldSaucerMiniGame/GoldSaucerBlessingDefine")
local PWorldDynDataMgr = require("Game/PWorld/DynData/PWorldDynDataMgr")
local ProtoCS = require("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local TimeUtil = require("Utils/TimeUtil")
local FairyBlessedTimeCfg = require("TableCfg/FairyBlessedTimeCfg")
local CS_CMD = ProtoCS.CS_CMD
local EffectUtil = require("Utils/EffectUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local EBlessingState = GoldSaucerBlessingDefine.EBlessingState
local PWorldMgr = _G.PWorldMgr
local EventID = _G.EventID
local MapDynType = ProtoCommon.MapDynType
local EffectType = MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
local SecDef = 60
---@class GoldSaucerBlessingMgr : MgrBase
local GoldSaucerBlessingMgr = LuaClass(MgrBase)

function GoldSaucerBlessingMgr:OnInit()
    self.JDMapID = 12060
    self.VfxHaneleIDMap = {}        -- VfxMap Key为InstanceID Value为Vfx的HandleID
    
    self.CurBlessState = EBlessingState.NotBegin   -- 当前赐福状态
    self.NextReqBlessTime = nil                    -- 下一次请求赐福数据时间
    self.MachineID = 0                             -- 赐福的机器ID
    self.BlessKind = 0                             -- 大赐福还是小赐福
    self.BlessHelper = nil                         -- 赐福类实例
    -- self.bFinishBless = false                      -- 是否完成该轮赐福
    -- self.LastStartTime = 0                         -- 上一次赐福时间
end

function GoldSaucerBlessingMgr:Reset()
    self.VfxHaneleIDMap = {}
    self.MachineID = 0
    self.BlessKind = 0
    self.BlessHelper = nil                         -- 赐福类实例
end

function GoldSaucerBlessingMgr:OnBegin()
  
end

function GoldSaucerBlessingMgr:OnEnd()
end

function GoldSaucerBlessingMgr:OnShutdown()
 
end

function GoldSaucerBlessingMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldMapEnter)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)

end

function GoldSaucerBlessingMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_BLESSED, ProtoCS.Game.FairyBlessed.CS_FAIRY_BLESSED_CMD.CS_FAIRY_BLESSED_CMD_GET, self.OnGetBlessStateRsp)
end

--- @type 当加载完世界
function GoldSaucerBlessingMgr:OnPWorldMapEnter(Params)
    self.CurrMapResID = Params.CurrMapResID
    if Params.CurrMapResID == self.JDMapID then
        self:Reset()
        self:SendMsgCheckBlessStateReq()
    end
end

function GoldSaucerBlessingMgr:OnPWorldExit(LeavePWorldResID, LeaveMapResID)
    local BaseInfo = PWorldMgr.BaseInfo
    self.CurrMapResID = BaseInfo.CurrMapResID
    if LeaveMapResID == self.JDMapID then

    end
end

--- @type 查看赐福信息
function GoldSaucerBlessingMgr:SendMsgCheckBlessStateReq()
    local MsgID = CS_CMD.CS_CMD_FAIRY_BLESSED
    local SubMsgID = ProtoCS.Game.FairyBlessed.CS_FAIRY_BLESSED_CMD.CS_FAIRY_BLESSED_CMD_GET
    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- @type 赐福信息回包
function GoldSaucerBlessingMgr:OnGetBlessStateRsp(MsgBody)
    if MsgBody == nil then
        return
    end
    local BlessedGetRsp = MsgBody.BlessedGetRsp
    if BlessedGetRsp == nil then
        return
    end
    local StartTime = BlessedGetRsp.StartTime
    self.BlessKind = BlessedGetRsp.BlessKind + 1   -- 赐福类型
    self.MachineID = BlessedGetRsp.MachineID
    local BlessState = self:GetBlessState(StartTime)
    self.CurBlessState = BlessState
    self:UpdateBlessByState(BlessState, BlessedGetRsp.MachineID, StartTime)
end

--- @type 查看赐福的状态
function GoldSaucerBlessingMgr:GetBlessState(StartTime)
    local ReturnState
    local Time = TimeUtil.GetServerTime()
    local Cfg = FairyBlessedTimeCfg:FindCfgByKey(self.BlessKind)
    if Cfg == nil then
        FLOG_ERROR("FairyBlessedTimeCfg = nil")
        return
    end
    local BlessTimeSec = Cfg.BlessTime * SecDef
    local WarningSec = Cfg.WarningTime * SecDef
    local PrepareSec = Cfg.PrepareTime * SecDef
    local Duration = BlessTimeSec + WarningSec  -- 总持续时间
    if Time >= StartTime - PrepareSec and Time < StartTime then
        ReturnState = EBlessingState.Prepare
    elseif Time >= StartTime and Time < StartTime + BlessTimeSec then
        ReturnState = EBlessingState.InBlessing
    elseif Time >= StartTime + BlessTimeSec and Time < Duration then
        ReturnState = EBlessingState.InWarning
    else
        ReturnState = EBlessingState.NotBegin
    end
    return ReturnState
end

--- @type 刷新当前赐福
--- @param BlessState 当前赐福状态
--- @param MachineID 游戏机sg实例ID
--- @param BlessKind 赐福类型
--- @param StartTime 赐福开启的时间
function GoldSaucerBlessingMgr:UpdateBlessByState(BlessState, MachineID, StartTime)
    local VfxEffectPath = GoldSaucerBlessingDefine.VfxEffectPath
    local Cfg = FairyBlessedTimeCfg:FindCfgByKey(self.BlessKind)
    if Cfg == nil then
        FLOG_ERROR("FairyBlessedTimeCfg = nil")
        return
    end
    local BlessTimeSec = Cfg.BlessTime * SecDef
    local WarningSec = Cfg.WarningTime * SecDef
    local PrepareSec = Cfg.PrepareTime * SecDef

    local TempMsgStr, VfxPath, NeedStopVfx, NextReqBlessTime
    if BlessState == EBlessingState.InBlessing then         -- 赐福中且没到预警时间
        TempMsgStr = "在赐福中"
        VfxPath = VfxEffectPath.BelssingVfx
        NextReqBlessTime = StartTime + BlessTimeSec
    elseif BlessState == EBlessingState.InWarning then        -- 赐福中已经达到预警时间
        TempMsgStr = "赐福进入结束预警"
        VfxPath = VfxEffectPath.BelssingVfx
        NextReqBlessTime = StartTime + WarningSec + BlessTimeSec
    elseif BlessState == EBlessingState.NotBegin then       -- 不再赐福中
        TempMsgStr = "仙人赐福未开始"
        NeedStopVfx = true
        NextReqBlessTime = StartTime - PrepareSec
    elseif BlessState == EBlessingState.Prepare then        -- 准备赐福，此时特效已经出现
        TempMsgStr = "赐福正在准备中"
        VfxPath = VfxEffectPath.BelssingVfx
        NextReqBlessTime = StartTime
    end
    if NextReqBlessTime ~= nil then
        self.NextReqBlessTime = NextReqBlessTime + 1
    end

    if TempMsgStr ~= nil then
        MsgTipsUtil.ShowTips(TempMsgStr)
    end

    if VfxPath ~= nil then
        self:TryPlayBlessingVfx(MachineID, VfxPath)
    end

    if NeedStopVfx then
        self:TryStopBlessingVfx(MachineID)
    end
end

-- lua GoldSaucerBlessingMgr:TryPlayBlessingVfx(5360362)
--- @type 尝试播放仙人赐福的特效
function GoldSaucerBlessingMgr:TryPlayBlessingVfx(InstanceID, VfxPath)
    self:TryStopBlessingVfx(InstanceID)
    local SgTransform = _G.UE.FTransform()
    PWorldMgr:GetInstanceAssetTransform(InstanceID, SgTransform)
    local SgLocation = SgTransform:GetLocation()
    if not (SgLocation.X == 0 and SgLocation.Y == 0 and SgLocation.Z == 0) then
        local VfxParameter = _G.UE.FVfxParameter()
        VfxParameter.VfxRequireData.EffectPath = VfxPath
        -- VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_MiniGameCuff  后面要加新的Type
                
        VfxParameter.VfxRequireData.VfxTransform = SgTransform
        VfxParameter.VfxRequireData.bAlwaysSpawn = true
        local HandleID = EffectUtil.PlayVfx(VfxParameter)
        self.VfxHaneleIDMap[InstanceID] = HandleID
    end
end

-- lua GoldSaucerBlessingMgr:TryStopBlessingVfx(5360362)
--- @type 停止播放仙人赐福的特效
function GoldSaucerBlessingMgr:TryStopBlessingVfx(InstanceID)
    local HandleID = self.VfxHaneleIDMap[InstanceID]
    if HandleID ~= nil then
        EffectUtil.StopVfx(HandleID)
        self.VfxHaneleIDMap[InstanceID] = nil
    end
end

--- @type 检测是否存在赐福
function GoldSaucerBlessingMgr:CheckHasBless()
    local CurBlessState = self.CurBlessState
    return (CurBlessState == EBlessingState.InBlessing or CurBlessState == EBlessingState.InWarning)
end

--- @type 检测游戏机是否处于仙人赐福状态
function GoldSaucerBlessingMgr:GetSgIsInBlessing(InstanceID)
    return self.MachineID == InstanceID and self:CheckHasBless() 
end

--- @type 获取下次请求赐福的时间
function GoldSaucerBlessingMgr:GetReqBlessTime()
    return self.NextReqBlessTime
end

--- @type 获取赐福类型
function GoldSaucerBlessingMgr:GetBlessKind()
    return self.BlessKind
end


--- @type 设置完成gai
-- function GoldSaucerBlessingMgr:SetbFinishBless(bFinish)
--     self.bFinishBless = bFinish
--     if bFinish then
--         self.NextReqBlessTime = nil
--     end
-- end

-- --- @type 小游戏赐福模式
-- function GoldSaucerBlessingMgr:TryEnterBlessMode(SgInstanceID)
--     if not self:CheckHasBless() then
--         return
--     end
--     if SgInstanceID == self.MachineID then
--         self.BlessHelper = MiniGameBlessHelper.New()
--     end
-- end

-- --- @type 获取赐福实例
-- function GoldSaucerBlessingMgr:GetBlessHelper()
--     return self.BlessHelper
-- end

-- --- @type 释放
-- function GoldSaucerBlessingMgr:DestoryBlessHelper()
--     self.BlessHelper = nil
-- end

return GoldSaucerBlessingMgr
