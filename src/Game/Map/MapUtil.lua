-- Author: anypkvcai
--
-- Date: 2022-12-08 10:18
-- Description:
--

local MapCfg = require("TableCfg/MapCfg")
local MapUICfg = require("TableCfg/MapUICfg")
local MapTypeCfg = require("TableCfg/MapTypeCfg")
local MapIconCfg = require("TableCfg/MapIconCfg")
local PlaceNameCfg = require("TableCfg/PlaceNameCfg")
local MapSymbolCfg = require("TableCfg/MapSymbolCfg")
local TeleportCrystalCfg = require("TableCfg/TeleportCrystalCfg")
local MapMap2areaCfg = require("TableCfg/MapMap2areaCfg")
local MapArea2regionCfg = require("TableCfg/MapArea2regionCfg")
local MapRegionIconCfg = require("TableCfg/MapRegionIconCfg")
local MapMarkerCfg = require("TableCfg/MapMarkerCfg")
local MapMarkerRegionCfg = require("TableCfg/MapMarkerRegionCfg")
local AetherCurrentCfg = require("TableCfg/AetherCurrentCfg")
local DiscoverNoteCfg = require("TableCfg/DiscoverNoteCfg")
local WildBoxMoundCfg = require("TableCfg/WildBoxMoundCfg")

local MapDefine = require("Game/Map/MapDefine")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local ActorUtil = require("Utils/ActorUtil")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local TeamHelper = require("Game/Team/TeamHelper")

local MapConstant = MapDefine.MapConstant
local MapMarkerBPConfigs = MapDefine.MapMarkerBPConfigs
local MapType = MapDefine.MapType
local MapContentType = MapDefine.MapContentType
local MapMarkerBPType = MapDefine.MapMarkerBPType
local MapFixPointMakerColorType = MapDefine.MapFixPointMakerColorType

local MapMarkerLayout = ProtoRes.MapMarkerLayout
local MapMarkerEventType = ProtoRes.MapMarkerEventType
local TELEPORT_CRYSTAL_TYPE = ProtoRes.TELEPORT_CRYSTAL_TYPE
local TransitionType = ProtoRes.transition_type

local MAP_PANEL_HALF_WIDTH = MapConstant.MAP_PANEL_HALF_WIDTH
local MAP_REGION_MARKER_RATION = MapConstant.MAP_REGION_MARKER_RATION
--local MAP_MAX_UI_COORDINATE = MapConstant.MAP_MAX_UI_COORDINATE
--local AREA_MAP_DEF_COMPENSATION = MapConstant.AREA_MAP_DEF_COMPENSATION

local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR
local FVector2D = _G.UE.FVector2D


---@class MapUtil
local MapUtil = {

}

function MapUtil.GetMapName(UIMapID)
	local NameUI = MapUICfg:FindValue(UIMapID, "NameUI")
	return MapUtil.GetPlaceName(NameUI)
end

function MapUtil.GetMapFloorName(UIMapID)
	local FloorNameUI = MapUtil.GetMapFloorNameUI(UIMapID)
	if FloorNameUI ~= nil and FloorNameUI ~= 0 then
		return MapUtil.GetPlaceName(FloorNameUI)
	end
end

function MapUtil.GetUIMapID(MapID)
	return MapCfg:FindValue(MapID, "UIMapID")
end

function MapUtil.GetUIMapIDByMarker(MarkerID)
	local FindDBCache = MapUtil.MarkerID2UIMapIDDBCache
	if FindDBCache == nil then
		MapUtil.MarkerID2UIMapIDDBCache = {}
		FindDBCache = MapUtil.MarkerID2UIMapIDDBCache
	end
	if FindDBCache[MarkerID] then
		return FindDBCache[MarkerID]
	end

	local SearchConditions = string.format("Marker = %d", MarkerID)
	local Cfg = MapUICfg:FindCfg(SearchConditions)
	if nil ~= Cfg then
		local UIMapID = Cfg.ID
		FindDBCache[MarkerID] = UIMapID
		return UIMapID
	end

	return 0
end

---清理地图查表的一些缓存
function MapUtil.ClearFindDBCache()
	MapUtil.MarkerID2UIMapIDDBCache = nil
	MapUtil.UIMapID2UpperUIMapIDDBCache = nil
end

function MapUtil.GetMapID(UIMapID)
	return MapUICfg:FindValue(UIMapID, "MapID")
end

function MapUtil.GetMapMarkerID(UIMapID)
	return MapUICfg:FindValue(UIMapID, "Marker")
end

function MapUtil.GetMapCategoryNameUI(UIMapID)
	return MapUICfg:FindValue(UIMapID, "CategoryNameUI")
end

function MapUtil.GetMapType(UIMapID)
	return MapUICfg:FindValue(UIMapID, "MapType")
end

function MapUtil.GetMapScale(UIMapID)
	return MapUICfg:FindValue(UIMapID, "Scale")
end

function MapUtil.GetMapFloorNameUI(UIMapID)
	return MapUICfg:FindValue(UIMapID, "FloorNameUI")
end

function MapUtil.GetMapNameUI(UIMapID)
	return MapUICfg:FindValue(UIMapID, "NameUI")
end

function MapUtil.GetDiscoveryFlag(UIMapID)
	return MapUICfg:FindValue(UIMapID, "DiscoveryFlag")
end

---根据版本号判断给定UIMapID是否开启
---@param UIMapID number
---@param VersionName string|nil 表里配的版本号，如果nil会多一次查表
function MapUtil.IsUIMapOpenByVersion(UIMapID, VersionName)
	if VersionName == nil then
		VersionName = MapUICfg:FindValue(UIMapID, "VersionName")
	end

	if string.isnilorempty(VersionName) then
		return true
	end

	return _G.ClientVisionMgr:CheckVersionByGlobalVersion(VersionName)
end


function MapUtil.GetFixedPointMarkerBPType(MarkerCfg)
	if MarkerCfg.Region > 0 then
		return MapMarkerBPType.Region
	end

	local TextType = MarkerCfg.TextType
	if TextType > 0 then
		return MapMarkerBPType.PlaceName
	end

	local Layout = MarkerCfg.Layout

	if MapMarkerLayout.MAP_MARKER_LAYOUT_LEFT == Layout then
		return MapMarkerBPType.CommIconLeft
	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_RIGHT == Layout then
		return MapMarkerBPType.CommIconRight
	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_TOP == Layout then
		return MapMarkerBPType.CommIconTop
	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_BOTTOM == Layout then
		return MapMarkerBPType.CommIconBottom

	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_TEXT_CENTER == Layout then
		return MapMarkerBPType.CommTextCenter
	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_TEXT_RIGHT == Layout then
		return MapMarkerBPType.CommTextRight
	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_TEXT_LEFT == Layout then
		return MapMarkerBPType.CommTextLeft

	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_NO_ICON_TEXT == Layout then
		return MapMarkerBPType.CommIconTop

	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_TEXT_CENTER_AREA == Layout then
		return MapMarkerBPType.CommTextCenter
	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_TEXT_RIGHT_AREA == Layout then
		return MapMarkerBPType.CommTextRight
	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_TEXT_LEFT_AREA == Layout then
		return MapMarkerBPType.CommTextLeft

	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_REGION_ICON == Layout then
		return MapMarkerBPType.RegionIcon
	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_WORLD_ICON == Layout then
		return MapMarkerBPType.WorldIcon
	end

	return MapMarkerBPType.CommIconBottom
end

