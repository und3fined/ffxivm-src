---
--- Author: anypkvcai
--- DateTime: 2022-12-07 11:20
--- Description: 大地图
---

--local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapVM = require("Game/Map/VM/MapVM")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")
local MapUtil = require("Game/Map/MapUtil")
local MapContentView = require("Game/Map/View/MapContentView")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetMaterialTextureFromAssetPath = require("Binder/UIBinderSetMaterialTextureFromAssetPath")
local UIBinderSetMaterialScalarParameterValue = require("Binder/UIBinderSetMaterialScalarParameterValue")

local EventID = require("Define/EventID")
local MapDefine = require("Game/Map/MapDefine")
local CommonUtil = require("Utils/CommonUtil")
local UIViewID = require("Define/UIViewID")
local MapUICfg = require("TableCfg/MapUICfg")
local ObjectGCType = require("Define/ObjectGCType")

local MapContentType = MapDefine.MapContentType
local MapConstant = MapDefine.MapConstant
local MapMarkerType = MapDefine.MapMarkerType

local UKismetInputLibrary = _G.UE.UKismetInputLibrary
local FVector2D = _G.UE.FVector2D
local WorldMapMgr = _G.WorldMapMgr
local MapMgr = _G.MapMgr
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local UIViewMgr = _G.UIViewMgr

local TargetSizeX = 2500
local TargetSizeY = 2048


---@class WorldMapContentView : MapContentView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommGesture_UIBP CommGestureView
---@field CommonCurve_UIBP CommonCurveView
---@field ImgBG UFImage
---@field ImgMap UFImage
---@field ImgMask UFImage
---@field MapPlacedMarker WorldMapPlacedMarkerItemView
---@field MovePath_UIBP MovePathView
---@field PanelMap UFCanvasPanel
---@field PanelMarker UFCanvasPanel
---@field PanelRegion UFCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimMapIn UWidgetAnimation
---@field AnimMapOut UWidgetAnimation
---@field AnimMove UWidgetAnimation
---@field CurveMove CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapContentView = LuaClass(MapContentView, true)

function WorldMapContentView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommGesture_UIBP = nil
	--self.CommonCurve_UIBP = nil
	--self.ImgBG = nil
	--self.ImgMap = nil
	--self.ImgMask = nil
	--self.MapPlacedMarker = nil
	--self.MovePath_UIBP = nil
	--self.PanelMap = nil
	--self.PanelMarker = nil
	--self.PanelRegion = nil
	--self.AnimIn = nil
	--self.AnimMapIn = nil
	--self.AnimMapOut = nil
	--self.AnimMove = nil
	--self.CurveMove = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.PlacedMarkerPos = nil
	--self.MarkerOffset = UE.FMargin()
	--self.MarkerAnchors = UE.FAnchors()
	--self.MarkerAnchors.Minimum = UE.FVector2D(0, 0)
	--self.MarkerAnchors.Maximum = UE.FVector2D(0, 0)
	--self.MarkerAnchors.Minimum = UE.FVector2D(0.5, 0.5)
	--self.MarkerAnchors.Maximum = UE.FVector2D(0.5, 0.5)
end

function WorldMapContentView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommGesture_UIBP)
	self:AddSubView(self.CommonCurve_UIBP)
	self:AddSubView(self.MapPlacedMarker)
	self:AddSubView(self.MovePath_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapContentView:OnInit()
	self.Super:OnInit()

	self.IsControlDown = false
	self.AllowClick = false
	self.SendLoctionMode = false
	self.ContentType = MapContentType.WorldMap
	self.DerivativeWindowHide = false
	self.MinScaleTimes = 0
	self.MaxScaleTimes = 0

	local CommGesture = self.CommGesture_UIBP

	local function OnScaleChanged(RenderScale)
		WorldMapMgr:OnMapScaleChange(RenderScale.X, true)
	end

	CommGesture:SetOnScaleChangedCallback(OnScaleChanged)

	local function OnPositionChanged(X, Y)
		self:OnPositionChanged(X, Y)
	end

	CommGesture:SetOnPositionChangedCallback(OnPositionChanged)

	local function OnClickedMap(ScreenPosition)
		WorldMapVM:HideTempPanel()

		if not self.AllowClick then
			return
		end

		self:OnClickedMap(ScreenPosition)

		if CommonUtil.GetDeviceType() == 2 then
			self:WorldMapClickedMap(ScreenPosition)
		end
	end

	CommGesture:SetOnClickedCallback(OnClickedMap)

	self.MultiBinders = {
		{
			ViewModel = MapVM,
			Binders = {
				{ "MarkerTextVisible", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerTextVisible) },

				{ "MarkerIconVisible", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerIconVisible) },
				{ "MapCrystalIconVisible", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerIconVisible) },
				{ "MapQuestShowType", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerIconVisible) },
				{ "MapWildBoxVisible", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerIconVisible, MapDefine.MapMarkerType.Gameplay) },
				{ "MapAetherCurrentVisible", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerIconVisible, MapDefine.MapMarkerType.Gameplay) },
				{ "MapDiscoverNoteVisible", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerIconVisible, MapDefine.MapMarkerType.Gameplay) },
			}
		},
		{
			ViewModel = WorldMapVM,
			Binders = {
				{ "MapPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgMap, false, true, true)},
				{ "IsMaskVisible", UIBinderSetIsVisible.New(self, self.ImgMask)},
				{ "MaskPath", UIBinderSetMaterialTextureFromAssetPath.New(self, self.ImgMask, "Mask")},
				{ "DiscoveryFlag", UIBinderSetMaterialScalarParameterValue.New(self, self.ImgMask, "DiscoveryFlag")},

				{ "PlacedMarkerVisible", UIBinderSetIsVisible.New(self, self.MapPlacedMarker) },
				{ "WorldMapContentAllowClick", UIBinderValueChangedCallback.New(self, nil, self.SetAllowClick)},
				{ "MapSendMarkWinLoctionPanelVisible", UIBinderValueChangedCallback.New(self, nil, self.SetSendLoctionMode)},
			}
		}
	}

end

function WorldMapContentView:SetSendLoctionMode(IsOpen)
	self.SendLoctionMode = IsOpen
end

function WorldMapContentView:SetAllowClick(Allow)
	self.AllowClick = Allow
end

function WorldMapContentView:OnShow()
	self:OnMapChanged()

	local Params = self.Params
	if nil ~= Params then
		self:SetContentType(Params.ContentType)
	else
		self:SetContentType(MapContentType.WorldMap)
	end

	self.PlacedMarkerPos = nil
	WorldMapVM:SetPlacedMarkerVisible(false)

	self.AdditionalMapMarker = nil
    self.IsControlDown = false
	self.LastCheckMark = nil

	_G.MapMarkerMgr:CreateProviders(self.ContentType)
	self:CreateAllMarkers(WorldMapMgr:GetUIMapID(), WorldMapMgr:GetMapID())

	local ViewportSize = UIUtil.GetViewportSize()
	local Scale = UIUtil.GetViewportScale()
	local ViewportX = ViewportSize.X / Scale
	local ViewportY = ViewportSize.Y / Scale

	local CommGesture = self.CommGesture_UIBP
	CommGesture:SetIsLockArea(true)
	CommGesture:SetLockArea(0, ViewportX, 0, ViewportY)
	CommGesture:SetTargetSize(TargetSizeX, TargetSizeY)

	--local MinScale = math.min(ViewportX / MAP_PANEL_WIDTH, ViewportY / MAP_PANEL_HEIGHT)
	--CommGesture:SetMinRenderScale(MinScale)
	--CommGesture:SetMaxRenderScale(2)
	--CommGesture:SetMaxMoveDistance(ViewportX / 2, ViewportY / 2)

	self:UpdateAutoPathLine()

	self:OpenMapShowMarker()
