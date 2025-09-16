local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapUtil = require("Game/Map/MapUtil")
local MapMarkerGoldActiviry = require("Game/Map/Marker/MapMarkerGoldActiviry")
local MapDefine = require("Game/Map/MapDefine")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")
local NpcQuestCfg = require("TableCfg/NpcQuestCfg")
local ProtoCS = require("Protocol/ProtoCS")
local TARGET_STATUS = ProtoCS.CS_QUEST_NODE_STATUS

local MapEditDataMgr = _G.MapEditDataMgr


---@class MapMarkerProviderGoldActivity
local MapMarkerProviderGoldActivity = LuaClass(MapMarkerProvider)

---Ctor
function MapMarkerProviderGoldActivity:Ctor()
    self.IconPath = GoldSauserDefine.TaskIcon.AlreadySignUp
    self.TheMapID = 196
    self.RelatedNpcIDList = {
        JumboCactpotIssueNpc = 1010446, -- 仙人仙彩发放员
        MiniCactpotIssuerNpc = 1010445,  -- 仙人微彩发放员
        MagicCardReceptNpc = 1010479,    -- 幻卡大赛接待员
        FashionCheckRecptNpc = 1025176,  -- 时尚品鉴Npc 假面·罗斯
    }
end

function MapMarkerProviderGoldActivity:OnGetMarkers(UIMapID)
	if UIMapID ~= _G.MapMgr:GetUIMapID() then
		return
	end
    if UIMapID ~= self.TheMapID then
        return
    end

	local Markers = {}
    -- 功能修改暂时隐藏
	-- local MarkList = self:FindMarkerParams()
	-- if MarkList == nil then
	-- 	return
	-- end
	-- for _, GoldActivityMarker in pairs(MarkList) do
	-- 	local Marker = self:OnCreateMarker(GoldActivityMarker)
	-- 	table.insert(Markers, Marker)
	-- end
	return Markers
end

function MapMarkerProviderGoldActivity:FindMarkerParams()
    local RelatedNpcIDList = self.RelatedNpcIDList
    local BehaviorNpcIDList = GoldSauserDefine.BehaviorNpcIDList
    local MarkerList = {}
    local IconPath = self.IconPath
    local MapID = self.TheMapID
    for _, v in pairs(RelatedNpcIDList) do
        local TempTabel = {}
        local NpcID = v
        local bFinsihQuest = self:CheckFinishQuestByNpcID(NpcID)
        if NpcID == BehaviorNpcIDList.JumboCactpotIssueNpc and (not _G.JumboCactpotMgr:IsExistJumbCount() or not bFinsihQuest) then -- 仙彩没次数
            NpcID = nil
        elseif NpcID == BehaviorNpcIDList.MiniCactpotIssuerNpc and (_G.MiniCactpotMgr:GetLeftChance() == 0 or not bFinsihQuest) then -- 仙人微彩没次数
            NpcID = nil
        elseif NpcID == BehaviorNpcIDList.MagicCardReceptNpc and (_G.MagicCardTourneyMgr:IsFinishedTourney() or not bFinsihQuest) then -- 幻卡大赛没次数
            NpcID = nil
        elseif  NpcID == BehaviorNpcIDList.FashionCheckRecptNpc then -- 时尚品鉴TODO

        end
        if NpcID ~= nil then
            local NpcData = MapEditDataMgr:GetNpc(NpcID)
            if NpcData ~= nil then
                TempTabel.ID = NpcID
                TempTabel.ContentType = 1
                TempTabel.IconPath = IconPath
                TempTabel.BirthPoint = NpcData.BirthPoint
                TempTabel.MapID = MapID
                table.insert(MarkerList, TempTabel)
            end
        end
    end

    return MarkerList
end

function MapMarkerProviderGoldActivity:FindMarkerParamByNpcResID(NpcID, bIsRemove)
    local IconPath = self.IconPath
    local MapID = self.TheMapID
    local BehaviorNpcIDList = GoldSauserDefine.BehaviorNpcIDList
    local MarkerParam = {}
    local bFinsihQuest = self:CheckFinishQuestByNpcID(NpcID)
    if NpcID == BehaviorNpcIDList.JumboCactpotIssueNpc and (not _G.JumboCactpotMgr:IsExistJumbCount() or not bFinsihQuest) then -- 仙彩没次数
        NpcID = nil
    elseif NpcID == BehaviorNpcIDList.MiniCactpotIssuerNpc and (_G.MiniCactpotMgr:GetLeftChance() == 0 or not bFinsihQuest) then -- 仙人微彩没次数
        NpcID = nil
    elseif NpcID == BehaviorNpcIDList.MagicCardReceptNpc and (_G.MagicCardTourneyMgr:IsFinishedTourney() or not bFinsihQuest) then -- 幻卡大赛没次数
        NpcID = nil
    elseif  NpcID == BehaviorNpcIDList.FashionCheckRecptNpc then -- 时尚品鉴TODO

    end
    if NpcID ~= nil then
        local NpcData = MapEditDataMgr:GetNpc(NpcID)
        if NpcData ~= nil then
            MarkerParam.ID = NpcID
            MarkerParam.ContentType = 1
            MarkerParam.IconPath = IconPath
            MarkerParam.BirthPoint = NpcData.BirthPoint
            if bIsRemove then
                MarkerParam.BirthPoint = {}
            end
            MarkerParam.MapID = MapID
        end
    end

    return MarkerParam
end

function MapMarkerProviderGoldActivity:OnCreateMarker(Params)
	if self.UIMapID ~= _G.MapMgr:GetUIMapID() then
		return
	end
    local Point = Params.BirthPoint
    local Marker = self:CreateMarker(MapMarkerGoldActiviry, Params.ID, Params)

    local X, Y = MapUtil.GetUIPosByLocation(Point, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)

	return Marker
end

function MapMarkerProviderGoldActivity:GetMarkerType()
	return MapDefine.MapMarkerType.GoldActivity
end

---检测该Npc是否完成了相关任务
function MapMarkerProviderGoldActivity:CheckFinishQuestByNpcID(NpcID)
    local QusetIDList = self:GetQusetIDByNpcID(NpcID)
    if QusetIDList == nil or #QusetIDList < 1 then    -- 本来就没有任务
        return true
    end
    local bFinsihQuest = true
    for _, v in pairs(QusetIDList) do
        local QuestID = v
        local QuestStatus = _G.QuestMgr:GetQuestStatus(QuestID)
        if QuestStatus ~= TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED then -- 不是已完成
            bFinsihQuest = false
        end
    end
    return bFinsihQuest
end

function MapMarkerProviderGoldActivity:GetQusetIDByNpcID(NpcID)
    local Cfg = NpcQuestCfg:FindCfgByKey(NpcID)
    if Cfg == nil then
        return
    end
    return Cfg.StartQuest
end


return MapMarkerProviderGoldActivity