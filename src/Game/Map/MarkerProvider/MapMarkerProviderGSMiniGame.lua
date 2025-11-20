--
-- Author: alex
-- Date: 2023-09-11 17:05
-- Description:风脉泉标记
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerGSMiniGame = require("Game/Map/Marker/MapMarkerGSMiniGame")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local GoldSaucerBlessingMgr = require("Game/GoldSaucerMiniGame/MiniGameBless/GoldSaucerBlessingMgr")
local MapMarkerType = MapDefine.MapMarkerType

---@class MapMarkerProviderGSMiniGame
local MapMarkerProviderGSMiniGame = LuaClass(MapMarkerProvider)

---Ctor
function MapMarkerProviderGSMiniGame:Ctor()

end

function MapMarkerProviderGSMiniGame:GetMarkerType()
	return MapMarkerType.GSMiniGame
end

function MapMarkerProviderGSMiniGame:OnGetMarkers(UIMapID)
	local MapInfos = GoldSaucerBlessingMgr:CreateMarkersDataSource(UIMapID)
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

function MapMarkerProviderGSMiniGame:OnCreateMarker(Params)
    local ID = Params.GameID
    local Point = Params.PointLocation
	local Marker = self:CreateMarker(MapMarkerGSMiniGame, ID, Params)

	local X, Y = MapUtil.GetUIPosByLocation(Point, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)

	return Marker
end
 
return MapMarkerProviderGSMiniGame