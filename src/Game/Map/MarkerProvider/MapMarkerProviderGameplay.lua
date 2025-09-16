--
-- Author: peterxie
-- Date:
-- Description: 地图通用玩法标记
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerGameplay = require("Game/Map/Marker/MapMarkerGameplay")
local MapUtil = require("Game/Map/MapUtil")
local ProtoRes = require ("Protocol/ProtoRes")
local MapDefine = require("Game/Map/MapDefine")
local MapGameplayType = MapDefine.MapGameplayType

local WildBoxMoundCfg = require("TableCfg/WildBoxMoundCfg")
local AetherCurrentCfg = require("TableCfg/AetherCurrentCfg")
local DiscoverNoteCfg = require("TableCfg/DiscoverNoteCfg")


---@class MapMarkerProviderGameplay : MapMarkerProvider
local MapMarkerProviderGameplay = LuaClass(MapMarkerProvider)

function MapMarkerProviderGameplay:Ctor()

end

function MapMarkerProviderGameplay:GetMarkerType()
	return MapDefine.MapMarkerType.Gameplay
end

function MapMarkerProviderGameplay:OnGetMarkers(UIMapID, MapID)
	local MapMarkers = {}

	local GameplayMarkers = self:CreateWildBoxMarkers()
	table.merge_table(MapMarkers, GameplayMarkers)

	GameplayMarkers = self:CreateAetherCurrentMarkers()
	table.merge_table(MapMarkers, GameplayMarkers)

	GameplayMarkers = self:CreateDiscoverNoteMarkers()
	table.merge_table(MapMarkers, GameplayMarkers)

	GameplayMarkers = self:CreatePWorldEntityMarkers()
	table.merge_table(MapMarkers, GameplayMarkers)

	return MapMarkers
end

function MapMarkerProviderGameplay:OnCreateMarker(Params)
	local Marker = self:CreateMarker(MapMarkerGameplay, Params.ID, Params)
	if nil == Marker then
		return
	end

	local X, Y = MapUtil.GetUIPosByLocation(Params.Pos, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)

	return Marker
end

---野外宝箱标记
function MapMarkerProviderGameplay:CreateWildBoxMarkers()
	local MapMarkers = {}

	local MapID = self.MapID
	local DataList = _G.WildBoxMoundMgr:GetOpenedBoxList(MapID)
	for _, ID in ipairs(DataList or {}) do
		local Cfg = WildBoxMoundCfg:FindCfgByKey(ID)
		if Cfg then
			local MarkerID = Cfg.ID
			local Pos = MapUtil.GetMapEObjPosByListID(MapID, Cfg.EmptyListID)
			local Params = { ID = MarkerID, GameplayType = MapGameplayType.WildBox, Pos = Pos }
			local Marker = self:OnCreateMarker(Params)
			table.insert(MapMarkers, Marker)
		end
	end

	return MapMarkers
end

---风脉泉标记
function MapMarkerProviderGameplay:CreateAetherCurrentMarkers()
	local MapMarkers = {}

	local MapID = self.MapID
	local DataList = _G.AetherCurrentsMgr:GetTheMapActivedPointIdList(MapID)
	for _, PointID in ipairs(DataList or {}) do
		local Cfg = AetherCurrentCfg:FindCfgByKey(PointID)
		if Cfg and Cfg.CurrentType == ProtoRes.WindPulseSpringActivateType.Interact then
			local MarkerID = Cfg.PointID
			local Pos = MapUtil.GetMapEObjPosByListID(MapID, Cfg.ListID)
			local Params = { ID = MarkerID, GameplayType = MapGameplayType.AetherCurrent, Pos = Pos }
			local Marker = self:OnCreateMarker(Params)
			table.insert(MapMarkers, Marker)
		end
	end

	return MapMarkers
end

---探索笔记标记
function MapMarkerProviderGameplay:CreateDiscoverNoteMarkers()
	local MapMarkers = {}

	local MapID = self.MapID
	local DataList = _G.DiscoverNoteMgr:GetThePerfectActivePointInfoByMapID(MapID)
	for _, PointInfo in ipairs(DataList or {}) do
		local Cfg = DiscoverNoteCfg:FindCfgByKey(PointInfo.ID)
		if Cfg then
			local MarkerID = Cfg.ID
			local Pos = MapUtil.GetMapEObjPosByResID(MapID, Cfg.EobjID)
			local Params = { ID = MarkerID, GameplayType = MapGameplayType.DiscoverNote, Pos = Pos, bPerfectCond = PointInfo.bPerfectCond }
			local Marker = self:OnCreateMarker(Params)
			table.insert(MapMarkers, Marker)
		end
	end

	return MapMarkers
