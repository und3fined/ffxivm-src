local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local QuestDefine = require("Game/Quest/QuestDefine")
local QuestHelper = require("Game/Quest/QuestHelper")
local NaviDecalMgr = require("Game/Navi/NaviDecalMgr")
local BuoyMgr = require("Game/HUD/BuoyMgr")
local MapEditDataMgr = require("Game/PWorld/MapEditDataMgr")
local CrystalPortalMgr = require("Game/PWorld/CrystalPortal/CrystalPortalMgr")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local MapUtil = require("Game/Map/MapUtil")
local CommonDefine = require("Define/CommonDefine")
local NavigationPathMgr = require("Game/PWorld/Navigation/NavigationPathMgr")
local HUDType = require("Define/HUDType")

-- local MapStartnpcCfg = require("TableCfg/MapStartnpcCfg")
local TeleportCrystalCfg = require("TableCfg/TeleportCrystalCfg")

local ProtoRes = require("Protocol/ProtoRes")
local QUEST_TYPE = ProtoRes.QUEST_TYPE

local FVector = _G.UE.FVector
local QuestNaviType = QuestDefine.NaviType
local AddBouyByNaviType = {
	[QuestNaviType.NpcResID] = BuoyMgr.AddBuoyByNpcID,
	[QuestNaviType.EObjResID] = BuoyMgr.AddBuoyByEObjID,
	[QuestNaviType.None] = function() end,
	[QuestNaviType.CrystalID] = BuoyMgr.AddBuoyByCrystalID,
	[QuestNaviType.AreaListID] = BuoyMgr.AddBuoyByArea,
	[QuestNaviType.PointListID] = BuoyMgr.AddBuoyByPoint,
	[QuestNaviType.MonsterListID] = BuoyMgr.AddBuoyByMonsterListID,
}

local MapQuestParamClass = {}
function MapQuestParamClass.New(MapID, QuestID, TargetID, QuestType,
	Pos, Radius, NaviType, NaviObjID, AssistPointID, AssistPos, UIMapID)

	-- 如果uimapid为0填充默认值,不用其他系统再自己处理
	if not UIMapID or UIMapID == 0 then
		UIMapID = MapUtil.GetUIMapID(MapID)
	end
	local Object = {
		MapID = MapID, QuestID = QuestID, TargetID = TargetID, QuestType = QuestType,
		Pos = Pos, Radius = Radius,
		NaviType = NaviType, NaviObjID = NaviObjID or 0,
		AssistPointID = AssistPointID, AssistPos = AssistPos,
		UIMapID = UIMapID,
	}
	-- setmetatable(Object, { __index = MapQuestParamClass })
	return Object
end

local NaviItemClass = {}
function NaviItemClass.New(MapID, Pos, BuoyPos, NaviType, NaviObjID, TargetID)
	local Object = {
		MapID = MapID,
		Pos = Pos,
		BuoyPos = BuoyPos,
		NaviType = NaviType,
		NaviObjID = NaviObjID or 0,
		TargetID = TargetID,
	}
	-- setmetatable(Object, { __index = NaviItemClass })
	return Object
end

local StoryMgr = nil

---@class QuestTrackMgr : MgrBase
local QuestTrackMgr = LuaClass(MgrBase)

function QuestTrackMgr:OnInit()
	-- 任务地图导航数据及缓存
	self.MapQuestParams = {} -- defined at MapQuestParamClass
	self.MapQuestParamsCache = {}

	-- 地图所需数据
	self.UpdatedQuestListForEvent = {}
	self.RemovedQuestListForEvent = {}
	self.TrackingParamList = {}
	self.MainlineParamList = {}

	-- 导航功能开关
	self.bSettingEnableNavi = true
	self.bInDungeon = false
	self.bWaitingMapEnter = false

	-- 导航相关
	self.NaviItemList = {} -- defined at NaviItemClass
	self.ChapterVMWaitToNavi = nil
	self.bNaviItemsHidden = false
	self.bNaviItemsCleared = true
	self.TimerID = nil
	self.bFindMapPathFailed = false

	self.QuestBuoyUID = nil
    self.QuestBuoyPos = nil -- 任务追踪浮标坐标，缓存下来供小地图使用，包括跨地图的情况
	self.DelayCreateBuoyParam = nil

	self.CurrNavMapPath = nil --缓存当前客户端寻路到的数据

	self.ForceNaviWhenFirstTime = false --第一次强制刷新

	self.AutoPathTrackChapterID = nil -- 自动寻路追踪的章节ID
