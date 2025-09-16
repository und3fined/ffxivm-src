--
-- Author: anypkvcai
-- Date: 2022-12-13 15:14
-- Description: 大地图
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")
local MapDefine = require("Game/Map/MapDefine")
local MajorUtil = require("Utils/MajorUtil")
local MapUtil = require("Game/Map/MapUtil")
local EventID = require("Define/EventID")
local CommonDefine = require("Define/CommonDefine")
local MsgTipsID = require("Define/MsgTipsID")
local EffectUtil = require("Utils/EffectUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local NaviDecalMgr = require("Game/Navi/NaviDecalMgr")
local DataReportUtil = require("Utils/DataReportUtil")
local MathUtil = require("Utils/MathUtil")
local Json = require("Core/Json")

local MapUICfg = require("TableCfg/MapUICfg")
local MapMarkerCfg = require("TableCfg/MapMarkerCfg")
local MapPlacedMarkerCfg = require("TableCfg/MapPlacedMarkerCfg")
local MapIconMappingCfg = require("TableCfg/MapIconMappingCfg")
local MapNpcIconCfg = require("TableCfg/MapNpcIconCfg")

local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local MapMarkerPlaced = require("Game/Map/Marker/MapMarkerPlaced")
local HUDType = require("Define/HUDType")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local AutoMoveTargetType = require("Define/AutoMoveTargetType")
local QuestDefine = require("Game/Quest/QuestDefine")

local MapMarkerType = MapDefine.MapMarkerType
local MapType = MapDefine.MapType
local MapContentType = MapDefine.MapContentType
local MapPlacedMarkerType = ProtoRes.MapPlacedMarkerType
local MapMarkerEventType = ProtoRes.MapMarkerEventType
local MapMarkerTrackType = ProtoRes.MapMarkerTrackType
local ClientSetupKey = ProtoCS.ClientSetupKey
local CS_CMD = ProtoCS.CS_CMD
local MapNPCIconType = ProtoRes.MapNPCIconType

local UE = _G.UE
local FVector = _G.UE.FVector
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

local EventMgr ---@type EventMgr
local ClientSetupMgr ---@type ClientSetupMgr
local BuoyMgr ---@type BuoyMgr
local PWorldMgr ---@type PWorldMgr
local AutoPathMoveMgr ---@type AutoPathMoveMgr


---@class WorldMapMgr : MgrBase
local WorldMapMgr = LuaClass(MgrBase)

function WorldMapMgr:OnInit()
	self.UIMapID = 0
	self.UpperUIMapID = 0
	self.MapID = 0
	self.LastUIMapID = 0

	self.PlacedMarkerPos = nil
	self.PlacedMarkers = {} -- 地图上放置标记列表
	self.PlacedMarkerSetupValue = ""
	self.CheckPlacedMarkerTimerID = nil -- 地图放置标记检查定时器
	self.PlacedMarkerEffectID = nil -- 地图放置标记特效ID

	self.FavorTransfer = {} -- 传送水晶收藏列表

	-- 地图追踪信息
	self.FollowInfo =
	{
		FollowID = 0,
		FollowType = 0,
		FollowSubType = 0,
		FollowUIMapID = 0,
		FollowMapID = 0,
	}
	self.MapFollowBuoyUID = nil -- 地图追踪浮标ID
	self.MapFollowBuoyPos = nil -- 地图追踪浮标坐标，如果目标跨地图则指向传送点，此时非最终目标点
	self.CheckMapFollowTimerID = nil -- 地图追踪检查定时器

	self.OpenMapAutoPath = false -- （已废弃）是否开启地图自动寻路，后面改成寻路模块提供的统一开关

	self.AllMapIconMapping = {} -- 地图图标映射关系
	self.AllUIMapIconMapping = {}
	local AllMapIconMappingCfg = MapIconMappingCfg:FindAllCfg() -- 数据量极少
    for _, Cfg in pairs(AllMapIconMappingCfg) do
		self.AllMapIconMapping[Cfg.MapID] = Cfg
		self.AllUIMapIconMapping[Cfg.UIMapID] = Cfg
    end
end

function WorldMapMgr:OnBegin()
	EventMgr = _G.EventMgr
	ClientSetupMgr = _G.ClientSetupMgr
	BuoyMgr = _G.BuoyMgr
	PWorldMgr = _G.PWorldMgr
	AutoPathMoveMgr = _G.AutoPathMoveMgr
end

function WorldMapMgr:OnEnd()
	self.PlacedMarkerPos = nil
	self.PlacedMarkers = {}
	self.PlacedMarkerSetupValue = ""

	self.FavorTransfer = {}
end

function WorldMapMgr:OnShutdown()

end

function WorldMapMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_NAVMESH, 0, self.OnNetMsgFindPath)
end

function WorldMapMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ClientSetupPost, self.OnGameEventClientSetupPost)
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
	self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldMapExit)
	self:RegisterGameEvent(EventID.PWorldTransBegin, self.OnGameEventPWorldTransBegin)
	self:RegisterGameEvent(EventID.StopAutoPathMove, self.OnGameEventStopAutoPathMove)
end

function WorldMapMgr:OnRegisterTimer()

end

function WorldMapMgr:OnGameEventClientSetupPost(EventParams)
	local IsSet = EventParams.BoolParam1
	if IsSet then
		return
	end

	local RoleID = MajorUtil.GetMajorRoleID()
	if EventParams.ULongParam1 ~= RoleID then
		return
	end

	local SetupKey = EventParams.IntParam1
	local SetupValue = EventParams.StringParam1

	if ClientSetupKey.MapTransferFavor == SetupKey then
		self:ParseMapTransferFavor(SetupValue)
	elseif ClientSetupKey.MapMarkerPlaced == SetupKey then
		self:ParseMapPlacedMarker(SetupValue)
	elseif ClientSetupID.CSMapFollowInfo == SetupKey then
		self:ParseMapFollowInfo(SetupValue)
	end
end

function WorldMapMgr:OnGameEventPWorldMapEnter(Params)
	if MapUtil.IsSpecialPWorldMap(PWorldMgr:GetCurrMapResID()) then
		return
	end

	-- 进入地图后，判断是否显示地图追踪表现
	self:ClearMapFollowPerformance()
	self:ShowMapFollowPerformance()
	self:UpdateMapAutoPathMove()

	self:PlayPlacedMarkerSenceEffect()
	self:CheckEnablePlacedMarkerTimer()
	self:CheckEnableMapFollowTimer()
end

function WorldMapMgr:OnGameEventPWorldMapExit(Params)
	self:ResetUIMapInfo()
	self:StopPlacedMarkerSenceEffect()
end

function WorldMapMgr:OnGameEventPWorldTransBegin(IsOnlyChangeLocation)
	if IsOnlyChangeLocation then
		-- 只是位置改变，不会走PWorldMapEnter逻辑
		self:OnGameEventPWorldMapEnter()
	end
end

function WorldMapMgr:OnGameEventStopAutoPathMove(Params)
	self:ClearMapAutoPathMoveData()
end


--region 大地图打开

---打开当前主角所在的大地图，并以主角标记为中心。目前用于从小地图打开大地图
function WorldMapMgr:ShowCurrWorldMap()
	if _G.ChocoboRaceMgr:IsChocoboRacePWorld() then
		return
	end

	WorldMapVM.MapOpenSource = MapDefine.MapOpenSource.MiniMap
	local Params = { ContentType = MapContentType.WorldMap, MarkerType = MapMarkerType.Major, MarkerID = 0, }
	UIViewMgr:ShowView(UIViewID.WorldMapPanel, Params)
end

---打开指定大地图
---@param MapID number 地图ID
---@param OpenSource number 地图打开来源，可以nil，目前主要数据打点使用
function WorldMapMgr:ShowWorldMap(MapID, OpenSource)
	if UIViewMgr:IsViewVisible(UIViewID.WorldMapPanel) then
		local UIMapID = MapUtil.GetUIMapID(MapID)
		self:ChangeMap(UIMapID, MapID)
	else
		WorldMapVM.MapOpenSource = OpenSource or MapDefine.MapOpenSource.Other
		local Params = { MapID = MapID, ContentType = MapContentType.WorldMap }
		UIViewMgr:ShowView(UIViewID.WorldMapPanel, Params)
	end
end

---打开指定大地图，并找离寻宝点最近的水晶
---@param MapData number 地图打开来源，可以nil，目前主要数据打点使用
function WorldMapMgr:ShowWorldMapTreasureHunt(MapData)
	if MapData == nil then return end

	local MapID = MapData.MapResID
	if UIViewMgr:IsViewVisible(UIViewID.WorldMapPanel) then
		local UIMapID = MapUtil.GetUIMapID(MapID)
		self:ChangeMap(UIMapID, MapID)
	else
		WorldMapVM.MapOpenSource = MapDefine.MapOpenSource.TreasureHunt
		local Params = { MapID = MapID, ContentType = MapContentType.WorldMap, TreasureHuntMapData = MapData }
		UIViewMgr:ShowView(UIViewID.WorldMapPanel, Params)
	end
end

---打开大地图，并以指定采集点为中心
---@param MapID number 地图ID
---@param GatherPointIDList number 采集点ID列表
---@param IsShowMakers bool 是否显示该采集点的位置
function WorldMapMgr:ShowWorldMapGather(MapID, GatherPointIDList)
	self.WorldMapGatherParams = { MapID = MapID, GatherPointIDList = GatherPointIDList}

	WorldMapVM.MapOpenSource = MapDefine.MapOpenSource.GatheringLog
	local Params = { ContentType = MapContentType.WorldMapGather, MapID = MapID, MarkerType = MapMarkerType.WorldMapGather, MarkerID = GatherPointIDList[1].GatherPointID, IsShowMakers = GatherPointIDList[1].IsShowMakers }
	UIViewMgr:ShowView(UIViewID.WorldMapPanel, Params)
end