---GetFixedPointMarkerColorType
---@param MarkerCfg table
---@param UIMapID number
function MapUtil.GetFixedPointMarkerColorType(MarkerCfg, UIMapID)
	local EventType = MarkerCfg.EventType
	local IsChangeMap = MapMarkerEventType.MAP_MARKER_EVENT_CHANGE_MAP == EventType
	if not IsChangeMap then
		return MapFixPointMakerColorType.Normal
	end

	local EventArg = MarkerCfg.EventArg
	local Type = MapUtil.GetMapType(UIMapID)

	if MapType.World == Type then
		return MapFixPointMakerColorType.Blue
	elseif MapType.Region == Type then
		if MapUtil.GetUpperUIMapID(EventArg) == UIMapID then
			return MapFixPointMakerColorType.Blue
		else
			return MapFixPointMakerColorType.Orange
		end
	else
		if MapUtil.GetUpperUIMapID(EventArg) == MapUtil.GetUpperUIMapID(UIMapID) then
			return MapFixPointMakerColorType.Blue
		else
			return MapFixPointMakerColorType.Orange
		end
	end
end

function MapUtil.IsRegionMarkerBPType(MarkerBPType)
	return MapMarkerBPType.Region == MarkerBPType
end

function MapUtil.IsQuestTargetBPType(MarkerBPType)
	return MapMarkerBPType.QuestTarget == MarkerBPType
end

function MapUtil.IsWorldMap(UIMapID)
	local Type = MapUtil.GetMapType(UIMapID)
	return MapType.World == Type
end

function MapUtil.IsAreaMap(UIMapID)
	local Type = MapUtil.GetMapType(UIMapID)
	return MapType.Area == Type
end

function MapUtil.IsRegionMap(UIMapID)
	local Type = MapUtil.GetMapType(UIMapID)
	return MapType.Region == Type
end

function MapUtil.IsMiniMapContentType(ContentType)
	return MapContentType.MiniMap == ContentType
end

---GetIconPath
---@param Icon number  @MapIconCfg表中的ID 表格复用端游字段名Icon
function MapUtil.GetIconPath(Icon)
	if nil == Icon or 0 == Icon then
		return
	end

	local IconPath = MapIconCfg:FindValue(Icon, "IconPath")
	if nil ~= IconPath then
		return IconPath
	end
end

---GetPlaceName
---@param ID number  @PlaceNameCfg表中的ID 表格复用端游字段名NameUI
function MapUtil.GetPlaceName(ID)
	if nil == ID or 0 >= ID then
		return ""
	end

	local Name = PlaceNameCfg:FindValue(ID, "Name")
	if nil ~= Name then
		Name = string.gsub(Name, "<br>", "\n")
		return Name
	end

	return LSTR(700008) -- "未知地名"
end

function MapUtil.GetMapMarkerBPName(MarkerBPType)
	local Config = MapMarkerBPConfigs[MarkerBPType]
	if nil == Config then
		return
	end

	return Config.BPName
end

function MapUtil.GetRegionMarkerTextAlignment(Layout)
	local X = 0.5
	local Y = 0.5

	if MapMarkerLayout.MAP_MARKER_LAYOUT_TEXT_RIGHT_AREA == Layout then
		X = 0
		Y = 0.5
	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_TEXT_LEFT_AREA == Layout then
		X = 1
		Y = 0.5
	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_TEXT_RIGHT == Layout then
		X = 0
		Y = 0.5
	elseif MapMarkerLayout.MAP_MARKER_LAYOUT_TEXT_LEFT == Layout then
		X = 1
		Y = 0.5
	end

	--print("GetRegionMarkerTextAlignment", Layout, X, Y)
	return _G.UE.FVector2D(X, Y)
end

---调整三级地图的缩放位置
---@param X number
---@param Y number
---@param Scale number
function MapUtil.AdjustMapMarkerPosition(Scale, X, Y)
	if X == nil or Y == nil then
		return 0, 0
	end

	-- 二三级地图的Size为2048。这里没考虑PVP地图的情况，PVP只有小地图Scale为1
	local HalfWidth = MAP_PANEL_HALF_WIDTH

	X = HalfWidth - (HalfWidth - X) * Scale
	Y = HalfWidth - (HalfWidth - Y) * Scale

	return X, Y
end

---调整一级地图的缩放位置
function MapUtil.AdjustWorldMapMarkerPosition(Scale, X, Y)
	if X == nil or Y == nil then
		return 0, 0
	end

	-- 二三级地图的Size为2048。这里没考虑PVP地图的情况，PVP只有小地图Scale为1
	--local HalfWidth = MAP_PANEL_HALF_WIDTH
	-- 【特殊】一级地图的Size为4096
	local HalfWidth = MapConstant.WORLDMAP_PANEL_HALF_WIDTH

	X = HalfWidth - (HalfWidth - X) * Scale
	Y = HalfWidth - (HalfWidth - Y) * Scale

	return X, Y
end

---调整地图的缩放位置，通过UIMapID区分地图类型
function MapUtil.AdjustMapMarkerPositionEx(Scale, X, Y, UIMapID)
	if UIMapID and MapUtil.IsWorldMap(UIMapID) then
		X, Y = MapUtil.AdjustWorldMapMarkerPosition(Scale, X, Y)
	else
		X, Y = MapUtil.AdjustMapMarkerPosition(Scale, X, Y)
	end

	return X, Y
end


local MapMarkerViewPosition = FVector2D()

---设置地图标记View的位置
---需要在一级地图和三级地图都显示的地图标记使用此接口，目前主要是主角标记和各种追踪标记
---@param Scale number @地图缩放比例
---@param ViewModel MapMarkerVM @地图标记ViewModel
---@param View MapMarkerView @地图标记View
function MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, View)
	if ViewModel == nil or View == nil then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if MapMarker == nil then
		return
	end

	local X, Y = ViewModel:GetPosition()
	if MapUtil.IsWorldMap(MapMarker:GetUIMapID()) then
		X, Y = MapUtil.AdjustWorldMapMarkerPosition(Scale, X, Y)
	else
		X, Y = MapUtil.AdjustMapMarkerPosition(Scale, X, Y)
	end
	MapMarkerViewPosition.X = X
	MapMarkerViewPosition.Y = Y
	UIUtil.CanvasSlotSetPosition(View, MapMarkerViewPosition)
end

---地图场景坐标转地图UI坐标
---@param X number @地图坐标
---@param Y number @地图坐标
---@param MapCenterOffsetX number @地图中心点和UI中心点偏移坐标
---@param MapCenterOffsetY number @地图中心点和UI中心点偏移坐标
---@param MapScale number @地图和UI的缩放比例
---@param IsLeftTop boolean @true：返回左上角坐标  false：返回中心点的坐标
---@param UIMapID number @地图UIMapID
---@return number, number
function MapUtil.ConvertMapPos2UI(X, Y, MapCenterOffsetX, MapCenterOffsetY, MapScale, IsLeftTop, UIMapID)
	if MapCenterOffsetX == nil or  MapCenterOffsetY == nil or MapScale == nil then
		return 0, 0
	end

	local Scale = MapScale * 0.01

	--补偿值
	--local Compensation = AREA_MAP_DEF_COMPENSATION * 0.2 * Scale
	local Compensation = 0

	--之前的映射方式:3D场景中X轴向右，Y轴向下，UI也是X轴向右，Y轴向下，所以XY一致
	--修正后映射方式:3D场景中X轴向下，Y轴向左，UI的X轴对应场景的-Y,Y轴对应场景的X
	local UIX = (-Y * 0.01 + MapCenterOffsetX) * Scale + Compensation
	local UIY = (X * 0.01 + MapCenterOffsetY) * Scale + Compensation
	-- local UIX = (X * 0.01 + MapCenterOffsetX) * Scale + Compensation
	-- local UIY = (Y * 0.01 - MapCenterOffsetY) * Scale + Compensation

	local HalfWidth = MAP_PANEL_HALF_WIDTH

	-- PVP地图的Size是720*720，普通三级地图Size是2048*2048，这里需要转换UI坐标
	if UIMapID and MapUtil.IsPVPUIMap(UIMapID) then
		HalfWidth = MapUtil.GetPVPUIMapHalfWidth(UIMapID)

		UIX = UIX * HalfWidth / MAP_PANEL_HALF_WIDTH
		UIY = UIY * HalfWidth / MAP_PANEL_HALF_WIDTH
	end

	if IsLeftTop then
		UIX = HalfWidth + UIX
		UIY = HalfWidth + UIY
	end

	return UIX, UIY
