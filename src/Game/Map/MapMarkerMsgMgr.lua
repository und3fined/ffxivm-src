--
-- Author: anypkvcai
-- Date: 2023-04-20 0:08
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local MapDefine = require("Game/Map/MapDefine")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local ProtoCS = require("Protocol/ProtoCS")
local TeamHelper = require("Game/Team/TeamHelper")

local MapMarkerType = MapDefine.MapMarkerType
local MapGameplayType = MapDefine.MapGameplayType

local FLOG_INFO
local EActorType = _G.UE.EActorType


---@class MapMarkerMsgMgr : MgrBase
local MapMarkerMsgMgr = LuaClass(MgrBase)

function MapMarkerMsgMgr:OnInit()

end

function MapMarkerMsgMgr:OnBegin()
	FLOG_INFO = _G.FLOG_INFO
end

function MapMarkerMsgMgr:OnEnd()

end

function MapMarkerMsgMgr:OnShutdown()

end

function MapMarkerMsgMgr:OnRegisterNetMsg()

end

function MapMarkerMsgMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateQuest, self.OnGameEventUpdateQuest)
	self:RegisterGameEvent(EventID.UpdateQuestTrack, self.OnGameEventUpdateQuestTrack)
	self:RegisterGameEvent(EventID.UpdateTrackQuestTarget, self.OnGameEventUpdateTrackQuestTarget)
	self:RegisterGameEvent(EventID.ClearQuest, self.OnGameEventClearQuest)

	self:RegisterGameEvent(EventID.FateUpdate, self.OnGameEventFateUpdate)
	self:RegisterGameEvent(EventID.FateEnd, self.OnGameEventFateEnd)

	self:RegisterGameEvent(EventID.WorldMapUpdatePlacedMaker, self.OnGameEventUpdatePlacedMaker)
	self:RegisterGameEvent(EventID.WorldMapAddPlacedMakers, self.OnGameEventAddPlacedMakers)
	self:RegisterGameEvent(EventID.WorldMapRemovePlacedMakers, self.OnGameEventRemovePlacedMakers)

	self:RegisterGameEvent(EventID.TeamUpdateMember, self.OnGameEventTeamUpdateMember)
	self:RegisterGameEvent(EventID.TeamSceneTeamDataUpdate, self.OnGameEventSceneMemberUpdate)

	self:RegisterGameEvent(EventID.PVPColosseumCheckPointUpdate, self.OnGameEventPVPColosseumCheckPointUpdate)
	self:RegisterGameEvent(EventID.PVPColosseumCrystalStateUpdate, self.OnGameEventPVPColosseumCrystalStateUpdate)

	self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
	self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)

	--self:RegisterGameEvent(EventID.FishNoteNotifyMapInfo, self.OnGameEventFishNoteNotifyMapInfo)
	self:RegisterGameEvent(EventID.FishNoteNotifyChangePointState, self.OnGameEventFishNoteNotifyChangePointState)

	self:RegisterGameEvent(EventID.UpdateGatherPoints, self.OnGameEventUpdateGatherPoints)
	self:RegisterGameEvent(EventID.UpdateNearestGatherPoint, self.OnGameEventUpdateNearestGatherPoint)
	self:RegisterGameEvent(EventID.AddMiniMapGatherPoint, self.OnGameEventAddMiniMapGatherPoint)
	self:RegisterGameEvent(EventID.RemoveMiniMapGatherPoint, self.OnGameEventRemoveMiniMapGatherPoint)
	self:RegisterGameEvent(EventID.AddMiniMapTimeLimitGatherPoint, self.OnGameEventAddMiniMapTimeLimitGatherPoint)
	self:RegisterGameEvent(EventID.RemoveMiniMapTimeLimitGatherPoint, self.OnGameEventRemoveMiniMapTimeLimitGatherPoint)

	self:RegisterGameEvent(EventID.GoldSauserCommMapUpdate, self.OnGameEventPlayStyleUpdate)
	self:RegisterGameEvent(EventID.GoldSauserCommMapEnd, self.OnGameEventPlayStyleEnd)

	self:RegisterGameEvent(EventID.GoldActivityMapUpdate, self.OnGameEventGoldActivityUpdate)
	self:RegisterGameEvent(EventID.GoldActivityMapEnd, self.OnGameEventGoldActivityEnd)

	self:RegisterGameEvent(EventID.LeveQuestMapUpdate, self.OnGameEventLeveQuestUpdate)
	self:RegisterGameEvent(EventID.LeveQuestMapEnd, self.OnGameEventLeveQuestEnd)

	self:RegisterGameEvent(EventID.CrystalActivated, self.OnGameEventCrystalActivated)

	self:RegisterGameEvent(EventID.MapFollowAdd, self.OnGameEventFollowUpdate)
	self:RegisterGameEvent(EventID.MapFollowDelete, self.OnGameEventFollowUpdate)
	self:RegisterGameEvent(EventID.MapFollowUpdate, self.OnGameEventFollowUpdate)
	self:RegisterGameEvent(EventID.MapFollowTargetUpdate, self.OnGameEventFollowTargetUpdate)

	self:RegisterGameEvent(EventID.TeamSceneMarkAddEvent, self.OnGameEventSceneMarkUpdate)
	self:RegisterGameEvent(EventID.TeamSceneMarkRemoveEvent, self.OnGameEventSceneMarkUpdate)
	self:RegisterGameEvent(EventID.TeamSceneMarkPosChangedEvent, self.OnGameEventSceneMarkUpdate)

	self:RegisterGameEvent(EventID.TreasureHuntAddMapMine, self.OnGameEventAddMapMine)
	self:RegisterGameEvent(EventID.TreasureHuntRemoveMapMine, self.OnGameEventRemoveMapMine)
	self:RegisterGameEvent(EventID.TreasureHuntUpdateMapMine, self.OnGameEventUpdateMapMine)
	self:RegisterGameEvent(EventID.TreasureHuntClearMapMine, self.OnGameEventClearMapMine)

	self:RegisterGameEvent(EventID.ChocoboRacerMapUpdate, self.OnGameEventChocoboRacerMapUpdate)
	self:RegisterGameEvent(EventID.ChocoboRacerMapClear, self.OnGameEventChocoboRacerMapClear)
	self:RegisterGameEvent(EventID.ChocoboRaceItemMapUpdate, self.OnGameEventChocoboRaceItemMapUpdate)
	self:RegisterGameEvent(EventID.ChocoboRaceItemMapClear, self.OnGameEventChocoboRaceItemMapClear)

	self:RegisterGameEvent(EventID.EnterTheDetectedTargetRange, self.OnGameEventAddDetectedTarget)
	self:RegisterGameEvent(EventID.ExitTheDetectedTargetRange, self.OnGameEventRemoveDetectedTarget)

	self:RegisterGameEvent(EventID.LoadWildBoxRangeCheckData, self.OnGameEventWildBoxDataUpdate)
	self:RegisterGameEvent(EventID.RemoveWildBoxRangeCheckDataByBoxOpened, self.OnGameEventWildBoxDataUpdate)
	self:RegisterGameEvent(EventID.AetherCurrentSingleActive, self.OnGameEventAetherCurrentDataUpdate)
	self:RegisterGameEvent(EventID.TimeToUpdateMapPointPerfectCond, self.OnGameEventDiscoverNoteDataUpdate)
	self:RegisterGameEvent(EventID.NoteSinglePerfectActive, self.OnGameEventDiscoverNoteDataUpdate)

	self:RegisterGameEvent(EventID.PWorldEntityListSync, self.OnGameEventPWorldEntityListSync)
	self:RegisterGameEvent(EventID.PWorldEntityAdd, self.OnGameEventPWorldEntityAdd)
	self:RegisterGameEvent(EventID.PWorldEntityRemove, self.OnGameEventPWorldEntityRemove)
	self:RegisterGameEvent(EventID.PWorldEntityUpdate, self.OnGameEventPWorldEntityUpdate)
