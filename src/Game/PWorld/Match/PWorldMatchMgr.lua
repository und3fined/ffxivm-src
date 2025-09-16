local LuaClass = require("Core/LuaClass")

local TimeUtil = require("Utils/TimeUtil")
local ProtoCS = require("Protocol/ProtoCS")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local PWorldEntDefine = require("Game/PWorld/Entrance/PWorldEntDefine")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local PworldCfg = require("TableCfg/PworldCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local SceneMode = ProtoCommon.SceneMode
local MsgTipsID = require("Define/MsgTipsID")
local MajorUtil = require("Utils/MajorUtil")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ProtoRes = require("Protocol/ProtoRes")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local ProfUtil = require("Game/Profession/ProfUtil")
local PWorldHelper = require("Game/PWorld/PWorldHelper")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SceneEnterDailyRandomCfg = require("TableCfg/SceneEnterDailyRandomCfg")
local LogableMgr = require("Common/LogableMgr")

---@type TeamMgr
local TeamMgr

local GameNetworkMgr
local PWorldMatchVM = nil
---@deprecated #TODO DELETE
local PWorldEntDetailVM
local PWorldEntVM
local LSTR = _G.LSTR

local MatchType = ProtoCS.MatchType
local MatchInfomationType = ProtoCS.MatchInfomation
local PrintTable = _G.table_to_string_block
local MatchObjTypeDef = ProtoCS.MatchObjType
local CS_CMD_MATCH = ProtoCS.CS_CMD.CS_CMD_MATCH
local SUB_MSG_ID = ProtoCS.CSSubMsgIDMatch
local MatchSideBarType = SidebarDefine.SidebarType.PWorldMatch


local GetMatchTypeObj = function()
    local HasTeam = _G.TeamMgr:IsInTeam()
    local MatchTypeObj = HasTeam and MatchObjTypeDef.MatchObjTypeTeam or MatchObjTypeDef.MatchObjTypeSingle
    return MatchTypeObj
end

local MakeDuty = function(EnterDutyType, EntID, Mode)
    local MatchTypeObj = GetMatchTypeObj()
    local IsRandom = PWorldEntUtil.IsDailyRandom(EnterDutyType)
    local Ret = {
        IsRandom = IsRandom,
        ID = EntID,
        Mode = Mode,
        MatchObj = MatchTypeObj,
    }

    return Ret
end

local ValidMatchClassTypes = {
    ProtoCommon.function_type.FUNCTION_TYPE_GUARD,
    ProtoCommon.function_type.FUNCTION_TYPE_ATTACK,
    ProtoCommon.function_type.FUNCTION_TYPE_RECOVER
}
local ValidMatchClassTypeSet = table.makeset(ValidMatchClassTypes)


---@class PWorldMatchMgr: LogableMgr
local PWorldMatchMgr = LuaClass(LogableMgr)

function PWorldMatchMgr:OnInit()
    self.Matches = {}
    self.MatchRanks = {}
    self.MatchChocobos = {}
    self.MatchCrystallines = {}
    self.MatchFrontlines = {}
    self.ServerMactchEstTimeData = {}
    self.LackProfListeners = {}
    self.LackProfFuncInfo = {}

    self.PunishStartTime = 0
    self.InValidMatchSet = {}

    self.CurCrystallineInterval = 0

    PWorldEntVM = require("Game/PWorld/Entrance/PWorldEntVM")
    PWorldMatchVM = require("Game/PWorld/Match/PWorldMatchVM")
    PWorldEntDetailVM = self:GetPWorldEntDetailVM()

    self:SetLogName("PWorldMatchMgr")
end

function PWorldMatchMgr:OnBegin()
	GameNetworkMgr = _G.GameNetworkMgr
    TeamMgr = require("Game/Team/TeamMgr")
end

function PWorldMatchMgr:OnEnd()
    self.Matches = {}
    self.MatchRanks = {}
    self.MatchChocobos = {}
    self.MatchCrystallines = {}
    self.MatchFrontlines = {}
    self.LackProfListeners = {}
    self.LackProfFuncInfo = {}
    self.InValidMatchSet = {}
    self.PunishStartTime = 0
    self.CurCrystallineInterval = 0
end

function PWorldMatchMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD_MATCH, SUB_MSG_ID.CSSubMsgIDMatch_Match,         self.OnMsgStartMatch)
    self:RegisterGameNetMsg(CS_CMD_MATCH, SUB_MSG_ID.CSSubMsgIDMatch_CancelMatch,   self.OnMsgCancelMatch)
    self:RegisterGameNetMsg(CS_CMD_MATCH, SUB_MSG_ID.CSSubMsgIDMatch_GetMatchInfo,  self.OnMsgQueryRankOrLackProf)
    self:RegisterGameNetMsg(CS_CMD_MATCH, SUB_MSG_ID.CSSubMsgIDMatch_Query,         self.OnMsgQueryMatch)
    self:RegisterGameNetMsg(CS_CMD_MATCH, SUB_MSG_ID.CSSubMsgIDMatch_Punishment,    self.OnMsgPunish)
end

function PWorldMatchMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.CounterInit,      self.OnCounterUpdate)
    self:RegisterGameEvent(_G.EventID.CounterUpdate,    self.OnCounterUpdate)
    self:RegisterGameEvent(_G.EventID.CounterClear,     self.OnCounterUpdate)

    self:RegisterGameEvent(_G.EventID.RoleLoginRes,     self.OnLogin)
    self:RegisterGameEvent(_G.EventID.PWorldExit,       self.OnPWorldExit)
    self:RegisterGameEvent(_G.EventID.UpdateQuest,  self.OnQuestUpdate)
    self:RegisterGameEvent(_G.EventID.TeamVoteEnterSceneEnd, self.OnVoteEnterSceneEnd)
end

function PWorldMatchMgr:OnRegisterTimer()
    self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

local function MergeLackProfQuery(Map)
    local Dict = {}
    for _, List in pairs(Map) do
        for _, EntID in pairs(List) do
            Dict[EntID] = true
        end
    end

    local Ret = {}
    for EntID in pairs(Dict) do
        local Duty = {
            ID = EntID,
            MatchObj = MatchObjTypeDef.MatchObjTypeSingle,
            IsRandom = true,
            Mode = PWorldEntUtil.GetRandDefaultMode()
        }
        table.insert(Ret, Duty)
    end

    return Ret
end

