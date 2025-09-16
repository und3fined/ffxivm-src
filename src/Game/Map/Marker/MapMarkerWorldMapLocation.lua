--
-- Author: peterxie
-- Date:
-- Description: 世界地图坐标定位
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapUtil = require("Game/Map/MapUtil")
local ProtoRes = require("Protocol/ProtoRes")
local MapDefine = require("Game/Map/MapDefine")
local NpcCfg = require("TableCfg/NpcCfg")
local MapNpcIconCfg = require("TableCfg/MapNpcIconCfg")
local EObjCfg = require("TableCfg/EobjCfg")


local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType
local ClientEObjType = ProtoRes.ClientEObjType


---@class MapMarkerWorldMapLocation
local MapMarkerWorldMapLocation = LuaClass(MapMarker)

function MapMarkerWorldMapLocation:Ctor()
	self.LocationType = nil
end

function MapMarkerWorldMapLocation:GetType()
	return MapMarkerType.WorldMapLocation
end

function MapMarkerWorldMapLocation:GetBPType()
	return MapMarkerBPType.CommIconTop
end

function MapMarkerWorldMapLocation:InitMarker(Params)
	-- 图标固定
	self.IconPath = MapDefine.MapIconConfigs.WorldMapLocation

	self.LocationType = Params.LocationType

	if self.LocationType == MapDefine.MapLocationType.Npc then
		local NpcResID = Params.MarkerID
		-- 优先用MapNpcIconCfg表里的TipsName，比如幻卡希望不要显示Npc名字，避免剧透
		local MapNpcIconCfgItem = MapNpcIconCfg:FindCfgByKey(NpcResID)
		if MapNpcIconCfgItem then
			self.TipsName = MapNpcIconCfgItem.TipsName
		else
			self.TipsName = NpcCfg:FindValue(NpcResID, "Name")
		end
	elseif self.LocationType == MapDefine.MapLocationType.EObj then
		local EObjResID = Params.MarkerID
		if EObjResID then
			self.TipsName = EObjCfg:FindValue(EObjResID, "Name")
			self:ChangeTheEObjIconPath(EObjResID)
		end
	end

	self:UpdateMarker(Params)
end

function MapMarkerWorldMapLocation:UpdateMarker(Params)
    self:UpdateFollow()
end

function MapMarkerWorldMapLocation:IsNameVisible(Scale)
	return false
end

function MapMarkerWorldMapLocation:GetTipsName()
	return self.TipsName
end

function MapMarkerWorldMapLocation:GetSubType()
	return self.LocationType
end

function MapMarkerWorldMapLocation:OnTriggerMapEvent(EventParams)
	MapUtil.ShowWorldMapMarkerFollowTips(self, EventParams)
end

function MapMarkerWorldMapLocation:ChangeTheEObjIconPath(EObjResID)
	local EObjType = EObjCfg:FindValue(EObjResID, "EObjType")
	if not EObjType then
		return
	end

	if EObjType == ClientEObjType.ClientEObjTypeDiscoverNote then
		self.IconPath = MapDefine.MapIconConfigs.DiscoverNoteCommon
	end
end

return MapMarkerWorldMapLocation