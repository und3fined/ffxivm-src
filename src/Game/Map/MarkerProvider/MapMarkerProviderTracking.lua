--
-- Author: sammrli
-- Date: 2025-03-25 11:01
-- Description: 任务追踪辅助标记代理
-- 它是一个辅助追踪的地图标记，严格来说不属于任务目标，所以没放入到 MapMarkerQuest 一起处理

local LuaClass = require("Core/LuaClass")

local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerTracking = require("Game/Map/Marker/MapMarkerTracking")

local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")

local NpcCfg = require("TableCfg/NpcCfg")
local ProtoRes = require("Protocol/ProtoRes")

local MapMarkerType = MapDefine.MapMarkerType

local QUEST_TYPE = ProtoRes.QUEST_TYPE

---@class MapMarkerProviderTracking : MapMarkerProvider
local MapMarkerProviderTracking = LuaClass(MapMarkerProvider)

function MapMarkerProviderTracking:Ctor()

end

function MapMarkerProviderTracking:GetMarkerType()
	return MapMarkerType.Tracking
end

function MapMarkerProviderTracking:OnGetMarkers(UIMapID, MapID)
	local MapMarkers = self:CreateQuestMarkers(UIMapID)
	return MapMarkers
end

function MapMarkerProviderTracking:OnCreateMarker(Params)

	local Marker = self:CreateMarker(MapMarkerTracking, Params.ResID, Params)

	self:UpdateTrackingIcon(Marker, Params.QuestID)


	local Pos = Params.Pos
	local X, Y = MapUtil.GetUIPosByLocation(Pos, Params.UIMapID)

	Marker:SetAreaMapPos(X, Y)
	Marker:SetWorldPos(Pos.X, Pos.Y, Pos.Z)

	Marker:SetAreaUIMapID(Params.UIMapID)
	Marker:SetMapID(Params.MapID)

	return Marker
end

function MapMarkerProviderTracking:CreateQuestMarkers(UIMapID)
	local MapMarkers = {}

	if _G.PWorldMgr:CurrIsInDungeon() then
		return MapMarkers
	end

	local CurrNavPath = _G.QuestTrackMgr:GetCurrNavPath()
	if CurrNavPath and CurrNavPath.EndPosActorResID and CurrNavPath.EndPosInteractiveID then
		local ActorResID = CurrNavPath.EndPosActorResID
		local NpcCfgItem = NpcCfg:FindCfgByKey(ActorResID)
		if NpcCfgItem and NpcCfgItem.ID == ActorResID then
			local QuestParamList = _G.QuestTrackMgr:GetTrackingQuestParam()
			if QuestParamList then
				local QuestParam = QuestParamList[1]
				if QuestParam then
					if not self:IsFindSameQuestMarker(QuestParam.QuestID) then
						if QuestParam.QuestType == QUEST_TYPE.QUEST_TYPE_MAIN then
							local CurrUIMapID = _G.MapMgr:GetUIMapID()
							if CurrUIMapID == UIMapID then
								local CurrMapID = _G.PWorldMgr:GetCurrMapResID()
								local Params = {Pos=CurrNavPath.EndPos, ResID = ActorResID, QuestID = QuestParam.QuestID, MapID = CurrMapID, UIMapID = CurrUIMapID}
								local Marker = self:OnCreateMarker(Params)
								table.insert(MapMarkers, Marker)
							end
						end
					end
				end
			end
		end
	end

	return MapMarkers
end

function MapMarkerProviderTracking:IsFindSameQuestMarker(QuestID)
	-- 同类型的有映射图标
    local MarkerProviders = _G.MapMarkerMgr:GetMarkerProviders(MapMarkerType.Quest)
	if MarkerProviders then
		local DefaultMarkerProvide = MarkerProviders[1]
		if DefaultMarkerProvide then
			for _, MapMarker in ipairs(DefaultMarkerProvide.MapMarkers) do
				if MapMarker.ID == QuestID then
					return true
				end
			end
		end
	end
	return false
end

function MapMarkerProviderTracking:UpdateAllQuest()
	self:ClearMarkers()
	self:UpdateMarkers()
end

function MapMarkerProviderTracking:UpdateQuest(Params)
	self:ClearMarkers()
	self:UpdateMarkers()
end

function MapMarkerProviderTracking:UpdateQuestIcon(QuestID)
	local MapMarkers = self.MapMarkers
	if nil == MapMarkers then
		return
	end
	for i = 1, #MapMarkers do
		local Marker = MapMarkers[i]
		if Marker:GetID() == QuestID then
			self:UpdateTrackingIcon(Marker, QuestID)
		end
	end
end

function MapMarkerProviderTracking:UpdateTrackingIcon(Marker, QuestID)
	if not Marker then
		return
	end
	local IconPath = _G.QuestMgr:GetTrackingIconAtMap(QuestID)
	Marker:SetIconPath(IconPath)
	self:SendUpdateMarkerEvent(Marker)
end

function MapMarkerProviderTracking:TrackQuestChanged(QuestID)
	self:ClearMarkers()
	self:UpdateMarkers()
end

return MapMarkerProviderTracking