end


---PVP战场UI地图配置
local PVPUIMapConfig =
{
	[759] = 1, -- 角力学校地图
	[760] = 1, -- 火山之心地图
	[761] = 1, -- 九霄云上地图
}

function MapUtil.IsPVPUIMap(UIMapID)
	return PVPUIMapConfig[UIMapID] ~= nil
end

---获取PVP小地图标记点界面一半宽度
function MapUtil.GetPVPUIMapHalfWidth(UIMapID)
	local HalfWidth = MapConstant.PVPMAP_PANEL_HALF_WIDTH

	if UIMapID == 760 then
		-- 视觉要求PVP第二张地图放大
		HalfWidth = HalfWidth * 1.2
	end

	return HalfWidth
end


---ConvertUIPos2LeftTop @把地图中心UI坐标转为左上角坐标
---@param X number
---@param Y number
---@return number, number
function MapUtil.ConvertUIPos2LeftTop(X, Y, UIMapID)
	local HalfWidth = MAP_PANEL_HALF_WIDTH

	if UIMapID and MapUtil.IsPVPUIMap(UIMapID) then
		HalfWidth = MapUtil.GetPVPUIMapHalfWidth(UIMapID)
	end

	return X + HalfWidth, Y + HalfWidth
end

---将标记坐标（地图中心坐标）转换为世界地图UI坐标（左上角坐标）
function MapUtil.ConvertAreaPos2World(X, Y)
	local WorldMapHalfWidth = MapConstant.WORLDMAP_PANEL_HALF_WIDTH

	X = X + WorldMapHalfWidth
	Y = Y + WorldMapHalfWidth

	return X, Y
end

---地图UI坐标转地图场景坐标
---@param X number @UI坐标
---@param Y number @UI坐标
---@param MapCenterOffsetX number @地图中心点和UI中心点偏移坐标
---@param MapCenterOffsetY number @地图中心点和UI中心点偏移坐标
---@param MapScale number @地图和UI的缩放比例
---@param IsLeftTop boolean true：X和Y为左上角坐标  false：X和Y为中心点的坐标
---@return number,number
function MapUtil.ConvertUIPos2Map(X, Y, MapCenterOffsetX, MapCenterOffsetY, MapScale, IsLeftTop)
	if X == nil or Y == nil then
		return 0, 0
	end

	local HalfWidth = MAP_PANEL_HALF_WIDTH
	if IsLeftTop then
		X = X - HalfWidth
		Y = Y - HalfWidth
	end

	--补偿值
	local Compensation = 0

	X = (X - Compensation) / (MapScale * 0.01)
	Y = (Y - Compensation) / (MapScale * 0.01)

	X = (X - MapCenterOffsetX) * 100
	Y = (Y - MapCenterOffsetY) * 100

	--这里做下修正,规则说明参考MapUtil.ConvertMapPos2UI
	return Y, -X
	--return X, Y
end

---ConvertAreaPos2Region
---@param X number
---@param Y number
---@param RegionPosX number
---@param RegionPosY number
---@param RegionScale number @MapMarkerRegion PictureScale
function MapUtil.ConvertAreaPos2Region(X, Y, RegionPosX, RegionPosY, RegionScale)
	local HalfWidth = MAP_PANEL_HALF_WIDTH

	X = (X - HalfWidth) * RegionScale * 0.01 * MAP_REGION_MARKER_RATION + RegionPosX
	Y = (Y - HalfWidth) * RegionScale * 0.01 * MAP_REGION_MARKER_RATION + RegionPosY

	return X, Y
end


---获取当前主角所在的地图完整名称
---@return string
function MapUtil.GetMapFullName()
	local MajorUIMapID = _G.MapMgr:GetUIMapID()

	local MapName = MapUtil.GetMapName(MajorUIMapID) or LSTR(700009) -- "未知地图"
	local MapFullName = MapName

	local MapFloorName = MapUtil.GetMapFloorName(MajorUIMapID)
	if MapFloorName and MapFloorName ~= "" then
		MapFullName = MapName .. "·" ..MapFloorName
	else
		-- 区域名称
		local MapAreaName
		local MapAreaMgr = _G.MapAreaMgr
		if MapAreaMgr.CurrSpot > 0 then
			MapAreaName = MapUtil.GetPlaceName(MapAreaMgr.CurrSpot)
		elseif MapAreaMgr.CurrBlock > 0 then
			MapAreaName = MapUtil.GetPlaceName(MapAreaMgr.CurrBlock)
		end
		if MapAreaName and MapAreaName ~= "" then
			MapFullName = MapName .. "·" ..MapAreaName
		end
	end

	return MapFullName
end

---获取给定UI坐标的显示坐标
---@param TopLeftPosition table UI坐标
function MapUtil.GetCoordinateText(TopLeftPosition)
	--print("[MapUtil.GetCoordinateText] TopLeftPosition ", TopLeftPosition.X, TopLeftPosition.Y)

	--[[
	需求：手游的显示坐标计算需要同端游保持一致
	以地图左上角作为坐标起始点x=1,y=1，右下角坐标为x=42,y=42，且坐标都是正数
	等于将UI地图宽度MAP_PANEL_WIDTH分成41格Grid，每个格子大小约50*50

	端游有些地图（如主城）右下角是21.4，等于每个格子大小约100*100
	端游有些地图（如8人本）右下角是11.2，等于每个格子大小约200*200
	端游有些地图（如旅馆）右下角是6.1，等于每个格子大小约400*400
	具体表格地图比例Scale字段决定
	--]]
	local UIGridSize = 50
	local MajorUIMapID = _G.MapMgr:GetUIMapID()
	local Scale = MapUtil.GetMapScale(MajorUIMapID)
	if Scale and Scale > 0 then
		UIGridSize = Scale / 2
	end

	local X = TopLeftPosition.X / UIGridSize
	local Y = TopLeftPosition.Y / UIGridSize
	return string.format("(%.1f, %.1f)", X + 1, Y + 1)
	--return string.format("(%.1f, %.1f)", TopLeftPosition.X * 0.01 + 1, TopLeftPosition.Y * 0.01 + 1)
end

function MapUtil.GetRegionUIMapID(UIMapID)
	local CategoryNameUI = MapUtil.GetMapCategoryNameUI(UIMapID)
	local SearchConditions = string.format("CategoryNameUI = %d AND MapType >= %d", CategoryNameUI, MapType.Region)
	local Cfg = MapUICfg:FindCfg(SearchConditions)
	if nil ~= Cfg then
		return Cfg.ID
	end
end

function MapUtil.GetUpperUIMapID(UIMapID)
	local FindDBCache = MapUtil.UIMapID2UpperUIMapIDDBCache
	if FindDBCache == nil then
		MapUtil.UIMapID2UpperUIMapIDDBCache = {}
		FindDBCache = MapUtil.UIMapID2UpperUIMapIDDBCache
	end
	if FindDBCache[UIMapID] then
		return FindDBCache[UIMapID]
	end

	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		return
	end

	local UpperUIMapID = 0
	if MapType.Area == Cfg.MapType then
		UpperUIMapID = MapUtil.GetRegionUIMapID(UIMapID)
	elseif MapType.Region == Cfg.MapType then
		UpperUIMapID = MapTypeCfg:FindValue(Cfg.MapType, "WorldMap")
	end

	FindDBCache[UIMapID] = UpperUIMapID

	return UpperUIMapID