end

function QuestTrackMgr:OnBegin()
	StoryMgr = _G.StoryMgr
end

function QuestTrackMgr:OnEnd()
	self:Reset()
end

-- function QuestTrackMgr:OnShutdown()
-- end

-- function QuestTrackMgr:OnRegisterNetMsg()
-- end

function QuestTrackMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldMapExit)
	self:RegisterGameEvent(EventID.PWorldTransBegin, self.OnGameEventPWorldTransBegin)
end

function QuestTrackMgr:OnGameEventPWorldMapEnter(_)
	self.bWaitingMapEnter = false
	self:RemoveQuestBuoy() -- BuoyMgr生命期是level，需要重新创建浮标
	self.bInDungeon = PWorldMgr:CurrIsInDungeon()
	self.bNaviItemsHidden = false
	self.bFindMapPathFailed = false
	if (not self.bNaviItemsCleared) and (not self.bInDungeon) then
		self:SetNaviTimer(true)
	end
end

function QuestTrackMgr:OnGameEventPWorldMapExit(_)
	self:RemoveNaviTimer()
	self:HideNaviItems(true)
	self.bWaitingMapEnter = true
end

function QuestTrackMgr:OnGameEventPWorldTransBegin(_)
	if self.TimerID ~= nil then
		self:QuestNaviPathTick()
	end
end

function QuestTrackMgr:Reset()
	self.MapQuestParams = {}
	self.MapQuestParamsCache = {}

	self.UpdatedQuestListForEvent = {}
	self.RemovedQuestListForEvent = {}
	self.TrackingParamList = {}
	self.MainlineParamList = {}

	self:HideNaviItems()
	self:ClearNaviItems()

	self.AutoPathTrackChapterID = nil
end

-- ==================================================
-- 外部系统接口
-- ==================================================

---@return table
function QuestTrackMgr:GetMapQuestList(MapID)
	local MapQuestList = {}
	for _, QuestParamsList in pairs(self.MapQuestParams[MapID] or {}) do
		for _, Params in pairs(QuestParamsList) do
			table.insert(MapQuestList, Params)
		end
	end
    return MapQuestList
end

---@return table
function QuestTrackMgr:GetTrackingQuestParam()
	return self.TrackingParamList
end

---@return table
function QuestTrackMgr:GetMainlineQuestParam()
	return self.MainlineParamList
end

function QuestTrackMgr:GetMapQuestParam(MapID, QuestID, TargetID)
	local ParamsList = self.MapQuestParams
	if ParamsList[MapID] == nil then return {} end
	if ParamsList[MapID][QuestID] == nil then return {} end

	if TargetID then
		return { ParamsList[MapID][QuestID][TargetID] }
	else
		local RetList = {}
		for _, Params in pairs(ParamsList[MapID][QuestID]) do
			table.insert(RetList, Params)
		end
		return RetList
	end
end

---游戏设置专用，业务逻辑不主动调用
function QuestTrackMgr:SettingEnableNavigation()
	self.bSettingEnableNavi = true
	self:SetNaviTimer()
end

---游戏设置专用，业务逻辑不主动调用
function QuestTrackMgr:SettingDisableNavigation()
	self:RemoveNaviTimer()
	if self.bSettingEnableNavi then
		NaviDecalMgr:CancelNaviType(NaviDecalMgr.EGuideType.Task)
		NaviDecalMgr:HideNaviPath(NaviDecalMgr.EGuideType.Task)
		self.bSettingEnableNavi = false
	end
end

-- ==================================================
-- 地图图标
-- ==================================================

