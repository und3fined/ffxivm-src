--
-- Author: ranyuan
-- Date: 2024-05-22 16:14
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerVM = require("Game/Map/MarkerVM/MapMarkerVM")
local ProtoCS = require("Protocol/ProtoCS")


---@class MapMarkerFateVM : MapMarkerVM
local MapMarkerFateVM = LuaClass(MapMarkerVM)

---Ctor
function MapMarkerFateVM:Ctor()
    self.Progress = 0
    self.bHighRisk = false
end

function MapMarkerFateVM:UpdateVM(Value)
    self.MapMarker = Value
    self.Name = Value:GetName()
    self.IconPath = Value:GetIconPath()
    self:UpdateNameVisibility()
    self:UpdateIconVisibility()
    self:UpdateMarkerVisible()
    self.IsFollow = Value:GetIsFollow()
    self.bHighRisk = Value.bHighRisk
    self.ImgIconFateNpcVisible = Value:GetImgIconFateNpcVisible()
    self.ImgIconFateNpcPath = Value:GetImgIconFateNpcPath()
    self.Progress = Value.Progress
    self.EndTimeMS = Value.EndTimeMS
end

function MapMarkerVM:GetFateNpcPosition()
    return self.MapMarker:GetFateNpcMapPos()
end

return MapMarkerFateVM
