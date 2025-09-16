---
--- Author: Administrator
--- DateTime: 2023-08-14 16:25
--- Description: 地图手动标记显示项
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")
local ProtoRes = require("Protocol/ProtoRes")

local WorldMapMgr = _G.WorldMapMgr
local MapPlacedMarkerType = ProtoRes.MapPlacedMarkerType


---@class WorldMapMarkItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBG UFImage
---@field ImgCheck UFImage
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapMarkItemView = LuaClass(UIView, true)

function WorldMapMarkItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBG = nil
	--self.ImgCheck = nil
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapMarkItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapMarkItemView:OnInit()
	--UIUtil.SetIsVisible(self.ImgBG, true)
	--UIUtil.SetIsVisible(self.ImgSelect, false)
end

function WorldMapMarkItemView:OnDestroy()

end

function WorldMapMarkItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local PlacedMarkerCfg = Params.Data
	if nil == PlacedMarkerCfg then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, PlacedMarkerCfg.IconPath)

	if PlacedMarkerCfg.Type == MapPlacedMarkerType.MAP_PLACED_MARKER_TRACE then
		local IsUsed = WorldMapMgr:IsTraceMarkerUsed(PlacedMarkerCfg.ID)
		local ShowUsed = IsUsed and (not PlacedMarkerCfg.SendMarkerPanelMode)

		--UIUtil.SetIsVisible(self.ImgBG, not IsUsed)
		--UIUtil.SetIsVisible(self.ImgUsedBkg, IsUsed)
		UIUtil.SetIsVisible(self.ImgCheck, false)
	end
end

function WorldMapMarkItemView:OnHide()

end

function WorldMapMarkItemView:OnRegisterUIEvent()

end

function WorldMapMarkItemView:OnRegisterGameEvent()

end

function WorldMapMarkItemView:OnRegisterBinder()

end

function WorldMapMarkItemView:OnSelectChanged(IsSelected, IsByClick)
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
	local Cfg = self.Params.Data
	if Cfg ~= nil then
		if IsSelected then
			WorldMapVM:SetPlacedMarkerIconPath(Cfg.IconPath)
		end

		if Cfg.SendMarkerPanelMode and IsSelected then
			local Marker = WorldMapMgr:FindPlacedMarker(Cfg.ID)
			if Marker then
				WorldMapMgr:ChangeMap(Marker:GetUIMapID())
			end
		end
	end
end

return WorldMapMarkItemView