end

function MapMarkerMsgMgr:UpdateProviders(MarkerType, FunctionName, ...)
	local Providers = _G.MapMarkerMgr:GetMarkerProviders(MarkerType)
	if nil == Providers then
		return
	end

	for i = 1, #Providers do
		local Provider = Providers[i]
		local Function = Provider[FunctionName]
		Function(Provider, ...)
	end
end


function MapMarkerMsgMgr:OnGameEventUpdateQuest(Params)
	--FLOG_INFO("MapMarkerMsgMgr:OnGameEventUpdateQuest=%s", table.tostring_block(Params))
	self:UpdateProviders(MapMarkerType.Quest, "UpdateQuest", Params)
	--self:UpdateProviders(MapMarkerType.QuestTarget, "UpdateQuest", Params)
	self:UpdateProviders(MapMarkerType.Tracking, "UpdateQuest")

	-- Quest更新，如果正在追踪要更新表现
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo and FollowInfo.FollowType == MapMarkerType.Quest then
		_G.WorldMapMgr:ShowMapFollowPerformance()
	end
end

function MapMarkerMsgMgr:OnGameEventUpdateQuestTrack(Params)
	--print("MapMarkerMsgMgr:OnGameEventUpdateQuestTrack", table.tostring_block(Params))
	local QuestID = Params.QuestID

	self:UpdateProviders(MapMarkerType.Quest, "TrackQuestChanged", QuestID)
	self:UpdateProviders(MapMarkerType.QuestTarget, "TrackQuestChanged", QuestID)
