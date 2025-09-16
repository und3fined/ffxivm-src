---
--- Author: Administrator
--- DateTime: 2024-02-20 16:40
--- Description:主题部位列表Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetOpacity = require("Binder/UIBinderSetOpacity")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FashionEvaluationTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRanKing UToggleButton
---@field Icon UFImage
---@field ImgFocus UFImage
---@field ImgNormal UFImage
---@field PanelFocus UFCanvasPanel
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationTabItemView = LuaClass(UIView, true)

function FashionEvaluationTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRanKing = nil
	--self.Icon = nil
	--self.ImgFocus = nil
	--self.ImgNormal = nil
	--self.PanelFocus = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationTabItemView:OnInit()
	self.Binders = {
		{"PartThemeName", UIBinderSetText.New(self, self.Text)},
		{"AppearanceIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon)},
		{ "EquipIconOpacity", UIBinderSetOpacity.New(self, self.Icon) },
	}
end

function FashionEvaluationTabItemView:OnDestroy()

end

function FashionEvaluationTabItemView:OnShow()
	
end

function FashionEvaluationTabItemView:OnHide()

end

function FashionEvaluationTabItemView:OnRegisterUIEvent()

end

function FashionEvaluationTabItemView:OnRegisterGameEvent()

end

function FashionEvaluationTabItemView:OnRegisterBinder()
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

function FashionEvaluationTabItemView:OnSelectChanged(IsSelected)
	self.BtnRanKing:SetChecked(IsSelected, false)
end

return FashionEvaluationTabItemView