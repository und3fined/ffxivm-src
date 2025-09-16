---
--- Author: lydianwang
--- DateTime: 2022-01-21
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local FunctionItemFactory = require("Game/Interactive/FunctionItemFactory")
local DialogueUtil = require("Utils/DialogueUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local SaveKey = require("Define/SaveKey")
local CommonUtil = require("Utils/CommonUtil")
local StoryDefine = require("Game/Story/StoryDefine")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")

local StoryMgr = nil
local QuestMgr = nil
local TimerMgr = nil
local USaveMgr = nil

local TOUCH_COUNTDOWN = 4
local LSTR = _G.LSTR
local DialogTypeSystem = 8 -- 对话框样式表 对话框ID
local DialogTypeSubTitle = 10 -- 对话框样式表 对话框ID
local FRichTextSplitter = _G.UE.FRichTextSplitter

---@class SequencePlayerVM : UIViewModel
local SequencePlayerVM = LuaClass(UIViewModel)

---Ctor
function SequencePlayerVM:Ctor()
	self.MenuChoiceIndex = 0
end

function SequencePlayerVM:OnInit()
end

function SequencePlayerVM:OnBegin()
	self:ResetVM()
	StoryMgr = _G.StoryMgr
	QuestMgr = _G.QuestMgr
	TimerMgr = _G.TimerMgr
	USaveMgr = _G.UE.USaveMgr
end

function SequencePlayerVM:OnEnd()
end

function SequencePlayerVM:OnShutdown()
end

-- ==================================================
-- VM变量
-- ==================================================

function SequencePlayerVM:ResetVM()
	-- === info ===

	self.bIsCanSkip = false --确定当前sequence能否跳过，关卡编辑器配置
	self.SkipType = 0 -- 跳过类型，0: 单人， 1组队，sequence轨道里配置
	self.FadeColorType = 0
	self.bTouchIgnore = false
	self.ActualSpeedLevel = 1

	self.bSystemDialog = false
	self.bSelfSync = true
	self.bHasAudio = false

	self.bIsNcut = false
	if self.HideTopButtonTimer ~= nil then
		TimerMgr:CancelTimer(self.HideTopButtonTimer)
	end
	self.HideTopButtonTimer = nil

	-- dialog update
	self.bIsDialogPlaying = false
	self.DialogPlayIndex = 1
	self.bClickedScreen = false -- 控制字幕滚动
	self.bTouchedScreen = false -- 控制跳过对话
	self.TouchWaitTime = StoryDefine.TouchWaitTimeMS
	local Cfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_TOUCH_WAIT_TIME)
	if (Cfg ~= nil) then
		self.TouchWaitTime = Cfg.Value[1]
	end
	self.DialogueStartTimeMS = 0
	self.RichTextSplitter = nil
	self.RichTextLen = 0

	self.bDialogUpdated = false

	-- multiple bar / travel log
	self.CurrentSequence = 1
	self.ToTalSequence = 1

	-- === BindableProperties ===

	self.bTalkPanelVisible = false
	self.SpeakerName = ""
	self.SpeakerTag = "说话者标签"
	self.TalkContent = ""
	self.bTouchWaitCfg = true

	self.bHasAnyDialog = true
	self.bShowAutoPlayBtn = true
	self.bInDialogHistory = false

	-- BindableProperties for StaffRoll
	self.bStaffRollVisible = false

	-- dialog update
	self.SpeedLevel = 1
	self.bIsAutoPlay = false
	self.PreResumeParam = false
	self.bShowSpeed = false
	self.bHideAllTopButton = false
	self.ForbidSkipDialogTime = 0

	-- multiple bar / travel log
	self.bIsPlayMultiple = false
	self.TextVideoNum = ""
	self.bForbidSkipWhenHasNewbieInTeam = false --一些副本配置了不可跳过的条件：队伍有未通关此副本的队友
	

	self:ClearDialogueMenu()
end

function SequencePlayerVM:ClearDialogueMenu()
	-- === BindableProperties ===
	self.bChoicePanelVisible = false
	self.ChoiceMessage = ""
    self.ChoiceUnitList = {}
	self.DialogueBranchID = 0
end