---@private
function PWorldMatchMgr:OnTimer(bForceUpdate)
    if self.PunishStartTime > 0 then
        local HasPunish = _G.PWorldEntDetailVM:UpdPunish()
        if not HasPunish then
            self.PunishStartTime = 0
        end
    end

    if self:IsMatching() then
        self:UpdateMatchTimeData()
    end

    self:CheckCrystallineMap()
end

---@deprecated
function PWorldMatchMgr:UpdateMatchTimeData()
    _G.EventMgr:SendEvent(_G.EventID.PWorldMatchTimeUpdate)

    local SideBarVMToUpdate = _G.SidebarMgr:GetSidebarItemVM(MatchSideBarType)
    if SideBarVMToUpdate then
        local Data = nil

        local function Update(MatchItems)
            for _, v in ipairs(MatchItems) do
                local NData = self:GetMatchTimeDataElement(v.EntID)
                if NData then
                    if Data == nil then
                        Data = NData
                    end
                    if Data.EstWaitTime > NData.EstWaitTime then
                        Data = NData
                    end
                end
            end
        end

        if self:GetCrystallineItemCnt() > 0 then
            Update(self.MatchCrystallines)
        else
            Update(self.Matches)
            if Data == nil then
                Update(self.MatchChocobos)
            end
        end
        
        if Data then
            SideBarVMToUpdate.Text2 = Data.EstDesc
            SideBarVMToUpdate.Tips  = LocalizationUtil.GetCountdownTimeForShortTime(Data.TotalWaitTime, "mm:ss")
        end
    end
end


function PWorldMatchMgr:GetMatchTimeDataElement(ResID)
    local BeginTime = self:GetMatchWaitTime(nil, ResID)
    if BeginTime == nil or BeginTime == 0 then
        return
    end

    local EstWaitTime = self:GetMatchEstimateWaitTime(ResID) or 0
    return {
        EstWaitTime = EstWaitTime,
        EstDesc = self:GetMatchEstimateTimeDesc(ResID),
        TotalWaitTime = (BeginTime == nil or BeginTime == 0) and 0 or math.clamp(_G.TimeUtil.GetServerTime() - BeginTime, 0, math.maxinteger)
    }
end

function PWorldMatchMgr:GetMatchEstimateWaitTime(EntID)
    if EntID == nil then
        return
    end

    for _, v in ipairs(self.Matches or {}) do
        if v.EntID == EntID then
            return v.WaitTime
        end
    end

    for _, v in pairs(self.MatchChocobos or {}) do
        if v.EntID == EntID then
            return v.WaitTime
        end
    end

    for _, v in pairs(self.MatchCrystallines or {}) do
        if v.EntID == EntID then
            return v.WaitTime
        end
    end
end

function PWorldMatchMgr:GetMatchEstimateTimeDesc(EntID)
    local Time <const> = self:GetMatchEstimateWaitTime(EntID)
    if EntID == self:GetMatchChocoboEntID() then
       return string.format(_G.LSTR(1320012), Time)
    end

    local WaitTime <const> = _G.TimeUtil.GetServerTime() - (self:GetMatchWaitTime(nil, EntID) or 0)

    -- 水晶冲突不走PVE的逻辑
    local Type = SceneEnterCfg:FindValue(EntID, "TypeID")
    if PWorldEntUtil.IsCrystalline(Type) then
        return self:GetCrystallineWaitTimeDesc(WaitTime)
    end

    if Time == nil or Time == 0 or Time >= 300 then
        return WaitTime >= 540 and _G.LSTR(1320018) or _G.LSTR(1320017)
    end

    if WaitTime < 240 then
        return _G.LSTR(1320016)
    elseif WaitTime < 540 then
        return _G.LSTR(1320017)
    end

    return _G.LSTR(1320018)
end

function PWorldMatchMgr:GetCrystallineWaitTimeDesc(WaitTime)
    if WaitTime == nil then return LSTR(1320250) end

    if WaitTime < 120 then
        local Minute = math.ceil((WaitTime / 60))
        return string.format(LSTR(1320249), Minute)
    elseif WaitTime < 180 then
        return LSTR(1320250)
    elseif WaitTime < 300 then
        return LSTR(1320251)
    else
        return LSTR(1320252)
    end
end

function PWorldMatchMgr:CheckCrystallineMap()
    if self.CurCrystallineInterval == 0 then return end

    if self:GetCrystallineItemCnt() == 0 then
        self.CurCrystallineInterval = 0
        return
    end

    local EntPolPVP = PWorldEntUtil.GetPol(nil, ProtoCommon.ScenePoolType.ScenePoolPVPCrystal)
    if EntPolPVP then
        local IsInEventTime, _, CurIntervalData, _ = EntPolPVP:CheckIsInEventTime()
        if IsInEventTime then
            if CurIntervalData.Interval ~= self.CurCrystallineInterval then
                MsgTipsUtil.ShowTips(string.format(LSTR(1320208), CurIntervalData.MapName))
                self.CurCrystallineInterval = CurIntervalData.Interval
                return
            end
        else
            local ShowTips = false
            for _, Match in pairs(self.MatchCrystallines or {}) do
                local EntCfg = SceneEnterCfg:FindCfgByKey(Match.EntID)
                if EntCfg then
                    self:ReqCancelMatch(EntCfg.TypeID)
                end

                if not ShowTips then
                    MsgTipsUtil.ShowTipsByID(338043)  -- 活动时间结束终止匹配
                    ShowTips = true
                end
            end
            PWorldEntDetailVM:UpdateJoinRelatedInfo() -- 刷新UI显示
            self.CurCrystallineInterval = 0
        end
    end
end

-------------------------------------------------------------------------------------------------------
---@see EventHandles
function PWorldMatchMgr:OnLogin(Params)
    self.bReconnect = Params and Params.bReconnect
    self.TipPunishCount = 0
    self.DutyMatchCount = 0
    self.PVPMatchCount = 0
    self.LastRankQueryUpdateTime = os.time()
    self:ReqQueryMatch()
    self:ReqPunish()
end
function PWorldMatchMgr:OnQuestUpdate(Params)
end

function PWorldMatchMgr:OnVoteEnterSceneEnd(EntID)
    if self:IsEntMatching(EntID) then
       self:InnerRegisterMatchGuide(EntID)
    end
end

---@private
function PWorldMatchMgr:OnPWorldExit()
    self:OnTimer()
end

--[[
    NetMsgHandle
]]
function PWorldMatchMgr:OnMsgStartMatch(MsgBody)
    local Msg = MsgBody.Match
    if not Msg then
        return
    end
