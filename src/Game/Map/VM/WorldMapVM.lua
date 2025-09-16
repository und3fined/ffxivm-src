--
-- Author: anypkvcai
-- Date: 2022-12-13 15:15
-- Description:
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


---@class WorldMapVM : UIViewModel
local WorldMapVM = LuaClass(UIViewModel)

function WorldMapVM:Ctor()
	--self.MapBackground = ""
	self.MapPath = ""
	self.MaskPath = ""
	self.MapTitle = ""
	self.MapName = ""
	self.BgPath = ""
	self.MapScale = 1
	self.MapScaleByGesture = false
	self.DiscoveryFlag = 0
	self.DiscoveryOn = 0
	self.IsMaskVisible = false
	self.IsFogAllActivate = true
	self.PlacedMarkerIconPath = ""
	self.PlacedMarkerVisible = false

	self.BtnTransmitVisible = true
	self.BtnSetVisible = true
	self.BtnWeatherVisible = true
	self.BtnAetherCurrentVisible = true
	self.BtnMountSpeedVisible = true
	self.BtnTreasureHuntVisible = false
	self.BtnTaskListVisible = false --cbt2隐藏按钮,功能需要调整

	self.WorldMapContentAllowClick = true -- 是否可以点击地图
	self.MapSendMarkWinMarkPanelVisible = false
	self.MapSendMarkWinLoctionPanelVisible = false

	self.SecondaryMapList = UIBindableList.New(WorldMapListItemVM)
	self.ThreeLevelMapList = UIBindableList.New(WorldMapListItemVM)
	self.FloorMapList = UIBindableList.New(WorldMapListItemVM)

	self.WorldMapFrameVisible = false -- 一级地图额外要显示的内容
	self.WorldTitlePanelVisible = false -- 副本内外的地图功能区分显示
	self.ThreeLevelPanelVisible = false
	self.SecondaryPanelVisible = false
	self.ThreeLevelMapListVisible = false
	self.SecondaryMapListVisible = false
	self.FloorMapListVisible = false

	self.WeatherTimePanelVisible = true

	self.SelectedMarker = nil
	self.MapSetMarkPanelVisible = false -- 地图标记界面
	self.MapSettingPanelVisible = false -- 地图设置界面
	self.WorldMapTransferPanelVisible = false
	self.WorldMapTaskListPanelVisible = false
	self.WorldMapTaskDetailPanelVisible = false

	self.MapAutoPathMoving = false -- 当前是否自动寻路中

	self.TaskListVM = NewMapTaskListPanelVM.New()

	self.RegionID = 0 -- 地域ID
	self.RegionName = "" -- 地域名称
	self.AreaList = UIBindableList.New(WorldMapTransferAreaVM) -- 当前地域ID的地区列表
	self.FavorRegionID = 100 -- 收藏分类的RegionID

	self.ClickWorldMapTipsContent = false -- 是否点击大地图tips界面的内容区域，没有点击时tips界面判断可以穿透

	self.QuestParamAfterChangeMap = nil

	self.MapOpenSource = 0 -- 打开地图来源

	self.DransDoorHighlightMapList = nil -- 传送门标记高亮地图列表
end

function WorldMapVM:OnInit()

end

function WorldMapVM:OnBegin()
	LSTR = _G.LSTR
	UIViewMgr = _G.UIViewMgr
	USaveMgr = _G.UE.USaveMgr

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
		local UIMapID = _G.WorldMapMgr:GetUIMapID()
		local VmList = self.ThreeLevelMapList:GetItems() or {}
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
		local UIMapID = _G.WorldMapMgr:GetUIMapID()
		local VmList = self.SecondaryMapList:GetItems() or {}
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
	local SecondaryMapListData = {}
	for i = 1, #MapList do
		local MapItem = MapList[i]
		local UIMapID = MapItem.ID

		local MapInfo = {}
		MapInfo.ID = UIMapID
		MapInfo.Name = MapUtil.GetPlaceName(tonumber(MapItem.NameUI))
		MapInfo.IsLocation = MapUtil.MajorInHere(UIMapID)
		MapInfo.IsUnlock = MapUtil.CheckMapIsUnLock(UIMapID)
		MapInfo.IsSelect = MapUtil.GetMapNameUI(UIMapID) == MapUtil.GetMapNameUI(_G.WorldMapMgr:GetUIMapID())

		table.insert(SecondaryMapListData, MapInfo)
	end

	self.SecondaryMapList:UpdateByValues(SecondaryMapListData)
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
		MapInfo.IsSelect = MapUtil.GetMapNameUI(UIMapID) == MapUtil.GetMapNameUI(_G.WorldMapMgr:GetUIMapID())

		local bHaveFlyRight, IconFlyAdmitted = self:MakeTheThreeTabMapFlyData(UIMapID)
		MapInfo.bHaveFlyRight = bHaveFlyRight
		MapInfo.IconFlyAdmitted = IconFlyAdmitted

		table.insert(ThreeLevelMapList, MapInfo)
	end

	self.ThreeLevelMapList:UpdateByValues(ThreeLevelMapList)
