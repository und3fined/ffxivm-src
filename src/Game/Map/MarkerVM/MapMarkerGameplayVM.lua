--
-- Author: peterxie
-- Date:
-- Description: 地图通用玩法标记
--

local LuaClass = require("Core/LuaClass")
local MapMarkerVM = require("Game/Map/MarkerVM/MapMarkerVM")


---@class MapMarkerGameplayVM : MapMarkerVM
local MapMarkerGameplayVM = LuaClass(MapMarkerVM)

function MapMarkerGameplayVM:Ctor()
	self.bPerfectCond = false
end

---@param Value MapMarkerGameplay
function MapMarkerGameplayVM:UpdateVM(Value)
	self.MapMarker = Value
	self.Name = Value:GetName()
	self.IconPath = Value:GetIconPath()
	self:UpdateNameVisibility()
	self:UpdateIconVisibility()
	self:UpdateMarkerVisible()
	self.IsFollow = Value:GetIsFollow()

	self.bPerfectCond = Value:GetIsPerfectCond()
end

return MapMarkerGameplayVM