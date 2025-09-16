---
--- Author: Administrator
--- DateTime: 2023-11-30 14:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class BuddySurfaceTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field PanelTabItem UFCanvasPanel
---@field AnimCheck UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddySurfaceTabItemView = LuaClass(UIView, true)

function BuddySurfaceTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.PanelTabItem = nil
	--self.AnimCheck = nil
	--self.AnimUncheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddySurfaceTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddySurfaceTabItemView:OnInit()
	self.Binders = {
		{ "ImgIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgNormal) },
		{ "SelectedIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgSelect) },
		{ "SelectedVisible", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "SelectedAni", UIBinderValueChangedCallback.New(self, nil, self.PanelCheckChanged) },
	}
end

function BuddySurfaceTabItemView:OnDestroy()

end

function BuddySurfaceTabItemView:OnShow()

end

function BuddySurfaceTabItemView:OnHide()

end

function BuddySurfaceTabItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnClickButtonItem)
end

function BuddySurfaceTabItemView:OnRegisterGameEvent()

end

function BuddySurfaceTabItemView:OnRegisterBinder()
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

function BuddySurfaceTabItemView:OnClickButtonItem()
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

function BuddySurfaceTabItemView:PanelCheckChanged()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	local IsShow = ViewModel.SelectedVisible
		if IsShow then
			self:PlayAnimation(self.AnimCheck)
		else
			self:PlayAnimation(self.AnimUncheck)
		end
end

return BuddySurfaceTabItemView