end

---副本Entity标记
function MapMarkerProviderGameplay:CreatePWorldEntityMarkers()
	local MapMarkers = {}

	local DataList = _G.PWorldMgr:GetPWorldMechanismDataMgr():GetPWorldEntityList()
	for _, CSEntity in ipairs(DataList or {}) do
		local BelongUIMapID = _G.MapAreaMgr:GetUIMapIDByLocation(CSEntity.Pos, self.MapID)
		-- 后台下发的是整个MapID的Entity，只显示当前层UIMapID的Entity
		if BelongUIMapID == self.UIMapID then
			local Params = { ID = CSEntity.ID, GameplayType = MapGameplayType.PWorldEntity, Pos = CSEntity.Pos, Data = CSEntity }
			local Marker = self:OnCreateMarker(Params)
			table.insert(MapMarkers, Marker)
		end
	end

	return MapMarkers
end

---创建给定玩法类型的标记
---@param GameplayType MapGameplayType 玩法类型
function MapMarkerProviderGameplay:AddMarkersByType(GameplayType)
	local GameplayMarkers
	if GameplayType == MapGameplayType.WildBox then
		GameplayMarkers = self:CreateWildBoxMarkers()
	elseif GameplayType == MapGameplayType.AetherCurrent then
		GameplayMarkers = self:CreateAetherCurrentMarkers()
	elseif GameplayType == MapGameplayType.DiscoverNote then
		GameplayMarkers = self:CreateDiscoverNoteMarkers()
	elseif GameplayType == MapGameplayType.PWorldEntity then
		GameplayMarkers = self:CreatePWorldEntityMarkers()
	end

	if nil == GameplayMarkers then
		return
	end

	self:AddMarkersByList(GameplayMarkers)
end

---移除给定玩法类型的标记
---@param GameplayType MapGameplayType 玩法类型
function MapMarkerProviderGameplay:RemoveMarkersByType(GameplayType)
	self:RemoveMarkersByPredicate(function(Marker)
		return Marker:GetSubType() == GameplayType
	end)
end

---更新给定玩法类型的标记，简化处理，直接先移除再创建
function MapMarkerProviderGameplay:UpdateMarkers(GameplayType, Params)
	self:RemoveMarkersByType(GameplayType)
	self:AddMarkersByType(GameplayType)
end

---副本Entity增加
function MapMarkerProviderGameplay:AddPWorldEntity(CSEntity)
	if nil == CSEntity then
		return
	end
	local BelongUIMapID = _G.MapAreaMgr:GetUIMapIDByLocation(CSEntity.Pos, self.MapID)
	if BelongUIMapID == self.UIMapID then
		local Params = { ID = CSEntity.ID, GameplayType = MapGameplayType.PWorldEntity, Pos = CSEntity.Pos, Data = CSEntity }
		self:AddMarker(Params)
	end
end

---副本Entity移除
function MapMarkerProviderGameplay:RemovePWorldEntity(CSEntity)
	if nil == CSEntity then
		return
	end
	self:RemoveMarker({ ID = CSEntity.ID, SubType = MapGameplayType.PWorldEntity })
end

---副本Entity更新，简化处理，直接先移除再创建
function MapMarkerProviderGameplay:UpdatePWorldEntity(CSEntity)
	if nil == CSEntity then
		return
	end
	self:RemovePWorldEntity(CSEntity)
	self:AddPWorldEntity(CSEntity)
end

---查找标记
---@return MapMarker
function MapMarkerProviderGameplay:FindMarker(Params)
	local GameplayMarkerID = Params.ID -- 玩法标记ID
	local GameplayType = Params.SubType -- 玩法标记类型

	local Marker = table.find_by_predicate(self.MapMarkers, function(Marker)
		return Marker:GetSubType() == GameplayType and Marker:GetID() == GameplayMarkerID
	end)
	return Marker
end

function MapMarkerProviderGameplay:UpdateFollowMarker(FollowInfo)
	if FollowInfo == nil then
		return
	end

	if MapUtil.IsAreaMap(self.UIMapID) then
		local Params = { ID = FollowInfo.FollowID, SubType = FollowInfo.FollowSubType }
		local Marker = self:FindMarker(Params)
		if Marker then
			Marker:UpdateFollow()
			self:SendUpdateMarkerEvent(Marker)
		end
	else
		_G.EventMgr:SendEvent(_G.EventID.WorldMapUpdateAllMarker)
	end
end


return MapMarkerProviderGameplay