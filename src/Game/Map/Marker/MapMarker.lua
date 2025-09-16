--
-- Author: anypkvcai
-- Date: 2022-12-08 9:54
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapSetting = require("Game/Map/MapSetting")
local MapVM = require("Game/Map/VM/MapVM")

local MAP_PANEL_HALF_WIDTH = MapDefine.MapConstant.MAP_PANEL_HALF_WIDTH
local MAP_RADIUS = MapDefine.MapConstant.MAP_RADIUS
local MapMarkerConfigs = MapDefine.MapMarkerConfigs
local ESlateVisibility = _G.UE.ESlateVisibility


---@class MapMarker 地图上的标记
---@field ID number @不同类型的标记ID意义不同，例如：固定点是表里的ID，Actor是EntityID
---@field UIMapID number @当前查看地图UIMapID，例如：如果某个FixPoint，当前是显示在二级地图，这里是二级地图的UIMapID
---@field AreaUIMapID number @标记所在三级地图UIMapID，这个不随着查看哪级地图发生变化
---@field MapID number @标记所在三级地图MapID
---@field Name string @名称
---@field IconPath string @图标路径
---@field IsFollow boolean @是否追踪状态
local MapMarker = LuaClass()

---Ctor
function MapMarker:Ctor()
	self:Reset()
end

function MapMarker:Reset()
	self.ID = 0
	self.UIMapID = 0
	self.AreaUIMapID = 0
	self.MapID = 0

	self.Name = ""
	self.IconPath = ""

	self.IsFollow = false

	-- 三级地图的UI坐标，除了固定点走配表外，其他标记一般都是地图世界坐标转换而来的地图UI坐标
	self.AreaUIPosX = 0
	self.AreaUIPosY = 0

	-- 三级地图的世界坐标
	self.WorldPosX = 0
	self.WorldPosY = 0
	self.WorldPosZ = 0

	-- 二级地图需要显示部分区域地图的标记（比如：水晶、主角标记 ）会用到下面数据来坐标转换
	self.RegionPosX = nil
	self.RegionPosY = nil
	self.RegionScale = nil

	-- 二级地图大图标上的UI坐标（目前只有金蝶地图使用）
	self.RegionIconUIPosX = nil
	self.RegionIconUIPosY = nil

	-- 一级地图需要显示的UI坐标
	self.WorldUIPosX = nil
	self.WorldUIPosY = nil
end

---GetType 标记类型
---@return MapMarkerType
function MapMarker:GetType()

end

---GetBPType 标记蓝图类型
---@return MapMarkerBPType
function MapMarker:GetBPType()

end

---InitMarker @初始化Marker ID和UIMapID已经在已创建的时候统一设置了
---@param Params any
function MapMarker:InitMarker(Params)

end

---UpdateMarker @更新Marker， Params可能和InitMarker的参数不同
---@param Params any
function MapMarker:UpdateMarker(Params)

end

---SetID
---@param ID number
function MapMarker:SetID(ID)
	self.ID = ID
end

---GetID
---@return number
function MapMarker:GetID()
	return self.ID
end

---GetSubID
---@return number
function MapMarker:GetSubID()
	return nil
end

---SetUIMapID
---@param UIMapID number
function MapMarker:SetUIMapID(UIMapID)
	self.UIMapID = UIMapID
end

---GetUIMapID
---@return number
function MapMarker:GetUIMapID()
	return self.UIMapID
end

---@param MapID number
function MapMarker:SetMapID(MapID)
	self.MapID = MapID
end

---@return number
function MapMarker:GetMapID()
	return self.MapID
end

---@param AreaUIMapID number
function MapMarker:SetAreaUIMapID(AreaUIMapID)
	self.AreaUIMapID = AreaUIMapID
end

---@return number
function MapMarker:GetAreaUIMapID()
	return self.AreaUIMapID
end

---SetName
---@param Name string
function MapMarker:SetName(Name)
	self.Name = Name
end

---GetName
---@return string
function MapMarker:GetName()
	return self.Name
end

---SetIconPath
---@param IconPath string
function MapMarker:SetIconPath(IconPath)
	self.IconPath = IconPath
end

---GetIconPath
---@return string
function MapMarker:GetIconPath()
	return self.IconPath
end

---IsNameVisible @缩放比例为Scale时，标记点名字是否可见。默认可见，受文字设置影响
---@param Scale number
---@return boolean
function MapMarker:IsNameVisible(Scale)
	if not string.isnilorempty(self.Name) then
		if self:IsCanShowInDiscovery() then
			if MapSetting.GetSettingValue(MapSetting.SettingType.ShowText) > 0 then
				return true
			end
		end
	end

	return false
end

