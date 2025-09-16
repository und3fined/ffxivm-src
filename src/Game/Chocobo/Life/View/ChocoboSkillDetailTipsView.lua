---
--- Author: Administrator
--- DateTime: 2024-01-02 18:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ChocoboSkillDetailTipsVM = require("Game/Chocobo/Life/VM/ChocoboSkillDetailTipsVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class ChocoboSkillDetailTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelDetail UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field RichTextDiscribe URichTextBox
---@field SkillType1 SkillTypeTagItemView
---@field SkillType2 SkillTypeTagItemView
---@field TextAttr1 URichTextBox
---@field TextAttr2 UFTextBlock
---@field TextSkillName UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboSkillDetailTipsView = LuaClass(UIView, true)

function ChocoboSkillDetailTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelDetail = nil
	--self.PopUpBG = nil
	--self.RichTextDiscribe = nil
	--self.SkillType1 = nil
	--self.SkillType2 = nil
	--self.TextAttr1 = nil
	--self.TextAttr2 = nil
	--self.TextSkillName = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboSkillDetailTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.SkillType1)
	self:AddSubView(self.SkillType2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboSkillDetailTipsView:OnInit()
	self.ViewModel = ChocoboSkillDetailTipsVM.New()
end

function ChocoboSkillDetailTipsView:OnDestroy()

end

function ChocoboSkillDetailTipsView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local SkillID = Params.SkillID
	self.ViewModel:UpdateVM(SkillID)


	self.HideCallback = Params.HideCallback

	local ItemView = Params.SlotView
	if nil ~= ItemView then
		ItemTipsUtil.AdjustTipsPosition(self.PanelDetail, ItemView, Params.Offset)
	end
end

function ChocoboSkillDetailTipsView:OnHide()

end

function ChocoboSkillDetailTipsView:OnRegisterUIEvent()

end

function ChocoboSkillDetailTipsView:OnRegisterGameEvent()

end

function ChocoboSkillDetailTipsView:OnRegisterBinder()
	local Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextSkillName) },
		{ "Desc", UIBinderSetText.New(self, self.RichTextDiscribe) },
		{ "CD", UIBinderSetText.New(self, self.TextAttr1) },
		{ "Cost", UIBinderSetText.New(self, self.TextAttr2) },
		{ "SkillTypeText", UIBinderSetText.New(self, self.SkillType1.TextType) },
		{ "RarityText", UIBinderSetText.New(self, self.SkillType2.TextType) },
		{ "SkillTypePath", UIBinderSetBrushFromAssetPath.New(self, self.SkillType1.ImgType) },
		{ "RarityPath", UIBinderSetBrushFromAssetPath.New(self, self.SkillType2.ImgType) },
		{ "IsShowCost", UIBinderSetIsVisible.New(self, self.TextAttr2) },
		{ "IsShowCD", UIBinderSetIsVisible.New(self, self.TextAttr1) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

return ChocoboSkillDetailTipsView