end

function WorldMapContentView:OnHide()
	self:FocusMarkerByID(0)
	_G.MapMarkerMgr:ReleaseProviders(self.ContentType)
	--self:CheckMarkAnim()

	-- 地图关闭时，延迟销毁地图标记，避免在地图退场动画时，地图背景元素被销毁从而穿帮
	local function DelayReleaseAllMarker()
		self:ReleaseAllMarker()
		self:HideFirsetWorldMap()
		self:HideGoldSaucerMap()
		_G.ObjectMgr:CollectGarbage(false)
	end
	self:RegisterTimer(DelayReleaseAllMarker, 0.3)
	UIUtil.SetIsVisible(self.PanelMarker, false)

	WorldMapMgr:ResetUIMapInfo()
	self.MovePath_UIBP:Clear()
	MapUtil.ClearFindDBCache()
end

function WorldMapContentView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()

	self:RegisterGameEvent(EventID.WorldMapScaleChanged, self.OnGameEventWorldMapScaleChanged)
	self:RegisterGameEvent(EventID.WorldMapSelectChanged, self.OnGameEventWorldMapSelectChanged)
	self:RegisterGameEvent(EventID.WorldMapUpdateAllMarker, self.OnGameEventWorldMapUpdateAllMarker)
	self:RegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)

	self:RegisterGameEvent(EventID.UpdateChocoboTransportPosition, self.OnGameEventUpdateChocoboTransportPosition)
	self:RegisterGameEvent(EventID.ChocoboTransportFinish, self.OnGameEventChocoboTransportFinish)
	self:RegisterGameEvent(EventID.MapAutoPathUpdate, self.OnGameEventMapAutoPathUpdate)
	self:RegisterGameEvent(EventID.MapAutoPathProgressUpdate, self.OnGameEventMapAutoPathProgressUpdate)

	self:RegisterGameEvent(EventID.MapFollowAdd, self.OnGameEventMapFollowAdd)
	self:RegisterGameEvent(EventID.MapFollowDelete, self.OnGameEventMapFollowDelete)

	self:RegisterGameEvent(EventID.UpdateQuest, self.OnGameEventUpdateQuest)
	self:RegisterGameEvent(EventID.MapMarkerPriorityUpdate, self.OnGameEventMapMarkerPriorityUpdate)
	self:RegisterGameEvent(EventID.MapMarkerHighlight, self.OnGameEventMapMarkerHighlight)
end

function WorldMapContentView:OnRegisterBinder()
	self:RegisterMultiBinders(self.MultiBinders)
end


function WorldMapContentView:OnPreprocessedMouseButtonDown(MouseEvent)
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)

	if self:CheckHaveDerivativeWindow() then
		self.DerivativeWindowHide = true
		self:RegisterTimer(function()
			if UIUtil.IsUnderLocation(self, MousePosition) and not self:CheckHaveDerivativeWindow()
				and not WorldMapVM.ClickWorldMapTipsContent then
				if self.CommGesture_UIBP.OnClickedCallback ~= nil then
					self.CommGesture_UIBP.OnClickedCallback(MousePosition)
				end
			end
		end , 0.3)
	end
end

function WorldMapContentView:CheckHaveDerivativeWindow()
	-- 目前所有 地图标记 扩展界面
	if UIViewMgr:IsViewVisible(UIViewID.WorldMapMarkerTipsList) or
	   UIViewMgr:IsViewVisible(UIViewID.WorldMapMarkerTipsFollow) or
	   UIViewMgr:IsViewVisible(UIViewID.WorldMapMarkerTipsTransfer) or
	   UIViewMgr:IsViewVisible(UIViewID.WorldMapMarkerTipsTarget) or
	   UIViewMgr:IsViewVisible(UIViewID.WorldMapMarkerFateStageInfoPanel) or
	   UIViewMgr:IsViewVisible(UIViewID.WorldMapMarkerPlayStyleStageInfo) then
		return true
	end

	return false
end

---通过滑动条改变缩放
---@param Scale number
function WorldMapContentView:OnGameEventWorldMapScaleChanged(Scale)
	self.RenderScale.X = Scale
	self.RenderScale.Y = Scale
	self:OnScaleChanged()
end

function WorldMapContentView:OnGameEventWorldMapSelectChanged()
	self:OnMapChanged()

	self:CreateAllMarkers(WorldMapMgr:GetUIMapID(), WorldMapMgr:GetMapID())

	-- 触发已完成创建标记事件，分两个事件是因为标记显示和切换动画完成有时间差
	_G.EventMgr:SendEvent(_G.EventID.WorldMapFinishCreateMarkers)

	-- 与动效沟通，入场动画本身时间较长，但影响MapContent节点坐标的时间约1.1秒
	self:RegisterTimer(function()
		_G.EventMgr:SendEvent(_G.EventID.WorldMapFinishChanged)
	end, 1.1)

	-- 切地图后，处理标记尽量居中显示，目前用于非首次打开地图的情况
	if self.AdjustCenterMarker then
		self:AdjustMarker2CenterPos(self.AdjustCenterMarker:GetType(), self.AdjustCenterMarker:GetID())
		self.AdjustCenterMarker = nil
	end

	-- 切换地图后加上gc，避免内存持续增长
	_G.ObjectMgr:CollectGarbage(false)
end

---更新所有地图标记
---目前主要用于一二级地图标记的追踪状态变更后图标要重新排版显示，而三级地图标记不涉及排版，仅更新对应标记即可
function WorldMapContentView:OnGameEventWorldMapUpdateAllMarker()
	MapUtil.ResetRegionIconUIPosList()
	MapUtil.ResetWorldUIPosList()

	self:CreateAllMarkers(WorldMapMgr:GetUIMapID(), WorldMapMgr:GetMapID())
end

function WorldMapContentView:HideFirsetWorldMap()
	if self.WorldMap then
		self.PanelMap:RemoveChild(self.WorldMap)
		UIViewMgr:RecycleView(self.WorldMap)
		self.WorldMap = nil

		-- 打开过一级地图，关闭时加上gc
		_G.ObjectMgr:CollectGarbage(false)
	end
end

---一级地图改成动态加载，游戏内很多情况打开地图并不会查看一级地图，节省内存
function WorldMapContentView:ShowFirstWorldMap()
	if self.WorldMap == nil then
		local BPName = 'Map/WorldMapNew_UIBP'
		local MapView = UIViewMgr:CreateViewByName(BPName, ObjectGCType.NoCache, self, true, true, nil)
		self.PanelMap:AddChildToCanvas(MapView)
		self.WorldMap = MapView

		local Anchor = _G.UE.FAnchors()
		Anchor.Minimum = _G.UE.FVector2D(0.5, 0.5)
		Anchor.Maximum = _G.UE.FVector2D(0.5, 0.5)
		UIUtil.CanvasSlotSetAnchors(MapView, Anchor)
		UIUtil.CanvasSlotSetPosition(MapView, _G.UE.FVector2D(0, 0))
		UIUtil.CanvasSlotSetAlignment(MapView, _G.UE.FVector2D(0.5, 0.5))
		UIUtil.CanvasSlotSetSize(MapView, FVector2D(MapConstant.MAP_PANEL_WIDTH * 2, MapConstant.MAP_PANEL_HEIGHT * 2))
		UIUtil.CanvasSlotSetZOrder(MapView, 20)
	end
end

