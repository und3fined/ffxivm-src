--
-- Author: anypkvcai
-- Date: 2023-04-11 10:04
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerQuestTarget = require("Game/Map/Marker/MapMarkerQuestTarget")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local MapMarkerType = MapDefine.MapMarkerType


---@class MapMarkerProviderQuestTarget : MapMarkerProvider
local MapMarkerProviderQuestTarget = LuaClass(MapMarkerProvider)

function MapMarkerProviderQuestTarget:Ctor()

end

function MapMarkerProviderQuestTarget:GetMarkerType()
	return MapMarkerType.QuestTarget
end

function MapMarkerProviderQuestTarget:OnGetMarkers(UIMapID, MapID)
	return self:CreateQuestMarkers()
end

function MapMarkerProviderQuestTarget:OnCreateMarker(Params)
	local Pos = Params.Pos
	if Pos == nil then
		return
	end

	local Marker = self:CreateMarker(MapMarkerQuestTarget, Params.MarkerID, Params)

	local X, Y = MapUtil.GetUIPosByLocation(Pos, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)
	Marker:SetWorldPos(Pos.X, Pos.Y, Pos.Z)

	return Marker
end

function MapMarkerProviderQuestTarget:FindMarker(Params)
	return table.find_item(self.MapMarkers, Params)
end

function MapMarkerProviderQuestTarget:CreateQuestMarkers()
	local MapMarkers = {}

	-- 追踪任务列表
	--[[
	local QuestList = _G.QuestTrackMgr:GetTrackingQuestParam()
	if nil == QuestList then
		return
	end

	for i = 1, #QuestList do
		local Quest = QuestList[i]
		if nil ~= Quest.Pos and Quest.UIMapID == self.UIMapID then
			local Marker = self:OnCreateMarker(Quest)
			table.insert(MapMarkers, Marker)
		end
	end
	--]]

	local BuoyPos = _G.QuestTrackMgr.QuestBuoyPos
	if BuoyPos then
		-- 标记ID用0即可，只显示任务的一个目标，和任务浮标对应
		local Params = { MarkerID = 0, Pos = BuoyPos }
		local Marker = self:OnCreateMarker(Params)
		table.insert(MapMarkers, Marker)
	end

	return MapMarkers
end

-- 追踪任务目标更新，可以是追踪任务更新，或者任务的目标更新
function MapMarkerProviderQuestTarget:TrackQuestChanged()
	self:ClearMarkers()
	self:UpdateMarkers()
end

return MapMarkerProviderQuestTarget