---IsIconVisible @缩放比例为Scale时，标记点图标是否可见。默认可见，受图标设置影响
---@param Scale number
---@return boolean
function MapMarker:IsIconVisible(Scale)
	if not string.isnilorempty(self.IconPath) then
		if self:GetIsFollow() then
			return true
		end

		if self:IsCanShowInDiscovery() then
			if MapSetting.GetSettingValue(MapSetting.SettingType.ShowIcon) > 0 then
				return true
			end
		end
	end

	return false
end

---GetNameVisibility
---@param Scale table
---@return ESlateVisibility
function MapMarker:GetNameVisibility(Scale)
	return self:IsNameVisible(Scale) and ESlateVisibility.SelfHitTestInvisible or ESlateVisibility.Collapsed
end

---GetIconVisibility
---@param Scale ESlateVisibility
---@return ESlateVisibility
function MapMarker:GetIconVisibility(Scale)
	return self:IsIconVisible(Scale) and ESlateVisibility.SelfHitTestInvisible or ESlateVisibility.Collapsed
end

---是否在迷雾下显示，默认显示
---备注：出于性能考虑，标记所属的迷雾ID即InDiscovery一般建议是离线填到配表里，只有坐标不固定的标记才会运行时计算InDiscovery
---@return boolean
function MapMarker:IsCanShowInDiscovery()
	return true
end

---显示是否受迷雾控制，默认不受控制
---@return boolean
function MapMarker:IsControlByFog()
	return false
end

---显示是否受开启条件控制，比如指定任务是否完成，默认不受控制
---@return boolean
function MapMarker:IsControlByOpenFlag()
	return false
end


---GetAlpha
---@return number
function MapMarker:GetAlpha()
	return 1
end

---GetTipsName
---@return string
function MapMarker:GetTipsName()
	return ""
end

---GetIsEnableHitTest @是否可以点击
---@return boolean
function MapMarker:GetIsEnableHitTest()
	return true
end

---GetAreaMapPos @获取标记点在区域地图（三级地图）上的坐标
---@return number, number  @X和Y的坐标
function MapMarker:GetAreaMapPos()
	return self.AreaUIPosX, self.AreaUIPosY
end

---SetAreaMapPos @设置标记点在区域地图（三级地图）上的坐标
---@param X number
---@param Y number
function MapMarker:SetAreaMapPos(X, Y)
	self.AreaUIPosX = X
	self.AreaUIPosY = Y
end

---GetPosition @获取在当前地图的坐标
---二级地图需要显示部分区域地图的标记，需要坐标转换
---一级地图的标记坐标问题，按规则排列
---@return number, number  @X和Y的坐标
function MapMarker:GetPosition()
	local X, Y = self:GetAreaMapPos()

	if nil ~= self.RegionPosX and nil ~= self.RegionPosY and nil ~= self.RegionScale then
		if self.RegionIconUIPosX and self.RegionIconUIPosY then
			return self.RegionIconUIPosX, self.RegionIconUIPosY
		else
			return MapUtil.ConvertAreaPos2Region(X, Y, self.RegionPosX, self.RegionPosY, self.RegionScale)
		end
	end

	if MapUtil.IsWorldMap(self.UIMapID) then
		X, Y = MapUtil.ConvertAreaPos2World(X, Y)
		if nil ~= self.WorldUIPosX and nil ~= self.WorldUIPosY then
			return MapUtil.ConvertAreaPos2World(self.WorldUIPosX, self.WorldUIPosY)
		end
	end

	return X or 0, Y or 0
end

---SetRegionInfo 设置在二级地图上的坐标
---@param RegionPosX number
---@param RegionPosY number
---@param RegionScale number
function MapMarker:SetRegionInfo(RegionPosX, RegionPosY, RegionScale)
	self.RegionPosX = RegionPosX
	self.RegionPosY = RegionPosY
	self.RegionScale = RegionScale

	self.RegionIconUIPosX = nil
	self.RegionIconUIPosY = nil
	self.InRegionIconUI = nil

	self.WorldUIPosX = nil
	self.WorldUIPosY = nil
	self.InWorldIconUI = nil
end

---SetRegionIconInfo 设置在二级地图大图标上的坐标
---@param RegionIconUIPosX number
---@param RegionIconUIPosY number
function MapMarker:SetRegionIconInfo(RegionIconUIPosX, RegionIconUIPosY)
	self.RegionIconUIPosX = RegionIconUIPosX
	self.RegionIconUIPosY = RegionIconUIPosY
	self.InRegionIconUI = true -- 标记当前在二级地图大图标上
end

