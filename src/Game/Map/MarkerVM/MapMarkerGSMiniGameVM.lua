--
-- Author: alex
-- Date: 2025-06-23 11:19
-- Description:金碟游乐场小游戏标记
--

local LuaClass = require("Core/LuaClass")
local MapMarkerVM = require("Game/Map/MarkerVM/MapMarkerVM")
local GoldSaucerBlessingDefine = require("Game/GoldSaucerMiniGame/GoldSaucerBlessingDefine")
local EBlessingState = GoldSaucerBlessingDefine.EBlessingState

---@class MapMarkerGSMiniGameVM : MapMarkerVM
local MapMarkerGSMiniGameVM = LuaClass(MapMarkerVM)

---Ctor
function MapMarkerGSMiniGameVM:Ctor()
    self.BlessState = EBlessingState.NotBegin
end

function MapMarkerGSMiniGameVM:UpdateVM(Value)
    self.MapMarker = Value
	self.Name = Value:GetName()
	self.IconPath = Value:GetIconPath()
	self:UpdateNameVisibility()
	self:UpdateIconVisibility()
	self:UpdateMarkerVisible()
	self.IsFollow = Value:GetIsFollow()
    self.BlessState = Value:GetMarkerBlessState()
end

return MapMarkerGSMiniGameVM