end

function PWorldMatchMgr:OnMsgCancelMatch(MsgBody)
    local Msg = MsgBody.Cancel
    if not Msg then
        return
    end

    local Duty = Msg.Duty
    if Duty then
        local EntIDs = Duty.SceneID or {}
        local bRandomEnt = Duty.IsRandom
        self:OnCancelMatch(EntIDs, bRandomEnt)
        local Reason = Duty.Reason
        for _, EntID in pairs(EntIDs) do
            if Reason == ProtoCS.CancelReason.CancelBySelf then
                if TeamMgr:IsInTeam() then
                    local Name = PWorldEntUtil.GetPWorldEntName(EntID, bRandomEnt)
                    _G.MsgTipsUtil.ShowTips(string.format(LSTR(1320013), Name))
                else
                    _G.MsgTipsUtil.ShowTips(LSTR(1320014))
                end
                break
            end
        end

        if Reason == ProtoCS.CancelReason.GuideDailyRandomTimeout then
            _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldGuideCancel, nil)
        elseif Reason == ProtoCS.CancelReason.TeamMemLogout then
            _G.MsgTipsUtil.ShowTipsByID(103106)
        elseif Reason == ProtoCS.CancelReason.SceneMatchTimeout then
            _G.MsgTipsUtil.ShowTipsByID(146075)
        end
    end

    local Chocobo = Msg.Chocobo
    if Chocobo then
        self:CleanMatchChocoboAndUpdateInfo()
        local Reason = Chocobo.Reason
        if Reason == ProtoCS.CancelReason.CancelBySelf then
            if TeamMgr:IsInTeam() then
                _G.MsgTipsUtil.ShowTips(LSTR(1320015))
            else
                _G.MsgTipsUtil.ShowTips(LSTR(1320014))
            end
        end
    end

    local Crystal = Msg.Crystal
    if Crystal then
        self:CleanCrystalMatchAndUpdateInfo()
        local Reason = Msg.Reason
        if Reason == ProtoCS.CancelReason.CancelBySelf then
            _G.MsgTipsUtil.ShowTips(LSTR(1320014))
        end
    end
end

function PWorldMatchMgr:OnMsgQueryRankOrLackProf(MsgBody)
    local Msg = MsgBody.State
    if not Msg then
        return
    end

    local QueryType = Msg.MInfo
    if QueryType == MatchInfomationType.MatchInfoRanking then
        local Ranking = Msg.Rankings
        local RankInfo = Ranking.DMInfo
        self:SetRankInfo(RankInfo)
    elseif QueryType == MatchInfomationType.MatchInfoLackFunc then
        local Funcs = Msg.Funcs
        local FuncInfo = Funcs.DMInfo
        self:SetLackProfFuncInfo(FuncInfo)
    end
end

local function MakeMatchCacheItem(IsRandom, SceneID, Prof, Level, Mode)
    Mode = IsRandom and PWorldEntUtil.GetRandDefaultMode() or Mode
    local Item = {
        IsRandom = IsRandom,
        EntID = SceneID,
        Prof = Prof,
        Level = Level,
        Mode = Mode
    }

    return Item
end

local function TryPopStartMatchTips(EntID, IsRandom, Reason)
    if Reason ~= ProtoCS.QueryMatchType.QueryMatchTypeMatch then
        return
    end

    if PWorldMatchMgr:GetMatchItem(EntID, true) ~= nil then
        return
    end

    if TeamMgr:IsInTeam() then
        local Name = PWorldEntUtil.GetPWorldEntName(EntID, IsRandom)
        _G.MsgTipsUtil.ShowTips(string.format(LSTR(1320023), Name))
    end
end

function PWorldMatchMgr:OnMsgQueryMatch(MsgBody)
    local FieldQuery = MsgBody.Query
    local Reason = (FieldQuery or {}).Reason
    local Convert = {}
    local CrystallineMatch = {}
    local Chocobos = {}

    for _, Info in pairs(((FieldQuery or {}).Datas or {}).Infos or {}) do
        local Duty = Info.Duty
        if Duty then
            if not table.is_nil_empty(Duty.Random) then
                local Random = Duty.Random
                local EntID = Random.ID
                local Prof = Random.Prof
                local Level = Random.Level
                local CacheItem = MakeMatchCacheItem(true, EntID, Prof, Level, nil)
                CacheItem.BeginTime = Random.BeginTime
                CacheItem.WaitTime = Random.WaitTime
                table.insert(Convert, CacheItem)
                TryPopStartMatchTips(EntID, true, Reason)
            else
                if Duty.NotRandom == nil then
                   _G.FLOG_ERROR("PWorldMatchMgr:OnMsgQueryMatch error" .. PrintTable(MsgBody, 10))
                end
                local NotRandomDutys = Duty.NotRandom and Duty.NotRandom.Dutys or {}
                for _, Item in pairs(NotRandomDutys) do
                    local SceneID = Item.SceneID
                    local Prof = Item.Prof
                    local Level = Item.Level
                    local Mode = Item.Mode
                    local CacheItem = MakeMatchCacheItem(false, SceneID, Prof, Level, Mode)
                    CacheItem.BeginTime = Item.BeginTime
                    CacheItem.WaitTime = Item.WaitTime
                    table.insert(Convert, CacheItem)
                    TryPopStartMatchTips(SceneID, false, Reason)
                end
            end
        end

        local Chocobo = Info.Chocobo
        if Chocobo ~= nil then
            local CacheItem = self:GetMatchChocoboItem(Chocobo.ID)
            if CacheItem == nil then
                CacheItem = {}
                CacheItem.EntID = Chocobo.ID
                CacheItem.IsRandom = Chocobo.IsRandom
                CacheItem.BeginTime = Chocobo.BeginTime
                CacheItem.WaitTime = self:GetMatchChocoboWaitTime()
                table.insert(Chocobos, CacheItem)
            end
        end

        local Crystal = Info.Crystal
        if Crystal then
            local ID = 0
            local EntPolPVP = nil
            if Crystal.Mode == ProtoCS.PvPColosseumMode.Exercise then
                ID = 1218010
                EntPolPVP = PWorldEntUtil.GetPol(ID, ProtoCommon.ScenePoolType.ScenePoolPVPCrystal)
            elseif Crystal.Mode == ProtoCS.PvPColosseumMode.Rank then
                ID = 1218020
                EntPolPVP = PWorldEntUtil.GetPol(ID, ProtoCommon.ScenePoolType.ScenePoolPVPCrystalRank)
            end
            if EntPolPVP then
                local _, _, CurIntervalData, _ = EntPolPVP:CheckIsInEventTime(ID)
                if CurIntervalData then
                    self.CurCrystallineInterval = CurIntervalData.Interval
                end
            end
            local CacheItem = {
                EntID = ID,
                Mode = Crystal.Mode,
                Prof = Crystal.ProfID,
                Level = Crystal.Level,
                BeginTime = Crystal.BeginTime,
                WaitTime = Crystal.WaitTime,
            }
            table.insert(CrystallineMatch, CacheItem)
        end
    end

    self.MatchChocobos = Chocobos
    -- 断线重连Query如果没有数据，没法清空水晶冲突匹配数据，所以用一个默认为空的表清理数据
    self.MatchCrystallines = CrystallineMatch

    self:SetMatchInfo(Convert)
    self.bInStartQueryMatch = nil
    self:EndStartMatchTimeoutTimer()
