local LuaClass = require("Core/LuaClass")
local MapUtil = require("Game/Map/MapUtil")

local QuestCfg = require("TableCfg/QuestCfg")
local QuestTargetCfg = require("TableCfg/QuestTargetCfg")
local QuestChapterCfg = require ("TableCfg/QuestChapterCfg")

local MapMarkerRedPoint = require("Game/Map/Marker/MapMarkerRedPoint")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")

---@class MapMarkerProviderQuestNpcQuery
local MapMarkerProviderQuestNpcQuery = LuaClass(MapMarkerProvider)

function MapMarkerProviderQuestNpcQuery:Ctor()
end

function MapMarkerProviderQuestNpcQuery:OnGetMarkers(UIMapID)
    if UIMapID ~= _G.MapMgr:GetUIMapID() then
		return
	end

    local IsQuestNpcQueryEnable = _G.ChocoboTransportMgr:GetQuestNpcQueryEnable()
    local IsShowTransportPointEnable = _G.ChocoboTransportMgr:GetShowTransportPointEnable()

    --是否开启
    if not IsQuestNpcQueryEnable and not IsShowTransportPointEnable then
        return
    end

    local Markers = {}

    if IsQuestNpcQueryEnable then
        local TargetCfgList = QuestTargetCfg:FindAllCfg("MapID = "..tostring(_G.MapMgr:GetMapID()))
        local NpcCfgDict = _G.MapEditDataMgr:GetNpcCfgList()
        for _, TargetCfg in pairs(TargetCfgList) do
            local NPCID = tonumber(TargetCfg.Properties[1])
            if NPCID then
                local NPCCfg = NpcCfgDict[NPCID]
                if NPCCfg then
                    local QuestList = QuestCfg:FindAllCfg("TargetParamID like '%"..tostring(TargetCfg.id).."%'")
                    local FindChapterID = nil
                    for _, QuestCfgItem in ipairs(QuestList) do
                        FindChapterID = QuestCfgItem.ChapterID
                    end
                    local QuestChapterCfgItem = nil
                    if FindChapterID then
                        QuestChapterCfgItem = QuestChapterCfg:FindCfgByKey(FindChapterID)
                    end
                    local Param =
                    {
                        ID = NPCID,
                        BirthPoint = NPCCfg.BirthPoint,
                        GenreID = QuestChapterCfgItem and QuestChapterCfgItem.QuestGenreID or 40000
                    }
                    local Marker = self:OnCreateMarker(Param)

                    table.insert(Markers, Marker)
                end
            end
        end
    end

    if IsShowTransportPointEnable then
        local CurMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
        if CurMapEditCfg.ChocoboTransportPointList then
            for _, V in ipairs(CurMapEditCfg.ChocoboTransportPointList) do
                local Param =
                {
                    ID = V.ListId,
                    BirthPoint =  V.Point,
                    GenreID = 0,
                }
                local Marker = self:OnCreateMarker(Param)

                table.insert(Markers, Marker)
            end
        end
    end

    return Markers
end

function MapMarkerProviderQuestNpcQuery:OnCreateMarker(Params)
    local Point = Params.BirthPoint
    local Marker = self:CreateMarker(MapMarkerRedPoint, Params.ID, Params)

    local X, Y = MapUtil.GetUIPosByLocation(Point, self.UIMapID)
    Marker:SetAreaMapPos(X, Y)

    return Marker
end

return MapMarkerProviderQuestNpcQuery
