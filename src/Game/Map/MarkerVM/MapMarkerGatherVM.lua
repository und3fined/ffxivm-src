--
-- Author: anypkvcai
-- Date: 2023-08-15 15:59
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerVM = require("Game/Map/MarkerVM/MapMarkerVM")

---@class MapMarkerGatherVM : MapMarkerVM
local MapMarkerGatherVM = LuaClass(MapMarkerVM)

---Ctor
function MapMarkerGatherVM:Ctor()
	self.IsTracking = false
	self.IsDirectionVisible = false
	self.bOutOfRange = false
	self.bSelected = false
end

function MapMarkerGatherVM:UpdateVM(Value)
	self.MapMarker = Value
	self.Name = Value:GetName()
	self.IconPath = Value:GetIconPath()
	self:UpdateNameVisibility()
	self:UpdateIconVisibility()
	self:UpdateMarkerVisible()
	self.IsFollow = Value:GetIsFollow()

	self.IsTracking = Value:GetIsTracking()
	self.bSelected = Value:GetIsSelected()
end

function MapMarkerGatherVM:SetDirectionVisible(bVisible)
	self.IsDirectionVisible = bVisible
end

function MapMarkerGatherVM:SetOutOfRange(bOutOfRange)
	self.bOutOfRange = bOutOfRange
	self:SetIsShowMarker(not bOutOfRange or self.IsTracking)
	self:SetDirectionVisible(bOutOfRange and self.IsTracking)
end

return MapMarkerGatherVM