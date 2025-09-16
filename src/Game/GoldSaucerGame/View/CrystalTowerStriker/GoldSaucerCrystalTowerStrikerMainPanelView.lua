---
--- Author: Administrator
--- DateTime: 2024-03-08 19:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MonsterTossAudioDefine = require("Game/GoldSaucerMiniGame/MonsterToss/MonsterTossAudioDefine")
local ObjectGCType = require("Define/ObjectGCType")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreMgr = require("Game/Score/ScoreMgr")
local UIBinderCanvasSlotSetPosition = require("Binder/UIBinderCanvasSlotSetPosition")
local UIBinderSetOutlineColor = require("Binder/UIBinderSetOutlineColor")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")
local CrystalTowerAudioDefine = require("Game/GoldSaucerMiniGame/CrystalTower/CrystalTowerAudioDefine")
local CrystalTowerInteractionVM = require("Game/GoldSaucerGame/View/CrystalTowerStriker/ItemVM/CrystalTowerInteractionVM")
local AudioPath = CrystalTowerAudioDefine.AudioPath

local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local DelayTime = GoldSaucerMiniGameDefine.DelayTime
local LSTR = _G.LSTR
local UE = _G.UE
local UIViewID = _G.UIViewID
local EventID = _G.EventID
local UIViewMgr = _G.UIViewMgr
local FLOG_ERROR = _G.FLOG_ERROR

local ShootingTipsBPName = "GoldSaucerGame/CrystalTowerStriker/GoldSaucer_CrystalTowerStrikerShootingTipsItem_UIBP"
local InteractionItemBPName = "GoldSaucerGame/CrystalTowerStriker/Item/GoldSaucer_CrystalTowerStrikerCrystalItem_UIBP"

---@class GoldSaucerCrystalTowerStrikerMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Award GoldSaucerGameCuffAwardItemView
---@field BottomPanel MainLBottomPanelView
---@field Btn1 CommBtnMView
---@field Btn2 CommBtnMView
---@field ChallengeBegins GoldSaucerCuffchallengeBeginsItemView
---@field ChallengeResults GoldSaucerCrystalTowerStrikerChallengeResultsItemView
---@field CloseBtn CommonCloseBtnView
---@field Critical GoldSaucerGameCommCriticalItemView
---@field CrystalEFF1 GoldSaucerCrystalTowerStrikerCrystalItemEFFView
---@field CrystalEFF2 GoldSaucerCrystalTowerStrikerCrystalItemEFFView
---@field CrystalEFF3 GoldSaucerCrystalTowerStrikerCrystalItemEFFView
---@field CrystalEFF4 GoldSaucerCrystalTowerStrikerCrystalItemEFFView
---@field CrystalEFF5 GoldSaucerCrystalTowerStrikerCrystalItemEFFView
---@field CrystalEFF6 GoldSaucerCrystalTowerStrikerCrystalItemEFFView
---@field FHorizontalBox_0 UFHorizontalBox
---@field IconGold UFImage
---@field ImgMask2 UFImage
---@field ImgTipsLight UFImage
---@field JunctionLine GoldSaucerCrystalTowerStrikerJunctionLineItemView
---@field MainTeamPanel MainTeamPanelView
---@field MoneySlot CommMoneySlotView
---@field PanelChallengeFailurePrompt UFCanvasPanel
---@field PanelChallengeRecordList UFVerticalBox
---@field PanelCold UFCanvasPanel
---@field PanelCrystal UFCanvasPanel
---@field PanelMain UFCanvasPanel
---@field PanelNormal UFCanvasPanel
---@field PanelResult UFCanvasPanel
---@field ProBar UProgressBar
---@field ProBarScore GoldSaucerCrystalTowerStrikerProBarScoreItemView
---@field ScoreFeedback GoldSaucerCrystalTowerStrikerScoreFeedbackItemView
---@field StageTips GoldSaucerMooglePawStageTipsItemView
---@field TableViewList UTableView
---@field TableViewScoreFeedback UTableView
---@field TextAward UFTextBlock
---@field TextHint1 UFTextBlock
---@field TextMagnification UFTextBlock
---@field TextPz UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextQuantity1 UFTextBlock
---@field AnimaNormalOut UWidgetAnimation
---@field AnimaNumber UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimSettlement UWidgetAnimation
---@field AnimShock UWidgetAnimation
---@field AnimTipsIn UWidgetAnimation
---@field AnimTitleLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCrystalTowerStrikerMainPanelView = LuaClass(UIView, true)

function GoldSaucerCrystalTowerStrikerMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Award = nil
	--self.BottomPanel = nil
	--self.Btn1 = nil
	--self.Btn2 = nil
	--self.ChallengeBegins = nil
	--self.ChallengeResults = nil
	--self.CloseBtn = nil
	--self.Critical = nil
	--self.CrystalEFF1 = nil
	--self.CrystalEFF2 = nil
	--self.CrystalEFF3 = nil
	--self.CrystalEFF4 = nil
	--self.CrystalEFF5 = nil
	--self.CrystalEFF6 = nil
	--self.FHorizontalBox_0 = nil
	--self.IconGold = nil
	--self.ImgMask2 = nil
	--self.ImgTipsLight = nil
	--self.JunctionLine = nil
	--self.MainTeamPanel = nil
	--self.MoneySlot = nil
	--self.PanelChallengeFailurePrompt = nil
	--self.PanelChallengeRecordList = nil
	--self.PanelCold = nil
	--self.PanelCrystal = nil
	--self.PanelMain = nil
	--self.PanelNormal = nil
	--self.PanelResult = nil
	--self.ProBar = nil
	--self.ProBarScore = nil
	--self.ScoreFeedback = nil
	--self.StageTips = nil
	--self.TableViewList = nil
	--self.TableViewScoreFeedback = nil
	--self.TextAward = nil
	--self.TextHint1 = nil
	--self.TextMagnification = nil
	--self.TextPz = nil
	--self.TextQuantity = nil
	--self.TextQuantity1 = nil
	--self.AnimaNormalOut = nil
	--self.AnimaNumber = nil
	--self.AnimIn = nil
	--self.AnimSettlement = nil
	--self.AnimShock = nil
	--self.AnimTipsIn = nil
	--self.AnimTitleLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Award)
	self:AddSubView(self.BottomPanel)
	self:AddSubView(self.Btn1)
	self:AddSubView(self.Btn2)
	self:AddSubView(self.ChallengeBegins)
	self:AddSubView(self.ChallengeResults)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.Critical)
	self:AddSubView(self.CrystalEFF1)
	self:AddSubView(self.CrystalEFF2)
	self:AddSubView(self.CrystalEFF3)
	self:AddSubView(self.CrystalEFF4)
	self:AddSubView(self.CrystalEFF5)
	self:AddSubView(self.CrystalEFF6)
	self:AddSubView(self.JunctionLine)
	self:AddSubView(self.MainTeamPanel)
	self:AddSubView(self.MoneySlot)
	self:AddSubView(self.ProBarScore)
	self:AddSubView(self.ScoreFeedback)
	self:AddSubView(self.StageTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerMainPanelView:OnInit()

	self.MainTeamPanel.nforBtn.HelpInfoID = 11044
	self.ResultTableViewAdapter =  UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, true)
	self.InteractResultTableViewAdapter =  UIAdapterTableView.CreateAdapter(self, self.TableViewScoreFeedback, nil, false)

	self.Binders = {
		-- {"TotalTimeTextTitle", UIBinderSetText.New(self, self.TextTime)},
		{"TotalTimeTextTitle", UIBinderSetText.New(self, self.MainTeamPanel.TextTime)},

		{"bAddScoreVisible", UIBinderSetIsVisible.New(self, self.ProBarScore)},
		{"bPanelNormalVisible", UIBinderSetIsVisible.New(self, self.PanelNormal)},
		{"AddScore", UIBinderSetText.New(self, self.ProBarScore.TextScore)},
		{"AddScoreOutLineColor", UIBinderSetOutlineColor.New(self, self.ProBarScore.TextScore)},
		{"AddScoreColor", UIBinderSetColorAndOpacityHex.New(self, self.ProBarScore.TextScore)},
		{"bImgMask2Visible", UIBinderSetIsVisible.New(self, self.ImgMask2)},
		{"TextQuantityValue", UIBinderSetText.New(self, self.TextQuantity)},
		{"CTStrengthPro", UIBinderSetPercent.New(self, self.ProBar)},
		{"CTTextMultiple", UIBinderSetText.New(self, self.TextMagnification)},
		{"bTextMultipleVisible", UIBinderSetIsVisible.New(self, self.TextMagnification)},
		{"bFailed", UIBinderSetIsVisible.New(self, self.PanelChallengeFailurePrompt)},
		{"bSuccessed", UIBinderSetIsVisible.New(self, self.PanelChallengeRecordList)},
		{"EndResultVMList", UIBinderUpdateBindableList.New(self, self.ResultTableViewAdapter)},
		{"RewardGot", UIBinderSetTextFormatForMoney.New(self, self.Award.TextQuantity)},
		{"RewardGot", UIBinderSetTextFormatForMoney.New(self, self.MainTeamPanel.TextNumber)},
		{"CTAddRewardGot",  UIBinderSetText.New(self, self.MainTeamPanel.TextNumber1)},

		{"AwardIconPath", UIBinderSetBrushFromAssetPath.New(self, self.Award.Comm96Slot.Icon)},
		{"TextHint", UIBinderSetText.New(self, self.StageTips.TextTips)},

		{"bShootingTipVisible", UIBinderValueChangedCallback.New(self, nil, self.ChangeShootingTips)},
		{"JDCoinColor", UIBinderSetColorAndOpacityHex.New(self, self.TextQuantity1)},
		{"RightBtnContent", UIBinderSetText.New(self, self.Btn2.TextContent)},
		{"bEnterEndState", UIBinderValueChangedCallback.New(self, nil, self.ChangeShowType)},
		{"AddScorePos", UIBinderCanvasSlotSetPosition.New(self, self.ProBarScore, true)},
		{"InteractResultVMList", UIBinderUpdateBindableList.New(self, self.InteractResultTableViewAdapter)},
		{"bInEndRound", UIBinderSetIsVisible.New(self, self.ScoreFeedback)},
		{"CriticalText", UIBinderSetText.New(self, self.Critical.TextQuantity)},

	}
	self.ArriveEffectPool = {
		self.CrystalEFF1, self.CrystalEFF2, self.CrystalEFF3, self.CrystalEFF4, self.CrystalEFF5, self.CrystalEFF6
	}

	self.InteractionPool = {}
