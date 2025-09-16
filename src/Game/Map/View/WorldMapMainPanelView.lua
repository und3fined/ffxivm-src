---
--- Author: Administrator
--- DateTime: 2023-08-10 15:54
--- Description: 大地图
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapVM = require("Game/Map/VM/MapVM")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")
local WeatherDefine = require("Game/Weather/WeatherDefine")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MapUICfg = require("TableCfg/MapUICfg")
local UILayer = require("UI/UILayer")
local ProtoRes = require("Protocol/ProtoRes")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

local MapMgr = _G.MapMgr
local WorldMapMgr = _G.WorldMapMgr
local MapType = MapDefine.MapType
local MapMarkerEventType = ProtoRes.MapMarkerEventType


---@class WorldMapMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAetherCurrent UFButton
---@field BtnChangeLine UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnMountSpeed UFButton
---@field BtnSecondary UFButton
---@field BtnSet UFButton
---@field BtnTaskList UFButton
---@field BtnThreeLevel UFButton
---@field BtnTransmit UFButton
---@field BtnTreasureHunt UFButton
---@field BtnWeather UFButton
---@field BtnWorld UFButton
---@field BtnWorld02 UFButton
---@field EFF_Cloud UFCanvasPanel
---@field EFF_Fog UFCanvasPanel
---@field EFF_Part UFCanvasPanel
---@field FButton_0 UFButton
---@field ImgLocalIcon UFImage
---@field MI_DX_Common_WorldMap UFImage
---@field MapContent WorldMapContentView
---@field MapScalePanel WorldMapScaleItemView
---@field PanelMapCorner UFCanvasPanel
---@field PanelWayFinding UFCanvasPanel
---@field PanelWorldMapFrame UFCanvasPanel
---@field RichTextBox_65 URichTextBox
---@field SecondaryDropDown WorldMapTabDropDownListView
---@field SecondaryPanel UFCanvasPanel
---@field TableViewLocateList UTableView
---@field TextCoordinate UFTextBlock
---@field TextCoordinate_1 UFTextBlock
---@field TextSecondary UFTextBlock
---@field TextThreeLevel UFTextBlock
---@field TextWorld UFTextBlock
---@field TextWorld02 UFTextBlock
---@field TextWorldMapName UFTextBlock
---@field ThreeLevelDropDown WorldMapTabDropDownListView
---@field ThreeLevelPanel UFCanvasPanel
---@field ToggleButtonSecondary UToggleButton
---@field ToggleButtonThreeLevel UToggleButton
---@field WeatherTimeBar WeatherTimeBarItemView
---@field WeatherTimePanel UFCanvasPanel
---@field WorldTitlePanel UFCanvasPanel
---@field WorldTitlePanel01 UFCanvasPanel
---@field WorldTitlePanel02 UFCanvasPanel
---@field AnimCloudIn UWidgetAnimation
---@field AnimEnter_In UWidgetAnimation
---@field AnimEnter_Out UWidgetAnimation
---@field AnimFogClean UWidgetAnimation
---@field AnimFogCleanEnterIn UWidgetAnimation
---@field AnimFogCleanIn UWidgetAnimation
---@field AnimFogSwitch UWidgetAnimation
---@field AnimIn1 UWidgetAnimation
---@field AnimLeave_In UWidgetAnimation
---@field AnimLeave_Out UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimMap1In UWidgetAnimation
---@field AnimMap1To2 UWidgetAnimation
---@field AnimMap1To3 UWidgetAnimation
---@field AnimMap2To3 UWidgetAnimation
---@field AnimMap3To2 UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimToggleGroupDynamicIn UWidgetAnimation
---@field CurveScale CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapMainPanelView = LuaClass(UIView, true)

function WorldMapMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAetherCurrent = nil
	--self.BtnChangeLine = nil
	--self.BtnClose = nil
	--self.BtnMountSpeed = nil
	--self.BtnSecondary = nil
	--self.BtnSet = nil
	--self.BtnTaskList = nil
	--self.BtnThreeLevel = nil
	--self.BtnTransmit = nil
	--self.BtnTreasureHunt = nil
	--self.BtnWeather = nil
	--self.BtnWorld = nil
	--self.BtnWorld02 = nil
	--self.EFF_Cloud = nil
	--self.EFF_Fog = nil
	--self.EFF_Part = nil
	--self.FButton_0 = nil
	--self.ImgLocalIcon = nil
	--self.MI_DX_Common_WorldMap = nil
	--self.MapContent = nil
	--self.MapScalePanel = nil
	--self.PanelMapCorner = nil
	--self.PanelWayFinding = nil
	--self.PanelWorldMapFrame = nil
	--self.RichTextBox_65 = nil
	--self.SecondaryDropDown = nil
	--self.SecondaryPanel = nil
	--self.TableViewLocateList = nil
	--self.TextCoordinate = nil
	--self.TextCoordinate_1 = nil
	--self.TextSecondary = nil
	--self.TextThreeLevel = nil
	--self.TextWorld = nil
	--self.TextWorld02 = nil
	--self.TextWorldMapName = nil
	--self.ThreeLevelDropDown = nil
	--self.ThreeLevelPanel = nil
	--self.ToggleButtonSecondary = nil
	--self.ToggleButtonThreeLevel = nil
	--self.WeatherTimeBar = nil
	--self.WeatherTimePanel = nil
	--self.WorldTitlePanel = nil
	--self.WorldTitlePanel01 = nil
	--self.WorldTitlePanel02 = nil
	--self.AnimCloudIn = nil
	--self.AnimEnter_In = nil
	--self.AnimEnter_Out = nil
	--self.AnimFogClean = nil
	--self.AnimFogCleanEnterIn = nil
	--self.AnimFogCleanIn = nil
	--self.AnimFogSwitch = nil
	--self.AnimIn1 = nil
	--self.AnimLeave_In = nil
	--self.AnimLeave_Out = nil
	--self.AnimLoop = nil
	--self.AnimMap1In = nil
	--self.AnimMap1To2 = nil
	--self.AnimMap1To3 = nil
	--self.AnimMap2To3 = nil
	--self.AnimMap3To2 = nil
	--self.AnimOut = nil
	--self.AnimToggleGroupDynamicIn = nil
	--self.CurveScale = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.MapContent)
	self:AddSubView(self.MapScalePanel)
	self:AddSubView(self.SecondaryDropDown)
	self:AddSubView(self.ThreeLevelDropDown)
	self:AddSubView(self.WeatherTimeBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapMainPanelView:OnInit()
	self.UIMapMinScale = MapDefine.MapConstant.MAP_SCALE_MIN
	self.UIMapMaxScale = MapDefine.MapConstant.MAP_SCALE_MAX

	self.LastUIMapType = nil

	self.TextWorld:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
	self.TextSecondary:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
	self.TextThreeLevel:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)

	self.AdapterThreeLevelDropDown = UIAdapterTableView.CreateAdapter(self, self.ThreeLevelDropDown.TableViewItemList, self.OnMapSelectChanged)
	self.AdapterSecondaryDropDown = UIAdapterTableView.CreateAdapter(self, self.SecondaryDropDown.TableViewItemList, self.OnMapSelectChanged)
	self.AdapterFloorMapList = UIAdapterTableView.CreateAdapter(self, self.TableViewLocateList, self.OnMapSelectChanged)

	self.MultiBinders = {
		{
			ViewModel = MapVM,
			Binders = {
				{ "MapTimeVisible", UIBinderSetIsVisible.New(self, self.WeatherTimeBar) },
				{ "MajorLeftTopPosition", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMajorPosition)},
			}
		},
		{
			ViewModel = WorldMapVM,
			Binders = {
				{ "WorldMapName", UIBinderSetText.New(self, self.TextWorld) },  -- 一级菜单名称
				{ "MapTitle", UIBinderSetText.New(self, self.TextSecondary) },  -- 二级菜单名称
				{ "MapName", UIBinderSetText.New(self, self.TextThreeLevel) },  -- 三级菜单名称
				{ "MapName", UIBinderSetText.New(self, self.TextWorld02) }, -- 副本地图名称

				{ "SecondaryMapList", UIBinderUpdateBindableList.New(self, self.AdapterSecondaryDropDown) },
				{ "ThreeLevelMapList", UIBinderUpdateBindableList.New(self, self.AdapterThreeLevelDropDown) },
				{ "FloorMapList", UIBinderUpdateBindableList.New(self, self.AdapterFloorMapList) },

				{ "MapScale", UIBinderSetSlider.New(self, self.MapScalePanel.Slider) },
				{ "MapScale", UIBinderValueChangedCallback.New(self, nil, self.SetProgressBar) },

				{ "WorldMapFrameVisible", UIBinderSetIsVisible.New(self, self.PanelWorldMapFrame) },
				{ "WorldMapFrameVisible", UIBinderSetIsVisible.New(self, self.PanelMapCorner) },
				{ "WorldMapFrameVisible", UIBinderSetIsVisible.New(self, self.EFF_Part, true) },
				{ "WorldTitlePanelVisible", UIBinderSetIsVisible.New(self, self.WorldTitlePanel01) },
				{ "WorldTitlePanelVisible", UIBinderSetIsVisible.New(self, self.WorldTitlePanel02, true) },

				--{ "ThreeLevelPanelVisible", UIBinderSetIsVisible.New(self, self.ThreeLevelPanel) },
				--{ "SecondaryPanelVisible", UIBinderSetIsVisible.New(self, self.SecondaryPanel) },
				{ "ThreeLevelMapListVisible", UIBinderSetIsVisible.New(self, self.ThreeLevelDropDown) },
				{ "SecondaryMapListVisible", UIBinderSetIsVisible.New(self, self.SecondaryDropDown) },
				{ "FloorMapListVisible", UIBinderSetIsVisible.New(self, self.TableViewLocateList) },
				{ "ThreeLevelMapListVisible", UIBinderSetIsChecked.New(self, self.ToggleButtonThreeLevel) },
				{ "SecondaryMapListVisible", UIBinderSetIsChecked.New(self, self.ToggleButtonSecondary) },

				{ "BtnTransmitVisible", UIBinderSetIsVisible.New(self, self.BtnTransmit, false, true) },
				{ "BtnSetVisible", UIBinderSetIsVisible.New(self, self.BtnSet, false, true) },
				{ "BtnWeatherVisible", UIBinderSetIsVisible.New(self, self.BtnWeather, false, true) },
				{ "BtnAetherCurrentVisible", UIBinderSetIsVisible.New(self, self.BtnAetherCurrent, false, true) },
				{ "BtnTreasureHuntVisible", UIBinderSetIsVisible.New(self, self.BtnTreasureHunt, false, true) },
				{ "BtnTaskListVisible", UIBinderSetIsVisible.New(self, self.BtnTaskList, false, true) },

				{ "WeatherTimePanelVisible", UIBinderSetIsVisible.New(self, self.WeatherTimePanel ) },

				{ "MapAutoPathMoving", UIBinderSetIsVisible.New(self, self.ImgLocalIcon, true ) },
				{ "MapAutoPathMoving", UIBinderSetIsVisible.New(self, self.PanelWayFinding ) },
				{ "BtnMountSpeedVisible",UIBinderSetIsVisible.New(self, self.BtnMountSpeed, false, true)}
			}
		}
	}
