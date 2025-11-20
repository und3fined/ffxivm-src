local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SequencePlayerVM = require("Game/Story/SequencePlayerVM")
local EventID = require("Define/EventID")
local StoryDefine = require("Game/Story/StoryDefine")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderIsLoopAnimPlay = require("Binder/UIBinderIsLoopAnimPlay")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")

local LSTR = _G.LSTR

---@class DialogueMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AutoPlaySwitcher UFWidgetSwitcher
---@field BackBtn CommBackBtnView
---@field BtnAuto UFButton
---@field BtnClick UFButton
---@field BtnJumpOver UFButton
---@field BtnNext UFButton
---@field BtnReview UFButton
---@field BtnSpeed UFButton
---@field BubbleBoxList UFVerticalBox
---@field DialogHistory NPCPlotReviewItemView
---@field Dialogue NewNPCTalkDialogPanelView
---@field HorizontalRight UFHorizontalBox
---@field IconReview UFImage
---@field PanelJumpOver UFCanvasPanel
---@field PanelPlay UFCanvasPanel
---@field PanelReview UFCanvasPanel
---@field PanelSpeed UFCanvasPanel
---@field PanelVideo UFCanvasPanel
---@field TableViewBubblebox UTableView
---@field Text UFTextBlock
---@field TextAuto UFTextBlock
---@field TextJumpOver UFTextBlock
---@field TextMultiple UFTextBlock
---@field TextPlay UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextReview UFTextBlock
---@field TextVideo UFTextBlock
---@field TextVideoNum UFTextBlock
---@field TopButtonGroup UFCanvasPanel
---@field AnimAutoLoop UWidgetAnimation
---@field AnimBubbleBoxIn UWidgetAnimation
---@field AnimBubbleBoxOut UWidgetAnimation
---@field AnimTopButtonIn UWidgetAnimation
---@field AnimTopButtonOut UWidgetAnimation
---@field SubTitles text
---@field NpcName text
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DialogueMainPanelView = LuaClass(UIView, true)

function DialogueMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AutoPlaySwitcher = nil
	--self.BackBtn = nil
	--self.BtnAuto = nil
	--self.BtnClick = nil
	--self.BtnJumpOver = nil
	--self.BtnNext = nil
	--self.BtnReview = nil
	--self.BtnSpeed = nil
	--self.BubbleBoxList = nil
	--self.DialogHistory = nil
	--self.Dialogue = nil
	--self.HorizontalRight = nil
	--self.IconReview = nil
	--self.PanelJumpOver = nil
	--self.PanelPlay = nil
	--self.PanelReview = nil
	--self.PanelSpeed = nil
	--self.PanelVideo = nil
	--self.TableViewBubblebox = nil
	--self.Text = nil
	--self.TextAuto = nil
	--self.TextJumpOver = nil
	--self.TextMultiple = nil
	--self.TextPlay = nil
	--self.TextQuantity = nil
	--self.TextReview = nil
	--self.TextVideo = nil
	--self.TextVideoNum = nil
	--self.TopButtonGroup = nil
	--self.AnimAutoLoop = nil
	--self.AnimBubbleBoxIn = nil
	--self.AnimBubbleBoxOut = nil
	--self.AnimTopButtonIn = nil
	--self.AnimTopButtonOut = nil
	--self.SubTitles = nil
	--self.NpcName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DialogueMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.DialogHistory)
	self:AddSubView(self.Dialogue)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DialogueMainPanelView:OnInit()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBubblebox)
end

function DialogueMainPanelView:OnShow()
	self.TextReview:SetText(LSTR(1280001))
	self.TextAuto:SetText(LSTR(1280006))
	self.TextPlay:SetText(LSTR(1280002))
	
	self.TextMultiple:SetText(LSTR(1280003))
	self.TextJumpOver:SetText(LSTR(1280004))
	self.TextVideo:SetText(LSTR(1280005))

	if _G.TravelLogMgr:GetIsPlaying() then
		FLOG_INFO("DialogueMainPanelView: TravelLogMgr hide PanelJumpOver")
		UIUtil.SetIsVisible(self.PanelJumpOver, false)
	end
	self:InitPanelHandle()
end

function DialogueMainPanelView:OnHide()
	self:HidePanelHandle()
end

function DialogueMainPanelView:OnRegisterUIEvent()
	self.BackBtn:AddBackClick(self, self.OnClickTravelLogButtonExit)
	UIUtil.AddOnClickedEvent(self, self.BtnJumpOver, self.OnClickButtonJumpOver)
	UIUtil.AddOnClickedEvent(self, self.BtnNext, self.OnClickButtonNextSequence)
	UIUtil.AddOnClickedEvent(self, self.BtnAuto, self.OnClickButtonSwitchAuto)
	UIUtil.AddOnClickedEvent(self, self.BtnReview, self.OnClickButtonOpenHistory)
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickScreen)
	UIUtil.AddOnClickedEvent(self, self.BtnSpeed, self.OnClickButtonChangeSpeed)