end

function GoldSaucerCrystalTowerStrikerMainPanelView:OnDestroy()

end

function GoldSaucerCrystalTowerStrikerMainPanelView:OnShow()
	UIUtil.SetIsVisible(self.BottomPanel, false)
	self:SetViewToDefault()

	self.TextHint1:SetText(LSTR(260011)) -- 不要气馁，再挑战看看吧！
	self.TextAward:SetText(LSTR(260012)) -- 奖励
	self.TextQuantity1:SetText(1) -- 阿拉伯数字1
	self.Btn1.TextContent:SetText(LSTR(10036)) -- 离 开
	self.TextPz:SetText(LSTR(260013)) -- Pz

end

function GoldSaucerCrystalTowerStrikerMainPanelView:OnHide()
	self.IsHide = true
	self:StopAllAnimations()
	self.Award:StopAllAnimations()
end

function GoldSaucerCrystalTowerStrikerMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.Btn1.Button, self.OnLeaveBtnClick)
	UIUtil.AddOnPressedEvent(self, self.Btn2.Button, self.OnFightAgainBtnClick)
	self:BindBtnCloseCallBack()
end

function GoldSaucerCrystalTowerStrikerMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MiniGameMainPanelPlayAnim, self.MiniGameCuffMainPlayAnimEvent)
	self:RegisterGameEvent(EventID.ScoreUpdate, self.OnMoneyUpdate)


