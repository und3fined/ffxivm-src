--
-- Author: Alex
-- Date: 2023-09-11 17:06
-- Description:风脉泉标记
--


local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType

---@class MapMarkerAetherCurrent
local MapMarkerAetherCurrent = LuaClass(MapMarker)

---Ctor
function MapMarkerAetherCurrent:Ctor()
    self.PointContent = nil
end

function MapMarkerAetherCurrent:GetType()
	return MapMarkerType.AetherCurrent
end

function MapMarkerAetherCurrent:GetBPType()
	return MapMarkerBPType.AetherCurrent
end

function MapMarkerAetherCurrent:InitMarker(Params)
    self:UpdateMarker(Params)
end

function MapMarkerAetherCurrent:UpdateMarker(Params)
	local IconPath = Params.IconPath
    self:SetIconPath(IconPath)
    self.PointContent = Params.PointContent
end

function MapMarkerAetherCurrent:OnTriggerMapEvent(EventParams)

end

function MapMarkerAetherCurrent:IsNameVisible(Scale)
	return false
end

function MapMarkerAetherCurrent:IsIconVisible(Scale)
	return true
end


return MapMarkerAetherCurrent