end

---SortComparison
---@param Left MapUICfg
---@param Right MapUICfg
---@private
function MapUtil.SortMapUICfg(ListMapUICfg, KeyName)
	local function SortComparison(Left, Right)
		local LeftKey = Left[KeyName]
		local RightKey = Right[KeyName]

		if LeftKey ~= RightKey then
			return LeftKey < RightKey
		end

		if Left.ID ~= Right.ID then
			return Left.ID < Right.ID
		end

		return false
	end

	table.sort(ListMapUICfg, SortComparison)
end

function MapUtil.GetAdjacentMapList(UIMapID)
	local MapList = {}
	local Type = MapUtil.GetMapType(UIMapID)
	if nil == Type then
		return MapList
	end

	local SearchConditions
	local KeyName

	if MapType.Area == Type then
		local CategoryNameUI = MapUtil.GetMapCategoryNameUI(UIMapID)
		SearchConditions = string.format("CategoryNameUI = %d AND MapType == %d AND NameUI > 0 AND PriorityUI > 0", CategoryNameUI, Type)
		KeyName = "PriorityUI"
	else
		SearchConditions = string.format("MapType == %d AND NameUI > 0 AND PriorityUI > 0", Type)
		KeyName = "PriorityCategoryUI"
	end

	local AllCfg = MapUICfg:FindAllCfg(SearchConditions)
	local NameUIs = {}
	for i = 1, #AllCfg do
		local Cfg = AllCfg[i]
		if not NameUIs[Cfg.NameUI] then
			table.insert(MapList, Cfg)
			NameUIs[Cfg.NameUI] = true
		end
	end

	MapUtil.SortMapUICfg(MapList, KeyName)

	return MapList
end

function MapUtil.GetMapTipsName(MarkerCfg)
	local EventType = MarkerCfg.EventType
	local EventArg = MarkerCfg.EventArg

	if MapMarkerEventType.MAP_MARKER_EVENT_TELEPO == EventType
		or MapMarkerEventType.MAP_MARKER_EVENT_TRANS_DOOR == EventType then
		local CrystalName = TeleportCrystalCfg:FindValue(EventArg, "CrystalName")
		return CrystalName or LSTR(700010)
	elseif MapMarkerEventType.MAP_MARKER_EVENT_TOOLTIP == EventType then
		if EventArg > 0 then
			local PlaceName = MapUtil.GetPlaceName(EventArg)
			if nil ~= PlaceName then
				return PlaceName
			end
		end
	end

	local Icon = MarkerCfg.Icon
	local Name
	if Icon > 0 then
		Name = MapSymbolCfg:FindValue(Icon, "Name")
	end

	if nil == Name then
		Name = MarkerCfg.Name
	end

	return MapUtil.GetPlaceName(Name)
end


---获取传送水晶名称
---@param CrystalID number 水晶ID
---@return string
function MapUtil.GetTransferCrystalName(CrystalID)
	local CrystalCfg = TeleportCrystalCfg:FindCfgByKey(CrystalID)
	if CrystalCfg then
		-- 优先使用“地图传送水晶名称”
		if CrystalCfg.MapTransferName then
			return CrystalCfg.MapTransferName
		end

		-- 使用“水晶名称”
		if CrystalCfg.CrystalName then
			return CrystalCfg.CrystalName
		end
	end

	return LSTR(700010) -- "未知水晶名"
end

---获取传送水晶位置
---@param CrystalID number 传送水晶ID
---@return table
function MapUtil.GetTransferCrystalPos(CrystalID)
	local CrystalCfg = TeleportCrystalCfg:FindCfgByKey(CrystalID)
	if CrystalCfg then
		return {X = CrystalCfg.X, Y = CrystalCfg.Y, Z = CrystalCfg.Z}
	end
end

---判断给定传送水晶是传送大水晶
---@param CrystalID number 传送水晶ID
---@return boolean
function MapUtil.IsAcrossMapCrystal(CrystalID)
	local CrystalType = TeleportCrystalCfg:FindValue(CrystalID, "Type")
	if CrystalType == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP then
		return true
	end

	return false
end

---判断给定传送水晶是传送小水晶
---@param CrystalID number 传送水晶ID
---@return boolean
function MapUtil.IsCurrentMapCrystal(CrystalID)
	local CrystalType = TeleportCrystalCfg:FindValue(CrystalID, "Type")
	if CrystalType == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_CURRENTMAP then
		return true
	end

	return false
end

---判断给定地图标记是传送水晶
function MapUtil.IsMapCrystalByMarkerCfg(MarkerCfg)
	if MapMarkerEventType.MAP_MARKER_EVENT_TELEPO == MarkerCfg.EventType then
		return true
	end

	return false
end

---判断给定地图标记是传送大水晶
function MapUtil.IsAcrossMapCrystalByMarkerCfg(MarkerCfg)
	if MapMarkerEventType.MAP_MARKER_EVENT_TELEPO == MarkerCfg.EventType then
		local CrystalID = MarkerCfg.EventArg
		return MapUtil.IsAcrossMapCrystal(CrystalID)
	end

	return false
end

---判断给定地图标记是传送小水晶
function MapUtil.IsCurrentMapCrystalByMarkerCfg(MarkerCfg)
	if MapMarkerEventType.MAP_MARKER_EVENT_TELEPO == MarkerCfg.EventType then
		local CrystalID = MarkerCfg.EventArg
		return MapUtil.IsCurrentMapCrystal(CrystalID)
	end

	return false
end

---判断给定地图是否有传送大水晶，一般对应大主城和野外
function MapUtil.MapHasAcrossMapCrystal(UIMapID)
	local MarkerID = MapUtil.GetMapMarkerID(UIMapID)
	local AllCfg = MapMarkerCfg:WorldMapGetAllMarkerCfgByEventType(MarkerID, MapMarkerEventType.MAP_MARKER_EVENT_TELEPO)
	if nil == AllCfg then
		return false, nil
	end

	for i = 1, #AllCfg do
		local Cfg = AllCfg[i]
		if MapUtil.IsAcrossMapCrystalByMarkerCfg(Cfg) then
			return true, Cfg
		end
	end

	return false, nil
end

---判断给定地图是否只有传送小水晶，一般对应小主城
function MapUtil.MapHasOnlyCurrentMapCrystal(UIMapID)
	local MarkerID = MapUtil.GetMapMarkerID(UIMapID)
	local AllCfg = MapMarkerCfg:WorldMapGetAllMarkerCfgByEventType(MarkerID, MapMarkerEventType.MAP_MARKER_EVENT_TELEPO)
	if nil == AllCfg then
		return false
	end
	if #AllCfg == 0 then
		return false
	end

	for i = 1, #AllCfg do
		local Cfg = AllCfg[i]
		if MapUtil.IsAcrossMapCrystalByMarkerCfg(Cfg) then
			return false, Cfg
		end
	end

	return true
end


function MapUtil.GenerateMarkerID()
	return TimeUtil.GetServerTimeMS()
end

function MapUtil.GetCommMarkerTextColor(MapMarker)
	local ColorType = MapFixPointMakerColorType.Normal
	if MapMarker.GetMarkerCfg then
		ColorType = MapUtil.GetFixedPointMarkerColorType(MapMarker:GetMarkerCfg(), MapMarker:GetUIMapID())
	end

	local ColorHex = "ffffff"
	local OutlineColorHex = "3f310fbf"
	local FontSize = 22

	if MapFixPointMakerColorType.Blue == ColorType then
		ColorHex = "ffffff"
		OutlineColorHex = "bd8213bf"
		FontSize = 22
	elseif MapFixPointMakerColorType.Orange == ColorType then
		ColorHex = "fff6abff"
		OutlineColorHex = "583e21bf"
		FontSize = 30
	end

	return ColorHex, OutlineColorHex, FontSize
