---
--- Author: sammrli
--- DateTime: 2024-02-26 10:12
--- Description:运输陆行鸟地图
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local MapUtil = require("Game/Map/MapUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetMaterialTextureFromAssetPath = require("Binder/UIBinderSetMaterialTextureFromAssetPath")
local UIBinderSetMaterialScalarParameterValue = require("Binder/UIBinderSetMaterialScalarParameterValue")

local MapContentView = require("Game/Map/View/MapContentView")

local EventID = require("Define/EventID")
local MapVM = require("Game/Map/VM/MapVM")
local UIViewID = require("Define/UIViewID")
local MapDefine = require("Game/Map/MapDefine")
local ChocoboTransportDefine = require ("Game/Chocobo/Transport/ChocoboTransportDefine")

local MapUICfg = require("TableCfg/MapUICfg")
local ProtoRes = require("Protocol/ProtoRes")

local TimerMgr = require("Timer/TimerMgr")

local MapMarkerType = MapDefine.MapMarkerType
local MapContentType = MapDefine.MapContentType
local MapMarkerEventType = ProtoRes.MapMarkerEventType

local UE = _G.UE
local LSTR = _G.LSTR
local WorldMapMgr = _G.WorldMapMgr
local MapMarkerMgr = _G.MapMarkerMgr
local ChocoboTransportMgr = _G.ChocoboTransportMgr
local FVector2D = UE.FVector2D

local TargetSizeX = 2500
local TargetSizeY = 2048
local ChocoboRunSpeed = 2
local ChocoboRunMinDistance = ChocoboRunSpeed * 2
local UIMapMinScale = MapDefine.MapConstant.MAP_SCALE_MIN
local UIMapMaxScale = MapDefine.MapConstant.MAP_SCALE_MAX

---@class ChocoboTransportMapContentView : MapContentView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommGesture_UIBP CommGestureView
---@field CommonCurve_UIBP CommonCurveView
---@field Fly ChocoboTransportBirdFlyItemView
---@field Focus ChocoboTransportFocusBirdRoomItemView
---@field ImgBG UFImage
---@field ImgMap UFImage
---@field ImgMask UFImage
---@field MovePath_UIBP MovePathView
---@field PanelMap UFCanvasPanel
---@field PanelMarker UFCanvasPanel
---@field Run ChocoboTransportBirdRunItemView
---@field AnimIn UWidgetAnimation
---@field AnimMapIn UWidgetAnimation
---@field AnimMapOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboTransportMapContentView = LuaClass(MapContentView, true)

function ChocoboTransportMapContentView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommGesture_UIBP = nil
	--self.CommonCurve_UIBP = nil
	--self.Fly = nil
	--self.Focus = nil
	--self.ImgBG = nil
	--self.ImgMap = nil
	--self.ImgMask = nil
	--self.MovePath_UIBP = nil
	--self.PanelMap = nil
	--self.PanelMarker = nil
	--self.Run = nil
	--self.AnimIn = nil
	--self.AnimMapIn = nil
	--self.AnimMapOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.FocusPosition = {X = 0, Y = 0}
	self.AnimTimer = nil
end

function ChocoboTransportMapContentView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommGesture_UIBP)
	self:AddSubView(self.CommonCurve_UIBP)
	self:AddSubView(self.Fly)
	self:AddSubView(self.Focus)
	self:AddSubView(self.MovePath_UIBP)
	self:AddSubView(self.Run)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboTransportMapContentView:OnInit()
	self.Super:OnInit()

	self.Binders = {
		{ "MapPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgMap, false, false, true) },
		{ "IsMaskVisible", UIBinderSetIsVisible.New(self, self.ImgMask)},
		{ "MaskPath", UIBinderSetMaterialTextureFromAssetPath.New(self, self.ImgMask, "Mask")},
		{ "DiscoveryFlag", UIBinderSetMaterialScalarParameterValue.New(self, self.ImgMask, "DiscoveryFlag")},
	}

	local CommGesture = self.CommGesture_UIBP
	local function OnScaleChanged(RenderScale)
		WorldMapMgr:OnMapScaleChange(RenderScale.X)
	end

	CommGesture:SetOnScaleChangedCallback(OnScaleChanged)

	local function OnPositionChanged(X, Y)
		self:OnPositionChanged(X, Y)
	end

	CommGesture:SetOnPositionChangedCallback(OnPositionChanged)

	local function OnClickedMap(ScreenPosition)
		self:OnClickedMap(ScreenPosition)
	end

	CommGesture:SetOnClickedCallback(OnClickedMap)
	CommGesture:SetMinRenderScale(UIMapMinScale)
	CommGesture:SetMaxRenderScale(UIMapMaxScale)
end

function ChocoboTransportMapContentView:OnClickedMap(ScreenPosition)
	if not UIUtil.IsUnderLocation(self.ImgMap, ScreenPosition) then
		return
	end

	local IsShowCurrentMapUseTip = false
	local MapMarkers = {}
	local RegionMarkers = {}
	for k, v in pairs(self.MarkerInfos) do
		local MapMarker = k
		if v.View:IsUnderLocation(ScreenPosition) then
			local MarkerType = v.ViewModel:GetType()
			if MarkerType == MapMarkerType.ChocoboStable then
				-- 判断是否可选
				if not MapMarker.IsBook then
					MsgTipsUtil.ShowTips(LSTR(580004)) --580004=该鸟房暂未登记，请先登记
					return
				end
				if ChocoboTransportMgr:IsStartNpc(MapMarker.NpcID) then
					MsgTipsUtil.ShowTips(LSTR(580005)) --580005=此处为当前所在地
					return
				end
				table.insert(MapMarkers, MapMarker)
				-- 更新focus
				local PosX, PosY = v.ViewModel:GetPosition()
				self.FocusPosition.X = PosX
				self.FocusPosition.Y = PosY
				local Scale = self.RenderScale.X
				local X, Y = MapUtil.AdjustMapMarkerPosition(Scale, PosX, PosY)
				UIUtil.CanvasSlotSetPosition(self.Focus, FVector2D(X, Y))
				UIUtil.SetIsVisible(self.Focus, true)
				break
			elseif MarkerType == MapMarkerType.ChocoboTransportPoint or
					((MarkerType == MapMarkerType.ChocoboTransportWharf or MarkerType == MapMarkerType.ChocoboTransportTransferLine)
					and MapMarker.IsCanClick) then
				table.insert(MapMarkers, MapMarker)
				-- 更新focus
				local PosX, PosY = v.ViewModel:GetPosition()
				self.FocusPosition.X = PosX
				self.FocusPosition.Y = PosY
				local Scale = self.RenderScale.X
				local X, Y = MapUtil.AdjustMapMarkerPosition(Scale, PosX, PosY)
				UIUtil.CanvasSlotSetPosition(self.Focus, FVector2D(X, Y))
				UIUtil.SetIsVisible(self.Focus, true)
				break
			elseif MapMarker.MarkerCfg and MapMarker.MarkerCfg.EventType == 1 then
				IsShowCurrentMapUseTip = true
			end
		end
	end
	--没有找到其他可点击mapmarker
	if #MapMarkers == 0 and IsShowCurrentMapUseTip then
		MsgTipsUtil.ShowTips(LSTR(580011)) --580011("该陆行鸟只能在当前地图使用")
	end

	local MapMarker = MapMarkers[1]
	if MapMarker and MapMarker:GetType() == MapMarkerType.ChocoboTransportPoint then
		-- 处理任务目标点在不同地块情况
		local Major = MajorUtil.GetMajor()
		local StartPos = Major:FGetActorLocation()
		local PosX, PosY, PosZ = MapMarker:GetWorldPos()
		local EndPos = {X=PosX, Y=PosY, Z=PosZ}
		if not _G.ChocoboTransportMgr:IsSameMapBlock(MapMarker.MapID, StartPos, EndPos) then
			self:FindGapToQuestPoint(MapMarker.MapID, EndPos)
			return
		end
	end

	self:OnClickedMakers(MapMarkers, RegionMarkers, ScreenPosition)
end

function ChocoboTransportMapContentView:FindGapToQuestPoint(MapID, Pos)
	local Point = _G.ChocoboTransportMgr:GetGapPointToTransportPoint(MapID, Pos)
	if Point then
		local UIMapID = MapUtil.GetUIMapID(MapID)
		local Cfg = MapUICfg:FindCfgByKey(UIMapID)
		if not Cfg then
			return
		end
		local MapScale = Cfg.Scale
		local MapOffsetX = Cfg.OffsetX
		local MapOffsetY = Cfg.OffsetY
		local UIX, UIY = MapUtil.ConvertMapPos2UI(Point.X, Point.Y, MapOffsetX, MapOffsetY, MapScale, true)
		self.FocusPosition.X = UIX
		self.FocusPosition.Y = UIY

		local RenderScale = self.RenderScale.X
		local X, Y = MapUtil.AdjustMapMarkerPosition(RenderScale, self.FocusPosition.X, self.FocusPosition.Y)
		UIUtil.CanvasSlotSetPosition(self.Focus, FVector2D(X, Y))
		UIUtil.SetIsVisible(self.Focus, true)

		ChocoboTransportMgr:SendFindPath(UE.FVector(Point.X, Point.Y, Point.Z))

		self:ShowQuestTrackInfo()
	end
end

function ChocoboTransportMapContentView:OnDestroy()

end

function ChocoboTransportMapContentView:OnShow()
	self.FocusPosition.X = 0
	self.FocusPosition.Y = 0

	WorldMapMgr:OnMapScaleChange(1.0)

	local CurrentMapResID = _G.PWorldMgr:GetCurrMapResID()
	local UIMapID = MapUtil.GetUIMapID(CurrentMapResID)

	self:SetContentType(MapContentType.ChocoboTransport)
	MapMarkerMgr:CreateProviders(self.ContentType)
	self:CreateAllMarkers(UIMapID)

	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if Cfg then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgMap, Cfg.Path)
		--UIUtil.ImageSetBrushFromAssetPath(self.ImgBackground, Cfg.Background, false, true)
	end

	local X = Cfg.UIMapOffsetX
	local Y = Cfg.UIMapOffsetY
	local CommGesture = self.CommGesture_UIBP
	CommGesture:SetOffset(X, Y)
	self:OnPositionChanged(X, Y)

	local ViewportSize = UIUtil.GetViewportSize()
	local Scale = UIUtil.GetViewportScale()
	local ViewportX = ViewportSize.X / Scale
	local ViewportY = ViewportSize.Y / Scale
	CommGesture:SetIsLockArea(true)
	CommGesture:SetLockArea(0, ViewportX, 0, ViewportY)
	CommGesture:SetTargetSize(TargetSizeX, TargetSizeY)

	self:FindQuestTargetNearbyTransportPoint()

	if self.IsNearGap then
		_G.MsgTipsUtil.ShowTipsByID(306210)
	else
		_G.MsgTipsUtil.ShowTipsByID(40267)
	end
