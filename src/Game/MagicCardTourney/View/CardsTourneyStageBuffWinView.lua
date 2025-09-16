---
--- Author: Administrator
--- DateTime: 2023-11-24 19:53
--- Description:阶段效果选择界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIAdapterPanelWidget = require("UI/Adapter/UIAdapterPanelWidget")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local TourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")

local UE = _G.UE
local EventID = _G.EventID
local FMath = _G.UE.UMathUtil

---@class CardsTourneyStageBuffWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CardsItem1 CardsStageBuffNewItemView
---@field CardsItem2 CardsStageBuffNewItemView
---@field CardsItem3 CardsStageBuffNewItemView
---@field FButton_0 UFButton
---@field FCanvasCardPanel UFCanvasPanel
---@field ImgTrophy UFImage
---@field InfoTips InfoTextTipsView
---@field MaskBG CommonPopUpBGView
---@field PanelTips UFCanvasPanel
---@field TextChoose UFTextBlock
---@field TextDiscribe UFTextBlock
---@field TextNode UFTextBlock
---@field AnimOut UWidgetAnimation
---@field AnimShowChoice UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyStageBuffWinView = LuaClass(UIView, true)

function CardsTourneyStageBuffWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CardsItem1 = nil
	--self.CardsItem2 = nil
	--self.CardsItem3 = nil
	--self.FButton_0 = nil
	--self.FCanvasCardPanel = nil
	--self.ImgTrophy = nil
	--self.InfoTips = nil
	--self.MaskBG = nil
	--self.PanelTips = nil
	--self.TextChoose = nil
	--self.TextDiscribe = nil
	--self.TextNode = nil
	--self.AnimOut = nil
	--self.AnimShowChoice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyStageBuffWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CardsItem1)
	self:AddSubView(self.CardsItem2)
	self:AddSubView(self.CardsItem3)
	self:AddSubView(self.InfoTips)
	self:AddSubView(self.MaskBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyStageBuffWinView:OnInit()
	self.PanelEffectsAdapter = UIAdapterPanelWidget.CreateAdapter(self, self.FCanvasCardPanel)
	--self.LocationFishListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBuff, self.OnEffectSelectChanged, true)
	self.Binders = {
		--{"EffectChoiceVMList", UIBinderUpdateBindableList.New(self, self.LocationFishListAdapter)},
		{"EffectChoiceVMList", UIBinderUpdateBindableList.New(self, self.PanelEffectsAdapter)},
	}
end

function CardsTourneyStageBuffWinView:OnDestroy()

end



function CardsTourneyStageBuffWinView:OnShow()
	self.TextChoose:SetText(_G.LSTR(1150069))--("请选择一个阶段效果")
	self.IsSelectedEfffect = false
	self.MaxMoveTime = 0.4
	self.MoveTimeCount = 0
	--self.LocationFishListAdapter:ClearSelectedItem()
	self:UpdateStageDesc()
	UIUtil.SetIsVisible(self.TextChoose, false)
	UIUtil.SetIsVisible(self.FCanvasCardPanel, false)
	local function ShowCards()
		UIUtil.SetIsVisible(self.TextChoose, true)
		UIUtil.SetIsVisible(self.FCanvasCardPanel, true)
		self:PlayAnimation(self.AnimShowChoice)
		AudioUtil.LoadAndPlayUISound(TourneyDefine.SoundPath.EffectsOppenView)
	end
	self:RegisterTimer(ShowCards, 3)
end

function CardsTourneyStageBuffWinView:OnHide()
	_G.EventMgr:SendEvent(_G.EventID.MagicCardTourneyEffectSelected)
end

function CardsTourneyStageBuffWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButton_0, self.OnDetailBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.InfoTips.BtnIcon, self.OnDetailBtnClicked)
end

function CardsTourneyStageBuffWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MagicCardTourneySelectEffect, self.OnEffectSelectChanged)
end

function CardsTourneyStageBuffWinView:OnRegisterBinder()
	if TourneyVM == nil then
		return
	end
	self:RegisterBinders(TourneyVM, self.Binders)
end

