---
--- Author: Administrator
--- DateTime: 2023-12-06 15:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local ArmyMgr = nil

---@class ArmyDepotListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot_UIBP CommonRedDotView
---@field ImageIcon UFImage
---@field ListItem UToggleButton
---@field TextName URichTextBox
---@field TextName_1 URichTextBox
---@field AnimUnlock UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyDepotListItemView = LuaClass(UIView, true)

function ArmyDepotListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot_UIBP = nil
	--self.ImageIcon = nil
	--self.ListItem = nil
	--self.TextName = nil
	--self.TextName_1 = nil
	--self.AnimUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyDepotListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyDepotListItemView:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	self.Binders = {
		{ "PageName", UIBinderSetText.New(self, self.TextName) },
		{ "PageName", UIBinderSetText.New(self, self.TextName_1) },
		{ "PageIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImageIcon) },
		{ "IconColor", UIBinderSetColorAndOpacityHex.New(self, self.ImageIcon) },
	}
end

function ArmyDepotListItemView:OnDestroy()

end

function ArmyDepotListItemView:OnShow()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end
	local RedDotName = ArmyMgr:GetStroeRedDotName(ViewModel.PageIndex)
	if RedDotName then
		self.CommonRedDot_UIBP:SetRedDotNameByString(RedDotName)
		ArmyMgr:AddCancelStoreRedDot(ViewModel.PageIndex)
	else
		self.CommonRedDot_UIBP:SetRedDotNameByString("")
	end
	
end

function ArmyDepotListItemView:OnHide()

end

function ArmyDepotListItemView:OnRegisterUIEvent()

end

function ArmyDepotListItemView:OnRegisterGameEvent()

end

function ArmyDepotListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end
	
	self:RegisterBinders(ViewModel, self.Binders)
end

return ArmyDepotListItemView