end

function GoldSaucerCrystalTowerStrikerMainPanelView:OnRegisterBinder()
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end
	self:RegisterBinders(ViewModel, self.Binders)

	-- local AllInteractionVM = ViewModel:GetAllInteractionVM()
	-- for i = 1, 16 do
	-- 	local NameIndex = string.format("Crystal%d", i)
	-- 	local InteractVM = AllInteractionVM[i]
	-- 	self[NameIndex]:SetParams({Data = InteractVM })
	-- end
	local InteractResultVM = ViewModel:GetInteractResultVM()
	self.JunctionLine:SetParams({Data = InteractResultVM})
	-- self.InteractionPool = self:ConstructInteractionPool()
	local CenterInteractResultVM = ViewModel:GetCenterInteractResultVM()
	self.ScoreFeedback:SetParams({Data = CenterInteractResultVM})
end


function GoldSaucerCrystalTowerStrikerMainPanelView:ChangeShootingTips(NewValue)
	if NewValue then
		self:ShowShootingTips()
	else
		self:HideShootingTips()
	end
end

function GoldSaucerCrystalTowerStrikerMainPanelView:ShowShootingTips()
	if self.ShootingTips then
		return
	end
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end
	local InteractionResultTipVM = ViewModel:GetInteractionResultTipVM()
	local Params = { Data = InteractionResultTipVM }
	self.ShootingTips = _G.UIViewMgr:CreateViewByName(ShootingTipsBPName, ObjectGCType.NoCache, self, true, true, Params)
	if self.ShootingTips == nil then
		return
	end
	self.PanelMain:AddChildToCanvas(self.ShootingTips)
	local Anchor = _G.UE.FAnchors()
	Anchor.Minimum = _G.UE.FVector2D(0.5, 0)
	Anchor.Maximum = _G.UE.FVector2D(0.5, 0)
	local Alignment = _G.UE.FVector2D(0.5, 0)
	local Size = _G.UE.FVector2D(100, 30)
	local Position = _G.UE.FVector2D(0, 84)
	UIUtil.CanvasSlotSetAnchors(self.ShootingTips, Anchor)
	UIUtil.CanvasSlotSetAlignment(self.ShootingTips, Alignment)
	UIUtil.CanvasSlotSetSize(self.ShootingTips, Size)
	UIUtil.CanvasSlotSetPosition(self.ShootingTips, Position)
	UIUtil.CanvasSlotSetAutoSize(self.ShootingTips, true)
	_G.UIViewMgr:ShowSubView(self.ShootingTips, Params)
end

function GoldSaucerCrystalTowerStrikerMainPanelView:HideShootingTips()
	if self.ShootingTips == nil then
		return
	end
	_G.UIViewMgr:HideSubView(self.ShootingTips)
	self.PanelMain:RemoveChild(self.ShootingTips)
	_G.UIViewMgr:RecycleView(self.ShootingTips)
	self.ShootingTips = nil
end

-- 点击离开按钮
function GoldSaucerCrystalTowerStrikerMainPanelView:OnLeaveBtnClick()
	GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.CrystalTower, false)
	self.Btn2.Button:SetIsEnabled(false)

	self:Hide()
end

-- 点击再战按钮
function GoldSaucerCrystalTowerStrikerMainPanelView:OnFightAgainBtnClick()
	local OwnJdCoinNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE) --持有的金碟币
	if OwnJdCoinNum >= 1 then
		self:PlayAnimation(self.AnimIn)
		self:SetViewToDefault()
		self.Btn1.Button:SetIsEnabled(false)
		GoldSaucerMiniGameMgr:OnBtnFightAgainClick(MiniGameType.CrystalTower)
	else
		_G.JumboCactpotMgr:GetJDcoin()
		self:OnLeaveBtnClick()
	end