end

function WorldMapVM:SetFloorMapList(MapList)
	local FloorMapList = {}
	for i = 1, #MapList do
		local MapItem = MapList[i]
		local UIMapID = MapItem.ID

		local MapInfo = {}
		MapInfo.ID = UIMapID
		MapInfo.Name = MapUtil.GetPlaceName(MapItem.FloorNameUI)
		MapInfo.IsUnlock = MapUtil.CheckMapIsUnLock(UIMapID)
		MapInfo.IsSelect = (UIMapID == _G.WorldMapMgr:GetUIMapID())

		MapInfo.IconPath = self:GetMapListItemIconPath(UIMapID)
		MapInfo.IconVisible = (MapInfo.IconPath ~= nil)

		table.insert(FloorMapList, MapInfo)
	end

	self.FloorMapList:UpdateByValues(FloorMapList)
end

-- 切换到一级地图
function WorldMapVM:ChangeToWorldMap()
	self.WorldMapFrameVisible = true
	self.ThreeLevelPanelVisible = false
	self.SecondaryPanelVisible = false
	self.FloorMapListVisible = false

	self:HideSidePanel()
end

-- 切换到二级地图
function WorldMapVM:ChangeToRegionMap(UIMapID)
	self.WorldMapFrameVisible = false
	self.ThreeLevelPanelVisible = false
	self.ThreeLevelMapListVisible = false
	self.SecondaryPanelVisible = true
	self.SecondaryMapListVisible = false
	self.FloorMapListVisible = false

	self.MapTitle = MapUtil.GetMapName(UIMapID)
	self.MapName = ""

	self:HideSidePanel()
end

-- 切换到三级地图
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

---切换UI地图后按需查询当前UI地图某些玩法数据
function WorldMapVM:QueryMapDataAfterChangeMap()
	local MapID = _G.WorldMapMgr:GetMapID()

	-- 当前所在地图一般不用重复查询
	if MapID == _G.MapMgr:GetMapID() then
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

	self:SetPlacedMarkerIconPath("PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_MarkLoction_png.UI_Map_Icon_MarkLoction_png'")
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

		CommSideBarUtil.ShowSideBarByType(SideBarDefine.PanelType.MapSetting, SideBarDefine.MapSettingTabType.Basic)
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


---组织3级Tab地图的飞行相关数据
---@param UIMapID number@地图UI数据
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

---获取三级地图中分层地图的显示图标
---图标按优先顺序显示：任务追踪目标所在层，自主追踪点所在层，主角位置所在层，默认图标
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

	local bIsLocation = (UIMapID == _G.MapMgr:GetUIMapID())
	if bIsLocation then
		return MapDefine.MapListItemIconPath.MajorLocation
	end

	return MapDefine.MapListItemIconPath.Default
end


function WorldMapVM:InitRegionAreaMapTable()
	self.Region2AreaTable, self.Area2MapTable = MapUtil.GetRegionAndAreaTable()
end

---获取地域列表
function WorldMapVM:GetRegionTabList()
	local ItemTabs = {}

	local AllCfg = MapRegionIconCfg:GetAllValidRegion()
	for _, Value in ipairs(AllCfg) do
		if (Value.bShow == 1) then
			table.insert(ItemTabs, {IconPath = Value.Icon, Name = Value.Name, IsLock = false, RegionID = Value.ID})
		end
	end

	-- 收藏分类
	local FavorRegion =
	{
		IconPath = "Texture2D'/Game/Assets/Icon/Region/UI_Icon_Tab_Collect.UI_Icon_Tab_Collect'",
		Name = LSTR(700017), -- "收藏"
		IsLock = false,
		RegionID = self.FavorRegionID,
	}
	table.insert(ItemTabs, FavorRegion)

	return ItemTabs
end

---获取给定地域ID的地区列表
---@param RegionID number 地域ID
function WorldMapVM:UpdateAreaList(RegionID)
	self.RegionID = RegionID

	local AreaList = {}

	if RegionID ~= self.FavorRegionID then
		local Cfg = MapRegionIconCfg:FindCfgByKey(RegionID)
		self.RegionName = Cfg.Name

		local TempList = self.Region2AreaTable[RegionID]
		for _, AreaInfo in pairs(TempList) do
			local MapList = self.Area2MapTable[AreaInfo.ID]
			if MapList and #MapList > 0 then
				table.insert(AreaList, {ID = AreaInfo.ID, Name = AreaInfo.Name, RegionID = RegionID })
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

	self.AreaList:UpdateByValues(AreaList)
end


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