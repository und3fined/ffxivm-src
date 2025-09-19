--
-- Author: anypkvcai
-- Date: 2022-10-24 14:55
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local MapVM = require("Game/Map/VM/MapVM")
local MapUtil = require("Game/Map/MapUtil")
local MapSetting = require("Game/Map/MapSetting")

local MapUICfg = require("TableCfg/MapUICfg")
local MapNpcIconCfg = require("TableCfg/MapNpcIconCfg")
local MapIconMappingCfg = require("TableCfg/MapIconMappingCfg")

local FLOG_INFO
local PWorldMgr ---@type PWorldMgr
local EventMgr ---@type EventMgr
local MapAreaMgr ---@type MapAreaMgr
local EXLocationType = _G.UE.EXLocationType


---@class MapMgr : MgrBase
local MapMgr = LuaClass(MgrBase)

function MapMgr:OnInit()
	self.UIMapID = 0
	self.MapID = 0
	self.WeatherID = 0
	self.UpdateMapBit = 0
	self.MapInfo = {}
    self.MapIconMappingByRes = {}
end

function MapMgr:OnBegin()
	FLOG_INFO = _G.FLOG_INFO
	PWorldMgr = _G.PWorldMgr
	EventMgr = _G.EventMgr
	MapAreaMgr = _G.MapAreaMgr

	MapSetting.InitSetting()

	local AllCfg = MapIconMappingCfg:FindAllCfg()
	for _,Cfg in ipairs(AllCfg) do
		self.MapIconMappingByRes[Cfg.ActorResID] = Cfg
	end
end

function MapMgr:OnEnd()

end

function MapMgr:OnShutdown()

end

function MapMgr:OnRegisterNetMsg()

end

function MapMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldEnter)
	self:RegisterGameEvent(EventID.MapRangeChanged, self.OnGameEventMapRangeChanged)

	self:RegisterGameEvent(EventID.ManualSelectTarget, self.OnGameEventManualSelectTarget)
	self:RegisterGameEvent(EventID.EnterInteractionRange, self.OnGameEventEnterInteractionRange)
end

function MapMgr:OnRegisterTimer()
	self:RegisterTimer(self.OnTimerUpdateMap, 0, 0.067, 0)
end


function MapMgr:OnGameEventPWorldEnter(Params)
	--print("MapMgr:OnGameEventPWorldEnter")
	self:UpdateMapInfo()
end

function MapMgr:OnGameEventMapRangeChanged(Params)
	if nil == Params then
		return
	end
	--FLOG_INFO("[MapMgr:OnGameEventMapRangeChanged] MapRangeMapID=%d", Params.MapID)
	self:UpdateMapInfo(Params.MapID)
end

function MapMgr:OnGameEventManualSelectTarget(Params)
	local EntityID = Params.ULongParam1
	self:PrintEntityInfo(EntityID)
end

function MapMgr:OnGameEventEnterInteractionRange(Params)
	local EntityID = Params.ULongParam1
	self:PrintEntityInfo(EntityID)
end

function MapMgr:PrintEntityInfo(EntityID)
	if not _G.WorldMapMgr.bShowDebugInfo then
		return
	end

	local TargetActor = ActorUtil.GetActorByEntityID(EntityID)
	if nil == TargetActor then
		return
	end

	local AttributeComp = TargetActor:GetAttributeComponent()
	local ResID = TargetActor:GetActorResID()
	local ListID = AttributeComp.ListID
	local ActorName = ActorUtil.GetActorName(EntityID)

	-- 点击NPC时输出NPC相关信息，方便策划配表，请保留下述log！！！
	FLOG_INFO("[MapMgr:PrintEntityInfo] click ResID=%d, ListID=%d, Name=%s, Pos(%s)", ResID, ListID, ActorName, TargetActor:FGetActorLocation())
end


function MapMgr:UpdateWeather(WeatherID)
	--FLOG_INFO("[MapMgr:UpdateWeather] WeatherID:%d", WeatherID)
	self.WeatherID = WeatherID
	MapVM:SetWeatherID(WeatherID)