local function GetMapObjInfo(MapEditCfg, NaviType, NaviObjID)
	local Pos = nil
	local Radius = 0

	if NaviType == QuestNaviType.NpcResID then
		local NpcData = MapEditDataMgr:GetNpc(NaviObjID, MapEditCfg)
		if NpcData ~= nil then
			local P = NpcData.BirthPoint
			Pos = FVector(P.X, P.Y, P.Z)
		end

	elseif NaviType == QuestNaviType.EObjResID then
		local EObjData = MapEditDataMgr:GetEObjByResID(NaviObjID, MapEditCfg)
		if EObjData ~= nil then
			local P = EObjData.Point
			Pos = FVector(P.X, P.Y, P.Z)
		end

	elseif NaviType == QuestNaviType.AreaListID then
		local AreaData = MapEditDataMgr:GetArea(NaviObjID, MapEditCfg)
		if AreaData ~= nil then
			if AreaData.Box then
				local P = AreaData.Box.Center
				Pos = FVector(P.X, P.Y, P.Z)
			elseif AreaData.Cylinder then
				local P = AreaData.Cylinder.Start
				Pos = FVector(P.X, P.Y, P.Z)
				Radius = AreaData.Cylinder.Radius
			end
		end

	elseif NaviType == QuestNaviType.CrystalID then
		local TCCfg = TeleportCrystalCfg:FindCfgByKey(NaviObjID)
		if TCCfg ~= nil then
			Pos = FVector(TCCfg.X, TCCfg.Y, TCCfg.Z)
		end

	elseif NaviType == QuestNaviType.PointListID then
		local PointData = MapEditDataMgr:GetMapPoint(NaviObjID, MapEditCfg)
		if PointData ~= nil then
			local P = PointData.Point
			Pos = FVector(P.X, P.Y, P.Z)
		end

	elseif NaviType == QuestNaviType.MonsterListID then
		local MonsterData = MapEditDataMgr:GetMonsterByListID(NaviObjID, MapEditCfg)
		if MonsterData ~= nil then
			local P = MonsterData.BirthPoint
			Pos = FVector(P.X, P.Y, P.Z)
		end
	end

	return Pos, Radius
end

local function UpdateMapQuestParamInternal(MapQuestParams, MapQuestParamsCache, MapEditCfg, MapID, QuestID, TargetID, NaviType, NaviObjID, AssistPointID)
	if not MapEditCfg then
		return
	end
	local Pos, Radius, AssistPos
	Pos, Radius = GetMapObjInfo(MapEditCfg, NaviType, NaviObjID)
	if AssistPointID then
		AssistPos = GetMapObjInfo(MapEditCfg, QuestNaviType.PointListID, AssistPointID)
	end
	if Pos == nil then
		if AssistPos ~= nil then
			Pos = AssistPos
		else
			QuestHelper.PrintQuestWarning("QuestTrackMgr finding object pos failed.\
				MapID %d, QuestID %d, TargetID %d, NaviType %d, NaviObjID %d",
				MapID or 0, QuestID or 0, TargetID or 0, NaviType or 0, NaviObjID or 0)
		end
	end

	if Pos ~= nil then
		local Map = MapQuestParams[MapID]
		if Map then
			local Quests = Map[QuestID]
			if Quests then
				local Target = Quests[TargetID]
				if Target then
					Target.Pos = Pos
					Target.Radius = Radius
					Target.AssistPos = AssistPos
				end
			end
		end
	else
		local MapQuestParam = MapQuestParamClass.New(
        MapID, QuestID, TargetID, nil, Pos, Radius,
		NaviType, NaviObjID, AssistPointID, AssistPos)
		if MapQuestParamsCache[MapID] == nil then
			MapQuestParamsCache[MapID] = {}
		end
		if MapQuestParamsCache[MapID][QuestID] == nil then
			MapQuestParamsCache[MapID][QuestID] = {}
		end
		MapQuestParamsCache[MapID][QuestID][TargetID] = MapQuestParam
	end
end

local function AddMapQuestParamInternal(MapQuestParams, MapQuestParamsCache, MapEditCfg,
	MapID, QuestID, TargetID, QuestType, NaviType, NaviObjID, AssistPointID, UIMapID)

	local bMapEditCfgLoaded = (MapEditCfg ~= nil)
	local Pos, Radius, AssistPos, _
	TargetID = TargetID or 0
	if AssistPointID == 0 then
		AssistPointID = nil
	end

	if bMapEditCfgLoaded then
		Pos, Radius = GetMapObjInfo(MapEditCfg, NaviType, NaviObjID)
		if AssistPointID then
			AssistPos, _ = GetMapObjInfo(MapEditCfg, QuestNaviType.PointListID, AssistPointID)
		end
		if Pos == nil then
			if AssistPos ~= nil then
				Pos = AssistPos
			else
				QuestHelper.PrintQuestWarning("QuestTrackMgr finding object pos failed.\
					MapID %d, QuestID %d, TargetID %d, NaviType %d, NaviObjID %d",
					MapID or 0, QuestID or 0, TargetID or 0, NaviType or 0, NaviObjID or 0)
			end
		end
	end

    local MapQuestParam = MapQuestParamClass.New(
        MapID, QuestID, TargetID, QuestType, Pos, Radius,
		NaviType, NaviObjID, AssistPointID, AssistPos, UIMapID)

	if MapQuestParams[MapID] == nil then
		MapQuestParams[MapID] = {}
	end
	if MapQuestParams[MapID][QuestID] == nil then
		MapQuestParams[MapID][QuestID] = {}
	end
	MapQuestParams[MapID][QuestID][TargetID] = MapQuestParam

	--记录没有赋值追踪信息的任务
	if not bMapEditCfgLoaded or Pos == nil then -- Pos可能为nil，现在有节日EditCfg，有些追踪点是节日里的npc或eobj
		if MapQuestParamsCache[MapID] == nil then
			MapQuestParamsCache[MapID] = {}
		end
		if MapQuestParamsCache[MapID][QuestID] == nil then
			MapQuestParamsCache[MapID][QuestID] = {}
		end
		MapQuestParamsCache[MapID][QuestID][TargetID] = MapQuestParam
	end

	return MapQuestParam
