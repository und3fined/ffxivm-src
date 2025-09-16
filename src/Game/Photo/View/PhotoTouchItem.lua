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

---@class PhotoTouchItem : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Content UCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoTouchItem = LuaClass(UIView, true)

function PhotoTouchItem:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Content = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoTouchItem:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoTouchItem:OnInit()
	self.IsTouched = false
	self.TouchPos = UE.FVector2D(0, 0)
	self.IsMoving = false

	-- self.View = nil
	-- self.TouchStartCB = nil
	-- self.TouchMoveCB = nil
	-- self.TouchEndCB = nil
	-- self.CapCondFunc = nil
end

function PhotoTouchItem:OnDestroy()

end

function PhotoTouchItem:OnShow()

end

function PhotoTouchItem:OnHide()

end

function PhotoTouchItem:OnRegisterUIEvent()

end

function PhotoTouchItem:OnRegisterGameEvent()

end

function PhotoTouchItem:OnRegisterBinder()

end

function PhotoTouchItem:OnTouchStarted(InGeometry, InTouchEvent)
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
	
	self.IsTouched = true
	self.IsMoving = false
	self.TouchPos = LocalPosition
	-- _G.FLOG_INFO('Andre.PhotoTouchItem:OnTouchStarted X = ' .. tostring(self.TouchPos.X) .. " Y = " .. tostring(self.TouchPos.Y))
	
	if self.View and self.TouchStartCB then
		self.TouchStartCB(self.View, self.TouchPos)
	end
	
	local Handled = UWidgetBlueprintLibrary.Handled()
	return UWidgetBlueprintLibrary.CaptureMouse(Handled, self)
end

function PhotoTouchItem:OnTouchMoved(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	
	if not self:CheckPointIdx(PointerIndex) then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	if not self.IsTouched then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local ScreenSpacePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)
	-- _G.FLOG_INFO('Andre.PhotoTouchItem:OnTouchMoved X = ' .. tostring(self.TouchPos.X) .. " Y = " .. tostring(self.TouchPos.Y))
	self.TouchPos = LocalPosition
	self.IsMoving = true

	if self.View and self.TouchMoveCB then
		self.TouchMoveCB(self.View, self.TouchPos)
	end

	return UWidgetBlueprintLibrary.Handled()
end

function PhotoTouchItem:OnTouchEnded(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)

	if not self:CheckPointIdx(PointerIndex) then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	if not self.IsTouched or (not self.IsMoving) then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local ScreenSpacePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)
	-- _G.FLOG_INFO('Andre.PhotoTouchItem:OnTouchEnded X = ' .. tostring(self.TouchPos.X) .. " Y = " .. tostring(self.TouchPos.Y))

	self.TouchPos = LocalPosition
	self.IsMoving = false
	self.IsTouched = false

	if self.View and self.TouchEndCB then
		self.TouchEndCB(self.View, self.TouchPos)
	end

	--self:Overscroll()

	local Handled = UWidgetBlueprintLibrary.Handled()
	return UWidgetBlueprintLibrary.ReleaseMouseCapture(Handled)
end

function PhotoTouchItem:CheckPointIdx(PointIdx)
	if PointIdx == -99 then
		return false
	end
	return true
end

return PhotoTouchItem