end

function PWorldMatchMgr:OnMsgPunish(MsgBody)
    local Msg = MsgBody.Punishment
    if not Msg then
        return
    end

    local StartTime = Msg.StartTime
    self:SetPunishTime(StartTime)

    local RefuseTimes = tonumber(Msg.RefuseTimes)
    if RefuseTimes and (RefuseTimes > 0) then
        self.TipPunishCount = (self.TipPunishCount or 0) + 1
        if (self.bReconnect and self.TipPunishCount == 1)  or _G.PWorldMgr:CurrIsInDungeon() or ((self.DutyMatchCount or 0) == 0 and (self.PVPMatchCount or 0) == 0) then
           return
        end
        if RefuseTimes == 1 then
            _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldMatchCancelPunish_1, nil)
        elseif RefuseTimes == 2 then
            _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldMatchCancelPunish_2, nil)
        elseif RefuseTimes == 3 then
            _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldMatchCancelPunish_3, nil)
        else
            _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldMatchCancelPunish_n, nil)
        end
    end
end

--[[
    Request
]]
function PWorldMatchMgr:ReqMatch(SubCmd, Params)
    local MsgBody = Params
    MsgBody.SubCmd = SubCmd
    MsgBody.mType = MatchType.MatchDuty
	GameNetworkMgr:SendMsg(CS_CMD_MATCH, SubCmd, MsgBody)
end


--[[
    Public Request
]]

--- @param Type common.ScenePoolType
function PWorldMatchMgr:ReqStartMatch(Type, EntID, Mode, SubType)
    local CommonStateUtil = require("Game/CommonState/CommonStateUtil")

    if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_MATCH, true) then
		self:LogWarn("unable to req match for behavior check failed, type %s ent id %s mode %s sub type %s", Type, EntID, Mode, SubType)
		return
	end

    local Params = {}
    if Type == ProtoCommon.ScenePoolType.ScenePoolChocobo then
        Params.Match = {
            Chocobo = {ID = EntID, IsRandom = SubType == ProtoCommon.ScenePoolType.ScenePoolChocoboRandomTrack}
        }
        Params.mType = MatchType.ChocoboMatch
    elseif PWorldEntUtil.IsCrystalline(Type) then
        local Mode = nil
        if PWorldEntUtil.IsCrystallineExercise(Type) then
            Mode = ProtoCS.PvPColosseumMode.Exercise
        elseif PWorldEntUtil.IsCrystallineRank(Type) then
            Mode = ProtoCS.PvPColosseumMode.Rank
        end

        Params.Match = {
            Crystal = {
                Mode = Mode,
                BeginTime = TimeUtil.GetServerTime(),
            }
        }
        Params.mType = MatchType.CrystalConflict
    else
        Params.Match = {
            Duty = MakeDuty(Type, EntID, Mode)
        }
        Params.mType = MatchType.MatchDuty
    end

    Params.SubCmd = SUB_MSG_ID.CSSubMsgIDMatch_Match
	GameNetworkMgr:SendMsg(CS_CMD_MATCH, SUB_MSG_ID.CSSubMsgIDMatch_Match, Params)

    if Params.mType == MatchType.MatchDuty then
        self.DutyMatchCount = (self.DutyMatchCount or 0) + 1
    elseif Params.mType == MatchType.CrystalConflict then
        self.PVPMatchCount = (self.PVPMatchCount or 0) + 1
    end

    self.bInStartQueryMatch = true
    self:EndStartMatchTimeoutTimer()
    self.TimerIdTimeoutStartQueryMatch = self:RegisterTimer(function()
        self.TimerIdTimeoutStartQueryMatch = nil
    end, 3)
end

function PWorldMatchMgr:EndStartMatchTimeoutTimer()
    if self.TimerIdTimeoutStartQueryMatch then
        self:UnRegisterTimer(self.TimerIdTimeoutStartQueryMatch)
    end
    self.TimerIdTimeoutStartQueryMatch = nil
end

function PWorldMatchMgr:ReqCancelMatch(Type, EntID, Mode)
    local Params = {}
    if Type == ProtoCommon.ScenePoolType.ScenePoolChocobo then
        Params.Cancel = {
            Chocobo = {ID = EntID, IsRandom = Mode ~= SceneMode.SceneModeNormal}
        }
        Params.mType = MatchType.ChocoboMatch
    elseif PWorldEntUtil.IsCrystalline(Type) then
        local GameMode = nil
        if PWorldEntUtil.IsCrystallineExercise(Type) then
            GameMode = ProtoCS.PvPColosseumMode.Exercise
        elseif PWorldEntUtil.IsCrystallineRank(Type) then
            GameMode = ProtoCS.PvPColosseumMode.Rank
        end

        Params.Cancel = {
            Crystal = {
                Mode = GameMode,
            }
        }
        Params.mType = MatchType.CrystalConflict
    else
        self:SetInValidMatchSet(EntID, true)

        Params.Cancel = {
            Duty = MakeDuty(Type, EntID, Mode)
        }
        Params.mType = MatchType.MatchDuty
    end

    Params.SubCmd = SUB_MSG_ID.CSSubMsgIDMatch_CancelMatch
	GameNetworkMgr:SendMsg(CS_CMD_MATCH, SUB_MSG_ID.CSSubMsgIDMatch_CancelMatch, Params)

    self.bStartCancelMatch = true
end