---@type 更新阶段和效果信息
function CardsTourneyStageBuffWinView:UpdateStageDesc()
	if TourneyVM == nil then
		return
	end

	if TourneyVM.TourneyInfo == nil then
		return
	end

	local CurStageIndex = TourneyVM.CurStageIndex
	local NewStageIndex = CurStageIndex
	local ChoiceList = TourneyVM.TourneyInfo.EffectChoiceList
	local SelectedEffectList = TourneyVM.TourneyInfo.SelectedEffectList
	
	if ChoiceList and #ChoiceList > 0 and #SelectedEffectList > 0 then
		NewStageIndex =  CurStageIndex + 1 -- 选择阶段效果时进入新阶段
	end
	
    local NewStageName = TourneyVMUtils.GetStageNameByIndex(NewStageIndex)
	--self.TextNode:SetText(NewStageName)
	local AwardInfo = TourneyVMUtils.GetMagicCardTourneyScoreAward(NewStageIndex)
	if AwardInfo == nil then
		return
	end
	local DescText = string.format(TourneyDefine.StageDescText,AwardInfo.Win, AwardInfo.Lose)
	--self.TextDiscribe:SetText(DescText)

	local Params = {}
	Params.Type = 3
	Params.ImagePanel = self.InfoTips.TipsImageItem
	Params.Content = NewStageName
	Params.HintText = DescText
	Params.ShowBtn = true
	self.InfoTips.Params = Params
	self.InfoTips:OnShow()
end

---@type 展示选中效果动画
function CardsTourneyStageBuffWinView:OnShowSelectItem()
	self.MoveTimeCount = self.MoveTimeCount + 0.05

	if self.SelectItemView ~= self.TargetEntry then
		local Rate = math.clamp(self.MoveTimeCount / self.MaxMoveTime, 0, 1)
		local NewPositionX = FMath.Lerp(0, self.TipsAbsolute.X, Rate)
		self.SelectItemView:SetRenderTranslation(UE.FVector2D(NewPositionX, 0))
	end

	if self.MoveTimeCount >= self.MaxMoveTime then
		self.MoveTimeCount = 0
		self.TargetEntry = nil
		if self.MoveTimer then
			self:UnRegisterTimer(self.MoveTimer)
			self.MoveTimer = nil
		end

		if self.HideSelectTimer then
			self:UnRegisterTimer(self.HideSelectTimer)
			self.HideSelectTimer = nil
		end
		self.HideSelectTimer = self:RegisterTimer(self.OnHideSelectItem, 1)
	end
end

---@type 隐藏选中效果动画
function CardsTourneyStageBuffWinView:OnHideSelectItem()
	if self.SelectItemView == nil then
		return
	end

	local SelectOutDuration = self.SelectItemView:PlaySelectFadeOutAnimation()
	self:RegisterTimer(self.Hide, SelectOutDuration)
end

function CardsTourneyStageBuffWinView:OnDetailBtnClicked()
	MagicCardTourneyMgr:ShowTourneyDetailView()
end

function CardsTourneyStageBuffWinView:OnEffectSelectChanged(EffectIndex, ItemView)
	if self.IsSelectedEfffect then
		return
	end

	if EffectIndex == nil then
		return
	end
	
	self.IsSelectedEfffect = true
	MagicCardTourneyMgr:OnEffectSelected(EffectIndex)
	self.SelectItemView = ItemView
	self.SelectItemView:PlaySelectedAnimation()

	--local Entries = self.FCanvasCardPanel:GetChildrenCount()
	local Length = self.FCanvasCardPanel:GetChildrenCount()
	-- 将未选中的淡出
	for i=1, Length do
	    local Entry = self.FCanvasCardPanel:GetChildAt(i - 1)
	    if nil ~= Entry and ItemView ~= Entry then
			Entry:PlayUnSelectFadeOutAnimation()
	    end
	end

	self.UnSelectFadeOutTime = 0
	if Length > 0 then
		self.TargetEntry = self.FCanvasCardPanel:GetChildAt(1)
		if self.TargetEntry then
			self.UnSelectFadeOutTime = self.TargetEntry:GetOutAnimEndTime()
			local TragetAbsolute = UIUtil.GetWidgetAbsolutePosition(self.TargetEntry)
			self.TipsAbsolute = UIUtil.AbsoluteToLocal(self.SelectItemView, TragetAbsolute)
		end
		
	end

	if self.MoveTimer then
		self:UnRegisterTimer(self.MoveTimer)
		self.MoveTimer = nil
	end

	--结束开场动效
	local AnimTime = self.AnimShowChoice:GetEndTime()
	self:PlayAnimationTimeRange(self.AnimShowChoice, AnimTime - 0.01, AnimTime, 1, _G.UE.EUMGSequencePlayMode.Forward)
	self.MoveTimer = self:RegisterTimer(self.OnShowSelectItem, self.UnSelectFadeOutTime, 0.03, -1)
end

return CardsTourneyStageBuffWinView