end

-- function GoldSaucerCrystalTowerStrikerMainPanelView:ConstructBeginPos()
-- 	local BeginPos = {}
-- 	for i = 1, 5 do
-- 		local NameIndex = string.format("Crystal%d", i)
-- 		table.insert(BeginPos, UE.FVector2D(UIUtil.CanvasSlotGetPosition(self[NameIndex]).X, -375) )
-- 	end
-- 	return BeginPos
-- end

--- 播放动画
function GoldSaucerCrystalTowerStrikerMainPanelView:MiniGameCuffMainPlayAnimEvent(InAnim, bNormal)
	local Anim = MiniGameClientConfig[MiniGameType.CrystalTower].Anim
	local ChallengeResults = self.ChallengeResults
	if InAnim == Anim.AnimSettlementIn then
		-- self:PlayAnimation(self.AnimSettlementIn)
		-- self:OnPlayAnimSettlementIn()
	elseif InAnim == Anim.AddScoreAnimIn then
		self:PlayAnimation(self.AnimaNumber)
		self.ProBarScore:PlayAnimation(self.ProBarScore.AnimIn)
	elseif InAnim == Anim.AnimaNormalOut then
		self:OnPlayAnimNormalOut()
	elseif InAnim == Anim.AnimVictory then
		ChallengeResults:PlayAnimation(ChallengeResults.AnimVictory)
		AudioUtil.LoadAndPlay2DSound(MonsterTossAudioDefine.AudioPath.GameSuccess)
	elseif InAnim == Anim.AnimInTimeUp then
		ChallengeResults:PlayAnimation(ChallengeResults.AnimInTimeUp)
	elseif InAnim == Anim.AnimInFail then
		ChallengeResults:PlayAnimation(ChallengeResults.AnimInFail)
	elseif InAnim == Anim.AnimTipsIn then
		if not bNormal then
			self:PlayAnimation(self.AnimTipsIn, 0, 1, _G.UE.EUMGSequencePlayMode.Reverse)
		else
			self:PlayAnimation(self.AnimTipsIn)
		end
	elseif InAnim == Anim.AnimaNumber then
		self:PlayAnimation(self.AnimaNumber)	
	elseif InAnim == Anim.Critical then
		self:OnPlayCriticalAnim()
	elseif InAnim == Anim.AnimShock then
		self:PlayAnimation(self.AnimShock)	
	end
end

function GoldSaucerCrystalTowerStrikerMainPanelView:OnPlayAnimNormalOut()
	self:PlayAnimation(self.AnimaNormalOut)
	UIUtil.SetIsVisible(self.CloseBtn, false)
	self.Btn1.Button:SetIsEnabled(true)
	self.Btn2.Button:SetIsEnabled(true)

	local SubViews = self.ResultTableViewAdapter.SubViews
	for _, View in pairs(SubViews) do
		View:CheckPlayAnim()
	end

	-- self:RegisterTimer(function() 
	-- 	local SubViews = self.ResultTableViewAdapter.SubViews
	-- 	for _, View in pairs(SubViews) do
	-- 		View:Reset()
	-- 	end
	-- end, 0.5)

	-- local function PlaySubViewAnim()
		
	-- end
	-- self:RegisterTimer(PlaySubViewAnim, 1.5)
end

