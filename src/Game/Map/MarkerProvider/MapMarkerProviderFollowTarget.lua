local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerFollowTarget = require("Game/Map/Marker/MapMarkerFollowTarget")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")

local MapMarkerType = MapDefine.MapMarkerType
local MapFollowTargetType = MapDefine.MapFollowTargetType


---@class MapMarkerProviderFollowTarget : MapMarkerProvider
local MapMarkerProviderFollowTarget = LuaClass(MapMarkerProvider)

function MapMarkerProviderFollowTarget:Ctor()

end

function MapMarkerProviderFollowTarget:GetMarkerType()
	return MapMarkerType.FollowTarget
end

function MapMarkerProviderFollowTarget:OnGetMarkers(UIMapID, MapID)
	return self:CreateFollowMarkers()
end

function MapMarkerProviderFollowTarget:OnCreateMarker(Params)
	local Pos = Params.Pos
	if Pos == nil then
		return
	end

	local Marker = self:CreateMarker(MapMarkerFollowTarget, Params.FollowTargetType, Params)

	local X, Y = MapUtil.GetUIPosByLocation(Pos, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)
	Marker:SetWorldPos(Pos.X, Pos.Y, Pos.Z)

	return Marker
end

function MapMarkerProviderFollowTarget:CreateFollowMarkers()
	local MapMarkers = {}

	-- 地图追踪
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	local BuoyPos = _G.WorldMapMgr:GetMapFollowBuoyPos()
	if FollowInfo and BuoyPos then
		local Params = {FollowTargetType = MapFollowTargetType.FollowByPlayer, Pos = BuoyPos}
		local Marker = self:OnCreateMarker(Params)
		table.insert(MapMarkers, Marker)
	end

	-- 附近未解锁水晶
	local CrystalPortalInfo = _G.BuoyMgr.UnActivatedCrystalPortalInfo
	if CrystalPortalInfo then
		local Params = {FollowTargetType = MapFollowTargetType.UnActivatedCrystal, Pos = CrystalPortalInfo.Pos}
		local Marker = self:OnCreateMarker(Params)
		table.insert(MapMarkers, Marker)
	end

	-- 金蝶地图机遇任务开启时NPC
	local GoldGameNPCFollowState, CurrGoldGameNPC = _G.BuoyMgr:GetGoldGameNPCFollowInfo()
	if GoldGameNPCFollowState and CurrGoldGameNPC then
		local Params = {FollowTargetType = MapFollowTargetType.GoldGameNPC, Pos = CurrGoldGameNPC.BirthPoint}
		local Marker = self:OnCreateMarker(Params)
		table.insert(MapMarkers, Marker)
	end

	return MapMarkers
end


return MapMarkerProviderFollowTarget