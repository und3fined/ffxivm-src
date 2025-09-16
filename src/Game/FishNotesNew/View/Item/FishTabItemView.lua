---
--- Author: v_vvxinchen
--- DateTime: 2025-01-07 20:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class FishTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishTabItemView = LuaClass(UIView, true)

function FishTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishTabItemView:OnInit()
	self.Binders = {
		{ "ClockTabIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.ImgSelect)},
	}
end

function FishTabItemView:OnDestroy()

end

function FishTabItemView:OnShow()

end

function FishTabItemView:OnHide()

end

function FishTabItemView:OnRegisterUIEvent()
end

function FishTabItemView:OnRegisterGameEvent()

end

function FishTabItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)

end

return FishTabItemView