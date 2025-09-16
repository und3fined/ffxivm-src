---
--- Author: eddardchen
--- DateTime: 2021-05-10 14:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = _G.EventID
local UWidgetBlueprintLibrary = UE.UWidgetBlueprintLibrary

---@class MainUIMoveControlView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn_Cancel UFButton
---@field Btn_Cancel_1 UFButton
---@field Btn_OK UFButton
---@field Btn_OK_1 UFButton
---@field CenterPanel UCanvasPanel
---@field Img_MoveBkg UFImage
---@field MovePanel_Down UCanvasPanel
---@field MovePanel_Up UCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainUIMoveControlView = LuaClass(UIView, true)

function MainUIMoveControlView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.Btn_Cancel = nil
	self.Btn_Cancel_1 = nil
	self.Btn_OK = nil
	self.Btn_OK_1 = nil
	self.CenterPanel = nil
	self.Img_MoveBkg = nil
	self.MovePanel_Down = nil
	self.MovePanel_Up = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainUIMoveControlView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainUIMoveControlView:OnInit()
	
end

function MainUIMoveControlView:OnDestroy()

end

function MainUIMoveControlView:OnShow()
end

function MainUIMoveControlView:OnHide()

end

function MainUIMoveControlView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn_OK, self.OnBtnOKClick)
	UIUtil.AddOnClickedEvent(self, self.Btn_Cancel, self.OnBtnCancelClick)
	UIUtil.AddOnClickedEvent(self, self.Btn_OK_1, self.OnBtnOKClick)
	UIUtil.AddOnClickedEvent(self, self.Btn_Cancel_1, self.OnBtnCancelClick)
end

function MainUIMoveControlView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.WidgetDragMove, self.OnWidgetDragMove)
end

function MainUIMoveControlView:OnRegisterTimer()

end

function MainUIMoveControlView:OnRegisterBinder()

end

function MainUIMoveControlView:print(s)
	_G.UE.UKismetSystemLibrary.PrintString(self, tostring(s), true, false, _G.UE.FLinearColor(1, 1, 1, 1), 10)
end

--根据不同Widget调整BG的Size和Button的position
function MainUIMoveControlView:AdjustViewSizeAndPos(MoveBgSize)
	if (MoveBgSize == nil) then
		return
	end
	local OriginMoveBgSize = UIUtil.CanvasSlotGetSize(self.Img_MoveBkg)
	if (OriginMoveBgSize == nil) then
		return
	end
	MoveBgSize.Y = OriginMoveBgSize.Y --这个背景高度是自动的
	UIUtil.CanvasSlotSetSize(self.Img_MoveBkg, MoveBgSize)

	local OffsetX = MoveBgSize.X - OriginMoveBgSize.X
	local function AdjustBtnPos(BtnWidget, OffsetX)
		if (BtnWidget ~= nil) then
			local OriginPos = UIUtil.CanvasSlotGetPosition(BtnWidget)
			local NewPos = _G.UE.FVector2D(OriginPos.X + OffsetX, OriginPos.Y)
			UIUtil.CanvasSlotSetPosition(BtnWidget, NewPos)
		end
	end

	AdjustBtnPos(self.Btn_OK, OffsetX)
	AdjustBtnPos(self.Btn_OK_1, OffsetX)
end

function MainUIMoveControlView:EnableView(MoveBgSize)
	self:SetRenderOpacity(1.0)
	self:AdjustViewSizeAndPos(MoveBgSize)
end

function MainUIMoveControlView:OnBtnOKClick()
	if nil == self.ParentWidget then return end

	EventMgr:SendEvent(EventID.WidgetDragConfirm, self.ParentWidget)
end

function MainUIMoveControlView:OnBtnCancelClick()
	if nil == self.ParentWidget then return end

	EventMgr:SendEvent(EventID.WidgetDragCancel, self.ParentWidget)
end

function MainUIMoveControlView:OnTouchStarted(MyGeometry, InTouchEvent)
	-- self:print("on touch start")

	if nil == self.ParentWidget then return UWidgetBlueprintLibrary.Unhandled() end

	local mousePos = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	EventMgr:SendEvent(EventID.WidgetDragStart, self.ParentWidget, mousePos.X, mousePos.Y)

	return UWidgetBlueprintLibrary.CaptureMouse(UWidgetBlueprintLibrary.Handled(), self)
end

function MainUIMoveControlView:OnTouchMoved(MyGeometry, InTouchEvent)
	-- self:print("on touch move")

	if nil == self.ParentWidget then return UWidgetBlueprintLibrary.Unhandled() end

	local mousePos = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	EventMgr:SendEvent(EventID.WidgetDragMove, self.ParentWidget, mousePos.X, mousePos.Y)

	if self:GetRenderOpacity() > 0.0 then
		return UWidgetBlueprintLibrary.Handled()
	else
		return UWidgetBlueprintLibrary.Unhandled()
	end
end

function MainUIMoveControlView:OnTouchEnded(MyGeometry, InTouchEvent)
	if nil == self.ParentWidget then return UWidgetBlueprintLibrary.Unhandled() end

	EventMgr:SendEvent(EventID.WidgetDragEnd, self.ParentWidget)

	return UWidgetBlueprintLibrary.Handled()
end

function MainUIMoveControlView:OnWidgetDragMove()
	if self:GetRenderOpacity() > 0.0 then
		local Pos = UIUtil.WidgetLocalToViewport(self.CenterPanel, 0, 0)

		-- self:print("update: " .. tostring(Pos))

		local MagicNumber = 350
		if Pos.Y < MagicNumber then
			self:UpdateButtonPos(true)
		else
			self:UpdateButtonPos(false)
		end

		if nil ~= self.ParentWidget and nil ~= self.OnDragMoveCallback then
			self.OnDragMoveCallback(self.ParentWidget, Pos)
		end
	end
end

function MainUIMoveControlView:SetParentWidget(InParentWidget)
	self.ParentWidget = InParentWidget
end

function MainUIMoveControlView:SetDragMoveCallback(InDragMoveCallback)
	self.OnDragMoveCallback = InDragMoveCallback
end

function MainUIMoveControlView:OnMouseLeave(MouseEvent)
	if nil == self.ParentWidget then return end

	EventMgr:SendEvent(EventID.WidgetDragEnd, self.ParentWidget)
end

function MainUIMoveControlView:UpdateButtonPos(bDown)
	if bDown then
		UIUtil.SetIsVisible(self.Btn_Cancel, true, true)
		UIUtil.SetIsVisible(self.Btn_OK, true, true)
		UIUtil.SetIsVisible(self.Btn_Cancel_1, false)
		UIUtil.SetIsVisible(self.Btn_OK_1, false)
	else
		UIUtil.SetIsVisible(self.Btn_Cancel_1, true, true)
		UIUtil.SetIsVisible(self.Btn_OK_1, true, true)
		UIUtil.SetIsVisible(self.Btn_Cancel, false)
		UIUtil.SetIsVisible(self.Btn_OK, false)
	end
end

return MainUIMoveControlView