function WorldMapContentView:ShowGoldSaucerMap()
	if self.GoldSaucerMap == nil then
		local BPName = 'Map/MapContentGoldSaucerPanel_UIBP'
		local MapView = UIViewMgr:CreateViewByName(BPName, ObjectGCType.NoCache, self, true, true, nil)
		self.PanelMap:AddChildToCanvas(MapView)
		self.GoldSaucerMap = MapView

		local Anchor = _G.UE.FAnchors()
		Anchor.Minimum = _G.UE.FVector2D(0.5, 0.5)
		Anchor.Maximum = _G.UE.FVector2D(0.5, 0.5)
		UIUtil.CanvasSlotSetAnchors(MapView, Anchor)
		UIUtil.CanvasSlotSetPosition(MapView, _G.UE.FVector2D(0, 0))
		UIUtil.CanvasSlotSetAlignment(MapView, _G.UE.FVector2D(0.5, 0.5))
		UIUtil.CanvasSlotSetSize(MapView, FVector2D(MapConstant.MAP_PANEL_WIDTH, MapConstant.MAP_PANEL_HEIGHT))
		UIUtil.CanvasSlotSetZOrder(MapView, 20)
	end
end

function WorldMapContentView:HideGoldSaucerMap()
	if self.GoldSaucerMap then
		self.PanelMap:RemoveChild(self.GoldSaucerMap)
		UIViewMgr:RecycleView(self.GoldSaucerMap)
		self.GoldSaucerMap = nil
	end
end

function WorldMapContentView:OnMapChanged()
	local UIMapID = WorldMapMgr:GetUIMapID()

	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		return
	end

	local DefaultScale = Cfg.UIMapDefaultScale
	local LastCfg = MapUICfg:FindCfgByKey(WorldMapMgr:GetLastUIMapID())
	if LastCfg and Cfg.NameUI == LastCfg.NameUI then
		-- 三级地图上下层切换时缩放比例保持不变
		DefaultScale = self.RenderScale.X
	end
	WorldMapVM:SetMapScale(DefaultScale)

	local RenderScale = self.RenderScale
	RenderScale.X = DefaultScale
	RenderScale.Y = DefaultScale

	local X = Cfg.UIMapOffsetX
	local Y = Cfg.UIMapOffsetY
	UIUtil.CanvasSlotSetPosition(self.PanelMarker, FVector2D(X, Y))
	UIUtil.CanvasSlotSetPosition(self.PanelMap, FVector2D(X, Y))
	UIUtil.CanvasSlotSetPosition(self.MovePath_UIBP, FVector2D(X, Y))
	self.PanelMap:SetRenderScale(RenderScale)

	-- 世界地图缩放到最小时，PanelMarker会隐藏，这里重置
	UIUtil.SetIsVisible(self.PanelMarker, true, false)

	local CommGesture = self.CommGesture_UIBP
	CommGesture:SetScale(DefaultScale)
	CommGesture:SetMinRenderScale(Cfg.UIMapMinScale)
	CommGesture:SetMaxRenderScale(Cfg.UIMapMaxScale)
	CommGesture:SetRenderScale(FVector2D(DefaultScale, DefaultScale))
	--CommGesture:SetMoveEnable(not MapUtil.IsWorldMap(UIMapID))
	self.MinScaleTimes = 0
	self.MaxScaleTimes = 0

	-- 金蝶地图额外有一层背景
	if UIMapID == 196 or UIMapID == 197 then
		self:ShowGoldSaucerMap()
	else
		self:HideGoldSaucerMap()
	end

	if MapUtil.IsWorldMap(UIMapID) then
		self:ShowFirstWorldMap()
		UIUtil.SetIsVisible(self.ImgMap, false)
		if self.WorldMap then
			UIUtil.SetIsVisible(self.WorldMap, true)
		end
		UIUtil.CanvasSlotSetSize(self.PanelMarker, FVector2D(MapConstant.MAP_PANEL_WIDTH * 2, MapConstant.MAP_PANEL_HEIGHT * 2))

		local ViewportSize = UIUtil.GetViewportSize()
		local Scale = UIUtil.GetViewportScale()
		local ViewportX = ViewportSize.X / Scale
		local ViewportY = ViewportSize.Y / Scale
		local WorldMapWidth = 4096
		local WorldMapHeight = 1654
		local MinScaleWidth = ViewportX / WorldMapWidth
		local MinScaleHeight = ViewportY / WorldMapHeight
		local UIMapMinScale = math.max(MinScaleWidth, MinScaleHeight)

		-- 世界地图宽度是4096高度1654，以高度填充整个视口为最小缩放值
		if UIMapMinScale == MinScaleWidth then
			CommGesture:SetMinRenderScale(UIMapMinScale, true, nil)
		else
			CommGesture:SetMinRenderScale(UIMapMinScale, nil, true)
		end

		FLOG_INFO("[WorldMapContentView:OnMapChanged] ViewportSize=%f %f, ViewportX=%f, ViewportY=%f, GetViewportScale=%f, MinScaleWidth=%f, MinScaleHeight=%f, UIMapMinScale=%f"
			, ViewportSize.X, ViewportSize.Y, ViewportX, ViewportY, Scale, MinScaleWidth, MinScaleHeight, UIMapMinScale)
		CommGesture:SetTargetSize(WorldMapWidth, WorldMapHeight)
		-- 世界地图默认显示位置：聚焦左下角，Y方向往下一段距离
		local TargetHalfWidth = WorldMapWidth * 0.5 * DefaultScale
		local TargetHalfHeight = WorldMapHeight * 0.5 * DefaultScale
		local PosX = TargetHalfWidth - ViewportX / 2
		local PosY = ViewportY / 2 - TargetHalfHeight + 120
		CommGesture:SetOffset(PosX, PosY)
		self:OnPositionChanged(PosX, PosY)
		CommGesture:AdjustOffset()

	else
		UIUtil.SetIsVisible(self.ImgMap, true)
		if self.WorldMap then
			UIUtil.SetIsVisible(self.WorldMap, false)
		end
		UIUtil.CanvasSlotSetSize(self.PanelMarker, FVector2D(MapConstant.MAP_PANEL_WIDTH, MapConstant.MAP_PANEL_HEIGHT))

		CommGesture:SetTargetSize(TargetSizeX, TargetSizeY)
		CommGesture:SetOffset(X, Y)
		self:OnPositionChanged(X, Y)
		CommGesture:AdjustOffset()

		self:UpdateAutoPathLine()
	end

	WorldMapVM:SetPlacedMarkerVisible(false)
	WorldMapVM:HideRelatedTipsPanel()
	self.HasTriggerChangeClosestRegionMap = false
end

function WorldMapContentView:OnScaleChanged()
	local RenderScale = self.RenderScale
	local Scale = RenderScale.X

	self.PanelMap:SetRenderScale(RenderScale)

	local CommGesture = self.CommGesture_UIBP
	local LastScale = CommGesture.Scale
	CommGesture:SetScale(Scale)
	CommGesture:SetRenderScale(FVector2D(RenderScale.X, RenderScale.Y))

	local UIMapID = WorldMapMgr:GetUIMapID()
	if MapUtil.IsWorldMap(UIMapID) then
		-- 世界地图希望以屏幕中心（当前查看位置）作为缩放点，不是以地图中心作为缩放点
		local PosX = CommGesture.OffsetX * Scale / LastScale
		local PosY = CommGesture.OffsetY * Scale / LastScale
		--print("[WorldMapContentView:OnScaleChanged] OffsetX, OffsetY, PosX, PosY, Scale, LastScale", CommGesture.OffsetX, CommGesture.OffsetY, PosX, PosY, Scale, LastScale)
		CommGesture:SetOffset(PosX, PosY)
		self:OnPositionChanged(PosX, PosY)

		-- 世界地图缩放到最小时，图标全部隐藏，主城建筑图不做隐藏
		if Scale <= CommGesture:GetMinRenderScale() or CommonUtil.FloatIsEqual(Scale, CommGesture:GetMinRenderScale(), 0.001) then
			UIUtil.SetIsVisible(self.PanelMarker, false, nil, true)
			self.WorldMap:ShowCityInfo(false)
		else
			UIUtil.SetIsVisible(self.PanelMarker, true, false)
			self.WorldMap:ShowCityInfo(true)
		end
	end

	-- 打开地图时会播放动画，动画AnimFogCleanIn会触发Scale变更，导致标记位置居中后又被重置，流程复杂先不改
	CommGesture:AdjustOffset()

	do
		local _ <close> = CommonUtil.MakeProfileTag(("WorldMapContentView_OnScaleChanged"))
		for _, v in pairs(self.MarkerInfos) do
			v.ViewModel:OnScaleChanged(Scale)
			v.View:OnScaleChanged(Scale)
		end
	end

	self:UpdatePlacedMarkerPos()

	if WorldMapVM.MapScaleByGesture then
		self:ChangeMapByScale()
	end

	self:UpdateAutoPathLine()

	if WorldMapMgr.bShowDebugInfo then
		FLOG_INFO("[WorldMapContentView:OnScaleChanged] Scale=%f", Scale)
	end
