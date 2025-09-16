---
--- Author: Administrator
--- DateTime: 2025-03-18 11:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class WorldExploraPlaceItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextPlace UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraPlaceItemView = LuaClass(UIView, true)

function WorldExploraPlaceItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextPlace = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraPlaceItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldExploraPlaceItemView:OnInit()
	self.Binders = {
		{ "PlaceName", UIBinderSetText.New(self, self.TextPlace) },

	}
end

function WorldExploraPlaceItemView:OnDestroy()

end

function WorldExploraPlaceItemView:OnShow()

end

function WorldExploraPlaceItemView:OnHide()

end

function WorldExploraPlaceItemView:OnRegisterUIEvent()

end

function WorldExploraPlaceItemView:OnRegisterGameEvent()

end

function WorldExploraPlaceItemView:OnRegisterBinder()
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

return WorldExploraPlaceItemView