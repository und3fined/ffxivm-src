--
-- Author: anypkvcai
-- Date: 2023-06-24 21:19
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerWorldMapGather = require("Game/Map/Marker/MapMarkerWorldMapGather")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class MapMarkerProviderWorldMapGather : MapMarkerProvider
local MapMarkerProviderWorldMapGather = LuaClass(MapMarkerProvider)

function MapMarkerProviderWorldMapGather:Ctor()

end

function MapMarkerProviderWorldMapGather:GetMarkerType()
	return MapDefine.MapMarkerType.WorldMapGather
end

function MapMarkerProviderWorldMapGather:OnGetMarkers(UIMapID, MapID)
	local MapMarkers = {}

	if self.ContentType == MapDefine.MapContentType.WorldMapGather then
		-- 采集点世界地图，显示传参的采集点
		local GatherParams = _G.WorldMapMgr.WorldMapGatherParams
		if GatherParams == nil then
			return
		end
		if MapID ~= GatherParams.MapID then
			return
		end

		MapMarkers = self:CreateGatherMarkers()
	else
		-- 普通大地图，只显示追踪中的采集点
		local FollowMarker = self:GetFollowMarker()
        if FollowMarker then
            table.insert(MapMarkers, FollowMarker)
        end
	end

	return MapMarkers
end

function MapMarkerProviderWorldMapGather:OnCreateMarker(Params)
	local Marker = self:CreateMarker(MapMarkerWorldMapGather, Params.ResID, Params)
	if nil == Marker then
		return
	end

	local X, Y = MapUtil.GetUIPosByLocation(Params.Pos, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)

	return Marker
end

function MapMarkerProviderWorldMapGather:CreateGatherMarkers()
	local MapMarkers = {}

	local GatherParams = _G.WorldMapMgr.WorldMapGatherParams
	if GatherParams == nil then
		return MapMarkers
	end
	local MapID = GatherParams.MapID
	local GatherPointIDList = GatherParams.GatherPointIDList

	for _, GatherPointData in ipairs(GatherPointIDList) do
		if GatherPointData.IsShowMakers then
			local GatherPointPosList = _G.GatherMgr:GetGatherPoints(MapID, GatherPointData.GatherPointID)
			if #GatherPointPosList > 0 then
				-- 一个采集点可能配有多个坐标点，这里显示用第一个坐标点
				local Params = { ResID = GatherPointData.GatherPointID, Pos = GatherPointPosList[1], WorldMapGather = true, }
				local Marker = self:OnCreateMarker(Params)
				table.insert(MapMarkers, Marker)
			end
		end
	end

	if #MapMarkers == 0 then
		MsgTipsUtil.ShowTips(_G.LSTR(70062)) --尚未完成首次采集，无法查看精准位置
	end

	return MapMarkers
end

function MapMarkerProviderWorldMapGather:GetFollowMarker()
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo == nil  then
		return
	end
	if FollowInfo.FollowType ~= self:GetMarkerType() then
		return
	end
    local FollowGatherResID = FollowInfo.FollowID
    local FollowMapID = FollowInfo.FollowMapID

	if self.MapID ~= FollowMapID then
		return
	end

	local GatherPointPosList = _G.GatherMgr:GetGatherPoints(FollowMapID, FollowGatherResID)
	if #GatherPointPosList > 0 then
		local Params = { ResID = FollowGatherResID, Pos = GatherPointPosList[1], WorldMapGather = true, }
		local Marker = self:OnCreateMarker(Params)
		return Marker
	end
end


return MapMarkerProviderWorldMapGather