function GoldSaucerCrystalTowerStrikerMainPanelView:OnPlayCriticalAnim()
	local MiniGameInst = self:GetGameInst()
	if MiniGameInst == nil then
		return
	end
	local VM = self:GetTheParamsVM()
	if VM == nil then
		return
	end
	local ShowResultAnimTime = 1.7
	UIUtil.SetIsVisible(self.Critical, false)
	self.ShowCriticalTimer = self:RegisterTimer(function()
		if UIUtil.IsVisible(self.PanelResult) then
			UIUtil.SetIsVisible(self.Critical, true)
			self.Critical:PlayAnimation(self.Critical.AnimCriticalIn)
			self.Award:PlayAnimation(self.Award.AnimCriticalIn)
			MiniGameInst:UpdateCriticalRewardGot()
			self:RegisterTimer(function() VM:UpdateRewardGotSingle() end, 1.5)
		end
		self.ShowCriticalTimer = nil
	end, ShowResultAnimTime) 
end

--- @type 准备开始
function GoldSaucerCrystalTowerStrikerMainPanelView:OnReady()
	local ChallengeBegins = self.ChallengeBegins
	UIUtil.SetIsVisible(ChallengeBegins, true)
	UIUtil.SetIsVisible(self.PanelResult, false)

	ChallengeBegins:SetPrepare()
	AudioUtil.LoadAndPlayUISound(AudioPath.OnPrepare)
	local MiniGameInst = self:GetGameInst()
	if MiniGameInst == nil then
		return
	end
	MiniGameInst:SetArriveEffectPool(self.ArriveEffectPool)
	MiniGameInst:RegisterInteractionFactory(function()
		return self:GetOrCreateInteractionItem()
	end)
	self:RegisterTimer(function()
		ChallengeBegins:SetBegin()
		AudioUtil.LoadAndPlayUISound(AudioPath.OnBegin)
	end, DelayTime.ReadyToBegin, 0, 1)
end

function GoldSaucerCrystalTowerStrikerMainPanelView:GetOrCreateInteractionItem()
	-- 有缓存了没使用的优先选择
	for _, v in pairs(self.InteractionPool) do
		local Elem = v
		if not Elem:GetbIsShowing() then
			return Elem
		end
	end
	-- 创建一个新的
	local InteractVM = CrystalTowerInteractionVM.New()
	local Params = { Data = InteractVM }
	local NewInteractionItem = _G.UIViewMgr:CreateViewByName(InteractionItemBPName, ObjectGCType.NoCache, self, true, true, Params)
	if NewInteractionItem == nil then
		return
	end
	self.PanelCrystal:AddChildToCanvas(NewInteractionItem)
	local Anchor = _G.UE.FAnchors()
	Anchor.Minimum = _G.UE.FVector2D(0.5, 0.5)
	Anchor.Maximum = _G.UE.FVector2D(0.5, 0.5)
	local Alignment = _G.UE.FVector2D(0.5, 0.5)
	local Size = _G.UE.FVector2D(112.0, 155.0)
	UIUtil.CanvasSlotSetAnchors(NewInteractionItem, Anchor)
	UIUtil.CanvasSlotSetAlignment(NewInteractionItem, Alignment)
	UIUtil.CanvasSlotSetSize(NewInteractionItem, Size)
	NewInteractionItem:SetIsEnabled(true)
	NewInteractionItem:SetVisibility(_G.UE.ESlateVisibility.SelfHitTestInvisible)
	_G.UIViewMgr:ShowSubView(NewInteractionItem, Params)
	table.insert(self.InteractionPool, NewInteractionItem)
	return NewInteractionItem
end

function GoldSaucerCrystalTowerStrikerMainPanelView:ResetInteractionItems()
	local InteractionPool = self.InteractionPool
	for _, v in pairs(InteractionPool) do
		local Elem = v
		Elem:UnRegisterAllTimer()
		_G.UIViewMgr:HideSubView(Elem)
		self.PanelCrystal:RemoveChild(Elem)
		_G.UIViewMgr:RecycleView(Elem)
	end
	table.clear(self.InteractionPool)
end

