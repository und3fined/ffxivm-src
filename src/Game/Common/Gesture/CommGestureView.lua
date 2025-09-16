---
--- Author: anypkvcai
--- DateTime: 2022-11-22 16:28
--- Description: 缩放时只简单处理2指 而且是以中心点缩放
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")

local UE = _G.UE
local UWidgetBlueprintLibrary = UE.UWidgetBlueprintLibrary
local MIN_OFFSET = 100

---@class CommGestureView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field NamedSlotChild UNamedSlot
---@field MinRenderScale float
---@field MaxRenderScale float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
---@field Scale number
---@field bLockArea boolean
local CommGestureView = LuaClass(UIView, true)

function CommGestureView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.NamedSlotChild = nil
	--self.MinRenderScale = nil
	--self.MaxRenderScale = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.OnScaleChangedCallback = nil
	self.OnPositionChangedCallback = nil
	self.OnClickedCallback = nil
	self.OnPressCallback = nil
end

function CommGestureView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommGestureView:OnInit()
	self.bMoveEnable = true
	self.OffsetX = 0
	self.OffsetY = 0
	self.Scale = 1
	self.IsMoving = false
	self.bLockArea = false
	self.LockAreaMinX = 0
	self.LockAreaMaxX = 0
	self.LockAreaMinY = 0
	self.LockAreaMaxY = 0
	self.TargetWidth = 0
	self.TargetHeight = 0
	self.OverscrollRatio = 0.6

	self.RenderScale = UE.FVector2D(1, 1)

	self.TouchInfos = {
		[1] = {
			PointerIndex = 0,
			IsTouched = false,
			TouchPosition = UE.FVector2D(0, 0)
		},
		[2] = {
			PointerIndex = 1,
			IsTouched = false,
			TouchPosition = UE.FVector2D(0, 0)
		}
	}
end

function CommGestureView:OnDestroy()
	self.OnScaleChangedCallback = nil
	self.OnPositionChangedCallback = nil
	self.OnClickedCallback = nil
	self.OnPressCallback = nil
end

function CommGestureView:OnShow()
end

function CommGestureView:OnHide()
end

function CommGestureView:OnRegisterUIEvent()
end

function CommGestureView:OnRegisterGameEvent()
end

function CommGestureView:OnRegisterBinder()
end

function CommGestureView:GetTouchInfo(PointerIndex)
	return self.TouchInfos[PointerIndex + 1]
end

function CommGestureView:GetTouchCount()
	local Count = 0

	for i = 1, #self.TouchInfos do
		if self.TouchInfos[i].IsTouched then
			Count = Count + 1
		end
	end

	return Count
end

function CommGestureView:GetAnotherTouchInfo(PointerIndex)
	for i = 1, #self.TouchInfos do
		if i ~= PointerIndex + 1 then
			return self.TouchInfos[i]
		end
	end
end

--function CommGestureView:SetMaxMoveDistance(X, Y)
--	self.MaxMoveDistanceX = X
--	self.MaxMoveDistanceY = Y
--end

function CommGestureView:SetMoveEnable(bMoveEnable)
	self.bMoveEnable = bMoveEnable
end

function CommGestureView:SetIsLockArea(bLockArea)
	self.bLockArea = bLockArea
end

function CommGestureView:SetLockArea(MinX, MaxX, MinY, MaxY)
	self.LockAreaMinX = MinX
	self.LockAreaMaxX = MaxX
	self.LockAreaMinY = MinY
	self.LockAreaMaxY = MaxY
end

function CommGestureView:SetTargetSize(Width, Height)
	self.TargetWidth = Width
	self.TargetHeight = Height
end

function CommGestureView:SetOffset(X, Y)
	self.OffsetX = X
	self.OffsetY = Y
end

function CommGestureView:SetScale(Scale)
	self.Scale = Scale
end

function CommGestureView:SetRenderScale(RenderScale)
	self.RenderScale = RenderScale
end

function CommGestureView:SetMinRenderScale(Scale, MinScaleLimitByX, MinScaleLimitByY)
	self.MinRenderScale = Scale
	self.MinScaleLimitByX = MinScaleLimitByX
	self.MinScaleLimitByY = MinScaleLimitByY
end

function CommGestureView:SetMaxRenderScale(Scale)
	self.MaxRenderScale = Scale
end

function CommGestureView:GetMinRenderScale()
	return self.MinRenderScale
end

function CommGestureView:GetMaxRenderScale()
	return self.MaxRenderScale
end

function CommGestureView:SetOverscrollRatio(Ratio)
	self.OverscrollRatio = Ratio
end