end

--根据MapID获取聊天系统中地图超链接中显示的地图名称
---@param MapID number
function MapUtil.GetChatHyperlinkMapName(MapID)
	local UIMapID = MapUtil.GetUIMapID(MapID)
	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		return
	end

	local MapFloorName = MapUtil.GetMapFloorName(UIMapID)
	if MapFloorName and MapFloorName ~= "" then
		return MapFloorName
	end
	return MapUtil.GetMapName(UIMapID)
end

---获取玩家自己所在地图ID 和位置
---@return MapID  @number 所在地图ID
---@return Position  @table 坐标 X Y
function MapUtil.GetMajorMapIDAndPosition()
	local MapID = _G.MapMgr:GetMapID()
	local Position = _G.MapVM:GetMajorLeftTopPosition()
	return MapID, Position
end


---获取Region地图（二级地图）列表
---@return table
function MapUtil.GetAllRegionMapList()
	local SearchConditions = string.format("MapType == %d AND NameUI > 0 AND PriorityCategoryUI > 0",  MapType.Region)
	local KeyName = "PriorityCategoryUI"

	local AllCfg = MapUICfg:FindAllCfg(SearchConditions)
	local MapList = {}
	local NameUIs = {}
	for i = 1, #AllCfg do
		local Cfg = AllCfg[i]
		if not NameUIs[Cfg.NameUI] then
			table.insert(MapList, Cfg)
			NameUIs[Cfg.NameUI] = true
		end
	end

	MapUtil.SortMapUICfg(MapList, KeyName)

	return MapList
end

---获取Area地图（三级地图）列表
---@param UIMapID number   @同CategoryNameUI的UIMapID
---@return table
function MapUtil.GetAllAreaMapList(UIMapID)
	local CategoryNameUI = MapUtil.GetMapCategoryNameUI(UIMapID)
	local SearchConditions = string.format("CategoryNameUI = %d AND MapType == %d AND NameUI > 0 AND PriorityUI > 0", CategoryNameUI, MapType.Area)
	local KeyName = "PriorityUI"

	local AllCfg = MapUICfg:FindAllCfg(SearchConditions)
	local MapList = {}
	local NameUIs = {}
	for i = 1, #AllCfg do
		local Cfg = AllCfg[i]
		if not NameUIs[Cfg.NameUI] then
			table.insert(MapList, Cfg)
			NameUIs[Cfg.NameUI] = true
		end
	end

	MapUtil.SortMapUICfg(MapList, KeyName)

	return MapList
end

---获取三级地图下面的细分地图（分层）列表
---@param UIMapID number
---@return table
function MapUtil.GetAreaDownMapList(UIMapID)
	local NameUI = MapUtil.GetMapNameUI(UIMapID)
	if NameUI == 0 then
		return {}
	end
	local SearchConditions = string.format("NameUI = %d AND FloorNameUI > 0 AND PriorityFloorUI > 0", NameUI)
	local KeyName = "PriorityFloorUI"

	local AllCfg = MapUICfg:FindAllCfg(SearchConditions)
	local MapList = {}
	local FloorNameUIs = {}
	for i = 1, #AllCfg do
		local Cfg = AllCfg[i]
		if not FloorNameUIs[Cfg.FloorNameUI] then
			table.insert(MapList, Cfg)
			FloorNameUIs[Cfg.FloorNameUI] = true
		end
	end

	MapUtil.SortMapUICfg(MapList, KeyName)

	return MapList
end

---查询玩家是否在当前地图 或者 当前地图的下层地图
---@param UIMapID number
---@return boolean  @false 不在该地图  @true 存在
function MapUtil.MajorInHere(UIMapID)
	local CurrentMapType = MapUtil.GetMapType(UIMapID)
	if MapType.Area == CurrentMapType then
		--return _G.MapMgr:GetMapID() == MapUtil.GetMapID(UIMapID)
		return MapUtil.GetMapNameUI(_G.MapMgr:GetUIMapID()) == MapUtil.GetMapNameUI(UIMapID)
	elseif MapType.Region == CurrentMapType then
		return MapUtil.GetMapCategoryNameUI(_G.MapMgr:GetUIMapID()) == MapUtil.GetMapCategoryNameUI(UIMapID)
	end
	return false
end

---根据MapID查询地图是否已经解锁
---@param UIMapID number
---@return boolean  @false 暂未解锁  @true 已经解锁
function MapUtil.CheckMapIsUnLock(UIMapID)
	return true
end

---获取一级地图UIMapID
function MapUtil.GetWorldUIMapID()
	return MapTypeCfg:FindValue(MapType.Region, "WorldMap")
end


---地图场景坐标转地图UI坐标
---@param Location FVector
---@param UIMapID number
---@return number, number
function MapUtil.GetUIPosByLocation(Location, UIMapID)
	if nil == Location then
		return  0, 0
	end

	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		return 0, 0
	end

	local MapScale = Cfg.Scale
	local MapOffsetX = Cfg.OffsetX
	local MapOffsetY = Cfg.OffsetY

	return MapUtil.ConvertMapPos2UI(Location.X, Location.Y, MapOffsetX, MapOffsetY, MapScale, true, UIMapID)
end

---地图场景坐标转地图UI坐标
---@return number, number
function MapUtil.GetUIPosByXY(X, Y, UIMapID)
	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		return 0, 0
	end

	local MapScale = Cfg.Scale
	local MapOffsetX = Cfg.OffsetX
	local MapOffsetY = Cfg.OffsetY

	return MapUtil.ConvertMapPos2UI(X, Y, MapOffsetX, MapOffsetY, MapScale, true, UIMapID)
end

---地图场景坐标转地图UI坐标
function MapUtil.GetUIPosByLocation2(Location, MapID)
	local UIMapID = MapUtil.GetUIMapID(MapID)
	return MapUtil.GetUIPosByLocation(Location, UIMapID)
end

---根据EntityID获取角色地图UI坐标
function MapUtil.GetActorUIPosByEntityID(UIMapID, EntityID)
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if nil == Actor then
		return 0, 0
	end

	local Location = Actor:FGetActorLocation()
	return MapUtil.GetUIPosByLocation(Location, UIMapID)
end

---根据RoleID获取角色地图UI坐标
---@param UIMapID number
---@param RoleID number 队伍成员RoleID
---@param IsPVPPlayer boolean 是否是PVP玩家
---@return number, number
function MapUtil.GetActorUIPosByRoleID(UIMapID, RoleID, IsPVPPlayer)
	-- 优先使用视野内角色的位置，实时性更好
	local Actor = ActorUtil.GetActorByRoleID(RoleID)
	if Actor then
		local Location = Actor:FGetActorLocation()
		return MapUtil.GetUIPosByLocation(Location, UIMapID)
	end

	if not IsPVPPlayer then
		-- 大地图队友使用队伍系统定时拉取的位置
		local MemberLocation = TeamHelper.GetTeamMgr():GetTeamMemberNetPositionInfoByRoleID(RoleID)
		if nil == MemberLocation then
			return 0, 0
		end
		return MapUtil.GetUIPosByLocation(MemberLocation.Pos, UIMapID)
	else
		-- 视野外玩家的HP、位置等属性由玩法协议额外同步
		local CSPosition = _G.PVPTeamMgr:GetTeamMemberNetPositionInfoByRoleID(RoleID)
		if nil == CSPosition then
			return 0, 0
		end
		return MapUtil.GetUIPosByXY(CSPosition.x, CSPosition.y, UIMapID)
	end