end

function ChocoboTransportMapContentView:OnHide()
	MapMarkerMgr:ReleaseProviders(self.ContentType)

	self:ReleaseAllMarker()

	self:StopChocoboRun()
end

function ChocoboTransportMapContentView:OnRegisterUIEvent()

end

function ChocoboTransportMapContentView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()

	self:RegisterGameEvent(EventID.WorldMapScaleChanged, self.OnGameEventWorldMapScaleChanged)
end

function ChocoboTransportMapContentView:OnRegisterBinder()
	self:RegisterBinders(MapVM, self.Binders)
end


---重写子类CreateAllMarkers
function ChocoboTransportMapContentView:CreateAllMarkers(UIMapID)
	self:ReleaseAllMarker()

	if nil == UIMapID or UIMapID <= 0 then
		return
	end

	self.UIMapID = UIMapID

	local Markers = MapMarkerMgr:GetMapMarkers(UIMapID, nil, self:GetContentType())
	if nil == Markers then
		return
	end

	for i = 1, #Markers do
		local Marker = Markers[i]
		local MarkerCfg = Marker.MarkerCfg
		if MarkerCfg then
			if MarkerCfg.TextType > 0 or MarkerCfg.EventType == MapMarkerEventType.MAP_MARKER_EVENT_CHANGE_MAP
				or MarkerCfg.EventType == MapMarkerEventType.MAP_MARKER_EVENT_TELEPO then
				self:CreateMarker(Marker)
			end
		else
			self:CreateMarker(Marker)
		end
	end