end

function MapMarkerMsgMgr:OnGameEventUpdateTrackQuestTarget(Params)
	self:UpdateProviders(MapMarkerType.QuestTarget, "TrackQuestChanged")
	self:UpdateProviders(MapMarkerType.Tracking, "TrackQuestChanged")
end

function MapMarkerMsgMgr:OnGameEventClearQuest(Params)
	self:UpdateProviders(MapMarkerType.Quest, "ClearMarkers")
	self:UpdateProviders(MapMarkerType.QuestTarget, "ClearMarkers")
	self:UpdateProviders(MapMarkerType.Tracking, "ClearMarkers")
end


function MapMarkerMsgMgr:OnGameEventFateUpdate(Params)
	if nil == Params then
		return
	end
	--目前在fate结束后，服务器还会发fateUpdte协议，所以客户端屏蔽处理
	if Params.State == ProtoCS.FateState.FateState_Finished then
		return
	end

	self:UpdateProviders(MapMarkerType.Fate, "UpdateMarker", Params.ID, Params)

	-- Fate更新，如果正在追踪要更新表现（比如Fate等待状态和开启状态的目标点坐标会变）
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo and FollowInfo.FollowType == MapMarkerType.Fate and FollowInfo.FollowID == Params.ID then
		if Params.bStateChanged then
			_G.WorldMapMgr:ShowMapFollowPerformance()
			-- 寻路过程中，Fate状态变化，才发起新坐标的寻路。这块容易导致体验异常，和策划讨论，去掉寻路过程修正目标的处理
		end
	end
end

function MapMarkerMsgMgr:OnGameEventFateEnd(Params)
	if nil == Params then
		return
	end
	self:UpdateProviders(MapMarkerType.Fate, "RemoveMarker", Params.ID)

	-- Fate结束，如果正在追踪要取消
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo and FollowInfo.FollowType == MapMarkerType.Fate and FollowInfo.FollowID == Params.ID then
		_G.WorldMapMgr:CancelMapFollow()
	end
end

function MapMarkerMsgMgr:OnGameEventUpdatePlacedMaker(Params)
	self:UpdateProviders(MapMarkerType.Placed, "UpdatePlacedMaker", Params)
end

