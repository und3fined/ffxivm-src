local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local MainPanelVM = require("Game/Main/MainPanelVM")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoCS = require("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local OperationUtil = require("Utils/OperationUtil")
local ChatSetting = require("Game/Chat/ChatSetting")

local GameBotRedDotCmd = ProtoCS.CS_CMD.CS_CMD_REDPOSITION
local GameBotRedDotSubCmd = ProtoCS.Profile.RedPosition.CsRedPositionCmd

local MainFunctionPanelVM = require("Game/Main/FunctionPanel/MainFunctionPanelVM")
local MainFunctionDefine = require("Game/Main/FunctionPanel/MainFunctionDefine")

local ProtoCommon = require("Protocol/ProtoCommon")

---@class MainPanelMgr : MgrBase
local MainPanelMgr = LuaClass(MgrBase)

function MainPanelMgr:OnInit()
    self.ReadingInfos = {}
    self.SelectedEntityID = nil
    self.UpdateReadingInfoTimer = nil
    self.CurGameBotRedDotInfo = {}
end

function MainPanelMgr:OnBegin()

end

function MainPanelMgr:OnEnd()

end

function MainPanelMgr:OnShutdown()

end

function MainPanelMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(GameBotRedDotCmd, GameBotRedDotSubCmd.CS_RED_POSITION_QUERY, self.OnQueryGameBotRedDotRsp)
    self:RegisterGameNetMsg(GameBotRedDotCmd, GameBotRedDotSubCmd.CS_RED_POSITION_CANCEL, self.OnCancelGameBotRedDotRsp)
end

function MainPanelMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes) --角色成功登录
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)

    self:RegisterGameEvent(EventID.ChatOpenPrivateRedDotTipChanged, self.OnEvenOpenPrivateRedDotTipChanged)

    -- 读条相关
    self:RegisterGameEvent(EventID.StartDamageWarningCell, self.OnGameEventDamageWarning)
	self:RegisterGameEvent(EventID.EndDamageWarning, self.OnGameEventDamageWarningBreak)
	self:RegisterGameEvent(EventID.SelectTarget, self.OnGameEventSelectTarget)
	self:RegisterGameEvent(EventID.UnSelectTarget, self.OnGameEventUnSelectTarget)

	self:RegisterGameEvent(EventID.ModuleOpenUpdated, self.UpdateFunctionLayout)
    self:RegisterGameEvent(EventID.SeasonActivityUpdatRedDot, self.UpdateSeasonActivity)
    self:RegisterGameEvent(EventID.ShowMURSurveyEntrance, self.UpdateFunctionLayout)
    self:RegisterGameEvent(EventID.DepartEntranceUpdate, self.UpdateFunctionLayout)
	self:RegisterGameEvent(EventID.DepartEntranceOpened, self.UpdateFunctionLayout)
	self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify)
	self:RegisterGameEvent(EventID.BattlePassOpeningUp, self.UpdateFunctionLayout)

    self:RegisterGameEvent(EventID.MainPanelShow, self.OnMainPanelShow)
end

function MainPanelMgr:OnRegisterTimer()
    self:RegisterTimer(self.OnTimerCleanReadingInfo, 5, 5, 0, nil)
end

function MainPanelMgr:OnGameEventLoginRes()
    MainPanelVM.IsShowMainLBottomPanel = true
end

function MainPanelMgr:OnGameEventPWorldMapEnter()
	if PWorldMgr:CurrIsInDungeon() then
        MainPanelVM.IsShowMainLBottomPanel = true
	end
end

function MainPanelMgr:OnEvenOpenPrivateRedDotTipChanged()
    if ChatSetting.IsOpenPrivateRedDotTip() then
        -- 清除头像提示
        MainPanelVM:SetPersonChatHeadTipsPlayer()
    end
end

function MainPanelMgr:OnGameEventSelectTarget(Params)
	self.SelectedEntityID = Params.ULongParam1
    if nil == self.UpdateReadingInfoTimer then
        self.UpdateReadingInfoTimer = self:RegisterTimer(self.OnTimerUpdateReadingInfo, 0, 0.05, 0, nil)
    end
end

function MainPanelMgr:OnGameEventUnSelectTarget(Params)
	self.SelectedEntityID = nil
    MainPanelVM.IsReadingInfoVisible = false
    if nil ~= self.UpdateReadingInfoTimer then
        self:UnRegisterTimer(self.UpdateReadingInfoTimer)
        self.UpdateReadingInfoTimer = nil
    end
end

function MainPanelMgr:OnGameEventDamageWarning(Params)
	local MainSkillID = Params.IntParam1
	local DurationTime = Params.FloatParam1
	local EntityID = Params.ULongParam1
	local IsGuidedReading = Params.BoolParam1
	local IsAllowBreak = Params.BoolParam2

	if EntityID == nil then
		return
	end

    local ExpdTime = TimeUtil.GetServerTimeMS() / 1000 + DurationTime
    local SkillName = SkillMainCfg:GetSkillName(MainSkillID)

	self.ReadingInfos[EntityID] = {
        SkillName = SkillName,
        ExpdTime = ExpdTime,
        DurationTime = DurationTime,
        IsGuidedReading = IsGuidedReading,
        IsAllowBreak = IsAllowBreak,
    }
end

