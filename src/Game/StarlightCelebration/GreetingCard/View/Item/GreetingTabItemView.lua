---
--- Author: Administrator
--- DateTime: 2025-06-30 17:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

---@class GreetingTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMailStyle UFImage
---@field ImgSelect UFImage
---@field PanelLock UFCanvasPanel
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GreetingTabItemView = LuaClass(UIView, true)

function GreetingTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgMailStyle = nil
	--self.ImgSelect = nil
	--self.PanelLock = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GreetingTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GreetingTabItemView:OnInit()
	self.Binders = {
		{ "UnSelectIconPath", 		UIBinderSetBrushFromAssetPath.New(self, self.ImgMailStyle) },
		{ "Islock", 				UIBinderSetIsVisible.New(self, self.PanelLock) },
		{ "SelectIconPath", 		UIBinderSetBrushFromAssetPath.New(self, self.ImgSelect) },
		{ "IsSelected", 			UIBinderSetIsChecked.New(self, self.ToggleBtn) },
	}
end

function GreetingTabItemView:OnDestroy()

end

function GreetingTabItemView:OnShow()
	UIUtil.SetIsVisible(self.ToggleBtn, true, true)
end

function GreetingTabItemView:OnHide()

end

function GreetingTabItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnClickButtonItem)
end

function GreetingTabItemView:OnRegisterGameEvent()

end

function GreetingTabItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

function GreetingTabItemView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	Adapter:OnItemClicked(self, Params.Index)
end

return GreetingTabItemView