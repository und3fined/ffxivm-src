--
-- Author: peterxie
-- Date:
-- Description: 房屋土地标记
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerHouseLand = require("Game/Map/Marker/MapMarkerHouseLand")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local HousingMapMarkerInfoCfg = require("TableCfg/HousingMapMarkerInfoCfg")


---@class MapMarkerProviderHouseLand : MapMarkerProvider
local MapMarkerProviderHouseLand = LuaClass(MapMarkerProvider)

function MapMarkerProviderHouseLand:Ctor()

end

function MapMarkerProviderHouseLand:GetMarkerType()
	return MapDefine.MapMarkerType.HouseLand
end

function MapMarkerProviderHouseLand:OnGetMarkers(UIMapID, MapID)
	return self:CreateMarkers()
end

function MapMarkerProviderHouseLand:OnCreateMarker(Params)
	local Marker = self:CreateMarker(MapMarkerHouseLand, Params.ID, Params)
	if nil == Marker then
		return
	end

	local X, Y = MapUtil.GetUIPosByLocation(Params.Pos, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)

	return Marker
end

function MapMarkerProviderHouseLand:CreateMarkers()
	if not MapUtil.IsHouseUIMap(self.UIMapID) then
		return
	end

	local CurMapLandList = _G.HouseLandMgr.CurMapLandList
	if nil == CurMapLandList then
		return
	end

	local MapMarkers = {}

	for i = 1, #CurMapLandList do
		local LandInfo = CurMapLandList[i]
		local BlockID = type(LandInfo) == "table" and LandInfo.LandNumber or 0
		local HousingMapMarkerInfoCfgData = HousingMapMarkerInfoCfg:GetMarkerInfoCfg(self.MapID, BlockID)
		if HousingMapMarkerInfoCfgData then
			if HousingMapMarkerInfoCfgData.UIMapID ~= self.UIMapID then
				-- 土地数据非当前UI地图
				return
			end
			local Params = { ID = BlockID, LandInfo = LandInfo, Pos = HousingMapMarkerInfoCfgData.Pos, Radius = HousingMapMarkerInfoCfgData.RangeOnMap, }
			local Marker = self:OnCreateMarker(Params)
			table.insert(MapMarkers, Marker)
		end
	end

	--[[
	local AllCfg = HousingMapMarkerInfoCfg:GetAllMarkerInfoCfg(self.UIMapID)
	for i = 1, #AllCfg do
		local HousingMapMarkerInfoCfgData = AllCfg[i]
		local MarkerID = HousingMapMarkerInfoCfgData.BlockID -- 房屋住宅区地块ID
		local Params = { ID = MarkerID, Pos = HousingMapMarkerInfoCfgData.Pos, Radius = HousingMapMarkerInfoCfgData.RangeOnMap, }
		local Marker = self:OnCreateMarker(Params)
		table.insert(MapMarkers, Marker)
	end
	--]]

	return MapMarkers
end


return MapMarkerProviderHouseLand