end

function WorldMapMainPanelView:OnDestroy()

end

function WorldMapMainPanelView:OnShow()
	self.TextWorldMapName:SetText(_G.LSTR(700045))

	WorldMapVM:SetSecondaryMapList(MapUtil.GetAllRegionMapList())
	self:UpdateMajorCoordinate()

	local UIMapID
	local MapID
	local Params = self.Params
	if nil ~= Params then
		if nil ~= Params.UIMapID and nil ~= Params.MapID then
			UIMapID = Params.UIMapID
			MapID = Params.MapID
		elseif nil ~= Params.MapID then
			UIMapID = MapUtil.GetUIMapID(Params.MapID)
			MapID = Params.MapID
		elseif nil ~= Params.UIMapID then
			UIMapID = Params.UIMapID
			MapID = MapUtil.GetMapID(Params.UIMapID)
		end
	end
	if nil == UIMapID then
		UIMapID = MapMgr:GetUIMapID()
		MapID = MapMgr:GetMapID()
	end
	self.LastUIMapType = MapUtil.GetMapType(UIMapID)

	WorldMapMgr:UpdateFog(UIMapID, MapID)
	if not WorldMapMgr:ChangeMap(UIMapID, MapID, true) then
		self:UpdateMapList()
		self:UpdateMapScale()
	end

	if UIViewMgr:IsViewVisible(UIViewID.TreasureHuntSkillPanel) then
		local TreasureHuntView = UIViewMgr:FindView(UIViewID.TreasureHuntSkillPanel)
		if TreasureHuntView ~= nil then
			local InPosition = TreasureHuntView:GetPosition()
			local Offsets = TreasureHuntView:GetOffsets()
			UIViewMgr:ChangeLayer(UIViewID.TreasureHuntSkillPanel, UILayer.AboveNormal)
			TreasureHuntView:SetPosition(InPosition)
			TreasureHuntView:SetOffsets(Offsets)
		end
	end

	self.IsOpenMapShow = true
	self:PlayFogAnim(true, MapID, UIMapID)

	WorldMapMgr:ReportData(MapDefine.MapReportType.MapOpen, WorldMapVM.MapOpenSource)

	MapMgr:SetUpdateMap(true, 2)