end

local function RemoveMapQuestParamInternal(ParamsList, MapID, QuestID, TargetID)
	if ParamsList[MapID] == nil then return nil end
	if ParamsList[MapID][QuestID] == nil then return nil end

	TargetID = TargetID or 0
	local MapQuestParam = ParamsList[MapID][QuestID][TargetID]
	ParamsList[MapID][QuestID][TargetID] = nil

	if next(ParamsList[MapID][QuestID]) == nil then
		ParamsList[MapID][QuestID] = nil
	end
	if next(ParamsList[MapID]) == nil then
		ParamsList[MapID] = nil
	end

	return MapQuestParam
end

---@param MapID int32
---@param QuestID int32
---@param TargetID int32
---@param NaviType QuestDefine.NaviType
---@param NaviObjID int32
---@param AssistPointID int32
---@param UIMapID int32
---@return table|nil
function QuestTrackMgr:AddMapQuestParam(MapID, QuestID, TargetID, NaviType, NaviObjID, AssistPointID, UIMapID)
	if (MapID == nil) or (MapID == 0) then return nil end

	local MapEditCfg = MapEditDataMgr:GetMapEditCfgByMapID(MapID)

	local QuestType = QuestHelper.GetQuestTypeByQuestID(QuestID)

	local MapQuestParam = AddMapQuestParamInternal(self.MapQuestParams, self.MapQuestParamsCache, MapEditCfg,
		MapID, QuestID, TargetID, QuestType,
		NaviType, NaviObjID, AssistPointID, UIMapID)

	self:OnAddMapQuestParam(MapQuestParam)

	return MapQuestParam
end

function QuestTrackMgr:OnMapEditCfgLoaded(MapEditCfg)
	if MapEditCfg == nil then return end
	local CacheList = self.MapQuestParamsCache
	local MapID = _G.NavigationPathMgr:RejustDynamicMap(MapEditCfg.MapID)
	if MapID ~= MapEditCfg.MapID then
		_G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
		--理论上是需要return
		return
	end
	local CacheInMap = CacheList[MapID]
	if CacheInMap == nil then return end
	self.MapQuestParamsCache[MapID] = nil

	for QuestID, QuestCacheList in pairs(CacheInMap) do
		for TargetID, Params in pairs(QuestCacheList) do
			UpdateMapQuestParamInternal(self.MapQuestParams, self.MapQuestParamsCache, MapEditCfg, MapID, QuestID, TargetID,
				Params.NaviType, Params.NaviObjID, Params.AssistPointID)
		end
	end

	if self.ChapterVMWaitToNavi then
		local VM = self.ChapterVMWaitToNavi
		if self:ValidateQuestParams(VM, true) then
			self.ChapterVMWaitToNavi = nil
			self:NaviToQuest(VM)
		end
	end
end

---@return table|nil
function QuestTrackMgr:RemoveMapQuestParam(MapID, QuestID, TargetID)
	RemoveMapQuestParamInternal(self.MapQuestParamsCache, MapID, QuestID, TargetID)
    local MapQuestParam = RemoveMapQuestParamInternal(self.MapQuestParams, MapID, QuestID, TargetID)

	if MapQuestParam then
		self:OnRemoveMapQuestParam(MapQuestParam)
	end

	return MapQuestParam
end

