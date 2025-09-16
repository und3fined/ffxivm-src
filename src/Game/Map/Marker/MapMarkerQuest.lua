--
-- Author: anypkvcai
-- Date: 2023-03-29 16:57
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local QuestHelper = require("Game/Quest/QuestHelper")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local MapSetting = require("Game/Map/MapSetting")

local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local QUEST_TYPE = ProtoRes.QUEST_TYPE
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType
local MapMarkerPriority = MapDefine.MapMarkerPriority
local MapConstant = MapDefine.MapConstant


---@class MapMarkerQuest : MapMarker
local MapMarkerQuest = LuaClass(MapMarker)

function MapMarkerQuest:Ctor()
	self.IsTrackQuest = true -- 任务是否追踪状态
	self.Radius = 0 -- 任务范围半径
	self.TargetID = 0 -- 任务TargetID
	self.MapQuestParamClass = nil -- 地图任务原始数据
	self.OverlayPriority = 0 -- 任务图标叠加优先级
end

function MapMarkerQuest:GetType()
	return MapMarkerType.Quest
end

function MapMarkerQuest:GetBPType()
	if self.Radius > 0 then
		if MapUtil.IsWorldMap(self.UIMapID) then
			-- 在一级地图上任务范围圈改为对应任务图标
			return MapMarkerBPType.Quest
		else
			return MapMarkerBPType.QuestRange
		end
	end

	return MapMarkerBPType.Quest
end

function MapMarkerQuest:OnTriggerMapEvent(EventParams)
	_G.FLOG_INFO(string.format("[MapMarkerQuest:OnTriggerMapEvent] %s", self:ToString()))
	local QuestStatus = _G.QuestMgr:GetQuestStatus(self.ID)
	if QuestStatus == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED then
		MapUtil.ShowWorldMapMarkerFollowTips(self, EventParams)
	else
		local QuestCfgitem = QuestHelper.GetQuestCfgItem(self.ID) or {}
		local Params = {
			ChapterID = QuestCfgitem.ChapterID,
			QuestID = self.ID,
			ScreenPosition = EventParams.ScreenPosition,
			EntryMode = 1,
			TargetID = self.TargetID
		}
		_G.WorldMapVM:ShowWorldMapTaskDetailPanel(true, Params)
	end
end

function MapMarkerQuest:IsNameVisible(Scale)
	return false
end

function MapMarkerQuest:IsIconVisible(Scale)
	if self:GetIsTrackQuest() or self:GetIsFollow() then
		return true
	end

	if _G.QuestFaultTolerantMgr:IsFaultTolerantQuest(self.ID) then -- 容错节点始终显示
		return true
	end

	if _G.QuestFaultTolerantMgr:CheckQuestFault(self.ID) then -- 任务失败不显示
		return false
	end

	local QuestType = _G.QuestMgr:GetQuestType(self.ID)
	if QUEST_TYPE.QUEST_TYPE_MAIN == QuestType then
		return true
	end

	local SettingShowType = MapSetting.GetSettingValue(MapSetting.SettingType.QuestType)

	if MapUtil.IsAreaMap(self.UIMapID) and _G.QuestMgr:GetQuestStatus(self.ID) > 0 then --正在进行中的任务
		if SettingShowType == MapSetting.QuestShowType.All then
			return true
		end
	end

	if not _G.FogMgr:IsAllActivate(self.MapID) then
		local InDiscovery = _G.MapAreaMgr:GetDiscoveryIDByLocation(self.Pos.X, self.Pos.Y, self.Pos.Z, self.MapID)
		if InDiscovery and InDiscovery > 0 then -- 有区域数据且不在区域内
			if not _G.FogMgr:IsInFlag(self.MapID, InDiscovery) then
				return false
			end
		end
	end

	if SettingShowType == MapSetting.QuestShowType.All then
		if QUEST_TYPE.QUEST_TYPE_IMPORTANT == QuestType then
			return Scale >= MapConstant.MAP_SCALE_VISIBLE_LEVEL1
		end

		if QUEST_TYPE.QUEST_TYPE_BRANCH == QuestType then
			return Scale >= MapConstant.MAP_SCALE_VISIBLE_LEVEL3
		end
	end

	return false
end

function MapMarkerQuest:GetTipsName()
	return self:GetName()
end

function MapMarkerQuest:GetIsTrackQuest()
	return self.IsTrackQuest
end

function MapMarkerQuest:SetIsTrackQuest(IsTrack)
	self.IsTrackQuest = IsTrack
end

function MapMarkerQuest:GetRadius()
	return self.Radius
end

function MapMarkerQuest:GetSubID()
	return self.TargetID
end

function MapMarkerQuest:GetTargetID()
	return self.TargetID
end

---@param Params MapQuestParamClass
function MapMarkerQuest:InitMarker(Params)
	self:UpdateMarker(Params)
end

---@param Params MapQuestParamClass
function MapMarkerQuest:UpdateMarker(Params)
	self.MapQuestParamClass = Params
	self.TargetID = Params.TargetID
	self.Radius = Params.Radius
	self.Pos = Params.Pos

	self.Name = _G.QuestMgr:GetQuestName(self.ID)
	self:UpdateFollow()
end

function MapMarkerQuest:GetPriority()
	local QuestPriority = MapMarkerPriority.Quest

	if self.OverlayPriority > 0 then
		-- 任务图标叠加优先级
		QuestPriority = QuestPriority + self.OverlayPriority

	else
		-- 非叠加时保持原有逻辑
		local QuestType = _G.QuestMgr:GetQuestType(self.ID)
		if QUEST_TYPE.QUEST_TYPE_MAIN == QuestType then
			-- 主线任务图标需要显示在大水晶之上
			QuestPriority =  MapMarkerPriority.Telepo + 1
		elseif QUEST_TYPE.QUEST_TYPE_IMPORTANT == QuestType then
			-- 重要支线任务比支线任务显示高一级
			QuestPriority = QuestPriority + 1
		end
	end

	return QuestPriority
end

function MapMarkerQuest:SetOverlayPriority(OverlayPriority)
	self.OverlayPriority = OverlayPriority
end

function MapMarkerQuest:IsControlByFog()
	return true
end

function MapMarkerQuest:GetAlpha()
	if not MapUtil.IsAreaMap(self.UIMapID) then
		return 1
	end

	if _G.FogMgr:IsAllActivate(self.MapID) then
		return 1
	end
	local QuestType = _G.QuestMgr:GetQuestType(self.ID)
	if QUEST_TYPE.QUEST_TYPE_MAIN == QuestType or self:GetIsTrackQuest() or self:GetIsFollow() then
		if not self.Pos then
			return 1
		end
		local InDiscovery = _G.MapAreaMgr:GetDiscoveryIDByLocation(self.Pos.X, self.Pos.Y, self.Pos.Z, self.MapID)
		if InDiscovery and InDiscovery > 0 then
			if not _G.FogMgr:IsInFlag(self.MapID, InDiscovery) then
				return 0.5
			end
		end
	end
	return 1
end

return MapMarkerQuest