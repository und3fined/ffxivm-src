local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapUtil = require("Game/Map/MapUtil")
local MapMarkerChocoboTransportPoint = require("Game/Map/Marker/MapMarkerChocoboTransportPoint")
local ProtoCS = require("Protocol/ProtoCS")

local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS

---@class MapMarkerProviderChocoboTransportPoint
local MapMarkerProviderChocoboTransportPoint = LuaClass(MapMarkerProvider)

function MapMarkerProviderChocoboTransportPoint:Ctor()
end

function MapMarkerProviderChocoboTransportPoint:OnGetMarkers(UIMapID)
    local QuestParamList = {}
    local TempQuestMap = {}
    local TrackingQuestList = _G.QuestTrackMgr:GetTrackingQuestParam()
    if TrackingQuestList then
        for i=1, #TrackingQuestList do
            local Quest = TrackingQuestList[i]
            local Key = Quest.TargetID > 0 and Quest.TargetID or Quest.QuestID
            TempQuestMap[Key] = true
            table.insert(QuestParamList, Quest)
        end
    end

    local MapID = MapUtil.GetMapID(UIMapID)
    local MapQuestList = _G.QuestTrackMgr:GetMapQuestList(MapID)
    for i=1, #MapQuestList do
        local Quest = MapQuestList[i]
        local Key = Quest.TargetID > 0 and Quest.TargetID or Quest.QuestID
        if not TempQuestMap[Key] then
            TempQuestMap[Key] = true
            local Status = _G.QuestMgr:GetQuestStatus(Quest.QuestID)
            if Status == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS then
                table.insert(QuestParamList, Quest)
            end
        end
    end

    local Markers = {}

    for i = 1, #QuestParamList do
		local Quest = QuestParamList[i]
        if Quest.UIMapID == UIMapID then
            local Marker = self:OnCreateMarker(Quest)
            if Marker then
                table.insert(Markers, Marker)
            end
        else
            --任务映射在当前地图
            local MappingMapCfg = _G.WorldMapMgr:FindMappingMapCfgByMapID(Quest.MapID)
            if MappingMapCfg and MappingMapCfg.MappingUIMapID == UIMapID then
                local Marker = self:OnCreateMappingMarker(Quest, MappingMapCfg)
                if Marker then
                    table.insert(Markers, Marker)
                end
            end
        end
	end

    return Markers
end

function MapMarkerProviderChocoboTransportPoint:OnCreateMarker(Params)
    local Point = Params.AssistPos or Params.Pos
    if not Point then
        return
    end

    self.ID = Params.QuestID

    ---@type MapMarkerChocoboTransportPoint
    local Marker = self:CreateMarker(MapMarkerChocoboTransportPoint, Params.QuestID, Params)

    local X, Y = MapUtil.GetUIPosByLocation(Point, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)
    Marker:SetWorldPos(Point.X, Point.Y, Point.Z)

    self:OnUpdateQuestIcon(Marker, Params.QuestID)

    local TrackingQuestList = _G.QuestTrackMgr:GetTrackingQuestParam()
    if TrackingQuestList then
        for i=1, #TrackingQuestList do
            local QuestParam = TrackingQuestList[i]
            if QuestParam.QuestID == Params.QuestID then
                Marker:SetIsTrackQuest(true)
                break
            end
        end
    end

    return Marker
end

function MapMarkerProviderChocoboTransportPoint:OnCreateMappingMarker(QuestParams, MappingMapCfg)
    self.ID = QuestParams.QuestID

    ---@type MapMarkerChocoboTransportPoint
    local Marker = self:CreateMarker(MapMarkerChocoboTransportPoint, QuestParams.QuestID, QuestParams)

    local Pos = MapUtil.GetMappingMapTransPos(MappingMapCfg.MappingMapID, MappingMapCfg.ActorResID, MappingMapCfg.TransType)
	local X, Y = MapUtil.GetUIPosByLocation(Pos, MappingMapCfg.MappingUIMapID)

	Marker:SetAreaMapPos(X, Y)
    Marker:SetWorldPos(Pos.X, Pos.Y, Pos.Z)

    --重新矫正mapid是映射地图id，不是任务真正的地图id
    Marker.MapID = MappingMapCfg.MappingMapID

    self:OnUpdateQuestIcon(Marker, QuestParams.QuestID)

    return Marker
end

function MapMarkerProviderChocoboTransportPoint:OnUpdateQuestIcon(Marker, QuestID)
	if nil == Marker then
		return
	end

	local IconPath = _G.QuestMgr:GetQuestIconAtMap(QuestID)
	Marker:SetIconPath(IconPath)
	self:SendUpdateMarkerEvent(Marker)
end

return MapMarkerProviderChocoboTransportPoint
