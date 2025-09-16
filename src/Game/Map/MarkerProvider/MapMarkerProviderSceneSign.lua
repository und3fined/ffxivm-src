local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerSceneSign = require("Game/Map/Marker/MapMarkerSceneSign")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerType = MapDefine.MapMarkerType


---@class MapMarkerProviderSceneSign : MapMarkerProvider
local MapMarkerProviderSceneSign = LuaClass(MapMarkerProvider)

function MapMarkerProviderSceneSign:Ctor()
end

function MapMarkerProviderSceneSign:GetMarkerType()
	return MapMarkerType.SceneSign
end

function MapMarkerProviderSceneSign:OnGetMarkers(UIMapID)
    if self.UIMapID ~= _G.MapMgr:GetUIMapID() then
		return
	end

    return self:CreateSceneSignMarkers()
end

function MapMarkerProviderSceneSign:OnCreateMarker(Params, UIMapID)
    local Marker = self:CreateMarker(MapMarkerSceneSign, Params.Index, Params)

    local X, Y = MapUtil.GetUIPosByLocation(Params.Position, UIMapID)
	Marker:SetAreaMapPos(X, Y)

    return Marker
end

function MapMarkerProviderSceneSign:CreateSceneSignMarkers()
    local MapMarkers = {}

    local SignsMgr = _G.SignsMgr
    if SignsMgr.CurrentUseSceneMarkers == nil
        or SignsMgr.CurrentUseSceneMarkers.Items == nil then
        return MapMarkers
    end

    for _, ItemData in pairs(SignsMgr.CurrentUseSceneMarkers.Items) do
        local Marker = self:OnCreateMarker(ItemData, self.UIMapID)
        table.insert(MapMarkers, Marker)
    end

	return MapMarkers
end

function MapMarkerProviderSceneSign:UpdateSceneSigns()
    self:ClearMarkers()
    self:UpdateMarkers()
end


return MapMarkerProviderSceneSign