--- @param Type common.ScenePoolType
--- @param InfoType MatchInfomation
function PWorldMatchMgr:ReqQueryMatchInfo(Dutys, InfoType)
    local Params = {}

    Params.State = {
        Dutys = {
            Dutys = Dutys
        },
        MInfo = InfoType
    }

    self:ReqMatch(SUB_MSG_ID.CSSubMsgIDMatch_GetMatchInfo, Params)
end

function PWorldMatchMgr:ReqQueryRankMatch()
    local Dutys = {}
    for _, MatchInfo in pairs(self.Matches or {}) do
        if self:IsValidMatch(MatchInfo.EntID) then
            local Duty = {
                MatchObj = GetMatchTypeObj(),
                IsRandom = MatchInfo.IsRandom,
                ID = MatchInfo.EntID,
                Mode = MatchInfo.Mode
            }
            table.insert(Dutys, Duty)
        end
    end

    if #Dutys > 0 then
        self:ReqQueryMatchInfo(Dutys, MatchInfomationType.MatchInfoRanking)
    end
end

---@deprecated
function PWorldMatchMgr:ReqQueryLackFunc()
    local Dutys = MergeLackProfQuery(self.LackProfListeners)

    self:ReqQueryMatchInfo(Dutys, MatchInfomationType.MatchInfoLackFunc)
end

function PWorldMatchMgr:BatchQueryLackProf(bForce)
    local bFlag = false
    if self.CachedUnlockEIDs == nil then
        self.CachedUnlockEIDs = {}
        bFlag = true
    end

    self:LogInfo("batch update lack prof, force: %s", bForce)

    local PWorldEntPol = require("Game/PWorld/Entrance/Policy/PWorldEntPol")
    local function IsPassQuest(ID, bRand)
        if ID then
            return self.CachedUnlockEIDs[ID] or (bRand and PWorldEntUtil.IsDailyRandomUnlocked(ID)) or (bRand ~= true and PWorldEntPol.IsPassPreQuest(ID, false))
        end
    end

    local OldPassCount = 0
    for _, v in pairs(self.CachedUnlockEIDs) do
        if v then
            OldPassCount = OldPassCount + 1
        end
    end

    local Dutys = {}
    local Mode = PWorldEntUtil.GetRandDefaultMode()

    for _, Cfg in ipairs(SceneEnterDailyRandomCfg:FindAllCfg() or {}) do
        if IsPassQuest(Cfg.ID, true) then
            self.CachedUnlockEIDs[Cfg.ID] = true
            table.insert(Dutys, {
                ID = Cfg.ID,
                MatchObj = MatchObjTypeDef.MatchObjTypeSingle,
                IsRandom = true,
                Mode = Mode
            })
        end
    end

    for _, Cfg in ipairs(SceneEnterCfg:FindAllCfg() or {}) do
        if Cfg.TypeID and Cfg.TypeID > 0 and Cfg.TypeID < 5 and IsPassQuest(Cfg.ID, false) then
            self.CachedUnlockEIDs[Cfg.ID] = true
            table.insert(Dutys, {
                ID = Cfg.ID,
                MatchObj = MatchObjTypeDef.MatchObjTypeSingle,
                IsRandom = false,
                Mode = Mode
            })
        end
    end

    bFlag = bFlag or #Dutys ~= OldPassCount
    if #Dutys > 0 and (bForce or bFlag) then
        self:ReqQueryMatchInfo(Dutys, MatchInfomationType.MatchInfoLackFunc)
    end
end

function PWorldMatchMgr:ReqQueryMatch()
    local Params = {}
    Params.Query = {
    }
    self:ReqMatch(SUB_MSG_ID.CSSubMsgIDMatch_Query, Params)
end

function PWorldMatchMgr:ReqPunish()
    self:ReqMatch(SUB_MSG_ID.CSSubMsgIDMatch_Punishment, {Punishment={}})
end

--[[
    Private
]]
-- Match
function PWorldMatchMgr:AddMatchInfo(Info)
    -- Avoid repeating match info
    self:RemoveMatchInfo(Info, true)
    table.insert(self.Matches, Info)
    self:UpdateMatchInfo()
end

function PWorldMatchMgr:RemoveMatchInfo(Info, NoSync)
    -- Promise to use ID as key
    table.array_remove_item_pred(self.Matches, function(Item)
        return Item.EntID == Info.EntID
    end)

    self:SetInValidMatchSet(Info.EntID, nil)

    if not NoSync then
        self:UpdateMatchInfo()
    end
end

---@private
function PWorldMatchMgr:OnCancelMatch(EntIDs, bRandom)
    if bRandom then
        self.Matches = {}
    else
        for _, ID in ipairs(EntIDs) do
            table.array_remove_item_pred(self.Matches, function(Item)
                return Item.EntID == ID
            end)

            self:SetInValidMatchSet(ID, nil)
        end
    end

    if #(self.Matches or {}) == 0 then
        self:ClearMatchSet()
    end

    self:UpdateMatchInfo()
    self.bStartCancelMatch = nil
end

function PWorldMatchMgr:CleanMatchChocoboAndUpdateInfo()
    self.MatchChocobos = {}
    self:UpdateMatchInfo()
end

function PWorldMatchMgr:CleanCrystalMatchAndUpdateInfo()
    self.MatchCrystallines = {}
    self:UpdateMatchInfo()
end

function PWorldMatchMgr:SetMatchInfo(V)
    local OldMatches = table.clone(self.Matches or {})
    self.Matches = V
    self:UpdateMatchInfo()
    self:OnTimer(true)
    -- UPDATE RANK
    self:ReqQueryRankMatch()

    if self.MatchTimeoutNavData and self.Matches then
        local InvalidMatches = {}
        for EntID in pairs(self.MatchTimeoutNavData) do
            if not table.find_item(self.Matches, EntID, "EntID") then
               table.insert(InvalidMatches, EntID)
            end
        end
        for _, v in ipairs(InvalidMatches) do
            self:RemoveRobotMatchNav(v)
        end
    end

    for _, v in ipairs(self.Matches or {}) do
        if not table.find_item(OldMatches, v.EntID, "EntID") then
            self:InnerRegisterMatchGuide(v.EntID)
        end
    end
end

function PWorldMatchMgr:UpdateMatchInfo()
    if not self.bInStartQueryMatch and not self.bStartCancelMatch then
        self:SetMatchSideBar(self:IsMatching())
        self:ShowMatchView(false)
    else
        self:SetMatchSideBar(false)
        self:ShowMatchView(self:IsMatching())
    end

    self:NtfUpdateMatch()
end