---打开大地图，显示指定Npc位置，用于地图不常显的Npc
function WorldMapMgr:ShowWorldMapLocationNpc(MapID, NpcResID)
	self.WorldMapLocationParams = { MapID = MapID, MarkerID = NpcResID, LocationType = MapDefine.MapLocationType.Npc }

	WorldMapVM.MapOpenSource = MapDefine.MapOpenSource.MapLocation
	local Params = { ContentType = MapContentType.WorldMapLocation, MapID = MapID, MarkerType = MapMarkerType.WorldMapLocation, MarkerID = NpcResID, MarkerSubType = MapDefine.MapLocationType.Npc }
	UIViewMgr:ShowView(UIViewID.WorldMapPanel, Params)
end

---打开大地图，显示指定EObj位置
function WorldMapMgr:ShowWorldMapLocationEObj(MapID, EObjResID)
	self.WorldMapLocationParams = { MapID = MapID, MarkerID = EObjResID, LocationType = MapDefine.MapLocationType.EObj }

	WorldMapVM.MapOpenSource = MapDefine.MapOpenSource.MapLocation
	local Params = { ContentType = MapContentType.WorldMapLocation, MapID = MapID, MarkerType = MapMarkerType.WorldMapLocation, MarkerID = EObjResID, MarkerSubType = MapDefine.MapLocationType.EObj }
	UIViewMgr:ShowView(UIViewID.WorldMapPanel, Params)
end

---打开大地图，显示指定坐标点位置（占位，未实现）
function WorldMapMgr:ShowWorldMapLocationPoint(MapID, PointID)
	self.WorldMapLocationParams = { MapID = MapID, MarkerID = PointID, LocationType = MapDefine.MapLocationType.Point }

	WorldMapVM.MapOpenSource = MapDefine.MapOpenSource.MapLocation
	local Params = { ContentType = MapContentType.WorldMapLocation, MapID = MapID, MarkerType = MapMarkerType.WorldMapLocation, MarkerID = PointID, MarkerSubType = MapDefine.MapLocationType.Point }
	UIViewMgr:ShowView(UIViewID.WorldMapPanel, Params)
end

---打开大地图，并以指定Npc标记为中心，用于地图常显的Npc
---@param MapID number
---@param NpcResID number 常显的Npc ResID。关卡编辑器里的Npc列表，哪些在地图上常显由策划配表决定
function WorldMapMgr:ShowWorldMapNpc(MapID, NpcResID)
	WorldMapVM.MapOpenSource = MapDefine.MapOpenSource.Other
	local UIMapID = MapUtil.GetUIMapID(MapID)
	self:ShowWorldMapMarker(MapID, UIMapID, MapMarkerType.Npc, NpcResID)
end

---打开大地图，并以指定固定标记为中心
---@param MapID number
---@param MarkerID number 策划表格配置的固定标记ID
---@param UIMapID number
function WorldMapMgr:ShowWorldMapFixPoint(MapID, MarkerID, UIMapID)
	WorldMapVM.MapOpenSource = MapDefine.MapOpenSource.Other
	local RealUIMapID = UIMapID or MapUtil.GetUIMapID(MapID)
	self:ShowWorldMapMarker(MapID, RealUIMapID, MapMarkerType.FixPoint, MarkerID)
end

---打开大地图，并以指定水晶为中心
---@param MapID number
---@param CrystalID number
function WorldMapMgr:ShowWorldMapCrystal(MapID, CrystalID)

	local function FindUIMapIDByCrystalID(UIMapID)
		local MarkerID = MapUtil.GetMapMarkerID(UIMapID)
		local MarkerCfg = MapMarkerCfg:GetMarkerCfgByEventTypeAndArg(MarkerID, MapMarkerEventType.MAP_MARKER_EVENT_TELEPO, CrystalID)
		if MarkerCfg == nil then
			FLOG_INFO("[WorldMapMgr:FindUIMapIDByCrystalID] MarkerCfg is nil, UIMapID=%d, MarkerID=%d, CrystalID=%d", UIMapID, MarkerID, CrystalID)
		end
		return MarkerCfg
	end

	local UIMapID = MapUtil.GetUIMapID(MapID)
	local MarkerCfg = FindUIMapIDByCrystalID(UIMapID)
	if not MarkerCfg then
		if MapID == 12002 then
			-- 乌尔达哈来生回廊地图有两层，查询下政府层
			UIMapID = 73
			MarkerCfg = FindUIMapIDByCrystalID(UIMapID)
		end
	end
	if not MarkerCfg then
		FLOG_ERROR("[WorldMapMgr:ShowWorldMapCrystal] cannot find crystal MarkerCfg, MapID=%d, CrystalID=%d", MapID, CrystalID)
		return
	end
	WorldMapVM.MapOpenSource = MapDefine.MapOpenSource.Other
	self:ShowWorldMapMarker(MapID, UIMapID, MapMarkerType.FixPoint, MarkerCfg.ID)
end

---打开地图并定位附近的鸟房
function WorldMapMgr:ShowWorldMapChocoboStable()
	local MapID = PWorldMgr:GetCurrMapResID()
	local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    if not MapEditCfg then
		return
	end
	local Major = MajorUtil:GetMajor()
	if not Major then
		return
	end
	local MajorPos = Major:FGetLocation(UE.EXLocationType.ServerLoc)
	local MinDistance = 0
	local TargetNapID = 0
	local IsFindChocoboStable = false
    for _, NpcData in pairs(MapEditCfg.NpcList) do
        local CfgMapNpcIcon = MapNpcIconCfg:FindCfgByKey(NpcData.NpcID)
        if CfgMapNpcIcon and CfgMapNpcIcon.NPCIconType == MapNPCIconType.MAP_NPC_ICON_TYPE_CHOCOBO then
            if IsFindChocoboStable then
				local Dist = MathUtil.Dist(MajorPos, NpcData.BirthPoint)
				if Dist < MinDistance then
					MinDistance = Dist
					TargetNapID = NpcData.NpcID
				end
			else
				IsFindChocoboStable = true
				MinDistance = MathUtil.Dist(MajorPos, NpcData.BirthPoint)
				TargetNapID = NpcData.NpcID
			end
        end
    end
	if IsFindChocoboStable then
		local UIMapID = MapUtil.GetUIMapID(MapID)
		self:ShowWorldMapMarker(MapID, UIMapID, MapMarkerType.Npc, TargetNapID)
	else
		--参数按策划要求固定
		self:ShowWorldMapMarker(12004, 21, MapMarkerType.Npc, 1001607)
	end
end

---打开大地图，并以指定标记为中心
---@param MapID number 地图ID
---@param UIMapID number 地图UIMapID
---@param MarkerType number 标记类型
---@param MarkerID number 标记ID
function WorldMapMgr:ShowWorldMapMarker(MapID, UIMapID, MarkerType, MarkerID)
	local Params = { MapID = MapID, UIMapID = UIMapID, ContentType = MapContentType.WorldMap, MarkerType = MarkerType, MarkerID = MarkerID, }
	UIViewMgr:ShowView(UIViewID.WorldMapPanel, Params)
end

function WorldMapMgr:GetWorldMapShowQuestID()
	return self.WorldMapShowQuestID
end

---设置大地图指定显示任务
function WorldMapMgr:SetWorldMapShowQuestID(QuestID)
	self.WorldMapShowQuestID = QuestID
end

---是否大地图指定显示任务，比如推荐任务、职业任务
---指定任务必然显示，不受地图迷雾、地图缩放等影响，和追踪任务类似
---@param QuestID number 任务ID
---@return boolean
function WorldMapMgr:IsWorldMapShowQuest(QuestID)
	local ShowQuestID = self.WorldMapShowQuestID
	return ShowQuestID and QuestID == ShowQuestID
end

---打开大地图，并以指定任务为中心
---@param MapID number 任务要传参MapID
---@param UIMapID number 任务要传参UIMapID。比如乌尔达哈来生回廊/政府层MapID相同，但UIMapID不同
---@param QuestID number 任务ID。如果仅仅是切换地图，可以为nil
---@param TargetID numnber 目标ID
function WorldMapMgr:ShowWorldMapQuest(MapID, UIMapID, QuestID, OpenSource, TargetID)
	if UIMapID == nil then
		UIMapID = MapUtil.GetUIMapID(MapID)
	end

	local MappingMapCfg = self:FindMappingMapCfgByUIMapID(UIMapID)
	if MappingMapCfg and MappingMapCfg.UIMapID ~= _G.MapMgr:GetUIMapID() then
		MapID = MappingMapCfg.MappingMapID
		UIMapID = MappingMapCfg.MappingUIMapID
	end

	self:SetWorldMapShowQuestID(QuestID)

	if UIViewMgr:IsViewVisible(UIViewID.WorldMapPanel) then
		self:ChangeMap(UIMapID, MapID)
    else
		WorldMapVM.MapOpenSource = OpenSource or MapDefine.MapOpenSource.Other
		local Params = { MapID = MapID, UIMapID = UIMapID, ContentType = MapContentType.WorldMap, MarkerType = MapMarkerType.Quest, MarkerID = QuestID, SubID = TargetID }
		UIViewMgr:ShowView(UIViewID.WorldMapPanel, Params)
    end
end

---打开大地图，追踪任务，显示离追踪任务最近的水晶
---@param MapID number
---@param UIMapID number
---@param TrackQuestID number 追踪任务ID
---@param TrackTargetID number 追踪的目标ID
function WorldMapMgr:ShowWorldMapTrackQuest(MapID, UIMapID, TrackQuestID, TrackTargetID)
	if UIMapID == nil then
		UIMapID = MapUtil.GetUIMapID(MapID)
	end

	local MappingMapCfg = self:FindMappingMapCfgByUIMapID(UIMapID)
	-- 地图映射任务：主角已经在目标地图内，查看地图时显示目标地图，否则显示映射地图
	if MappingMapCfg and MappingMapCfg.UIMapID ~= _G.MapMgr:GetUIMapID() then
		MapID = MappingMapCfg.MappingMapID
		UIMapID = MappingMapCfg.MappingUIMapID
	end

	if UIViewMgr:IsViewVisible(UIViewID.WorldMapPanel) then
		self:ChangeMap(UIMapID, MapID)
	else
		WorldMapVM.MapOpenSource = MapDefine.MapOpenSource.QuestTrack
		local Params = { MapID = MapID, UIMapID = UIMapID, ContentType = MapContentType.WorldMap, TrackQuestID = TrackQuestID, TrackTargetID = TrackTargetID }
		UIViewMgr:ShowView(UIViewID.WorldMapPanel, Params)
	end
