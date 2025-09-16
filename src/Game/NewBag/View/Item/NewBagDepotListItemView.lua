---
--- Author: Administrator
--- DateTime: 2023-09-04 20:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")

---@class NewBagDepotListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot CommonRedDotView
---@field ImageIcon UFImage
---@field ListItem UToggleButton
---@field TextName URichTextBox
---@field TextName_1 URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagDepotListItemView = LuaClass(UIView, true)

function NewBagDepotListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot = nil
	--self.ImageIcon = nil
	--self.ListItem = nil
	--self.TextName = nil
	--self.TextName_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagDepotListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagDepotListItemView:OnInit()
	self.Binders = {
		{ "PageName", UIBinderSetText.New(self, self.TextName) },
		{ "PageName", UIBinderSetText.New(self, self.TextName_1) },
		{ "PageIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImageIcon) },
		{ "IconColor", UIBinderSetColorAndOpacityHex.New(self, self.ImageIcon) },
		{ "PageChecked", UIBinderSetCheckedState.New(self, self.ListItem)},
	}
end

function NewBagDepotListItemView:OnDestroy()

end

function NewBagDepotListItemView:OnShow()

end

function NewBagDepotListItemView:OnHide()

end

function NewBagDepotListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ListItem, self.OnClickedItem)
end

function NewBagDepotListItemView:OnRegisterGameEvent()

end

function NewBagDepotListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self:RegisterBinders(ViewModel, self.Binders)
end

function NewBagDepotListItemView:OnClickedItem()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	Adapter:OnItemClicked(self, Params.Index)
end

return NewBagDepotListItemView