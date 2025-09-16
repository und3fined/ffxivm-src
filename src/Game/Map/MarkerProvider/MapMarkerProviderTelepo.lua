--
-- Author: anypkvcai
-- Date: 2023-03-01 16:57
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProviderFixPoint = require("Game/Map/MarkerProvider/MapMarkerProviderFixPoint")
local MapMarkerFixedPoint = require("Game/Map/Marker/MapMarkerFixedPoint")
local MapMarkerRegion = require("Game/Map/Marker/MapMarkerRegion")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerType = MapDefine.MapMarkerType

---@class MapMarkerProviderTelepo @水晶 和端游命名保持一致
local MapMarkerProviderTelepo = LuaClass(MapMarkerProviderFixPoint)

---Ctor
function MapMarkerProviderTelepo:Ctor()

end

function MapMarkerProviderTelepo:GetMarkerType()
	return MapMarkerType.Telepo
end

function MapMarkerProviderTelepo:OnCreateMarker(Params, IsRegion)
	-- 只显示传送大水晶
	if not MapUtil.IsAcrossMapCrystalByMarkerCfg(Params) then
		return
	end

	if IsRegion then
		return self:CreateMarker(MapMarkerRegion, Params.ID, Params)
	else
		return self:CreateMarker(MapMarkerFixedPoint, Params.ID, Params)
	end
end

return MapMarkerProviderTelepo