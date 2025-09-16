local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ClientReportType = ProtoCS.ReportType
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local ItemUtil = require("Utils/ItemUtil")
local ERR = _G.FLOG_ERROR

local ProtoCommon = require("Protocol/ProtoCommon")
local SceneModeDef = ProtoCommon.SceneMode
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsID = require("Define/MsgTipsID")

local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")


local InputCheckInterval = 10 --secs

---@class PWorldQuestMgr : MgrBase
local PWorldQuestMgr = LuaClass(MgrBase)

local PWorldQuestVM

function PWorldQuestMgr:OnInit()
    -- self.IsPWorldFinished = nil
    self.IsRolling = false
end

function PWorldQuestMgr:OnBegin()
    PWorldQuestVM = _G.PWorldQuestVM

    self.Scheme = {}

    local TimeScheme = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_SCENE_LEAVE_TIME_NTF, "Value")
    local TimeOutCfg = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_SCENE_LEAVE_TIMEOUT, "Value")
    local TimeOut = TimeOutCfg and TimeOutCfg[1] or 0

    self.TimeOut = math.floor(TimeOut / 60)
    if TimeScheme then
        for Idx = 1, 3 do
            self.Scheme[Idx] = TimeScheme[Idx]
        end
    else
        _G.FLOG_ERROR("PWorldQuestMgr:OnBegin TimeScheme = nil")
    end

    table.insert(self.Scheme, TimeOut)
end

function PWorldQuestMgr:OnEnd()
    self:EndFirstPassTimer()
end

function PWorldQuestMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.PWorldBegin, function()
        self:CheckFirstPass()
        self:CheckSyncTips()
    end)

    self:RegisterGameEvent(_G.EventID.PWorldMapEnter, function()
        -- _G.FLOG_INFO("Andre. 开始检测玩家挂机")
        self:Reset()

        self:EndInputTimer()

        if _G.PWorldMgr:CurrIsInDungeon() then
            self.InputTimerHdl = self:RegisterTimer(self.OnTimerMajorInput, 0, InputCheckInterval, 0)
        end
    end)

    self:RegisterGameEvent(_G.EventID.PWorldExit, function()
        self:Reset()
        self:EndInputTimer()
    end)

	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnMajorInput)

    self:RegisterGameEvent(_G.EventID.TeamRollStartEvent, function()
        self.IsRolling = true
    end)

    self:RegisterGameEvent(_G.EventID.TeamRollEndEvent, function()
        self.IsRolling = false
    end)

	self:RegisterGameEvent(_G.EventID.RoleLoginRes,             self.OnRoleLoginRes)
end

function PWorldQuestMgr:OnRoleLoginRes(Params)
	if Params == nil or Params.bReconnect == false then return end

    if _G.PWorldMgr:CurrIsInDungeon() then
        self:CheckFirstPass()
        self:CheckSyncTips()
    end
end

function PWorldQuestMgr:Reset()
    -- self.IsPWorldFinished = nil
    self:ClearMajorInput()
end

-- PWorldQuestMenuWinView 界面打开时，驱动其更新
function PWorldQuestMgr:OnTimer()
    PWorldQuestVM:OnTimer()
end

-- # NetMsgHandle

-- # Request
function PWorldQuestMgr:ReqPWorldInputTimeOut()
    if self.MajorInputLastTime and _G.PWorldMgr:CurrIsInDungeon() then
        _G.ClientReportMgr:SendClientReport(ClientReportType.ReportTypeRoleLeave, {Leave = {BeginTime = self.MajorInputLastTime}})
    end
 end

function PWorldQuestMgr:ShowPWQuestView()
    -- if _G.PWorldTeamMgr.PWorldQuestEnable then
        _G.UIViewMgr:ShowView(_G.UIViewID.PWorldQuestMenu)
    -- end
end


-------------------------------------------------------------------------------------------------------
---@see 玩家输入检测和提示

function PWorldQuestMgr:EndInputTimer()
    if self.InputTimerHdl then
        -- _G.FLOG_INFO("zhg 结束检测玩家挂机")
        self:UnRegisterTimer(self.InputTimerHdl)
        self.InputTimerHdl = false
    end
end

function PWorldQuestMgr:OnTimerMajorInput()
    self:CheckMajorInput()
end

