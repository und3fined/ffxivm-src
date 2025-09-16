--
-- Author: anypkvcai
-- Date: 2022-12-08 10:00
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapSetting = require("Game/Map/MapSetting")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MapIconCfg = require("TableCfg/MapIconCfg")
local MapMarkerOpenFlagCfg = require("TableCfg/MapMarkerOpenFlagCfg")
local TeleportCrystalCfg = require("TableCfg/TeleportCrystalCfg")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerPriority = MapDefine.MapMarkerPriority
local MapMarkerEventType = ProtoRes.MapMarkerEventType
local MapConstant = MapDefine.MapConstant
local MapMarkerBPType = MapDefine.MapMarkerBPType
local TELEPORT_CRYSTAL_TYPE = ProtoRes.TELEPORT_CRYSTAL_TYPE
local MapMarkerLayout = ProtoRes.MapMarkerLayout
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS

local ESlateVisibility = _G.UE.ESlateVisibility


---@class MapMarkerFixedPoint : MapMarker
local MapMarkerFixedPoint = LuaClass(MapMarker)

function MapMarkerFixedPoint:Ctor()
	self.MarkerCfg = nil -- 标记表格配置
	self.BPType = nil -- 标记使用的蓝图类型
	self.IconResize = 1 -- 图标缩放比例
	self.IsEnableHitTest = true -- 标记是否可以点击

	self.ExtraIconPath1 = "" -- 标记扩展图标路径1
	self.ExtraIconPath2 = "" -- 标记扩展图标路径2
end

function MapMarkerFixedPoint:GetType()
	return MapMarkerType.FixPoint
end

function MapMarkerFixedPoint:GetBPType()
	return self.BPType
end

function MapMarkerFixedPoint:InitMarker(MarkerCfg)
	self.MarkerCfg = MarkerCfg
	self.Name = MapUtil.GetPlaceName(MarkerCfg.Name)
	self.IconPath = MapUtil.GetIconPath(MarkerCfg.Icon)
	local MapIconCfgItem = MapIconCfg:FindCfgByKey(MarkerCfg.Icon)
	if MapIconCfgItem then
		self.IconResize = MapIconCfgItem.IconResize
	else
		self.IconResize = 1
	end
	self.BPType = MapUtil.GetFixedPointMarkerBPType(MarkerCfg)

	-- 记录标记所属的三级地图信息
	self:SetAreaUIMapID(MapUtil.GetUIMapIDByMarker(MarkerCfg.Marker))
	self:SetMapID(MapUtil.GetMapID(self.AreaUIMapID))

	if self.MarkerCfg.NoTips == 1 then
		self.IsEnableHitTest = false
	else
		self.IsEnableHitTest = true
	end

	self:UpdateMarker()
end

function MapMarkerFixedPoint:UpdateMarker()
    self:UpdateFollow()
	self:UpdateIconPath()
	self:UpdateAdjacentMapIcon()
end

function MapMarkerFixedPoint:UpdateIconPath()
	local EventType = self.MarkerCfg.EventType
	local EventArg = self.MarkerCfg.EventArg

	if MapMarkerEventType.MAP_MARKER_EVENT_TELEPO == EventType then
		local CrystalID = EventArg
		local CrystalType = TeleportCrystalCfg:FindValue(CrystalID, "Type")
		if CrystalType == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP then
			if self:GetIsActive() then
				self.IconPath = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060453.UI_Icon_060453'"
			else
				self.IconPath = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060453_gray.UI_Icon_060453_gray'"
			end
		elseif CrystalType == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_CURRENTMAP then
			if self:GetIsActive() then
				self.IconPath = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060430.UI_Icon_060430'"
			else
				self.IconPath = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060430_gray.UI_Icon_060430_gray'"
			end
		end
	end
end