end

-- 缩放地图时按一定规则切换地图
function WorldMapContentView:ChangeMapByScale()
	if _G.PWorldMgr:CurrIsInDungeon() then
		return
	end

	local Scale = self.RenderScale.X
	local MinScale = self.CommGesture_UIBP.MinRenderScale
	local MaxScale = self.CommGesture_UIBP.MaxRenderScale

	if MapUtil.IsRegionMap(WorldMapMgr:GetUIMapID()) then
		if Scale <= MinScale then
			-- 交互要求：首次缩放到最小边界时不立即切换地图，再次缩放时才切换
			self.MinScaleTimes = self.MinScaleTimes + 1
			if self.MinScaleTimes == 10 then
				WorldMapMgr:ChangeMap(WorldMapMgr:GetUpperUIMapID())
			end
		elseif Scale >= MaxScale then
			self.MaxScaleTimes = self.MaxScaleTimes + 1
			--print("ChangeMapByScale MaxScaleTimes", self.MaxScaleTimes, Scale)
			if self.MaxScaleTimes == 10 then
				self:ChangeClosestRegionMap()
			end
		else
			self.MinScaleTimes = 0
			self.MaxScaleTimes = 0
		end
	elseif MapUtil.IsAreaMap(WorldMapMgr:GetUIMapID()) then
		if Scale <= MinScale then
			self.MinScaleTimes = self.MinScaleTimes + 1
			--print("ChangeMapByScale MinScaleTimes", self.MinScaleTimes, Scale)
			if self.MinScaleTimes == 10 then
				WorldMapMgr:ChangeMap(WorldMapMgr:GetUpperUIMapID())
			end
		else
			self.MinScaleTimes = 0
		end
	elseif MapUtil.IsWorldMap(WorldMapMgr:GetUIMapID()) then
		-- nothing
	end
end

function WorldMapContentView:OnPositionChanged(X, Y)
	local Position = FVector2D(X, Y)

	UIUtil.CanvasSlotSetPosition(self.PanelMap, Position)
	UIUtil.CanvasSlotSetPosition(self.PanelMarker, Position)
	UIUtil.CanvasSlotSetPosition(self.MovePath_UIBP, Position)

	if WorldMapMgr.bShowDebugInfo then
		FLOG_INFO("[WorldMapContentView] OnPositionChanged OffsetX=%f OffsetY=%f", X, Y)
	end
end

-- 标记动画，点击标记时，上一个标记还原，当前标记放大
-- 目前未使用了，标记蓝图会复用，导致一些显示问题
function WorldMapContentView:CheckMarkAnim(MapMarkers)
	if self.LastCheckMark ~= nil and self.MarkerInfos[self.LastCheckMark] ~= nil then
		local LastCheckMarkView = self.MarkerInfos[self.LastCheckMark].View
		if LastCheckMarkView ~= nil and LastCheckMarkView.AnimScaleOut ~= nil then
			LastCheckMarkView:PlayAnimation(LastCheckMarkView.AnimScaleOut)
		end
	end
	self.LastCheckMark = nil

	if nil == MapMarkers then
		return
	end

	if 1 == #MapMarkers then
		local CheckMark = MapMarkers[1]
		if CheckMark ~= nil and self.MarkerInfos[CheckMark] ~= nil then
			local CheckMarkView = self.MarkerInfos[CheckMark].View
			if CheckMarkView ~= nil and CheckMarkView.AnimScaleIn ~= nil then
				CheckMarkView:PlayAnimation(CheckMarkView.AnimScaleIn)
				self.LastCheckMark = CheckMark
			end
		end
	end
end

function WorldMapContentView:OnClickedMakers(MapMarkers, RegionMarkers, ScreenPosition)
	if self.SendLoctionMode and MapUtil.IsAreaMap(WorldMapMgr:GetUIMapID()) then
		self:SendLoctionModeClicked(ScreenPosition)
		return
	end

	--self:CheckMarkAnim(MapMarkers)
	if nil == MapMarkers then
		return
	end

	local Count = #MapMarkers
	if Count <= 0 then
		if not self.DerivativeWindowHide then
			if MapUtil.IsAreaMap(WorldMapMgr:GetUIMapID()) then
				if not MapUtil.CheckScreenPositionInSafeArea(ScreenPosition) then
					return
				end

				local LocalPosition = UIUtil.AbsoluteToLocal(self.ImgMap, ScreenPosition)
				self.PlacedMarkerPos = LocalPosition
				WorldMapMgr:SetPlacedMarkerPos(LocalPosition)
				-- 点击一次空白区域只是显示新标记点，再点击一次标记点才显示标记界面
				WorldMapVM:SetPlacedMarkerVisible(true)
				-- 【交互体验优化】标记界面显示的情况下，点击一次空白区域就要刷新标记界面
				if WorldMapVM.MapSetMarkPanelVisible then
					WorldMapVM:ShowWorldMapPlaceMarkerPanel(nil)
				end
				self:UpdatePlacedMarkerPos()

			elseif MapUtil.IsRegionMap(WorldMapMgr:GetUIMapID()) then
				if #RegionMarkers > 0 then
					-- 考虑Region的响应区域有重叠，优先响应配置为Link的Region，一般是主城
					table.sort(RegionMarkers, function(A, B)
						if A:IsLink() and not B:IsLink() then
							return true
						end
						if not A:IsLink() and B:IsLink() then
							return false
						end
						return A.ID < B.ID
					end)

					self:OnClickedRegionMarker(RegionMarkers[1])
				end
			end
		end
		self.DerivativeWindowHide = false
	else
		WorldMapVM:SetPlacedMarkerVisible(false)
		WorldMapVM:SetMapSetMarkPanelVisible(false)
		self.Super:OnClickedMakers(MapMarkers, RegionMarkers, ScreenPosition)
	end
end