function MainPanelMgr:OnGameEventDamageWarningBreak(Params)
	local EntityID = Params.ULongParam1
	self.ReadingInfos[EntityID] = nil
end

function MainPanelMgr:OnTimerCleanReadingInfo()
    local Time = TimeUtil.GetServerTimeMS() / 1000
    for EntityID, Info in pairs(self.ReadingInfos) do
        if Info.ExpdTime < Time then
            self.ReadingInfos[EntityID] = nil
        end
    end
end

function MainPanelMgr:OnTimerUpdateReadingInfo()
    if nil == self.SelectedEntityID or nil == self.ReadingInfos[self.SelectedEntityID] then
        MainPanelVM.IsReadingInfoVisible = false
        return
    end

    local Time = TimeUtil.GetServerTimeMS() / 1000
    local ReadingInfo = self.ReadingInfos[self.SelectedEntityID]

    if Time >= ReadingInfo.ExpdTime then
        MainPanelVM.IsReadingInfoVisible = false
        return
    end

    MainPanelVM.IsReadingInfoVisible = true
    MainPanelVM.ReadingInfoSkillName = ReadingInfo.SkillName
    MainPanelVM.ReadingInfoPercent = 1 - (ReadingInfo.ExpdTime - Time) / ReadingInfo.DurationTime
end

function MainPanelMgr:UpdateSeasonActivity()
    _G.OpsSeasonActivityMgr:SetSeasonActivityIcon()
    self:UpdateFunctionLayout()
end

function MainPanelMgr:UpdateFunctionLayout()
    MainFunctionPanelVM:UpdateButtonLayout()
end

function MainPanelMgr:OnModuleOpenNotify(ModuleID)
    if ModuleID == ProtoCommon.ModuleID.ModuleIDMall then
        MainFunctionPanelVM:UpdateUnlockState(MainFunctionDefine.ButtonType.STORE)
    elseif ModuleID == ProtoCommon.ModuleID.ModuleIDActivitySystem then
        MainFunctionPanelVM:UpdateUnlockState(MainFunctionDefine.ButtonType.ACTIVITY)
    elseif ModuleID == ProtoCommon.ModuleID.ModuleIDAdventure then
		MainFunctionPanelVM:UpdateUnlockState(MainFunctionDefine.ButtonType.ADVENTURE)
    elseif ModuleID == ProtoCommon.ModuleID.ModuleIDBattlePass then
        MainFunctionPanelVM:UpdateUnlockState(MainFunctionDefine.ButtonType.BATTLE_PASS)
    end
end

function MainPanelMgr:OnMainPanelShow(Params)
    if nil ~= Params and nil ~= Params.bShow and Params.bShow == true then
        self:OnQueryGameBotRedDot()
    end
end

function MainPanelMgr:OnQueryGameBotRedDot()
	local SubMsgID = GameBotRedDotSubCmd.CS_RED_POSITION_QUERY

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Get = {}
    MsgBody.Get.WorldID = _G.LoginMgr:GetWorldID()
    MsgBody.Get.OpenID = tostring(_G.LoginMgr:GetOpenID())
    MsgBody.Get.RoleID = _G.LoginMgr:GetRoleID() or 0

	GameNetworkMgr:SendMsg(GameBotRedDotCmd, SubMsgID, MsgBody)
end

function MainPanelMgr:OnQueryGameBotRedDotRsp(MsgBody)
    self.CurGameBotRedDotInfo = {}
    local GameBotRedDotList = MsgBody.Get.RedPositionList
    for _, Value in ipairs(GameBotRedDotList) do
        local RedDotPositionInfo = {}
        RedDotPositionInfo.Position = Value.Position
        RedDotPositionInfo.PositionNo = Value.PositionNo
        self.CurGameBotRedDotInfo[Value.Position] = RedDotPositionInfo
        OperationUtil.ShowGameBotRedDot(true, Value.Position)
    end
end

function MainPanelMgr:OnCancelGameBotRedDot(RedDotIndex)
    if #self.CurGameBotRedDotInfo == 0 or nil == RedDotIndex or
        RedDotIndex == 0 or nil == self.CurGameBotRedDotInfo[RedDotIndex] then
        return
    end

	local SubMsgID = GameBotRedDotSubCmd.CS_RED_POSITION_CANCEL
	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Cancel = {}
    MsgBody.Cancel.WorldID = _G.LoginMgr:GetWorldID()
    MsgBody.Cancel.OpenID = tostring(_G.LoginMgr:GetOpenID())
    MsgBody.Cancel.RoleID = _G.LoginMgr:GetRoleID() or 0
    MsgBody.Cancel.RedPosition = {}
    MsgBody.Cancel.RedPosition.Position = self.CurGameBotRedDotInfo[RedDotIndex].Position
    MsgBody.Cancel.RedPosition.PositionNo = self.CurGameBotRedDotInfo[RedDotIndex].PositionNo

	GameNetworkMgr:SendMsg(GameBotRedDotCmd, SubMsgID, MsgBody)

    self.CurGameBotRedDotInfo[RedDotIndex] = nil
end

function MainPanelMgr:OnCancelGameBotRedDotRsp(MsgBody)

end

---@param Type number @see MainFunctionDefine.ButtonType
---@return boolean
function MainPanelMgr:IsFunctionButtonInLayout(Type)
    return MainFunctionPanelVM:IsInLayout(Type)
end

return MainPanelMgr