---
--- Author: anypkvcai
--- DateTime: 2022-12-26 23:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")

---@class WorldMapMarkerIconItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgNormalBkg UFImage
---@field ImgSelected UFImage
---@field ImgUsedBkg UFImage
---@field AnimSelect UWidgetAnimation
---@field AnimUnSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapMarkerIconItemView = LuaClass(UIView, true)

function WorldMapMarkerIconItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgNormalBkg = nil
	--self.ImgSelected = nil
	--self.ImgUsedBkg = nil
	--self.AnimSelect = nil
	--self.AnimUnSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerIconItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerIconItemView:OnInit()
	UIUtil.SetIsVisible(self.ImgNormalBkg, true)
	UIUtil.SetIsVisible(self.ImgUsedBkg, false)
end

function WorldMapMarkerIconItemView:OnDestroy()

end

function WorldMapMarkerIconItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local PlacedMarkerCfg = Params.Data
	if nil == PlacedMarkerCfg then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, PlacedMarkerCfg.IconPath)


end

function WorldMapMarkerIconItemView:OnHide()

end

function WorldMapMarkerIconItemView:OnRegisterUIEvent()

end

function WorldMapMarkerIconItemView:OnRegisterGameEvent()

end

function WorldMapMarkerIconItemView:OnRegisterBinder()

end

function WorldMapMarkerIconItemView:OnSelectChanged(IsSelected, IsByClick)
	UIUtil.SetIsVisible(self.ImgSelected, IsSelected)

	if IsSelected then
		local Cfg = self.Params.Data
		WorldMapVM:SetPlacedMarkerIconPath(Cfg.IconPath)
	end

	--if IsSelected then
	--	self:PlayAnimation(self.AnimSelect)
	--else
	--	self:PlayAnimation(self.AnimUnSelect)
	--end
end

return WorldMapMarkerIconItemView