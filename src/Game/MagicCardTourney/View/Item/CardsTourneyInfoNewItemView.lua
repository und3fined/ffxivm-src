---
--- Author: Administrator
--- DateTime: 2023-11-24 19:54
--- Description:详情界面的阶段效果Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MagicCardTourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class CardsTourneyInfoNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImage_Check UFImage
---@field ImgVS UFImage
---@field ImgVSBG UFImage
---@field PanelEmpty UFCanvasPanel
---@field PanelInfo UFCanvasPanel
---@field PanelMask UFCanvasPanel
---@field RichTextCount URichTextBox
---@field RichTextMiddle URichTextBox
---@field TextNoOpen UFTextBlock
---@field TextNumber UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimSelect UWidgetAnimation
---@field AnimUnSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyInfoNewItemView = LuaClass(UIView, true)

function CardsTourneyInfoNewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImage_Check = nil
	--self.ImgVS = nil
	--self.ImgVSBG = nil
	--self.PanelEmpty = nil
	--self.PanelInfo = nil
	--self.PanelMask = nil
	--self.RichTextCount = nil
	--self.RichTextMiddle = nil
	--self.TextNoOpen = nil
	--self.TextNumber = nil
	--self.TextTitle = nil
	--self.AnimSelect = nil
	--self.AnimUnSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyInfoNewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyInfoNewItemView:OnInit()
	self.Binders = {
		{ "EffectTitle", UIBinderSetText.New(self, self.TextTitle) },
		{ "ResultText", UIBinderSetText.New(self, self.RichTextCount)},
		{ "EffectInstruction", UIBinderSetText.New(self, self.RichTextMiddle)},
		{ "IsEffectStart", UIBinderSetIsVisible.New(self, self.PanelInfo)},
		{ "IsEffectStart", UIBinderSetIsVisible.New(self, self.ImgVS)},
		{ "IsEffectStart", UIBinderSetIsVisible.New(self, self.PanelEmpty, true)},
		{ "IsLastStage", UIBinderSetIsVisible.New(self, self.PanelMask)},
		{ "IsLastStage", UIBinderSetIsVisible.New(self, self.TextNumber, true)},
		{ "ProgressText", UIBinderSetText.New(self, self.TextNumber)},
		{ "EffectIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgVS)},
		--{ "RiskLevelBGPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgVSBG)},
		{ "IsEffectStart", UIBinderValueChangedCallback.New(self, nil, self.OnIsEffectStartChange) },
	}
end

function CardsTourneyInfoNewItemView:OnDestroy()

end

function CardsTourneyInfoNewItemView:OnShow()
	self.TextNoOpen:SetText(_G.LSTR(1150070))--("未开启")
end

function CardsTourneyInfoNewItemView:OnHide()

end

function CardsTourneyInfoNewItemView:OnRegisterUIEvent()

end

function CardsTourneyInfoNewItemView:OnRegisterGameEvent()

end

function CardsTourneyInfoNewItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CardsTourneyInfoNewItemView:OnIsEffectStartChange(IsEffectStart)
	local RiskLevelBGPath = MagicCardTourneyDefine.RiskLevelBGPath[0]
	if IsEffectStart then
		RiskLevelBGPath = MagicCardTourneyDefine.RiskLevelBGPath[1]
		if self.ViewModel and not self.ViewModel.IsLastStage then
			self:PlayAnimation(self.AnimSelect)
		end
	end
	UIUtil.ImageSetBrushFromAssetPath(self.ImgVSBG, RiskLevelBGPath)
end

return CardsTourneyInfoNewItemView