function SequencePlayerVM:InitSequenceInfo(SequenceCfg)
	self:ResetVM()

	if SequenceCfg ~= nil then
		self.bIsNcut = SequenceCfg.bIsNcut
		self.bHasAnyDialog = SequenceCfg.bHasAnyDialog
		self.bShowAutoPlayBtn = self.bHasAnyDialog
		self.bIsPlayMultiple = SequenceCfg.bIsPlayMultiple
		self.CurrentSequence = SequenceCfg.CurrentSequence
		self.ToTalSequence = SequenceCfg.ToTalSequence
	end

    local IsAutoPlayValue = USaveMgr.GetInt(SaveKey.IsAutoPlay, 1, true)
	if _G.LevelRecordMgr ~= nil and _G.LevelRecordMgr:InRecordState() then
		IsAutoPlayValue = 0
	end
    local SpeedLevelValue = USaveMgr.GetInt(SaveKey.AutoPlaySpeedLevel, 1, true)
	self:SetAutoPlay(IsAutoPlayValue == 1, true)
	self:SetAutoPlaySpeedLevel(SpeedLevelValue, true)

	self.MenuChoiceIndex = 0
	--以enbleskipstart轨道配置的为准，放到Play之前设置，防止覆盖轨道的值
    local bIsCanSkipTemp = self:CheckIsCanSkip(SequenceCfg)
	self:UpdateSkipInfo(bIsCanSkipTemp and not self.bIsPlayMultiple, 0, 0)

	--强制自动播放+点击无效
	if (self.bForbidSkipWhenHasNewbieInTeam) then
		self.bShowAutoPlayBtn = false
		self:SetAutoPlay(true, true)
	end

	if self.bIsPlayMultiple then
		self.TextVideoNum = string.format("(%d/%d)", self.CurrentSequence or 1, self.ToTalSequence or 1)
	end
end

-- ==================================================
-- 更新VM变量
-- ==================================================

---StoryMgr计时器更新
function SequencePlayerVM:UpdateOnTimer()
	self:DoAutoPlayDialog()
	self:UpdateDialogContentScroll()
end

function SequencePlayerVM:CheckIsCanSkip(SequenceCfg)
	local bIsCanSkipTemp = true
	self.bForbidSkipWhenHasNewbieInTeam = false
	if (SequenceCfg ~= nil and SequenceCfg.bIsCanSkip ~= nil) then
        bIsCanSkipTemp = SequenceCfg.bIsCanSkip
		if (bIsCanSkipTemp and SequenceCfg.CheckNewbieForSkip) then
			local bHasNewbie = _G.PWorldMgr:HasNewbieInTeam()
			--配置了可跳过但队伍里有新人
			if (bHasNewbie) then
				self.bForbidSkipWhenHasNewbieInTeam = true
			end

			bIsCanSkipTemp = not bHasNewbie
		end
    end

	return bIsCanSkipTemp
end


---是否可跳过动画
function SequencePlayerVM:UpdateSkipInfo(bIsCanSkip, SkipType, FadeColorType)
	self.bIsCanSkip = bIsCanSkip
	self.SkipType = SkipType
	self.FadeColorType = FadeColorType
end

function SequencePlayerVM:ResetActualSpeedLevel()
	local bForceNormalSpeed = (not self.bIsAutoPlay) or (not self.bHasAnyDialog)
		or self.bSystemDialog or (not self.bSelfSync) or self.bHasAudio
	self.bShowSpeed = not (bForceNormalSpeed or self.bChoicePanelVisible or self.bIsNcut)
	self.ActualSpeedLevel = bForceNormalSpeed and 1 or self.SpeedLevel
end

function SequencePlayerVM:SetAutoPlaySpeedLevel(SpeedLevel, bInit)
	self.SpeedLevel = SpeedLevel
	if not bInit then
		USaveMgr.SetInt(SaveKey.AutoPlaySpeedLevel, SpeedLevel, true)
	end
end

function SequencePlayerVM:HideAllTopButton()
	self.bHideAllTopButton = true
end

function SequencePlayerVM:WakeUpTopButton()
	if self.bIsNcut then -- ncut定时隐藏按钮逻辑
		if self.HideTopButtonTimer ~= nil then
			TimerMgr:CancelTimer(self.HideTopButtonTimer)
		end
		-- todo 这里重复创建timer table，有优化空间
		self.HideTopButtonTimer = TimerMgr:AddTimer(self, self.HideAllTopButton, TOUCH_COUNTDOWN)
		self.bHideAllTopButton = false
	end
end

function SequencePlayerVM:GMSetTouchWaitTimeMS(Time)
	self.TouchWaitTime = Time
end

-- --------------------------------------------------
-- View接口
-- --------------------------------------------------