---点击二级地图
function WorldMapContentView:OnClickedRegionMarker(RegionMarker)
	if nil == RegionMarker then
		return
	end
	local Info = self.MarkerInfos[RegionMarker]
	if nil == Info then
		return
	end

	local RegionViewList = {}
	for k, v in pairs(self.MarkerInfos) do
		local MapMarker = k
		if MapUtil.IsRegionMarkerBPType(MapMarker:GetBPType())
			and RegionMarker.Name == MapMarker.Name then
			local RegionView = v.View
			table.insert(RegionViewList, RegionView)
		end
	end
	for i = 1, #RegionViewList do
		RegionViewList[i]:PlayClickAnim()
	end

	local MapMarkerRegionView = Info.View
	--MapMarkerRegionView:PlayClickAnim()

	local ViewportSize = UIUtil.GetViewportSize()
	local Scale = UIUtil.GetViewportScale()
	local ViewportX = ViewportSize.X / Scale
	local ViewportY = ViewportSize.Y / Scale
	local ScreenCenterPosition = FVector2D(ViewportX/2, ViewportY/2)

	local ViewPosition = UIUtil.LocalToViewport(MapMarkerRegionView, FVector2D(0,0))
	local DeltaPostion = ScreenCenterPosition - ViewPosition
	if math.abs(DeltaPostion.X) > 200 or math.abs(DeltaPostion.Y) > 200 then
		-- 当前所点目标地图region位于屏幕边缘时，向屏幕中心区域位移
		-- 直接切地图，因为有出场动画。之前效果是先移动再切地图
		-- 要判断地图是否切换成功，避免不可切换时也移动地图
		if WorldMapMgr:ChangeMap(RegionMarker.TargetUIMapID) then
			self:MoveMapByOffect(DeltaPostion)
		end
	else
		-- 当前所点目标地图region正好位于屏幕中心区域
		WorldMapMgr:ChangeMap(RegionMarker.TargetUIMapID)
	end
end

---移动地图一定偏移
---@param DeltaPostion FVector2D 偏移量
---@param MoveFinishCallback function 移动时回调
function WorldMapContentView:MoveMapByOffect(DeltaPostion, MoveFinishCallback)
	local Interval = 0.05
	local MoveTime = 0.5
	self.CurrentValue = FVector2D(0,0)
	self:SetAllowClick(false) -- 移动地图时禁止点击

	self.TimerID = self:RegisterTimer(function(_, _, ElapsedTime)
		local Curve = self.CurveMove
		local MovePercent = math.clamp(ElapsedTime / MoveTime, 0, 1)
		local CurveFloatValue
		if Curve then
			CurveFloatValue = Curve:GetFloatValue(MovePercent)
		else
			CurveFloatValue = MovePercent
		end
		local NewValue = DeltaPostion * CurveFloatValue
		local DeltaValue = NewValue - self.CurrentValue
		--print("MovePercent", MovePercent)
		local IsMoveFinish = MovePercent >= 1

		if math.abs(DeltaValue.X) < 5 and math.abs(DeltaValue.Y) < 5 then
			if MoveFinishCallback then
				MoveFinishCallback(NewValue, IsMoveFinish)
			end
			self:SetAllowClick(true)
			return
		end
		self.CurrentValue = NewValue
		self.CommGesture_UIBP:OnMoved(DeltaValue)

		if MoveFinishCallback then
			MoveFinishCallback(NewValue, IsMoveFinish)
		end
	end, 0, Interval, math.ceil(MoveTime / Interval) + 1)
end

-- 通过缩放从二级地图进入三级地图
function WorldMapContentView:ChangeClosestRegionMap()
	local ViewportSize = UIUtil.GetViewportSize()
	local Scale = UIUtil.GetViewportScale()
	local ViewportX = ViewportSize.X / Scale
	local ViewportY = ViewportSize.Y / Scale
	local ScreenCenterPosition = FVector2D(ViewportX/2, ViewportY/2)

	local ClosestDistance = math.huge
	local ClosestRegionMarker

	-- 查找满足条件的离屏幕中心最近的地图Region，参考点击时的条件判断
	for k, v in pairs(self.MarkerInfos) do
		local MapMarker = k
		if MapUtil.IsRegionMarkerBPType(MapMarker:GetBPType()) then
			local MapMarkerRegionView = v.View
			if v.ViewModel:GetIsMarkerVisible() and MapMarker:GetIsEnableHitTest() then
				local ViewPosition = UIUtil.LocalToViewport(MapMarkerRegionView, FVector2D(0,0))
				local dis = _G.UE.UKismetMathLibrary.Distance2D(ViewPosition, ScreenCenterPosition)
				if dis < ClosestDistance then
					ClosestDistance = dis
					ClosestRegionMarker = MapMarker
				end
			end
		end
	end

	if ClosestDistance > 500 then
		-- 可进入的地图Region位置距离放大中心区域较远
		return
	end
	if ClosestRegionMarker and not self.HasTriggerChangeClosestRegionMap then
		self.HasTriggerChangeClosestRegionMap = true -- 避免滑动条缩放时多次触发，从而多次位移动画导致抖动
		self:OnClickedRegionMarker(ClosestRegionMarker)
	end
end

function WorldMapContentView:UpdatePlacedMarkerPos()
	local PlacedMarkerPos = self.PlacedMarkerPos
	if nil ~= PlacedMarkerPos then
		local Scale = self.RenderScale.X
		local X, Y = MapUtil.AdjustMapMarkerPosition(Scale, PlacedMarkerPos.X, PlacedMarkerPos.Y)
		UIUtil.CanvasSlotSetPosition(self.MapPlacedMarker, FVector2D(X, Y))
	end
end


function WorldMapContentView:OnKeyDown(Geometry, KeyEvent)
    local inputEvent = _G.UE.UWidgetBlueprintLibrary.GetInputEventFromKeyEvent(KeyEvent)
    if _G.UE.UKismetInputLibrary.InputEvent_IsControlDown(inputEvent)  then
		self.IsControlDown = true
	end
    return _G.UE.UWidgetBlueprintLibrary.Handled()
end

function WorldMapContentView:OnKeyUp(Geometry, KeyEvent)
	self.IsControlDown = false
end

-- 按住Ctrl键点击主角所在当前UI地图，可以GM传送
function WorldMapContentView:WorldMapClickedMap(ScreenPosition)
	if MapUtil.IsAreaMap(WorldMapMgr:GetUIMapID()) and self.IsControlDown and WorldMapMgr:GetUIMapID() == MapMgr:GetUIMapID() then
		local MapInfo = MapMgr.MapInfo
		local LocalPosition = UIUtil.AbsoluteToLocal(self.ImgMap, ScreenPosition)
		local TargetX, TargetY = MapUtil.ConvertUIPos2Map(LocalPosition.X , LocalPosition.Y , MapInfo.MapOffsetX, MapInfo.MapOffsetY, MapInfo.MapScale, true )
		WorldMapMgr:SendGMTransfer(TargetX, TargetY)
		self.IsControlDown = false
	end
end


---@overload
function WorldMapContentView:IsSpecialMarkerNeedImmediateCreate(MarkerType, MarkerID)
	local Params = self.Params
	if Params and Params.MarkerType and Params.MarkerID
		and Params.MarkerType == MarkerType and Params.MarkerID == MarkerID then
		--- 显示指定标记时，该标记需要立即创建，不能分帧创建
		return true
	end

	return false
end

---显示指定标记
---打开地图时，通过附带的参数MarkerType和MarkerID来判断
function WorldMapContentView:AdjustMarker2CenterPos_Common()
	local Params = self.Params
	if Params and Params.MarkerType and Params.MarkerID then
		local DefaultClick = true
		if Params.MarkerType == MapMarkerType.WorldMapGather and _G.GatheringLogMgr:GetCurProfbLock() then
			DefaultClick = false
		end
		self:AdjustMarker2CenterPos(Params.MarkerType, Params.MarkerID, DefaultClick, Params.MarkerSubType, Params.SubID)
	end
end

---给定标记居中显示
---@param MarkerType number 标记类型
---@param MarkerID number 标记ID
---@param DefaultClick boolean 默认是否点击标记以弹出标记tips
---@param MarkerSubType number 标记子类型
---@param SubID number 子ID
function WorldMapContentView:AdjustMarker2CenterPos(MarkerType, MarkerID, DefaultClick, MarkerSubType, SubID)
	local MarkerSubType = MarkerSubType or 0
	local MarkerView, Marker = self:GetMapMarkerByTypeAndID(MarkerType, MarkerID, MarkerSubType, SubID)
	if MarkerView == nil or Marker == nil then
		return
	end

	self:AdjustMarkerView2CenterPos(MarkerView)

	if DefaultClick then
		self:ShowMarkerTips(Marker, MarkerView)
	end