end

function ChocoboTransportMapContentView:FindQuestTargetNearbyTransportPoint()
	local CurrentMapResID = _G.PWorldMgr:GetCurrMapResID()
	local UIMapID = MapUtil.GetUIMapID(CurrentMapResID)
	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if not Cfg then
		self.IsNearGap = false --最近隘口
		return
	end
	local MapScale = Cfg.Scale
	local MapOffsetX = Cfg.OffsetX
	local MapOffsetY = Cfg.OffsetY
	-- 获取传输目标点
	---@type ChocoboTransportPoint
	local Point, IsNearGap = ChocoboTransportMgr:GetQuestTargetNearbyTransportPoint(CurrentMapResID)
	if Point then
		local UIX, UIY = MapUtil.ConvertMapPos2UI(Point.X, Point.Y, MapOffsetX, MapOffsetY, MapScale, true)
		self.FocusPosition.X = UIX
		self.FocusPosition.Y = UIY

		local RenderScale = self.RenderScale.X
		local X, Y = MapUtil.AdjustMapMarkerPosition(RenderScale, self.FocusPosition.X, self.FocusPosition.Y)
		UIUtil.CanvasSlotSetPosition(self.Focus, FVector2D(X, Y))
		UIUtil.SetIsVisible(self.Focus, true)

		--if Point.NpcID and Point.NpcID > 0 then
		--	--如果是npc,则寻找npc前面的位置点
		--	local OffsetPos = _G.NavigationPathMgr.GetNavigationPosByNpcID(CurrentMapResID, Point.NpcID)
		--	if OffsetPos then
		--		ChocoboTransportMgr:SendFindPath(OffsetPos)
		--	else
		--		--保底,避免计算npc前面位置点错误导致无法运输
		--		ChocoboTransportMgr:SendFindPath(UE.FVector(Point.X, Point.Y, Point.Z))
		--	end
		--else
			ChocoboTransportMgr:SendFindPath(UE.FVector(Point.X, Point.Y, Point.Z))
		--end
		self:AdjustMarkerView2CenterPos(UIX, UIY)

		self:RegisterTimer(self.OnPlayAnimInFinish, self.AnimIn:GetEndTime())
	else
		local Major = MajorUtil.GetMajor()
		local Location = Major:FGetActorLocation()
		local UIX, UIY = MapUtil.ConvertMapPos2UI(Location.X, Location.Y, MapOffsetX, MapOffsetY, MapScale, true)
		self:AdjustMarkerView2CenterPos(UIX, UIY)
	end
	self.IsNearGap = IsNearGap