end


---获取地域ID到地区ID列表、地区ID到地图ID列表的两个table
function MapUtil.GetRegionAndAreaTable()
	local AllCfg = MapRegionIconCfg:GetAllValidRegion()
	-- 在这里的都是有图标的地域
	local RegionIDMap = {}
	for i=1, #AllCfg do
		RegionIDMap[AllCfg[i].ID] = true
	end

	local Region2AreaTable = {}
	local Area2MapTable = {}

	local AllAreaCfg = MapArea2regionCfg:FindAllCfg()
	for _, AreaInfo in pairs(AllAreaCfg) do
		if RegionIDMap[AreaInfo.RegionID] ~= nil then
			if Region2AreaTable[AreaInfo.RegionID] == nil then
				Region2AreaTable[AreaInfo.RegionID] = {}
			end
			table.insert(Region2AreaTable[AreaInfo.RegionID], AreaInfo)
		end
	end

	local AllMapCfg = MapMap2areaCfg:FindAllCfg()
	for _, MapInfo in pairs(AllMapCfg) do
		if Area2MapTable[MapInfo.AreaID] == nil then
			Area2MapTable[MapInfo.AreaID] = {}
		end
		table.insert(Area2MapTable[MapInfo.AreaID], MapInfo)
	end

	return Region2AreaTable, Area2MapTable
end

---获取给定地图的地区ID
function MapUtil.GetMapAreaID(MapID)
	local Map2area = MapMap2areaCfg:FindCfgByKey(MapID)
	if not Map2area then
		return
	end
	return Map2area.AreaID
end

---获取给定地图的地域ID
function MapUtil.GetMapRegionID(MapID)
	local AreaID = MapUtil.GetMapAreaID(MapID)
	if not AreaID then
		return
	end

	local Area2region = MapArea2regionCfg:FindCfgByKey(AreaID)
	if not Area2region then
		return
	end
	return Area2region.RegionID
end


---二级地图大图标，同一个RegionIcon上的图标位置要排列显示（参考一级地图图标做法）
local RegionIconMarkerList = nil

---二级地图需要显示部分区域地图的标记，需要坐标转换
---@param Marker MapMarker
---@param RegionUIMapID number 二级地图UIMapID
---@param AreaUIMapID number 三级地图UIMapID
---@return boolean Region坐标设置是否成功
function MapUtil.SetRegionUIPos(Marker, RegionUIMapID, AreaUIMapID)
	if not RegionUIMapID or not AreaUIMapID then
		return
	end
	local MarkerID = MapUtil.GetMapMarkerID(RegionUIMapID)
	local EventType = MapMarkerEventType.MAP_MARKER_EVENT_CHANGE_MAP
	local MarkerCfg = MapMarkerCfg:GetMarkerCfgByEventTypeAndArg(MarkerID, EventType, AreaUIMapID)
	if nil == MarkerCfg then
		--[[备注：
			有些三级地图（比如栖木旅馆）属于某二级地图，但没法查找到二级地图到三级地图的Region配置
			这种情况下该地图的标记无法有效坐标转换，这种情况标记在二级地图不显示
		--]]
		return
	end
	local PictureScale = MapMarkerRegionCfg:FindValue(MarkerCfg.Region, "PictureScale")
	Marker:SetRegionInfo(MarkerCfg.PosX, MarkerCfg.PosY, PictureScale)

	if MarkerCfg.Layout == MapMarkerLayout.MAP_MARKER_LAYOUT_REGION_ICON then
		-- 二级地图大图标特殊显示
		if RegionIconMarkerList == nil then
			RegionIconMarkerList = {}
		end
		table.insert(RegionIconMarkerList, Marker)

		local function SortPredicate(Left, Right)
			local LeftPriority = Left:GetPriority()
			local RightPriority = Right:GetPriority()
			if LeftPriority ~= RightPriority then
				return LeftPriority > RightPriority
			end
			return false
		end
		table.sort(RegionIconMarkerList, SortPredicate)

		local PosX, PosY = MarkerCfg.PosX, MarkerCfg.PosY
		PosY = PosY + 135
		local IconSpace = 50
		local MarkerNum = #RegionIconMarkerList
		if MarkerNum == 1 then
			for i = 1, MarkerNum do
				RegionIconMarkerList[i]:SetRegionIconInfo(PosX + IconSpace*(i-1), PosY)
			end
		elseif MarkerNum == 2 then
			for i = 1, MarkerNum do
				RegionIconMarkerList[i]:SetRegionIconInfo(PosX + IconSpace*(i-1) - IconSpace/2, PosY)
			end
		elseif MarkerNum == 3 then
			for i = 1, MarkerNum do
				RegionIconMarkerList[i]:SetRegionIconInfo(PosX + IconSpace*(i-2), PosY)
			end
		else
			for i = 1, MarkerNum do
				RegionIconMarkerList[i]:SetRegionIconInfo(PosX + IconSpace*(i-2) - IconSpace/2, PosY)
			end
		end
	end

	return true
end

---清理二级地图大图标的标记坐标缓存
function MapUtil.ResetRegionIconUIPosList()
	RegionIconMarkerList = nil
end


---一级地图上，同一个Region上的图标位置要排列显示
local WorldUIPosList = nil

---一级地图的标记坐标问题，按规则排列
---@param Marker MapMarker
---@param WorldUIMapID number 一级地图UIMapID
---@param RegionUIMapID number 二级地图UIMapID
function MapUtil.SetWorldUIPos(Marker, WorldUIMapID, RegionUIMapID)
	if not WorldUIMapID or not RegionUIMapID then
		return
	end
	local MarkerID = MapUtil.GetMapMarkerID(WorldUIMapID)
	local EventType = MapMarkerEventType.MAP_MARKER_EVENT_CHANGE_MAP
	local MarkerCfg = MapMarkerCfg:GetMarkerCfgByEventTypeAndArg(MarkerID, EventType, RegionUIMapID)
	if nil == MarkerCfg then
		return
	end
	local PosX, PosY = MarkerCfg.PosX, MarkerCfg.PosY

	if WorldUIPosList == nil then
		WorldUIPosList = {}
	end
	if WorldUIPosList[RegionUIMapID] == nil then
		WorldUIPosList[RegionUIMapID] = {}
	end
	local RegionMarkerList = WorldUIPosList[RegionUIMapID]
	table.insert(RegionMarkerList, Marker)

	local function SortPredicate(Left, Right)
		local LeftPriority = Left:GetPriority()
		local RightPriority = Right:GetPriority()
		if LeftPriority ~= RightPriority then
			return LeftPriority > RightPriority
		end
		return false
	end
	table.sort(RegionMarkerList, SortPredicate)

	PosY = PosY + 45
	local IconSpace = 50
	local MarkerNum = #RegionMarkerList
	if MarkerNum == 1 then -- UI坐标X 0
		for i = 1, MarkerNum do
			RegionMarkerList[i]:SetWorldInfo(PosX + IconSpace*(i-1), PosY)
		end
	elseif MarkerNum == 2 then --  UI坐标X -25 25
		for i = 1, MarkerNum do
			RegionMarkerList[i]:SetWorldInfo(PosX + IconSpace*(i-1) - IconSpace/2, PosY)
		end
	elseif MarkerNum == 3 then
		for i = 1, MarkerNum do
			RegionMarkerList[i]:SetWorldInfo(PosX + IconSpace*(i-2), PosY)
		end
	else
		for i = 1, MarkerNum do
			RegionMarkerList[i]:SetWorldInfo(PosX + IconSpace*(i-2) - IconSpace/2, PosY)
		end
	end

	return true
