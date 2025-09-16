---
--- Author: anypkvcai
--- DateTime: 2023-07-04 20:50
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local EventID = require("Define/EventID")
local MapDefine = require("Game/Map/MapDefine")
local MapContentView = require("Game/Map/View/MapContentView")
local MapUICfg = require("TableCfg/MapUICfg")
local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetMaterialTextureFromAssetPath = require("Binder/UIBinderSetMaterialTextureFromAssetPath")
local UIBinderSetMaterialScalarParameterValue = require("Binder/UIBinderSetMaterialScalarParameterValue")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")
local MapMarkerType = MapDefine.MapMarkerType
local FVector2D = _G.UE.FVector2D
local MapContentType = MapDefine.MapContentType

local TargetSizeX = 3800
local TargetSizeY = 2500

---@class FishMapContentView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommGesture_UIBP CommGestureView
---@field ImgBG UFImage
---@field ImgFogBg UFImage
---@field ImgMap UFImage
---@field ImgMask UFImage
---@field PanelMap UFCanvasPanel
---@field PanelMarker UFCanvasPanel
---@field AnimMapIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishMapContentView = LuaClass(MapContentView, true)

function FishMapContentView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommGesture_UIBP = nil
	--self.ImgBG = nil
	--self.ImgFogBg = nil
	--self.ImgMap = nil
	--self.ImgMask = nil
	--self.PanelMap = nil
	--self.PanelMarker = nil
	--self.AnimMapIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishMapContentView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommGesture_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishMapContentView:OnInit()
	self.Super:OnInit()
	self.ContentType = MapContentType.FishMap
	self.RenderScale = FVector2D(1, 1)

	local function OnClickedMap(ScreenPosition)
		self:OnClickedMap(ScreenPosition)
	end
	self.CommGesture_UIBP:SetOnClickedCallback(OnClickedMap)

	local function OnScaleChanged(RenderScale)
		self.RenderScale = RenderScale
		_G.FishIngholeVM:SetMapScale(RenderScale.X)
        self.CommGesture_UIBP.NamedSlotChild:SetRenderScale(RenderScale)
	end
	self.CommGesture_UIBP:SetOnScaleChangedCallback(OnScaleChanged)

	local function OnPositionChanged(X, Y)
		self:OnPositionChanged(X, Y)
	end

	self.CommGesture_UIBP:SetOnPositionChangedCallback(OnPositionChanged)
	UIUtil.SetIsVisible(self.ImgFogBg, false, false)
end

function FishMapContentView:OnShow()
	_G.MapMarkerMgr:CreateProviders(self.ContentType)

	local MapID = FishIngholeVM.SelectedLocationMapID
	self:OnGameEventFishNoteNotifyMapInfo({MapID = MapID})
	local LocationID = FishIngholeVM.SelectLocationID
	if LocationID then
		_G.EventMgr:SendEvent(EventID.FishNoteNotifyChangePointState, LocationID, true)
	end

	self:SetContentLimitArea()
	self.SetContentLimit = true
end

--- 设置地图内容的限制区域
function FishMapContentView:SetContentLimitArea()
	local ViewportSize = UIUtil.GetViewportSize()
	local Scale = UIUtil.GetViewportScale()
	local ViewportX = ViewportSize.X / Scale
	local ViewportY = ViewportSize.Y / Scale

	local CommGesture = self.CommGesture_UIBP
	CommGesture:SetIsLockArea(true)
	CommGesture:SetLockArea(0, ViewportX, 0, ViewportY)
	CommGesture:SetTargetSize(TargetSizeX, TargetSizeY)
end

function FishMapContentView:OnHide()
	_G.MapMarkerMgr:ReleaseProviders(self.ContentType)

	self:ReleaseAllMarker()
end