function PWorldMatchMgr:NtfUpdateMatch()
    PWorldMatchVM:UpdateVM()
    PWorldEntDetailVM:UpdMatch()
    PWorldEntDetailVM:UpdateForbidText()
    PWorldEntVM:UpdMatch()

	_G.EventMgr:SendEvent(_G.EventID.PWorldMatchRandUpd)
end

-- Rank
function PWorldMatchMgr:SetRankInfo(V)
    self.MatchRanks = V

    PWorldMatchVM:UpdateMatchRank()
	_G.EventMgr:SendEvent(_G.EventID.PWorldMatchRandUpd)
end

-- LackProf
function PWorldMatchMgr:SetLackProfFuncInfo(V)
    self.LackProfFuncInfo = V or {}

    local NextUpdateTime = 0
    if #self.LackProfFuncInfo > 0 then
        NextUpdateTime = math.max(NextUpdateTime, self.LackProfFuncInfo[1].NextTime or 0)
    end

    local ServerTime = _G.TimeUtil.GetServerTime()
    if NextUpdateTime == 0 or NextUpdateTime <= ServerTime then
        NextUpdateTime = ServerTime + 300
    end

	_G.EventMgr:SendEvent(_G.EventID.PWorldMatchLackProfUpd, NextUpdateTime)

    PWorldMatchVM:UpdateLackProf()
end

-- Punish
function PWorldMatchMgr:SetPunishTime(V)
    self.PunishStartTime = V
    self:GetPWorldEntDetailVM():UpdPunish()
end

---@private
function PWorldMatchMgr:OnCounterUpdate()
    self:NtfRewardUpdate()
end

-- Rewards
function PWorldMatchMgr:NtfRewardUpdate()
    self:GetPWorldEntDetailVM():UpdateRewards()
	_G.EventMgr:SendEvent(_G.EventID.PWorldRewardsUpd)
end

---@return PWorldEntDetailVM
function PWorldMatchMgr:GetPWorldEntDetailVM()
    return require("Game/PWorld/Entrance/PWorldEntDetailVM")
end

--[[
    Public
]]
function PWorldMatchMgr:SetMatchSideBar(IsVisible)
    local SidebarMgr = require("Game/Sidebar/SidebarMgr")
    local IsExist = SidebarMgr:GetSidebarItemVM(MatchSideBarType) ~= nil

    if IsVisible then
        if IsExist then
            return
        end
        SidebarMgr:AddSidebarItem(MatchSideBarType, nil, nil, nil, false, LSTR(1320008))
        _G.SidebarMgr:TryOpenSidebarMainWin()
    else
        SidebarMgr:RemoveSidebarItem(MatchSideBarType)
    end
end

function PWorldMatchMgr:ShowMatchView(IsVisible)
    if IsVisible then
        _G.UIViewMgr:ShowView(_G.UIViewID.PWorldMatchDetail)
    else
        _G.UIViewMgr:HideView(_G.UIViewID.PWorldMatchDetail)
    end
end

--- @return number
function PWorldMatchMgr:GetMatchItemCnt()
    return #(self:GetMatchItems() or {})
end

function PWorldMatchMgr:GetMatchChocoboItemCnt()
    return #(self:GetMatchChocoboItems() or {})
end

function PWorldMatchMgr:GetMatchChocoboEntID()
    if self.MatchChocobos ~= nil and self.MatchChocobos[1] ~= nil and self.MatchChocobos[1].EntID ~= nil then
        return self.MatchChocobos[1].EntID
    end

    return -1; -- 0是随机，这里返回-1
end

function PWorldMatchMgr:GetMatchItems()
    if not self.Matches or table.empty(self.Matches) then
        return {}
    end

    if self:IsDailyRandomStat() then
        return {self.Matches[1].EntID}
    end

    local Ret = {}

    for _, Match in pairs(self.Matches) do
        table.insert(Ret, Match.EntID)
    end

    return Ret
end

function PWorldMatchMgr:GetMatchChocoboItems()
    if not self.MatchChocobos or table.empty(self.MatchChocobos) then
        return {}
    end

    local Ret = {}

    for _, Match in pairs(self.MatchChocobos) do
        table.insert(Ret, Match.EntID)
    end

    return Ret
end

function PWorldMatchMgr:GetCrystallineItems()
    local Ret = {}

    for _, Match in pairs(self.MatchCrystallines or {}) do
        table.insert(Ret, Match.EntID)
    end

    return Ret
end

function PWorldMatchMgr:GetCrystallineItemCnt()
    return #(self:GetCrystallineItems() or {})
end

function PWorldMatchMgr:GetFrontlineItems()
    local Ret = {}

    for _, Match in pairs(self.MatchFrontlines or {}) do
        table.insert(Ret, Match.Mode)
    end

    return Ret
end

function PWorldMatchMgr:GetFrontlineItemCnt()
    return #(self:GetFrontlineItems() or {})
end

function PWorldMatchMgr:IsPWorldMatching(EntID, TypeID)
    local Info = nil
    if PWorldEntUtil.IsCrystalline(TypeID) then
        Info = table.find_item(self.MatchCrystallines, EntID, "EntID")
    elseif TypeID == ProtoCommon.ScenePoolType.ScenePoolChocobo then
        Info = table.find_item(self.MatchChocobos, EntID, "EntID")
        if Info ~= nil and Info.IsRandom ~= nil and Info.IsRandom == false then
            return true
        else
            return false
        end
    elseif TypeID == ProtoCommon.ScenePoolType.ScenePoolChocoboRandomTrack then
        -- 随机赛道的EntID = 0
        Info = table.find_item(self.MatchChocobos, 0, "EntID")
        if Info ~= nil and Info.IsRandom ~= nil then
            return Info.IsRandom == true
        end
    else
        Info = table.find_item(self.Matches, EntID, "EntID")
    end
    return Info ~= nil
end

function PWorldMatchMgr:GetMatchItem(EntID, Ref)
    local Item = table.find_item(self.Matches or {}, EntID, "EntID")
    if Ref then
        return Item
    end

    return table.deepcopy(Item)
end

function PWorldMatchMgr:GetMatchChocoboItem(EntID, Ref)
    local Item = table.find_item(self.MatchChocobos or {}, EntID, "EntID")
    if Ref then
        return Item
    end

    return table.deepcopy(Item)
end

function PWorldMatchMgr:GetCrystallineItem(EntID)
    local Item = nil
    if EntID then
        Item= table.find_item(self.MatchCrystallines or {}, EntID, "EntID")
    end

    return table.deepcopy(Item)