end

---打开大地图发送标记视图
function WorldMapMgr:ShowSendMarkerView()
	self:ShowWorldMap(_G.MapMgr:GetMapID(), MapDefine.MapOpenSource.ChatSend)
	WorldMapVM:ShowSendMarkerView()
end

---打开大地图发送位置视图
function WorldMapMgr:ShowSendLoctionView()
	self:ShowWorldMap(_G.MapMgr:GetMapID(), MapDefine.MapOpenSource.ChatSend)
	WorldMapVM:ShowSendLoctionView()
end

---根据 地图超链接信息 打开大地图
---@param MapID number
---@param Pos FVector2D
function WorldMapMgr:OpenMapFromChatHyperlink(MapID, Pos)
	WorldMapVM.MapOpenSource = MapDefine.MapOpenSource.Other
	local Params = { MapID = MapID, ContentType = MapContentType.WorldMap, MarkerInitPos = Pos }
	UIViewMgr:ShowView(UIViewID.WorldMapPanel, Params)
end

---关闭大地图;如果是钓鱼笔记/采集笔记开启的寻路，关闭笔记及跳转前的UI
function WorldMapMgr:HideWorldMap()
	if UIViewMgr:IsViewVisible(UIViewID.WorldMapPanel) then
		UIViewMgr:HideView(UIViewID.WorldMapPanel)
	end

	if UIViewMgr:IsViewVisible(UIViewID.GatheringLogMainPanelView) or UIViewMgr:IsViewVisible(UIViewID.FishInghole) then
		_G.UIViewMgr:HideAllUIByLayer() -- 默认关闭所有 Normal 的界面
	end
end

--endregion 大地图打开


--region 地图放置标记

function WorldMapMgr:SendAddPlacedMakers(Makers)
	EventMgr:SendEvent(EventID.WorldMapAddPlacedMakers, Makers)
end

function WorldMapMgr:SendRemovePlacedMakers(Makers)
	EventMgr:SendEvent(EventID.WorldMapRemovePlacedMakers, Makers)
end

function WorldMapMgr:SendUpdatePlacedMaker(Maker)
	EventMgr:SendEvent(EventID.WorldMapUpdatePlacedMaker, Maker)
end

---检查是否开启标记检查定时器
function WorldMapMgr:CheckEnablePlacedMarkerTimer()
	local MajorUIMapID = _G.MapMgr:GetUIMapID()

	local Markers = {}
	for i = 1, #self.PlacedMarkers do
		local Marker = self.PlacedMarkers[i]
		if Marker:IsTraceMarker() and Marker:GetAreaUIMapID() == MajorUIMapID then
			table.insert(Markers, Marker)
		end
	end

	-- 当前地图存在追踪标记类型时才开启定时器
	if #Markers > 0 then
		if not self.CheckPlacedMarkerTimerID then
			self.CheckPlacedMarkerTimerID = self:RegisterTimer(self.OnTimerCheckPlacedMarker, 0, 1.0, 0)
		end
	else
		if self.CheckPlacedMarkerTimerID then
			self:UnRegisterTimer(self.CheckPlacedMarkerTimerID)
			self.CheckPlacedMarkerTimerID = nil
		end
	end
end

---定时检查追踪标记
function WorldMapMgr:OnTimerCheckPlacedMarker()
	local Major = MajorUtil:GetMajor()
	if Major == nil then return end
	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)

	local MajorUIMapID = _G.MapMgr:GetUIMapID()
	local MapUICfgItem = MapUICfg:FindCfgByKey(MajorUIMapID)
	if MapUICfgItem == nil then
		return
	end

	for i = #self.PlacedMarkers, 1, -1 do
		local Marker = self.PlacedMarkers[i]
		if Marker:IsTraceMarker() and Marker:GetAreaUIMapID() == MajorUIMapID then
			local UIPosX, UIPosY = Marker:GetAreaMapPos()
			local TargetX, TargetY = MapUtil.ConvertUIPos2Map(UIPosX, UIPosY, MapUICfgItem.OffsetX, MapUICfgItem.OffsetY, MapUICfgItem.Scale, true)
			local TargetPos = FVector(TargetX, TargetY, MajorPos.Z)
			local Distance = FVector.Dist(MajorPos, TargetPos)
			--[[
				使用主角的Z坐标，等于只计算XY平面的距离
				当距离小于给定值后，自动删除该标记
			--]]
			if Distance < CommonDefine.Buoy.CancelTrackDistance then
				self:RemovePlacedMarker(Marker)
				self:SaveMapPlacedMarker()
			end
		end
	end
end

---更新放置标记追踪状态
function WorldMapMgr:UpdatePlacedMarkerFollow()
	for i = 1, #self.PlacedMarkers do
		local Marker = self.PlacedMarkers[i]
		if Marker then
			Marker:UpdateFollow()
		end
	end
end

function WorldMapMgr:RemoveAllPlacedIconMarkers()
	local Makers = {}
	local Marker

	for i = #self.PlacedMarkers, 1, -1 do
		Marker = self.PlacedMarkers[i]
		if Marker:IsIconMarker() then
			if Marker:GetIsFollow() then
				self:CancelMapFollow()
			end
			table.remove(self.PlacedMarkers, i)
			table.insert(Makers, Marker)
		end
	end

	self:SendRemovePlacedMakers(Makers)
	self:CheckEnablePlacedMarkerTimer()
end

function WorldMapMgr:RemoveAllPlacedTraceMarkers()
	local Makers = {}
	local Marker

	for i = #self.PlacedMarkers, 1, -1 do
		Marker = self.PlacedMarkers[i]
		if Marker:IsTraceMarker() then
			if Marker:GetIsFollow() then
				self:CancelMapFollow()
			end
			table.remove(self.PlacedMarkers, i)
			table.insert(Makers, Marker)
		end
	end

	self:SendRemovePlacedMakers(Makers)
	self:CheckEnablePlacedMarkerTimer()
end

function WorldMapMgr:AddPlacedMarker(MarkerID, CfgID, UIMapID, Name, PosX, PosY, bSendEvent)
	if MarkerID == nil or CfgID == nil or UIMapID == nil or PosX == nil or PosY == nil then
		return
	end

	local Cfg = MapPlacedMarkerCfg:FindCfgByKey(CfgID)
	if nil == Cfg then
		return
	end

	local Marker = MapMarkerPlaced.New()
	Marker:SetID(MarkerID)
	Marker:SetUIMapID(UIMapID)
	Marker:SetAreaUIMapID(UIMapID) -- 真正标记的三级地图UIMapID，区别于要显示的UIMapID
	Marker:SetMapID(MapUtil.GetMapID(UIMapID))
	Marker:InitMarker(Cfg, Name, PosX, PosY)

	table.insert(self.PlacedMarkers, Marker)

	if bSendEvent then
		self:SendAddPlacedMakers({ Marker })
	end
	self:CheckEnablePlacedMarkerTimer()

	return Marker
end

function WorldMapMgr:UpdatePlacedMarker(Marker, PlacedMarkerCfg, Name)
	Marker:UpdateMarker(PlacedMarkerCfg, Name)

	self:SendUpdatePlacedMaker(Marker)
end

function WorldMapMgr:ReplacePlacedMarker(Marker, ReplacedMapMarker, Name)
	self:UpdatePlacedMarker(Marker, ReplacedMapMarker:GetPlacedMarkerCfg(), Name)
	self:RemovePlacedMarker(ReplacedMapMarker)
end

function WorldMapMgr:RemovePlacedMarker(Marker)
	if Marker:GetIsFollow() then
		self:CancelMapFollow()
	end

	table.remove_item(self.PlacedMarkers, Marker)

	self:SendRemovePlacedMakers({ Marker })
	self:CheckEnablePlacedMarkerTimer()
end

function WorldMapMgr:GetPlacedMarkers(UIMapID)
	local Markers = {}

	for i = 1, #self.PlacedMarkers do
		local Marker = self.PlacedMarkers[i]
		if Marker:GetUIMapID() == UIMapID then
			table.insert(Markers, Marker)
		-- else
		-- 	if Marker:IsTraceMarker() then
		-- 		table.insert(Markers, Marker)
		-- 	end
		end
	end

	return Markers
end

-- 将放置标记重置回默认数据，避免追踪标记在一二级地图显示后数据出错
function WorldMapMgr:ResetPlacedMarkerUIMapInfo()
	for i = 1, #self.PlacedMarkers do
		local Marker = self.PlacedMarkers[i]
		Marker:SetUIMapID(Marker:GetAreaUIMapID())
		Marker:SetRegionInfo(nil, nil, nil)
	end
end

function WorldMapMgr:GetPlacedTraceMarkers()
	local Markers = {}

	for i = 1, #self.PlacedMarkers do
		local Marker = self.PlacedMarkers[i]
		if Marker:IsTraceMarker() then
			table.insert(Markers, Marker)
		end
	end

	return Markers
end

function WorldMapMgr:GetPlacedIconMarkers()
	local Markers = {}

	for i = 1, #self.PlacedMarkers do
		local Marker = self.PlacedMarkers[i]
		if Marker:IsIconMarker() then
			table.insert(Markers, Marker)
		end
	end

	return Markers
end

function WorldMapMgr:GetPlacedIconMarkerNum()
	local Num = 0
	for i = 1, #self.PlacedMarkers do
		local Marker = self.PlacedMarkers[i]
		if Marker:IsIconMarker() then
			Num = Num + 1
		end
	end

	return Num
end

-- 获取追踪标记最大数量
function WorldMapMgr:GetTraceMarkerTotalNum()
	return #(self:GetTraceMarkerCfgList() or {})
end