function QuestTrackMgr:ExtractQuestListForEvent()
	local QuestListForEvent = { self.UpdatedQuestListForEvent, self.RemovedQuestListForEvent }
	self.UpdatedQuestListForEvent = {}
	self.RemovedQuestListForEvent = {}
	return QuestListForEvent
end

local function MapQuestParamEqual(v1, v2)
	return v1.MapID == v2.MapID
		and v1.QuestID == v2.QuestID
		and v1.TargetID == v2.TargetID
end

function QuestTrackMgr:OnAddMapQuestParam(MapQuestParam)
	if MapQuestParam.QuestType == QUEST_TYPE.QUEST_TYPE_MAIN then
		local v, k = table.find_by_predicate(self.MainlineParamList, function(v)
			return MapQuestParamEqual(v, MapQuestParam)
		end)
		if (not v) or (not k) then
			table.insert(self.MainlineParamList, MapQuestParam)
		end
	end
	table.insert(self.UpdatedQuestListForEvent, MapQuestParam)
end

---@return table|nil
function QuestTrackMgr:OnRemoveMapQuestParam(MapQuestParam)
	if MapQuestParam.QuestType == QUEST_TYPE.QUEST_TYPE_MAIN then
		table.array_remove_item_pred(self.MainlineParamList, function(v)
			return MapQuestParamEqual(v, MapQuestParam)
		end)
	end
	table.insert(self.RemovedQuestListForEvent, MapQuestParam)
end

-- ==================================================
-- 任务导航
-- ==================================================

---地图拥有未赋值的任务
---@param MapID number
---@return boolean
function QuestTrackMgr:HasQuestParamsCache(MapID)
	return self.MapQuestParamsCache[MapID] ~= nil
end

---尝试初始化所在地图的任务追踪信息
---@param MapID number
function QuestTrackMgr:TryInitQuestParams(MapID)
	if MapID == nil or MapID == 0 then
		return
	end
	if self:HasQuestParamsCache(MapID) then --兜底,赋值追踪信息
		local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
		if self:HasQuestParamsCache(MapID) then --还存在cache，说明地图已经加载了，再赋值一次追踪信息
			if MapEditCfg then
				self:OnMapEditCfgLoaded(MapEditCfg)
			end
		end
	end
end

---追踪多个目标，并且显示对应的浮标
---@param QuestID int32
---@return boolean
function QuestTrackMgr:NaviToQuest(CurrTrackQuestVM)
	self:ClearNaviItems()
	self.TrackingParamList = {}
	if not CurrTrackQuestVM then
		self:HideNaviItems()
		return true
	end

	local QuestID = CurrTrackQuestVM.QuestID
	if not QuestID then
		QuestHelper.PrintQuestWarning("Navi chapter %d QuestID invalid", CurrTrackQuestVM.ChapterID)
		return false
	end

	if not self:ValidateQuestParams(CurrTrackQuestVM) then
		return false
	end

	self.bNaviItemsHidden = false
	self.bNaviItemsCleared = false

	for MapID, _ in pairs(CurrTrackQuestVM.MapIDList) do
		self:TryInitQuestParams(MapID)
		local MapQuestParam = self.MapQuestParams[MapID][QuestID]
		if MapQuestParam then
			for _, Params in pairs(MapQuestParam) do
				table.insert(self.TrackingParamList, Params)
				-- 相隔地图不显示浮标
				if (Params.Pos ~= nil) then
					local bUseAssistPoint = ((Params.AssistPointID or 0) ~= 0) and (Params.AssistPos ~= nil)

					local NaviItem = NaviItemClass.New(MapID,
						bUseAssistPoint and Params.AssistPos or Params.Pos,
						Params.Pos, -- 浮标不受辅助导航点影响
						bUseAssistPoint and QuestNaviType.PointListID or Params.NaviType,
						bUseAssistPoint and Params.AssistPointID or Params.NaviObjID,
						Params.TargetID)

					table.insert(self.NaviItemList, NaviItem)
				end
			end
		end
	end

	if next(self.NaviItemList) == nil then
		self.bNaviItemsCleared = true
		return false
	end

	if self.bSettingEnableNavi and not self.bWaitingMapEnter then
		NaviDecalMgr:SetNaviType(NaviDecalMgr.EGuideType.Task)
		self:SetNaviTimer(true)
	end
	return true
end

