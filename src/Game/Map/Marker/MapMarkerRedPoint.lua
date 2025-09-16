local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType

---@class MapMarkerRedPoint
local MapMarkerRedPoint = LuaClass(MapMarker)

---Ctor
function MapMarkerRedPoint:Ctor()
	self.ID = nil
	self.IconPath = nil
	self.Radius = 0
end

function MapMarkerRedPoint:GetType()
	return MapMarkerType.RedPoint
end

function MapMarkerRedPoint:GetBPType()
	return MapMarkerBPType.Placed
end

function MapMarkerRedPoint:GetTipsName()
	return self.Name
end

function MapMarkerRedPoint:InitMarker(Params)
	self:UpdateMarker(Params)
end

function MapMarkerRedPoint:UpdateMarker(Params)
	local GenreID = Params.GenreID
	if GenreID then
		local Type = math.floor(GenreID / 10000)
		if Type == 0 then
			self.IconPath = "PaperSprite'/Game/UI/Atlas/MapIconSnap/Frames/060431_png.060431_png'"
		elseif Type == 1 then
			self.IconPath = "PaperSprite'/Game/UI/Atlas/MapIconSnap/Frames/060422_png.060422_png'"
		elseif Type ==2 then
			self.IconPath = "PaperSprite'/Game/UI/Atlas/MapIconSnap/Frames/060403_png.060403_png'"
		elseif Type == 3 then
			self.IconPath = "PaperSprite'/Game/UI/Atlas/MapIconSnap/Frames/060421_png.060421_png'"
		elseif Type == 4 then
			self.IconPath = "PaperSprite'/Game/UI/Atlas/MapIconSnap/Frames/060444_png.060444_png'"
		end
	end
	self.ID = Params.ID
end

function MapMarkerRedPoint:OnTriggerMapEvent(EventParams)
end


return MapMarkerRedPoint