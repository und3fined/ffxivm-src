--
-- Author: anypkvcai
-- Date: 2023-03-07 15:38
-- Description:
--


--local LuaClass = require("Core/LuaClass")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerVM = require("Game/Map/MarkerVM/MapMarkerVM")
local MapMarkerQuestVM = require("Game/Map/MarkerVM/MapMarkerQuestVM")
local MapMarkerFishVM = require("Game/Map/MarkerVM/MapMarkerFishVM")
local MapMarkerFateVM = require("Game/Map/MarkerVM/MapMarkerFateVM")
local MapMarkerGatherVM = require("Game/Map/MarkerVM/MapMarkerGatherVM")
local MapMarkerAetherCurrentVM = require("Game/Map/MarkerVM/MapMarkerAetherCurrentVM")
local MapMarkerMineVM = require("Game/Map/MarkerVM/MapMarkerMineVM")
local MapMarkerChocoboRacerVM = require("Game/Map/MarkerVM/MapMarkerChocoboRacerVM")
local MapMarkerGameplayVM = require("Game/Map/MarkerVM/MapMarkerGameplayVM")

local MapMarkerFixedPoint = require("Game/Map/Marker/MapMarkerFixedPoint")

local MapMarkerProviderMajor = require("Game/Map/MarkerProvider/MapMarkerProviderMajor")
local MapMarkerProviderPlaced = require("Game/Map/MarkerProvider/MapMarkerProviderPlaced")
local MapMarkerProviderFixPoint = require("Game/Map/MarkerProvider/MapMarkerProviderFixPoint")
local MapMarkerProviderFate = require("Game/Map/MarkerProvider/MapMarkerProviderFate")
local MapMarkerProviderFateArchive = require("Game/Map/MarkerProvider/MapMarkerProviderFateArchive")
local MapMarkerProviderQuest = require("Game/Map/MarkerProvider/MapMarkerProviderQuest")
local MapMarkerProviderQuestTarget = require("Game/Map/MarkerProvider/MapMarkerProviderQuestTarget")
local MapMarkerProviderTeammate = require("Game/Map/MarkerProvider/MapMarkerProviderTeammate")
local MapMarkerProviderGather = require("Game/Map/MarkerProvider/MapMarkerProviderGather")
local MapMarkerProviderWorldMapGather = require("Game/Map/MarkerProvider/MapMarkerProviderWorldMapGather")
local MapMarkerProviderWorldMapLocation = require("Game/Map/MarkerProvider/MapMarkerProviderWorldMapLocation")
local MapMarkerProviderFish = require("Game/Map/MarkerProvider/MapMarkerProviderFish")
local MapMarkerProviderTelepo = require("Game/Map/MarkerProvider/MapMarkerProviderTelepo")
local MapMarkerProviderPlayStyle = require("Game/Map/MarkerProvider/MapMarkerProviderPlayStyle")
local MapMarkerProviderGoldActivity = require("Game/Map/MarkerProvider/MapMarkerProviderGoldActivity")
local MapMarkerProviderAetherCurrent = require("Game/Map/MarkerProvider/MapMarkerProviderAetherCurrent")
local MapMarkerProviderQuestNpcQuery = require("Game/Map/MarkerProvider/MapMarkerProviderQuestNpcQuery")
local MapMarkerProviderChocoboStable = require("Game/Map/MarkerProvider/MapMarkerProviderChocoboStable")
local MapMarkerProviderChocoboTransportPoint = require("Game/Map/MarkerProvider/MapMarkerProviderChocoboTransportPoint")
local MapMarkerProviderMine = require("Game/Map/MarkerProvider/MapMarkerProviderMine")
local MapMarkerProviderFollowTarget = require("Game/Map/MarkerProvider/MapMarkerProviderFollowTarget")
local MapMarkerProviderChocoboAnim = require("Game/Map/MarkerProvider/MapMarkerProviderChocoboAnim")
local MapMarkerProviderLeveQuest = require("Game/Map/MarkerProvider/MapMarkerProviderLeveQuest")
local MapMarkerProviderNpc = require("Game/Map/MarkerProvider/MapMarkerProviderNpc")
local MapMarkerProviderMonster = require("Game/Map/MarkerProvider/MapMarkerProviderMonster")
local MapMarkerProviderSceneSign = require("Game/Map/MarkerProvider/MapMarkerProviderSceneSign")
local MapMarkerProviderGameplayLocation = require("Game/Map/MarkerProvider/MapMarkerProviderGameplayLocation")
local MapMarkerProviderChocoboRacer = require("Game/Map/MarkerProvider/MapMarkerProviderChocoboRacer")
local MapMarkerProviderChocoboRaceItem = require("Game/Map/MarkerProvider/MapMarkerProviderChocoboRaceItem")
local MapMarkerProviderChocoboWharf = require("Game/Map/MarkerProvider/MapMarkerProviderChocoboWharf")
local MapMarkerProviderChocoboTransferLine = require("Game/Map/MarkerProvider/MapMarkerProviderChocoboTransferLine")
local MapMarkerProviderPVPCommon = require("Game/Map/MarkerProvider/MapMarkerProviderPVPCommon")
local MapMarkerProviderPVPPlayer = require("Game/Map/MarkerProvider/MapMarkerProviderPVPPlayer")
local MapMarkerProviderDetectTarget = require("Game/Map/MarkerProvider/MapMarkerProviderDetectTarget")
local MapMarkerProviderGameplay = require("Game/Map/MarkerProvider/MapMarkerProviderGameplay")
local MapMarkerProviderTracking = require("Game/Map/MarkerProvider/MapMarkerProviderTracking")