end

function WorldMapMainPanelView:OnHide()
	WorldMapVM:CloseSendMarkerView()
	WorldMapVM:HideTempPanel()
	WorldMapVM:HideRelatedPanel()

	if WorldMapMgr:GetWorldMapShowQuestID() then
		WorldMapMgr:SetWorldMapShowQuestID(nil)
	end

	if UIViewMgr:IsViewVisible(UIViewID.TreasureHuntSkillPanel) then
		local TreasureHuntView = UIViewMgr:FindView(UIViewID.TreasureHuntSkillPanel)
		if TreasureHuntView ~= nil then
			local InPosition = TreasureHuntView:GetPosition()
			local Offsets = TreasureHuntView:GetOffsets()
			UIViewMgr:ChangeLayer(UIViewID.TreasureHuntSkillPanel, UILayer.AboveLow)
			TreasureHuntView:SetPosition(InPosition)
			TreasureHuntView:SetOffsets(Offsets)
		end
	end

	MapMgr:SetUpdateMap(false, 2)
end

function WorldMapMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnWorld, self.OnClickedBtnWorld)
	UIUtil.AddOnClickedEvent(self, self.BtnSecondary, self.OnClickedBtnSecondary)
	UIUtil.AddOnClickedEvent(self, self.BtnThreeLevel, self.OnClickedBtnThreeLevel)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonSecondary, self.OnStateChangedToggleSecondary)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonThreeLevel, self.OnStateChangedToggleThreeLevel)

	UIUtil.AddOnClickedEvent(self, self.BtnTransmit, self.OnClickedBtnTransmit)
	UIUtil.AddOnClickedEvent(self, self.BtnTreasureHunt, self.OnClickedBtnTreasureHunt)
	UIUtil.AddOnClickedEvent(self, self.BtnTaskList, self.OnClickedBtnTaskList)
	UIUtil.AddOnClickedEvent(self, self.BtnSet, self.OnClickedBtnSet)
	UIUtil.AddOnClickedEvent(self, self.BtnWeather, self.OnClickedBtnWeather)
	UIUtil.AddOnClickedEvent(self, self.BtnAetherCurrent, self.OnClickedBtnAetherCurrent)

	UIUtil.AddOnValueChangedEvent(self, self.MapScalePanel.Slider, self.OnValueChangedScale)
	UIUtil.AddOnMouseCaptureBeginEvent(self, self.MapScalePanel.Slider, self.OnSliderMouseCaptureBegin)
    UIUtil.AddOnMouseCaptureEndEvent(self, self.MapScalePanel.Slider, self.OnSliderMouseCaptureEnd)
	UIUtil.AddOnClickedEvent(self, self.MapScalePanel.BtnAdd, self.OnClickedBtnScaleAdd)
	UIUtil.AddOnClickedEvent(self, self.MapScalePanel.BtnSub, self.OnClickedBtnScaleSub)
	UIUtil.AddOnClickedEvent(self, self.FButton_0, self.OnClickedBtnMajorCoordinate)
	UIUtil.AddOnClickedEvent(self, self.BtnMountSpeed,self.OnClickBtnMountSpeed)
end

function WorldMapMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.WorldMapSelectChanged, self.OnGameEventWorldMapSelectChanged)
	self:RegisterGameEvent(EventID.WorldMapUpdateDiscovery, self.OnGameEventWorldMapUpdateDiscovery)
	self:RegisterGameEvent(EventID.MapFollowAdd, self.OnGameEventMapFollowAdd)
	self:RegisterGameEvent(EventID.MapFollowDelete, self.OnGameEventMapFollowDelete)
	self:RegisterGameEvent(EventID.UpdateFogInfo, self.OnGameEventUpdateFogInfo)
end

function WorldMapMainPanelView:OnRegisterTimer()
end

function WorldMapMainPanelView:OnRegisterBinder()
	self:RegisterMultiBinders(self.MultiBinders)
end

function WorldMapMainPanelView:OnMapSelectChanged(Index, ItemData, ItemView)
	WorldMapMgr:ChangeMap(ItemData.ID)
end

function WorldMapMainPanelView:OnGameEventWorldMapSelectChanged()
	self:UpdateMapList()
	self:UpdateMapScale()
	self.bReceiveSliderChangeByMouse = false -- 避免在缩放切换地图时多次触发

	self:PlayInMapAnim()
	self:PlayMapChangeTitleAnim()
	self:PlayFadeInMapAnim()
	self:PlayFogAnim()
