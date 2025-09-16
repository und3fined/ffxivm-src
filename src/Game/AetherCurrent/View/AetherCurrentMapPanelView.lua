---
--- Author: Alex
--- DateTime: 2023-09-04 10:38
--- Description: 风脉泉地图内容界面
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local ProtoRes = require("Protocol/ProtoRes")
local MapContentView = require("Game/Map/View/MapContentView")
local MapUtil = require("Game/Map/MapUtil")
local MapUICfg = require("TableCfg/MapUICfg")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetMaterialTextureFromAssetPath = require("Binder/UIBinderSetMaterialTextureFromAssetPath")
local UIBinderSetMaterialScalarParameterValue = require("Binder/UIBinderSetMaterialScalarParameterValue")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")
local AetherCurrentsMgr = require("Game/AetherCurrent/AetherCurrentsMgr")
local MapDefine = require("Game/Map/MapDefine")
local ModuleMapContentVM = require("Game/Map/VM/ModuleMapContentVM")
local MapProviderConfigs = MapDefine.MapProviderConfigs
local UnlockMapAnimConstantTime = AetherCurrentDefine.UnlockMapAnimConstantTime
local UnlockMapAnimDelayTime = AetherCurrentDefine.UnlockMapAnimDelayTime
local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerEventType = ProtoRes.MapMarkerEventType
local MapMarkerMgr = _G.MapMarkerMgr
local UIViewMgr = _G.UIViewMgr
local UE = _G.UE
local FVector2D = _G.UE.FVector2D
local TargetSizeX = 2600 * 1.5--2500
local TargetSizeY = 2248 * 1.5--2048
local XLockOffset = 0
local YLockOffset = 0
local FLOG_ERROR = _G.FLOG_ERROR

---@class AetherCurrentMapPanelView : MapContentView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommGesture_UIBP CommGestureView
---@field ImgBG UFImage
---@field ImgBackground UFImage
---@field ImgFogBg UFImage
---@field ImgMap UFImage
---@field ImgMask UFImage
---@field PanelMap UFCanvasPanel
---@field PanelMarker UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AetherCurrentMapPanelView = LuaClass(MapContentView, true)

function AetherCurrentMapPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommGesture_UIBP = nil
	--self.ImgBG = nil
	--self.ImgBackground = nil
	--self.ImgFogBg = nil
	--self.ImgMap = nil
	--self.ImgMask = nil
	--self.PanelMap = nil
	--self.PanelMarker = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AetherCurrentMapPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommGesture_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AetherCurrentMapPanelView:OnInit()
	self.Super:OnInit()

	local function OnClickedMap(ScreenPosition)
		if ModuleMapContentVM:GetTouchAllowed() then
			self:OnClickedMap(ScreenPosition)
		end
	end

	self.CommGesture_UIBP:SetOnClickedCallback(OnClickedMap)

	local function OnMapScaleChange(Scale)
		if ModuleMapContentVM:GetTouchAllowed() then
			ModuleMapContentVM:SetMapScale(Scale.X)
		end
	end

	self.CommGesture_UIBP:SetOnScaleChangedCallback(OnMapScaleChange)

	local function OnMapPositionChange(X, Y)
		if ModuleMapContentVM:GetTouchAllowed() then
			ModuleMapContentVM:SetMapOffset(X, Y)
		end
	end

	self.CommGesture_UIBP:SetOnPositionChangedCallback(OnMapPositionChange)

	self.Binders = {
		{ "IsMaskVisible", UIBinderSetIsVisible.New(self, self.ImgFogBg, true)},
		{ "MapPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgMap, false, true, true)},
		{ "BackgroundPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgBackground, false, false, true)},
		{ "IsMaskVisible", UIBinderSetIsVisible.New(self, self.ImgMask)},
		{ "MaskPath", UIBinderSetMaterialTextureFromAssetPath.New(self, self.ImgMask, "Mask")},
		{ "DiscoveryFlag", UIBinderSetMaterialScalarParameterValue.New(self, self.ImgMask, "DiscoveryFlag")},
		{ "MapScale", UIBinderValueChangedCallback.New(self, nil, self.OnCommGestureScaleChange)},
		{ "MapOffset", UIBinderValueChangedCallback.New(self, nil, self.OnCommGestureMapOffsetChange)},
	}

	self.TraceMarkerID = nil -- 当前需要追踪的MarkerID（为了处理分帧加载的地图标记）
end

function AetherCurrentMapPanelView:OnDestroy()
	self.TraceMarkerID = nil
end

function AetherCurrentMapPanelView:OnShow()
    self:SetContentLimitArea()
end

function AetherCurrentMapPanelView:OnHide()
	self:ReleaseAllMarker()
	_G.MapMarkerMgr:ReleaseProviders(self.ContentType)
	UIViewMgr:HideView(UIViewID.WorldMapMarkerTipsTransfer)
end

function AetherCurrentMapPanelView:OnRegisterUIEvent()

end

function AetherCurrentMapPanelView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
end

function AetherCurrentMapPanelView:OnRegisterBinder()
	self:RegisterBinders(ModuleMapContentVM, self.Binders)
end

--- 设置地图内容的限制区域
function AetherCurrentMapPanelView:SetContentLimitArea()
	local CommGesture = self.CommGesture_UIBP
	if not CommGesture then
		return
	end
	local ViewportSize = UIUtil.GetViewportSize()
	local Scale = UIUtil.GetViewportScale()
	local ViewportX = (ViewportSize.X - XLockOffset) / Scale
	local ViewportY = (ViewportSize.Y - YLockOffset) / Scale
	CommGesture:SetIsLockArea(true)
	CommGesture:SetLockArea(0, ViewportX, 0, ViewportY)
	CommGesture:SetTargetSize(TargetSizeX, TargetSizeY)
end

--[[function AetherCurrentMapPanelView:CreateAllMarkers(UIMapID)
	self:ReleaseAllMarker()

	if nil == UIMapID or UIMapID <= 0 then
		return
	end
	self.UIMapID = UIMapID

	local Markers = MapMarkerMgr:GetMapMarkers(UIMapID, self:GetContentType())
	if nil == Markers then
		return
	end

	for i = 1, #Markers do
		local Marker = Markers[i]
		self:CreateMarker(Marker)
		if Marker:GetType() == MapMarkerType.FixPoint then
			local VM = self:GetMapMarkerViewModeByMarker(Marker)
			if VM then
				VM.IconVisibility = _G.UE.ESlateVisibility.Visible
			end
		end
	end
end--]]

--- 分批创建地图标记(风脉使用)
function AetherCurrentMapPanelView:CreateMarkersByBatch(UIMapID)
	self:ReleaseAllMarker()

	if nil == UIMapID or UIMapID <= 0 then
		return
	end
	self.UIMapID = UIMapID

	local ContentType = self:GetContentType()

	local Configs = MapProviderConfigs[ContentType]
	if not Configs then
		return
	end

	local Markers = MapMarkerMgr:GetMapSpecificMarkers(UIMapID, ContentType, MapMarkerType.AetherCurrent)
	if nil == Markers then
		return
	end

	for i = 1, #Markers do
		local Marker = Markers[i]
		self:CreateMarker(Marker)
	end

	self:RegisterTimer(function()
		for _, MarkerType in ipairs(Configs) do
			if MarkerType ~= MapMarkerType.AetherCurrent then
				local Markers = MapMarkerMgr:GetMapSpecificMarkers(UIMapID, ContentType, MarkerType)
				if Markers then
					for i = 1, #Markers do
						local Marker = Markers[i]
						self:CreateMarker(Marker)
					end
				end
			end
		end
	end, UnlockMapAnimConstantTime + UnlockMapAnimDelayTime, nil, 1)
end

---重写父类的设定ContentType
---@param ContentType MapContentType
function AetherCurrentMapPanelView:SetContentType(ContentType)
	self.ContentType = ContentType
end

--- 刷新地图内容
---@param MapID number@地图id
---@param UIMapID number@地图UIid 某些地图没有对应的MapID，比如主城的飞空艇地图
function AetherCurrentMapPanelView:ShowMapContent(InMapId, InMakerId, bPlayEffect, UIMapID)
	local UIMapID = UIMapID and UIMapID or MapUtil.GetUIMapID(InMapId)

	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		FLOG_ERROR("无法找到 MapUICfg 数据，ID是 : "..UIMapID)
		return
	end

	AetherCurrentsMgr:ChangeMap(UIMapID) -- 因牵涉到更新迷雾数据，不再针对是否是同一地图id做屏蔽判断
	self.RenderScale.X = 1
	ModuleMapContentVM:SetMapScale(1)
	self:CreateAllMarkers(UIMapID, InMapId)
	-- 2024.11.25 策划要求去除分批创建风脉泉标志要求
	--[[if not bPlayEffect then

	else
		self:CreateMarkersByBatch(UIMapID)
	end--]]

	if InMakerId then
		self:FocusMarkerByID(InMakerId)
	end
end

function AetherCurrentMapPanelView:OnCommGestureScaleChange(Scale)
	local RenderScale = self.RenderScale
	RenderScale.X = Scale
	RenderScale.Y = Scale

	self.PanelMap:SetRenderScale(RenderScale)

	self.CommGesture_UIBP:SetScale(Scale)
	self.CommGesture_UIBP:SetRenderScale(UE.FVector2D(RenderScale.X, RenderScale.Y))
	self.CommGesture_UIBP:AdjustOffset()

	for _, v in pairs(self.MarkerInfos) do
		v.ViewModel:OnScaleChanged(Scale)
		v.View:OnScaleChanged(Scale)
	end
end

function AetherCurrentMapPanelView:OnCommGestureMapOffsetChange(NewOffset)
    if not NewOffset then
		return
	end

	local OffsetX = NewOffset.X
	local OffsetY = NewOffset.Y

	if not OffsetX or not OffsetY then
		return
	end

	local CommGesture = self.CommGesture_UIBP
	if not CommGesture then
		return
	end
	CommGesture:SetOffset(OffsetX, OffsetY)
	CommGesture:AdjustOffset() -- 调整偏移需求在设置的地图锁定限制区域内

	local Position = FVector2D(OffsetX, OffsetY)
	UIUtil.CanvasSlotSetPosition(self.PanelMap, Position)
	UIUtil.CanvasSlotSetPosition(self.PanelMarker, Position)
end

---@param MarkerID number @图标ID
---@param ZoomIn boolean @是否居中放大
function AetherCurrentMapPanelView:FocusMarkerByID(InMarkerID)
	local Marker = self:GetMapMarkerByID(InMarkerID)
	if Marker == nil then
		return
	end

	-- 距离中心点的位置
	local MarkerPos = UIUtil.CanvasSlotGetPosition(Marker)
	local ParentViewSize = UIUtil.CanvasSlotGetSize(self.PanelMarker)
	local Pos = -MarkerPos + ParentViewSize / 2
	ModuleMapContentVM:SetMapOffset(Pos.X, Pos.Y)
end

function AetherCurrentMapPanelView:SetPosition(X, Y)
	local CommGesture = self.CommGesture_UIBP
	if not CommGesture then
		return
	end
	CommGesture:SetOffset(0, 0)
	CommGesture:OnMoved(UE.FVector2D(X, Y))
end

--- 将不同类型标记的参数转化为对应MarkerID
--- 因为标记的结构比较乱，所以根据传参具体处理
function AetherCurrentMapPanelView:ConvertParamsTable2TargetMarkerID(Params)
	local ID = Params.ID
	if ID then
		return ID
	end

	local CrystalID = Params.CrystalID
	if CrystalID then
		local Marker = self:GetMapMarkerCrystal(CrystalID)
		if Marker then
			return Marker.ID
		end
	end
end

function AetherCurrentMapPanelView:PreSetTraceMarkerToImmediatelyCreate(MarkKeyParams)
	self.TraceMarkerID = self:ConvertParamsTable2TargetMarkerID(MarkKeyParams)
end

---@overload
function AetherCurrentMapPanelView:IsSpecialMarkerNeedImmediateCreate(MarkerType, MarkerID)
	if not MarkerID then
		return
	end

	local CurTraceID = self.TraceMarkerID
	if not CurTraceID then
		return
	end

	return MarkerID == CurTraceID
end

--- 追踪标记
---@param MarkKeyParams table
function AetherCurrentMapPanelView:TraceMarker(MarkKeyParams)
	local MarkerID = self:ConvertParamsTable2TargetMarkerID(MarkKeyParams)
	if not MarkerID then
		return
	end

	local _, Marker = self:GetMapMarkerByID(MarkerID)
	if Marker == nil then
		return
	end

	local DelayTraceTime = 0.1
	self:RegisterTimer(function()
		if MarkKeyParams.bBanTrace then -- ban掉追踪则return
			return
		end
		if not Marker:GetIsFollow() then
			Marker:ToggleFollow()
		end
	end, DelayTraceTime)

end

function AetherCurrentMapPanelView:UpdateCenterTelepoMarkerTipsState(MarkerID, bCloseTelepo)
	local _, Marker = self:GetMapMarkerByID(MarkerID)
	if Marker == nil then
		return
	end

	if not Marker.GetMarkerCfg then
		return
	end
	local MarkerCfg = Marker:GetMarkerCfg()
	if not MapUtil.IsMapCrystalByMarkerCfg(MarkerCfg) then
		return
	end

	if not Marker:GetIsActive() then
		return
	end

	local Info = self.MarkerInfos[Marker]
	if not Info then
		return
	end

	local MarkerView = Info.View
	if not MarkerView then
		return
	end

	local DelayTimeForMarkLoad = 0.5
	self:RegisterTimer(function()
		local ScreenPosition = UIUtil.LocalToAbsolute(MarkerView, FVector2D(0,-50))
		local Params = { MapMarker = Marker, ScreenPosition = ScreenPosition, ShowClosest = bCloseTelepo, NotHideOnClick = true }
		UIViewMgr:ShowView(UIViewID.WorldMapMarkerTipsTransfer, Params)
	end, DelayTimeForMarkLoad)
end


-- 找目标UI地图里指定坐标最近的已激活水晶
function AetherCurrentMapPanelView:FindClosestCrystal(TargetUIPos, CrystalTypePredicate)
	local ClosestDistance = math.huge
	local ClosestMapMarker

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
			end
		end
	end

	return ClosestMapMarker, ClosestDistance
end

return AetherCurrentMapPanelView