function WorldMapMgr:GetPlacedTraceMarkerNum()
	local Num = 0
	for i = 1, #self.PlacedMarkers do
		local Marker = self.PlacedMarkers[i]
		if Marker:IsTraceMarker() then
			Num = Num + 1
		end
	end

	return Num
end

function WorldMapMgr:IsTraceMarkerUsed(CfgID)
	return nil ~= self:FindPlacedMarker(CfgID)
end

function WorldMapMgr:FindPlacedMarker(CfgID)
	for i = 1, #self.PlacedMarkers do
		local Marker = self.PlacedMarkers[i]
		if Marker:GetCfgID() == CfgID then
			return Marker
		end
	end
end

function WorldMapMgr:FindPlacedMarkerByID(ID)
	for i = 1, #self.PlacedMarkers do
		local Marker = self.PlacedMarkers[i]
		if Marker:GetID() == ID then
			return Marker
		end
	end
end

function WorldMapMgr:GetRecommendedTraceMarkerIndex()
	local List = self:GetTraceMarkerCfgList()
	for i = 1, #List do
		local Cfg = List[i]
		if not self:IsTraceMarkerUsed(Cfg.ID) then
			return i, Cfg
		end
	end

	return 1, List[1]
end

-- 获取已经使用的追踪标记列表
function WorldMapMgr:GetTraceMarkerListUsed()
	local List = self:GetTraceMarkerCfgList()
	local UsedList = {}
	for i = 1, #List do
		local Cfg = List[i]
		if self:IsTraceMarkerUsed(Cfg.ID) then
			table.insert(UsedList, Cfg)
		end
	end

	return UsedList
end

local function SortComparison(Left, Right)
	if Left.MarkerIndex ~= Right.MarkerIndex then
		return Left.MarkerIndex < Right.MarkerIndex
	end

	return false
end

function WorldMapMgr:GetTraceMarkerCfgList()
	local SearchConditions = string.format("Type = %d", MapPlacedMarkerType.MAP_PLACED_MARKER_TRACE)
	local MarkerCfgList = MapPlacedMarkerCfg:FindAllCfg(SearchConditions)
	table.sort(MarkerCfgList, SortComparison)
	return MarkerCfgList
end

function WorldMapMgr:GetIconMarkerCfgList()
	local SearchConditions = string.format("Type = %d", MapPlacedMarkerType.MAP_PLACED_MARKER_ICON)
	local MarkerCfgList = MapPlacedMarkerCfg:FindAllCfg(SearchConditions)
	table.sort(MarkerCfgList, SortComparison)
	return MarkerCfgList
end

function WorldMapMgr:ParseMapPlacedMarker(Value)
	if nil ~= self.PlacedMarkers and nil ~= next(self.PlacedMarkers) then
		return
	end

	self.PlacedMarkers = {}

	local Setups = string.split(Value, ";")

	for i = 1, #Setups do
		local MarkerSetup = string.split(Setups[i], ",")
		local ID = tonumber(MarkerSetup[1])
		local CfgID = tonumber(MarkerSetup[2])
		local UIMapID = tonumber(MarkerSetup[3])
		local PosX = tonumber(MarkerSetup[4])
		local PosY = tonumber(MarkerSetup[5])
		self:AddPlacedMarker(ID, CfgID, UIMapID, "", PosX, PosY)
	end

	self:SendAddPlacedMakers(self.PlacedMarkers)
	self.PlacedMarkerSetupValue = Value
end

---保存放置点，目前是实时保存在服务器。后面看能否保存在本地或玩家手动上传到服务器保存
function WorldMapMgr:SaveMapPlacedMarker()
	local MarkerSetups = {}
	for i = 1, #self.PlacedMarkers do
		local Marker = self.PlacedMarkers[i]
		local UIPosX, UIPosY = Marker:GetAreaMapPos()
		local MarkerSetup = string.format("%d,%d,%d,%d,%d", Marker:GetID(), Marker:GetCfgID(), Marker:GetAreaUIMapID(), UIPosX, UIPosY)
		table.insert(MarkerSetups, MarkerSetup)
	end

	local Value = table.concat(MarkerSetups, ";")
	if self.PlacedMarkerSetupValue == Value then
		return
	end
	self.PlacedMarkerSetupValue = Value
	ClientSetupMgr:SendSetReq(ClientSetupKey.MapMarkerPlaced, Value)
end

function WorldMapMgr:SetPlacedMarkerPos(Pos)
	Pos.X = math.modf(Pos.X)
	Pos.Y = math.modf(Pos.Y)
	self.PlacedMarkerPos = Pos
end

function WorldMapMgr:GetPlacedMarkerPos()
	return self.PlacedMarkerPos
end

--endregion 地图放置标记


--region 传送水晶收藏

function WorldMapMgr:GetFavorTransferList()
	return self.FavorTransfer
end

function WorldMapMgr:AddTransferFavor(ID)
	if not self:IsInTransferFavor(ID) then
		table.insert(self.FavorTransfer, ID)
		return true
	end

	return false
end

function WorldMapMgr:RemoveTransferFavor(ID)
	return nil ~= table.remove_item(self.FavorTransfer, ID)
end

function WorldMapMgr:IsInTransferFavor(ID)
	return nil ~= table.find_item(self.FavorTransfer, ID)
end

function WorldMapMgr:ParseMapTransferFavor(Value)
	if nil ~= next(self.FavorTransfer) then
		return
	end

	local JsonStr = Value
	if not string.isnilorempty(JsonStr) then
		self.FavorTransfer = Json.decode(JsonStr) or {}
	end
end

function WorldMapMgr:SaveMapTransferFavor()
	local JsonStr = Json.encode(self.FavorTransfer)

	ClientSetupMgr:SendSetReq(ClientSetupKey.MapTransferFavor, JsonStr)
end

--endregion 传送水晶收藏


--region 大地图切换显示

---设置大地图缩放值
---@param Scale number 缩放值
---@param bScaleByGesture boolean 是否通过手势缩放。通过手势缩放才可以切换地图，滑动条缩放时不切换地图
function WorldMapMgr:OnMapScaleChange(Scale, bScaleByGesture)
	WorldMapVM:SetMapScale(Scale, bScaleByGesture)

	EventMgr:SendEvent(EventID.WorldMapScaleChanged, Scale)
end

function WorldMapMgr:UpdateFog(UIMapID, MapID)
	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		return
	end

	local IsAllActivate = true
	if MapID > 0 then
		IsAllActivate = _G.FogMgr:IsAllActivate(MapID)
	end

	WorldMapVM:SetIsFogAllActivate(IsAllActivate)
	WorldMapVM:SetMapPath(Cfg.Path)
	WorldMapVM:SetMapMaskPath(IsAllActivate and "" or Cfg.MaskPath)
	WorldMapVM:SetDiscoveryFlag(_G.FogMgr:GetFlogFlag(MapID))
end

---切换UI地图
---@param UIMapID number
---@param MapID number
---@param OnShow boolean 是否首次打开地图时切换
---@return boolean 是否切换成功
function WorldMapMgr:ChangeMap(UIMapID, MapID, OnShow)
	if MapID == nil then
		-- 切换地图，如果MapID为nil，则MapID优先使用当前主角所在地图
		if UIMapID == _G.MapMgr:GetUIMapID() then
			MapID = _G.MapMgr:GetMapID()
		else
			MapID = MapUtil.GetMapID(UIMapID)
		end
	end

	if not MapUtil.IsUIMapOpenByVersion(UIMapID) then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(700011)) -- "未知区域，无法探查"
		return
	end
	if UIMapID == self.UIMapID and MapID == self.MapID then
		-- 已经在当前地图，不需要切换，直接触发相关事件
		_G.EventMgr:SendEvent(_G.EventID.WorldMapFinishCreateMarkers)
		_G.EventMgr:SendEvent(_G.EventID.WorldMapFinishChanged)
		return
	end
	if WorldMapVM.ChageMaping then
		-- 正在切换UI地图中
		return
	end
	self.NextUIMapID = UIMapID

	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil ~= Cfg then
		--WorldMapVM:SetMapBackground(Cfg.Background)

		local function FadeOutMapAnimCallback()
			-- 出场动画结束后，才真正切换地图
			self.LastUIMapID = self.UIMapID
			self.UIMapID = UIMapID
			self.UpperUIMapID = MapUtil.GetUpperUIMapID(UIMapID)
			self.MapID = MapID

			self:UpdateFog(UIMapID, MapID)

			if Cfg.MapType == MapType.Area then
				WorldMapVM:ChangeToAreaMap(UIMapID)
			elseif Cfg.MapType == MapType.Region then
				MapUtil.ResetRegionIconUIPosList()
				WorldMapVM:ChangeToRegionMap(UIMapID)
				WorldMapMgr:ReportData(MapDefine.MapReportType.OpenRegionMap, UIMapID)
			elseif Cfg.MapType == MapType.World then
				MapUtil.ResetWorldUIPosList()
				WorldMapVM:ChangeToWorldMap()
				WorldMapMgr:ReportData(MapDefine.MapReportType.OpenWorldMap, UIMapID)
			end
			EventMgr:SendEvent(EventID.WorldMapSelectChanged)
			WorldMapVM.ChageMaping = false
		end

		WorldMapVM.ChageMaping = true
		if OnShow then
			-- 首次打开地图时，直接切地图，避免上次关闭时的地图闪现下
			FadeOutMapAnimCallback()
		else
			-- 正常切地图时，先播放出场动画，等出场动画播放完才真正切地图UIMapID
			-- 出场动画时段内，NextUIMapID表示下一地图，UIMapID还表示当前地图
			self:RegisterTimer(FadeOutMapAnimCallback, WorldMapVM:GetOutMapAnimTime())
			WorldMapVM:PlayOutMapAnim()
			WorldMapVM:PlayFadeOutMapAnim()
		end
	else
		--WorldMapVM:SetMapBackground(nil)
		WorldMapVM:SetIsFogAllActivate(true)
		WorldMapVM:SetMapPath(nil)
		WorldMapVM:SetMapMaskPath(nil)
		WorldMapVM:SetMapTitle("")
		WorldMapVM:SetMapName("")

		EventMgr:SendEvent(EventID.WorldMapSelectChanged)
	end

	return true