end

-- 显示追踪任务前往浮窗
function ChocoboTransportMapContentView:ShowQuestTrackInfo()
	local FocusPosition = self.FocusPosition
	if FocusPosition then
		local MinDistance = 4096 ^ 2
		local MapMarker = nil
		local MapMarkerView = nil
		for K, V in pairs(self.MarkerInfos) do
			local MarkerType = V.ViewModel:GetType()
			if MarkerType == MapMarkerType.ChocoboTransportPoint or
				MarkerType == MapMarkerType.ChocoboTransportWharf or
				MarkerType == MapMarkerType.ChocoboTransportTransferLine then
				local UIPosX, UIPosY = K:GetAreaMapPos()
				local Distance = (FocusPosition.X - UIPosX) ^ 2 +  (FocusPosition.Y - UIPosY) ^ 2
				if Distance < MinDistance then
					MinDistance = Distance
					MapMarker = K
					MapMarkerView = V.View
				end
				if V.View.AnimNew then
					V.View:PlayAnimation(V.View.AnimNew)
				end
			end
		end
		if MapMarker then
			if MapMarker.SetCanClick then
				MapMarker:SetCanClick(true)
			end
			local ScreenPosition = UIUtil.LocalToAbsolute(MapMarkerView, FVector2D(0,-50))
			local Params = { MapMarker = MapMarker, ScreenPosition = ScreenPosition }
			_G.UIViewMgr:ShowView(UIViewID.WorldMapMarkerTipsChocoboTransport, Params)
		end
	end
