--
-- Author: anypkvcai
-- Date: 2023-07-05 16:17
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerVM = require("Game/Map/MarkerVM/MapMarkerVM")


---@class MapMarkerFishVM : MapMarkerVM
local MapMarkerFishVM = LuaClass(MapMarkerVM)

---Ctor
function MapMarkerFishVM:Ctor()
	self.bSelected = false
end

function MapMarkerFishVM:UpdateVM(Value)
	self.MapMarker = Value
	self.Name = Value:GetName()
	self.IconPath = Value:GetIconPath()
	self:UpdateNameVisibility()
	self:UpdateIconVisibility()
	self:UpdateMarkerVisible()

	self.bSelected = Value:GetIsSelected()
	self.IsFollow = Value:GetIsFollow()
end

return MapMarkerFishVM