--
-- Author: anypkvcai
-- Date: 2023-06-19 19:19
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerGather = require("Game/Map/Marker/MapMarkerGather")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")

local MapMarkerType = MapDefine.MapMarkerType


---@class MapMarkerProviderGather : MapMarkerProvider
local MapMarkerProviderGather = LuaClass(MapMarkerProvider)

function MapMarkerProviderGather:Ctor()

end

function MapMarkerProviderGather:GetMarkerType()
	return MapMarkerType.Gather
end

function MapMarkerProviderGather:OnGetMarkers(UIMapID, MapID)
	if MapID ~= _G.MapMgr:GetMapID() then
		return
	end

	return self:CreateGatherMarkers()
end

function MapMarkerProviderGather:CreateGatherMarkers()
	-- 客户端小地图视野内的采集点
	local GatherPoints = _G.GatherMgr:GetAllGatherPoints()
	if nil == GatherPoints then
		return
	end

	local MapMarkers = {}

	for i = 1, #GatherPoints do
		local GatherPoint = GatherPoints[i]
		if nil ~= GatherPoint then
			local Marker = self:OnCreateMarker(GatherPoint)
			table.insert(MapMarkers, Marker)
		end
	end

	-- 最近采集点，可能超出客户端小地图视野，先判断该点是否已经创建过标记，如果没有创建过则需要创建显示
	local GatherPointInfo = _G.GatherMgr:GetNearestGatherPointInfo()
	if GatherPointInfo and GatherPointInfo.ListID then
		local HasCreateMarker = false
		for i = 1, #GatherPoints do
			local GatherPoint = GatherPoints[i]
			if nil ~= GatherPoint and GatherPoint.ListID == GatherPointInfo.ListID then
				HasCreateMarker = true
			end
		end

	   if not HasCreateMarker then
			local Marker = self:OnCreateMarker(GatherPointInfo)
			table.insert(MapMarkers, Marker)
		end
	end

	return MapMarkers
end

function MapMarkerProviderGather:OnCreateMarker(Params)
	local ListID = Params.ListID
	if nil ~= self:FindMarker(ListID) then
		return
	end

	local Marker = self:CreateMarker(MapMarkerGather, ListID, Params)
	if nil == Marker then
		return
	end

	local X, Y = MapUtil.GetUIPosByLocation(Params.Pos, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)

	Marker:SetIsTracking(self:CheckIsTracking(ListID))
	-- 限时采集点使用追踪一样表现
	if Params.IsTimeLimit then
		Marker:SetIsTracking(true)
	end

	return Marker
end

function MapMarkerProviderGather:UpdateGatherPoints()
	self:ClearMarkers()
	self:UpdateMarkers()
end

function MapMarkerProviderGather:UpdateNearestGather(Params)
	local ListID = Params.ListID

	local Marker = self:FindMarker(ListID)
	if nil == Marker then
		if Params.bShow then
			self:AddMarker(Params)
		end
		return
	end

	Marker:SetIsTracking(Params.bShow)

	self:SendUpdateMarkerEvent(Marker)
end

function MapMarkerProviderGather:CheckIsTracking(ListID)
	local GatherPointInfo = _G.GatherMgr:GetNearestGatherPointInfo()
	if nil == GatherPointInfo then
		return false
	end

	return GatherPointInfo.ListID == ListID
end


--[[
function MapMarkerProviderGather:OnGetMarkers(UIMapID)
	if UIMapID ~= _G.MapMgr:GetUIMapID() then
		return
	end

	local MapMarkers = {}

	local AllActors = _G.UE.UActorManager:Get():GetAllActors()
	local ActorCount = AllActors:Length()

	for i = 1, ActorCount, 1 do
		local Actor = AllActors:Get(i)
		if nil ~= Actor then
			local AttributeComponent = Actor:GetAttributeComponent()
			if nil ~= AttributeComponent and AttributeComponent.ObjType == _G.UE.EActorType.Gather then
				local Params = { EntityID = AttributeComponent.EntityID, ResID = AttributeComponent.ResID }
				local Marker = self:OnCreateMarker(Params)
				table.insert(MapMarkers, Marker)
			end
		end
	end

	return MapMarkers

end

function MapMarkerProviderGather:OnCreateMarker(Params)
	local Marker = self:CreateMarker(MapMarkerGather, Params.EntityID, Params)
	if nil == Marker then
		return
	end

	return Marker
end

function MapMarkerProviderGather:OnVisionEnter(EntityID, ResID)
	if _G.MapMgr:GetUIMapID() == self.UIMapID then
		local Params = { EntityID = EntityID, ResID = ResID }
		self:AddMarker(Params)
	end
end

function MapMarkerProviderGather:OnVisionLeave(EntityID, ResID)
	if _G.MapMgr:GetUIMapID() == self.UIMapID then
		self:RemoveMarker(EntityID)
	end
end
--]]

return MapMarkerProviderGather