---
--- Author: Administrator
--- DateTime: 2024-06-11 18:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MapUtil = require("Game/Map/MapUtil")

---@class MapMarkerMineView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgIcon UFImage
---@field TextTimer UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerMineView = LuaClass(UIView, true)

function MapMarkerMineView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgIcon = nil
	--self.TextTimer = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerMineView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerMineView:OnInit()
	self.Binders = {
		{ "IconVisibility", UIBinderSetIsVisible.New(self, self.ImgIcon) },
		{ "TreasureMineTime", UIBinderSetText.New(self, self.TextTimer) },
	}
end

function MapMarkerMineView:OnDestroy()

end

function MapMarkerMineView:OnShow()

end

function MapMarkerMineView:OnHide()

end

function MapMarkerMineView:OnRegisterUIEvent()

end

function MapMarkerMineView:OnRegisterGameEvent()

end

function MapMarkerMineView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerMineView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then return	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)
end

function MapMarkerMineView:IsUnderLocation(ScreenPosition)
	return  UIUtil.IsUnderLocation(self.BtnRegion, ScreenPosition)
end

return MapMarkerMineView