---SetWorldInfo 设置在一级地图上的坐标
---@param WorldUIPosX number
---@param WorldUIPosY number
function MapMarker:SetWorldInfo(WorldUIPosX, WorldUIPosY)
	self.WorldUIPosX = WorldUIPosX
	self.WorldUIPosY = WorldUIPosY
	self.InWorldIconUI = true -- 标记当前在一级地图图标上

	self.RegionPosX = nil
	self.RegionPosY = nil
	self.RegionScale = nil

	self.RegionIconUIPosX = nil
	self.RegionIconUIPosY = nil
	self.InRegionIconUI = nil
end

---获取标记世界坐标
function MapMarker:GetWorldPos()
	return self.WorldPosX, self.WorldPosY, self.WorldPosZ
end

---设置标记世界坐标
function MapMarker:SetWorldPos(X, Y, Z)
	self.WorldPosX = X
	self.WorldPosY = Y
	self.WorldPosZ = Z
end

---GetPriority 获取显示优先级
---@return number
function MapMarker:GetPriority()
	local Cfg = MapMarkerConfigs[self:GetType()]
	if nil ~= Cfg then
		return Cfg.Priority
	end

	return 0
end

---IsActive 是否激活状态
---@return boolean
function MapMarker:GetIsActive()
	return true
end

---是否追踪状态
---@return boolean
function MapMarker:GetIsFollow()
	return self.IsFollow
end

---更新追踪状态
function MapMarker:UpdateFollow()
	self.IsFollow = false

	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo == nil then
		return
	end
	if FollowInfo.FollowType ~= self:GetType() then
		return
	end
	if FollowInfo.FollowSubType ~= self:GetSubType() then
		return
	end
	if self.ID == FollowInfo.FollowID  then
		self.IsFollow = true
	end
end

---切换追踪状态
function MapMarker:ToggleFollow()
	if self:GetIsFollow() then
		_G.WorldMapMgr:CancelMapFollow()
	else
		self:StartMapFollow()

		if self:GetType() == MapDefine.MapMarkerType.Placed then
			_G.WorldMapMgr:ReportData(MapDefine.MapReportType.MapFollow, "2")
		else
			_G.WorldMapMgr:ReportData(MapDefine.MapReportType.MapFollow, "1", self:GetType())
		end
	end
end

---发起追踪
function MapMarker:StartMapFollow()
	local FollowID = self:GetID()
	local FollowType = self:GetType()
	local FollowSubType = self:GetSubType()
	local FollowUIMapID = self:GetAreaUIMapID()
	local FollowMapID = self:GetMapID()

	_G.WorldMapMgr:SetMapFollowInfo(FollowID, FollowType, FollowSubType, FollowUIMapID, FollowMapID, nil, true)
end

---获取标记子类型
---部分标记类型，一个类型里包含多种子类型，需要子类型和ID来唯一确定一个标记
---@return number
function MapMarker:GetSubType()
	return 0
end

---OnTriggerMapEvent 点击地图标记
function MapMarker:OnTriggerMapEvent(EventParams)

end

---@return string
function MapMarker:ToString()
	return string.format("MapMarker ID=%d, Type=%d, Name=%s, TipsName=%s"
		, self:GetID(), self:GetType(), self:GetName(), self:GetTipsName())
end

---UpdateView 更新显示,一些需要动态刷新的显示的
function MapMarker:UpdateView()
end

---标记是否在小地图视野内
---@return boolean
function MapMarker:IsInMiniMapVision()
	local X, Y = self:GetAreaMapPos()
	local MajorPos = MapVM:GetMajorPosition()

	local OffsetX = X - MAP_PANEL_HALF_WIDTH - MajorPos.X
	local OffsetY = Y - MAP_PANEL_HALF_WIDTH - MajorPos.Y
	if math.abs(OffsetX) > MAP_RADIUS or math.abs(OffsetY) > MAP_RADIUS then
		return false
	end

	return true
end

---标记是否在小地图显示
---@return boolean
function MapMarker:NeedShowInMiniMap()
	return self:IsInMiniMapVision()
end

-----IsDisplayOnMap @是否在地图显示
-----@param UIMapID number
-----@param ContentType MapContentType
--function MapMarker:IsDisplayOnMap(UIMapID, ContentType)
--	return self.UIMapID == UIMapID
--end

-----IsDisplayOnMiniMap @是否在小地图显示
-----@param UIMapID number
--function MapMarker:IsDisplayOnMiniMap(UIMapID)
--	return self.UIMapID == UIMapID
--end
--
-----IsDisplayOnMiddleMap @是否在中地图显示
-----@param UIMapID number
--function MapMarker:IsDisplayOnMiddleMap(UIMapID)
--	return self.UIMapID == UIMapID
--end
--
-----IsDisplayOnWorldMap @是否在世界地图显示
-----@param UIMapID number
--function MapMarker:IsDisplayOnWorldMap(UIMapID)
--	return self.UIMapID == UIMapID
--end

return MapMarker