function SequencePlayerVM:OnClickScreen()
	self:WakeUpTopButton()

	if self.bTouchIgnore or self.bForbidSkipWhenHasNewbieInTeam or self.bChoicePanelVisible then
		return
	end

	if self.ForbidSkipDialogTime and TimeUtil.GetLocalTimeMS() < self.ForbidSkipDialogTime then
		return --防止连点，间隔太短不能跳过
	end

	-- https://crashsight.qq.com/crash-reporting/errors/972e4a01e7/F83AF100EBCC6B02F84E789ABF061937?pid=1
	-- 原因未知，先做保护处理
	if not StoryMgr then return end

	self.bTouchedScreen = true
	if StoryMgr.bTouchNoJump then
		self:StopDialogueSentence()
		return
	end

	--如果文字还没全部滚动完，就加速显示，完成后才能跳过
	if self.bIsDialogPlaying then
		self.bClickedScreen = true
	else
		StoryMgr:ContinueSequence()
	end
end

function SequencePlayerVM:OnClickButtonSwitchAuto()
	self:WakeUpTopButton()
	self:SetAutoPlay(not self.bIsAutoPlay)

	if self.bIsAutoPlay then
		if not self.bIsDialogPlaying then
			StoryMgr:ContinueSequence()
		end
	end
end

function SequencePlayerVM:OnClickButtonChangeSpeed()
	self:WakeUpTopButton()
	self:SetAutoPlaySpeedLevel(self.SpeedLevel % 3 + 1)
end

function SequencePlayerVM:OnClickNextDialogContent(bWakeUpTopButton)
	if bWakeUpTopButton ~= false then
		self:WakeUpTopButton()
	end

	if self.bChoicePanelVisible then
		return
	end

	if (not StoryMgr:SequenceIsPausedStatus()) then
		if self.bSystemDialog or (not self.bSelfSync) then
			return 
		end
	end

	if StoryMgr.bTouchNoJump then
		self:StopDialogueSentence()
		return
	end

	StoryMgr:ContinueSequence()
end

function SequencePlayerVM:OnClickButtonJumpOver()
	if (not self.bIsCanSkip) then
		if (self.bForbidSkipWhenHasNewbieInTeam) then
			--队伍中有初见冒险者，无法跳过当前动画
			_G.MsgTipsUtil.ShowStoryTips(LSTR(1280016))
		else
			--当前动画不可跳过
			_G.MsgTipsUtil.ShowStoryTips(LSTR(1280014))
		end
		
		return
	end

	self:WakeUpTopButton()
	--SkipType: 0: 单人， 1组队
	-- if (self.SkipType ~= 0 and self.SkipStatus ~= 2) then
	-- 	return
	-- end

	local Player = StoryMgr.SequencePlayer
	if Player and Player.SequenceActor then
		local JumpTime = Player.SequenceActor:GetTimeResetSkipNcut()
		if JumpTime > 0 then
			Player:PlayToSeconds(JumpTime)
			Player:ContinueSequence()
			return
		end
	end

	--需要缓存下
	local FadeColorType = self.FadeColorType
	StoryMgr:StopSequence(true)
	if (FadeColorType ~= 0 and not _G.UIViewMgr:IsViewVisible(_G.UIViewID.CommonFadePanel)) then
		local Params = {}
		Params.FadeColorType = FadeColorType
		_G.UIViewMgr:ShowView(_G.UIViewID.CommonFadePanel, Params)
	end
	_G.StoryMgr:StopCGMovie()
end

function SequencePlayerVM:SetAutoPlay(bAutoPlay, bInit)
	self.bIsAutoPlay = bAutoPlay
	self:ResetActualSpeedLevel()
	if not bInit then
		USaveMgr.SetInt(SaveKey.IsAutoPlay, bAutoPlay and 1 or 0, true)
	end
end

function SequencePlayerVM:PauseAutoPlay()
	if self.bIsAutoPlay then
		self.PreResumeParam = true
	end
	self:SetAutoPlay(false)
end

function SequencePlayerVM:ResumeAutoPlay()
	if self.PreResumeParam then
		self:SetAutoPlay(true)
		local bPaused = StoryMgr:SequenceIsPausedStatus()
		if bPaused and not self.bIsDialogPlaying then
			StoryMgr:ContinueSequence()
		end
	end
	self.PreResumeParam = false
end

-- --------------------------------------------------
-- 更新对话文本
-- --------------------------------------------------