end

function ChocoboTransportMapContentView:UpdatePlacedMarkerPos()
	local PlacedMarkerPos = self.PlacedMarkerPos
	if nil ~= PlacedMarkerPos then
		local Scale = self.RenderScale.X
		local X, Y = MapUtil.AdjustMapMarkerPosition(Scale, PlacedMarkerPos.X, PlacedMarkerPos.Y)
		UIUtil.CanvasSlotSetPosition(self.MapPlacedMarker, FVector2D(X, Y))
	end
end

function ChocoboTransportMapContentView:UpdateChocoboStableMarkers()
	for _, MapMarker in pairs(self.MarkerInfos) do
		-- 只更新鸟房
		if MapMarker.ViewModel:GetType() == MapMarkerType.ChocoboStable then
			local Marker = MapMarker.ViewModel.MapMarker
			Marker:UpdateIcon()
			local IsBook = ChocoboTransportMgr:IsBook(Marker.MapID, Marker.NpcID)
			if IsBook then
				MapMarker.ViewModel.IconPath = ChocoboTransportDefine.ICON_ACTIVE_MARKER
			else
				MapMarker.ViewModel.IconPath = ChocoboTransportDefine.ICON_UNACTIVE_MARKER
			end
		end
	end
end

---陆行鸟动画
---@param FindPath UE.TArray(UE.FVector2D)
function ChocoboTransportMapContentView:PlayChocoboRun(FindPath)
	if not FindPath then
		return
	end
	--初始化动画参数
	---@type UE.TArray(UE.FVector2D)
	self.FindPathArray = FindPath
	self.NextIndex = 2
	self.RunPoint = FindPath:GetRef(1)
	self.ChocoboFace = FVector2D(1, 1)
	local bFlyVisible = ChocoboTransportMgr:IsFlyMode()
	UIUtil.SetIsVisible(self.Run, not bFlyVisible)
	UIUtil.SetIsVisible(self.Fly, bFlyVisible)


	if self.AnimTimerID then
		TimerMgr:CancelTimer(self.AnimTimerID)
	end
	self.AnimTimerID = TimerMgr:AddTimer(self, self.OnTick, 0, 0.033, 0)
end

function ChocoboTransportMapContentView:StopChocoboRun()
	UIUtil.SetIsVisible(self.Run, false)
	UIUtil.SetIsVisible(self.Fly, false)

	if self.AnimTimerID then
		TimerMgr:CancelTimer(self.AnimTimerID)
		self.AnimTimerID = nil
	end
end

