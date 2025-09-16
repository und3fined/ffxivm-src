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
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class CardsTourneyInfoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgVS UFImage
---@field PanelEmpty UFCanvasPanel
---@field PanelInfo UFCanvasPanel
---@field PanelMask UFCanvasPanel
---@field RichTextCount URichTextBox
---@field RichTextMiddle URichTextBox
---@field TextNumber UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyInfoItemView = LuaClass(UIView, true)

function CardsTourneyInfoItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgVS = nil
	--self.PanelEmpty = nil
	--self.PanelInfo = nil
	--self.PanelMask = nil
	--self.RichTextCount = nil
	--self.RichTextMiddle = nil
	--self.TextNumber = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyInfoItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyInfoItemView:OnInit()
	self.Binders = {
		{ "EffectTitle", UIBinderSetText.New(self, self.TextTitle) },
		{ "ResultText", UIBinderSetText.New(self, self.RichTextCount)},
		{ "EffectInstruction", UIBinderSetText.New(self, self.RichTextMiddle)},
		{ "IsEffectStart", UIBinderSetIsVisible.New(self, self.PanelInfo)},
		{ "IsEffectStart", UIBinderSetIsVisible.New(self, self.PanelEmpty, true)},
		{ "IsLastStage", UIBinderSetIsVisible.New(self, self.PanelMask)},
		{ "IsLastStage", UIBinderSetIsVisible.New(self, self.TextNumber, true)},
		{ "ProgressText", UIBinderSetText.New(self, self.TextNumber)},
		{ "EffectIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgVS)},
	}
end

function CardsTourneyInfoItemView:OnDestroy()

end

function CardsTourneyInfoItemView:OnShow()

end

function CardsTourneyInfoItemView:OnHide()

end

function CardsTourneyInfoItemView:OnRegisterUIEvent()

end

function CardsTourneyInfoItemView:OnRegisterGameEvent()

end

function CardsTourneyInfoItemView:OnRegisterBinder()
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

return CardsTourneyInfoItemView