local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local ScenemarkCfg = require("TableCfg/ScenemarkCfg")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType


---@class MapMarkerSceneSign : MapMarker
local MapMarkerSceneSign = LuaClass(MapMarker)

function MapMarkerSceneSign:Ctor()

end

function MapMarkerSceneSign:GetType()
	return MapMarkerType.SceneSign
end

function MapMarkerSceneSign:GetBPType()
    return MapMarkerBPType.CommGameplay
end

function MapMarkerSceneSign:InitMarker(Params)
	local CfgSceneMark = ScenemarkCfg:FindCfgByKey(Params.Index)
    if CfgSceneMark then
        self.IconPath = CfgSceneMark.IconPath
    end

    self:UpdateMarker(Params)
end

function MapMarkerSceneSign:UpdateMarker(Params)

end

function MapMarkerSceneSign:IsNameVisible(Scale)
	return false
end


return MapMarkerSceneSign