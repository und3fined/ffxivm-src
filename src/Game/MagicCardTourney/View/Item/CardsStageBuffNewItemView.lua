---
--- Author: Administrator
--- DateTime: 2023-11-24 19:54
--- Description:选择阶段效果Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")

---@class CardsStageBuffNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRefresh UFButton
---@field BtnSelect UFButton
---@field EFFSelectGoup UCanvasPanel
---@field ImgIconBG UFImage
---@field ImgNumberBG UFImage
---@field ImgVSBG UFImage
---@field NumberEffect UFCanvasPanel
---@field PanelTimes UFCanvasPanel
---@field RichTextContent URichTextBox
---@field TextContent UFTextBlock
---@field TextTips UFTextBlock
---@field AnimAloneOut UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimRefresh UWidgetAnimation
---@field AnimSelect UWidgetAnimation
---@field AnimSelectOut UWidgetAnimation
---@field AnimUnSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsStageBuffNewItemView = LuaClass(UIView, true)

function CardsStageBuffNewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRefresh = nil
	--self.BtnSelect = nil
	--self.EFFSelectGoup = nil
	--self.ImgIconBG = nil
	--self.ImgNumberBG = nil
	--self.ImgVSBG = nil
	--self.NumberEffect = nil
	--self.PanelTimes = nil
	--self.RichTextContent = nil
	--self.TextContent = nil
	--self.TextTips = nil
	--self.AnimAloneOut = nil
	--self.AnimLoop = nil
	--self.AnimRefresh = nil
	--self.AnimSelect = nil
	--self.AnimSelectOut = nil
	--self.AnimUnSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsStageBuffNewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsStageBuffNewItemView:OnInit()
	self.Binders = {
		{ "EffectTitle", UIBinderSetText.New(self, self.TextContent) },
		{ "Reroll", UIBinderSetText.New(self, self.TextTips)},
		{ "RerollEnabled", UIBinderSetIsEnabled.New(self, self.TextTips, false, true) },
		{ "RerollEnabled", UIBinderSetIsEnabled.New(self, self.ImgNumberBG, false, true) },
		{ "RerollEnabled", UIBinderSetIsVisible.New(self, self.NumberEffect) },
		{ "RerollEnabled", UIBinderSetIsVisible.New(self, self.PanelTimes) },
		{ "EffectInstruction", UIBinderSetText.New(self, self.RichTextContent)},
		{ "EffectIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgVSBG)},
		{ "RiskLevelBGPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIconBG)},
	}
end

function CardsStageBuffNewItemView:OnDestroy()

end

function CardsStageBuffNewItemView:OnShow()
	UIUtil.CanvasSlotSetZOrder(self.ImgVSBG, 1)
	UIUtil.SetIsVisible(self.NumberEffect, self.RerollEnabled)
end

function CardsStageBuffNewItemView:OnHide()

end

function CardsStageBuffNewItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRefresh, self.OnBtnRefreshClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnBtnSelectClicked)
end

function CardsStageBuffNewItemView:OnRegisterGameEvent()

end

function CardsStageBuffNewItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	self.RerollEnabled = self.ViewModel.RerollEnabled
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CardsStageBuffNewItemView:OnSelectChanged(IsSelect)
	if IsSelect == true then
		self:PlayAnimation(self.AnimSelect)
	else
		self:PlayAnimation(self.AnimUnSelect)
	end
end

function CardsStageBuffNewItemView:PlaySelectedAnimation()
	self:PlayAnimation(self.AnimSelect)
end

---@type 未被选中渐隐动画
function CardsStageBuffNewItemView:PlayUnSelectFadeOutAnimation()
	self:PlayAnimation(self.AnimAloneOut)
end

---@type 未被选中渐隐动画时长
function CardsStageBuffNewItemView:GetOutAnimEndTime()
	if self.AnimAloneOut then
		return self.AnimAloneOut:GetEndTime()
	end
	return 0
end

---@type 被选中展示完成后的隐藏动画
function CardsStageBuffNewItemView:PlaySelectFadeOutAnimation()
	AudioUtil.LoadAndPlayUISound(TourneyDefine.SoundPath.EffectSelected)
	self:PlayAnimation(self.AnimSelectOut)
	return self.AnimSelectOut:GetEndTime()
end

---@type 刷新效果
function CardsStageBuffNewItemView:OnBtnRefreshClicked()
	local Index = self.ViewModel and self.ViewModel.EffectIndex
	local RerollEnabled = self.ViewModel and self.ViewModel.RerollEnabled
	if not RerollEnabled then
		UIUtil.SetIsVisible(self.NumberEffect, false)
		return
	end
	AudioUtil.LoadAndPlayUISound(TourneyDefine.SoundPath.EffectRefresh)
	self:PlayAnimation(self.AnimRefresh)
	MagicCardTourneyMgr:SendMsgRefreshEffect(Index)
end

---@type 被选中
function CardsStageBuffNewItemView:OnBtnSelectClicked()
	local EffectIndex = self.ViewModel.EffectIndex
	--self.OnSelectCallback(self.View, EffectIndex, self)
	_G.EventMgr:SendEvent(_G.EventID.MagicCardTourneySelectEffect, EffectIndex, self)
end


return CardsStageBuffNewItemView