end

function MapMgr:UpdateMapInfo(UIMapID)
	self.UpdateMapBit = 1

	local MapID = PWorldMgr:GetCurrMapResID()
	if nil == UIMapID or UIMapID <= 0 then
		UIMapID = self:CalcUIMapID(MapID)
	end

	FLOG_INFO("[MapMgr:UpdateMapInfo] UIMapID=%s MapID=%s self.UIMapID=%s self.MapID=%s", UIMapID, MapID, self.UIMapID, self.MapID)
	local bSameWorldIns = _G.PWorldMgr.BaseInfo.LastPWorldInstID == _G.PWorldMgr.BaseInfo.CurrPWorldInstID
	if UIMapID == self.UIMapID and MapID == self.MapID and bSameWorldIns then
		-- 这里增加一个世界实例判断
		return
	end

	self.UIMapID = UIMapID
	self.MapID = MapID

	local MapInfo = self.MapInfo
	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		FLOG_INFO("[MapMgr:UpdateMapInfo] Cfg nil")
		--MapVM:SetMapBackground(nil)
		MapVM:SetMapPath(nil)
		MapVM:SetMapMaskPath(nil)
		MapVM:SetIsAllActivate(true)
		MapInfo.MapScale = nil
		MapInfo.MapOffsetX = 0
		MapInfo.MapOffsetY = 0
	else
		--MapVM:SetMapBackground(Cfg.Background)
		local IsAllActivate = _G.FogMgr:IsAllActivate(MapID)
		MapVM:SetMapPath(Cfg.Path)
		MapVM:SetMapMaskPath(IsAllActivate and "" or Cfg.MaskPath)
		MapVM:SetDiscoveryFlag(_G.FogMgr:GetFlogFlag(MapID))
		MapVM:SetIsAllActivate(IsAllActivate)
		MapInfo.MapScale = Cfg.Scale
		MapInfo.MapOffsetX = Cfg.OffsetX
		MapInfo.MapOffsetY = Cfg.OffsetY
	end

	local MapName = MapUtil.GetMapName(UIMapID)
	MapVM:SetMapName(MapName)

	EventMgr:PostEvent(EventID.MapChanged)
end

function MapMgr:OnTimerUpdateMap()
	if self.UpdateMapBit <= 0 then
		return
	end

	self:UpdateMajorRotation()
	self:UpdateCameraRotation()
	self:UpdateMajorPosition()
end

function MapMgr:UpdateMajorRotation()
	local Major = MajorUtil.GetMajor()
	if nil == Major then
		return
	end

	local Rotation = Major:K2_GetActorRotation()
	--场景转了90度,这里做下修正
	local Yaw = Rotation.Yaw + 90

	MapVM:SetMajorRotationAngle(Yaw - Yaw % 0.01)
end

function MapMgr:UpdateCameraRotation()
	local Major = MajorUtil.GetMajor()
	if nil == Major then
		return
	end

	local Rotation = Major:GetCameraBoomRelativeRotation()
	--场景转了90度,这里做下修正
	local Yaw = Rotation.Yaw + 90

	MapVM:SetCameraRotationAngle(Yaw - Yaw % 0.01)
end

function MapMgr:UpdateMajorPosition()
	local MapInfo = self.MapInfo

	local MapScale = MapInfo.MapScale
	if nil == MapScale then
		return
	end

	local Major = MajorUtil.GetMajor()
	if nil == Major then
		return
	end

	--local Location = Major:FGetActorLocation()
	local Location = Major:FGetLocation(EXLocationType.ServerLoc)

	local X, Y = MapUtil.ConvertMapPos2UI(Location.X, Location.Y, MapInfo.MapOffsetX, MapInfo.MapOffsetY, MapScale, false, self.UIMapID)
	MapVM:SetMajorPosition(X, Y)
	MapVM:SetMajorLeftTopPosition(MapUtil.ConvertUIPos2LeftTop(X, Y, self.UIMapID))

	MapVM:SetMajorWorldPosition(Location.X, Location.Y, Location.Z)