function MapMarkerMsgMgr:OnGameEventAddPlacedMakers(Params)
	self:UpdateProviders(MapMarkerType.Placed, "AddPlacedMakers", Params)
end

function MapMarkerMsgMgr:OnGameEventRemovePlacedMakers(Params)
	self:UpdateProviders(MapMarkerType.Placed, "RemovePlacedMakers", Params)
end


function MapMarkerMsgMgr:OnGameEventUpdateGatherPoints(Params)
	--print("MapMarkerMsgMgr:OnGameEventUpdateGatherPoints", table.tostring_block(Params))
	self:UpdateProviders(MapMarkerType.Gather, "UpdateGatherPoints", Params)

	-- 采集数据更新，如果正在追踪要更新表现，包括追踪和寻路
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo and FollowInfo.FollowType == MapMarkerType.WorldMapGather then
		_G.WorldMapMgr:ShowMapFollowPerformance()
		-- 回滚，可能导致未考虑到的异常问题
		--_G.WorldMapMgr:ReStartMapFollowAutoPath()
	end
end

function MapMarkerMsgMgr:OnGameEventUpdateNearestGatherPoint(Params)
	--print("MapMarkerMsgMgr:OnGameEventUpdateNearestGatherPoint", table.tostring_block(Params))
	self:UpdateProviders(MapMarkerType.Gather, "UpdateNearestGather", Params)
end

function MapMarkerMsgMgr:OnGameEventAddMiniMapGatherPoint(Params)
	--print("MapMarkerMsgMgr:OnGameEventAddMiniMapGatherPoint", table.tostring_block(Params))
	self:UpdateProviders(MapMarkerType.Gather, "UpdateMarker", Params.ListID, Params)
end

function MapMarkerMsgMgr:OnGameEventRemoveMiniMapGatherPoint(Params)
	--print("MapMarkerMsgMgr:OnGameEventRemoveMiniMapGatherPoint", table.tostring_block(Params))
	self:UpdateProviders(MapMarkerType.Gather, "RemoveMarker", Params.ListID)
end

function MapMarkerMsgMgr:OnGameEventAddMiniMapTimeLimitGatherPoint(Params)
	self:UpdateProviders(MapMarkerType.Gather, "UpdateMarker", Params.ListID, Params)
end

function MapMarkerMsgMgr:OnGameEventRemoveMiniMapTimeLimitGatherPoint(Params)
	self:UpdateProviders(MapMarkerType.Gather, "RemoveMarker", Params.ListID)
end


function MapMarkerMsgMgr:OnGameEventPlayStyleUpdate(Params)
	self:UpdateProviders(MapMarkerType.PlayStyle, "UpdateMarker",  Params.ID, Params)
end

function MapMarkerMsgMgr:OnGameEventPlayStyleEnd(Params)
	self:UpdateProviders(MapMarkerType.PlayStyle, "RemoveMarker", Params)
end

function MapMarkerMsgMgr:OnGameEventGoldActivityUpdate(Params)
	self:UpdateProviders(MapMarkerType.GoldActivity, "UpdateMarker",  Params.ID, Params)
end

function MapMarkerMsgMgr:OnGameEventGoldActivityEnd(Params)
	self:UpdateProviders(MapMarkerType.GoldActivity, "RemoveMarker", Params)
end

function MapMarkerMsgMgr:OnGameEventLeveQuestUpdate(Params)
	self:UpdateProviders(MapMarkerType.LeveQuest, "UpdateMarker",  Params.ID, Params)
end

function MapMarkerMsgMgr:OnGameEventLeveQuestEnd(Params)
	self:UpdateProviders(MapMarkerType.LeveQuest, "RemoveMarker", Params.ID)
end

function MapMarkerMsgMgr:OnGameEventTeamUpdateMember(Params)
	self:UpdateProviders(MapMarkerType.Teammate, "ClearAndUpdateMarkers")
end

function MapMarkerMsgMgr:OnGameEventSceneMemberUpdate(Params)
	self:UpdateProviders(MapMarkerType.PVPPlayer, "ClearAndUpdateMarkers")
