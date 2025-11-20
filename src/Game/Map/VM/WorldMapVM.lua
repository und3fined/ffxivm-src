--
-- Author: anypkvcai
-- Date: 2022-12-13 15:15
-- Description: 大地图
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local WorldMapListItemVM = require("Game/Map/VM/WorldMapListItemVM")
local NewMapTaskListPanelVM = require("Game/NewMap/VM/NewMapTaskListPanelVM")
local WorldMapTransferAreaVM = require("Game/Map/VM/WorldMapTransferAreaVM")
local UIBindableList = require("UI/UIBindableList")
local MapUtil = require("Game/Map/MapUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewID = require("Define/UIViewID")
local MapDefine = require("Game/Map/MapDefine")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")
local CommSideBarUtil = require("Utils/CommSideBarUtil")
local SideBarDefine = require("Game/Common/Frame/Define/CommonSelectSideBarDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local SaveKey = require("Define/SaveKey")
local Json = require("Core/Json")

local MapRegionIconCfg = require("TableCfg/MapRegionIconCfg")
local MapMap2areaCfg = require("TableCfg/MapMap2areaCfg")
local MapArea2regionCfg = require("TableCfg/MapArea2regionCfg")
local TeleportCrystalCfg = require("TableCfg/TeleportCrystalCfg")

local MapAllPointActivateState = AetherCurrentDefine.MapAllPointActivateState
local MapTabListItemFlyIconPath = AetherCurrentDefine.MapTabListItemFlyIconPath

local LSTR
local UIViewMgr
local USaveMgr
local WorldMapMgr ---@type WorldMapMgr
local MapMgr ---@type MapMgr


---@class WorldMapVM : UIViewModel
local WorldMapVM = LuaClass(UIViewModel)

function WorldMapVM:Ctor()
	--self.MapBackground = ""
	self.MapPath = ""
	self.MaskPath = ""
	self.WorldMapName = "" -- 一级地图名称
	self.MapTitle = "" -- 二级地图名称
	self.MapName = "" -- 三级地图名称或副本地图名称
	self.BgPath = ""
	self.MapScale = 1 -- 大地图缩放比例
	self.MapScaleByGesture = false -- 是否通过手势缩放
	self.DiscoveryFlag = 0
	self.DiscoveryOn = 0
	self.IsMaskVisible = false
	self.IsFogAllActivate = true

	self.PlacedMarkerIconPath = "" -- 手动标记点图标路径
	self.PlacedMarkerVisible = false -- 手动标记点显示
	self.SelectedMarker = nil -- 选定的手动标记
	self.WorldMapContentAllowClick = true -- 是否可以点击地图

	-- 功能按钮的显示 --
	self.BtnTransmitVisible = true
	self.BtnSetVisible = true
	self.BtnWeatherVisible = true
	self.BtnAetherCurrentVisible = true
	self.BtnMountSpeedVisible = true
	self.BtnHouseListVisible = false
	self.BtnTreasureHuntVisible = false
	self.BtnTaskListVisible = false --cbt2隐藏按钮,功能需要调整

	self.SecondaryMapVMList = UIBindableList.New(WorldMapListItemVM) -- 二级地图下拉列表 Region
	self.ThreeLevelMapVMList = UIBindableList.New(WorldMapListItemVM) -- 三级地图下拉列表 Area
	self.FloorMapVMList = UIBindableList.New(WorldMapListItemVM) -- 楼层地图列表 Floor

	self.WorldMapFrameVisible = false -- 一级地图额外要显示的内容
	self.WorldTitlePanelVisible = false -- 副本内和副本外的地图标题区分显示
	self.ThreeLevelPanelVisible = false -- 三级地图节点显隐，目前改由标题栏缩放动效控制
	self.SecondaryPanelVisible = false -- 二级地图节点显隐，目前改由标题栏缩放动效控制
	self.ThreeLevelMapListVisible = false -- 三级地图下拉列表显隐
	self.SecondaryMapListVisible = false -- 二级地图下拉列表显隐
	self.FloorMapListVisible = false -- 楼层地图列表显隐

	self.WeatherTimePanelVisible = true -- 天气时间面板显示
	self.MapSendMarkWinMarkPanelVisible = false -- 发送标记视图显示
	self.MapSendMarkWinLoctionPanelVisible = false -- 发送位置视图显示

	self.MapSetMarkPanelVisible = false -- 地图标记界面显示
	self.MapSettingPanelVisible = false -- 地图设置界面显示
	self.WorldMapTransferPanelVisible = false -- 地图传送列表界面显示
	self.WorldMapTaskListPanelVisible = false -- 地图任务列表界面显示
	self.WorldMapTaskDetailPanelVisible = false -- 地图任务详情界面显示

	self.MapAutoPathMoving = false -- 当前是否自动寻路中

	self.TaskListVM = NewMapTaskListPanelVM.New()

	--region 地图传送列表
	self.RegionID = 0 -- 当前查看地域ID
	self.RegionName = "" -- 当前查看地域名称
	self.AreaVMList = UIBindableList.New(WorldMapTransferAreaVM) -- 当前查看地域ID的地区列表
	self.FavorRegionID = 100 -- 收藏分类的RegionID
	self.OtherRegionID = 9 -- 其他分类的RegionID，和配表里保持一致
	self.HouseAreaID = -100 -- 房屋住宅区地区ID
	self.TransferHouseList = {} -- 传送房屋列表
	--endregion

	self.ClickWorldMapTipsContent = false -- 是否点击大地图tips界面的内容区域，没有点击时tips界面判断可以穿透

	self.QuestParamAfterChangeMap = nil

	self.MapOpenSource = 0 -- 打开地图来源

	self.DransDoorHighlightMapList = nil -- 记录传送门标记高亮地图列表

	self.WorldMapPanelVisible = true -- 显示默认大地图
    self.HouseMapPanelVisible = false -- 显示房屋地图

	--region 房屋地图
	self.HouseMapName = "" -- 住宅区名称
	self.HouseStreetName = "" -- 住宅区街区
	self.HouseAreaName = "" -- 住宅区初始区/扩建区

	self.HouseStreetVMList = UIBindableList.New(WorldMapListItemVM) -- Street二级下拉列表
	self.HouseAreaVMList = UIBindableList.New(WorldMapListItemVM) -- Area三级下拉列表
	self.HouseStreetListVisible = false -- Street二级下拉列表显隐
	self.HouseAreaListVisible = false -- Area三级下拉列表显隐
	--endregion
end

function WorldMapVM:OnInit()

end

function WorldMapVM:OnBegin()
	LSTR = _G.LSTR
	UIViewMgr = _G.UIViewMgr
	USaveMgr = _G.UE.USaveMgr
	WorldMapMgr = _G.WorldMapMgr
	MapMgr = _G.MapMgr

	self.WorldMapName = MapUtil.GetMapName(MapUtil.GetWorldUIMapID())

	self:InitRegionAreaMapTable()
end

function WorldMapVM:OnEnd()

end

function WorldMapVM:OnShutdown()

end

function WorldMapVM:SetWorldMapContentAllowClick(AllowClick)
	self.WorldMapContentAllowClick = AllowClick
end

function WorldMapVM:SetIsFogAllActivate(bAllActivate)
	self.IsFogAllActivate = bAllActivate
end

function WorldMapVM:SetMapPath(MapPath)
	if not MapPath or not string.find(MapPath, 'Texture') then
		self.MapPath = "" --?
		return
	end
	self.MapPath = MapPath
end

function WorldMapVM:SetMapMaskPath(MaskPath)
	if not MaskPath or not string.find(MaskPath, 'Texture') then
		self.MaskPath = ""
		self.DiscoveryOn = 0
		self.IsMaskVisible = false
		--self.BgPath = "Texture2D'/Game/UI/Texture/Map/World/UI_Map_Img_ThreeLevelBg.UI_Map_Img_ThreeLevelBg'"
		return
	end

	self.MaskPath = MaskPath
	self.DiscoveryOn = 1
	self.IsMaskVisible = true
	--self.BgPath = "Texture2D'/Game/UI/Texture/Map/World/UI_Map_Img_ThreeLevelBg.UI_Map_Img_ThreeLevelBg'"
end

function WorldMapVM:SetMapTitle(Title)
	self.MapTitle = Title
end

function WorldMapVM:SetMapName(Name)
	self.MapName = Name
end

function WorldMapVM:SetMapScale(Scale, bScaleByGesture)
	self.MapScale = Scale
	self.MapScaleByGesture = bScaleByGesture
end

function WorldMapVM:SetDiscoveryFlag(Flag)
	self.DiscoveryFlag = Flag
end

function WorldMapVM:SetPlacedMarkerIconPath(IconPath)
	self.PlacedMarkerIconPath = IconPath
end

function WorldMapVM:SetPlacedMarkerVisible(IsVisible)
	if self.MapSendMarkWinMarkPanelVisible then
		return
	end

	self.PlacedMarkerVisible = IsVisible
end


function WorldMapVM:SetThreeLevelMapListVisible(IsVisible)
	self.ThreeLevelMapListVisible = IsVisible

	if IsVisible then
		local UIMapID = WorldMapMgr:GetUIMapID()
		local VmList = self.ThreeLevelMapVMList:GetItems() or {}
		for i = 1, #VmList do
			if MapUtil.GetMapNameUI(VmList[i].ID) == MapUtil.GetMapNameUI(UIMapID) then
				VmList[i]:SetIsSelect(true)
			else
				VmList[i]:SetIsSelect(false)
			end
		end
	end
end

function WorldMapVM:SetSecondaryMapListVisible(IsVisible)
	self.SecondaryMapListVisible = IsVisible

	if IsVisible then
		local UIMapID = WorldMapMgr:GetUIMapID()
		local VmList = self.SecondaryMapVMList:GetItems() or {}
		for i = 1, #VmList do
			-- 当前查看的二级地图，对应的二级地图要选中
			-- 当前查看的三级地图，该地图对应的二级地图也要选中
			if MapUtil.GetMapNameUI(VmList[i].ID) == MapUtil.GetMapNameUI(UIMapID)
				or VmList[i].ID == MapUtil.GetUpperUIMapID(UIMapID) then
				VmList[i]:SetIsSelect(true)
			else
				VmList[i]:SetIsSelect(false)
			end
		end
	end
end

function WorldMapVM:SetFloorMapListVisible(IsVisible)
	self.FloorMapListVisible = IsVisible
end

function WorldMapVM:SetSecondaryMapList(MapList)
	local SecondaryMapList = {}
	for i = 1, #MapList do
		local MapItem = MapList[i]
		local UIMapID = MapItem.ID

		local MapInfo = {}
		MapInfo.ID = UIMapID
		MapInfo.Name = MapUtil.GetPlaceName(tonumber(MapItem.NameUI))
		MapInfo.IsLocation = MapUtil.MajorInHere(UIMapID)
		MapInfo.IsUnlock = MapUtil.CheckMapIsUnLock(UIMapID)
		MapInfo.IsSelect = MapUtil.GetMapNameUI(UIMapID) == MapUtil.GetMapNameUI(WorldMapMgr:GetUIMapID())

		table.insert(SecondaryMapList, MapInfo)
	end

	self.SecondaryMapVMList:UpdateByValues(SecondaryMapList)
end

function WorldMapVM:SetThreeLevelMapList(MapList)
	local ThreeLevelMapList = {}
	for i = 1, #MapList do
		local MapItem = MapList[i]
		local UIMapID = MapItem.ID

		local MapInfo = {}
		MapInfo.ID = UIMapID
		MapInfo.Name = MapUtil.GetPlaceName(tonumber(MapItem.NameUI))
		MapInfo.IsLocation = MapUtil.MajorInHere(UIMapID)
		MapInfo.IsUnlock = MapUtil.CheckMapIsUnLock(UIMapID)
		MapInfo.IsSelect = MapUtil.GetMapNameUI(UIMapID) == MapUtil.GetMapNameUI(WorldMapMgr:GetUIMapID())

		local bHaveFlyRight, IconFlyAdmitted = self:MakeTheThreeTabMapFlyData(UIMapID)
		MapInfo.bHaveFlyRight = bHaveFlyRight
		MapInfo.IconFlyAdmitted = IconFlyAdmitted

		table.insert(ThreeLevelMapList, MapInfo)
	end

	self.ThreeLevelMapVMList:UpdateByValues(ThreeLevelMapList)
end

function WorldMapVM:SetFloorMapList(MapList)
	local FloorMapList = {}
	for i = 1, #MapList do
		local MapItem = MapList[i]
		local UIMapID = MapItem.ID

		local MapInfo = {}
		MapInfo.ID = UIMapID
		MapInfo.Name = MapUtil.GetPlaceName(MapItem.FloorNameUI) -- 楼层名
		if MapUtil.IsHouseUIMap(UIMapID) then
			-- 如果是房屋地图，要求显示房屋住宅区街区ID
			MapInfo.Name = string.format(LSTR(700054), WorldMapMgr:GetStreetID()) .. MapInfo.Name
		end
		MapInfo.IsUnlock = MapUtil.CheckMapIsUnLock(UIMapID)
		MapInfo.IsSelect = (UIMapID == WorldMapMgr:GetUIMapID())

		MapInfo.IconPath = self:GetMapListItemIconPath(UIMapID)
		MapInfo.IconVisible = (MapInfo.IconPath ~= nil)

		table.insert(FloorMapList, MapInfo)
	end

	self.FloorMapVMList:UpdateByValues(FloorMapList)
end


---显示默认大地图
function WorldMapVM:ShowWorldMapPanel()
	self.WorldMapPanelVisible = true
	self.HouseMapPanelVisible = false
end

---显示独立房屋地图。通过房屋土地购买打开，和默认大地图显示内容有差异
function WorldMapVM:ShowHouseMapPanel()
	self.WorldMapPanelVisible = false
	self.HouseMapPanelVisible = true
	self.WorldMapFrameVisible = false
end


--region 房屋地图

---切换房屋UI地图
function WorldMapVM:ChangeToHouseAreaMap()
	local MapID = WorldMapMgr:GetMapID()

	local MapTableCfg = _G.PWorldMgr:GetMapTableCfg(MapID)
	if MapTableCfg then
		self.HouseMapName = MapTableCfg.DisplayName
	end

	self:SetHouseStreetList(MapID)
	local StreetID = WorldMapMgr:GetStreetID()
	self.HouseStreetName = string.format(LSTR(700054), StreetID) -- "第%d区"

	local UIMapID = WorldMapMgr:GetUIMapID()
	self:SetHouseAreaList(UIMapID)
	self.HouseAreaName = MapUtil.GetMapFloorName(UIMapID)

	self:HideTempPanel()

	self:QueryMapDataAfterChangeMap()
end

---Street二级下拉列表，住宅区街区列表
function WorldMapVM:SetHouseStreetList(AreaMapID)
	local HouseRegionID = MapUtil.GetHouseRegionID(AreaMapID)
	local HouseStreetCount = _G.HouseLandMgr:GetReleaseLand(HouseRegionID)

	local StreetList = {}
	for i = 1, HouseStreetCount do
		local StreetID = i

		local MapInfo = {}
		MapInfo.ID = StreetID
		MapInfo.Name = string.format(LSTR(700054), StreetID) -- "第%d区"
		MapInfo.IsUnlock = true
		MapInfo.IsSelect = (StreetID == WorldMapMgr:GetStreetID())

		table.insert(StreetList, MapInfo)
	end

	self.HouseStreetVMList:UpdateByValues(StreetList)
end

---Area三级下拉列表，住宅区分层地图列表
function WorldMapVM:SetHouseAreaList(AreaUIMapID)
	local AreaFloorMapList = MapUtil.GetAreaFloorMapList(AreaUIMapID)

	local FloorMapList = {}
	for i = 1, #AreaFloorMapList do
		local MapItem = AreaFloorMapList[i]
		local UIMapID = MapItem.ID

		local MapInfo = {}
		MapInfo.ID = UIMapID
		MapInfo.Name = MapUtil.GetPlaceName(MapItem.FloorNameUI)
		MapInfo.IsUnlock = MapUtil.CheckMapIsUnLock(UIMapID)
		MapInfo.IsSelect = (UIMapID == WorldMapMgr:GetUIMapID())

		table.insert(FloorMapList, MapInfo)
	end

	self.HouseAreaVMList:UpdateByValues(FloorMapList)
end

function WorldMapVM:SetHouseStreetListVisible(IsVisible)
	if IsVisible == nil then
		IsVisible = not self.HouseStreetListVisible
	end
	self.HouseStreetListVisible = IsVisible

	if IsVisible then
		self:SetHouseAreaListVisible(false)
	end
end

function WorldMapVM:SetHouseAreaListVisible(IsVisible)
	if IsVisible == nil then
		IsVisible = not self.HouseAreaListVisible
	end
	self.HouseAreaListVisible = IsVisible

	if IsVisible then
		self:SetHouseStreetListVisible(false)
	end
end

---查看对应住宅区的土地列表
function WorldMapVM:SetHouseLandListPanelVisible(IsVisible)
	if IsVisible then
		self:HideTempPanel()

		local HouseMapID = WorldMapMgr:GetMapID()
		local HouseRegionID = MapUtil.GetHouseRegionID(HouseMapID)
		_G.HouseLandMgr:OpenLandListWin(HouseRegionID, WorldMapMgr:GetStreetID())
	end
end

---查看对应住宅区的房屋列表
---@param HouseMapID number 住宅区MapID
function WorldMapVM:OpenMapHouseListPanel(HouseMapID)
	self:HideTempPanel()

	local HouseRegionID = MapUtil.GetHouseRegionID(HouseMapID)
	_G.HouseLandMgr:OpenMapHouseListPanel(HouseRegionID)
end

---当前地图所在区域地图（Region地图）是否有住宅区
---@return boolean, number
function WorldMapVM:IsHouseRegionMap()
	if MapUtil.IsAreaMap(WorldMapMgr:GetUIMapID()) then
		local CurrRegionUIMapID = WorldMapMgr:GetUpperUIMapID()

		local EstateInfo = _G.HouseLandMianPanelVM:GetEstateCfg()
		for _, EstateInfoCfgData in pairs(EstateInfo) do
			local MapID = EstateInfoCfgData.MapID
			local UIMapID = MapUtil.GetUIMapID(MapID)
			local RegionUIMapID = MapUtil.GetUpperUIMapID(UIMapID)
			if RegionUIMapID == CurrRegionUIMapID then
				return true, MapID
			end
		end
	end

	return false, 0
end

---打开对应住宅区的房屋列表界面
function WorldMapVM:OpenMapHouseListByRegion()
	local Result, HouseMapID = self:IsHouseRegionMap()
	if Result then
		self:OpenMapHouseListPanel(HouseMapID)
	end
end

---是否可以切换到房屋UI地图
---@return boolean
function WorldMapVM:CanChangeToHouseUIMap(AreaUIMapID)
	local AreaMapID = MapUtil.GetMapID(AreaUIMapID)
	local MajorMapID = MapMgr:GetMapID()
	-- 主角是否在当前正在点击的房屋地图中
	if AreaMapID == MajorMapID then
		return true
	end

	return false
end

function WorldMapVM:GetTransferHouseList()
	return self.TransferHouseList
end

--endregion


---切换到一级地图
function WorldMapVM:ChangeToWorldMap()
	self.WorldMapFrameVisible = true
	self.ThreeLevelPanelVisible = false
	self.SecondaryPanelVisible = false
	self.FloorMapListVisible = false

	self.BtnHouseListVisible = false

	self:HideSidePanel()
end

---切换到二级地图
function WorldMapVM:ChangeToRegionMap(UIMapID)
	self.WorldMapFrameVisible = false
	self.ThreeLevelPanelVisible = false
	self.SecondaryPanelVisible = true
	self.ThreeLevelMapListVisible = false
	self.SecondaryMapListVisible = false
	self.FloorMapListVisible = false

	self.BtnHouseListVisible = false

	self.MapTitle = MapUtil.GetMapName(UIMapID)
	self.MapName = ""

	self:HideSidePanel()
end

---切换到三级地图
function WorldMapVM:ChangeToAreaMap(UIMapID)
	self.WorldMapFrameVisible = false

	-- 副本内外的地图功能区分显示
	if (UIMapID == _G.MapMgr:GetUIMapID() or MapUtil.GetMapID(UIMapID) == _G.MapMgr:GetMapID())
		and _G.PWorldMgr:CurrIsInDungeon() then
		-- 当前查看UIMapID是否副本内，有多种情况：同一MapID分多层UIMapID；两个MapID共用一个UIMapID
		self.WorldTitlePanelVisible = false
		self.ThreeLevelPanelVisible = false
		self.SecondaryPanelVisible = false
		self.ThreeLevelMapListVisible = false
		self.SecondaryMapListVisible = false

		self.BtnTransmitVisible = false
		self.BtnSetVisible = false
		self.BtnWeatherVisible = false
		self.BtnAetherCurrentVisible = false
		self.BtnTreasureHuntVisible = false
		--self.BtnTaskListVisible = false
		self.BtnMountSpeedVisible = false
		self.BtnHouseListVisible = false

	else
		self.WorldTitlePanelVisible = true
		self.ThreeLevelPanelVisible = true
		self.SecondaryPanelVisible = true
		self.ThreeLevelMapListVisible = false
		self.SecondaryMapListVisible = false

		self.BtnTransmitVisible = true
		self.BtnSetVisible = true
		self.BtnWeatherVisible = true
		self.BtnAetherCurrentVisible = _G.AetherCurrentsMgr:IsAetherCurrentSysOpen()
		self.BtnTreasureHuntVisible = false
		--self.BtnTaskListVisible = true
		self.BtnMountSpeedVisible = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMount)
		self.BtnHouseListVisible = false -- 2.2版本暂时屏蔽 self:IsHouseRegionMap() -- 是否显示地图房屋列表按钮（住宅区按钮）
	end

	self.MapTitle = MapUtil.GetMapName(MapUtil.GetUpperUIMapID(UIMapID))
	self.MapName = MapUtil.GetMapName(UIMapID)

	self:SetThreeLevelMapList(MapUtil.GetAllAreaMapList(UIMapID))

	self:HideSidePanel()

	if self.QuestParamAfterChangeMap then
		self:ShowWorldMapTaskDetailPanel(true, self.QuestParamAfterChangeMap)
	else
        self:ShowWorldMapTaskDetailPanel(false)
    end

	self:QueryMapDataAfterChangeMap()
end

-- 切换UI地图后按需查询当前UI地图某些玩法数据，以便查看地图标记状态
function WorldMapVM:QueryMapDataAfterChangeMap()
	local MapID = WorldMapMgr:GetMapID()
	local UIMapID = WorldMapMgr:GetUIMapID()

	if MapUtil.IsHouseUIMap(UIMapID) then
		-- 查询房屋土地数据
		local HouseRegionID = MapUtil.GetHouseRegionID(MapID)
		local HouseAreaID = MapUtil.GetHouseAreaID(MapID, UIMapID)
		_G.HouseLandMgr:SetCurOpenMapData(HouseRegionID, WorldMapMgr:GetStreetID(), HouseAreaID)
		return
	end

	-- 当前所在地图玩法数据一般已经有了，不用重复查询
	if MapID == MapMgr:GetMapID() then
		return
	end

	-- 查询已开启宝箱
	_G.WildBoxMoundMgr:SendQueryReq(MapID)
	-- 查询其他内容
end


-- 打开发送标记视图
function WorldMapVM:ShowSendMarkerView()
	local Params = { IsShowMarkPanel = true }
	UIViewMgr:ShowView(UIViewID.WorldMapSendMarkWin, Params)
	self.MapSendMarkWinMarkPanelVisible = true

	self:SetWorldMapContentAllowClick(false)
	self.PlacedMarkerVisible = false
	self.WeatherTimePanelVisible = false
	self.BtnTransmitVisible = false
	self.BtnSetVisible = false
	self.BtnWeatherVisible = false
end

-- 打开发送位置视图
function WorldMapVM:ShowSendLoctionView()
	local Params = { IsShowLoctionPanel = true }
	UIViewMgr:ShowView(UIViewID.WorldMapSendMarkWin, Params)
	self.MapSendMarkWinLoctionPanelVisible = true

	self.WeatherTimePanelVisible = false
	self.BtnTransmitVisible = false
	self.BtnSetVisible = false
	self.BtnWeatherVisible = false
end

-- 关闭发送标记或位置视图
function WorldMapVM:CloseSendMarkerView()
	if self.MapSendMarkWinMarkPanelVisible then
		if UIViewMgr:IsViewVisible(UIViewID.WorldMapSendMarkWin) then
			UIViewMgr:HideView(UIViewID.WorldMapSendMarkWin)
		end

		self.MapSendMarkWinMarkPanelVisible = false
		self:SetWorldMapContentAllowClick(true)
		self.PlacedMarkerVisible = true
		self.WeatherTimePanelVisible = true
		self.BtnTransmitVisible = true
		self.BtnSetVisible = true
		self.BtnWeatherVisible = true
	end

	if self.MapSendMarkWinLoctionPanelVisible then
		if UIViewMgr:IsViewVisible(UIViewID.WorldMapSendMarkWin) then
			UIViewMgr:HideView(UIViewID.WorldMapSendMarkWin)
		end

		self.MapSendMarkWinLoctionPanelVisible = false
		self.WeatherTimePanelVisible = true
		self.BtnTransmitVisible = true
		self.BtnSetVisible = true
		self.BtnWeatherVisible = true
	end
end

-- 关闭WorldMapPanel
function WorldMapVM:CloseWorldMapPanel()
	UIViewMgr:HideView(UIViewID.WorldMapPanel)
end

-- 打开天气界面
function WorldMapVM:ShowWeatherForecastMainPanel()
	UIViewMgr:ShowView(UIViewID.WeatherForecastMainPanel)
	self:HideTempPanel()
end

-- 关闭附加临时界面
function WorldMapVM:HideTempPanel()
	self.ThreeLevelMapListVisible = false
	self.SecondaryMapListVisible = false
	self.HouseAreaListVisible = false
	self.HouseStreetListVisible = false
end

---关闭地图相关的界面
function WorldMapVM:HideRelatedPanel()
	self:HideSidePanel()
	self:HideRelatedTipsPanel()
end

---关闭地图侧边栏相关界面
function WorldMapVM:HideSidePanel()
	self:SetMapSetMarkPanelVisible(false)
	self:SetMapSettingPanelVisible(false)
	self:ShowWorldMapTransferPanel(false)
	self:ShowWorldMapTaskListPanel(false)
end

---关闭地图相关的Tips界面
function WorldMapVM:HideRelatedTipsPanel()
	if UIViewMgr:IsViewVisible(UIViewID.WorldMapMarkerTipsList) then
		UIViewMgr:HideView(UIViewID.WorldMapMarkerTipsList)
	end
	if UIViewMgr:IsViewVisible(UIViewID.WorldMapMarkerTipsFollow) then
		UIViewMgr:HideView(UIViewID.WorldMapMarkerTipsFollow)
	end
	if UIViewMgr:IsViewVisible(UIViewID.WorldMapMarkerTipsTransfer) then
		UIViewMgr:HideView(UIViewID.WorldMapMarkerTipsTransfer)
	end
	if UIViewMgr:IsViewVisible(UIViewID.WorldMapMarkerTipsHouse) then
		UIViewMgr:HideView(UIViewID.WorldMapMarkerTipsHouse)
	end
	if UIViewMgr:IsViewVisible(UIViewID.WorldMapGoldSaucerMarkerTips) then
		UIViewMgr:HideView(UIViewID.WorldMapGoldSaucerMarkerTips)
	end
end

-- 显示地图标记界面
function WorldMapVM:ShowWorldMapPlaceMarkerPanel(Params)
	if Params ~= nil then
		self.SelectedMarker = Params.Marker
	else
		self.SelectedMarker = nil
	end

	self:SetMapSetMarkPanelVisible(true)
end

-- 地图标记界面
function WorldMapVM:SetMapSetMarkPanelVisible(IsVisible)
	if IsVisible then
		self:SetMapSettingPanelVisible(false)
		self:ShowWorldMapTransferPanel(false)
		self:ShowWorldMapTaskListPanel(false)
		self:HideTempPanel()

		UIViewMgr:ShowView(UIViewID.WorldMapSetMarkPanel)
		self.MapSetMarkPanelVisible = true
	else
		UIViewMgr:HideView(UIViewID.WorldMapSetMarkPanel)
		self.MapSetMarkPanelVisible = false
	end
end

-- 地图设置界面
function WorldMapVM:SetMapSettingPanelVisible(IsVisible)
	if IsVisible then
		self:SetMapSetMarkPanelVisible(false)
		self:ShowWorldMapTransferPanel(false)
		self:ShowWorldMapTaskListPanel(false)
		self:SetWorldMapContentAllowClick(false)
		self:HideTempPanel()

		CommSideBarUtil.ShowMapSettingSideBarByType(SideBarDefine.MapSettingTabType.Basic)
		self.MapSettingPanelVisible = true
	else
		if UIViewMgr:IsViewVisible(UIViewID.CommEasytoUseView) then
			UIViewMgr:HideView(UIViewID.CommEasytoUseView)
		end
		self.MapSettingPanelVisible = false
		self:SetWorldMapContentAllowClick(true)
	end
end

-- 地图传送界面
function WorldMapVM:ShowWorldMapTransferPanel(IsOpen)
	if IsOpen == nil then
		return
	end

	if IsOpen then
		self:SetMapSettingPanelVisible(false)
		self:SetMapSetMarkPanelVisible(false)
		self:ShowWorldMapTaskListPanel(false)
		self:SetWorldMapContentAllowClick(false)
		self:HideTempPanel()

		UIViewMgr:ShowView(UIViewID.WorldMapTransferPanel)
		self.WorldMapTransferPanelVisible = true
	else
		UIViewMgr:HideView(UIViewID.WorldMapTransferPanel)
		self.WorldMapTransferPanelVisible = false
		self:SetWorldMapContentAllowClick(true)
		UIViewMgr:HideView(UIViewID.WorldMapUsePortal)
	end
end

-- 地图任务列表界面
function WorldMapVM:ShowWorldMapTaskListPanel(IsOpen)
	if IsOpen == nil then
		return
	end

	if IsOpen then
		self:SetMapSettingPanelVisible(false)
		self:SetMapSetMarkPanelVisible(false)
		self:ShowWorldMapTransferPanel(false)
		self:SetWorldMapContentAllowClick(false)
		self:HideTempPanel()

		UIViewMgr:ShowView(UIViewID.WorldMapTaskListPanel)
		self.WorldMapTaskListPanelVisible = true
	else
		UIViewMgr:HideView(UIViewID.WorldMapTaskListPanel)
		self.WorldMapTaskListPanelVisible = false
		self:SetWorldMapContentAllowClick(true)
	end
end

-- 任务详情界面
---@param EntryMode number @进入模式   1图标进入  2地图任务列表进入
---@param ChapterID @任务章节ID
function WorldMapVM:ShowWorldMapTaskDetailPanel(IsOpen, Params)
	if IsOpen == nil then
		-- 清理缓存数据
		self.QuestParamAfterChangeMap = nil
		return
	end

	if IsOpen then
		local ChapterVM = _G.QuestMainVM:GetChapterVM(Params.ChapterID)
		if ChapterVM == nil then
			MsgTipsUtil.ShowTips(LSTR(400009)) -- "未找到任务信息"
			-- 清理缓存数据
			self.QuestParamAfterChangeMap = nil
			return
		else
			Params.ChapterVM = ChapterVM
		end
	end

	local IsTaskListVisible = UIViewMgr:FindView(UIViewID.WorldMapTaskListPanel)
	if IsOpen then
		-- 不是透过地图任务列表打开的，要禁用地图移动
		if not IsTaskListVisible then
			self:SetWorldMapContentAllowClick(false)
			self:HideTempPanel()
		end

		UIViewMgr:HideView(UIViewID.NewMapTaskTrackingTips)
		UIViewMgr:ShowView(UIViewID.NewMapTaskDetailPanel, Params)
	else
		if not IsTaskListVisible then
			self:SetWorldMapContentAllowClick(true)
		end

		UIViewMgr:HideView(UIViewID.NewMapTaskTrackingTips)
		UIViewMgr:HideView(UIViewID.NewMapTaskDetailPanel)
	end

	-- 清理缓存数据
	self.QuestParamAfterChangeMap = nil
end


--region 动画相关

function WorldMapVM:GetWorldMapPanelView()
	if not UIViewMgr:IsViewVisible(UIViewID.WorldMapPanel) then
		return
	end

	local WorldMapPanelView = UIViewMgr:FindVisibleView(UIViewID.WorldMapPanel)
	return WorldMapPanelView
end

function WorldMapVM:PlayFadeOutMapAnim()
	local WorldMapPanelView = self:GetWorldMapPanelView()
	if WorldMapPanelView == nil then
		return
	end
	WorldMapPanelView:PlayFadeOutMapAnim()
end

function WorldMapVM:GetFadeOutMapAnimTime()
	local WorldMapPanelView = self:GetWorldMapPanelView()
	if WorldMapPanelView == nil then
		return 0
	end
	return WorldMapPanelView:GetFadeOutMapAnimTime()
end

function WorldMapVM:PlayOutMapAnim()
	local WorldMapPanelView = self:GetWorldMapPanelView()
	if WorldMapPanelView == nil then
		return
	end
	WorldMapPanelView:PlayOutMapAnim()
end

function WorldMapVM:GetOutMapAnimTime()
	local WorldMapPanelView = self:GetWorldMapPanelView()
	if WorldMapPanelView == nil then
		return 0
	end
	return WorldMapPanelView:GetOutMapAnimTime()
end

--endregion


---组织三级地图的飞行相关数据
---@param UIMapID number
function WorldMapVM:MakeTheThreeTabMapFlyData(UIMapID)
	local ItemMapID = MapUtil.GetMapID(UIMapID)
	if not ItemMapID then
		return
	end

	local bHaveFlyRight = MapUtil.IsMapHaveFlyRight(ItemMapID)
	local IconFlyAdmitted
	if bHaveFlyRight then
		local bFlyCommitUnlock = _G.AetherCurrentsMgr:IsMapPointsAllActived(ItemMapID) ~= MapAllPointActivateState.NotComp
		IconFlyAdmitted = bFlyCommitUnlock and MapTabListItemFlyIconPath.Yellow or MapTabListItemFlyIconPath.Grey
	end
	return bHaveFlyRight, IconFlyAdmitted
end

---获取三级地图中楼层地图的显示图标
---图标按优先顺序显示：任务追踪目标所在层，地图追踪点所在层，主角位置所在层，默认图标
---@param UIMapID number
function WorldMapVM:GetMapListItemIconPath(UIMapID)
	local ItemMapID = MapUtil.GetMapID(UIMapID)
	if not ItemMapID then
		return
	end

	local bHasFollowQuest = false
	local QuestList = _G.QuestTrackMgr:GetTrackingQuestParam()
	if QuestList then
		for i = 1, #QuestList do
			if nil ~= QuestList[i].Pos and QuestList[i].UIMapID == UIMapID then
				bHasFollowQuest = true
				break
			end
		end
	end
	if bHasFollowQuest then
		return MapDefine.MapListItemIconPath.FollowQuest
	end

	local bHasFollowTarget = false
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo and FollowInfo.FollowUIMapID == UIMapID then
		bHasFollowTarget = true
	end
	if bHasFollowTarget then
		return MapDefine.MapListItemIconPath.MapFollow
	end

	local bIsLocation = (UIMapID == MapMgr:GetUIMapID())
	if bIsLocation then
		return MapDefine.MapListItemIconPath.MajorLocation
	end

	return MapDefine.MapListItemIconPath.Default
end


--region 地图传送列表

---初始化地域ID到地区ID列表、地区ID到地图ID列表的两个table
function WorldMapVM:InitRegionAreaMapTable()
	self.Region2AreaTable, self.Area2MapTable = MapUtil.GetRegionAndAreaTable()
end

---获取地图传送列表地域列表
---@return table
function WorldMapVM:GetRegionTabList()
	local ItemTabs = {}

	local AllCfg = MapRegionIconCfg:GetAllValidRegion()
	for _, Value in ipairs(AllCfg) do
		if (Value.bShow == 1) then
			table.insert(ItemTabs, {IconPath = Value.Icon, Name = Value.Name, IsLock = false, RegionID = Value.ID})
		end
	end

	-- 额外增加收藏分类。不配置到地域表MapRegionIconCfg，是因为地域表用的地方很多
	local FavorRegion =
	{
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Region_025.UI_Icon_Tab_Region_025'",
		Name = LSTR(700017), -- "收藏"
		IsLock = false,
		RegionID = self.FavorRegionID,
	}
	table.insert(ItemTabs, FavorRegion)

	return ItemTabs
end

---更新给定地域ID的地区列表
---@param RegionID number 地域ID
function WorldMapVM:UpdateAreaList(RegionID)
	self.RegionID = RegionID

	local AreaList = {}

	if RegionID ~= self.FavorRegionID then
		local Cfg = MapRegionIconCfg:FindCfgByKey(RegionID)
		self.RegionName = Cfg.Name

		local TempList = self.Region2AreaTable[RegionID]
		for _, AreaInfo in pairs(TempList) do
			local AreaID = AreaInfo.ID
			local MapList = self.Area2MapTable[AreaID]
			if MapList and #MapList > 0 then
				table.insert(AreaList, {ID = AreaID, Name = AreaInfo.Name, RegionID = RegionID })
			end
		end

		if RegionID == self.OtherRegionID then
			local TransferHouseList = self:GetTransferHouseList()
			if TransferHouseList and #TransferHouseList > 0 then
				-- “其他”分类里增加“冒险者住宅区”地区
				local AreaID = self.HouseAreaID
				table.insert(AreaList, {ID = AreaID, Name = LSTR(700055), RegionID = RegionID })
			end
		end

	else
		self.RegionName = LSTR(700017) -- "收藏"

		local AreaIDs = {}
		local FavorTransferList = _G.WorldMapMgr:GetFavorTransferList()
		for _, CrystalID in ipairs(FavorTransferList) do
			local Cfg = TeleportCrystalCfg:FindCfgByKey(CrystalID)
			if Cfg then
				local Map2area = MapMap2areaCfg:FindCfgByKey(Cfg.MapID)
				if Map2area then
					local AreaID = Map2area.AreaID
					if not AreaIDs[AreaID] then
						AreaIDs[AreaID] = true

						local Area2region = MapArea2regionCfg:FindCfgByKey(AreaID)
						table.insert(AreaList, {ID = AreaID, Name = Area2region.Name, RegionID = Area2region.RegionID })
					end
				end
			end
		end
	end

	-- 排序规则：（1）按地域ID （2）按地区ID
	table.sort(AreaList, function(Left, Right)
		if Left.RegionID ~= Right.RegionID then
			return Left.RegionID < Right.RegionID
		end
		return Left.ID < Right.ID
	end)

	self.AreaVMList:UpdateByValues(AreaList)
end

--endregion


function WorldMapVM:CanPlayDransDoorHighlight(UIMapID)
	if self.DransDoorHighlightMapList == nil then
		self.DransDoorHighlightMapList = {}

		local JsonStr = USaveMgr.GetString(SaveKey.MapDransDoorHighlight, "", true)
		if not string.isnilorempty(JsonStr) then
			self.DransDoorHighlightMapList = Json.decode(JsonStr) or {}
		end
	end

	return table.find_item(self.DransDoorHighlightMapList, UIMapID) == nil
end

function WorldMapVM:RecordDransDoorHighlight(UIMapID)
	if self.DransDoorHighlightMapList == nil then
		self.DransDoorHighlightMapList = {}
	end
	table.insert(self.DransDoorHighlightMapList, UIMapID)

	local JsonStr = Json.encode(self.DransDoorHighlightMapList)
	USaveMgr.SetString(SaveKey.MapDransDoorHighlight, JsonStr, true)
end


return WorldMapVM