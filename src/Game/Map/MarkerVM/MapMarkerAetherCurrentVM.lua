--
-- Author: alex
-- Date: 2023-09-11 14:28
-- Description:风脉泉标记
--

local LuaClass = require("Core/LuaClass")
local MapMarkerVM = require("Game/Map/MarkerVM/MapMarkerVM")
local AetherCurrentMapMarkerItemVM = require("Game/AetherCurrent/ItemVM/AetherCurrentMapMarkerItemVM")


---@class MapMarkerAetherCurrentVM : MapMarkerVM
local MapMarkerAetherCurrentVM = LuaClass(MapMarkerVM)

---Ctor
function MapMarkerAetherCurrentVM:Ctor()
	self.bSelected = false
    self.PointListLen = 0
    self.PointContent = nil -- 统一成Table存放风脉点的信息
end

function MapMarkerAetherCurrentVM:UpdateVM(Value)
	self.MapMarker = Value
	self.IconPath = Value:GetIconPath()
	self:UpdateNameVisibility()
	self:UpdateIconVisibility()
    self:UpdateMarkerVisible()
    
    local PointContent = Value.PointContent
    self.PointListLen = #PointContent
    self:MakeTheMapMarkerData(PointContent)
end

function MapMarkerAetherCurrentVM:MakeTheMapMarkerData(PointContent)
    local Content = self.PointContent or {}
    for _, PointInfo in ipairs(PointContent) do
        local VMParam = {
            PointID = PointInfo.PointID,
            IconPath = self.IconPath,
            bWaitForPlayEffect = PointInfo.bWaitForPlayEffect
        }
        local SubVM = AetherCurrentMapMarkerItemVM.New()
        SubVM:UpdateVM(VMParam)
        table.insert(Content, SubVM)
    end
    self.PointContent = Content
end

function MapMarkerAetherCurrentVM:GetIsMarkerVisible()
    return false
end

return MapMarkerAetherCurrentVM