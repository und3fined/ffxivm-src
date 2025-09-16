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

---@class CommStickTouchItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Content UCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommStickTouchItemView = LuaClass(UIView, true)

function CommStickTouchItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Content = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommStickTouchItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommStickTouchItemView:OnInit()
	self.IsTouched = false
	self.TouchPos = UE.FVector2D(0, 0)
	self.IsMoving = false

	-- self.View = nil
	-- self.TouchStartCB = nil
	-- self.TouchMoveCB = nil
	-- self.TouchEndCB = nil
	-- self.CapCondFunc = nil
end

function CommStickTouchItemView:OnDestroy()

end

function CommStickTouchItemView:OnShow()

end

function CommStickTouchItemView:OnHide()

end

function CommStickTouchItemView:OnRegisterUIEvent()

end

function CommStickTouchItemView:OnRegisterGameEvent()

end

function CommStickTouchItemView:OnRegisterBinder()

end

function CommStickTouchItemView:OnTouchStarted(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)

	if not self:CheckPointIdx(PointerIndex) then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local ScreenSpacePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)

	if self.CapCondFunc then
		if not self.CapCondFunc(self.View, LocalPosition) then
			-- print('p1')
			return UWidgetBlueprintLibrary.UnHandled()
		end
	end
	
	self.IsTouched = true
	self.IsMoving = false
	self.TouchPos = LocalPosition
	-- _G.FLOG_INFO('Andre.CommStickTouchItemView:OnTouchStarted X = ' .. tostring(self.TouchPos.X) .. " Y = " .. tostring(self.TouchPos.Y))
	
	if self.View and self.TouchStartCB then
		self.TouchStartCB(self.View, self.TouchPos)
	end
	
	local Handled = UWidgetBlueprintLibrary.Handled()
	return UWidgetBlueprintLibrary.CaptureMouse(Handled, self)
end

function CommStickTouchItemView:OnTouchMoved(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	
	if not self:CheckPointIdx(PointerIndex) then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	if not self.IsTouched then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local ScreenSpacePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)
	-- _G.FLOG_INFO('Andre.CommStickTouchItemView:OnTouchMoved X = ' .. tostring(self.TouchPos.X) .. " Y = " .. tostring(self.TouchPos.Y))
	self.TouchPos = LocalPosition
	self.IsMoving = true

	if self.View and self.TouchMoveCB then
		self.TouchMoveCB(self.View, self.TouchPos)
	end

	return UWidgetBlueprintLibrary.Handled()
end

function CommStickTouchItemView:OnTouchEnded(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)

	if not self:CheckPointIdx(PointerIndex) then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	if not self.IsTouched then--or (not self.IsMoving) then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local ScreenSpacePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)
	-- _G.FLOG_INFO('Andre.CommStickTouchItemView:OnTouchEnded X = ' .. tostring(self.TouchPos.X) .. " Y = " .. tostring(self.TouchPos.Y))

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

function CommStickTouchItemView:CheckPointIdx(PointIdx)
	if PointIdx == -99 then
		return false
	end
	return true
end



return CommStickTouchItemView