function SequencePlayerVM:UpdateDialogueInfo(DialogueSentenceInfo)
	if DialogueSentenceInfo == nil then
		self.bDialogUpdated = false
		self.bTalkPanelVisible = false
		return
	end

	self.bDialogUpdated = true
	self.bTalkPanelVisible = (not self.bInDialogHistory) and (not DialogueSentenceInfo.bHideDialog)	

	self.SpeakerName = DialogueSentenceInfo.SpeakerName or ""
	self.bTouchIgnore = DialogueSentenceInfo.bTouchIgnore

	self.bSystemDialog = (DialogueSentenceInfo.DialogStyle == DialogTypeSubTitle) or (DialogueSentenceInfo.DialogStyle == DialogTypeSystem)
	self.bSelfSync = DialogueSentenceInfo.bSelfSync
	self.bHasAudio = (DialogueSentenceInfo.VoiceName ~= nil) and self.bIsNcut -- bIsNcut为临时判定，假设lcut不含语音，需修改
	self.bTouchWaitCfg = DialogueSentenceInfo.bTouchWaitCfg
	self:ResetActualSpeedLevel()

	self.DialogueStartTimeMS = TimeUtil.GetLocalTimeMS()
	self:SetupDialogRichTextInfo(DialogueSentenceInfo)

	if (self.bForbidSkipWhenHasNewbieInTeam) then
		self.bTouchWaitCfg = false
	end

	if DialogueSentenceInfo.bScrollContent then
		self.TalkContent = ""
		self:SetupDialogContentScroll(DialogueSentenceInfo)
	else
		local TalkContent = DialogueSentenceInfo.Content or ""
		TalkContent = DialogueUtil.ParseLabel(TalkContent)
		TalkContent = CommonUtil.GetTextFromStringWithSpecialCharacter(TalkContent)
		self.TalkContent = TalkContent
		-- 0.5s内禁止跳过
		self.ForbidSkipDialogTime = self.DialogueStartTimeMS + self.TouchWaitTime
	end
end

function SequencePlayerVM:OnEndDialogueSentence(bKeepWidget)
	self.bTouchedScreen = false
    self:StopDialogueSentence(bKeepWidget)
end

function SequencePlayerVM:SetupDialogRichTextInfo(DialogueSentenceInfo)
	local ConvertedContent = (DialogueSentenceInfo.Content == nil)
	and "" or DialogueUtil.ParseLabel(DialogueSentenceInfo.Content)

	self.RichTextSplitter = FRichTextSplitter.Create(ConvertedContent)
	if self.RichTextSplitter then
		self.RichTextLen = self.RichTextSplitter:RichTextLen()
	end
end

--对白自动播放的时候，界面停留的时间
function SequencePlayerVM:UpdateDialogueStayDurationWhenAutoPlay(CurrentAudioDuration)
	self.CurrentDialogueStayDuration = CurrentAudioDuration
end

function SequencePlayerVM:DoAutoPlayDialog()
	if (not self.bIsAutoPlay) or (not self.bDialogUpdated)
	or (self.DialogueStartTimeMS == 0) or (self.RichTextLen == 0) then
		return
	end

	local DurationMS = TimeUtil.GetLocalTimeMS() - self.DialogueStartTimeMS
	if DurationMS < self.TouchWaitTime then
		return
	end

	local AutoPlayTimeMS
	-- 对白轨道会执行按键等待，或者 已经处于按键等待暂停状态了
	if (self.bIsNcut and ((self.CurrentDialogueStayDuration ~= nil and self.CurrentDialogueStayDuration > 0) or StoryMgr:SequenceIsPausedStatus())) then
		AutoPlayTimeMS = self.CurrentDialogueStayDuration
		if (AutoPlayTimeMS ~= nil and AutoPlayTimeMS > 0) then
			AutoPlayTimeMS = 1000 * AutoPlayTimeMS
		else
			AutoPlayTimeMS = 1000 * DialogueUtil.GetAutoPlayTime(self.RichTextLen, self.ActualSpeedLevel)
		end
	else
		AutoPlayTimeMS = 1000 * DialogueUtil.GetAutoPlayTime(self.RichTextLen, self.ActualSpeedLevel)
	end

	if DurationMS > AutoPlayTimeMS then
		self:OnClickNextDialogContent(false)
	end
end

---@deprecated
function SequencePlayerVM:SetupDialogContentScroll(DialogueSentenceInfo)
	local ConvertedContent = (DialogueSentenceInfo.Content == nil)
	and "" or DialogueUtil.ParseLabel(DialogueSentenceInfo.Content)

	self.RichTextSplitter = _G.UE.FRichTextSplitter.Create(ConvertedContent)
	self.bIsDialogPlaying = true
	self.DialogPlayIndex = 1
	self.bClickedScreen = false
end