function FishMapContentView:OnRegisterBinder()
	self.Binders = {
		--{ "IsFogAllActivate", UIBinderSetIsVisible.New(self, self.ImgBg)},
		--{ "IsFogAllActivate", UIBinderSetIsVisible.New(self, self.ImgFogBg, true)},
		{ "BgPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgBg, false, false)},
		{ "MapPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgMap, false, true)},
		{ "IsMaskVisible", UIBinderSetIsVisible.New(self, self.ImgMask)},
		{ "MaskPath", UIBinderSetMaterialTextureFromAssetPath.New(self, self.ImgMask, "Mask")},
		{ "DiscoveryFlag", UIBinderSetMaterialScalarParameterValue.New(self, self.ImgMask, "DiscoveryFlag")},
	}
	self:RegisterBinders(WorldMapVM, self.Binders)
end

function FishMapContentView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimerUpdateMap, 0, 0.2, 0)
end

function FishMapContentView:OnTimerUpdateMap()
	_G.MapMgr:UpdateMajorPosition()
end

function FishMapContentView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()

	self:RegisterGameEvent(EventID.FishNotesMapScaleChanged, self.OnGameEventFishNotesMapScaleChanged)
	self:RegisterGameEvent(EventID.FishNoteNotifyMapInfo, self.OnGameEventFishNoteNotifyMapInfo)
	self:RegisterGameEvent(EventID.FishNoteNotifyChangePointState, self.OnGameEventFishNotifyChangePointState)
	self:RegisterGameEvent(EventID.PreprocessedMouseButtonUp, self.PrintMarkerPos)
	self:RegisterGameEvent(EventID.MapFollowAdd, self.OnGameEventMapFollowUpdate)
	self:RegisterGameEvent(EventID.MapFollowDelete, self.OnGameEventMapFollowUpdate)
end

---通过滑动条改变缩放
---@param Scale number
function FishMapContentView:OnGameEventFishNotesMapScaleChanged(Scale)
	self.RenderScale.X = Scale
	self.RenderScale.Y = Scale
	self.CommGesture_UIBP:OnScaleChanged(self.RenderScale)
	self.CommGesture_UIBP:AdjustOffset()
end

function FishMapContentView:OnGameEventMapFollowUpdate(FollowInfo)
	if FollowInfo.FollowType == MapMarkerType.FixPoint then
		local UIMapID = MapUtil.GetUIMapID(FishIngholeVM.SelectedLocationMapID)
		self:CreateAllMarkers(UIMapID)
	end
end

function FishMapContentView:OnGameEventFishNoteNotifyMapInfo(Params)
	local UIMapID = MapUtil.GetUIMapID(Params.MapID)

	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		return
	end

	_G.WorldMapMgr:ChangeMap(UIMapID)-- 更新迷雾数据
	if self.UIMapID == nil or self.UIMapID ~= UIMapID then
		self:PlayAnimation(self.AnimMapIn)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgMap, Cfg.Path)
	end
	if not Params.NoRreshMarkers then
		self:OnMapChanged(UIMapID)
		self:CreateAllMarkers(UIMapID)
	end
end

function FishMapContentView:OnMapChanged(UIMapID)
	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		return
	end
	--设置距UI地图中心点的偏移位置
	local X = Cfg.UIMapOffsetX
	local Y = Cfg.UIMapOffsetY
	UIUtil.CanvasSlotSetPosition(self.PanelMarker, FVector2D(X, Y))
	UIUtil.CanvasSlotSetPosition(self.PanelMap, FVector2D(X, Y))

	--设置默认大小
	local DefaultScale = Cfg.UIMapDefaultScale
	local UIMapMinScale = Cfg.UIMapMinScale
	local UIMapMaxScale = Cfg.UIMapMaxScale
	local RenderScale = self.RenderScale
	RenderScale.X = DefaultScale
	RenderScale.Y = DefaultScale
	self.PanelMap:SetRenderScale(RenderScale)

	self.CommGesture_UIBP:SetOffset(X, Y)
	self.CommGesture_UIBP:SetScale(DefaultScale)
	self.CommGesture_UIBP:SetMinRenderScale(UIMapMinScale)
	self.CommGesture_UIBP:SetMaxRenderScale(UIMapMaxScale)
    self.CommGesture_UIBP:SetRenderScale(RenderScale)
	self.CommGesture_UIBP:SetMoveEnable(not MapUtil.IsWorldMap(UIMapID))

	FishIngholeVM:SaveUIMapScale(UIMapMinScale, UIMapMaxScale)
	self.CommGesture_UIBP:OnScaleChanged(RenderScale)

	self:OnPositionChanged(X, Y)
	--WorldMapVM:SetPlacedMarkerVisible(false)
end

function FishMapContentView:OnPositionChanged(X, Y)
	local Position = FVector2D(X, Y)
	UIUtil.CanvasSlotSetPosition(self.PanelMap, Position)
	UIUtil.CanvasSlotSetPosition(self.PanelMarker, Position)

	if _G.FishNotesMgr.bShowDebugInfo then
		_G.FLOG_INFO("OnPositionChanged OffsetX=%f OffsetY=%f", X, Y)
	end
end

function FishMapContentView:OnGameEventFishNotifyChangePointState(LocationID)
	self:FocusMarkerByID(LocationID)
end

-- 钓场标记居中显示
function FishMapContentView:FocusMarkerByID(MarkerID)
	local Marker = self:GetMapMarkerByID(MarkerID)
	if Marker == nil then
		return
	end

	if not self.SetContentLimit then
		self:SetContentLimitArea()
	end
	local MarkerSlotPos = UIUtil.CanvasSlotGetPosition(Marker)
	local ParentViewSize = UIUtil.CanvasSlotGetSize(self.PanelMarker)
	local Pos = -MarkerSlotPos + ParentViewSize / 2
	self.CommGesture_UIBP:SetOffset(0, 0)
	self.CommGesture_UIBP:OnMoved(Pos)
end

function FishMapContentView:PrintMarkerPos(MouseEvent)
    if _G.FishNotesMgr.FishingholePosAdjustGM then
        local UKismetInputLibrary = _G.UE.UKismetInputLibrary
        local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
        if UIUtil.IsUnderLocation(self.PanelMap, MousePosition) then
            local SelfGeometry = _G.UE.UWidgetLayoutLibrary.GetViewportWidgetGeometry(self.PanelMarker)
            local LocalMousePosition = _G.UE.USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, MousePosition)
            local offset = UIUtil.GetWidgetPosition(self.PanelMarker)
            FLOG_ERROR(string.format("FishMapContentView:OnClickPosition {X = %f, Y = %f}",LocalMousePosition.X-offset.X , LocalMousePosition.Y-offset.Y))
        end
    end
end

return FishMapContentView