end

-- Match rank info query
function PWorldMatchMgr:GetMatchRank(EntID, EntTy)
    if PWorldEntUtil.IsDailyRandom(EntTy) and self.MatchRanks and self.MatchRanks[1] then
        if self.MatchRanks and self.MatchRanks[1] then
            return self.MatchRanks[1].Ranking
        end

        return 0
    end

    local Info = table.find_item(self.MatchRanks, EntID, "SceneID")
    if not Info then
        return 0
    end

    return Info.Ranking
end

---@deprecated
function PWorldMatchMgr:SubLackProfUpd(Listener, List)
    -- for _, ID in pairs(List or {}) do
    --     local Cfg = SceneEnterDailyRandomCfg:FindCfgByKey(ID)
    --     if not Cfg then
    --         _G.FLOG_ERROR("PWorldMatchMgr:SubLackProfUpd DailyRandomCfg not this ID = " .. tostring(ID))
    --         return
    --     end
    -- end

    -- self.LackProfListeners[Listener] = List
    -- self:ReqQueryLackFunc()
    -- self:BatchQueryLackProf(true)
end

---@deprecated
function PWorldMatchMgr:UnSubLackProfUpd(Listener)
    -- if not self.LackProfListeners then
    --     return
    -- end
    -- self.LackProfListeners[Listener] = nil
end

-- Lack prof query
function PWorldMatchMgr:GetLackProfFunc(EntID)
    return (table.find_item(self.LackProfFuncInfo, EntID, "SceneID") or {}).LackFunc
end

local GetCounter = function (ID)
    return ID and tonumber(_G.CounterMgr:GetCounterCurrValue(ID)) or 0
end

-- Rewards query
-- 日随
function PWorldMatchMgr:HasDailyRewardRecv(EntID)
    local Cfg = SceneEnterDailyRandomCfg:FindCfgByKey(EntID)
    local CounterCfg = require("TableCfg/CounterCfg")
    local CounterID = Cfg and Cfg.Counter or nil
    local CCfg = CounterCfg:FindCfgByKey(CounterID)
    if CCfg then
        return GetCounter(CounterID) >= (CCfg.SumLimit or 1)
    end
end

-- 首通
function PWorldMatchMgr:HasPassRewardRecv(EntID)
    local Cfg = PworldCfg:FindCfgByKey(EntID)
    return GetCounter(Cfg and Cfg.SucceedCounterID or nil) > 0
end

-- State query
function PWorldMatchMgr:IsDailyRandomStat()
    if not self.Matches then
        _G.FLOG_ERROR("PWorldMatchMgr:IsDailyRandomStat has not data")
        return
    end

    -- All the elements of matches array are of the same type
    local Sample = self.Matches[1]
    if not Sample then
        _G.FLOG_ERROR("PWorldMatchMgr:IsDailyRandomStat has not sample")
        return
    end

    return Sample.IsRandom
end

function PWorldMatchMgr:IsMatching()
    return self:GetMatchItemCnt() > 0 or self:GetMatchChocoboItemCnt() > 0 or self:GetCrystallineItemCnt() > 0
end

function PWorldMatchMgr:IsEntMatching(EntID, EntType)
    if EntID == nil then
       return false
    end

    for _, v in ipairs(self.Matches or {}) do
        if v.EntID == EntID then
           return  true
        end
    end
end

-- InValid
function PWorldMatchMgr:SetInValidMatchSet(EntID, V)
    self.InValidMatchSet[EntID] = V
end

function PWorldMatchMgr:ClearMatchSet()
    self.InValidMatchSet = {}
end

function PWorldMatchMgr:IsValidMatch(EntID)
    return self.InValidMatchSet[EntID] ~= true
end

function PWorldMatchMgr:PauseSideBar()
    self:SetMatchSideBar(false)
end

function PWorldMatchMgr:TryResumeSideBar()
    if self:IsMatching() then
        self:SetMatchSideBar(true)
    end
end

function PWorldMatchMgr:GetMatchWaitTime(_, EntID)
    for _, v in pairs(self.Matches or {}) do
        if v.EntID == EntID then
            return v.BeginTime
        end
    end

    for _, v in pairs(self.MatchChocobos or {}) do
        if v.EntID == EntID then
            return v.BeginTime
        end
    end

    for _, v in pairs(self.MatchCrystallines) do
        if v.EntID == EntID then
            return v.BeginTime
        end
    end

    return 0
end


function PWorldMatchMgr:GetMatchChocoboWaitTime()
    local ForecastCfg = GameGlobalCfg:FindValue(ProtoRes.Game.game_global_cfg_id.GAME_CFG_CHOCOBO_RACE_MATCH_FORECAST_TIME, "Value")
    local ForecastTime = ForecastCfg and ForecastCfg[1] or 45
    local DisturbanceCfg = GameGlobalCfg:FindValue(ProtoRes.Game.game_global_cfg_id.GAME_CFG_CHOCOBO_RACE_MATCH_DISTURBANCE_TIME, "Value")
    local DisturbanceTime = DisturbanceCfg and DisturbanceCfg[1] or 5

    return ForecastTime + math.random(0, DisturbanceTime)
end

function PWorldMatchMgr:IsRobotMatchUnChecked(EntID)
    if self.RobotMatchUnCheckMap and EntID then
       return self.RobotMatchUnCheckMap[EntID] == true
    end
end

function PWorldMatchMgr:SetUseRobotMatch(EntID, bUse)
    local bChanged
    if EntID then
       if self.RobotMatchUnCheckMap == nil then
            self.RobotMatchUnCheckMap = {}
       end

       bChanged = self.RobotMatchUnCheckMap[EntID] ~= (not bUse)
       self.RobotMatchUnCheckMap[EntID] = not bUse
    end

    if EntID and not bUse then
        self:RemoveRobotMatchNav(EntID)
    end

    if self.IsRobotMatchNeed(EntID) then
        if bChanged and bUse then
            self:InnerRegisterMatchGuide(EntID)
        end
        PWorldMatchVM:UpdateMatchGuide()
    end
end