-- 在切图标记上显示相邻地图的图标，如任务追踪图标、地图追踪图标
function MapMarkerFixedPoint:UpdateAdjacentMapIcon()
	self.ExtraIconPath1 = ""
	self.ExtraIconPath2 = ""

	local EventType = self.MarkerCfg.EventType
	local EventArg = self.MarkerCfg.EventArg
	if MapMarkerEventType.MAP_MARKER_EVENT_CHANGE_MAP == EventType then
		local TargetUIMapID = EventArg
		if TargetUIMapID == self.AreaUIMapID then
			-- 切图标记的目标地图就是当前地图，如地图里的码头
			return
		end
		local TargetMapID = MapUtil.GetMapID(TargetUIMapID)
		if TargetMapID == 0 then
			return
		end

		-- 任务追踪
		local TrackingQuestList = _G.QuestTrackMgr:GetTrackingQuestParam()
		for i = 1, #TrackingQuestList do
			local MapQuestParam = TrackingQuestList[i]
			if MapQuestParam.UIMapID == TargetUIMapID and MapQuestParam.MapID == TargetMapID then
				self.ExtraIconPath1 = _G.QuestMgr:GetQuestIconAtMap(MapQuestParam.QuestID)
			end
		end

		-- 地图追踪
		local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
		if FollowInfo then
			if FollowInfo.FollowUIMapID == TargetUIMapID and FollowInfo.FollowMapID == TargetMapID then
				self.ExtraIconPath2 = "Texture2D'/Game/UI/Texture/NewMap/UI_Map_Icon_TrackTips.UI_Map_Icon_TrackTips'"
			end
		end
	end
end

-- 是否切图标记
function MapMarkerFixedPoint:IsEventTypeChangeMap()
	local EventType = self.MarkerCfg.EventType
	if MapMarkerEventType.MAP_MARKER_EVENT_CHANGE_MAP == EventType then
		return true
	end

	return false
end

function MapMarkerFixedPoint:GetMarkerCfg()
	return self.MarkerCfg
end

function MapMarkerFixedPoint:GetAreaMapPos()
	return self.MarkerCfg.PosX, self.MarkerCfg.PosY
end

function MapMarkerFixedPoint:GetLayout()
	return self.MarkerCfg.Layout
end

function MapMarkerFixedPoint:GetEventType()
	return self.MarkerCfg.EventType
end

function MapMarkerFixedPoint:GetEventArg()
	return self.MarkerCfg.EventArg
end

function MapMarkerFixedPoint:OnTriggerMapEvent(EventParams)
	_G.FLOG_INFO(string.format("[MapMarkerFixedPoint:OnTriggerMapEvent] %s", self:ToString()))

	local EventType = self.MarkerCfg.EventType
	local EventArg = self.MarkerCfg.EventArg
	--local EventSubArg = self.MarkerCfg.EventSubArg
	if MapMarkerEventType.MAP_MARKER_EVENT_CHANGE_MAP == EventType then
		local TargetUIMapID = EventArg
		_G.WorldMapMgr:ChangeMap(TargetUIMapID)
        return
	elseif MapMarkerEventType.MAP_MARKER_EVENT_TELEPO == EventType
		or MapMarkerEventType.MAP_MARKER_EVENT_TRANS_DOOR == EventType then
		-- 如果水晶有激活，走传送流程；没有激活，走统一的追踪流程
        if self:GetIsActive() then
		    local Params = { MapMarker = self, ScreenPosition = EventParams.ScreenPosition }
		    UIViewMgr:ShowView(UIViewID.WorldMapMarkerTipsTransfer, Params)
            return
        end
	end

	MapUtil.ShowWorldMapMarkerFollowTips(self, EventParams)
end

function MapMarkerFixedPoint:IsNameVisible(Scale)
	if not string.isnilorempty(self.Name) then
		if MapUtil.IsWorldMap(self.UIMapID) and self:GetIsFollow() then
			return false
		end

		if not self:IsCanShowByOpenFlag() then
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