function QuestTrackMgr:ValidateQuestParams(ChapterVMItem, bDontRecordVM)
	local QuestID = ChapterVMItem.QuestID
	local ParamsList = self.MapQuestParams

	for MapID, _ in pairs(ChapterVMItem.MapIDList) do
		local bMapIDNotFound = (ParamsList[MapID] == nil)
		local bQuestIDNotFound = bMapIDNotFound or (ParamsList[MapID][QuestID] == nil)

		if bMapIDNotFound or bQuestIDNotFound then
			if bDontRecordVM ~= true then
				self.ChapterVMWaitToNavi = ChapterVMItem
			end

			local DebugInfo = bMapIDNotFound
				and string.format("MapID %d not found in QuestTrackMgr.MapQuestParams", MapID)
				or string.format("QuestID %d not found at map %d in QuestTrackMgr.MapQuestParams", QuestID, MapID)

			local CacheList = self.MapQuestParamsCache
			local bMapIDNotCached = (CacheList[MapID] == nil)
			local bQuestIDNotCached = bMapIDNotCached or (CacheList[MapID][QuestID] == nil)

			if bMapIDNotCached or bQuestIDNotCached then
				QuestHelper.PrintQuestWarning(DebugInfo)
				_G.FLOG_WARNING(debug.traceback())
				return false
			end

			QuestHelper.PrintQuestInfo("%s%s", DebugInfo, ", waiting")
			return false
		end
	end
	return true
end

function QuestTrackMgr:UpdateQuestBuoy(Pos, IsAdjacentMap, MapID)
	-- BuoyMgr生命期是level，切关卡时可能创建不出来，需要延迟创建
	if not BuoyMgr.bModuleBegin then
		self.DelayCreateBuoyParam = { Pos = Pos, IsAdjacentMap = IsAdjacentMap, MapID = MapID }
		return
	end

	self.DelayCreateBuoyParam = nil

	if Pos == nil then return end

	if self.QuestBuoyUID == nil then
		self.QuestBuoyUID = BuoyMgr:AddBuoyByPos(Pos, HUDType.BuoyQuest, IsAdjacentMap, MapID)
	else
		BuoyMgr:UpdateBuoyPos(self.QuestBuoyUID, Pos, IsAdjacentMap, MapID)
	end

	if self.QuestBuoyPos ~= Pos then
		self.QuestBuoyPos = Pos
		_G.EventMgr:SendEvent(EventID.UpdateTrackQuestTarget)
	end
end

function QuestTrackMgr:QuestNaviPathTick()
	if (not self.bSettingEnableNavi) or self.bFindMapPathFailed then
		return
	end
	local bGamePreventNavi = self.bInDungeon or StoryMgr:SequenceIsPlaying() or MajorUtil.IsMajorDead()
	if not bGamePreventNavi then
		self:NaviPath2NearestTarget()
		self.ForceNaviWhenFirstTime = false
	end
end

function QuestTrackMgr:ForceNaviTick()
	self.ForceNaviWhenFirstTime = true
	self:QuestNaviPathTick()
end

function QuestTrackMgr:SetNaviTimer(bForceNavi)
	if bForceNavi then
		self.ForceNaviWhenFirstTime = true
	end
	if not self.TimerID then
		local TimerID = _G.TimerMgr:AddTimer(self, self.QuestNaviPathTick, 0, CommonDefine.NaviDecal.FindPathReqInterval, 0)
		self.TimerID = TimerID
	else
		self:QuestNaviPathTick()
	end
end

function QuestTrackMgr:RemoveNaviTimer()
	if self.TimerID then
		_G.TimerMgr:CancelTimer(self.TimerID)
		self.TimerID = nil
	end
end

local MapInside = NavigationPathMgr.EMapPathType.MapInside
function QuestTrackMgr:CalcDist(SrcMapID, SrcPos, TargetMapID, TargetPos, NaviType, NaviObjID)
	local NavigationPaths, OverridePos

	if (NaviType == QuestNaviType.NpcResID) and (NaviObjID ~= 0) then
		NavigationPaths, OverridePos = NavigationPathMgr:FindMapPathsForNpcID(SrcMapID, SrcPos, TargetMapID, NaviObjID)
	else
		NavigationPaths = NavigationPathMgr:FindMapPaths(SrcMapID, SrcPos, TargetMapID, TargetPos)
	end

	if NavigationPaths == nil then
		self.bFindMapPathFailed = true
		return 0, {}, nil
	end

	local AllDistance = 0
	for _, MapPath in ipairs(NavigationPaths) do
		if MapPath.Type == MapInside then
			AllDistance = AllDistance + NavigationPathMgr:GetMapPathsDistance(MapPath)
		end
	end

	return AllDistance, NavigationPaths, OverridePos