end

function WorldMapMgr:GetUIMapID()
	return self.UIMapID
end

function WorldMapMgr:GetLastUIMapID()
	return self.LastUIMapID
end

function WorldMapMgr:GetMapID()
	return self.MapID
end

function WorldMapMgr:GetUpperUIMapID()
	return self.UpperUIMapID
end

function WorldMapMgr:GetNextUIMapID()
	return self.NextUIMapID
end

function WorldMapMgr:ResetUIMapInfo()
	self.UIMapID = 0
	self.UpperUIMapID = 0
	self.NextUIMapID = 0
    self.MapID = 0
	self.LastUIMapID = 0
end

function WorldMapMgr:UpdateDiscovery()
	if self.UIMapID == 0 then
		return
	end

	local MapID = MapUtil.GetMapID(self.UIMapID)
	if _G.FogMgr:IsFlagInit(MapID) then
		local Flag = _G.FogMgr:GetFlogFlag(MapID)
		WorldMapVM:SetDiscoveryFlag(Flag)
		local IsAllActivate = _G.FogMgr:IsAllActivate(MapID)
		WorldMapVM:SetIsFogAllActivate(IsAllActivate)
		if IsAllActivate then
			WorldMapVM:SetMapMaskPath("")
		end
	end
end

--endregion 大地图切换显示


--region 其他

---点击地图坐标发起GM传送
function WorldMapMgr:SendGMTransfer(TargetX, TargetY)
    if TargetX == 0.0 and TargetY == 0.0 then
        return
    end

	local Major = MajorUtil.GetMajor()
    local MajorPos = Major:FGetActorLocation()
	local GroudZ = MajorPos.Z
	local Result, GroudPos = self:GetMapGroudPos(TargetX, TargetY, true)
	if Result then
		GroudZ = GroudPos.Z
	end

	local cmd = string.format("cell move pos %s %s %s", tostring(TargetX), tostring(TargetY), tostring(GroudZ))
	FLOG_INFO(cmd)
	_G.GMMgr:ReqGM(cmd)
end

---获取给定XY位置的贴地坐标
function WorldMapMgr:GetMapGroudPos(TargetX, TargetY, bMultiTrace)
	local OutFloorPoint = FVector()

	local Position = FVector(TargetX, TargetY, 50000)
	local ZOffset = 100000
	local Result = _G.UE.UWorldMgr.Get():GetGroudPosByLineTrace(OutFloorPoint, Position, ZOffset, bMultiTrace or false, false)
	FLOG_INFO("[WorldMapMgr:GetMapGroudPos] Result(%s), Position(%s), ZOffset(%f), OutFloorPoint(%s)", Result, Position, ZOffset, OutFloorPoint)

	if Result and OutFloorPoint.X == 0 and OutFloorPoint.Y == 0 and OutFloorPoint.Z == 0 then
		-- 射线检查结果是默认值，则认为贴地坐标计算失败
		return false
	end
	return Result, OutFloorPoint
end

function WorldMapMgr:ShowDebugInfo(bShowDebugInfo)
	self.bShowDebugInfo = bShowDebugInfo
end