end

function WorldMapMainPanelView:OnGameEventWorldMapUpdateDiscovery()
	WorldMapMgr:UpdateDiscovery()
end

-- 地图追踪更新时要更新地图列表的状态图标
function WorldMapMainPanelView:OnGameEventMapFollowAdd()
	self:UpdateMapList()
end

function WorldMapMainPanelView:OnGameEventMapFollowDelete()
	self:UpdateMapList()
end

function WorldMapMainPanelView:OnGameEventUpdateFogInfo()
	self:PlayFogAnim()
	self.MapContent:UpdateMarkerByFogInfo()
end

function WorldMapMainPanelView:UpdateMapList()
	local UIMapID = WorldMapMgr:GetUIMapID()

	local CurrentMapType = MapUtil.GetMapType(UIMapID)
	if MapType.Area == CurrentMapType then
		self.AdapterThreeLevelDropDown:CancelSelected()

		local SmallAreaMapList = MapUtil.GetAreaDownMapList(UIMapID)
		if #SmallAreaMapList > 0 then
			WorldMapVM:SetFloorMapListVisible(true)
			if MapUtil.GetMapNameUI(UIMapID) ~= MapUtil.GetMapNameUI(WorldMapMgr:GetLastUIMapID()) then
				self:PlayAnimation(self.AnimToggleGroupDynamicIn)
			end
			WorldMapVM:SetFloorMapList(SmallAreaMapList)
		else
			WorldMapVM:SetFloorMapListVisible(false)
		end

	elseif MapType.Region == CurrentMapType then
		self.AdapterSecondaryDropDown:CancelSelected()
	end
end


function WorldMapMainPanelView:OnClickedBtnTaskList()
	WorldMapVM:ShowWorldMapTaskListPanel(true)
end

function WorldMapMainPanelView:OnClickedBtnTransmit()
	if WorldMapVM.WorldMapTransferPanelVisible then
		WorldMapVM:ShowWorldMapTransferPanel(false)
	else
		WorldMapVM:ShowWorldMapTransferPanel(true)
	end
end

function WorldMapMainPanelView:OnClickedBtnTreasureHunt()
	_G.TreasureHuntMgr:OpenTreasureHuntMainPanel()
end

function WorldMapMainPanelView:OnClickedBtnWorld()
	WorldMapMgr:ChangeMap(MapUtil.GetWorldUIMapID())
end

function WorldMapMainPanelView:OnClickedBtnSecondary()
	if MapUtil.IsAreaMap(WorldMapMgr:GetUIMapID()) then
		WorldMapMgr:ChangeMap(WorldMapMgr:GetUpperUIMapID())
	end
end

function WorldMapMainPanelView:OnClickedBtnThreeLevel()
	-- nothing
end

function WorldMapMainPanelView:OnStateChangedToggleSecondary(ToggleButton, ButtonState)
	if WorldMapVM.SecondaryMapListVisible then
		WorldMapVM:SetSecondaryMapListVisible(false)
	else
		WorldMapVM:SetSecondaryMapListVisible(true)
		WorldMapVM:SetThreeLevelMapListVisible(false)
	end
end

function WorldMapMainPanelView:OnStateChangedToggleThreeLevel(ToggleButton, ButtonState)
	if WorldMapVM.ThreeLevelMapListVisible then
		WorldMapVM:SetThreeLevelMapListVisible(false)
	else
		WorldMapVM:SetThreeLevelMapListVisible(true)
		WorldMapVM:SetSecondaryMapListVisible(false)
	end
end

function WorldMapMainPanelView:OnClickedBtnSet()
	WorldMapVM:SetMapSettingPanelVisible(true)
end

function WorldMapMainPanelView:OnClickedBtnWeather()
	_G.WeatherMgr:OpenWeahterForecastUI({Source = WeatherDefine.Source.Map})
end

function WorldMapMainPanelView:OnClickedBtnAetherCurrent()
	_G.AetherCurrentsMgr:OpenAetherCurrentMainPanel()
	WorldMapMgr:ReportData(MapDefine.MapReportType.OpenAetherCurrent)
end

function WorldMapMainPanelView:OnClickBtnMountSpeed()
	_G.MountMgr:OpenMountSpeedMainPanel()
end

--region 缩放相关

function WorldMapMainPanelView:SetProgressBar(Value)
	local UIMapMinScale = self.UIMapMinScale
	local UIMapMaxScale = self.UIMapMaxScale

	self.MapScalePanel.ProgressBar:SetPercent((Value - UIMapMinScale) / (UIMapMaxScale - UIMapMinScale))
