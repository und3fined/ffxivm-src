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
local UIBinderIsLoopAnimPlay = require("Binder/UIBinderIsLoopAnimPlay")
local CommonUtil = require("Utils/CommonUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")

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
		UIUtil.SetIsVisible(self.PanelJumpOver, false)
	end
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
	self:RegisterGameEvent(EventID.MajorSingBarBegin, self.OnMajorSingBarBegin)
    self:RegisterGameEvent(EventID.MajorSingBarOver, self.OnMajorSingBarOver)
end

function DialogueMainPanelView:OnRegisterBinder()
	if self.Params.ViewType == StoryDefine.UIType.SequenceDialog then
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
		}
		self:RegisterBinders(NpcDialogVM, Binders)
	end

	-- 两边VM都要有这些变量
	local CommonBinders = {
		{ "SpeakerName", UIBinderSetText.New(self.Dialogue, self.Dialogue.TexTitle) },
		{ "TalkContent", UIBinderSetText.New(self.Dialogue, self.Dialogue.TextContent) },
		{ "bIsAutoPlay", UIBinderSetActiveWidgetIndex.New(self, self.AutoPlaySwitcher)},
		{ "bIsAutoPlay", UIBinderIsLoopAnimPlay.New(self, nil, self.AnimAutoLoop, true) },
		{ "bShowSpeed", UIBinderSetIsVisible.New(self, self.PanelSpeed) },
		{ "SpeedLevel", UIBinderSetTextFormat.New(self, self.TextQuantity, "%dX") },
	}
	self:RegisterBinders(self.ViewModel, CommonBinders)
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
		local UIViewConfig = require("Define/UIViewConfig")
		local UILayer = require("UI/UILayer")
		local ViewConfig = UIViewConfig[UIViewID.LoginCreateMakeName]
		UIViewMgr:ShowView(UIViewID.LoginCreateMakeName, {ShowBg = true})
		self:RegisterGameEvent(EventID.RoleLoginRes, self.OnRoleLoginRes)

		UIUtil.SetIsVisible(self.BtnJumpOver, false)
		_G.StoryMgr:PauseSequence()
	else
		self.ViewModel:OnClickButtonJumpOver()
	end
end

function DialogueMainPanelView:OnRoleLoginRes()
	local UIViewConfig = require("Define/UIViewConfig")
	local UILayer = require("UI/UILayer")
	local ViewConfig = UIViewConfig[UIViewID.LoginCreateMakeName]

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

-------------------------------------功能按钮相关E---------------------------------
-------------------------------------Npc对话接口S----------------------------------
--Sequence原有的逻辑就不去动了，ShowUI带进来的参数控制一下
function DialogueMainPanelView:ShowDialog(Name, Post, Content)
	local UIViewID = require("Define/UIViewID")
	self.ViewModel:ShowDialog(Name, Post, Content)

	if self.ShowDialogTimer ~= nil then
		self:UnRegisterTimer(self.ShowDialogTimer)
		self.ShowDialogTimer = nil
	end

	local function SetDialog()
		self.ViewModel:TimeFuncCallBack()
	end
	self.ShowDialogTimer = self:RegisterTimer(SetDialog, 0, 0.05, 0)
	---------------- PlayDialog展开
	_G.UIViewMgr:HideView(UIViewID.EmotionMainPanel)
	_G.BusinessUIMgr:HideMainPanel(UIViewID.MainPanel)

	--这里手动设置一下隐藏，不关闭UI，不然会导致摇杆和移动被解锁
	local InteractiveMainView = _G.UIViewMgr:FindView(UIViewID.InteractiveMainPanel)
	_G.InteractiveMgr:StopTickTimer()
	
	UIUtil.SetInputMode_UIOnly()
    CommonUtil.HideJoyStick()
	_G.InteractiveMgr:SetMainPanelIsVisible(InteractiveMainView, false)
	--_G.InteractiveMgr:HideMainPanel()

	if nil ~= self.Dialogue.AnimLoop then    
		self.Dialogue:PlayAnimation(self.Dialogue.AnimLoop, 0, 0)
	end
	self.ViewModel.bIsDialogVisible = true
end

function DialogueMainPanelView:StopDialog()
	local UIViewID = require("Define/UIViewID")
	if nil ~= self.Dialogue and nil ~= self.Dialogue.AnimLoop then
		self.Dialogue:StopAnimation(self.Dialogue.AnimLoop)
	end
	_G.NpcDialogMgr.PreDefaultDialogID = 0
	_G.BusinessUIMgr:ShowMainPanel(UIViewID.MainPanel,true)
	self.ViewModel:ResetVM()
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
	--该恢复到一级入口
	_G.TimerMgr:AddTimer(nil, function()
		if not self.ViewModel.MajorIsSing then
			self:ShowInteractiveMainView()
		end
	end, 0.8, 0, 1)
end

--交互列表展示的逻辑挪出来这边，因为UI底层机制导致showUI会解锁移动，这里只设置UI显隐
function DialogueMainPanelView:ShowInteractiveMainView()
	local InteractiveMainView = _G.UIViewMgr:FindView(UIViewID.InteractiveMainPanel)
	if not InteractiveMainView then
		return
	end
	if InteractiveMainView.bMainPanelClosedByOtherUI == true then
        return
    end

    if _G.GatherMgr:IsGatherState() then
        return
    end

    --Sequenc播放的时候不展示交互列表了
    if InteractiveMainView.CanShowInteractive == false then return end
	_G.InteractiveMgr:SetMainPanelIsVisible(InteractiveMainView, true)

    _G.InteractiveMgr:ShowEntrances()
    _G.InteractiveMgr:StartTickTimer()
end

function DialogueMainPanelView:AddAutoPlayTimer(localTime)
	if self.AutoPlayTimer ~= nil then
		return
	end
	self.AutoPlayTimer = self:RegisterTimer(function ()
		self.ViewModel:OnClickNextDialogContent()
		self:UnRegisterTimer(self.AutoPlayTimer)
		self.AutoPlayTimer = nil
	end, localTime, 0)
end
-------------------------------------Npc对话接口E----------------------------------
-------------------------------------公共函数S-------------------------------------
function DialogueMainPanelView:SwitchStyle(StyleID)
	_G.NpcDialogMgr.DoSwitchStyle(self.Dialogue, self, StyleID)
end

function DialogueMainPanelView:ClearAllTimer()
	if self.ShowDialogTimer ~= nil then
		self:UnRegisterTimer(self.ShowDialogTimer)
		self.ShowDialogTimer = nil
	end

	if self.AutoPlayTimer ~= nil then
		self:UnRegisterTimer(self.AutoPlayTimer)
		self.AutoPlayTimer = nil
	end

	self.ViewModel.bClickVisible = false
end
-------------------------------------公共函数E-------------------------------------
return DialogueMainPanelView