---地图数据打点上报
function WorldMapMgr:ReportData(Type, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	DataReportUtil.ReportSystemFlowData("MapSystemInfo", Type, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
end

---获取地图图标映射关系
function WorldMapMgr:FindMappingMapCfgByMapID(MapID)
	return self.AllMapIconMapping[MapID]
end

function WorldMapMgr:FindMappingMapCfgByUIMapID(UIMapID)
	return self.AllUIMapIconMapping[UIMapID]
end

function WorldMapMgr:FindMappingMapCfgList(MappingMapID, MappingUIMapID)
	local CfgList = nil
	for _, Cfg in pairs(self.AllMapIconMapping) do
		if Cfg.MappingMapID == MappingMapID and Cfg.MappingUIMapID == MappingUIMapID then
			if not CfgList then
				CfgList = {}
			end
			table.insert(CfgList, Cfg)
		end
	end
	return CfgList
end

--endregion


--region 地图追踪

---获取地图追踪信息
function WorldMapMgr:GetMapFollowInfo()
	return self.FollowInfo
end

---设置地图追踪信息
---@param FollowID number 追踪的标记ID。不同标记类型，标记ID含义不同，比如地标点（MapMarker表里的ID）、手动标记点（ID参考MapUtil.GenerateMarkerID）；如果标记ID为0，表示取消追踪
---@param FollowType number 追踪的标记类型
---@param FollowSubType number 追踪的标记子类型
---@param FollowUIMapID number 追踪的UIMapID
---@param FollowMapID number 追踪的MapID。一般地图都可以通过UIMapID查表MapID，任务需要记录本身的MapID
---@param bUpdateInfo boolean 是否只是更新信息，比如断线重登后会用后台数据刷新本地数据
---@param bClicked boolean 是否点击追踪按钮触发的追踪
function WorldMapMgr:SetMapFollowInfo(FollowID, FollowType, FollowSubType, FollowUIMapID, FollowMapID, bUpdateInfo, bClicked)
	local FollowInfo = self.FollowInfo

	local OldFollowInfo
	local OldFollowID = FollowInfo.FollowID
	if OldFollowID and OldFollowID > 0 then
		OldFollowInfo = {}
		OldFollowInfo.FollowID = FollowInfo.FollowID
		OldFollowInfo.FollowType = FollowInfo.FollowType
		OldFollowInfo.FollowSubType = FollowInfo.FollowSubType
		OldFollowInfo.FollowUIMapID = FollowInfo.FollowUIMapID
		OldFollowInfo.FollowMapID = FollowInfo.FollowMapID
	end

	FollowInfo.FollowID = FollowID
	FollowInfo.FollowType = FollowType
	FollowInfo.FollowSubType = FollowSubType or 0
	FollowInfo.FollowUIMapID = FollowUIMapID
	FollowInfo.FollowMapID = FollowMapID

	if bUpdateInfo then
		-- 保证放置标记的追踪状态正确，避免创建放置标记时追踪数据还没获取到的情况，其他类型标记都是在地图显示标记时访问FollowInfo数据
		self:UpdatePlacedMarkerFollow()
	end

	if OldFollowID and OldFollowID > 0 then
		EventMgr:SendEvent(EventID.MapFollowDelete, OldFollowInfo)
		self:ClearMapFollowPerformance(bClicked)
		self:StopPlacedMarkerSenceEffect()
	end

	if FollowID and FollowID > 0 then
		EventMgr:SendEvent(EventID.MapFollowAdd, self.FollowInfo)
		if not bUpdateInfo and MapUtil.IsSpecialPWorldMap(PWorldMgr:GetCurrMapResID()) then
			_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.MapFollowNotSupport)
		else
			self:ShowMapFollowPerformance(bClicked)
			self:PlayPlacedMarkerSenceEffect()

			if not bUpdateInfo then
				self:StartMapFollowAutoPath()
			end
		end
	end

	self:CheckEnableMapFollowTimer()

    _G.QuestMgr.QuestReport:MarkFollowQuestID(FollowID)

	if not bUpdateInfo then
		self:SaveMapFollowInfo()
	end
end

---取消追踪
---@param AutoCancel boolean 是否自动取消追踪，如果是自动取消（比如距离目标很近时），则不应该停止自动寻路，由底层自动寻路自己驱动；只有主动取消追踪才调用停止自动寻路
function WorldMapMgr:CancelMapFollow(AutoCancel)
	self:SetMapFollowInfo(0, 0, 0, 0, 0, nil, true)

	if not AutoCancel then
		self:StopMapAutoPathMove()
	end
end

---分析保存到服务器的地图追踪信息
---@param JsonStr string
function WorldMapMgr:ParseMapFollowInfo(JsonStr)
	local Info = {}
	if not string.isnilorempty(JsonStr) then
		Info = Json.decode(JsonStr) or {}
	end
	--FLOG_INFO("[WorldMapMgr:ParseMapFollowInfo] Info=%s", table_to_string(Info))

	local FollowID = Info.FollowID or 0
	local FollowType = Info.FollowType or 0
	local FollowSubType = Info.FollowSubType or 0
	local FollowUIMapID = Info.FollowUIMapID or 0
	local FollowMapID = Info.FollowMapID or 0

	self:SetMapFollowInfo(FollowID, FollowType, FollowSubType, FollowUIMapID, FollowMapID, true)
end

---地图追踪信息保存到服务器
function WorldMapMgr:SaveMapFollowInfo()
	local FollowInfo = self.FollowInfo
	local JsonStr = Json.encode(FollowInfo)
	--FLOG_INFO("[WorldMapMgr:SaveMapFollowInfo] JsonStr=%s", JsonStr)

	ClientSetupMgr:SendSetReq(ClientSetupID.CSMapFollowInfo, JsonStr)
end


---目标位置获取结果
local MapTargetPosResult =
{
	Success = 1, -- 正确
	Fail_Config = 2, -- 配置问题失败
	Fail_GroudPos_LineTrace = 3, -- 射线检测贴地坐标失败
	Fail_GroudPos_DifferentMap = 4, -- 目标位置不在当前地图
}

---获取地图追踪点的场景地图坐标
---如果需要获取地图追踪点的UI地图坐标，可通过场景坐标转换
---@param NeedGroudPosZ boolean 是否需要贴地Z坐标
---@param ForAutoPath boolean 是否获取自动寻路坐标，比如NPC追踪和寻路的坐标处理有差异
---@return FVector | table, MapTargetPosResult, IsDstPosRejust
function WorldMapMgr:GetMapFollowPos(NeedGroudPosZ, ForAutoPath)
	local FollowUIMapID = self.FollowInfo.FollowUIMapID
	if FollowUIMapID == 0 then
		return
	end
	local FollowMapID = self.FollowInfo.FollowMapID
	if FollowMapID == 0 then
		return
	end
	local MapUICfgItem = MapUICfg:FindCfgByKey(FollowUIMapID)
	if MapUICfgItem == nil then
		return
	end

	local CurrMapID = PWorldMgr:GetCurrMapResID()
	local TargetPos = nil
	local TargetPosResult = MapTargetPosResult.Success
	local IsDstPosRejust = true

	local FollowMarkerType = self.FollowInfo.FollowType
	if FollowMarkerType == MapMarkerType.FixPoint then
		-- 目前测试发现UI坐标转换得的场景坐标，和地图里真实坐标如NPC位置、水晶位置有一点偏差
		local FixPointMarkerID = self.FollowInfo.FollowID
		local MarkerCfg = MapMarkerCfg:FindCfgByKey(FixPointMarkerID)
		if MarkerCfg == nil then
			return
		end
		local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(FollowMapID)
		if MapEditCfg == nil then
			return
		end

		-- 传送水晶通过配置参数来追踪
		if MapMarkerEventType.MAP_MARKER_EVENT_TELEPO == MarkerCfg.EventType then
			local CrystalID = MarkerCfg.EventArg
			local Point = MapUtil.GetTransferCrystalPos(CrystalID)
			if Point then
				TargetPos = FVector(Point.X, Point.Y, Point.Z)
				return TargetPos, TargetPosResult, IsDstPosRejust
			else
				FLOG_INFO("[WorldMapMgr:GetMapFollowPos] cannot find crystal config, CrystalID=%d", CrystalID)
			end
		end

		-- 地标点追踪，为了追踪位置的准确，增加了部分配置
		-- NPC、EObj等可以通过配置参数来追踪
		if MapMarkerTrackType.MAP_MARKER_TRACK_NPC == MarkerCfg.TrackType then
			local NpcListID = MarkerCfg.TrackArg
			local NpcData = _G.MapEditDataMgr:GetNpcByListID(NpcListID, MapEditCfg)
			if NpcData then
				if ForAutoPath then
					-- 如果寻路目标是NPC，生成新的寻路坐标
					TargetPos = _G.NavigationPathMgr.GetNavigationPosByNpcID(FollowMapID, NpcData.NpcID)
					-- 对于NPC目标，不再做寻路通用的终点偏移（避免2个偏移叠加，距离终点太远）
					IsDstPosRejust = false
				else
					local Point = NpcData.BirthPoint
					TargetPos = FVector(Point.X, Point.Y, Point.Z)
				end
				return TargetPos, TargetPosResult, IsDstPosRejust
			else
				FLOG_INFO("[WorldMapMgr:GetMapFollowPos] cannot find npc config, FixPointMarkerID=%d, NpcListID=%d", FixPointMarkerID, NpcListID)
			end

		elseif MapMarkerTrackType.MAP_MARKER_TRACK_EObj == MarkerCfg.TrackType then
			local EObjListID = MarkerCfg.TrackArg
			local Point = MapUtil.GetMapEObjPosByListID(FollowMapID, EObjListID)
			if Point then
				TargetPos = FVector(Point.X, Point.Y, Point.Z)
				return TargetPos, TargetPosResult, IsDstPosRejust
			else
				FLOG_INFO("[WorldMapMgr:GetMapFollowPos] cannot find EObj config, FixPointMarkerID=%d, EObjListID=%d", FixPointMarkerID, EObjListID)
			end
		end

		-- 如果没有配置参数来准确追踪位置，则默认通过UI坐标转换场景坐标
		local TargetX, TargetY = MapUtil.ConvertUIPos2Map(MarkerCfg.PosX, MarkerCfg.PosY, MapUICfgItem.OffsetX, MapUICfgItem.OffsetY, MapUICfgItem.Scale, true)
		TargetPos = FVector(TargetX, TargetY, 0.0)
		if NeedGroudPosZ then
			-- 判断是否当前地图
			if FollowMapID == CurrMapID then
				local Result, GroudPos = self:GetMapGroudPos(TargetX, TargetY, true)
				if Result then
					TargetPos = GroudPos
				else
					TargetPosResult = MapTargetPosResult.Fail_GroudPos_LineTrace
				end
			else
				TargetPosResult = MapTargetPosResult.Fail_GroudPos_DifferentMap
			end
		end

	elseif FollowMarkerType == MapMarkerType.Placed then
		-- 手动标记点
		local PlacedMarkerID = self.FollowInfo.FollowID
		local Marker = self:FindPlacedMarkerByID(PlacedMarkerID)
		if Marker == nil then
			return
		end
        local UIPosX, UIPosY = Marker:GetAreaMapPos()
		local TargetX, TargetY = MapUtil.ConvertUIPos2Map(UIPosX, UIPosY, MapUICfgItem.OffsetX, MapUICfgItem.OffsetY, MapUICfgItem.Scale, true)
		TargetPos = FVector(TargetX, TargetY, 0.0)
		if NeedGroudPosZ then
			-- 判断是否当前地图
			if FollowMapID == CurrMapID then
				local Result, GroudPos = self:GetMapGroudPos(TargetX, TargetY, true)
				if Result then
					TargetPos = GroudPos
				else
					TargetPosResult = MapTargetPosResult.Fail_GroudPos_LineTrace
				end
			else
				TargetPosResult = MapTargetPosResult.Fail_GroudPos_DifferentMap
			end
		end

	elseif FollowMarkerType == MapMarkerType.Fate then
		local FateID = self.FollowInfo.FollowID
		local CurrActiveFateList = _G.FateMgr.CurrActiveFateList
		if CurrActiveFateList and CurrActiveFateList[FateID] then
			TargetPos = CurrActiveFateList[FateID].FateCenter
		else
			TargetPosResult = MapTargetPosResult.Fail_Config
			FLOG_INFO("[WorldMapMgr:GetMapFollowPos] cannot find fate config, FateID=%d", FateID)
		end

	elseif FollowMarkerType == MapMarkerType.Npc or FollowMarkerType == MapMarkerType.LeveQuest then
		local NpcResID = self.FollowInfo.FollowID
		if ForAutoPath then
			TargetPos = _G.NavigationPathMgr.GetNavigationPosByNpcID(FollowMapID, NpcResID)
			IsDstPosRejust = false
		else
			TargetPos = MapUtil.GetMapNpcPosByResID(FollowMapID, NpcResID)
		end

	elseif FollowMarkerType == MapMarkerType.WorldMapGather then
		local GatherResID = self.FollowInfo.FollowID
		TargetPos = MapUtil.GetMapGatherPos(FollowMapID, GatherResID)

	elseif FollowMarkerType == MapMarkerType.WorldMapLocation then
		local ResID = self.FollowInfo.FollowID
		local LocationType = self.FollowInfo.FollowSubType
		if LocationType == MapDefine.MapLocationType.Npc then
			TargetPos = MapUtil.GetMapNpcPosByResID(FollowMapID, ResID)
		elseif LocationType == MapDefine.MapLocationType.EObj then
			TargetPos = MapUtil.GetMapEObjPosByResID(FollowMapID, ResID)
		end

	elseif FollowMarkerType == MapMarkerType.Quest then
		local QuestID = self.FollowInfo.FollowID
		-- 任务这里需要用记录的任务本身的MapID，不能是通过UIMapID查表的MapID，主要是沙之家这种
		local QuestParamList = _G.QuestTrackMgr:GetMapQuestParam(FollowMapID, QuestID, 0)
		if QuestParamList and #QuestParamList > 0 then
			local QuestParam = QuestParamList[1]
			TargetPos = QuestParam.Pos

			if ForAutoPath then
				if QuestParam.NaviType == QuestDefine.NaviType.NpcResID then
					TargetPos = _G.NavigationPathMgr.GetNavigationPosByNpcID(QuestParam.MapID, QuestParam.NaviObjID)
					IsDstPosRejust = false
				end
			end
		else
			TargetPosResult = MapTargetPosResult.Fail_Config
			FLOG_INFO("[WorldMapMgr:GetMapFollowPos] cannot find quest config, QuestID=%d", QuestID)
		end

	elseif FollowMarkerType == MapMarkerType.DetectTarget then
		local GamePlayType = self.FollowInfo.FollowSubType
		local AuthenID = self.FollowInfo.FollowID
		if AuthenID and GamePlayType then
			local RltPos = _G.RangeCheckTriggerMgr:GetLocation(GamePlayType, AuthenID)
			if RltPos then
				TargetPos = FVector(RltPos.X, RltPos.Y, RltPos.Z)
				if not TargetPos then
					TargetPosResult = MapTargetPosResult.Fail_Config
				end
			else
				FLOG_INFO("[WorldMapMgr:GetMapFollowPos] cannot find DetectTarget, AuthenID=%d", AuthenID)
			end
		end

	elseif FollowMarkerType == MapMarkerType.Gameplay then
		local GameplayType = self.FollowInfo.FollowSubType
		local GameplayMarkerID = self.FollowInfo.FollowID
		TargetPos = MapUtil.GetMapGameplayPos(FollowMapID, GameplayType, GameplayMarkerID)

	elseif FollowMarkerType == MapMarkerType.Fish then
		local PlaceID = self.FollowInfo.FollowID
		TargetPos = _G.FishNotesMgr:GetMapFishPos(PlaceID)

	elseif FollowMarkerType == MapMarkerType.Tracking then
		local NpcResID = self.FollowInfo.FollowID
		if ForAutoPath then
			TargetPos = _G.NavigationPathMgr.GetNavigationPosByNpcID(FollowMapID, NpcResID)
			IsDstPosRejust = false
		else
			TargetPos = MapUtil.GetMapNpcPosByResID(FollowMapID, NpcResID)
		end
	end

	if not TargetPos then
		TargetPosResult = MapTargetPosResult.Fail_Config
	end

	return TargetPos, TargetPosResult, IsDstPosRejust
end


---当前地图追踪点的标记类型是Placed
function WorldMapMgr:IsMapFollowPlaced()
	if self.FollowInfo.FollowType == MapMarkerType.Placed then
		return true
	end

	return false
end

---当前地图追踪点的标记UIMap是否当前UIMap，有些地图有多层有多个UIMap
function WorldMapMgr:IsMapFollowCurrUIMap()
	local MajorUIMapID = _G.MapMgr:GetUIMapID()
	if self.FollowInfo.FollowUIMapID == MajorUIMapID then
		return true
	end

	return false
end


---检查是否开启地图追踪定时器
function WorldMapMgr:CheckEnableMapFollowTimer()
	if self.CheckMapFollowTimerID then
		self:UnRegisterTimer(self.CheckMapFollowTimerID)
		self.CheckMapFollowTimerID = nil
	end

	--[[某些地图不同区域要通过码头传送，需要定时刷新追踪
		这类地图包括：拉诺西亚高地，东拉诺西亚，西拉诺西亚
	--]]
	local CurrMapID = PWorldMgr:GetCurrMapResID()
	local TargetMapID = self.FollowInfo.FollowMapID
	local CheckMapIDList =
	{
		13005,
		13006,
		13007,
	}
	if CurrMapID == TargetMapID and table.find_item(CheckMapIDList, CurrMapID) then
		self.CheckMapFollowTimerID = self:RegisterTimer(self.OnTimerCheckMapFollow, 4, 4, 0)
	end
end

---定时检查地图追踪表现
function WorldMapMgr:OnTimerCheckMapFollow()
	self:ShowMapFollowPerformance()
end

---显示地图追踪表现
function WorldMapMgr:ShowMapFollowPerformance(bClicked)
	local Major = MajorUtil.GetMajor()
	if Major == nil then return end
	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	MajorPos = MajorPos + PWorldMgr:GetWorldOriginLocation()

	local TargetPos, TargetPosResult = self:GetMapFollowPos(true)
	if not TargetPos or not TargetPosResult or TargetPosResult == MapTargetPosResult.Fail_Config then
		return
	end
	TargetPos = FVector(TargetPos.X, TargetPos.Y, TargetPos.Z)

	local CurrMapID = PWorldMgr:GetCurrMapResID()
	local TargetMapID = self.FollowInfo.FollowMapID

	FLOG_INFO("[WorldMapMgr:ShowMapFollowPerformance] TargetPos(%s), TargetPosResult=%d, CurrMapID=%d, TargetMapID=%d"
		, TargetPos, TargetPosResult, CurrMapID, TargetMapID)

	-- 寻路目标点，解决跨地图的追踪
	local NavPaths = _G.NavigationPathMgr:FindMapPaths(CurrMapID, MajorPos, TargetMapID, TargetPos)
	if (NavPaths == nil) or (#NavPaths == 0) then
		FLOG_INFO("[WorldMapMgr:ShowMapFollowPerformance] fail find map path")
		return
	end

	if bClicked then
		NaviDecalMgr:SetNaviType(NaviDecalMgr.EGuideType.BigMap)
	end

	local CurrMapPath = NavPaths[1] -- 寻路结果的第一个数据就是当前地图的数据
	local Paths = CurrMapPath.Paths
	if (#NavPaths == 1) and (NavPaths[1].MapID == CurrMapID) and (Paths ~= nil) and (#Paths == 1) then
		-- 目标在当前地图且无需传送
		self:CreateMapFollowBuoy(TargetPos, false, CurrMapID)
		NaviDecalMgr:NaviPathToPos(TargetPos, NaviDecalMgr.EGuideType.BigMap)
	else
		-- 目标跨地图，指向传送点
		local EndPos = Paths[1].EndPos
		local EndVec = FVector(EndPos.X, EndPos.Y, EndPos.Z)

		local AdjacentMapPath = NavPaths[2] -- 跨地图寻路结果的第二个就是下一个地图的数据
		local AdjacentMapID = AdjacentMapPath and AdjacentMapPath.MapID

		self:CreateMapFollowBuoy(EndVec, true, AdjacentMapID)
		NaviDecalMgr:NaviPathToPos(EndVec, NaviDecalMgr.EGuideType.BigMap)
	end
end

---清除地图追踪表现
function WorldMapMgr:ClearMapFollowPerformance(bClick)
	self:RemoveMapFollowBuoy()

	if bClick then
		NaviDecalMgr:CancelNaviType(NaviDecalMgr.EGuideType.BigMap)
	end
end

---创建地图追踪浮标
---@param FollowPos FVector 追踪坐标，如果是跨地图，此坐标是中转传送点的坐标
---@param IsAdjacentMap boolean 是否指向相邻地图
---@param MapID number 浮标指向的地图ID
function WorldMapMgr:CreateMapFollowBuoy(FollowPos, IsAdjacentMap, MapID)
	if self.MapFollowBuoyUID == nil then
		local BuoyUID = BuoyMgr:AddBuoyByPos(FollowPos, HUDType.BuoyMapFollow, IsAdjacentMap, MapID)
		if BuoyUID then
			FLOG_INFO("[WorldMapMgr:CreateMapFollowBuoy] FollowPos(%s), IsAdjacentMap=%s, MapID=%s, BuoyUID=%d", FollowPos, IsAdjacentMap, MapID, BuoyUID)
			self.MapFollowBuoyUID = BuoyUID
		end
	else
		BuoyMgr:UpdateBuoyPos(self.MapFollowBuoyUID, FollowPos, IsAdjacentMap, MapID)
	end

	if self.MapFollowBuoyPos ~= FollowPos then
		self.MapFollowBuoyPos = FollowPos -- 追踪坐标缓存下来，避免小地图追踪标记重复计算坐标
		EventMgr:SendEvent(EventID.MapFollowTargetUpdate)
	end
end

---移除地图追踪浮标
function WorldMapMgr:RemoveMapFollowBuoy()
	self.MapFollowBuoyPos = nil
	EventMgr:SendEvent(EventID.MapFollowTargetUpdate)

    if self.MapFollowBuoyUID then
		FLOG_INFO("[WorldMapMgr:RemoveMapFollowBuoy] BuoyUID=%d", self.MapFollowBuoyUID)
        BuoyMgr:RemoveBuoyByUID(self.MapFollowBuoyUID)
        self.MapFollowBuoyUID = nil
    end
end

function WorldMapMgr:GetMapFollowBuoyPos()
	return self.MapFollowBuoyPos
end


---显示放置标记特效
function WorldMapMgr:PlayPlacedMarkerSenceEffect()
	self:StopPlacedMarkerSenceEffect()

	for i = 1, #self.PlacedMarkers do
		local Marker = self.PlacedMarkers[i]
		if Marker:GetIsFollow()
			and Marker:GetAreaUIMapID() == _G.MapMgr:GetUIMapID() then
			--[[射线检测标记点的Z坐标:
				特效如果穿插到地表，表现上就会跟着相机移动，所以目前是用射线检测的第一个目标（排除天空飞行限制的空气墙），所以特效会显示在桥上、屋顶等
			--]]
			local TargetPos, TargetPosResult = self:GetMapFollowPos(true)
			if not TargetPos or not TargetPosResult or TargetPosResult == MapTargetPosResult.Fail_Config then
				FLOG_INFO("[WorldMapMgr:PlayPlacedMarkerSenceEffect] cannot get map groud pos")
				return
			end
			TargetPos = FVector(TargetPos.X, TargetPos.Y, TargetPos.Z)

			local FXPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Sence/Common/VBP/BP_fld_mark_new_1.BP_fld_mark_new_1_C'"
			local Translation = TargetPos
			local Rotation = _G.UE.FQuat()
			local Scale3D = FVector(3, 3, 1)
			local VfxParameter = _G.UE.FVfxParameter()
			VfxParameter.VfxRequireData.EffectPath = FXPath
			VfxParameter.PlaySourceType = _G.UE.EVFXPlaySourceType.PlaySourceType_WorldMap
			VfxParameter.VfxRequireData.VfxTransform = _G.UE.FTransform(Rotation, Translation, Scale3D)
			self.PlacedMarkerEffectID = EffectUtil.PlayVfx(VfxParameter)

			FLOG_INFO("[WorldMapMgr:PlayPlacedMarkerSenceEffect] TargetPos(%s), PlacedMarkerEffectID=%d", TargetPos, self.PlacedMarkerEffectID)
			return
		end
	end
end

---删除放置标记特效
function WorldMapMgr:StopPlacedMarkerSenceEffect()
	if self.PlacedMarkerEffectID then
		FLOG_INFO("[WorldMapMgr:StopPlacedMarkerSenceEffect] PlacedMarkerEffectID=%d", self.PlacedMarkerEffectID)
		EffectUtil.StopVfx(self.PlacedMarkerEffectID)
		self.PlacedMarkerEffectID = nil
	end
end


---开始地图追踪的自动寻路
function WorldMapMgr:StartMapFollowAutoPath()
	local FollowInfo = self.FollowInfo
	local TargetMapID = FollowInfo.FollowMapID
	if (not self:IsOpenAutoPath(TargetMapID)) then
		return
	end

	local TargetPos, TargetPosResult, IsDstPosRejust = self:GetMapFollowPos(true, true)
	if not TargetPos or not TargetPosResult or TargetPosResult == MapTargetPosResult.Fail_Config then
		return
	end
	TargetPos = FVector(TargetPos.X, TargetPos.Y, TargetPos.Z)
	FLOG_INFO("[WorldMapMgr:StartMapFollowAutoPath] TargetPos(%s), TargetPosResult=%d", TargetPos, TargetPosResult)

	-- 根据追踪的标记类型，设置自动寻路的目标类型，用于自动寻路tlog
	local TargetType = AutoMoveTargetType.Map
	local FollowMarkerType = FollowInfo.FollowType
	if FollowMarkerType == MapMarkerType.WorldMapGather then
		TargetType = AutoMoveTargetType.GatheringLog
	elseif FollowMarkerType == MapMarkerType.Fish then
		TargetType = AutoMoveTargetType.FishNote
	end

	local Result = self:StartMapAutoPathMove(TargetMapID, TargetPos, TargetType, IsDstPosRejust)
	if not Result then
		return
	end
	self.AutoPathTargetPosResult = TargetPosResult

	-- 寻路成功后关闭大地图;如果是钓鱼笔记/采集笔记开启的寻路，关闭笔记及跳转前的UI
	self:HideWorldMap()
end

---重新开始地图追踪的自动寻路
function WorldMapMgr:ReStartMapFollowAutoPath()
	-- 这里要严格限制条件，必须是地图追踪发起的寻路才可以修正寻路，否则会影响任务发起的寻路
	if not self.AutoPathDstMapID or not self.AutoPathDstPos then
		return
	end
	if not AutoPathMoveMgr:IsAutoPathMoving(self.AutoPathDstMapID, self.AutoPathDstPos) then
		return
	end

	local IsAutoPathMovingState = AutoPathMoveMgr:IsAutoPathMovingState()
	if IsAutoPathMovingState then
		AutoPathMoveMgr:StopAutoPathMoving()

		self:StartMapFollowAutoPath()
	end
end

--endregion 地图追踪


--region 地图自动寻路封装

---是否具备寻路条件
function WorldMapMgr:IsOpenAutoPath(DstMapID)
	local CanAutoPathMove = AutoPathMoveMgr:CanAutoPathMoveForMap(DstMapID)
    if not CanAutoPathMove then
        return false
    end

	return true
end

---开始自动寻路。参数含义参考寻路底层接口AutoPathMoveForMapSystem
---@param DstMapID number
---@param DstPos UE.FVector
---@param TargetType TargetType
---@param IsDstPosRejust boolean
---@return boolean 寻路是否成功
function WorldMapMgr:StartMapAutoPathMove(DstMapID, DstPos, TargetType, IsDstPosRejust)
	if not DstMapID or not DstPos then
		return
	end

	if not self:IsOpenAutoPath(DstMapID) then
		return
	end

	local CurrMapID = PWorldMgr:GetCurrMapResID()
	local MajorActor = MajorUtil.GetMajor()
	local MajorPos = MajorActor:FGetActorLocation()

	local Result, MapPathTable = AutoPathMoveMgr:AutoPathMoveForMapSystem(CurrMapID, MajorPos, DstMapID, DstPos, TargetType, IsDstPosRejust)
	if not Result then
		return
	end
	self.AutoPathDstMapID = DstMapID
	self.AutoPathDstPos = DstPos
	self.AllMapPathTable = MapPathTable
	self:DoMapFindPath()
	WorldMapVM.MapAutoPathMoving = true

	return true
end

---停止自动寻路
function WorldMapMgr:StopMapAutoPathMove()
	if not self.AutoPathDstMapID or not self.AutoPathDstPos then
		return
	end
	if not AutoPathMoveMgr:IsAutoPathMoving(self.AutoPathDstMapID, self.AutoPathDstPos) then
		return
	end

	AutoPathMoveMgr:StopAutoPathMoving()
	return true
end

---清理本次自动寻路相关数据
function WorldMapMgr:ClearMapAutoPathMoveData()
	--FLOG_INFO("WorldMapMgr:ClearMapAutoPathMoveData")
	self.AutoPathDstMapID = nil
	self.AutoPathDstPos = nil
	self.AllMapPathTable = nil
	self.CurrentFindPath = nil
	self.AutoPathTargetPosResult = nil
	WorldMapVM.MapAutoPathMoving = false

	EventMgr:SendEvent(EventID.MapAutoPathUpdate)
end

---跨地图寻路，切地图后更新自动寻路
function WorldMapMgr:UpdateMapAutoPathMove()
	if not self.AutoPathDstMapID or not self.AutoPathDstPos then
		return
	end
	if not AutoPathMoveMgr:IsAutoPathMoving(self.AutoPathDstMapID, self.AutoPathDstPos) then
		return
	end

	FLOG_INFO("[WorldMapMgr:UpdateMapAutoPathMove] AutoPathTargetPosResult=%d", self.AutoPathTargetPosResult or 0)
	if self.AutoPathTargetPosResult == MapTargetPosResult.Fail_GroudPos_DifferentMap then
		-- 【特殊处理】某些地图标记类型，比如手动标记点，跨地图寻路目标位置需要重新计算，这里重新发起一次自动寻路
		self:StartMapFollowAutoPath()
	else
		-- 看当前地图是否需要请求导航路径
		self:DoMapFindPath()
	end
end

---当前是否地图自动寻路中，且已经有了寻路路径。用于判断在地图上绘制路径
function WorldMapMgr:IsMapAutoPathMoving()
	if self.AutoPathDstMapID and self.AutoPathDstPos
		and AutoPathMoveMgr:IsAutoPathMoving(self.AutoPathDstMapID, self.AutoPathDstPos)
		and self.AllMapPathTable and self.CurrentFindPath then
		return true
	end

	return false
end

---请求当前地图的移动路径
function WorldMapMgr:DoMapFindPath()
	if not AutoPathMoveMgr:IsAutoPathMoving(self.AutoPathDstMapID, self.AutoPathDstPos) then
		return
	end

	if self.AllMapPathTable == nil then
		return
	end
	local CurrMapID = PWorldMgr:GetCurrMapResID()
	local CurrMapPathList = {}
	for _, MoveData in ipairs(self.AllMapPathTable) do
		if MoveData.MapID == CurrMapID then
			table.insert(CurrMapPathList, MoveData)
		end
	end

	self.CurrentFindPath = nil
	self.FindPathSeqIDList = {}
	self.FindPathRspList = {}
	local UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()

	for _, MoveData in ipairs(CurrMapPathList) do
		local StartPos = FVector(MoveData.SrcPos.X, MoveData.SrcPos.Y, MoveData.SrcPos.Z)
		local EndPos = FVector(MoveData.DstPos.X, MoveData.DstPos.Y, MoveData.DstPos.Z)

		local FindPathSeqID = UMoveSyncMgr:FindPath(StartPos, EndPos)
        table.insert(self.FindPathSeqIDList, FindPathSeqID)
	end
end

function WorldMapMgr:OnNetMsgFindPath(MsgBody)
    local FindPathRsp = MsgBody
	if not FindPathRsp then
		return
	end

	local FindItem, Index = table.find_item(self.FindPathSeqIDList, FindPathRsp.id)
    if (FindItem == nil or Index == nil) then
        return
    end
	table.remove(self.FindPathSeqIDList, Index)

	table.insert(self.FindPathRspList, FindPathRsp)

	-- 当前地图所有路径都返回后才更新路径
	if #self.FindPathSeqIDList == 0 then
		self:UpdateMapMovePath()
	end
end

---更新当前地图路径
function WorldMapMgr:UpdateMapMovePath()
	-- 先按请求id排序
	table.sort(self.FindPathRspList, function(FindPathA, FindPathB)
		return FindPathA.id < FindPathB.id
	end)

	self.CurrentFindPath = {}

	for _, FindPathRsp in ipairs(self.FindPathRspList) do
		local PointNum = #FindPathRsp.NavPoints
		if PointNum <= 1 then
			FLOG_ERROR("[WorldMapMgr:UpdateMapMovePath] server find path fail")
		else
			local WorldOriginLoc = PWorldMgr:GetWorldOriginLocation()
			local NavPointList = self.CurrentFindPath
			for index = 1, PointNum do
				local NavPoint = FindPathRsp.NavPoints[index]
				NavPoint.point_data.X = NavPoint.point_data.X - WorldOriginLoc.X
				NavPoint.point_data.Y = NavPoint.point_data.Y - WorldOriginLoc.Y
				table.insert(NavPointList, NavPoint)
			end
		end
	end

	--print("WorldMapMgr:UpdateMapMovePath", table_to_string(self.CurrentFindPath))
	EventMgr:SendEvent(EventID.MapAutoPathUpdate)
end

---获取UI上路点位置列表
---@param UIMapID number
---@param ScaleX number
---@return UE.TArray<UE.FVector2D>
function WorldMapMgr:GetUIMovePointList(UIMapID, ScaleX)
    local Points = UE.TArray(UE.FVector2D)

    if self.CurrentFindPath then
        local MapID = PWorldMgr:GetCurrMapResID()
        if UIMapID == MapUtil.GetUIMapID(MapID) then
            local Cfg = MapUICfg:FindCfgByKey(UIMapID)
            if Cfg then
                local MapScale = Cfg.Scale
                local MapOffsetX = Cfg.OffsetX
                local MapOffsetY = Cfg.OffsetY

                for i=1, #self.CurrentFindPath do
                    local Point = self.CurrentFindPath[i].point_data
                    local UIX, UIY = MapUtil.ConvertMapPos2UI(Point.X, Point.Y, MapOffsetX, MapOffsetY, MapScale, true)
                    local X, Y = MapUtil.AdjustMapMarkerPosition(ScaleX, UIX, UIY)
                    Points:Add(UE.FVector2D(X, Y))
                end
            end
        end
    end

    return Points
end

---获取自动移动的进度
---@return number@(0~1)
function WorldMapMgr:GetMoveProgress()
	if self.CurrentFindPath then
		local Major = MajorUtil.GetMajor()
		if not Major then
			return 0
		end
		local UMoveSyncMgr = UE.UMoveSyncMgr:Get()
		local CurrNum = UMoveSyncMgr:GetPathMovedPointsNum()
		local MajorPos = Major:FGetActorLocation()
		local TotalLength = 0
		local MoveLength = 0
		for i=2, #self.CurrentFindPath do
			local LastPoint = self.CurrentFindPath[i-1].point_data
			local CurrPoint = self.CurrentFindPath[i].point_data
			local Distance = UE.FVector(LastPoint.X, LastPoint.Y, LastPoint.Z):Dist2D(UE.FVector(CurrPoint.X, CurrPoint.Y, CurrPoint.Z))
			TotalLength = TotalLength + Distance
			if CurrNum == i then
				local AlreayMove = UE.FVector(LastPoint.X, LastPoint.Y, LastPoint.Z):Dist2D(UE.FVector(MajorPos.X, MajorPos.Y, MajorPos.Z))
				MoveLength = MoveLength + AlreayMove
			elseif i < CurrNum then
				MoveLength = MoveLength + Distance
			end
		end
		if TotalLength == 0 then
			return 0
		end
		return MoveLength / TotalLength
	end
	return 0
end

--endregion 地图自动寻路封装


return WorldMapMgr