end


function MapMgr:GetWeatherID()
	return self.WeatherID
end

function MapMgr:CalcUIMapID(MapID)
	local MapRangeMapID = MapAreaMgr:GetMapID()
	FLOG_INFO("[MapMgr:CalcUIMapID] MapRangeMapID=%d MapID=%d", MapRangeMapID, MapID)
	if MapRangeMapID > 0 then
		return MapRangeMapID
	end

	return MapUtil.GetUIMapID(MapID)
end

function MapMgr:GetUIMapID()
	return self.UIMapID
end

function MapMgr:GetMapID()
	return PWorldMgr:GetCurrMapResID()
end

---获取npc头顶图标
---@param EntityID number
---@return string|nil 图标资源路径
function MapMgr:GetNPCHudIcon(EntityID)
	local NpcID = ActorUtil.GetActorResID(EntityID)
	if NpcID then
		local CfgMapNpcIcon = MapNpcIconCfg:FindCfgByKey(NpcID)
		if CfgMapNpcIcon then
			return CfgMapNpcIcon.HudIcon
		end
	end

	return nil
end


function MapMgr:GetMappingHudIcon(EntityID)
	local ResID = ActorUtil.GetActorResID(EntityID)
	if ResID then
		local MappingCfgItem = self.MapIconMappingByRes[ResID]
		if not MappingCfgItem then
			return
		end
		local TargetMapIDList = {}
		local QuestList = _G.QuestMgr.QuestMap
		for _, Quest in pairs(QuestList) do
			for _, Target in pairs(Quest.Targets) do
				if Target.Cfg and Target.Cfg.UIMapID then
					TargetMapIDList[Target.Cfg.UIMapID] = Quest.QuestID
				end
			end
		end
		local MainlineQuestParam = _G.QuestTrackMgr:GetMainlineQuestParam()
		if MainlineQuestParam then
			for _, QuestParam in pairs(MainlineQuestParam) do
				if QuestParam.UIMapID then
					TargetMapIDList[QuestParam.UIMapID] = QuestParam.QuestID
				end
			end
		end
		if TargetMapIDList[MappingCfgItem.UIMapID] then
			local QuestID = TargetMapIDList[MappingCfgItem.UIMapID]
			return  _G.QuestMgr:GetQuestIconAtHUD(QuestID)
		end
	end
	return nil
end

function MapMgr:GetMainlineTrackingHudIcon(EntityID)
	local CurrNavPath = _G.QuestTrackMgr:GetCurrNavPath()
	if CurrNavPath then
		local ResID = ActorUtil.GetActorResID(EntityID)
		if CurrNavPath.EndPosActorResID == ResID then
			local QusetParamList = _G.QuestTrackMgr:GetTrackingQuestParam()
			if QusetParamList then
				local QuestParam = QusetParamList[1]
				if QuestParam and QuestParam.QuestType == 0 then
					return _G.QuestMgr:GetTrackingIconAtHUD(QuestParam.QuestID)
				end
			end
		end
	end
	return nil
end

---设置定位更新开关
---@param IsFlag boolean
---@param SourceBit number@来源
function MapMgr:SetUpdateMap(IsFlag, SourceBit)
	if IsFlag then
		self.UpdateMapBit = self.UpdateMapBit | SourceBit
	else
		self.UpdateMapBit = self.UpdateMapBit & ~SourceBit
	end
	--FLOG_INFO("[MapMgr:SetUpdateMap] UpdateMapBit=%d", self.UpdateMapBit)
end

--- 设置玩法定位可视化
---@param Visible boolean 是否显示
function MapMgr:SetGameplayLocationVisible(Visible)
	MapVM:SetGameplayLocationVisible(Visible)
end

--- 获取玩法定位可视化
function MapMgr:GetGameplayLocationVisible()
	return MapVM:GetGameplayLocationVisible()
end

return MapMgr