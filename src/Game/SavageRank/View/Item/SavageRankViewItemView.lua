---
--- Author: Administrator
--- DateTime: 2024-12-25 15:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")




---@class SavageRankViewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgItemNormal UFImage
---@field ImgItemSelect UFImage
---@field PanelOpening UFCanvasPanel
---@field TextNormal UFTextBlock
---@field TextOpening UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SavageRankViewItemView = LuaClass(UIView, true)

function SavageRankViewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgItemNormal = nil
	--self.ImgItemSelect = nil
	--self.PanelOpening = nil
	--self.TextNormal = nil
	--self.TextOpening = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SavageRankViewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SavageRankViewItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextNormal) },
		{ "OpenText", UIBinderSetText.New(self, self.TextOpening) },
		{ "SelectVisible", UIBinderSetIsVisible.New(self, self.ImgItemSelect) },
		{ "PanelOpeningVisible", UIBinderSetIsVisible.New(self, self.PanelOpening) },
		{ "TabIcon", UIBinderSetImageBrush.New(self, self.ImgItemNormal) },
	}
end

function SavageRankViewItemView:OnDestroy()

end

function SavageRankViewItemView:OnShow()
	if self.ViewModel.IsOpen then
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextNormal, "#D5D5D5")
	elseif self.ViewModel.IsEnd then
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextNormal, "#828282")
	end
end

function SavageRankViewItemView:OnHide()

end

function SavageRankViewItemView:OnRegisterUIEvent()

end

function SavageRankViewItemView:OnRegisterGameEvent()

end

function SavageRankViewItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function SavageRankViewItemView:OnSelectChanged(NewValue)
	self.ViewModel:UpdateSelectState(NewValue)
end


return SavageRankViewItemView