end

---给定标记居中显示
---标记居中显示位置计算不需要等动画结束，但标记tips显示位置需要等地图缩放动画结束
---@param MarkerView 标记View
function WorldMapContentView:AdjustMarkerView2CenterPos(MarkerView)
	if MarkerView == nil then
		return
	end

	local MarkerSlotPos = UIUtil.CanvasSlotGetPosition(MarkerView)
	local ParentViewSize = UIUtil.CanvasSlotGetSize(self.PanelMarker)
	local Pos = -MarkerSlotPos + ParentViewSize / 2
	self.CommGesture_UIBP:SetOffset(0, 0)
	self.CommGesture_UIBP:OnMoved(Pos)
end

-- 如OnShow参数有传入初始标记位置，直接根据位置显示标记
function WorldMapContentView:ShowMarkerFromInitPos()
	local Params = self.Params
	if Params ~= nil and Params.MarkerInitPos ~= nil then
		WorldMapVM:ShowWorldMapPlaceMarkerPanel(nil)
		local LocalPosition = UIUtil.AbsoluteToLocal(self.ImgMap, Params.MarkerInitPos)
		self.PlacedMarkerPos = LocalPosition
		WorldMapMgr:SetPlacedMarkerPos(LocalPosition)
		WorldMapVM:SetPlacedMarkerVisible(true)
		self:UpdatePlacedMarkerPos()
		self:AdjustMarkerView2CenterPos(self.MapPlacedMarker)
	end
end

-- 显示任务追踪信息
function WorldMapContentView:ShowQuestTrackInfo()
	local Params = self.Params
	if Params and Params.TrackQuestID then
		local TrackingParamList = _G.QuestTrackMgr:GetTrackingQuestParam()
		if TrackingParamList then
			local TargetNaviItem = nil
			if Params.TrackTargetID then
				for _, Param in ipairs(TrackingParamList) do
					if Param.QuestID == Params.TrackQuestID and Param.TargetID == Params.TrackTargetID then
						TargetNaviItem = Param
						break
					end
				end
			else
				if #TrackingParamList > 0 then
					TargetNaviItem = TrackingParamList[1]
				end
			end
			if TargetNaviItem and TargetNaviItem.Pos then
				-- 不能用任务坐标转换UI坐标，因为任务存在地图映射的问题，改用任务标记的UI坐标
				--local UIPosX, UIPosY = MapUtil.GetUIPosByLocation(NaviItem.Pos, WorldMapMgr:GetUIMapID())
				local _, Marker = self:GetMapMarkerQuest(TargetNaviItem.QuestID, TargetNaviItem.TargetID)
				if Marker == nil then
					 return
				end
				local UIPosX, UIPosY = Marker:GetAreaMapPos()
				local TargetUIPos = FVector2D(UIPosX, UIPosY)
				self:ShowClosestCrystal(TargetUIPos, Marker)
				_G.EventMgr:SendEvent(EventID.MapMarkerPlayAnimation, Params.TrackQuestID)
			end
		end
	end
end

-- 显示寻宝最近水晶传送
function WorldMapContentView:ShowTreasureHuntCrystal(MapData)
	if MapData == nil then
		MapData = self.Params and self.Params.TreasureHuntMapData
	end
	if MapData == nil then return end

	local UIMapID = MapUtil.GetUIMapID(MapData.MapResID)
	local UIPosX,UIPosY = MapUtil.GetUIPosByLocation(MapData.Pos, UIMapID)
	local TargetUIPos = _G.UE.FVector2D(UIPosX, UIPosY)
	self:ShowClosestCrystal(TargetUIPos, nil)
end

-- 显示地图追踪信息
function WorldMapContentView:OnGameEventMapFollowAdd()
	local FollowInfo = WorldMapMgr:GetMapFollowInfo()
	if FollowInfo == nil or FollowInfo.FollowType == 0 or FollowInfo.FollowID == 0 then
		return
	end

	-- 地图追踪时，如果开了自动寻路，不弹传送水晶tips，避免自动寻路时地图关闭了，延迟显示的水晶tips没关闭
	if (WorldMapMgr:IsOpenAutoPath(FollowInfo.FollowMapID)) then
		return
	end

	local MarkerView, Marker = self:GetMapMarkerByTypeAndID(FollowInfo.FollowType, FollowInfo.FollowID, FollowInfo.FollowSubType)
	if MarkerView == nil or Marker == nil then
		return
	end

	local UIPosX, UIPosY = Marker:GetAreaMapPos()
	local TargetUIPos = FVector2D(UIPosX, UIPosY)
	self:ShowClosestCrystal(TargetUIPos, Marker)
end

-- 地图自动寻路路线
function WorldMapContentView:UpdateAutoPathLine()
	if WorldMapMgr:IsMapAutoPathMoving() then
		local UIPoints = WorldMapMgr:GetUIMovePointList(WorldMapMgr:GetUIMapID(), self.RenderScale.X)
		self.MovePath_UIBP:DrawLine(UIPoints)
		self.MovePath_UIBP:UpdateProgress()
	elseif _G.ChocoboTransportMgr:GetIsTransporting() then
		local UIPoints = _G.ChocoboTransportMgr:GetUIMovePointList(WorldMapMgr:GetUIMapID(), self.RenderScale.X)
		self.MovePath_UIBP:DrawLine(UIPoints)
		self.MovePath_UIBP:UpdateProgress()
	else
		self.MovePath_UIBP:Clear()
	end
end


function WorldMapContentView:SendLoctionModeClicked(ScreenPosition)
		local LocalPosition = UIUtil.AbsoluteToLocal(self.ImgMap, ScreenPosition)
		self.PlacedMarkerPos = LocalPosition
		WorldMapMgr:SetPlacedMarkerPos(LocalPosition)
		WorldMapVM:SetPlacedMarkerVisible(true)
		self:UpdatePlacedMarkerPos()

		if WorldMapVM.MapSendMarkWinLoctionPanelVisible then
			local SendMarkWinView = UIViewMgr:FindVisibleView(UIViewID.WorldMapSendMarkWin)
			if SendMarkWinView == nil then
				FLOG_ERROR("WorldMapContentView In SendLoctionMode not find SendMarkWinView")
				WorldMapVM:CloseWorldMapPanel()
				return
			end
			SendMarkWinView:SetSelectedPosition(WorldMapMgr:GetUIMapID(), LocalPosition)
			return
		end
		FLOG_ERROR("WorldMapContentView In SendLoctionMode WorldMapVM.MapSendMarkWinLoctionPanelVisible Is false")
		WorldMapVM:CloseWorldMapPanel()
		return
end

function WorldMapContentView:PlayFadeOutMapAnim()
	self:PlayAnimation(self.AnimMapOut)
end

function WorldMapContentView:PlayFadeInMapAnim()
	self:PlayAnimation(self.AnimMapIn)
end

function WorldMapContentView:GetFadeOutMapAnimTime()
	if self.AnimMapOut ~= nil then
		return self.AnimMapOut:GetEndTime()
	end
	return 0
end


