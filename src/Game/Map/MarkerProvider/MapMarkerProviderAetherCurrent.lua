--
-- Author: alex
-- Date: 2023-09-11 17:05
-- Description:风脉泉标记
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerAetherCurrent = require("Game/Map/Marker/MapMarkerAetherCurrent")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local AetherCurrentsMgr = require("Game/AetherCurrent/AetherCurrentsMgr")
local MapMarkerType = MapDefine.MapMarkerType

---@class MapMarkerProviderAetherCurrent
local MapMarkerProviderAetherCurrent = LuaClass(MapMarkerProvider)

---Ctor
function MapMarkerProviderAetherCurrent:Ctor()

end

function MapMarkerProviderAetherCurrent:GetMarkerType()
	return MapMarkerType.AetherCurrent
end

function MapMarkerProviderAetherCurrent:OnGetMarkers(UIMapID)
	local MapInfos = AetherCurrentsMgr:CreateMarkersDataSource(UIMapID)
	if nil == MapInfos then
		return
	end

	local MapMarkers = {}

	for _, v in pairs(MapInfos) do
		local Marker = self:OnCreateMarker(v)
		table.insert(MapMarkers, Marker)
	end

	return MapMarkers
end

function MapMarkerProviderAetherCurrent:OnCreateMarker(Params)
    local ID = Params.MarkID
    local Point = Params.PointLocation
	local Marker = self:CreateMarker(MapMarkerAetherCurrent, ID, Params)

	local X, Y = MapUtil.GetUIPosByLocation(Point, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)

	return Marker
end

---@param Params MapMarkerAetherCurrent @默认是通过ID查找, 如果是其他条件查找，子类要重写FindMarker函数
function MapMarkerProviderAetherCurrent:FindMarker(PointID)
	return table.find_item(self.MapMarkers, PointID, "PointContent")
end

return MapMarkerProviderAetherCurrent