local function OnMajorOpWarn(self ,Time)
    MsgTipsUtil.ShowTipsByID(146049, nil, Time, self.TimeOut)
    -- _G.FLOG_INFO("zhg 挂机检测 ： " .. Str)
end

function PWorldQuestMgr:OnMajorInput()
   self:ClearMajorInput()
end

function PWorldQuestMgr:ClearMajorInput()
    self.MajorInputLastTime = self:GetAbsServerTime()
    self:ClearMajorInputData()
 end

function PWorldQuestMgr:CheckMajorInput()
    if self.WarnIdx > #self.Scheme or self.MajorInputLastTime == nil then
        return
    end

    local Delta = self:GetAbsServerTime() - self.MajorInputLastTime

    if Delta >= self.Scheme[self.WarnIdx] then
        if self.WarnIdx == #self.Scheme then
            self:ReqPWorldInputTimeOut()
        else
            OnMajorOpWarn(self, math.floor(Delta / 60))
        end

        self.WarnIdx = self.WarnIdx + 1
    end
end

function PWorldQuestMgr:ClearMajorInputData()
    self.WarnIdx = 1
end

function PWorldQuestMgr:GetAbsServerTime()
    return _G.TimeUtil.GetServerTime()
end

-------------------------------------------------------------------------------------------------------
---@see 初见

function PWorldQuestMgr:CheckFirstPass()
    local HasFirstPass = _G.PWorldTeamMgr:HasFirstPassMem()
    if HasFirstPass then
        self:StartFirstPassTimer()
    end
end

function PWorldQuestMgr:StartFirstPassTimer()
    self:EndFirstPassTimer()
    self.FirstPassHdl = self:RegisterTimer(self.OnFirstPassTimer, 10, 0, 1)
end

function PWorldQuestMgr:EndFirstPassTimer()
    if self.FirstPassHdl then
        self:UnRegisterTimer(self.FirstPassHdl)
        self.FirstPassHdl = false
    end
end

function PWorldQuestMgr:OnFirstPassTimer()
    local Concat = {}

    local PID = _G.PWorldMgr:GetCurrPWorldResID()
    local Cfg = SceneEnterCfg:FindCfgByKey(PID)

    if Cfg then
        local Rewards = Cfg.InitialRewards
        for _, ID in pairs(Rewards or {}) do
            local Name = ItemUtil.GetItemName(ID)
            table.insert(Concat, Name)
        end

        if not table.empty(Concat) then
            local RStr = table.concat(Concat, "、")
            local Text = string.format("%s", RStr or "")
            _G.MsgTipsUtil.ShowTipsByID(146040, nil, Text)
        end
    end

end

-------------------------------------------------------------------------------------------------------
---@see 同步提示

function PWorldQuestMgr:CheckSyncTips()
    -- print('zhg PWorldQuestMgr:CheckSyncTips')
    if not _G.PWorldMgr:CurrIsInDungeon() then
        return
    end

    -- 某些副本不提示
    if _G.GoldSauserMgr:CurrIsGoldSauserDungeon()
        or _G.PWorldMgr:CurrIsInPVPColosseum()
        or _G.ChocoboRaceMgr:IsChocoboRacePWorld() then
        return
    end
    
    -- 创角界面不显示
    -- if _G.IsDemoMajor then
	if _G.DemoMajorType > 0 then
        return
    end

    local Mode = _G.PWorldMgr:GetMode()
    if Mode ~= SceneModeDef.SceneModeUnlimited then
        self:StartSyncTipsTimer()
    end
end

function PWorldQuestMgr:StartSyncTipsTimer()
    -- print('zhg PWorldQuestMgr:StartSyncTipsTimer')
    self:EndSyncTipsTimer()
    local Val = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_ENTER_SCENE_X_SECOND_NTF_PROP_SYNC, "Value")
    local Time = Val and Val[1] or 0
    self.SyncTipsHdl = self:RegisterTimer(self.OnSyncTipsTimer, Time, 0, 1)
end

function PWorldQuestMgr:EndSyncTipsTimer()
    if self.SyncTipsHdl then
        self:UnRegisterTimer(self.SyncTipsHdl)
        self.SyncTipsHdl = false
    end
end

function PWorldQuestMgr:OnSyncTipsTimer()
    _G.MsgTipsUtil.ShowTipsByID(101051)
end
return PWorldQuestMgr