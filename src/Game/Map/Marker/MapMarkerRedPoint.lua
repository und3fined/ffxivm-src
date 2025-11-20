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
	self.GenreID = 0
	self.Range = 1
end

function MapMarkerRedPoint:GetType()
	return MapMarkerType.RedPoint
end

function MapMarkerRedPoint:GetBPType()
	return MapMarkerBPType.RedPoint
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
		--self.IconPath = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_Light_png.UI_Icon_Light_png'"
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

		self.QuestType = Type
	end
	self.ID = Params.ID
	self.GenreID = Params.GenreID
	self.Range = Params.Range
end

function MapMarkerRedPoint:GetPriority()
	return 200 - math.floor(self.GenreID/10000)
end

function MapMarkerRedPoint:GetAlpha()
	return 0.6
end

function MapMarkerRedPoint:GetQuestType()
	return self.QuestType
end

function MapMarkerRedPoint:GetRadius()
	return self.Range * 100
end

function MapMarkerRedPoint:OnTriggerMapEvent(EventParams)
end


return MapMarkerRedPoint