---@deprecated
function SequencePlayerVM:UpdateDialogContentScroll()
	if not self.bIsDialogPlaying then
		return
	end

	local Text
	if self.RichTextSplitter:RichTextLen() >= self.DialogPlayIndex then
		Text = self.RichTextSplitter:RichTextSub(self.DialogPlayIndex)
	else
		Text = self.RichTextSplitter:RichTextSub(self.RichTextSplitter:RichTextLen())
		self.bIsDialogPlaying = false
	end

	self.TalkContent = Text

	if self.bClickedScreen then
		self.DialogPlayIndex = self.DialogPlayIndex + 5 --5倍速 和NPCTalk一致
	else
		self.DialogPlayIndex = self.DialogPlayIndex + (self.ActualSpeedLevel or 1)
	end
end

function SequencePlayerVM:StopDialogueSentence(bKeepWidget)
	self.bDialogUpdated = false
	self.DialogueStartTimeMS = 0
	if bKeepWidget ~= true then
		self.bTalkPanelVisible = false
		self.RichTextSplitter = nil
		self.RichTextLen = 0
	end
end

-- --------------------------------------------------
-- 选项相关
-- --------------------------------------------------

---@param MenuInfo _G.UE.FMenuSetupInfo
function SequencePlayerVM:OpenMenu(MenuInfo)
	if MenuInfo == nil then return end

	print("SequencePlayerVM:OpenMenu", MenuInfo.Message)

	StoryMgr:PauseSequence()

	self.ChoiceMessage = MenuInfo.Message or ""

	local TempUnitList = {}
	for i, ChoiceContent in ipairs(MenuInfo.Choices) do
		local ChoiceFunctionUnit = FunctionItemFactory:CreateDialogueChoiceFunc(ChoiceContent,
			{
				ChoiceIndex = i,
				NeedInsertHistory = true,
			})
		table.insert(TempUnitList, ChoiceFunctionUnit)
	end

	self.ChoiceUnitList = TempUnitList
	self.DialogueBranchID = MenuInfo.DialogueBranchID
	self.bTouchIgnore = true
	self.bChoicePanelVisible = true

	self:ResetActualSpeedLevel()
	if self.CachedIsCanSkip == nil then
		self.CachedIsCanSkip = self.bIsCanSkip
	end
	self.bIsCanSkip = false
	if self.CachedHasAnyDialog == nil then
		self.CachedHasAnyDialog = self.bHasAnyDialog
	end
	self.bHasAnyDialog = false
	self.bShowAutoPlayBtn = false
end

function SequencePlayerVM:ChooseMenuChoice(Index)
	print("SequencePlayerVM:ChooseMenuChoice Index =", Index)
	self.MenuChoiceIndex = Index or 0
	self.bTouchIgnore = false
	if self.DialogueBranchID ~= 0 then
		QuestMgr:SetDialogBranchInfo(self.MenuChoiceIndex, self.DialogueBranchID)
	end
	self:ClearDialogueMenu()

	self:ResetActualSpeedLevel()
	if self.CachedIsCanSkip ~= nil then
		self.bIsCanSkip = self.CachedIsCanSkip
		self.CachedIsCanSkip = nil
	end
	if self.CachedHasAnyDialog ~= nil then
		self.bHasAnyDialog = self.CachedHasAnyDialog
		self.CachedHasAnyDialog = nil
	end
	self.bShowAutoPlayBtn = self.bHasAnyDialog

	self:OnEndDialogueSentence()
	StoryMgr:ContinueSequence()
end

---@return number
function SequencePlayerVM:GetMenuChoiceIndex()
	return self.MenuChoiceIndex or 0
end

-- ---------------------------------------------------- --------------------------------------------------
-- 片尾动画
-- ---------------------------------------------------- --------------------------------------------------

function SequencePlayerVM:UpdateStaffRollInfo()
	self.bStaffRollVisible = true
	_G.EventMgr:SendEvent(_G.EventID.StaffRollBeginPlay)
end

function SequencePlayerVM:HideStaffRollPanel()
    self.bStaffRollVisible = false
	_G.EventMgr:SendEvent(_G.EventID.StaffRollEndPlay)
end

function SequencePlayerVM:ShowStaffRollImage(Image)
	_G.EventMgr:SendEvent(_G.EventID.StaffRollBackImageShow, Image)
end

function SequencePlayerVM:HideStaffRollImage(Image)
	_G.EventMgr:SendEvent(_G.EventID.StaffRollBackImageHide, Image)
end

function SequencePlayerVM:ShowStaffScroll(StaffTable, ScrollTime)
	_G.EventMgr:SendEvent(_G.EventID.StaffRollShowStaffList, StaffTable, ScrollTime)
end

-- ---------------------------------------------------- --------------------------------------------------

return SequencePlayerVM