end

---清理一级地图的标记坐标缓存
function MapUtil.ResetWorldUIPosList()
	WorldUIPosList = nil
end


---获取控件的调整位置，确保显示在安全区内
---@param InTipsWidget UFCanvasPanel 需要调整位置的tips控件
---@param TipsWidgetAbsolutePosition FVector2D|nil 控件绝对坐标
---@return boolean,number,number 是否需要调整位置，如果需要调整则返回调整位置的偏移XY
function MapUtil.GetAdjustTipsPosition(InTipsWidget, TipsWidgetAbsolutePosition)
	if nil == InTipsWidget then
		return false
	end

	local ViewportSize = UIUtil.GetViewportSize()
	local ScreenSize = UIUtil.GetScreenSize()
	local WidgetAbsolutePosition = TipsWidgetAbsolutePosition
	if not WidgetAbsolutePosition then
		WidgetAbsolutePosition = UIUtil.GetWidgetAbsolutePosition(InTipsWidget)
	end
	local WidgetPixelPosition = UIUtil.AbsoluteToViewport(WidgetAbsolutePosition)
	WidgetPixelPosition.X = WidgetPixelPosition.X * ScreenSize.X / ViewportSize.X
	WidgetPixelPosition.Y = WidgetPixelPosition.Y * ScreenSize.Y / ViewportSize.Y

	local WidgetSize
	local IsAutoSize = UIUtil.CanvasSlotGetAutoSize(InTipsWidget) -- BP资源中勾选SizeToContent
	if IsAutoSize then
		WidgetSize = UIUtil.GetLocalSize(InTipsWidget)
	else
		WidgetSize = UIUtil.CanvasSlotGetSize(InTipsWidget)
	end

	--print("[MapUtil.GetAdjustTipsPosition] ViewportSize, ScreenSize ", ViewportSize, ScreenSize)
	--print("[MapUtil.GetAdjustTipsPosition] WidgetAbsolutePosition, WidgetPixelPosition, WidgetSize ", WidgetAbsolutePosition, WidgetPixelPosition, WidgetSize)

	local SafeAreaY = MapConstant.MAP_TIPS_WIDGET_SAFE_AREA_OFFSET_Y
	local SafeAreaX = MapConstant.MAP_TIPS_WIDGET_SAFE_AREA_OFFSET_X

	local OffsetTop = WidgetPixelPosition.Y
	local OffsetBottom = ScreenSize.Y - (WidgetPixelPosition.Y + WidgetSize.Y)
	local OffsetY = 0
	if OffsetTop < SafeAreaY then
		OffsetY = SafeAreaY - OffsetTop
	elseif OffsetBottom < SafeAreaY then
		OffsetY = OffsetBottom - SafeAreaY
	end

	local OffsetLeft = WidgetPixelPosition.X
	local OffsetRight = ScreenSize.X - (WidgetPixelPosition.X + WidgetSize.X)
	local OffsetX = 0
	if OffsetLeft < SafeAreaX then
		OffsetX = SafeAreaX - OffsetLeft
	elseif OffsetRight < SafeAreaX then
		OffsetX = OffsetRight - SafeAreaX
	end

	--print("[MapUtil.GetAdjustTipsPosition] OffsetTop, OffsetBottom, OffsetY ", OffsetTop, OffsetBottom, OffsetY)
	--print("[MapUtil.GetAdjustTipsPosition] OffsetLeft, OffsetRight, OffsetX ", OffsetLeft, OffsetRight, OffsetX)

	--if OffsetY ~= 0 or OffsetX ~= 0 then
	if math.abs(OffsetY) > 1 or math.abs(OffsetX) > 1 then
		return true, OffsetX, OffsetY
	end

	return false
end

---判断给定位置是否在屏幕安全区内，比如避免点击在关闭按钮区域影响关闭地图
---@param AbsoluteCoordinate FVector2D 屏幕绝对坐标
---@return boolean
function MapUtil.CheckScreenPositionInSafeArea(AbsoluteCoordinate)
	local ViewportSize = UIUtil.GetViewportSize()
	local ScreenSize = UIUtil.GetScreenSize()
	local PixelPosition = UIUtil.AbsoluteToViewport(AbsoluteCoordinate)
	PixelPosition.X = PixelPosition.X * ScreenSize.X / ViewportSize.X
	PixelPosition.Y = PixelPosition.Y * ScreenSize.Y / ViewportSize.Y

	local SafeAreaY = MapConstant.MAP_TIPS_WIDGET_SAFE_AREA_OFFSET_Y
	local SafeAreaX = MapConstant.MAP_TIPS_WIDGET_SAFE_AREA_OFFSET_X

	local OffsetTop = PixelPosition.Y
	local OffsetBottom = ScreenSize.Y - PixelPosition.Y
	if OffsetTop < SafeAreaY or OffsetBottom < SafeAreaY then
		--print("[MapUtil.CheckScreenPositionInSafeArea] click out, SafeAreaY, OffsetTop, OffsetBottom", SafeAreaY, OffsetTop, OffsetBottom)
		return false
	end
	local OffsetLeft = PixelPosition.X
	local OffsetRight = ScreenSize.X - PixelPosition.X
	if OffsetLeft < SafeAreaX or OffsetRight < SafeAreaX then
		--print("[MapUtil.CheckScreenPositionInSafeArea] click out, SafeAreaX, OffsetLeft, OffsetRight", SafeAreaX, OffsetLeft, OffsetRight)
		return false
	end

	return true
end

---判断View位置是否在屏幕范围内
---@param MapMarkerView UIView
---@return boolean
function MapUtil.CheckViewInScreenArea(MapMarkerView)
	if nil == MapMarkerView then
		return false
	end

	local AbsoluteCoordinate = UIUtil.LocalToAbsolute(MapMarkerView, FVector2D(0,0))

	local ViewportSize = UIUtil.GetViewportSize()
	local ScreenSize = UIUtil.GetScreenSize()
	local PixelPosition = UIUtil.AbsoluteToViewport(AbsoluteCoordinate)
	PixelPosition.X = PixelPosition.X * ScreenSize.X / ViewportSize.X
	PixelPosition.Y = PixelPosition.Y * ScreenSize.Y / ViewportSize.Y

	local SafeAreaY = 0
	local SafeAreaX = 0
	local OffsetTop = PixelPosition.Y
	local OffsetBottom = ScreenSize.Y - PixelPosition.Y
	if OffsetTop < SafeAreaY or OffsetBottom < SafeAreaY then
		return false
	end
	local OffsetLeft = PixelPosition.X
	local OffsetRight = ScreenSize.X - PixelPosition.X
	if OffsetLeft < SafeAreaX or OffsetRight < SafeAreaX then
		return false
	end

	return true
end


---获取地图标记状态图标路径
---@param MapMarker MapMarker
---@return string
function MapUtil.GetMapMarkerStateIconPath(MapMarker)
	local UIMapID = MapMarker:GetAreaUIMapID()
	local MapID = MapUtil.GetMapID(UIMapID)
	local IsOpenAutoPath = _G.WorldMapMgr:IsOpenAutoPath(MapID)

	local IconPath
	if MapMarker:GetIsFollow() then
		if IsOpenAutoPath then
			IconPath = MapDefine.MapFollowStateIconPath.AutoPathing
		else
			IconPath = MapDefine.MapFollowStateIconPath.Following
		end
	else
		if IsOpenAutoPath then
			IconPath = MapDefine.MapFollowStateIconPath.UnAutoPath
		else
			IconPath = MapDefine.MapFollowStateIconPath.UnFollow
		end
	end

	return IconPath
end

