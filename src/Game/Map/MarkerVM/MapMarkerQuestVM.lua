--
-- Author: anypkvcai
-- Date: 2023-04-19 20:14
-- Description:
--


local LuaClass = require("Core/LuaClass")
local MapMarkerVM = require("Game/Map/MarkerVM/MapMarkerVM")


---@class MapMarkerQuestVM : MapMarkerVM
local MapMarkerQuestVM = LuaClass(MapMarkerVM)

---Ctor
function MapMarkerQuestVM:Ctor()
	self.IsTrackQuest = false
	self.TargetID = 0
	self.PriorityOrder = 0
end

function MapMarkerQuestVM:UpdateVM(Value)
	self.MapMarker = Value
	self.Name = Value:GetName()
	self.IconPath = Value:GetIconPath()
	self:UpdateNameVisibility()
	self:UpdateIconVisibility()
	self:UpdateMarkerVisible()
	self.IsFollow = Value:GetIsFollow()

	self.IsTrackQuest = Value:GetIsTrackQuest()
	self.TargetID = Value:GetTargetID()
	self:UpdatePriority()
end

---更新地图标记显示优先级
function MapMarkerQuestVM:UpdatePriority()
	self.PriorityOrder = self.MapMarker:GetPriority()
end

return MapMarkerQuestVM