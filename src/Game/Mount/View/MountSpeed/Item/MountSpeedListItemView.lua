---
--- Author: janezli
--- DateTime: 2024-10-11 14:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class MountSpeedListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgFocus UFImage
---@field SwitcherIcon1 UFWidgetSwitcher
---@field SwitcherIcon2 UFWidgetSwitcher
---@field TextCity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountSpeedListItemView = LuaClass(UIView, true)

function MountSpeedListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgFocus = nil
	--self.SwitcherIcon1 = nil
	--self.SwitcherIcon2 = nil
	--self.TextCity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountSpeedListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountSpeedListItemView:OnInit()
	self.Binders = {
		{ "MapName", UIBinderSetText.New(self, self.TextCity)},
		{ "SpeedLevelOne", UIBinderSetActiveWidgetIndex.New(self, self.SwitcherIcon1) },
		{ "SpeedLevelTwo", UIBinderSetActiveWidgetIndex.New(self, self.SwitcherIcon2) },
		{ "ImgFocusVisible", UIBinderSetIsVisible.New(self, self.ImgFocus) },
	}
end

function MountSpeedListItemView:OnDestroy()

end

function MountSpeedListItemView:OnShow()

end

function MountSpeedListItemView:OnHide()

end

function MountSpeedListItemView:OnRegisterUIEvent()

end

function MountSpeedListItemView:OnRegisterGameEvent()

end

function MountSpeedListItemView:OnRegisterBinder()
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

return MountSpeedListItemView