function CommGestureView:OnTouchStarted(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	--print("CommGestureView:OnTouchStarted", PointerIndex, UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent))

	local TouchInfo = self:GetTouchInfo(PointerIndex)
	if nil == TouchInfo then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local Count = self:GetTouchCount()
	if Count <= 0 then
		self.IsMoving = false
	end

	local ScreenSpacePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)
	TouchInfo.IsTouched = true
	TouchInfo.TouchPosition = LocalPosition

	if nil ~= self.OnPressCallback then
		self.OnPressCallback(ScreenSpacePosition)
	end

	local AnotherTouchInfo = self:GetAnotherTouchInfo(PointerIndex)
	if nil ~= AnotherTouchInfo and AnotherTouchInfo.IsTouched then
		local Scale = UIUtil.GetViewportScale()
		self.m_ZoomDistance = UE.UKismetMathLibrary.Distance2D(LocalPosition, AnotherTouchInfo.TouchPosition) / Scale
	end

	local Handled = UWidgetBlueprintLibrary.Handled()
	return UWidgetBlueprintLibrary.CaptureMouse(Handled, self)
end

function CommGestureView:OnTouchMoved(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	--print("CommGestureView:OnTouchMoved", PointerIndex)

	local TouchInfo = self:GetTouchInfo(PointerIndex)
	if nil == TouchInfo then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local ScreenSpacePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)

	local Count = self:GetTouchCount()
	if Count <= 0 then
		TouchInfo.IsTouched = true
	end

	if Count == 1 then
		local LastPosition = TouchInfo.TouchPosition
		local Offset = LocalPosition - LastPosition
		--print("CommGestureView:OnTouchMoved LocalPosition, LastPosition, Offset", LocalPosition, LastPosition, Offset)
		local CursorDelta = UE.UKismetInputLibrary.PointerEvent_GetCursorDelta(InTouchEvent)
		--print("CursorDelta", CursorDelta)

		-- 有些手机手指单击会触发到move，这里假设距离很小时不判断为move
		if math.abs(Offset.X) > 1 or math.abs(Offset.Y) > 1 then
			self:OnMoved(Offset, ScreenSpacePosition)
			self.IsMoving = true
		end
	elseif Count == 2 then
		local AnotherTouchInfo = self:GetAnotherTouchInfo(PointerIndex)
		local Scale = UIUtil.GetViewportScale()
		local Distance = UE.UKismetMathLibrary.Distance2D(LocalPosition, AnotherTouchInfo.TouchPosition) / Scale
		self:OnZoomed(Distance / self.m_ZoomDistance)
		self.m_ZoomDistance = Distance
		self.IsMoving = true
	end

	TouchInfo.TouchPosition = LocalPosition

	return UWidgetBlueprintLibrary.Handled()
end

