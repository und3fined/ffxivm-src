--
-- Author: peterxie
-- Date: 2024-05-20
-- Description: NPC
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapSetting = require("Game/Map/MapSetting")
local MapNpcIconCfg = require("TableCfg/MapNpcIconCfg")
local ProtoRes = require("Protocol/ProtoRes")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType
local MapConstant = MapDefine.MapConstant


---@class MapMarkerNpc
local MapMarkerNpc = LuaClass(MapMarker)

function MapMarkerNpc:Ctor()
	self.MapNpcIconCfgItem = nil
    self.TipsName = "" -- 提示名称
end

function MapMarkerNpc:GetType()
	return MapMarkerType.Npc
end

function MapMarkerNpc:GetBPType()
    return MapMarkerBPType.CommIconTop
end

function MapMarkerNpc:InitMarker(Params)
    local MapNpcIconCfgItem = MapNpcIconCfg:FindCfgByKey(Params.NpcID)
	self.MapNpcIconCfgItem = MapNpcIconCfgItem
    if MapNpcIconCfgItem then
        self.IconPath = MapNpcIconCfgItem.MapIcon
        self.Name = MapNpcIconCfgItem.MapIconName
        self.TipsName = MapNpcIconCfgItem.TipsName
    end

	-- 记录NPC所属的三级地图信息，因为有些NPC图标需要MapID去判断是否激活，一二级地图显示时默认MapID是不对的
	self:SetAreaUIMapID(Params.UIMapID)
    self:SetMapID(Params.MapID)

    self:UpdateMarker(Params)
end

function MapMarkerNpc:UpdateMarker(Params)
    self:UpdateFollow()
	self:UpdateView()
end

function MapMarkerNpc:IsNameVisible(Scale)
	if not string.isnilorempty(self.Name) then
		if MapUtil.IsWorldMap(self.UIMapID) and self:GetIsFollow() then
			return false
		end

		if self:IsMarkerTextVisible(Scale) and self:IsCanShowInDiscovery() then
			if MapSetting.GetSettingValue(MapSetting.SettingType.ShowText) > 0 then
				return true
			end
		end
	end

	return false
end

function MapMarkerNpc:IsMarkerTextVisible(Scale)
	return Scale > MapConstant.MAP_SCALE_VISIBLE_LEVEL2
end

function MapMarkerNpc:IsCanShowInDiscovery()
	local MapNpcIconCfgItem = self.MapNpcIconCfgItem
	if not MapNpcIconCfgItem then
		return true
	end

	if MapNpcIconCfgItem.NPCIconType == ProtoRes.MapNPCIconType.MAP_NPC_ICON_TYPE_CHOCOBO then
		return true
	end

	if _G.FogMgr:IsAllActivate(self.MapID) then
		return true
	end

	local InDiscovery = MapNpcIconCfgItem.InDiscovery
	if InDiscovery and InDiscovery > 0 then
		return _G.FogMgr:IsInFlag(self.MapID, InDiscovery)
	end

	return true
end

function MapMarkerNpc:GetAlpha()
	local MapNpcIconCfgItem = self.MapNpcIconCfgItem
	if not MapNpcIconCfgItem then
		return 1
	end
	if MapNpcIconCfgItem.NPCIconType == ProtoRes.MapNPCIconType.MAP_NPC_ICON_TYPE_CHOCOBO then
		if _G.FogMgr:IsAllActivate(self.MapID) then
			return 1
		end
		local InDiscovery = MapNpcIconCfgItem.InDiscovery
		if InDiscovery and InDiscovery > 0 then
			if _G.FogMgr:IsInFlag(self.MapID, InDiscovery) then
				return 1
			else
				return 0.5
			end
		end
	end
	return 1
end

function MapMarkerNpc:IsControlByFog()
	return true
end

function MapMarkerNpc:GetTipsName()
    return self.TipsName
end

function MapMarkerNpc:OnTriggerMapEvent(EventParams)
	_G.FLOG_INFO(string.format("[MapMarkerNpc:OnTriggerMapEvent] %s", self:ToString()))
	MapUtil.ShowWorldMapMarkerFollowTips(self, EventParams)
end

function MapMarkerNpc:UpdateView()
	if self.MapNpcIconCfgItem then
		if self.MapNpcIconCfgItem.NPCIconType == ProtoRes.MapNPCIconType.MAP_NPC_ICON_TYPE_CHOCOBO then
			self.IconPath = _G.ChocoboTransportMgr:GetMapMarkerIcon(self.MapID, self.ID)
		elseif self.MapNpcIconCfgItem.NPCIconType == ProtoRes.MapNPCIconType.MAP_NPC_ICON_TYPE_MAGIC_CARD then
			self.IconPath = _G.MagicCardMgr:GetMapMarkerIcon(self.ID)
			if string.isnilorempty(self.IconPath) then
				self.TipsName = ""
				self.Name = ""
			end
		end
	end
end

return MapMarkerNpc