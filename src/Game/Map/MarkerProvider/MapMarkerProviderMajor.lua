--
-- Author: anypkvcai
-- Date: 2023-03-01 17:05
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapUtil = require("Game/Map/MapUtil")
local MapMarkerMajor = require("Game/Map/Marker/MapMarkerMajor")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerType = MapDefine.MapMarkerType

---@class MapMarkerProviderMajor
local MapMarkerProviderMajor = LuaClass(MapMarkerProvider)

---Ctor
function MapMarkerProviderMajor:Ctor()

end

function MapMarkerProviderMajor:GetMarkerType()
	return MapMarkerType.Major
end

function MapMarkerProviderMajor:OnGetMarkers(UIMapID)
	return self:GetMajorMarkers(UIMapID)
end

function MapMarkerProviderMajor:OnCreateMarker(Params)
	return self:CreateMarker(MapMarkerMajor, 0, Params)
end

function MapMarkerProviderMajor:GetMajorMarkers(UIMapID)
	local Markers = {}
	local CurrentUIMapID = _G.MapMgr:GetUIMapID()

	if CurrentUIMapID == UIMapID then
		-- 主角所在三级地图
		local Marker = self:OnCreateMarker(CurrentUIMapID)
		table.insert(Markers, Marker)
	else
		local RegionUIMapID = MapUtil.GetUpperUIMapID(CurrentUIMapID)
		if RegionUIMapID == UIMapID then
			-- 主角所在二级地图
			if MapUtil.IsSpecialUIMap(CurrentUIMapID) then
				-- 主角如果在沙之家这种特殊地图，二级地图标记不显示
				return
			end
			local Marker = self:OnCreateMarker(CurrentUIMapID)
			local SetPosResult = MapUtil.SetRegionUIPos(Marker, RegionUIMapID, CurrentUIMapID)
			if not SetPosResult then
				return
			end
			table.insert(Markers, Marker)
		else
			-- 一级地图的主角标记
			local WorldUIMapID = MapUtil.GetUpperUIMapID(RegionUIMapID)
			if WorldUIMapID == UIMapID then
				local Marker = self:OnCreateMarker(CurrentUIMapID)
				MapUtil.SetWorldUIPos(Marker, WorldUIMapID, RegionUIMapID)
				table.insert(Markers, Marker)
			end
		end
	end

	return Markers
end

return MapMarkerProviderMajor