function CommGestureView:OnTouchEnded(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	--print("CommGestureView:OnTouchEnded", PointerIndex)

	local TouchInfo = self:GetTouchInfo(PointerIndex)
	if nil == TouchInfo then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local Count = self:GetTouchCount()

	if Count == 1 and not self.IsMoving and nil ~= self.OnClickedCallback then
		local ScreenPosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
		self.OnClickedCallback(ScreenPosition)
	end

	TouchInfo.IsTouched = false

	if Count <= 0 then
		self.IsMoving = false
	end

	--self:Overscroll()

	local Handled = UWidgetBlueprintLibrary.Handled()
	return UWidgetBlueprintLibrary.ReleaseMouseCapture(Handled)
end

local Handled = _G.UE.UWidgetBlueprintLibrary:Handled()
function CommGestureView:OnMouseWheel(InGeometry, InMouseEvent)
	local WheelDelta = UE.UKismetInputLibrary.PointerEvent_GetWheelDelta(InMouseEvent)

	if WheelDelta > 0 then
		self:OnZoomed(1.1)
	else
		self:OnZoomed(0.9)
	end

	return Handled
end

--function CommGestureView:OnMouseLeave(InMouseEvent)
--	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
--	self:RemoveTouchPosition(PointerIndex)
--end

function CommGestureView:OnMoved(Offset, ScreenPosition)
	if not self.bMoveEnable then
		return
	end
	--print("CommGestureView:OnMoved", Offset, self.OffsetX, self.OffsetY)

	local X = self.OffsetX + Offset.X
	local Y = self.OffsetY + Offset.Y
	--local MaxX = self.MaxMoveDistanceX
	--local MaxY = self.MaxMoveDistanceY
	--
	--if MaxX >= 0 then
	--	if X > 0 then
	--		X = math.min(X, MaxX)
	--	else
	--		X = math.max(X, -MaxX)
	--	end
	--end
	--
	--if MaxY >= 0 then
	--	if Y > 0 then
	--		Y = math.min(Y, MaxY)
	--	else
	--		Y = math.max(Y, -MaxY)
	--	end
	--end

	self.OffsetX = X
	self.OffsetY = Y

	self:AdjustOffset()

	self:OnPositionChanged(self.OffsetX, self.OffsetY, ScreenPosition)
end

function CommGestureView:OnZoomed(Scale)
	--print("CommGestureView:OnZoomed", Scale)

	local RenderScale = self.RenderScale

	Scale = RenderScale.X * Scale

	if Scale < self.MinRenderScale then
		Scale = self.MinRenderScale
	elseif Scale > self.MaxRenderScale then
		Scale = self.MaxRenderScale
	end

	RenderScale.X = Scale
	RenderScale.Y = Scale

	self:OnScaleChanged(RenderScale)

	self:AdjustOffset()

	-- self:OnPositionChanged(self.OffsetX, self.OffsetY)
end

function CommGestureView:AdjustOffset()
	if not self.bLockArea then
		return
	end

	local HalfWidth = (self.LockAreaMaxX - self.LockAreaMinX) * 0.5
	local HalfHeight = (self.LockAreaMaxY - self.LockAreaMinY) * 0.5

	local Scale = self.Scale
	-- 二级地图放大到最大时，移动地图到最下面，有些标记图标会消失，调试看是因为PanelMarker节点被移到屏幕外了。目前修改方法是限制下最大移动距离
	local TargetHalfWidth = self.TargetWidth * 0.5 * Scale - 20
	local TargetHalfHeight = self.TargetHeight * 0.5 * Scale - 20

	local MinOffset = MIN_OFFSET * Scale
	local MaxX = math.max(TargetHalfWidth - HalfWidth, MinOffset)
	local MaxY = math.max(TargetHalfHeight - HalfHeight, MinOffset)

	--print("[AdjustOffset] TargetHalfWidth, HalfWidth, MinOffset, MaxX", TargetHalfWidth, HalfWidth, MinOffset, MaxX)
	--print("[AdjustOffset] TargetHalfHeight, HalfHeight, MinOffset, MaxY", TargetHalfHeight, HalfHeight, MinOffset, MaxY)

	if CommonUtil.FloatIsEqual(Scale, self.MinRenderScale, 0.01) then
		if self.MinScaleLimitByX then
			MaxX = 0
		elseif self.MinScaleLimitByY then
			MaxY = 0
		end
	end

	self:ClampOffset(MaxX, MaxY)
end

function CommGestureView:Overscroll()
	if not self.bLockArea then
		return
	end

	local HalfWidth = (self.LockAreaMaxX - self.LockAreaMinX) * 0.5
	local HalfHeight = (self.LockAreaMaxY - self.LockAreaMinY) * 0.5

	local Scale = self.Scale
	local OverscrollRatio = self.OverscrollRatio
	local TargetHalfWidth = self.TargetWidth * 0.5 * Scale * OverscrollRatio
	local TargetHalfHeight = self.TargetHeight * 0.5 * Scale * OverscrollRatio

	local MaxX = math.max(TargetHalfWidth - HalfWidth, 0)
	local MaxY = math.max(TargetHalfHeight - HalfHeight, 0)

	self:ClampOffset(MaxX, MaxY)
end

function CommGestureView:ClampOffset(MaxX, MaxY)
	local OffsetX = self.OffsetX
	local OffsetY = self.OffsetY

	local X = math.clamp(OffsetX, -MaxX, MaxX)
	local Y = math.clamp(OffsetY, -MaxY, MaxY)

	if not CommonUtil.FloatIsEqual(OffsetX, X, 0.01) or not CommonUtil.FloatIsEqual(OffsetY, Y, 0.01) then
		self:OnPositionChanged(X, Y)
	end

	self.OffsetX = X
	self.OffsetY = Y
end

function CommGestureView:OnPositionChanged(X, Y, ScreenPosition)
	if nil ~= self.OnPositionChangedCallback then
		self.OnPositionChangedCallback(X, Y, ScreenPosition)
	else
		local Offsets = UIUtil.CanvasSlotGetOffsets(self.NamedSlotChild)
		Offsets.Left = X
		Offsets.Top = Y
		UIUtil.CanvasSlotSetOffsets(self.NamedSlotChild, Offsets)
	end
end

function CommGestureView:OnScaleChanged(Scale)
	if nil ~= self.OnScaleChangedCallback then
		self.OnScaleChangedCallback(Scale)
	else
		self.NamedSlotChild:SetRenderScale(Scale)
	end
end

function CommGestureView:SetOnPositionChangedCallback(Callback)
	self.OnPositionChangedCallback = Callback
end

function CommGestureView:SetOnScaleChangedCallback(Callback)
	self.OnScaleChangedCallback = Callback
end

function CommGestureView:SetOnClickedCallback(Callback)
	self.OnClickedCallback = Callback
end

function CommGestureView:SetOnPressCallback(Callback)
	self.OnPressCallback = Callback
end

return CommGestureView