end

---选取最近的目标，显示地面指引
function QuestTrackMgr:NaviPath2NearestTarget()
	local Major = MajorUtil.GetMajor()
	if Major == nil then return end

	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	MajorPos = MajorPos + PWorldMgr:GetWorldOriginLocation()

	-- === 计算最近距离 ===
	local NearestItem, NavPaths, OverridePos, NearestBuoyPos = self:GetNearestItem(MajorPos)
	if (NearestItem == nil) or (NavPaths == nil) or (#NavPaths == 0) then
		_G.QuestMainVM.QuestTrackVM:SetCurrTrackTarget(nil)
		return
	end

	_G.QuestMainVM.QuestTrackVM:SetCurrTrackTarget(NearestItem)

	-- === 上报寻路，创建浮标 ===

	local Paths = NavPaths[1].Paths
	local CurrMapResID = PWorldMgr:GetCurrMapResID()
	local DefaultMapID = MapUtil.GetDefaultMapID(CurrMapResID)
	if (DefaultMapID or 0) ~= 0 then
		CurrMapResID = DefaultMapID -- 分多个layerset的地图，都按默认地图查找
	end

	local GuildType = NaviDecalMgr.EGuideType.Task
	local ForceType = self.ForceNaviWhenFirstTime and NaviDecalMgr.EForceType.OnceForce or NaviDecalMgr.EForceType.None
		--self.ForceNaviWhenFirstTime and NaviDecalMgr.EGuideType.OnceForce or NaviDecalMgr.EGuideType.Task

	if (#NavPaths == 1) and (NavPaths[1].MapID == CurrMapResID) and (Paths ~= nil) and (#Paths == 1) then
		-- 目标在当前地图且无需传送
		local Pos = NearestItem.Pos

		if (NearestItem.NaviType == QuestNaviType.AreaListID) and (NearestItem.NaviObjID ~= 0) then
			NaviDecalMgr:NaviPathToArea(NearestItem.NaviObjID, GuildType, ForceType)
		else
			NaviDecalMgr:NaviPathToPos(OverridePos or Pos, GuildType, ForceType)
		end

		self.CurrNavMapPath = NavPaths[1]

		self:UpdateQuestBuoy(NearestBuoyPos or NearestItem.BuoyPos, false, CurrMapResID)
	else
		for _, MapPath in ipairs(NavPaths) do
			if MapPath.MapID == CurrMapResID then
				local EndPos = Paths[1].EndPos
				local EndVec = FVector(EndPos.X, EndPos.Y, EndPos.Z)
				NaviDecalMgr:NaviPathToPos(EndVec, GuildType, ForceType)

				local OriginEndPos = Paths[1].OriginEndPos
				local OriginEndVec = nil
				if OriginEndPos then
					OriginEndVec = FVector(OriginEndPos.X, OriginEndPos.Y, OriginEndPos.Z)
				end

				local AdjacentMapPath = NavPaths[2] -- 跨地图寻路结果的第二个就是下一个地图的数据
				local AdjacentMapID = AdjacentMapPath and AdjacentMapPath.MapID

				self.CurrNavMapPath = MapPath

				self:UpdateQuestBuoy(OriginEndVec or EndVec, true, AdjacentMapID)
				break
			end
		end
	end
end

---@return Path OnePath from NavigationPathMgr
function QuestTrackMgr:GetCurrNavPath()
	if self.CurrNavMapPath and self.CurrNavMapPath.Paths then
		return self.CurrNavMapPath.Paths[1]
	else
		return nil
	end
end

---@return MapPath MapPath from NavigationPathMgr
function QuestTrackMgr:GetCurrNavMapPath()
	return self.CurrNavMapPath
end

function QuestTrackMgr:RemoveQuestBuoy()
	if self.QuestBuoyUID then
		BuoyMgr:RemoveBuoyByUID(self.QuestBuoyUID)
		self.QuestBuoyUID = nil
	end
	self.QuestBuoyPos = nil
end

function QuestTrackMgr:HideNaviItems(bNoCancelNaviType)
	if self.bNaviItemsHidden then return end

	if not bNoCancelNaviType then
		NaviDecalMgr:CancelNaviType(NaviDecalMgr.EGuideType.Task)
	end
	
	NaviDecalMgr:HideNaviPath(NaviDecalMgr.EGuideType.Task)

	self:RemoveQuestBuoy()
	_G.EventMgr:SendEvent(EventID.UpdateTrackQuestTarget)

	self.bNaviItemsHidden = true
end

function QuestTrackMgr:ClearNaviItems()
	if self.bNaviItemsCleared then return end

	self.NaviItemList = {}
	self.bNaviItemsCleared = true
	self.bFindMapPathFailed = false

	self:RemoveNaviTimer()

	self.CurrNavMapPath = nil

	_G.QuestMainVM.QuestTrackVM:SetCurrTrackTarget(nil)
end

function QuestTrackMgr:GetNearestItem(MajorPos)
	local NearestItem = nil
	local NavPaths = nil --客户端寻路获取的数据结构
	local OverridePos = nil
	local NearestBuoyPos = nil

	local CurrMapResID = PWorldMgr:GetCurrMapResID()
	local DefaultMapID = MapUtil.GetDefaultMapID(CurrMapResID)
	if (DefaultMapID or 0) ~= 0 then
		CurrMapResID = DefaultMapID -- 分多个layerset的地图，都按默认地图查找
	end

	local MinDist = 1999999999
	local MinBuoyDist = 1999999999
	for i = 1, #self.NaviItemList do
		local NaviItem = self.NaviItemList[i]
		if NaviItem.Pos then
			local Dist, NavigationPaths, OverrideNaviPos =
				self:CalcDist(CurrMapResID, MajorPos, NaviItem.MapID, NaviItem.Pos, NaviItem.NaviType, NaviItem.NaviObjID)
			if Dist > 0 and Dist < MinDist then
				MinDist = Dist
				NearestItem = self.NaviItemList[i]
				NavPaths = NavigationPaths
				OverridePos = OverrideNaviPos
			end
		end
		if NaviItem.BuoyPos and (NaviItem.MapID == CurrMapResID) then
			local Dist = FVector.Dist(MajorPos, NaviItem.BuoyPos)
			if Dist > 0 and Dist < MinBuoyDist then
				MinBuoyDist = Dist
				NearestBuoyPos = NaviItem.BuoyPos
			end
		end
	end

	return NearestItem, NavPaths, OverridePos, NearestBuoyPos
end

-- "GQT" = "GM Quest Teleport"
local GQTQuestID = 0
local GQTPivot = 1
---GM传送至追踪任务目标
---@return string|nil
function QuestTrackMgr:MakeGMQuestTeleportCmd()
	local TrackingParamList = self:GetTrackingQuestParam()
	if next(TrackingParamList) == nil then
		_G.MsgTipsUtil.ShowTips("没有追踪任务，或当前任务目标未配置追踪数据")
		GQTQuestID = 0
		GQTPivot = 1
		return nil
	end

	local NewQuestID = TrackingParamList[1].QuestID
	local bQuestChanged = (NewQuestID ~= GQTQuestID)
	GQTQuestID = NewQuestID
	if bQuestChanged or (GQTPivot > #TrackingParamList) then
		GQTPivot = 1
	end
	local MapQuestParam = TrackingParamList[GQTPivot]
	print("teleport to target pivot "..GQTPivot)
	GQTPivot = 1 + GQTPivot % #TrackingParamList

	local PWorldID = nil
	if MapQuestParam.MapID == PWorldMgr:GetCurrMapResID() then
		PWorldID = PWorldMgr:GetCurrPWorldResID()
	else
		local PworldCfg = require("TableCfg/PworldCfg")
		local NonInstPworldCfg = PworldCfg:FindAllCfg("Type != 12")
		for _, Cfg in ipairs(NonInstPworldCfg) do
			if Cfg.MapList ~= nil and next(Cfg.MapList) ~= nil then
				if MapQuestParam.MapID == Cfg.MapList[1] then
					PWorldID = Cfg.ID
					break
				end
			end
		end
	end

	--根据任务节点矫正副本id
	PWorldID = MapUtil.ConvertMapID(PWorldID)

	if PWorldID == nil or MapQuestParam.Pos == nil then
		_G.MsgTipsUtil.ShowTips("未查询到任务所在地")
		return nil
	end

	local P = MapQuestParam.Pos
	local Cmd = string.format("scene enter %d 0 0 0 %d %d %d", PWorldID, P.X, P.Y, P.Z)
	return Cmd
end

return QuestTrackMgr
