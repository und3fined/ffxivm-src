--
-- Author: anypkvcai
-- Date: 2022-12-08 10:00
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerFixedPoint = require("Game/Map/Marker/MapMarkerFixedPoint")
local MapUtil = require("Game/Map/MapUtil")
local MapMarkerRegionCfg = require("TableCfg/MapMarkerRegionCfg")

-- 蓝图修改为背景层和标记点同步移动和缩放，美术修改蓝图层级和大小，需要加一个偏移来兼容新蓝图
local REGION_MARKER_OFFSET = 1024

---@class MapMarkerRegion
local MapMarkerRegion = LuaClass(MapMarkerFixedPoint)

---Ctor
function MapMarkerRegion:Ctor()
	self.MarkerRegionCfg = nil
	self.Region = 0
	self.IsEnableHitTest = true
	self.TargetUIMapID = 0
	self.TargetMapID = 0
end

function MapMarkerRegion:InitMarker(MarkerCfg)
	self.MarkerCfg = MarkerCfg
	self.Name = MapUtil.GetPlaceName(MarkerCfg.Name)
	self.IconPath = MapUtil.GetIconPath(MarkerCfg.Icon)
	self.BPType = MapUtil.GetFixedPointMarkerBPType(MarkerCfg)

	self.Region = MarkerCfg.Region
	self.MarkerRegionCfg = MapMarkerRegionCfg:FindCfgByKey(MarkerCfg.Region)

	self.TargetUIMapID = MarkerCfg.EventArg
	self.TargetMapID = MapUtil.GetMapID(self.TargetUIMapID)

	--print(MarkerCfg.ID, self.TargetUIMapID, self.Name, self.TargetMapID)
end

--function MapMarkerRegion:GetNamePosX()
--	return self:GetPosX() + self.MarkerRegionCfg.NameX
--end
--
--function MapMarkerRegion:GetNamePosY()
--	return self:GetPosY() + self.MarkerRegionCfg.NameY
--end

function MapMarkerRegion:GetMarkerRegionCfg()
	return self.MarkerRegionCfg
end

function MapMarkerRegion:GetPictureScale()
	return self.MarkerRegionCfg.PictureScale
end

function MapMarkerRegion:IsLink()
	return self.MarkerRegionCfg.Link > 0
end

function MapMarkerRegion:SetIsEnableHitTest(IsEnable)
	self.IsEnableHitTest = IsEnable
end

function MapMarkerRegion:GetIsEnableHitTest()
	return self.IsEnableHitTest
end

function MapMarkerRegion:GetAreaMapPos()
	return self.MarkerCfg.PosX + REGION_MARKER_OFFSET, self.MarkerCfg.PosY + REGION_MARKER_OFFSET
end

function MapMarkerRegion:IsIconVisible(Scale)
	return true
end

function MapMarkerRegion:GetIsActive()
	-- 如果地图版本号不匹配，效果同未解锁的地图效果一致
	if not MapUtil.IsUIMapOpenByVersion(self.TargetUIMapID) then
		return false
	end

	return _G.FogMgr:IsAnyActivate(self.TargetMapID)
end

return MapMarkerRegion