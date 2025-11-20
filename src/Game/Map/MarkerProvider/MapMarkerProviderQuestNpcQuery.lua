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

function MapMarkerProviderQuestNpcQuery:GetQuestType(LevelID)
    if not LevelID then
        return 0
    end
    local SEQuestMap = _G.ChocoboTransportMgr.SEQuestMap
    if SEQuestMap then
        local Val = SEQuestMap[LevelID]
        if Val == 8 then
            return 20000
        elseif Val == 1 then
            return 30000
        elseif Val == 3 then
            return 10000
        end
    end
    return 40000
end

---查询端游
function MapMarkerProviderQuestNpcQuery:OnGetMarkers(UIMapID)
    local IsQuestNpcQueryEnable = _G.ChocoboTransportMgr:GetQuestNpcQueryEnable()
    if not IsQuestNpcQueryEnable then
        return
    end
    local Markers = {}

    local QuestLevelInfo = _G.UE.UExcelUtil.GetQuestLevelInfo(UIMapID)
    if not string.isnilorempty(QuestLevelInfo) then
        local RowList = string.split(QuestLevelInfo, '|')
        for i=1, #RowList do
            local Row = RowList[i]
            local ValueList = string.split(Row, ',')
            local LevelID = tonumber(ValueList[1])
            local Param =
            {
                ID = tonumber(ValueList[2]),
                BirthPoint =
                {
                    Y = tonumber(ValueList[3]) * -100,
                    Z = tonumber(ValueList[4]) * 100,
                    X = tonumber(ValueList[5]) * 100,
                },
                GenreID = self:GetQuestType(LevelID),
                Range = tonumber(ValueList[6]),
            }
            if Param.GenreID ~= 40000 then
                local Marker = self:OnCreateMarker(Param)
                table.insert(Markers, Marker)
            end
        end
    end

    return Markers
end

--[[
---查询手游
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
]]

function MapMarkerProviderQuestNpcQuery:OnCreateMarker(Params)
    local Point = Params.BirthPoint
    local Marker = self:CreateMarker(MapMarkerRedPoint, Params.ID, Params)

    local X, Y = MapUtil.GetUIPosByLocation(Point, self.UIMapID)
    Marker:SetAreaMapPos(X, Y)

    return Marker
end

return MapMarkerProviderQuestNpcQuery
