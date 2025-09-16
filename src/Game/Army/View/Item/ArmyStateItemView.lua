---
--- Author: Administrator
--- DateTime: 2023-11-27 10:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@Class ArmyStateItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgIcon01 UFImage
---@field ImgIcon02 UFImage
---@field PanelLocked UFCanvasPanel
---@field TextDiscribe UFTextBlock
---@field TextName01 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyStateItemView = LuaClass(UIView, true)

function ArmyStateItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgIcon01 = nil
	--self.ImgIcon02 = nil
	--self.PanelLocked = nil
	--self.TextDiscribe = nil
	--self.TextName01 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyStateItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyStateItemView:OnInit()
	self.Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon01)},
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon02)},
		{ "Permission", UIBinderSetText.New(self, self.TextName01)},
		{ "Describe", UIBinderSetText.New(self, self.TextDiscribe)},
		{ "IsUnlock", UIBinderSetIsVisible.New(self, self.PanelLocked, true)},
		{ "IsUnlock", UIBinderSetIsVisible.New(self, self.PanelOpen)},
	}
end

function ArmyStateItemView:OnDestroy()

end

function ArmyStateItemView:OnShow()

end

function ArmyStateItemView:OnHide()

end

function ArmyStateItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickedItem)
end

function ArmyStateItemView:OnClickedItem()
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

function ArmyStateItemView:OnRegisterGameEvent()

end

function ArmyStateItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return ArmyStateItemView