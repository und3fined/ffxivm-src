local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType


local IconType = {
	DiscoverNote = 1,
	WildBoxMound = 2,
	TouringBand = 3,
	MysteryMerchant = 4,
	Fate = 5,
	AetherCurrent = 6,
}

local IconMap = {
	[IconType.DiscoverNote] = "PaperSprite'/Game/UI/Atlas/MapIconSnap/Frames/060422_png.060422_png'",
	[IconType.WildBoxMound] = "PaperSprite'/Game/UI/Atlas/MapIconSnap/Frames/060424_png.060424_png'",
	[IconType.TouringBand] = "PaperSprite'/Game/UI/Atlas/MapIconSnap/Frames/060403_png.060403_png'",
	[IconType.MysteryMerchant] = "PaperSprite'/Game/UI/Atlas/MapIconSnap/Frames/060411_png.060411_png'",
	[IconType.Fate] = "PaperSprite'/Game/UI/Atlas/MapIconSnap/Frames/UI_MapMark_Img_Fate_png.UI_MapMark_Img_Fate_png'",
	[IconType.AetherCurrent] = "PaperSprite'/Game/UI/Atlas/MapIconSnap/Frames/060431_png.060431_png'",
}


---@class MapMarkerGameplayLocation : MapMarker
local MapMarkerGameplayLocation = LuaClass(MapMarker)

---Ctor
function MapMarkerGameplayLocation:Ctor()
	self.ID = nil
	self.IconPath = nil
	self.Radius = 0
	self.IconType = nil
	self.Pos = nil
end

function MapMarkerGameplayLocation:GetType()
	return MapMarkerType.GameplayLocation
end

function MapMarkerGameplayLocation:GetBPType()
	return MapMarkerBPType.GameplayLocation
end

function MapMarkerGameplayLocation:GetTipsName()
	return self.Name
end

function MapMarkerGameplayLocation:GetRadius()
	return self.Radius
end

function MapMarkerGameplayLocation:InitMarker(Params)
	self:UpdateMarker(Params)
end

function MapMarkerGameplayLocation:UpdateMarker(Params)
	self.Pos = Params.BirthPoint
	self.Radius = tonumber(Params.Radius) or 0
	self.IconType = Params.Type
	self.IconPath = IconMap[Params.Type]
end

return MapMarkerGameplayLocation