end

function MapMarkerMsgMgr:OnGameEventPVPColosseumCheckPointUpdate(Params)
	self:UpdateProviders(MapMarkerType.PVPCommon, "UpdateColosseumSGMarker")
end

function MapMarkerMsgMgr:OnGameEventPVPColosseumCrystalStateUpdate(Params)
	self:UpdateProviders(MapMarkerType.PVPCommon, "UpdateColosseumCrystalMarker")
end

function MapMarkerMsgMgr:OnGameEventVisionEnter(Params)
	if nil == Params then
		return
	end

	local EntityID = Params.ULongParam1

	if ActorUtil.IsMonster(EntityID) then
		local ResID = Params.IntParam2
		self:UpdateProviders(MapMarkerType.Monster, "OnVisionEnter", EntityID, ResID)
		self:UpdateProviders(MapMarkerType.PVPCommon, "OnVisionEnter", EntityID, ResID)
		return
	end

	-- TODO 等其他标和视野相关记点需求确认了，看看能否统一处理
	local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID)
	if TeamHelper.GetTeamMgr():IsTeamMemberByEntityID(EntityID)
		or TeamHelper.GetTeamMgr():IsTeamMemberByRoleID(RoleID) then
		self:UpdateProviders(MapMarkerType.Teammate, "OnVisionEnter", EntityID, RoleID)
		return
	end
end

function MapMarkerMsgMgr:OnGameEventVisionLeave(Params)
	if nil == Params then
		return
	end

	local EntityID = Params.ULongParam1
	local ActorType = Params.IntParam1

	if ActorType == EActorType.Monster then
		local ResID = Params.IntParam2
		self:UpdateProviders(MapMarkerType.Monster, "OnVisionLeave", EntityID, ResID)
		self:UpdateProviders(MapMarkerType.PVPCommon, "OnVisionLeave", EntityID, ResID)
		return
	end

	-- TODO 等其他标和视野相关记点需求确认了，看看能否统一处理
	-- 离开视野时已经无法获取RoleID, 无法判断是否队友
	self:UpdateProviders(MapMarkerType.Teammate, "OnVisionLeave", EntityID)
end


--function MapMarkerMsgMgr:OnGameEventFishNoteNotifyMapInfo(MapID, MapInfo)
--	print(table.tostring_block(MapInfo))
--end

function MapMarkerMsgMgr:OnGameEventFishNoteNotifyChangePointState(Params)
	local LocationID = Params
	self:UpdateProviders(MapMarkerType.Fish, "UpdateSelected", LocationID)
end

function MapMarkerMsgMgr:OnGameEventCrystalActivated(Params)
	local CrystalID = Params
	self:UpdateProviders(MapMarkerType.FixPoint, "UpdateCrystalMarker", CrystalID)
end

function MapMarkerMsgMgr:OnGameEventFollowUpdate(Params)
	local FollowInfo = Params
	self:UpdateProviders(FollowInfo.FollowType, "UpdateFollowMarker", FollowInfo)
end

function MapMarkerMsgMgr:OnGameEventFollowTargetUpdate(Params)
	self:UpdateProviders(MapMarkerType.FollowTarget, "ClearAndUpdateMarkers")
end

function MapMarkerMsgMgr:OnGameEventSceneMarkUpdate(Params)
	self:UpdateProviders(MapMarkerType.SceneSign, "UpdateSceneSigns", Params)
end

function MapMarkerMsgMgr:OnGameEventAddMapMine(Param)
	self:UpdateProviders(MapMarkerType.TreasureMine, "AddMapMine", Param)
end

function MapMarkerMsgMgr:OnGameEventRemoveMapMine(Param)
	self:UpdateProviders(MapMarkerType.TreasureMine, "RemoveMapMine", Param)
end

function MapMarkerMsgMgr:OnGameEventUpdateMapMine(Params)
	self:UpdateProviders(MapMarkerType.TreasureMine, "UpdateMapMine", Params)
