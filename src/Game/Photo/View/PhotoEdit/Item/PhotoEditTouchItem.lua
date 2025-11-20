---
--- Author: Administrator
--- DateTime: 2024-01-30 19:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UE = _G.UE
local UWidgetBlueprintLibrary = UE.UWidgetBlueprintLibrary

---@class PhotoEditTouchItem : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Content UCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoEditTouchItem = LuaClass(UIView, true)

function PhotoEditTouchItem:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Content = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoEditTouchItem:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoEditTouchItem:OnInit()
    self:ResetTouchData()
	-- self.View = nil
	-- self.TouchStartCB = nil
	-- self.TouchMoveCB = nil
	-- self.TouchEndCB = nil
	-- self.CapCondFunc = nil
	-- self.ScaleChangedCallback = nil
end

function PhotoEditTouchItem:OnDestroy()

end

function PhotoEditTouchItem:OnShow()
	self:SetRenderScale()
end

function PhotoEditTouchItem:OnHide()

end

function PhotoEditTouchItem:OnRegisterUIEvent()

end

function PhotoEditTouchItem:OnRegisterGameEvent()

end

function PhotoEditTouchItem:OnRegisterBinder()

end

function PhotoEditTouchItem:OnTouchStarted(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)

	if not self:CheckPointIdx(PointerIndex) then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local ScreenSpacePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)

	if self.CapCondFunc then
		if not self.CapCondFunc(self.View, LocalPosition) then
			return UWidgetBlueprintLibrary.UnHandled()
		end
	end

	local TouchInfo = self:GetTouchInfo(PointerIndex)
	if not TouchInfo then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	self.IsTouched = true
	self.IsMoving = false

	TouchInfo.IsTouched = true
	TouchInfo.TouchPosition = ScreenSpacePosition

	if self.View and self.TouchStartCB then
		self.TouchStartCB(self.View, LocalPosition)
	end

	local AnotherTouchInfo = self:GetAnotherTouchInfo(PointerIndex)
	if nil ~= AnotherTouchInfo and AnotherTouchInfo.IsTouched then
		local Scale = UIUtil.GetViewportScale()
		self.m_ZoomDistance = UE.UKismetMathLibrary.Distance2D(ScreenSpacePosition, AnotherTouchInfo.TouchPosition) / Scale
	end

	local Handled = UWidgetBlueprintLibrary.Handled()
	return UWidgetBlueprintLibrary.CaptureMouse(Handled, self)
end

function PhotoEditTouchItem:OnTouchMoved(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	if not self:CheckPointIdx(PointerIndex) then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	if not self.IsTouched then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local TouchInfo = self:GetTouchInfo(PointerIndex)
	if not TouchInfo then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local Count = self:GetTouchCount()
	if Count <= 0 then
		TouchInfo.IsTouched = true
	end

	local ScreenSpacePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)

	if Count == 1 then
		local LastPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, TouchInfo.TouchPosition)
		local Offset = LocalPosition - LastPosition
		if math.abs(Offset.X) > 1 or math.abs(Offset.Y) > 1 then
			if self.View and self.TouchMoveCB then
				self.TouchMoveCB(self.View, LocalPosition, Offset)
				self.IsMoving = true
			end
		end
	elseif Count == 2 then
		local AnotherTouchInfo = self:GetAnotherTouchInfo(PointerIndex)
		local Scale = UIUtil.GetViewportScale()
		local Distance = UE.UKismetMathLibrary.Distance2D(ScreenSpacePosition, AnotherTouchInfo.TouchPosition) / Scale
		local ScrMidPointX = (ScreenSpacePosition.X + AnotherTouchInfo.TouchPosition.X) * 0.5
		local ScrMidPointY = (ScreenSpacePosition.Y + AnotherTouchInfo.TouchPosition.Y) * 0.5
		self:OnZoomed(Distance / self.m_ZoomDistance, UE.FVector2D(ScrMidPointX, ScrMidPointY))
		self.m_ZoomDistance = Distance
		self.IsMoving = true
	end

	TouchInfo.TouchPosition = ScreenSpacePosition

	return UWidgetBlueprintLibrary.Handled()
end

function PhotoEditTouchItem:OnTouchEnded(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)

	if not self:CheckPointIdx(PointerIndex) then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	if not self.IsTouched or (not self.IsMoving) then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local ScreenSpacePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)

	if self.View and self.TouchEndCB then
		self.TouchEndCB(self.View, LocalPosition)
	end

    self:ResetTouchData()

	local Handled = UWidgetBlueprintLibrary.Handled()
	return UWidgetBlueprintLibrary.ReleaseMouseCapture(Handled)
end

local Handled = _G.UE.UWidgetBlueprintLibrary:Handled()
function PhotoEditTouchItem:OnMouseWheel(InGeometry, InMouseEvent)
	local WheelDelta = UE.UKismetInputLibrary.PointerEvent_GetWheelDelta(InMouseEvent)
	local ScreenPosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InMouseEvent)
	if WheelDelta > 0 then
		self:OnZoomed(1.1, ScreenPosition)
	else
		self:OnZoomed(0.9, ScreenPosition)
	end

	return Handled
end

function PhotoEditTouchItem:OnZoomed(Scale, ScreenPosition)
	if nil ~= self.ScaleChangedCallback then
		self.ScaleChangedCallback(self.View, Scale, ScreenPosition)
	end
end

function PhotoEditTouchItem:CheckPointIdx(PointIdx)
	if PointIdx == -99 then
		return false
	end
	return true
end

function PhotoEditTouchItem:GetTouchCount()
	local Count = 0
	for i = 1, #self.TrackedTouches do
		if self.TrackedTouches[i].IsTouched then
			Count = Count + 1
		end
	end
	return Count
end

function PhotoEditTouchItem:GetTouchInfo(PointerIndex)
	return self.TrackedTouches[PointerIndex + 1]
end

function PhotoEditTouchItem:GetAnotherTouchInfo(PointerIndex)
	for i = 1, #self.TrackedTouches do
		if i ~= PointerIndex + 1 then
			return self.TrackedTouches[i]
		end
	end
end

function PhotoEditTouchItem:SetRenderScale(RenderScale)
	self.RenderScale = RenderScale or UE.FVector2D(1, 1)
end

function PhotoEditTouchItem:ResetTouchData()
	self.IsMoving = false
	self.IsTouched = false
    self.IsLongClicked = false
    self.InitialDistance = nil
	self.TrackedTouches = {
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

return PhotoEditTouchItem