end

function DialogueMainPanelView:OnRegisterGameEvent()
		self:RegisterGameEvent(EventID.InputActionTypeChange, self.InitPanelHandle)
		self:RegisterGameEvent(EventID.GamePadSkip, self.OnGamePadSkip)
		self:RegisterGameEvent(EventID.GamePadEnter, self.OnGamePadEnter)
		self:RegisterGameEvent(EventID.GamepadDPadUp, self.OnGamepadDPadUp)
		self:RegisterGameEvent(EventID.GamepadDPadDown, self.OnGamepadDPadDown)
		self:RegisterGameEvent(EventID.OnUpdateHandleCusAction, self.InitPanelHandle)
end

function DialogueMainPanelView:OnRegisterBinder()
	self.ViewModel = SequencePlayerVM
	local Binders = {
		{ "bTalkPanelVisible", UIBinderSetIsVisible.New(self, self.Dialogue) },
		{ "bChoicePanelVisible", UIBinderSetIsVisible.New(self, self.BubbleBoxList, false, true) },
		{ "ChoiceMessage", UIBinderSetText.New(self, self.Text) },
		{ "ChoiceUnitList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{ "bTouchWaitCfg", UIBinderSetIsVisible.New(self, self.Dialogue.BtnContinue) },

		{ "bHideAllTopButton", UIBinderSetIsVisible.New(self, self.TopButtonGroup, true) }, -- todo 动画控制
		{ "bInDialogHistory", UIBinderSetIsVisible.New(self, self.DialogHistory) },
		{ "bInDialogHistory", UIBinderSetIsVisible.New(self, self.BtnClick, true, true) },

		{ "bHasAnyDialog", UIBinderSetIsVisible.New(self, self.PanelReview) },
		{ "bShowAutoPlayBtn", UIBinderSetIsVisible.New(self, self.PanelPlay) },
		{ "bShowJumpOverBtn", UIBinderSetIsVisible.New(self, self.PanelJumpOver) },

		{ "bIsPlayMultiple", UIBinderSetIsVisible.New(self, self.PanelVideo) },
		{ "bIsPlayMultiple", UIBinderSetIsVisible.New(self, self.BackBtn, false, true) },
		{ "TextVideoNum", UIBinderSetText.New(self, self.TextVideoNum) },

		{ "SpeakerName", UIBinderSetText.New(self.Dialogue, self.Dialogue.TexTitle) },
		{ "TalkContent", UIBinderSetText.New(self.Dialogue, self.Dialogue.TextContent) },
		{ "bIsAutoPlay", UIBinderSetActiveWidgetIndex.New(self, self.AutoPlaySwitcher)},
		{ "bIsAutoPlay", UIBinderIsLoopAnimPlay.New(self, nil, self.AnimAutoLoop, true) },
		{ "bIsAutoPlay", UIBinderValueChangedCallback.New(self, nil, self.OnAutoPlayChanged) },
		{ "bShowSpeed", UIBinderSetIsVisible.New(self, self.PanelSpeed) },
		{ "SpeedLevel", UIBinderSetTextFormat.New(self, self.TextQuantity, "%dX") },
		{ "bHandleBtnContinue", UIBinderSetIsVisible.New(self, self.Dialogue.HandleState)},
		{ "bHandleBtnJumpOver", UIBinderSetIsVisible.New(self, self.HandleState)},
		{ "HandleBtnContinue", UIBinderSetText.New(self, self.Dialogue.HandleState.TextNum)},
		{ "HandleBtnJumpOver", UIBinderSetText.New(self, self.HandleState.TextNum)},
	}
	self:RegisterBinders(SequencePlayerVM, Binders)
end

------------------------------------------功能按钮相关S------------------------------------------------

--触摸函数，顶部按钮点击显示以及对话加速
function DialogueMainPanelView:OnClickScreen(MyGeometry, MouseEvent)
	self.ViewModel:OnClickScreen()
end

--自动播放
function DialogueMainPanelView:OnClickButtonSwitchAuto()
	self.ViewModel:OnClickButtonSwitchAuto()
end

--倍速按钮
function DialogueMainPanelView:OnClickButtonChangeSpeed()
	self.ViewModel:OnClickButtonChangeSpeed()
end

--跳过整段对话/对白按钮
function DialogueMainPanelView:OnClickButtonJumpOver()
	local PWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
	--出生场景，并且是莫莫蒂 设置昵称的过场动画的时候(莫莫蒂的那个)，才做特殊处理
	--		暂停剧情的播放，然后走设置昵称的流程，
	--		设置昵称的流程走完，再OnClickButtonJumpOver，完成任务
    if _G.NewbieMgr:IsNewbiePWorld(PWorldResID) and _G.StoryMgr:GetCurrentSequenceID() == 8000142 
		and _G.DemoMajorType == 2 then
		UIViewMgr:ShowView(UIViewID.LoginCreateMakeName, {ShowBg = true})
		self:RegisterGameEvent(EventID.RoleLoginRes, self.OnRoleLoginRes)

		FLOG_INFO("DialogueMainPanelView: LoginCreateMakeName hide PanelJumpOver")
		UIUtil.SetIsVisible(self.BtnJumpOver, false)
		_G.StoryMgr:PauseSequence()
	else
		self.ViewModel:OnClickButtonJumpOver()
	end
end

function DialogueMainPanelView:OnRoleLoginRes()
	UIViewMgr:HideView(UIViewID.LoginCreateMakeName)
	self:UnRegisterGameEvent(EventID.RoleLoginRes, self.OnRoleLoginRes)
	
	UIUtil.SetIsVisible(self.BtnJumpOver, true, true)
	FLOG_INFO("login makename finish, jumpover")
	self.ViewModel:OnClickButtonJumpOver()
	self:Hide()
	_G.LoginUIMgr.LoginReConnectMgr:ExitCreateRole()
end

--新退出动画按钮
function DialogueMainPanelView:OnClickTravelLogButtonExit()
	_G.TravelLogMgr:ExitPlay()
end

--播放下一个动画
function DialogueMainPanelView:OnClickButtonNextSequence()
	_G.StoryMgr:StopSequence()
end

--剧情回顾
function DialogueMainPanelView:OnClickButtonOpenHistory()
	self.ViewModel:PauseAutoPlay()
	local bIsSeq = self.Params.ViewType == StoryDefine.UIType.SequenceDialog
	self.DialogHistory:SetParams({bIsSeq = bIsSeq})
	SequencePlayerVM.bInDialogHistory = true
end

function DialogueMainPanelView:SwitchStyle(StyleID)
	_G.NpcDialogMgr.DoSwitchStyle(self.Dialogue, self, StyleID)
end

function DialogueMainPanelView:OnAutoPlayChanged()
	if self.ViewModel.bIsAutoPlay then
		self.Dialogue:PlayAnimation(self.Dialogue.AnimContinue0)
	else
		self.Dialogue:PlayAnimation(self.Dialogue.AnimContinue1)
	end
end

---手柄交互相关
function DialogueMainPanelView:InitPanelHandle(IsHandleAttached)
	if nil == IsHandleAttached or type(IsHandleAttached) ~= "boolean" then
		IsHandleAttached = _G.SettingsHandleMgr:GetIsHandleAttached()
	end
	if self.ViewModel then
		self.ViewModel:UpdateHandlebtn(IsHandleAttached, true)
	end
	if IsHandleAttached then
		_G.NpcDialogMgr:RegisterHandleKeyDownData(SettingsHandleDefine.HandleCustomActionType.NormalSkill)
		_G.NpcDialogMgr:RegisterHandleKeyDownData(SettingsHandleDefine.HandleCustomActionType.Jump)
		_G.NpcDialogMgr:RegisterHandleKeyDownData("HandleUp")
		_G.NpcDialogMgr:RegisterHandleKeyDownData("HandleDown")
	else
		_G.NpcDialogMgr:UnRegisterHandleKeyDownData(SettingsHandleDefine.HandleCustomActionType.NormalSkill)
		_G.NpcDialogMgr:UnRegisterHandleKeyDownData(SettingsHandleDefine.HandleCustomActionType.Jump)
		_G.NpcDialogMgr:UnRegisterHandleKeyDownData("HandleUp")
		_G.NpcDialogMgr:UnRegisterHandleKeyDownData("HandleDown")
	end
end

function DialogueMainPanelView:HidePanelHandle()
	_G.NpcDialogMgr:UnRegisterHandleKeyDownData(SettingsHandleDefine.HandleCustomActionType.NormalSkill)
	_G.NpcDialogMgr:UnRegisterHandleKeyDownData(SettingsHandleDefine.HandleCustomActionType.Jump)
	_G.NpcDialogMgr:UnRegisterHandleKeyDownData("HandleUp")
	_G.NpcDialogMgr:UnRegisterHandleKeyDownData("HandleDown")
end

function DialogueMainPanelView:OnGamePadSkip()
	self:OnClickButtonJumpOver()
end

function DialogueMainPanelView:OnGamePadEnter(Params)
	local Priority = Params.IntParam1
	if Priority ~= SettingsHandleDefine.HandleActionPriority.NpcDialogCustom then
		return
	end
	if not UIUtil.IsVisible(self.BtnClick) then
		return
	end
	self.ViewModel:OnClickScreen()
end

function DialogueMainPanelView:OnGamepadDPadUp()
	self.ViewModel:SwitchCurSelectItem(false)
	_G.EventMgr:SendEvent(EventID.GamePadUpdateDialogue)
end

function DialogueMainPanelView:OnGamepadDPadDown()
	self.ViewModel:SwitchCurSelectItem(true)
	_G.EventMgr:SendEvent(EventID.GamePadUpdateDialogue)
end

return DialogueMainPanelView