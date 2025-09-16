local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local ProtoCS = require("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local TimeUtil = require("Utils/TimeUtil")
local SaveKey = require("Define/SaveKey")
local CommonUtil = require("Utils/CommonUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local MainFunctionDefine = require("Game/Main/FunctionPanel/MainFunctionDefine")

local QuestionnaireCmd = ProtoCS.CS_CMD.CS_CMD_QUESTIONNAIRE
local QuestionnaireSubCmd = ProtoCS.Game.Questionnaire.Cmd

local MURSurveyMgr = LuaClass(MgrBase)

function MURSurveyMgr:OnInit()
    self.MainRedDotId = 17003
    self.RedDotId = 17001
    self.MURSurveyList = {}
    self.MajorMaxLevel = 0
    self.SurveySid = 0
    self.SurveyUrl = ""
    self.NumberID = 0
    self.bNeedShowRedDot = false
    self.bNeedShowQuestionnaire = false

    self.CheckTimer = nil
    self.CheckInterval = 2
    self.CheckedSurveyIDList = {}
end

function MURSurveyMgr:OnBegin()

end

function MURSurveyMgr:OnEnd()

end

function MURSurveyMgr:OnShutdown()
    self.MURSurveyList = {}
    self.CheckedSurveyIDList = {}
    self:CancelCheckTimer()
end

function MURSurveyMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(QuestionnaireCmd, QuestionnaireSubCmd.QueryQuestionnaire, self.OnQuerySurveyListRsp)
    self:RegisterGameNetMsg(QuestionnaireCmd, QuestionnaireSubCmd.TriggerQuestionnaire, self.OnTriggerQuestionnaireRsp)
    self:RegisterGameNetMsg(QuestionnaireCmd, QuestionnaireSubCmd.QuestionnaireValid, self.OnQuestionnaireValidRsp)
end

function MURSurveyMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MainPanelShow, self.OnMainPanelShow)
    self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
    self:RegisterGameEvent(EventID.MainPanelFunctionLayoutChange, self.ChangeRedDotShowStatus)
end

function MURSurveyMgr:BeginQueryQuestionnaire()
    --local ServerTime = TimeUtil.GetServerTime()
    --FLOG_INFO("MURSurveyMgr:OnBegin, ServerTime:%d", ServerTime)
    self.MajorMaxLevel = self:GetMajorMaxLevel()
    _G.FLOG_INFO("MURSurveyMgr:BeginQueryQuestionnaire, MajorMaxLevel:%d", self.MajorMaxLevel)
    self:SendQuerySurveyListReq()
end

function MURSurveyMgr:SendQuerySurveyListReq()
	local SubMsgID = QuestionnaireSubCmd.QueryQuestionnaire

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Query = {}

	GameNetworkMgr:SendMsg(QuestionnaireCmd, SubMsgID, MsgBody)
end

function MURSurveyMgr:OnQuerySurveyListRsp(MsgBody)
    self.MURSurveyList = {}
    local SurveyList = MsgBody.Query.List
    if nil ~= SurveyList and #SurveyList > 0 then
        for _, Value in ipairs(SurveyList) do
            local Info = {
                ID = Value.ID,
                MurUrl = Value.MurUrl,
                RoleLevel = Value.RoleLevel,
                StartTime = Value.StartTime / 1000,
                EndTime = Value.EndTime / 1000,
                NumberID = Value.NumberID,
                Invalid = false
            }
            table.insert(self.MURSurveyList, Info)
        end
    end
    _G.FLOG_INFO("MURSurveyMgr:OnQuerySurveyListRsp, num:%d, list:%s", #self.MURSurveyList, table.tostring(self.MURSurveyList))
    self:CheckSurveyEntranceAndRedDot()
    if self:HasUnvalidationQuestionnaire() and nil == self.CheckTimer then
        self.CheckTimer = self:RegisterTimer(self.CheckSurveyIDIsValid, 0.5, self.CheckInterval, 0)
    end
end

function MURSurveyMgr:OnTriggerQuestionnaireRsp(MsgBody)
    local TriggerData = MsgBody.TriggerData
    local FinishID = TriggerData.FinishID
    _G.FLOG_INFO("MURSurveyMgr:OnTriggerQuestionnaireRsp, FinishID:%d", FinishID)
    if nil ~= FinishID and FinishID ~= 0 then
        for Index, Value in ipairs(self.MURSurveyList) do
            if FinishID == Value.ID then
                table.remove(self.MURSurveyList, Index)
                break
            end
        end
    end
    self:CheckSurveyEntranceAndRedDot(true)
end

function MURSurveyMgr:CheckSurveyIDIsValid()
    self:CheckSurveyEntranceAndRedDot(true)
end

function MURSurveyMgr:HasUnvalidationQuestionnaire()
    local CurrentServerTime = TimeUtil.GetServerTime()
    for _, Value in ipairs(self.MURSurveyList) do
        if Value.NumberID > 0 then
            if CurrentServerTime < Value.StartTime then
                return true
            end
        end
    end
    return false
end

function MURSurveyMgr:IsInCheckedSurveyIDList(SurveySid)
    for _, SurveyID in ipairs(self.CheckedSurveyIDList) do
        if SurveyID == SurveySid then
            return true
        end
    end
    return false
end

function MURSurveyMgr:OnQueryQuestionnaireIsItValid()
    if self:IsInCheckedSurveyIDList(self.SurveySid) then
        return
    end

    local function QueryQuestionnaireIsItValid()
        local SubMsgID = QuestionnaireSubCmd.QuestionnaireValid

        local MsgBody = {}
        MsgBody.Cmd = SubMsgID
        MsgBody.Valid = { ID = self.SurveySid }

        GameNetworkMgr:SendMsg(QuestionnaireCmd, SubMsgID, MsgBody)
    end

    local RandomTime = math.random(2, 100) / 100
    _G.FLOG_INFO("MURSurveyMgr:OnQueryQuestionnaireIsItValid, RandomTime:%f", RandomTime)

    self:RegisterTimer(QueryQuestionnaireIsItValid, RandomTime, 1, 1)
end

function MURSurveyMgr:OnQuestionnaireValidRsp(MsgBody)
    local ValidData = MsgBody.Valid
    local QuestionnaireID = ValidData.ID
    local Result = ValidData.Result
    if QuestionnaireID == self.SurveySid then
        if Result then
            self:ShowOrHideEntrance(true)
            local bIsNeedShowRedDot = self:IsNeedShowRedDot(self.SurveySid)
            self:ShowOrHideRedDot(bIsNeedShowRedDot)
        else
            for _, Value in ipairs(self.MURSurveyList) do
                if Value.ID == self.SurveySid then
                    Value.Invalid = true
                    break
                end
            end
            self:CheckSurveyEntranceAndRedDot(true)
        end
    end
    table.insert(self.CheckedSurveyIDList, QuestionnaireID)
end

function MURSurveyMgr:SavedCheckedSurveyID(SurveyID)
    local LastSaveValue = _G.UE.USaveMgr.GetString(SaveKey.CheckedSurveyID, "", true)
    local SaveValue = string.format("%d", SurveyID)
    if not string.isnilorempty(LastSaveValue) then
        SaveValue = string.format("%s-%s", LastSaveValue, SaveValue)
    end
    _G.FLOG_INFO("MURSurveyMgr:SavedCheckedSurveyID, SaveValue:%s", SaveValue)
    _G.UE.USaveMgr.SetString(SaveKey.CheckedSurveyID, SaveValue, true)
end

function MURSurveyMgr:GetCheckedSurveyIDList()
    self.CheckedSurveyIDList = {}
    local LastSaveValue = _G.UE.USaveMgr.GetString(SaveKey.CheckedSurveyID, "", true)
    if not string.isnilorempty(LastSaveValue) then
        local ValueList = string.split(LastSaveValue, "-")
        for _, Value in ipairs(ValueList) do
            table.insert(self.CheckedSurveyIDList, tonumber(Value))
        end
    end
end

function MURSurveyMgr:CheckSurveyEntranceAndRedDot(IsNeedValidation)
    if not self:HasUnvalidationQuestionnaire() then
        self:CancelCheckTimer()
    end
    if nil == self.MURSurveyList or #self.MURSurveyList == 0 then
        self:ShowOrHideEntrance(false)
    else
        table.sort(self.MURSurveyList, function(A, B)
            if A.RoleLevel < B.RoleLevel then
                return true
            elseif A.RoleLevel > B.RoleLevel then
                return false
            else
                return A.StartTime < B.StartTime
            end
        end)

        local CurrentServerTime = TimeUtil.GetServerTime()
        self.MajorMaxLevel = self:GetMajorMaxLevel()
        local bHasUncheckedQuestionnaire = false
        self.SurveySid = 0
        self.SurveyUrl = ""
        self.NumberID = 0

        for _, Value in ipairs(self.MURSurveyList) do
            if not Value.Invalid and
                self.MajorMaxLevel >= Value.RoleLevel and
                CurrentServerTime >= Value.StartTime and
                CurrentServerTime <= Value.EndTime then
                bHasUncheckedQuestionnaire = true
                self.SurveySid = Value.ID
                self.SurveyUrl = Value.MurUrl
                self.NumberID = Value.NumberID
                break
            end
        end
        -- FLOG_INFO("MURSurveyMgr:CheckSurveyEntranceAndRedDot, Num:%d, SurveySid:%d, SurveyUrl:%s, bHasUncheckedQuestionnaire:%s",
        --     #self.MURSurveyList, self.SurveySid, self.SurveyUrl, tostring(bHasUncheckedQuestionnaire))
        if bHasUncheckedQuestionnaire and self.NumberID > 0 then
            if IsNeedValidation then
                self:OnQueryQuestionnaireIsItValid()
                return
            else
                table.insert(self.CheckedSurveyIDList, self.SurveySid)
            end
        end

        self:ShowOrHideEntrance(bHasUncheckedQuestionnaire)
        if bHasUncheckedQuestionnaire then
            local bIsNeedShowRedDot = self:IsNeedShowRedDot(self.SurveySid)
            self:ShowOrHideRedDot(bIsNeedShowRedDot)
        end
    end
end

function MURSurveyMgr:CancelCheckTimer()
    if nil ~= self.CheckTimer then
        TimerMgr:CancelTimer(self.CheckTimer)
        self.CheckTimer = nil
    end
end

function MURSurveyMgr:SaveRedDotData(SurveySid)
    local SaveTime = TimeUtil.GetServerTime()
    local SaveValue = string.format("%s-%d", SurveySid, SaveTime)
    local RedDotData = _G.UE.USaveMgr.GetString(SaveKey.MURSurveyRedDot, "", true)
    local bHideRedDot = false
    if RedDotData == "" then
        bHideRedDot = true
    else
        local ValueList = string.split(RedDotData, "-")
        local SaveSurveyId = tonumber(ValueList[1])
        local LastSaveTime = tonumber(ValueList[2])
        local SaveDay = math.ceil(SaveTime / 86400)
        local LastSaveDay = math.ceil(LastSaveTime / 86400)
        if SurveySid ~= SaveSurveyId or
            LastSaveTime == 0 or
            (SaveDay - LastSaveDay) >= 1 then
            bHideRedDot = true
        end
    end
    if bHideRedDot then
        _G.FLOG_INFO("MURSurveyMgr:SaveRedDotData, SaveValue:%s", SaveValue)
        _G.UE.USaveMgr.SetString(SaveKey.MURSurveyRedDot, SaveValue, true)
        self:ShowOrHideRedDot(false)
    end
end

function MURSurveyMgr:IsNeedShowQuestionnaire()
    return self.bNeedShowQuestionnaire
end

function MURSurveyMgr:IsNeedShowRedDot(SurveySid)
    local RedDotData = _G.UE.USaveMgr.GetString(SaveKey.MURSurveyRedDot, "", true)
    --_G.FLOG_INFO("MURSurveyMgr:IsNeedShowRedDot, RedDotData:%s", RedDotData)
    if RedDotData == "" then
        return true
    end

    local ValueList = string.split(RedDotData, "-")
    local SaveSurveyId = tonumber(ValueList[1])
    if SurveySid ~= SaveSurveyId then
        return true
    end

    local SaveTime = tonumber(ValueList[2])
    if SaveTime == 0 then
        return true
    end
    
    local ServerTime = TimeUtil.GetServerTime()
    local SaveDay = math.ceil(ServerTime / 86400)
    local LastSaveDay = math.ceil(SaveTime / 86400)
    if (SaveDay - LastSaveDay) >= 1 then
        return true
    end

    return false
end

function MURSurveyMgr:ShowOrHideEntrance(bShow)
    --_G.FLOG_INFO("MURSurveyMgr:ShowOrHideEntrance, bShow:%s", tostring(bShow))
    self.bNeedShowQuestionnaire = bShow
    _G.EventMgr:SendEvent(EventID.ShowMURSurveyEntrance, { bIsShow = bShow })
    if not bShow then
        self.bNeedShowRedDot = false
    end
    -- if bShow then
    --     _G.RedDotMgr:AddRedDotByID(self.RedDotId)
    -- else
    --     _G.RedDotMgr:DelRedDotByID(self.RedDotId)
    -- end
end

function MURSurveyMgr:ShowOrHideRedDot(bShow)
    --_G.FLOG_INFO("MURSurveyMgr:ShowOrHideRedDot, bShow:%s", tostring(bShow))
    _G.EventMgr:SendEvent(EventID.ShowMURSurveyRedDot, { bIsShow = bShow })
    self.bNeedShowRedDot = bShow

    self:ChangeRedDotShowStatus()
end

function MURSurveyMgr:IsNeedShowEntrance()
    return self.bNeedShowQuestionnaire
end

function MURSurveyMgr:OnMainPanelShow(Params)
    if nil ~= Params and nil ~= Params.bShow and Params.bShow == true then
        if CommonUtil.IsAndroidPlatform() or CommonUtil.IsIOSPlatform()then
            self:BeginQueryQuestionnaire()
        end
    end
end

function MURSurveyMgr:OnMajorLevelUpdate(Params)
    self.MajorMaxLevel = self:GetMajorMaxLevel()
    self:CheckSurveyEntranceAndRedDot(true)
end

function MURSurveyMgr:ChangeRedDotShowStatus()
    if self.bNeedShowRedDot then
        if _G.MainPanelMgr:IsFunctionButtonInLayout(MainFunctionDefine.ButtonType.MUR_SURVEY) then
            _G.RedDotMgr:AddRedDotByID(self.MainRedDotId)
            _G.RedDotMgr:DelRedDotByID(self.RedDotId)
        else
            _G.RedDotMgr:DelRedDotByID(self.MainRedDotId)
            _G.RedDotMgr:AddRedDotByID(self.RedDotId)
        end
    else
        _G.RedDotMgr:DelRedDotByID(self.MainRedDotId)
        _G.RedDotMgr:DelRedDotByID(self.RedDotId)
    end
end

function MURSurveyMgr:GetMajorMaxLevel()
    local MaxLevel = 1
	local RoleVM = MajorUtil.GetMajorRoleVM()
    if nil ~= RoleVM then
        local ProfList = RoleVM.ProfSimpleDataList
        if nil ~= ProfList and #ProfList > 0 then
            for _, Value in pairs(ProfList) do
                if ProfUtil.IsCombatProf(Value.ProfID) and Value.Level > MaxLevel then
                    MaxLevel = Value.Level
                end
            end
        end
    end
    return MaxLevel
end

function MURSurveyMgr:OpenMURSurvey(ScreenType, IsFullScreen, IsUseURLEncode, ExtraJson, IsBrowser)
    if string.isnilorempty(self.SurveyUrl) then
        _G.FLOG_WARNING("MURSurveyMgr:OpenMURSurvey, SurveyUrl is invalid!")
        return
    end
	-- local PlatfromStr = ""
	-- if CommonUtil.IsIOSPlatform() then
	-- 	PlatfromStr = "&sPlatId=0"
	-- elseif CommonUtil.IsAndroidPlatform() then
	-- 	PlatfromStr = "&sPlatId=1"
	-- end

	local MajorRoleID = MajorUtil.GetMajorRoleID() or 0
	-- local ExtraParams = string.format("%s&sArea=%d&sRoleId=%d&seq_id=%d&role_id=%d&channelid=%d", 
	-- 	PlatfromStr, _G.LoginMgr.ChannelID, MajorRoleID, self.SurveySid, MajorRoleID, _G.LoginMgr.ChannelID)
    -- local ExtraParams = string.format("&seq_id=%d&role_id=%d", self.SurveySid, MajorRoleID)
    -- FLOG_INFO("MURSurveyMgr:OpenMURSurvey, url:%s, ExtraParams:%s", self.SurveyUrl, ExtraParams)
	-- _G.UE.UAccountMgr.Get():OpenMURSurvey(self.SurveyUrl, ExtraParams, ScreenType, IsFullScreen, true, ExtraJson, IsBrowser, true)

    local SurveyUrl = self.SurveyUrl or ""
    local OpenId = _G.LoginMgr:GetOpenID() or 0
    local SurveyId = self.SurveySid or 0

    local NewUrl = string.format("%s&openid=%s&seq_id=%d&role_id=%s", SurveyUrl, tostring(OpenId), SurveyId, tostring(MajorRoleID))
    _G.FLOG_INFO("MURSurveyMgr:OpenMURSurvey, url:%s", NewUrl)
    _G.UE.UAccountMgr.Get():OpenMURSurvey(NewUrl, "", ScreenType, IsFullScreen, IsUseURLEncode, ExtraJson, IsBrowser, false)
    self:SaveRedDotData(self.SurveySid)
end

return MURSurveyMgr