local MapMarkerType = MapDefine.MapMarkerType
local ObjectPoolMgr = _G.ObjectPoolMgr


local MapMarkerFactory = {}

---CreateMarkerVM
---@param MarkerType MapMarkerType
---@return MapMarkerVM
function MapMarkerFactory.CreateMarkerVM(MarkerType)
	if MapMarkerType.Quest == MarkerType then
		return MapMarkerQuestVM.New()
	elseif MapMarkerType.Fish == MarkerType then
		return MapMarkerFishVM.New()
	elseif MapMarkerType.Gather == MarkerType or MapMarkerType.WorldMapGather == MarkerType then
		return MapMarkerGatherVM.New()
	elseif MapMarkerType.AetherCurrent == MarkerType then
		return MapMarkerAetherCurrentVM.New()
	elseif MapMarkerType.Fate == MarkerType then
		return MapMarkerFateVM.New()
	elseif MapMarkerType.TreasureMine == MarkerType then
		return MapMarkerMineVM.New()
	elseif MapMarkerType.ChocoboRacer == MarkerType then
		return MapMarkerChocoboRacerVM.New()
	elseif MapMarkerType.ChocoboTransportPoint == MarkerType then
		return MapMarkerQuestVM.New()
	elseif MapMarkerType.Gameplay == MarkerType then
		return MapMarkerGameplayVM.New()
	else
		return MapMarkerVM.New()
		--local MarkerVM = ObjectPoolMgr:AllocObject(MapMarkerVM)
		--MarkerVM:Reset()
		--return MarkerVM
	end
end

function MapMarkerFactory.ReleaseMarkerVM(ViewModel)
	if nil == ViewModel then
		return
	end

	local MarkerType = ViewModel.MapMarker:GetType()
	if MapMarkerType.Quest == MarkerType
		or MapMarkerType.Fish == MarkerType
		or MapMarkerType.Gather == MarkerType
		or MapMarkerType.WorldMapGather == MarkerType
		or MapMarkerType.AetherCurrent == MarkerType
		or MapMarkerType.Fate == MarkerType
		or MapMarkerType.TreasureMine == MarkerType
		or MapMarkerType.ChocoboRacer == MarkerType then
		ViewModel = nil
	else
		--ObjectPoolMgr:FreeObject(MapMarkerVM, ViewModel)
	end
end

function MapMarkerFactory.CreateMarker(MarkerClass)
	local Marker
	if MarkerClass == MapMarkerFixedPoint then
		Marker = ObjectPoolMgr:AllocObject(MapMarkerFixedPoint)
		Marker:Reset() -- 从对象池中取出要重置
	else
		Marker = MarkerClass.New()
	end
	return Marker
end

function MapMarkerFactory.ReleaseMarker(Marker)
	if nil == Marker then
		return
	end

	if Marker:GetType() == MapMarkerType.FixPoint then
		ObjectPoolMgr:FreeObject(MapMarkerFixedPoint, Marker)
	else
		Marker = nil
	end
end

