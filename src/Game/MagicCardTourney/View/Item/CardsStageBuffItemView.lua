---
--- Author: Administrator
--- DateTime: 2023-11-24 19:54
--- Description:选择阶段效果Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class CardsStageBuffItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field EFFSelectGoup UCanvasPanel
---@field ImgSelect UFImage
---@field ImgVSBG UFImage
---@field RichTextContent URichTextBox
---@field TextContent UFTextBlock
---@field TextTips UFTextBlock
---@field AnimAloneOut UWidgetAnimation
---@field AnimSelect UWidgetAnimation
---@field AnimSelectOut UWidgetAnimation
---@field AnimUnSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsStageBuffItemView = LuaClass(UIView, true)

function CardsStageBuffItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.EFFSelectGoup = nil
	--self.ImgSelect = nil
	--self.ImgVSBG = nil
	--self.RichTextContent = nil
	--self.TextContent = nil
	--self.TextTips = nil
	--self.AnimAloneOut = nil
	--self.AnimSelect = nil
	--self.AnimSelectOut = nil
	--self.AnimUnSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsStageBuffItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsStageBuffItemView:OnInit()
	self.Binders = {
		{ "EffectTitle", UIBinderSetText.New(self, self.TextContent) },
		{ "EffectValue", UIBinderSetText.New(self, self.TextTips)},
		{ "EffectInstruction", UIBinderSetText.New(self, self.RichTextContent)},
		{ "EffectIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgVSBG)},

	}
end

function CardsStageBuffItemView:OnDestroy()

end

function CardsStageBuffItemView:OnShow()

end

function CardsStageBuffItemView:OnHide()

end

function CardsStageBuffItemView:OnRegisterUIEvent()

end

function CardsStageBuffItemView:OnRegisterGameEvent()

end

function CardsStageBuffItemView:OnRegisterBinder()
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

function CardsStageBuffItemView:OnSelectChanged(IsSelect)
	if IsSelect == true then
		self:PlayAnimation(self.AnimSelect)
	else
		self:PlayAnimation(self.AnimUnSelect)
	end
end

function CardsStageBuffItemView:PlaySelectedAnimation()
	self:PlayAnimation(self.AnimSelect)
end

---@type 未被选中渐隐动画
function CardsStageBuffItemView:PlayUnSelectFadeOutAnimation()
	self:PlayAnimation(self.AnimAloneOut)
end

---@type 未被选中渐隐动画时长
function CardsStageBuffItemView:GetOutAnimEndTime()
	if self.AnimAloneOut then
		return self.AnimAloneOut:GetEndTime()
	end
	return 0
end

---@type 被选中展示完成后的隐藏动画
function CardsStageBuffItemView:PlaySelectFadeOutAnimation()
	self:PlayAnimation(self.AnimSelectOut)
end

---@type 被选中隐藏动画时长
function CardsStageBuffItemView:GetSelectOutAnimEndTime()
	if self.AnimSelectOut then
		return self.AnimSelectOut:GetEndTime()
	end
	return 0
end

return CardsStageBuffItemView