function ChocoboTransportMapContentView:OnTick()
	local Target = self.FindPathArray:GetRef(self.NextIndex)
	local Dir = Target - self.RunPoint
    local DirLength = math.sqrt(Dir.X*Dir.X + Dir.Y*Dir.Y)

	--normalize
	Dir.X = Dir.X / DirLength
	Dir.Y = Dir.Y / DirLength
	self.RunPoint = self.RunPoint + Dir * ChocoboRunSpeed

	local Offset = Target - self.RunPoint
	local Distance = math.sqrt(Offset.X*Offset.X + Offset.Y*Offset.Y)
	if Distance <= ChocoboRunMinDistance then
		if self.NextIndex >= self.FindPathArray:Length() then
			self.NextIndex = 2
			self.RunPoint = self.FindPathArray:GetRef(1)
		else
			self.NextIndex = self.NextIndex + 1
		end
	end

	--陆行鸟朝向
	if Dir.X > 0 then
		self.ChocoboFace.X = -1
	else
		self.ChocoboFace.X = 1
	end
	self.Run:SetRenderScale(self.ChocoboFace)
	UIUtil.CanvasSlotSetPosition(self.Run, self.RunPoint)

	self.Fly:SetRenderScale(self.ChocoboFace)
	UIUtil.CanvasSlotSetPosition(self.Fly, self.RunPoint)
end

function ChocoboTransportMapContentView:OnGameEventWorldMapScaleChanged(Scale)
	self.RenderScale.X = Scale
	self.RenderScale.Y = Scale
	self:OnScaleChanged()
end

---OnScaleChanged
function ChocoboTransportMapContentView:OnScaleChanged()
	local RenderScale = self.RenderScale
	local Scale = RenderScale.X

	self.PanelMap:SetRenderScale(RenderScale)

	self.CommGesture_UIBP:SetScale(Scale)
	self.CommGesture_UIBP:SetRenderScale(FVector2D(RenderScale.X, RenderScale.Y))
	self.CommGesture_UIBP:AdjustOffset()

	for _, v in pairs(self.MarkerInfos) do
		v.ViewModel.Scale = Scale
		v.View:OnScaleChanged(Scale)
		v.ViewModel.IsMarkerVisible = true

		local MarkerCfg = v.ViewModel.MapMarker.MarkerCfg
		if MarkerCfg then
			if MarkerCfg.TextType > 0 or MarkerCfg.EventType == MapMarkerEventType.MAP_MARKER_EVENT_CHANGE_MAP then
				v.ViewModel.NameVisibility = 0
			else
				v.ViewModel.NameVisibility = 2
			end
		end
	end

	-- 更新focus
	local X, Y = MapUtil.AdjustMapMarkerPosition(Scale, self.FocusPosition.X, self.FocusPosition.Y)
	UIUtil.CanvasSlotSetPosition(self.Focus, FVector2D(X, Y))

	--self:UpdatePlacedMarkerPos()
	self.ParentView:UpdateFindPath()
end

function ChocoboTransportMapContentView:OnPositionChanged(X, Y)
	local Position = FVector2D(X, Y)

	UIUtil.CanvasSlotSetPosition(self.PanelMap, Position)
	UIUtil.CanvasSlotSetPosition(self.PanelMarker, Position)
	UIUtil.CanvasSlotSetPosition(self.MovePath_UIBP, Position)

	if WorldMapMgr.bShowDebugInfo then
		_G.FLOG_INFO("OnPositionChanged OffsetX=%f OffsetY=%f", X, Y)
	end

	self.ParentView:UpdateFindPathPosition(Position)
end

function ChocoboTransportMapContentView:OnPlayAnimInFinish()
	self:ShowQuestTrackInfo()
end

function ChocoboTransportMapContentView:AdjustMarkerView2CenterPos(UIPosX, UIPosY)
	local MarkerSlotPos = UE.FVector2D(UIPosX, UIPosY)
	local ParentViewSize = UIUtil.CanvasSlotGetSize(self.PanelMarker)
	local Pos = -MarkerSlotPos + ParentViewSize / 2
	self.CommGesture_UIBP:SetOffset(0, 0)
	self.CommGesture_UIBP:OnMoved(Pos)
end

return ChocoboTransportMapContentView