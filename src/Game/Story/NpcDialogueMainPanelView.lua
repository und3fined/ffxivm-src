local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local NpcDialogVM = require("Game/Story/NpcDialogPlayVM")
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
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderIsLoopAnimPlay = require("Binder/UIBinderIsLoopAnimPlay")
local CommonUtil = require("Utils/CommonUtil")
local EffectUtil = require("Utils/EffectUtil")

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
	self:AddSubView(self.Dialogue)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DialogueMainPanelView:OnInit()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBubblebox)
end

function DialogueMainPanelView:OnShow()
	self.Dialogue:PlayAnimation(self.Dialogue.InAnim)
	self.TextReview:SetText(LSTR(1280001))
	self.TextAuto:SetText(LSTR(1280006))
	self.TextPlay:SetText(LSTR(1280002))
	
	self.TextMultiple:SetText(LSTR(1280003))
	self.TextJumpOver:SetText(LSTR(1280004))
	self.TextVideo:SetText(LSTR(1280005))
end

function DialogueMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self.Dialogue, self.Dialogue.BtnContinue, self.OnClickNextDialogContent)
	self.BackBtn:AddBackClick(self, self.OnClickTravelLogButtonExit)
	UIUtil.AddOnClickedEvent(self, self.BtnJumpOver, self.OnClickButtonJumpOver)
	UIUtil.AddOnClickedEvent(self, self.BtnNext, self.OnClickButtonNextSequence)
	UIUtil.AddOnClickedEvent(self, self.BtnAuto, self.OnClickButtonSwitchAuto)
	UIUtil.AddOnClickedEvent(self, self.BtnReview, self.OnClickButtonOpenHistory)
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickScreen)
	UIUtil.AddOnClickedEvent(self, self.BtnSpeed, self.OnClickButtonChangeSpeed)
end

function DialogueMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MajorSingBarBegin, self.OnMajorSingBarBegin)
    self:RegisterGameEvent(EventID.MajorSingBarOver, self.OnMajorSingBarOver)
	self:RegisterGameEvent(EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
    self:RegisterGameEvent(EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
end

function DialogueMainPanelView:OnRegisterBinder()
	if self.Params.ViewType == StoryDefine.UIType.SequenceDialog then
		self.ViewModel = SequencePlayerVM
		local Binders = {
			{ "bTalkPanelVisible", UIBinderSetIsVisible.New(self, self.Dialogue) },
			{ "bChoicePanelVisible", UIBinderSetIsVisible.New(self, self.BubbleBoxList, false, true) },
			{ "ChoiceMessage", UIBinderSetText.New(self, self.Text) },
			{ "ChoiceUnitList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },

			{ "bHideAllTopButton", UIBinderSetIsVisible.New(self, self.TopButtonGroup, true) }, -- todo 动画控制

			{ "bHasAnyDialog", UIBinderSetIsVisible.New(self, self.PanelReview) },
			{ "bHasAnyDialog", UIBinderSetIsVisible.New(self, self.PanelPlay) },
			{ "bIsCanSkip", UIBinderSetIsVisible.New(self, self.PanelJumpOver) },

			{ "bIsPlayMultiple", UIBinderSetIsVisible.New(self, self.PanelVideo) },
			{ "bIsPlayMultiple", UIBinderSetIsVisible.New(self, self.BackBtn, false, true) },
			{ "TextVideoNum", UIBinderSetText.New(self, self.TextVideoNum) },
		}
		self:RegisterBinders(SequencePlayerVM, Binders)
	else
		self.ViewModel = NpcDialogVM
		local Binders = {
			{ "bTopButtonGroupVisible", UIBinderSetIsVisible.New(self, self.TopButtonGroup) },
			{ "bPanelReviewVisible", UIBinderSetIsVisible.New(self, self.PanelReview) },
			{ "bPanelPlayVisible", UIBinderSetIsVisible.New(self, self.PanelPlay) },
			{ "bHorizontalRightVisible", UIBinderSetIsVisible.New(self, self.HorizontalRight) },
			{ "bBackBtnVisible", UIBinderSetIsVisible.New(self, self.BackBtn) },
			{ "bClickVisible", UIBinderSetIsVisible.New(self, self.BtnClick, false, true) },
			{ "bTalkPanelVisible", UIBinderSetIsVisible.New(self, self.Dialogue) },
			{ "ChoiceMessage", UIBinderSetText.New(self, self.Text) },
			{ "DialogBranchList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
			{ "bChoicePanelVisible", UIBinderSetIsVisible.New(self, self.BubbleBoxList, false, true) },
			{ "IsArrowHide", UIBinderSetIsVisible.New(self, self.Dialogue.BtnContinue, true) },
			{ "DialogTexturePath", UIBinderSetBrushFromAssetPath.New(self, self.Dialogue.UpgradeNpcDialogue.ImgPaper)},
			{ "IsTextureShow", UIBinderSetIsVisible.New(self, self.Dialogue.UpgradeNpcDialogue) },
		}
		self:RegisterBinders(NpcDialogVM, Binders)
	end

	-- 两边VM都要有这些变量
	local CommonBinders = {
		{ "SpeakerName", UIBinderSetText.New(self.Dialogue, self.Dialogue.TexTitle) },
		{ "TalkContent", UIBinderSetText.New(self.Dialogue, self.Dialogue.TextContent) },
		{ "bIsAutoPlay", UIBinderSetActiveWidgetIndex.New(self, self.AutoPlaySwitcher)},
		{ "bIsAutoPlay", UIBinderIsLoopAnimPlay.New(self, nil, self.AnimAutoLoop, true) },
		{ "bIsAutoPlay", UIBinderValueChangedCallback.New(self, nil, self.OnAutoPlayChanged) },
		{ "bShowSpeed", UIBinderSetIsVisible.New(self, self.PanelSpeed) },
		{ "SpeedLevel", UIBinderSetTextFormat.New(self, self.TextQuantity, "%dX") },
	}
	self:RegisterBinders(self.ViewModel, CommonBinders)
end

------------------------------------------功能按钮相关S------------------------------------------------

--触摸函数，顶部按钮点击显示以及对话加速
function DialogueMainPanelView:OnClickScreen(MyGeometry, MouseEvent)
	if self.AutoPlayTimer ~= nil then
		self:UnRegisterTimer(self.AutoPlayTimer)
		self.AutoPlayTimer = nil
	end
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

--Next对话
function DialogueMainPanelView:OnClickNextDialogContent()
	-- 这里的self绑在Dialogue组件上面，要获取父组件
	if self.ParentView then
		self.ParentView.ViewModel:OnClickNextDialogContent()
	else
		_G.FLOG_ERROR("Dialogue.ParentView is nil")
	end
end

--跳过整段对话/对白按钮
function DialogueMainPanelView:OnClickButtonJumpOver()
	self.ViewModel:OnClickButtonJumpOver()
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
	self.ViewModel:PauseAutoPlay(false)
	local bIsSeq = self.Params.ViewType == StoryDefine.UIType.SequenceDialog
	_G.UIViewMgr:ShowView(_G.UIViewID.DialogHistoryLow, {bIsSeq = bIsSeq})
end

function DialogueMainPanelView:OnGameEventAppEnterBackground()
	self.ViewModel:PauseAutoPlay(false)
end

function DialogueMainPanelView:OnGameEventAppEnterForeground()
	local View = _G.UIViewMgr:FindView(_G.UIViewID.DialogHistoryLow)
	if not View then
		self.ViewModel:ResumeAutoPlay()
	end
end
-------------------------------------功能按钮相关E---------------------------------
-------------------------------------Npc对话接口S----------------------------------
--Sequence原有的逻辑就不去动了，ShowUI带进来的参数控制一下
function DialogueMainPanelView:ShowDialog(Name, Post, Content, TexturePath)
	self.ViewModel.DialogueStartTime = TimeUtil.GetLocalTimeMS()
	local UIViewID = require("Define/UIViewID")
	self.ViewModel:ShowDialog(Name, Post, Content, TexturePath)
	---------------- PlayDialog展开
	_G.UIViewMgr:HideView(_G.UIViewID.EmotionMainPanel)
	-- _G.BusinessUIMgr:HideMainPanel(_G.UIViewID.MainPanel, true)
	--这里需要处理一下外部调用对话的情况
	if not _G.NpcDialogMgr.HudHideState then
		FLOG_INFO("DialogueMainPanelView:HideHUD")
		_G.HUDMgr:SetIsDrawHUD(false)
		self.HudHideState = true
	end	
	--这里手动设置一下隐藏，不关闭UI，不然会导致摇杆和移动被解锁
	local InteractiveMainView = _G.UIViewMgr:FindView(UIViewID.InteractiveMainPanel)
	
	UIUtil.SetInputMode_UIOnly()
    CommonUtil.HideJoyStick()
	_G.InteractiveMgr:HideTargetSwitchPanel()
	--_G.InteractiveMgr:SetMainPanelIsVisible(InteractiveMainView, false)
	--_G.InteractiveMgr:HideMainPanel()
	_G.InteractiveMgr:HideEntrance()

	if nil ~= self.Dialogue.AnimLoop then    
		self.Dialogue:PlayAnimation(self.Dialogue.AnimLoop, 0, 0)
	end
	self.ViewModel.bIsDialogVisible = true
	EffectUtil.SetIsInDialog(true)
	self.ViewModel:SetContorllerButtonVisible(true)
end

function DialogueMainPanelView:StopDialog()
	EffectUtil.SetIsInDialog(false)
	local UIViewID = require("Define/UIViewID")
	if nil ~= self.Dialogue and nil ~= self.Dialogue.AnimLoop then
		self.Dialogue:StopAnimation(self.Dialogue.AnimLoop)
	end
	_G.NpcDialogMgr.PreDefaultDialogID = 0
	--_G.BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel)

	if self.HudHideState then
		FLOG_INFO("DialogueMainPanelView:ShowHUD")
		_G.HUDMgr:SetIsDrawHUD(true)
		self.HudHideState = false
	end	
	self.ViewModel:ResetVM()
    UIUtil.SetInputMode_GameAndUI()
	CommonUtil.ShowJoyStick()
	self.ViewModel.bIsDialogVisible = false

end

function DialogueMainPanelView:OnMajorSingBarBegin()    
    self.ViewModel.MajorIsSing = true
end

function DialogueMainPanelView:OnMajorSingBarOver()
    self.ViewModel.MajorIsSing = false
end

function DialogueMainPanelView:HideDialog()
	self:StopDialog()
	if not self.ViewModel.MajorIsSing then
		self:ShowInteractiveMainView()
	end
end

--交互列表展示的逻辑挪出来这边，因为UI底层机制导致showUI会解锁移动，这里只设置UI显隐
function DialogueMainPanelView:ShowInteractiveMainView()
	local InteractiveMainView = _G.UIViewMgr:FindView(UIViewID.InteractiveMainPanel)
	local CommonFadePanel = _G.UIViewMgr:FindView(UIViewID.CommonFadePanel)
    if _G.GatherMgr:IsGatherState() then
		FLOG_ERROR("DialogMainPanel Show InteractivePanel is In IsCollectionState !!")
    end
	
    --Sequenc播放的时候不展示交互列表了
	local IsInSeq = _G.StoryMgr:SequenceIsPlaying() or CommonFadePanel
    if _G.InteractiveMgr.CanShowInteractive == false or IsInSeq then return end
	if InteractiveMainView then
		_G.InteractiveMgr:SetMainPanelIsVisible(InteractiveMainView, true)
	end
    _G.InteractiveMgr:ShowEntrances()
end

function DialogueMainPanelView:AddAutoPlayTimer(localTime)
	if localTime < self.ViewModel.AutoWaitTime then localTime = self.ViewModel.AutoWaitTime end
	if self.AutoPlayTimer ~= nil then
		self:UnRegisterTimer(self.AutoPlayTimer)
		self.AutoPlayTimer = nil
	end
	self.AutoPlayTimer = self:RegisterTimer(function ()
		if self.ViewModel.bIsAutoPlay then
			self.ViewModel:OnClickNextDialogContentAuto()
		end
	end, localTime, 0)
end


-------------------------------------Npc对话接口E----------------------------------
-------------------------------------公共函数S-------------------------------------
function DialogueMainPanelView:SwitchStyle(StyleID)
	_G.NpcDialogMgr.DoSwitchStyle(self.Dialogue, self, StyleID)
end

function DialogueMainPanelView:ClearAllTimer()

	if self.AutoPlayTimer ~= nil then
		self:UnRegisterTimer(self.AutoPlayTimer)
		self.AutoPlayTimer = nil
	end

	self.ViewModel.bClickVisible = false
end

function DialogueMainPanelView:OnHide()
	if self.Params.ViewType == StoryDefine.UIType.NpcDialog then
		_G.NpcDialogMgr.MainPanel = nil
		self:ClearAllTimer()
		self:HideDialog()
		self.CurrentStyleID = nil
	end
	--self.Dialogue:PlayAnimation(self.Dialogue.OutAnim)
end

function DialogueMainPanelView:OnAutoPlayChanged()
	if self.ViewModel.bIsAutoPlay then
		self.Dialogue:PlayAnimation(self.Dialogue.AnimContinue0)
	else
		self.Dialogue:PlayAnimation(self.Dialogue.AnimContinue1)
	end
end
-------------------------------------公共函数E-------------------------------------
return DialogueMainPanelView