--
-- Author: Alex
-- Date:2025-02-24
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerDetectTarget = require("Game/Map/Marker/MapMarkerDetectTarget")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")


---@class MapMarkerProviderDetectTarget : MapMarkerProvider
local MapMarkerProviderDetectTarget = LuaClass(MapMarkerProvider)

function MapMarkerProviderDetectTarget:Ctor()
	self.ActiveID = nil -- 当前地图激活的技能id
end

function MapMarkerProviderDetectTarget:GetMarkerType()
	return MapDefine.MapMarkerType.DetectTarget
end

function MapMarkerProviderDetectTarget:OnGetMarkers(_, MapID)
	local MapMarkers = {}

	if self.ContentType == MapDefine.MapContentType.WorldMap or self.ContentType == MapDefine.MapContentType.MiniMap then
		local DetectTargetInRange = _G.DiscoverNoteMgr:GetTheDetectTargetInRange(MapID)
		if DetectTargetInRange == nil then
			return
		end
		local Markers = self:CreateDetectedMarkers(DetectTargetInRange)
		if Markers then
            table.merge_table(MapMarkers, Markers)
        end
	--[[else
		local FollowMarker = self:GetFollowMarker()
        if FollowMarker then
            table.insert(MapMarkers, FollowMarker)
        end 非世界地图与小地图暂不显示此图标--]]
	end

	return MapMarkers
end

function MapMarkerProviderDetectTarget:OnCreateMarker(Params)
	local MapID = self.MapID
    if not MapID then
        return
    end

	local MarkerID = Params.MarkerID
	--Params.ActiveID = Params.ActiveID
	local Marker = self:CreateMarker(MapMarkerDetectTarget, MarkerID, Params)
	if nil == Marker then
		return
	end

	local Location = Params.Position
	if Location == nil then
		return
	end

	local X, Y = MapUtil.GetUIPosByLocation(Location, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)

	return Marker
end

function MapMarkerProviderDetectTarget:CreateDetectedMarkers(DetectTargetInRange)
	if not DetectTargetInRange or not next(DetectTargetInRange) then
		return
	end

    local Markers = {}
    local ActiveID = DetectTargetInRange.ActiveID
	self.ActiveID = ActiveID
    local TargetList = DetectTargetInRange.TargetArray
    for _, Target in ipairs(TargetList) do
        local MarkerID = Target.MarkerID
        local ActorType = Target.ActorType -- TriggerGamePlayType
        local Params = { MarkerID = MarkerID, ActiveID = ActiveID, ActorType = ActorType, Position = Target.Position }
        local Marker = self:OnCreateMarker(Params)
        table.insert(Markers, Marker)
    end
	return Markers
end

function MapMarkerProviderDetectTarget:UpdateFollowMarker(FollowInfo)
	if FollowInfo == nil then
		return
	end

	if MapUtil.IsAreaMap(self.UIMapID) then
		local FollowMarkerID = FollowInfo.FollowID
		local Markers = table.find_all_by_predicate(self.MapMarkers, function(Element)
			return Element.ID == FollowMarkerID
		end)
		if Markers then
			for _, Marker in ipairs(Markers) do
				Marker:UpdateFollow()
				self:SendUpdateMarkerEvent(Marker)
			end
		end
	else
		_G.EventMgr:SendEvent(_G.EventID.WorldMapUpdateAllMarker)
	end
end

function MapMarkerProviderDetectTarget:AddMarkerInRange(Params)
	if nil == self.MapMarkers then
		return
	end

	local MarkerID = Params.MarkerID
	local ActorType = Params.ActorType
	if not MarkerID or not ActorType then
		return
	end

	local bExistMarker = table.find_by_predicate(self.MapMarkers, function(Element)
		return Element.ID == MarkerID and Element.ActorType == ActorType
	end)

	if bExistMarker then
		return -- 已经存在的Marker不再创建，避免重复创建Marker
	end

	local Marker = self:OnCreateMarker(Params)
	if nil == Marker then
		return
	end

	table.insert(self.MapMarkers, Marker)

	self:SendAddMarkerEvent(Marker)
end

function MapMarkerProviderDetectTarget:RemoveMarkerOutRange(Params)
	local MarkerID = Params.MarkerID
	local ActorType = Params.ActorType
	if not MarkerID or not ActorType then
		return
	end
	local Marker = table.find_by_predicate(self.MapMarkers, function(Element)
		return Element.ID == MarkerID and Element.ActorType == ActorType
	end)

	if nil == Marker then
		return
	end

	if nil == self.MapMarkers then
		return
	end

	table.remove_item(self.MapMarkers, Marker)

	self:SendRemoveMarkerEvent(Marker)
end

return MapMarkerProviderDetectTarget