--- @type 当开始时
function GoldSaucerCrystalTowerStrikerMainPanelView.OnBegin(self)
	-----Test-----5360362
	-- local StagePoleData = _G.PWorldDynDataMgr:GetDynData(EffectType,  5360362)
	-- local Data = _G.MapEditDataMgr:GetMapEditCfg()
	-----Test-----
	UIUtil.SetIsVisible(self.ChallengeBegins, false)

	local MiniGameInst = self:GetGameInst()
	if MiniGameInst == nil then
		return
	end
	MiniGameInst:StartGameTimeLoop(MiniGameInst.GameRun)
    MiniGameInst:SetTextHint(LSTR(260010), false) -- 请在晶体下落至线时点击
	self:PlayAnimation(self.AnimTipsIn, 0, 1, _G.UE.EUMGSequencePlayMode.Reverse)
	MiniGameInst:SetIsBegin(true)
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end
	local RoundIntervalTime = MiniGameInst:GetRoundIntervalTime()
	if RoundIntervalTime == nil then
		FLOG_ERROR("CrystalTowerStriker RoundIntervalTime Cfg is nil")
		return
	end
	local CurRoundIndex = MiniGameInst:GetCurRoundIndex()
	local LogIntervalTime = RoundIntervalTime[CurRoundIndex]
	if not LogIntervalTime then
		FLOG_ERROR("GoldSaucerCrystalTowerStrikerMainPanelView LogIntervalTimeError CurRoundIndex:%s RoundIntervalTime:%s", CurRoundIndex, RoundIntervalTime)
	end
	local IntervalTime = LogIntervalTime or 0
	self:RegisterTimer(function() MiniGameInst:OnBeginFalling()  end, IntervalTime / 2)
end

--- @type 设置刚开始需要隐藏的部分
function GoldSaucerCrystalTowerStrikerMainPanelView:SetViewToDefault()
	-- UIUtil.SetIsVisible(self.HelpTips, false)
	self.IsHide = false
	self.Btn2.Button:SetIsEnabled(true)
	UIUtil.SetIsVisible(self.ChallengeBegins, false)
	UIUtil.SetIsVisible(self.TextMagnification, false)
	UIUtil.SetIsVisible(self.CloseBtn, true)

	UIUtil.SetIsVisible(self.PanelResult, false)
	UIUtil.SetIsVisible(self.Critical, false)
	-- UIUtil.SetIsVisible(self.ProBarScore, false)
	UIUtil.SetRenderOpacity(self.PanelNormal, 1)	
	-- UIUtil.SetRenderOpacity(self.StageTips, 1)	

	self.MainTeamPanel:SwitchTab(4)
	self.MainTeamPanel:SetShowGameInfo()
	self.MainTeamPanel.TextGameName:SetText(LSTR(260001))  -- 强袭水晶塔
	self.MainTeamPanel.TextGameName_1:SetText(LSTR(250009)) -- 当前奖励
	local IconGamePath = MiniGameClientConfig[MiniGameType.CrystalTower].IconGamePath
	UIUtil.ImageSetBrushFromAssetPath(self.MainTeamPanel.IconGame, IconGamePath)	
	UIUtil.SetIsVisible(self.MainTeamPanel.PanelCountdown, true)
	UIUtil.SetIsVisible(self.MainTeamPanel.HorizontalGold, true)
	UIUtil.SetIsVisible(self.MainTeamPanel.HorizontalObtain, true)

	--self.BottomPanel:SetButtonEmotionVisible(false)
	--self.BottomPanel:SetButtonPhotoVisible(false)

	self:StopAnimation(self.AnimTitleLoop)
	self:HideShootingTips()
	self.Award:StopAllAnimations()

	if self.ShowCriticalTimer ~= nil then
		self:UnRegisterTimer(self.ShowCriticalTimer)
		self.ShowCriticalTimer = nil
	end

	UIUtil.SetColorAndOpacityHex(self.Award.TextQuantity, "FFF9E1FF")
	AudioUtil.LoadAndPlayUISound(AudioPath.AnimInAudio)
end