---CreateMarkerProvider
---@param MarkerType MapMarkerType
---@return MapMarkerProvider
function MapMarkerFactory.CreateMarkerProvider(MarkerType)
	if MapMarkerType.Major == MarkerType then
		return MapMarkerProviderMajor.New()
	elseif MapMarkerType.Placed == MarkerType then
		return MapMarkerProviderPlaced.New()
	elseif MapMarkerType.FixPoint == MarkerType then
		return MapMarkerProviderFixPoint.New()
	elseif MapMarkerType.Quest == MarkerType then
		return MapMarkerProviderQuest.New()
	elseif MapMarkerType.QuestTarget == MarkerType then
		return MapMarkerProviderQuestTarget.New()
	elseif MapMarkerType.Teammate == MarkerType then
		return MapMarkerProviderTeammate.New()
	elseif MapMarkerType.PVPCommon == MarkerType then
		return MapMarkerProviderPVPCommon.New()
	elseif MapMarkerType.PVPPlayer == MarkerType then
		return MapMarkerProviderPVPPlayer.New()
	elseif MapMarkerType.Fate == MarkerType then
		return MapMarkerProviderFate.New()
	elseif MapMarkerType.FateArchive == MarkerType then
		return MapMarkerProviderFateArchive.New()
	elseif MapMarkerType.Gather == MarkerType then
		return MapMarkerProviderGather.New()
	elseif MapMarkerType.WorldMapGather == MarkerType then
		return MapMarkerProviderWorldMapGather.New()
	elseif MapMarkerType.WorldMapLocation == MarkerType then
		return MapMarkerProviderWorldMapLocation.New()
	elseif MapMarkerType.Fish == MarkerType then
		return MapMarkerProviderFish.New()
	elseif MapMarkerType.Telepo == MarkerType then
		return MapMarkerProviderTelepo.New()
	elseif MapMarkerType.PlayStyle == MarkerType then
		return MapMarkerProviderPlayStyle.New()
	elseif MapMarkerType.AetherCurrent == MarkerType then
		return MapMarkerProviderAetherCurrent.New()
	elseif MapMarkerType.GoldActivity == MarkerType then
		return MapMarkerProviderGoldActivity.New()
	elseif MapMarkerType.ChocoboStable == MarkerType then
		return MapMarkerProviderChocoboStable.New()
	elseif MapMarkerType.RedPoint == MarkerType then
		return MapMarkerProviderQuestNpcQuery.New()
	elseif MapMarkerType.ChocoboTransportPoint == MarkerType then
		return MapMarkerProviderChocoboTransportPoint.New()
	elseif MapMarkerType.TreasureMine == MarkerType then
		return MapMarkerProviderMine.New()
	elseif MapMarkerType.FollowTarget == MarkerType then
		return MapMarkerProviderFollowTarget.New()
	elseif MapMarkerType.ChocoboAnim == MarkerType then
		return MapMarkerProviderChocoboAnim.New()
	elseif MapMarkerType.LeveQuest == MarkerType then
		return MapMarkerProviderLeveQuest.New()
	elseif MapMarkerType.Npc == MarkerType then
		return MapMarkerProviderNpc.New()
	elseif MapMarkerType.Monster == MarkerType then
		return MapMarkerProviderMonster.New()
	elseif MapMarkerType.SceneSign == MarkerType then
		return MapMarkerProviderSceneSign.New()
	elseif MapMarkerType.GameplayLocation == MarkerType then
		return MapMarkerProviderGameplayLocation.New()
	elseif MapMarkerType.ChocoboRacer == MarkerType then
		return MapMarkerProviderChocoboRacer.New()
	elseif MapMarkerType.ChocoboRaceItem == MarkerType then
		return MapMarkerProviderChocoboRaceItem.New()
	elseif MapMarkerType.ChocoboTransportWharf == MarkerType then
		return MapMarkerProviderChocoboWharf.New()
	elseif MapMarkerType.ChocoboTransportTransferLine == MarkerType then
		return MapMarkerProviderChocoboTransferLine.New()
	elseif MapMarkerType.DetectTarget == MarkerType then
		return MapMarkerProviderDetectTarget.New()
	elseif MapMarkerType.Gameplay == MarkerType then
		return MapMarkerProviderGameplay.New()
	elseif MapMarkerType.Tracking == MarkerType then
		return MapMarkerProviderTracking.New()
	end
end

return MapMarkerFactory