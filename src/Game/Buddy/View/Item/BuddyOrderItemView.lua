---
--- Author: Administrator
--- DateTime: 2023-11-16 15:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class BuddyOrderItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF UFCanvasPanel
---@field ImgIcon UFImage
---@field ImgMask UFImage
---@field ImgUse UFImage
---@field AnimLearned UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddyOrderItemView = LuaClass(UIView, true)

function BuddyOrderItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF = nil
	--self.ImgIcon = nil
	--self.ImgMask = nil
	--self.ImgUse = nil
	--self.AnimLearned = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddyOrderItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddyOrderItemView:OnInit()
	self.Binders = {
		{ "UseImgVisible", UIBinderSetIsVisible.New(self, self.ImgUse) },
		{ "IconImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "MaskImgVisible", UIBinderSetIsVisible.New(self, self.ImgMask) },
		{ "SelectImgVisible", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "EFFVisible", UIBinderSetIsVisible.New(self, self.EFF) },

	}
end

function BuddyOrderItemView:OnDestroy()

end

function BuddyOrderItemView:OnShow()

end

function BuddyOrderItemView:OnHide()

end

function BuddyOrderItemView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.ToggleBtnSkill, self.OnClickButtonItem)
end

function BuddyOrderItemView:OnRegisterGameEvent()

end

function BuddyOrderItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

function BuddyOrderItemView:OnClickButtonItem()
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

return BuddyOrderItemView