---聚焦锁定给定标记
---@param MarkerID number 标记ID
---@param IsQuest boolean 是否是任务标记
---@param TargetID number 目标ID，对于任务标记需要TargetID
---@param ZoomIn boolean 是否居中放大
function WorldMapContentView:FocusMarkerByID(MarkerID, IsQuest, TargetID, ZoomIn)
	if (MarkerID or 0) == 0 then
		if self.ShowFocusTimerID then
			self:UnRegisterTimer(self.ShowFocusTimerID)
			self.ShowFocusTimerID = nil
		end
		UIViewMgr:HideView(UIViewID.WorldMapMarkerFocusItem)
		return
	end

	local MarkerView
	if IsQuest then
		MarkerView = self:GetMapMarkerQuest(MarkerID, TargetID)
	else
		MarkerView = self:GetMapMarkerByID(MarkerID)
	end
	if MarkerView == nil then
		return
	end

	local UIMapMaxScale = self.CommGesture_UIBP.MaxRenderScale
	if ZoomIn then
		local RenderScale = self.RenderScale
		RenderScale.X = UIMapMaxScale
		RenderScale.Y = UIMapMaxScale
		WorldMapMgr:OnMapScaleChange(UIMapMaxScale)

		self:AdjustMarkerView2CenterPos(MarkerView)
	end

	self.ShowFocusTimerID = self:RegisterTimer(function ()
		local MarkerPos = UIUtil.GetWidgetPosition(MarkerView)
		local View = UIViewMgr:ShowView(UIViewID.WorldMapMarkerFocusItem)
		View:SetPositionByCenter(MarkerPos)
		self.ShowFocusTimerID = nil
	end, 0.3)
end

function WorldMapContentView:OnGameEventUpdateChocoboTransportPosition()
	local Scale = self.RenderScale.X
	for Marker,Value in pairs(self.MarkerInfos) do
		local MarkerType = Marker:GetType()
		if MarkerType == MapMarkerType.ChocoboAnim or MarkerType == MapMarkerType.Major then
			Value.View:OnScaleChanged(Scale)
		end
	end
	-- 更新移动的进度
	self.MovePath_UIBP:UpdateProgress()
end

function WorldMapContentView:OnGameEventMapAutoPathProgressUpdate()
	-- 更新移动的进度
	self.MovePath_UIBP:UpdateProgress()
end

function WorldMapContentView:OnGameEventChocoboTransportFinish()
	self.MovePath_UIBP:Clear()
end

function WorldMapContentView:OnGameEventMapAutoPathUpdate()
	self:UpdateAutoPathLine()
end

function WorldMapContentView:OnGameEventUpdateQuest(Params)
	if Params.UpdatedRspQuests ~= nil then
		self:UpdateMarkerByOpenFlag()
	end
end

function WorldMapContentView:OnGameEventMapMarkerPriorityUpdate(Params)
	self:UpdateMarkerPriority()
end

function WorldMapContentView:OnGameEventMapMarkerHighlight(Params)
	self:UpdateMarkerHighlightEffect(Params)
end

function WorldMapContentView:OnGameEventMapFollowDelete()
	self:UpdateMarkerExtraIcon()
end


local FindClosestCrystalFailReason =
{
	NoActive = 1, -- 水晶未激活
	NoCrystal = 2, -- 水晶不存在
}

---显示距离给定UI坐标最近的传送水晶（非场景可行走路线最近）
---@param TargetUIPos FVector2D 目标UI坐标
---@param TargetMarker Marker 目标标记
function WorldMapContentView:ShowClosestCrystal(TargetUIPos, TargetMarker)
	local MajorUIMapID = MapMgr:GetUIMapID() -- 主角所在UIMapID
	local TargetUIMapID = WorldMapMgr:GetUIMapID() -- 目标所在UIMapID

	-- 判断主角所在UIMapID等于目标UIMapID，也查找最近的水晶，但是查找不到不会显示二级地图
	if MajorUIMapID == TargetUIMapID then
		self:FindClosestCrystal(TargetUIPos, MapUtil.IsMapCrystalByMarkerCfg, true)
		return
	end

	-- 找目标UI地图里最近的已激活水晶
	local FindResult, FailReason = self:FindClosestCrystal(TargetUIPos, MapUtil.IsMapCrystalByMarkerCfg)
	if FindResult then
		-- 找到了满足条件的水晶
	else
		if FailReason == FindClosestCrystalFailReason.NoActive then
			-- 找不到满足条件的水晶，切换到目标所在UIMapID的二级地图，同时让目标标记尽量居中显示
			-- 只处理任务类型，因为追踪的任务会显示在二级地图，其他标记类型很多不会显示在二级地图
			if TargetMarker and TargetMarker:GetType() == MapMarkerType.Quest then
				self.AdjustCenterMarker = TargetMarker
				local RegionUIMapID = MapUtil.GetUpperUIMapID(TargetUIMapID)
				WorldMapMgr:ChangeMap(RegionUIMapID, nil, self.IsOpenMapShow)
			end
			_G.MsgTipsUtil.ShowTips(_G.LSTR(700012)) -- "该地图水晶未激活，请自行前往"
		end
	end
end

---老的传送水晶逻辑
---@deprecated
function WorldMapContentView:ShowClosestCrystalOld(TargetUIPos, TargetMarker)
	local MajorUIMapID = MapMgr:GetUIMapID() -- 主角所在UIMapID
	local TargetUIMapID = WorldMapMgr:GetUIMapID() -- 目标所在UIMapID

	-- 判断主角所在UIMapID等于目标UIMapID，此时不提示
	if MajorUIMapID == TargetUIMapID then
		return
	end

	-- 判断主角所在UIMapID和目标所在的UIMapID是否在同一个主城，此时找目标UI地图里最近的已激活水晶
	if MapUtil.GetMapNameUI(MajorUIMapID) == MapUtil.GetMapNameUI(TargetUIMapID) then
		self:FindClosestCrystal(TargetUIPos, MapUtil.IsMapCrystalByMarkerCfg)
		return
	end

	-- 有传送大水晶，找目标UI地图里最近的已激活大水晶
	if MapUtil.MapHasAcrossMapCrystal(TargetUIMapID) then
		if self:FindClosestCrystal(TargetUIPos, MapUtil.IsAcrossMapCrystalByMarkerCfg) then
			-- 找到了满足条件的大水晶
		else
			-- 找不到满足条件的大水晶，切换到目标所在UIMapID的二级地图，同时让目标标记尽量居中显示
			-- 只处理任务类型，因为追踪的任务会显示在二级地图，其他标记类型很多不会显示在二级地图
			if TargetMarker and TargetMarker:GetType() == MapMarkerType.Quest then
				self.AdjustCenterMarker = TargetMarker
				local RegionUIMapID = MapUtil.GetUpperUIMapID(TargetUIMapID)
				WorldMapMgr:ChangeMap(RegionUIMapID, nil, self.IsOpenMapShow)
			end
			_G.MsgTipsUtil.ShowTips(_G.LSTR(700012)) -- "该地图水晶未激活，请自行前往"
		end
		return
	end

	-- 只有传送小水晶，判断主角所在UIMapID是否是目标所在的大主城
	if MapUtil.MapHasOnlyCurrentMapCrystal(TargetUIMapID) then
		for SmallCityUIMapID, BigCityUIMapID in pairs(MapDefine.MapBigSmallCityConfigs) do
			if SmallCityUIMapID == TargetUIMapID then
				if BigCityUIMapID == MajorUIMapID then
					-- 找目标UI地图里最近的已激活小水晶
					self:FindClosestCrystal(TargetUIPos, MapUtil.IsCurrentMapCrystalByMarkerCfg)
				else
					-- 将大主城的大水晶标记点追加到当前小主城UI地图
					if self:AddAcrossMapCrystalMarker(SmallCityUIMapID, BigCityUIMapID) then
						-- 追加成功
					else
						-- 追加失败，一般是大主城的大水晶没有激活
						self.AdjustCenterMarker = TargetMarker
						local RegionUIMapID = MapUtil.GetUpperUIMapID(TargetUIMapID)
						WorldMapMgr:ChangeMap(RegionUIMapID, nil, self.IsOpenMapShow)
					end
				end
			end
		end
	end