function MapMarkerFixedPoint:IsIconVisible(Scale)
	if not string.isnilorempty(self.IconPath) then
		if self:GetIsFollow() then
			return true
		end

		if not self:IsCanShowByOpenFlag() then
			return false
		end

		if self:IsMarkerIconVisible(Scale) and self:IsCanShowInDiscovery() then
			-- 二级地图大图标不受设置影响
			if MapMarkerLayout.MAP_MARKER_LAYOUT_REGION_ICON == self:GetLayout() then
				return true
			end

			local EventType = self.MarkerCfg.EventType
			if MapMarkerEventType.MAP_MARKER_EVENT_TELEPO == EventType then
				if MapSetting.GetSettingValue(MapSetting.SettingType.ShowCrystalIcon) > 0 then
					return true
				end
			else
				if MapSetting.GetSettingValue(MapSetting.SettingType.ShowIcon) > 0 then
					return true
				end
			end
		end
	end

	return false
end

function MapMarkerFixedPoint:GetNameVisibility(Scale)
	if nil == self.Name then
		return ESlateVisibility.Collapsed
	else
		return self:IsNameVisible(Scale) and ESlateVisibility.SelfHitTestInvisible or ESlateVisibility.Hidden
	end
end

function MapMarkerFixedPoint:GetIconVisibility(Scale)
	if nil == self.IconPath then
		return ESlateVisibility.Collapsed
	else
		return self:IsIconVisible(Scale) and ESlateVisibility.SelfHitTestInvisible or ESlateVisibility.Hidden
	end
end

function MapMarkerFixedPoint:IsMarkerTextVisible(Scale)
	if self.MarkerBPType == MapMarkerBPType.Region then
		return Scale > MapConstant.MAP_SCALE_MIN
	else
		local EventType = self.MarkerCfg.EventType
		if MapMarkerEventType.MAP_MARKER_EVENT_CHANGE_MAP == EventType then
			return Scale > MapConstant.MAP_SCALE_MIN
		elseif MapMarkerEventType.MAP_MARKER_EVENT_TELEPO == EventType
			or MapMarkerEventType.MAP_MARKER_EVENT_TRANS_DOOR == EventType then
			if MapUtil.IsRegionMap(self.UIMapID) then
				return false
			else
				return Scale > MapConstant.MAP_SCALE_MIN
			end
		else
			local TextType = self.MarkerCfg.TextType
			if TextType > 0 then
				return Scale > MapConstant.MAP_SCALE_VISIBLE_LEVEL1
			else
				local IconType = self.MarkerCfg.Icon
				if IconType == 60442 then -- 地图图钉
					return Scale > MapConstant.MAP_SCALE_VISIBLE_LEVEL3
				end
				return Scale > MapConstant.MAP_SCALE_VISIBLE_LEVEL2
			end
		end
	end
end

function MapMarkerFixedPoint:IsMarkerIconVisible(Scale)
	if self.MarkerBPType == MapMarkerBPType.Region then
		return Scale > MapConstant.MAP_SCALE_MIN
	else
		local EventType = self.MarkerCfg.EventType
		if MapMarkerEventType.MAP_MARKER_EVENT_TELEPO == EventType
			or MapMarkerEventType.MAP_MARKER_EVENT_TRANS_DOOR == EventType then
			return Scale > MapConstant.MAP_SCALE_MIN
		else
			if MapMarkerLayout.MAP_MARKER_LAYOUT_REGION_ICON == self:GetLayout() then
				return Scale > MapConstant.MAP_SCALE_MIN
			else
				local IconType = self.MarkerCfg.Icon
				if IconType == 60442 then -- 地图图钉
					return Scale > MapConstant.MAP_SCALE_VISIBLE_LEVEL3
				else
					return Scale > MapConstant.MAP_SCALE_VISIBLE_LEVEL1
				end
			end
		end
	end
end