---创建地图标记追踪动效View
function MapUtil.CreateTrackAnimView()
	local BPName = "Map/MapTrack_UIBP"
	local View = _G.UIViewMgr:CreateViewByName(BPName, nil)
	return View
end

---创建地图标记高亮动效View
function MapUtil.CreateHighlightAnimView()
	local BPName = "Map/MapHighlight_UIBP"
	local View = _G.UIViewMgr:CreateViewByName(BPName, nil)
	return View
end

---显示地图标记通用tips界面
---@param Marker MapMarker 地图标记
---@param EventParams table 屏幕坐标等各类参数
function MapUtil.ShowWorldMapMarkerFollowTips(Marker, EventParams)
	local Params = { MapMarker = Marker, ScreenPosition = EventParams.ScreenPosition }
	UIViewMgr:ShowView(UIViewID.WorldMapMarkerTipsFollow, Params)
end


---获取对应地图是否有飞行条件
function MapUtil.IsMapHaveFlyRight(MapID)
	local AllowFlyRide = MapCfg:FindValue(MapID, "AllowFlyRide")
	if not AllowFlyRide or type(AllowFlyRide) ~= "number" then
		return
	end
	return  AllowFlyRide > 0
end

---是否特殊副本地图，主要是指使用了主城或野外地图的副本
function MapUtil.IsSpecialPWorldMap(MapID)
	local MapTableCfg = _G.PWorldMgr:GetMapTableCfg(MapID)
	if MapTableCfg and MapTableCfg.SpecialPWorldMap then
		return MapTableCfg.SpecialPWorldMap > 0
	end
end

---是否特殊UIMap地图，主要是指沙之家这种地图
function MapUtil.IsSpecialUIMap(UIMapID)
	local Cfg = _G.WorldMapMgr:FindMappingMapCfgByUIMapID(UIMapID)
	return Cfg ~= nil
end

---获取对应地域的名字
function MapUtil.GetRegionName(RegionID)
	local RegionCfg = MapRegionIconCfg:FindCfgByKey(RegionID)
    if not RegionCfg then
        return
    end
	return RegionCfg.Name
end

--- 根据任务节点转换地图ID
function MapUtil.ConvertMapID(WorldID, MapID)
	return _G.QuestMgr.QuestLayerset:ConvertMapID(WorldID, MapID)
end

function MapUtil.GetDefaultMapID(ChangeMapID)
	return _G.QuestMgr.QuestLayerset:GetDefaultMapID(ChangeMapID)
end


---获取地图图标映射传送坐标
---@return FVector | nil
function MapUtil.GetMappingMapTransPos(MapID, ResID, TransType)
	if TransType == TransitionType.TRANSITION_NPC then
		local Point = MapUtil.GetMapNpcPosByResID(MapID, ResID)
		if Point then
			return _G.UE.FVector(Point.X, Point.Y, Point.Z)
		end

	elseif TransType == TransitionType.TRANSITION_EOBJ then
		local Point = MapUtil.GetMapEObjPosByListID(MapID, ResID)
		if Point then
			return _G.UE.FVector(Point.X, Point.Y, Point.Z)
		end
	end
end

---获取指定地图指定Npc的坐标
---@return table | nil
function MapUtil.GetMapNpcPosByResID(MapID, NpcResID)
	local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    if MapEditCfg == nil then
        return
    end

	local NpcData = _G.MapEditDataMgr:GetNpc(NpcResID, MapEditCfg)
	if NpcData then
		return NpcData.BirthPoint
	else
		FLOG_INFO("[MapUtil.GetMapNpcPosByResID] cannot find npc config, MapID=%d, NpcResID=%d", MapID, NpcResID)
		return
	end
end

---@return table | nil
function MapUtil.GetMapNpcPosByListID(MapID, NpcListID)
	local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    if MapEditCfg == nil then
        return
    end

	local NpcData = _G.MapEditDataMgr:GetNpcByListID(NpcListID, MapEditCfg)
	if NpcData then
		return NpcData.BirthPoint
	else
		FLOG_INFO("[MapUtil.GetMapNpcPosByListID] cannot find npc config, MapID=%d, NpcListID=%d", MapID, NpcListID)
		return
	end
end

---@return table | nil
function MapUtil.GetMapEObjPosByResID(MapID, EObjResID)
	local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    if MapEditCfg == nil then
        return
    end

	local EObjData = _G.MapEditDataMgr:GetEObjByResID(EObjResID, MapEditCfg)
	if EObjData then
		return EObjData.Point
	else
		FLOG_INFO("[MapUtil.GetMapEObjPosByResID] cannot find eobj config, MapID=%d, EObjResID=%d", MapID, EObjResID)
		return
	end
end

---@return table | nil
function MapUtil.GetMapEObjPosByListID(MapID, EObjListID)
	local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    if MapEditCfg == nil then
        return
    end

	local EObjData = _G.MapEditDataMgr:GetEObjByListID(EObjListID, MapEditCfg)
	if EObjData then
		return EObjData.Point
	else
		FLOG_INFO("[MapUtil.GetMapEObjPosByListID] cannot find eobj config, MapID=%d, EObjListID=%d", MapID, EObjListID)
		return
	end
end

---@return table | nil
function MapUtil.GetMapGatherPos(MapID, GatherResID)
	local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    if MapEditCfg == nil then
        return
    end

	local MapPickItem = MapUtil.GetValidGatherInSameGroup(GatherResID, MapEditCfg)
	if MapPickItem then
		return MapPickItem.Point
	else
		FLOG_INFO("[MapUtil.GetMapGatherPos] cannot find gatherpoint config, MapID=%d, GatherResID=%d", MapID, GatherResID)
		return
	end
end

function MapUtil.GetValidGatherInSameGroup(ResID, MapEditCfg)
    -- 获取采集点ID同分组里的第一个有效采集点
    local GatherResIDList = _G.GatheringLogMgr:GetGatherResIDListInSameGroup(ResID)
    for _, GatherResID in ipairs(GatherResIDList) do
        local ValidMapPickItem = _G.MapEditDataMgr:GetValidGatherByResID(GatherResID, MapEditCfg)
        if ValidMapPickItem ~= nil then
            return ValidMapPickItem
        end
    end

	FLOG_INFO("[MapUtil.GetValidGatherInSameGroup] cannot find valid gatherpoint, ResID=%d", ResID)
    -- 如果找不到有效采集点，默认用第一个
    local MapPickItem = _G.MapEditDataMgr:GetGatherByResID(ResID, MapEditCfg)
	return MapPickItem
end

---获取地图通用玩法标记的场景地图坐标
---@param MapID number 地图ID
---@param GameplayType number 玩法标记类型
---@param GameplayMarkerID number 玩法标记ID
---@return table | nil
function MapUtil.GetMapGameplayPos(MapID, GameplayType, GameplayMarkerID)
	local Point

	if GameplayType == MapDefine.MapGameplayType.WildBox then
		local Cfg = WildBoxMoundCfg:FindCfgByKey(GameplayMarkerID)
		if Cfg then
			Point = MapUtil.GetMapEObjPosByListID(MapID, Cfg.EmptyListID)
		end
	elseif GameplayType == MapDefine.MapGameplayType.AetherCurrent then
		local Cfg = AetherCurrentCfg:FindCfgByKey(GameplayMarkerID)
		if Cfg then
			Point = MapUtil.GetMapEObjPosByListID(MapID, Cfg.ListID)
		end
	elseif GameplayType == MapDefine.MapGameplayType.DiscoverNote then
		local Cfg = DiscoverNoteCfg:FindCfgByKey(GameplayMarkerID)
		if Cfg then
			Point = MapUtil.GetMapEObjPosByResID(MapID, Cfg.EobjID)
		end
	end

	return Point
end


return MapUtil