end

---找目标UI地图里指定坐标最近的已激活水晶
---@param TargetUIPos FVector2D 目标UI坐标
---@param CrystalTypePredicate function 查找满足条件的水晶
---@param IsSameMap boolean 是否当前地图
---@return boolean, number 是否找到满足条件的水晶，没找到时的失败原因
function WorldMapContentView:FindClosestCrystal(TargetUIPos, CrystalTypePredicate, IsSameMap)
	local ClosestDistance = math.huge
	local ClosestMapMarker
	local ClosestMapView

	-- 如果玩家位置离目标点更近，不弹出传送tips
	if IsSameMap then
		for Marker,_ in pairs(self.MarkerInfos) do
			local MarkerType = Marker:GetType()
			if MarkerType == MapMarkerType.Major then
				local UIPosX, UIPosY = Marker:GetAreaMapPos()
				ClosestDistance = _G.UE.UKismetMathLibrary.Distance2D(TargetUIPos, FVector2D(UIPosX, UIPosY))
				break
			end
		end
	end

	-- 先判断是否存在水晶
	local HasCrystal = false
	for k, v in pairs(self.MarkerInfos) do
		local Marker = k
		if Marker:GetType() == MapMarkerType.FixPoint
			and CrystalTypePredicate(Marker:GetMarkerCfg()) then
			HasCrystal = true
			break
		end
	end
	if not HasCrystal then
		FLOG_INFO("[WorldMapContentView FindClosestCrystal] can not find crystal")
		return false, FindClosestCrystalFailReason.NoCrystal
	end

	-- 再判断水晶是否激活
	for k, v in pairs(self.MarkerInfos) do
		local Marker = k
		if Marker:GetType() == MapMarkerType.FixPoint
			and Marker:GetIsActive()
			and CrystalTypePredicate(Marker:GetMarkerCfg()) then
			local UIPosX, UIPosY = Marker:GetAreaMapPos()
			local dis = _G.UE.UKismetMathLibrary.Distance2D(TargetUIPos, FVector2D(UIPosX, UIPosY))
			if dis < ClosestDistance then
				ClosestDistance = dis
				ClosestMapMarker = Marker
				ClosestMapView = v.View
			end
		end
	end

	-- 找到满足条件的水晶，如果水晶在屏幕外则居中显示，然后弹tips
	if ClosestMapMarker and ClosestMapView then
		if not MapUtil.CheckViewInScreenArea(ClosestMapView) then
			self:AdjustMarkerView2CenterPos(ClosestMapView)
		end
		self:ShowCrystalTips(ClosestMapMarker, ClosestMapView)
		return true, 0
	else
		FLOG_INFO("[WorldMapContentView FindClosestCrystal] can not find active crystal")
		_G.QuestMgr.QuestReport:RecordCrossTask(nil) --清理跨图传送埋点数据
		return false, FindClosestCrystalFailReason.NoActive
	end
end

-- 将大主城的大水晶标记点追加到当前小主城UI地图
function WorldMapContentView:AddAcrossMapCrystalMarker(SmallCityUIMapID, BigCityUIMapID)
	if self.AdditionalMapMarker then
		self:RemoveMarker(self.AdditionalMapMarker)
		self.AdditionalMapMarker = nil
	end

	local HasAcrossMapCrystal, AcrossMapCrystalMarkerCfg = MapUtil.MapHasAcrossMapCrystal(BigCityUIMapID)
	if not HasAcrossMapCrystal then
		FLOG_INFO("[WorldMapContentView AddAcrossMapCrystalMarker] has not across map crystal, BigCityUIMapID=%d", BigCityUIMapID)
		return false
	end
	local MapMarkerFactory = require("Game/Map/MapMarkerFactory")
	local Provider = MapMarkerFactory.CreateMarkerProvider(MapMarkerType.FixPoint)
	Provider.UIMapID = SmallCityUIMapID
	local Marker = Provider:OnCreateMarker(AcrossMapCrystalMarkerCfg)
	if not Marker:GetIsActive() then
		FLOG_INFO("[WorldMapContentView AddAcrossMapCrystalMarker] has not active across map crystal, BigCityUIMapID=%d", BigCityUIMapID)
		return false
	end
	self:CreateMarker(Marker)
	self.AdditionalMapMarker = Marker -- 记录额外追加的地图标记，方便后面移除

	local ClosestMapMarker = Marker
	local Info = self.MarkerInfos[Marker]
	local ClosestMapView = Info.View
	-- 额外追加的大水晶，居中显示，然后弹tips
	if ClosestMapMarker and ClosestMapView then
		self:AdjustMarkerView2CenterPos(ClosestMapView)
		self:ShowCrystalTips(ClosestMapMarker, ClosestMapView)
		return true
	end

	return false
end

function WorldMapContentView:ShowCrystalTips(CrystalMapMarker, CrystalMapMarkerView)
	if CrystalMapMarkerView == nil then
		return
	end

	local DelayShowTipsTime = 0.1
	if self.IsOpenMapShow then
		--DelayShowTipsTime = self.ParentView:GetMapScaleAnimTime()
		self.CacheCrystalMapMarker = CrystalMapMarker
		self.CacheCrystalMapMarkerView = CrystalMapMarkerView
		return
	end

	self:RegisterTimer(function()
		local ScreenPosition = UIUtil.LocalToAbsolute(CrystalMapMarkerView, FVector2D(0,-50))
		local Params = { MapMarker = CrystalMapMarker, ScreenPosition = ScreenPosition, ShowClosest = true, }
		UIViewMgr:ShowView(UIViewID.WorldMapMarkerTipsTransfer, Params)
	end, DelayShowTipsTime)
end

function WorldMapContentView:ShowMarkerTips(MapMarker, MapMarkerView)
	if MapMarkerView == nil then
		return
	end

	local DelayShowTipsTime = 0.1
	if self.IsOpenMapShow then
		--DelayShowTipsTime = self.ParentView:GetMapScaleAnimTime()
		self.CacheMapMarker = MapMarker
		self.CacheMapMarkerView = MapMarkerView
		return
	end

	self:RegisterTimer(function()
		local ScreenPosition = UIUtil.LocalToAbsolute(MapMarkerView, FVector2D(0,-50))
		local EventParams = { ScreenPosition = ScreenPosition }
		MapMarker:OnTriggerMapEvent(EventParams)
	end, DelayShowTipsTime)
end

---地图缩放动画结束后才显示标记tips
---地图主界面打开时会播放动画缩放地图，从而影响地图标记的位置计算
function WorldMapContentView:OnPlayAnimMapScaleFinish()
	if self.CacheCrystalMapMarker and self.CacheCrystalMapMarkerView then
		self:ShowCrystalTips(self.CacheCrystalMapMarker, self.CacheCrystalMapMarkerView)
		self.CacheCrystalMapMarker = nil
		self.CacheCrystalMapMarkerView = nil
	end

	if self.CacheMapMarker and self.CacheMapMarkerView then
		self:ShowMarkerTips(self.CacheMapMarker, self.CacheMapMarkerView)
		self.CacheMapMarker = nil
		self.CacheMapMarkerView = nil
	end
end

---打开地图时显示指定标记
function WorldMapContentView:OpenMapShowMarker()
	self.IsOpenMapShow = true -- 是否打开地图显示指定标记
	self:ShowMarkerFromInitPos()
	self:ShowQuestTrackInfo()
	self:ShowTreasureHuntCrystal()
	self:AdjustMarker2CenterPos_Common()
	self.IsOpenMapShow = false
end

return WorldMapContentView