function MapMarkerFixedPoint:IsCanShowInDiscovery()
	local MarkerCfg = self.MarkerCfg
	if not MarkerCfg then
		return true
	end

	if MarkerCfg.TextType > 0 or MarkerCfg.EventType > 0 then
		return true
	end
	if _G.FogMgr:IsAllActivate(self.MapID) then
		return true
	end
	if MarkerCfg.Icon > 0 then
		local MapIconCfgItem = MapIconCfg:FindCfgByKey(MarkerCfg.Icon)
		if MapIconCfgItem and MapIconCfgItem.AlwaysShow > 0 then
			return true
		end
	end
	local InDiscovery = MarkerCfg.InDiscovery
	if InDiscovery and InDiscovery > 0 then
		return _G.FogMgr:IsInFlag(self.MapID, InDiscovery)
	end
	return true
end

function MapMarkerFixedPoint:IsControlByFog()
	return true
end

function MapMarkerFixedPoint:IsControlByOpenFlag()
	local MarkerCfg = self.MarkerCfg
	if MarkerCfg and MarkerCfg.OpenFlag > 0 then
		return true
	end

	return false
end

function MapMarkerFixedPoint:IsCanShowByOpenFlag()
	local MarkerCfg = self.MarkerCfg
	if not MarkerCfg then
		return true
	end

	if MarkerCfg.OpenFlag > 0 then
		local OpenQuestID = MapMarkerOpenFlagCfg:FindValue(MarkerCfg.OpenFlag, "OpenQuestID")
		if OpenQuestID > 0 then
			local QuestStatus = _G.QuestMgr:GetQuestStatus(OpenQuestID)
			if QuestStatus ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
				-- 解锁任务未完成
				return false
			end
		end
	end

	return true
end

function MapMarkerFixedPoint:GetIsActive()
	local EventType = self.MarkerCfg.EventType
	local EventArg = self.MarkerCfg.EventArg

	if MapMarkerEventType.MAP_MARKER_EVENT_TELEPO == EventType then
		local CrystalID = EventArg
		local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
		return CrystalMgr:IsExistActiveCrystal(CrystalID)
	end

	return true
end

function MapMarkerFixedPoint:GetTipsName()
	return MapUtil.GetMapTipsName(self.MarkerCfg)
end

function MapMarkerFixedPoint:GetIsEnableHitTest()
	return self.IsEnableHitTest
end

function MapMarkerFixedPoint:GetPriority()
	local EventType = self.MarkerCfg.EventType
	if MapMarkerEventType.MAP_MARKER_EVENT_CHANGE_MAP == EventType then
		if MapMarkerLayout.MAP_MARKER_LAYOUT_WORLD_ICON == self:GetLayout() then
			-- 一级地图标题层级要比主角还高
			return MapMarkerPriority.Major + 1
		end

		return MapMarkerPriority.Telepo
	elseif MapMarkerEventType.MAP_MARKER_EVENT_DISPLAY_QUEST == EventType then
		return MapMarkerPriority.Quest
	elseif MapMarkerEventType.MAP_MARKER_EVENT_TELEPO == EventType
		or MapMarkerEventType.MAP_MARKER_EVENT_TRANS_DOOR == EventType then
		return MapMarkerPriority.Telepo
	elseif MapMarkerEventType.MAP_MARKER_EVENT_TOOLTIP == EventType then
		return MapMarkerPriority.FixPoint
	end

	return MapMarkerPriority.FixPoint
end

function MapMarkerFixedPoint:GetAlpha()
	if not MapUtil.IsAreaMap(self.UIMapID) then
		return 1
	end

	if _G.FogMgr:IsAllActivate(self.MapID) then
		return 1
	end
	local MarkerCfg = self.MarkerCfg
	if not MarkerCfg then
		return 1
	end
	local InDiscovery = MarkerCfg.InDiscovery
	if InDiscovery and InDiscovery > 0 then
		if not _G.FogMgr:IsInFlag(self.MapID, InDiscovery) then
			return 0.5
		end
	end
	return 1
end


return MapMarkerFixedPoint