end

function WorldMapMainPanelView:OnValueChangedScale(_, Value)
	if self.bReceiveSliderChangeByMouse == true then
        WorldMapMgr:OnMapScaleChange(Value)
    else
        self.MapScalePanel.Slider:SetValue(WorldMapVM.MapScale)
    end
end

function WorldMapMainPanelView:OnSliderMouseCaptureBegin()
    self.bReceiveSliderChangeByMouse = true
end

function WorldMapMainPanelView:OnSliderMouseCaptureEnd()
    self.bReceiveSliderChangeByMouse = false
end

function WorldMapMainPanelView:OnClickedBtnScaleAdd()
	local Value = self.MapScalePanel.Slider:GetValue()
	local NewValue = Value + 0.2
	NewValue = math.clamp(NewValue, self.UIMapMinScale, self.UIMapMaxScale)
	WorldMapMgr:OnMapScaleChange(NewValue)
end

function WorldMapMainPanelView:OnClickedBtnScaleSub()
	local Value = self.MapScalePanel.Slider:GetValue()
	local NewValue = Value - 0.2
	NewValue = math.clamp(NewValue, self.UIMapMinScale, self.UIMapMaxScale)
	WorldMapMgr:OnMapScaleChange(NewValue)
end

function WorldMapMainPanelView:SetFogScale(Value)
	local UIMapMinScale = self.UIMapMinScale + 0.1 --加0.1,缩到最小会切出二级地图
	local UIMapMaxScale = self.UIMapMaxScale
	local Ratio = (Value - UIMapMinScale) / (UIMapMaxScale - UIMapMinScale)
	local RenderScale = _G.UE.UMathUtil.Lerp(1, 5.28, Ratio)
	RenderScale = math.clamp(RenderScale, 1, 1.7)
	self.EFF_Fog:SetRenderScale(_G.UE.FVector2D(RenderScale, RenderScale))
end

--endregion


function WorldMapMainPanelView:OnValueChangedMajorPosition(MajorLeftTopPosition)
	self:UpdateMajorCoordinate()
end

function WorldMapMainPanelView:UpdateMajorCoordinate()
	local Position = MapVM:GetMajorLeftTopPosition()
	local InfoText = string.format("%s  %s", MapUtil.GetCoordinateText(Position), MapUtil.GetMapFullName())

	if _G.PWorldMgr:IsShowPWorldLine() then
		local CurrLineID = _G.PWorldMgr:GetCurrPWorldLineID()
		if CurrLineID > 0 then
			InfoText = string.format("%s（%02d）", InfoText, CurrLineID)
		end
	end

	self.TextCoordinate:SetText(InfoText)
end

-- 点击个人位置坐标信息，切换到所在地图，并以主角标记为中心
function WorldMapMainPanelView:OnClickedBtnMajorCoordinate()
	self:RegisterGameEvent(EventID.WorldMapFinishCreateMarkers, self.OnWorldMapFinishCreateMarkers)
	WorldMapMgr:ChangeMap(MapMgr:GetUIMapID())
end

function WorldMapMainPanelView:OnWorldMapFinishCreateMarkers()
	self.MapContent:AdjustMarker2CenterPos(MapDefine.MapMarkerType.Major, 0)
	self:UnRegisterGameEvent(EventID.WorldMapFinishCreateMarkers, self.OnWorldMapFinishCreateMarkers)
end


--region 动画相关

---地图切换时播放标题切换动画（原来的动画改的，名称未变）
function WorldMapMainPanelView:PlayMapChangeTitleAnim()
	local LastMapType = self.LastUIMapType
	local CurrentMapType = MapUtil.GetMapType(WorldMapMgr:GetUIMapID())
	if LastMapType == CurrentMapType then
		return
	end

	if CurrentMapType == MapType.Area then
		if LastMapType == MapType.Region then
			self:PlayAnimation(self.AnimMap2To3)
		elseif LastMapType == MapType.World then
			self:PlayAnimation(self.AnimMap1To3)
		end
	end

	if CurrentMapType == MapType.Region then
		if LastMapType == MapType.World then
			self:PlayAnimation(self.AnimMap1To2)
		elseif LastMapType == MapType.Area then
			self:PlayAnimation(self.AnimMap3To2)
		end
	end

	if CurrentMapType == MapType.World then
		self:PlayAnimation(self.AnimMap1In)
	end

	self.LastUIMapType = CurrentMapType
end