end

function MapMarkerMsgMgr:OnGameEventClearMapMine(Params)
	self:UpdateProviders(MapMarkerType.TreasureMine, "ClearMapMine", Params)
end

function MapMarkerMsgMgr:OnGameEventChocoboRacerMapUpdate(Params)
	self:UpdateProviders(MapMarkerType.ChocoboRacer, "UpdateAllChocoboRacer", Params)
end

function MapMarkerMsgMgr:OnGameEventChocoboRacerMapClear(Params)
	self:UpdateProviders(MapMarkerType.ChocoboRacer, "ClearChocoboRacerMarkers", Params)
end

function MapMarkerMsgMgr:OnGameEventChocoboRaceItemMapUpdate(Params)
	self:UpdateProviders(MapMarkerType.ChocoboRaceItem, "UpdateAllChocoboRaceItem", Params)
end

function MapMarkerMsgMgr:OnGameEventChocoboRaceItemMapClear(Params)
	self:UpdateProviders(MapMarkerType.ChocoboRaceItem, "ClearChocoboRaceItemMarkers", Params)
end

function MapMarkerMsgMgr:OnGameEventAddDetectedTarget(Params)
	self:UpdateProviders(MapMarkerType.DetectTarget, "AddMarkerInRange", Params)
end

function MapMarkerMsgMgr:OnGameEventRemoveDetectedTarget(Params)
	self:UpdateProviders(MapMarkerType.DetectTarget, "RemoveMarkerOutRange", Params)
	-- 离开范围标记取消
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	local function IsTheMarkerFollowed(FollowInfo, Params)
		if not FollowInfo or not Params then
			return false
		end
		local MarkerType = FollowInfo.FollowType
		if MarkerType ~= MapMarkerType.DetectTarget then
			return false
		end

		local ID = FollowInfo.FollowID
		local MarkerID = Params.MarkerID
		if ID ~= MarkerID then
			return false
		end

		local FollowSubType = FollowInfo.FollowSubType
		if not FollowSubType then
			return false
		end

		local ActorType = FollowSubType
		local ParamActorType = Params.ActorType
		if ActorType ~= ParamActorType then
			return false
		end

		return true
	end
	if IsTheMarkerFollowed(FollowInfo, Params) then
		_G.WorldMapMgr:CancelMapFollow()
	end
end

function MapMarkerMsgMgr:OnGameEventWildBoxDataUpdate(Params)
	self:UpdateProviders(MapMarkerType.Gameplay, "UpdateMarkers", MapGameplayType.WildBox, Params)
end

function MapMarkerMsgMgr:OnGameEventAetherCurrentDataUpdate(Params)
	self:UpdateProviders(MapMarkerType.Gameplay, "UpdateMarkers", MapGameplayType.AetherCurrent, Params)
end

function MapMarkerMsgMgr:OnGameEventDiscoverNoteDataUpdate(Params)
	self:UpdateProviders(MapMarkerType.Gameplay, "UpdateMarkers", MapGameplayType.DiscoverNote, Params)
end

function MapMarkerMsgMgr:OnGameEventPWorldEntityListSync(Params)
	self:UpdateProviders(MapMarkerType.Gameplay, "UpdateMarkers", MapGameplayType.PWorldEntity, Params)
end

function MapMarkerMsgMgr:OnGameEventPWorldEntityAdd(Params)
	self:UpdateProviders(MapMarkerType.Gameplay, "AddPWorldEntity", Params)
end

function MapMarkerMsgMgr:OnGameEventPWorldEntityRemove(Params)
	self:UpdateProviders(MapMarkerType.Gameplay, "RemovePWorldEntity", Params)
end

function MapMarkerMsgMgr:OnGameEventPWorldEntityUpdate(Params)
	self:UpdateProviders(MapMarkerType.Gameplay, "UpdatePWorldEntity", Params)
end


return MapMarkerMsgMgr