--- @type 设置出现游戏名字和时间还是金碟币数量
function GoldSaucerCrystalTowerStrikerMainPanelView:ChangeShowType(bEnterEndState)
	local bMoneyVisible = bEnterEndState
	local bShowGameDesc = not bEnterEndState
	UIUtil.SetIsVisible(self.MoneySlot, bMoneyVisible)
	-- UIUtil.SetIsVisible(self.PanelCountdown, bShowGameDesc)
	-- UIUtil.SetIsVisible(self.HorizontalTitle, bShowGameDesc)
	UIUtil.SetIsVisible(self.MainTeamPanel.PanelCountdown, not bEnterEndState)
	UIUtil.SetIsVisible(self.MainTeamPanel.HorizontalGold, not bEnterEndState)
	UIUtil.SetIsVisible(self.MainTeamPanel.HorizontalObtain, not bEnterEndState)
	if bEnterEndState then
		self:OnMoneyUpdate()
	end
end

function GoldSaucerCrystalTowerStrikerMainPanelView:OnMoneyUpdate()
	local JDResID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE
	self.MoneySlot:UpdateView(JDResID, true, -1, true)
end

function GoldSaucerCrystalTowerStrikerMainPanelView:OnAnimationFinished(Animation)
	if self.IsHide then
		return
	end
	if Animation == self.AnimIn then
		-- self:PlayAnimation(self.AnimTextBreathe)
		self:PlayAnimation(self.AnimTitleLoop, 0, 0)
		self:OnReady()
		-- 临时代码等动效好了	
		self:RegisterTimer(self.OnBegin, DelayTime.PerpareToBegin, 0, 1, self)
	elseif Animation == self.AnimaNormalOut then
		UIUtil.SetIsVisible(self.PanelResult, true)
		self:PlayAnimation(self.AnimSettlement)
	end
end

function GoldSaucerCrystalTowerStrikerMainPanelView:GetTheParamsVM()
    local Params = self.Params
    if Params == nil then
        return
    end

    local ViewModel = Params.Data
    if ViewModel == nil then
        return
    end
    return ViewModel
end

function GoldSaucerCrystalTowerStrikerMainPanelView:GetGameInst()
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end

	local GameInst = ViewModel.MiniGame
	if GameInst == nil then
		return
	end
	return GameInst
end

function GoldSaucerCrystalTowerStrikerMainPanelView:BindBtnCloseCallBack()
	local function EnsureFailQuit()
		local GameInst = self:GetGameInst()
		if GameInst == nil then
			return
		end
		GameInst:ResetProvider()
		self:ResetInteractionItems()
		GameInst:SetIsForceEnd(true)
		GameInst:UnRegisterTimer()
		local AvatarComp = MajorUtil.GetMajorAvatarComponent()
		if AvatarComp then
			AvatarComp:TakeOffAvatarPart(UE.EAvatarPartType.WEAPON_SYSTEM, false) -- 清除小游戏武器Slot
		end
		GoldSaucerMiniGameMgr:SendMsgCrystalTowerExistReq(false)
		GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.CrystalTower, false)
		self:StopAllAnimations()
	end

	local function RecoverGameLoop()
		local GameInst = self:GetGameInst()
		if GameInst == nil then
			return
		end
		--GameInst:RecoverGameTimeLoop()
	end	
	local function OnBtnCloseClick(View)
		local GameInst = self:GetGameInst()
		if GameInst == nil then
			return
		end
		local GameState = GameInst:GetGameState()			
		if GameState == MiniGameStageType.Reward or GameState == MiniGameStageType.End then
			GameInst:Reset()
			GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.CrystalTower, false)
			-- UIViewMgr:HideView(UIViewID.)
		else
			--GameInst:StopGameTimeLoop(true)
			GoldSaucerMiniGameMgr:ShowEnsureExitTip(MiniGameType.CrystalTower, EnsureFailQuit, RecoverGameLoop)

		end
	end

	self.CloseBtn:SetCallback(self, OnBtnCloseClick)
end

return GoldSaucerCrystalTowerStrikerMainPanelView