---获取地图切换动画
---@param IsOut boolean 是否退场动画
function WorldMapMainPanelView:GetChangeMapAnim(IsOut)
	local LastMapType = self.LastUIMapType
	local CurrentMapType
	if IsOut then
		CurrentMapType = MapUtil.GetMapType(WorldMapMgr:GetNextUIMapID())
	else
		CurrentMapType = MapUtil.GetMapType(WorldMapMgr:GetUIMapID())
	end
	if LastMapType == CurrentMapType then
		return
	end

	-- 由三级地图方向向外，用Leave名称的动画
	if CurrentMapType == MapType.World
		or (CurrentMapType == MapType.Region and LastMapType == MapType.Area) then
		if IsOut then
			return self.AnimLeave_Out
		else
			return self.AnimLeave_In
		end
	end

	-- 由世界地图方向向内，用Enter名称的动画
	if CurrentMapType == MapType.Area
		or (CurrentMapType == MapType.Region and LastMapType == MapType.World) then
		if IsOut then
			return self.AnimEnter_Out
		else
			return self.AnimEnter_In
		end
	end
end

---播放退场动画
function WorldMapMainPanelView:PlayOutMapAnim()
	local OutMapAnim = self:GetChangeMapAnim(true)
	if OutMapAnim then
		self:PlayAnimation(OutMapAnim)
	end
end

---获得退场动画时长
function WorldMapMainPanelView:GetOutMapAnimTime()
	local OutMapAnim = self:GetChangeMapAnim(true)
	if OutMapAnim then
		return OutMapAnim:GetEndTime()
	end
	return 0
end

---播放入场动画
function WorldMapMainPanelView:PlayInMapAnim()
	local InMapAnim = self:GetChangeMapAnim(false)
	if InMapAnim then
		self:PlayAnimation(InMapAnim)
	end
end

---播放MapContent淡出动画（过去遗留）
function WorldMapMainPanelView:PlayFadeOutMapAnim()
	self.MapContent:PlayFadeOutMapAnim()
end

---播放MapContent淡入动画（过去遗留）
function WorldMapMainPanelView:PlayFadeInMapAnim()
	self.MapContent:PlayFadeInMapAnim()
end

---播放迷雾动画
---@param IsCallWhenShow boolean
---@param MapID number
---@param UIMapID number
function WorldMapMainPanelView:PlayFogAnim(IsCallWhenShow, MapID, UIMapID)
	if not self.IsInitEvent then --第一次调用不执行
		self.IsInitEvent = true
		return
	end
	self.CurMapScaleAnimTime = 0 --记录当前动效播放时间
	if self:IsAnimationPlaying(self.AnimFogCleanIn) then
		self:StopAnimation(self.AnimFogCleanIn)
	end
	if self:IsAnimationPlaying(self.AnimFogCleanEnterIn) then
		self:StopAnimation(self.AnimFogCleanEnterIn)
	end

	if self:IsAnimationPlaying(self.AnimIn1) then
		self:PlayAnimToEnd(self.AnimIn1)
	end

	if not MapID then
		MapID = WorldMapMgr:GetMapID()
	end
	if not UIMapID then
		UIMapID = WorldMapMgr:GetUIMapID()
	end
	if MapUtil.IsAreaMap(UIMapID) then
		if not MapID then
			UIUtil.SetIsVisible(self.EFF_Fog, false)
			UIUtil.SetIsVisible(self.EFF_Cloud, true)
			self:PlayAnimation(self.AnimIn1)
			self.CurMapScaleAnimTime = 1.2
			return
		end
		if MapID > 0 then
			if _G.FogMgr:CanPlayClearFogAnimation(MapID) then
				UIUtil.SetIsVisible(self.EFF_Fog, true)
				UIUtil.SetIsVisible(self.EFF_Cloud, true)
				if IsCallWhenShow then
					self:PlayAnimation(self.AnimFogCleanIn)
				else
					if self:IsAnimationPlaying(self.AnimEnter_In) then
						self:StopAnimation(self.AnimEnter_In)
					end
					self:PlayAnimation(self.AnimFogCleanEnterIn)
				end
				self.CurMapScaleAnimTime = 4.7
				_G.FogMgr:RecordPlayClearFogAnimation(MapID) --只会播放一次,播放记录存储到服务器
			else
				local IsAllActivate = _G.FogMgr:IsAllActivate(MapID)
				self.EFF_Fog:SetRenderScale(_G.UE.FVector2D(1.7, 1.7))
				UIUtil.SetIsVisible(self.EFF_Fog, not IsAllActivate)
				UIUtil.SetIsVisible(self.EFF_Cloud, IsAllActivate)
				if IsCallWhenShow then
					self:PlayAnimation(self.AnimIn1)
					self.CurMapScaleAnimTime = 1.2
				else
					self:PlayAnimation(self.AnimFogSwitch)
					self.CurMapScaleAnimTime = 0.2
				end
			end
		end
	else
		UIUtil.SetIsVisible(self.EFF_Fog, false)
	end