function PWorldMatchMgr:RegisterMatchGuide(EntID, Callback)
    if not self:IsEntMatching(EntID) then
       return
    end

    if self.MatchTimeoutNavData == nil then
        self.MatchTimeoutNavData = {}
    end

    -- local WaitTime = self:GetMatchWaitTime(nil, EntID)
    self:RemoveRobotMatchNav(EntID)

    local ECfg = SceneEnterCfg:FindCfgByKey(EntID)
    if ECfg == nil or ECfg.MatchTimeoutGuideType == 0 then
       return
    end

    local Interval <const> = ECfg.MatchTimeoutGuideTime or 0
    if Interval <= 0 then
       return
    end

    do
    -- if WaitTime and WaitTime > 0 then
        -- local Secs = WaitTime + Interval - os.time()
        local Secs = Interval
        if Secs > 0 then
            local TimerID = self:RegisterTimer(function()
                if not _G.PWorldVoteMgr:IsVoteEnterScenePending() then
                    Callback()
                end
            end, Secs)
            self.MatchTimeoutNavData[EntID] = {
                TimerID = TimerID
            }
            if TimerID then
               return true
            end
        end
    end
end

---@private
function PWorldMatchMgr:InnerRegNavRobotMatch(EntID)
    if not self.IsRobotMatchNeed(EntID)  or self:IsRobotMatchUnChecked(EntID) then
       return
    end

    return self:RegisterMatchGuide(EntID, function()
        if self:IsRobotMatchUnChecked(EntID) or not self:IsEntMatching(EntID) then
            self:RemoveRobotMatchNav(EntID)
            return
        end

        if _G.TeamMgr:IsInTeam() then
           return
        end

        self:CancelAllMatch()
        _G.UIViewMgr:HideView(_G.UIViewID.PWorldMatchDetail)
        _G.UIViewMgr:HideView(_G.UIViewID.PWorldEntouragePanel)
        _G.PWorldEntourageVM:SetCurEntID(EntID)
        _G.UIViewMgr:ShowView(_G.UIViewID.EntourageConfirm)
    end)
end

local function GetContentID(EntID)
    return (SceneEnterCfg:FindCfgByKey(EntID) or {}).MatchTimeoutGuideRecruitID
end

---@private
function PWorldMatchMgr:InnerRegisterMatchGuide(EntID)
    if self.IsRobotMatchNeed(EntID) then
        return self:InnerRegNavRobotMatch(EntID)
    else
        local ECfg = SceneEnterCfg:FindCfgByKey(EntID)
        if (ECfg and ECfg.MatchTimeoutGuideType == 2) then
            return self:RegisterMatchGuide(EntID, function()
                if not self:IsEntMatching(EntID) or _G.TeamMgr:IsInTeam() then
                   return
                end

                for _, v in ipairs(self.Matches or {}) do
                    if self.IsRobotMatchNeed(v.EntID) and not self:IsRobotMatchUnChecked(v.EntID) then
                        return
                    end
                end

                if self.CachedGuideMatchEntID then
                   return
                end

                -- if _G.UIViewMgr:IsViewVisible(_G.UIViewID.TeamMainPanel) then
                --     return
                -- end

                local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
                local Cfg = TeamRecruitCfg:FindCfgByKey(GetContentID(EntID))
                if Cfg == nil then
                   return
                end

                _G.UIViewMgr:HideView(_G.UIViewID.PWorldMatchDetail)
                local TeamDefine = require("Game/Team/TeamDefine")
                self.CachedGuideMatchEntID = EntID
                _G.MsgBoxUtil.ShowMsgBoxTwoOp(nil, _G.LSTR(1320230),
                _G.LSTR(1320220),
                     function ()
                        self:CancelAllMatch()
                        self:RegisterTimer(function()
                            local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	                        TeamRecruitUtil.TryOpenTeamRecruitView(Cfg.TypeID, GetContentID(EntID))
                        end, 0.3)
                    end,
                    nil,
                    _G.LSTR(1320222),
                    _G.LSTR(1320221),
                    nil,
                    function()
                        self.CachedGuideMatchEntID = nil
                    end)

            end)
        end
    end
end

function PWorldMatchMgr:RemoveRobotMatchNav(EntID)
    if self.MatchTimeoutNavData and EntID then
        local Data = self.MatchTimeoutNavData[EntID]
        if Data then
            self:UnRegisterTimer(Data.TimerID)
        end
        self.MatchTimeoutNavData[EntID] = nil
    end
end

function PWorldMatchMgr.IsRobotMatchNeed(EntID)
    local ECfg = SceneEnterCfg:FindCfgByKey(EntID)
    if not (ECfg and ECfg.MatchTimeoutGuideType == 1) then
       return false
    end

    local SceneEncourageCfg = require("TableCfg/SceneEncourageCfg")
    local Cfg = SceneEncourageCfg:FindCfgByKey(EntID)
    return Cfg and Cfg.SceneID == EntID
end

function PWorldMatchMgr:CancelAllMatch()
    if self.Matches and #self.Matches > 0 then
       self:LogInfo("cancel all match...")
       for _, v in ipairs(self.Matches) do
            local EntID = v.EntID
            local TypeID = ProtoCommon.ScenePoolType.ScenePoolRandom
            self:LogInfo("cancel all match, entid: %s", EntID)
            if not v.IsRandom then
                 local Cfg = SceneEnterCfg:FindCfgByKey(EntID)
                 TypeID = Cfg and Cfg.TypeID or nil
            end
            self:ReqCancelMatch(TypeID, EntID)
       end
    end

    for _, Data in pairs(self.MatchTimeoutNavData or {}) do
        self:UnRegisterTimer(Data.TimerID)
    end
    self.MatchTimeoutNavData = {}
end

function PWorldMatchMgr:CancelAllCrystallineMatches()
    if self.MatchCrystallines and #self.MatchCrystallines > 0 then
        for _, v in ipairs(self.MatchCrystallines) do
            local EntID = v.EntID
            local TypeID = ProtoCommon.ScenePoolType.ScenePoolPVPCrystal
            local Cfg = SceneEnterCfg:FindCfgByKey(EntID)
            if Cfg then
                TypeID = Cfg.TypeID
            end
            self:ReqCancelMatch(TypeID, EntID)
        end
    end
end

function PWorldMatchMgr:CancelAllChocobosMatches()
    if self.MatchChocobos and #self.MatchChocobos > 0 then
        for _, v in ipairs(self.MatchChocobos) do
            local EntID = v.EntID
            local TypeID = ProtoCommon.ScenePoolType.ScenePoolChocobo
            local Cfg = SceneEnterCfg:FindCfgByKey(EntID)
            if Cfg then
                TypeID = Cfg.TypeID
            end
            self:ReqCancelMatch(TypeID, EntID)
        end
    end
end

return PWorldMatchMgr
