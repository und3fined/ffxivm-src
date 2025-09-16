--
-- Author: peterxie
-- Date:
-- Description: 地图通用玩法标记
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapUtil = require("Game/Map/MapUtil")
local MapSetting = require("Game/Map/MapSetting")
local MapDefine = require("Game/Map/MapDefine")
local ProtoRes = require("Protocol/ProtoRes")
local EObjCfg = require("TableCfg/EobjCfg")

local MapGameplayType = MapDefine.MapGameplayType
local MapIconConfigs = MapDefine.MapIconConfigs
local LSTR = _G.LSTR


---@class MapMarkerGameplay : MapMarker
local MapMarkerGameplay = LuaClass(MapMarker)

function MapMarkerGameplay:Ctor()
	self.GameplayType = nil -- 玩法标记类型，不同类型的标记ID含义不同
	self.IsEnableHitTest = true -- 标记是否可以点击，从而弹出tips

	self.bPerfectCond = false -- 探索笔记，探索点是否在完美条件下

	self.CSEntity = nil -- 副本全地图显示实体
end

function MapMarkerGameplay:GetType()
	return MapDefine.MapMarkerType.Gameplay
end

function MapMarkerGameplay:GetBPType()
	return MapDefine.MapMarkerBPType.CommGameplay
end

function MapMarkerGameplay:InitMarker(Params)
	self.GameplayType = Params.GameplayType

	if self.GameplayType == MapGameplayType.WildBox then
		self.Name = LSTR(700046)
		self.IconPath = MapIconConfigs.WildBox

	elseif self.GameplayType == MapGameplayType.AetherCurrent then
		self.Name = LSTR(700047)
		self.IconPath = MapIconConfigs.AetherCurrent

	elseif self.GameplayType == MapGameplayType.DiscoverNote then
		self.Name = LSTR(700048)

		self.bPerfectCond = Params.bPerfectCond
		if self.bPerfectCond then
			self.IconPath = MapIconConfigs.DiscoverNotePerfect
		else
			self.IconPath = MapIconConfigs.DiscoverNoteCommon
		end

	elseif self.GameplayType == MapGameplayType.PWorldEntity then
		local CSEntity = Params.Data
		if CSEntity == nil then
			return
		end
		self.CSEntity = CSEntity
		self.IsEnableHitTest = false

		if CSEntity.Type == ProtoRes.entity_type.ENTITY_TYPE_EOBJ then
			local EObjResID = CSEntity.ResID
			local Cfg = EObjCfg:FindCfgByKey(EObjResID)
			if Cfg == nil then return end
			if Cfg.EObjType == ProtoRes.ClientEObjType.ClientEObjTypeOpsPWorldBox then
				self.IconPath = MapIconConfigs.OpsPWorldBoxEObj
			elseif Cfg.EObjType == ProtoRes.ClientEObjType.ClientEObjTypeOpsPWorldClue then
				self.IconPath = MapIconConfigs.OpsPWorldClueEObj
			end
		end
	end

	self:UpdateMarker(Params)
end

function MapMarkerGameplay:UpdateMarker(Params)
    self:UpdateFollow()
end

function MapMarkerGameplay:IsNameVisible(Scale)
	return false
end

function MapMarkerGameplay:IsIconVisible(Scale)
	if not string.isnilorempty(self.IconPath) then
		if self:GetIsFollow() then
			return true
		end

		if MapSetting.GetSettingValue(MapSetting.SettingType.ShowIcon) == 0 then
			return false
		end

		if self.GameplayType == MapGameplayType.WildBox then
			if MapSetting.GetSettingValue(MapSetting.SettingType.ShowWildBox) > 0 then
				return true
			end
		elseif self.GameplayType == MapGameplayType.AetherCurrent then
			if MapSetting.GetSettingValue(MapSetting.SettingType.ShowAetherCurrent) > 0 then
				return true
			end
		elseif self.GameplayType == MapGameplayType.DiscoverNote then
			if MapSetting.GetSettingValue(MapSetting.SettingType.ShowDiscoverNote) > 0 then
				return true
			end
		else
			return true
		end
	end

	return false
end

function MapMarkerGameplay:GetTipsName()
	return self.Name
end

function MapMarkerGameplay:GetIsEnableHitTest()
	return self.IsEnableHitTest
end

function MapMarkerGameplay:GetSubType()
	return self.GameplayType
end

function MapMarkerGameplay:GetIsPerfectCond()
	return self.bPerfectCond
end

function MapMarkerGameplay:OnTriggerMapEvent(EventParams)
	if self.GameplayType == MapGameplayType.PWorldEntity then
		-- 部分玩法标记类型不用tips弹框
		return
	end

	MapUtil.ShowWorldMapMarkerFollowTips(self, EventParams)
end

return MapMarkerGameplay