end

---播放传送门标记高亮效果
function WorldMapMainPanelView:PlayDransDoorHighlight()

	-- 查找传送门标记
	local MarkerPredicate = function(Marker)
		if Marker:GetType() == MapDefine.MapMarkerType.FixPoint then
			if Marker:GetEventType() == MapMarkerEventType.MAP_MARKER_EVENT_TRANS_DOOR then
				return true
			end
		end

		return false
	end

	-- 是否存在传送门标记
	local MarkerView = self.MapContent:GetMapMarkerByPredicate(MarkerPredicate)
	if not MarkerView then
		return
	end

	-- 首次打开该地图时才播放高亮效果
	local UIMapID = WorldMapMgr:GetUIMapID()
	if WorldMapVM:CanPlayDransDoorHighlight(UIMapID) then
		local Params = {}
		Params.MarkerPredicate = MarkerPredicate
		self.MapContent:UpdateMarkerHighlightEffect(Params)

		WorldMapVM:RecordDransDoorHighlight(UIMapID)
	end
end

---获取地图缩放动画时间
---地图主界面打开时会播放动画，动画里会缩放地图，从而影响地图标记的位置计算
---这里动画里缩放地图的时间是和动效沟通的，并不是动画本身的时长
function WorldMapMainPanelView:GetMapScaleAnimTime()
	return self.CurMapScaleAnimTime or 0
end

function WorldMapMainPanelView:GetFadeOutMapAnimTime()
	return self.MapContent:GetFadeOutMapAnimTime()
end

--endregion


function WorldMapMainPanelView:UpdateMapScale()
	local UIMapID = WorldMapMgr:GetUIMapID()
	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		return
	end

	local UIMapMinScale = Cfg.UIMapMinScale
	local UIMapMaxScale = Cfg.UIMapMaxScale

	if MapUtil.IsWorldMap(UIMapID) then
		local ViewportSize = UIUtil.GetViewportSize()
		local Scale = UIUtil.GetViewportScale()
		local ViewportX = ViewportSize.X / Scale
		local ViewportY = ViewportSize.Y / Scale
		local WorldMapWidth = 4096
		local WorldMapHeight = 1654
		local MinScaleWidth = ViewportX / WorldMapWidth
		local MinScaleHeight = ViewportY / WorldMapHeight
		UIMapMinScale = math.max(MinScaleWidth, MinScaleHeight)
	end

	self.UIMapMinScale = UIMapMinScale
	self.UIMapMaxScale = UIMapMaxScale

	self.MapScalePanel:UpdateSlider(UIMapMinScale, UIMapMaxScale)
end

--- 蓝图发送的事件
function WorldMapMainPanelView:SequenceEvent_FogCleanIn()
	local Percent = self:GetAnimationCurrentTime(self.AnimFogCleanIn) or 1
	local Val = self.CurveScale:GetFloatvalue(Percent) or 1
	local Scale = self.UIMapMinScale + 0.15 + 0.35 * Val
	self:SetFogScale(Scale)
	_G.EventMgr:SendEvent(EventID.WorldMapScaleChanged, Scale)
end

function WorldMapMainPanelView:SequenceEvent_FogCleanEnterIn()
	local Percent = self:GetAnimationCurrentTime(self.AnimFogCleanEnterIn) or 1
	local Val = self.CurveScale:GetFloatvalue(Percent) or 1
	local Scale = self.UIMapMinScale + 0.15 + 0.35 * Val
	self:SetFogScale(Scale)
	_G.EventMgr:SendEvent(EventID.WorldMapScaleChanged, Scale)
end

---打开地图时播放动画，动画事件通知地图缩放结束
function WorldMapMainPanelView:SequenceEvent_FinishMapScale()
	if self.IsOpenMapShow then
		self.MapContent:OnPlayAnimMapScaleFinish()
		self:PlayDransDoorHighlight()
		self.IsOpenMapShow = false
	end
end

function WorldMapMainPanelView:ShowTreasureHuntCrystal(MapData)
	self.MapContent:ShowTreasureHuntCrystal(MapData)
end

return WorldMapMainPanelView