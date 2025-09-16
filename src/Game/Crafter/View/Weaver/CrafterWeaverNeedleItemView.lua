---
--- Author: Administrator
--- DateTime: 2023-12-15 10:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UKismetInputLibrary = UE.UKismetInputLibrary
local UEMath = UE.UKismetMathLibrary

---@class CrafterWeaverNeedleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNeedle UFImage
---@field NeedlePanel UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterWeaverNeedleItemView = LuaClass(UIView, true)

function CrafterWeaverNeedleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNeedle = nil
	--self.NeedlePanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterWeaverNeedleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterWeaverNeedleItemView:OnInit()

end

function CrafterWeaverNeedleItemView:OnDestroy()

end

function CrafterWeaverNeedleItemView:OnShow()

end

function CrafterWeaverNeedleItemView:OnHide()

end

function CrafterWeaverNeedleItemView:OnRegisterUIEvent()

end

function CrafterWeaverNeedleItemView:OnRegisterGameEvent()

end

function CrafterWeaverNeedleItemView:OnRegisterBinder()

end

function CrafterWeaverNeedleItemView:OnMouseButtonDown(InGeo, InMouseEvent)
	UIUtil.SetInputMode_UIOnly()

	self.IsMouseDown = true
	
	self.IsCheckingDrag = true
	self.IsDragDetected = false
	self.DragStartPos = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InMouseEvent)
end

function CrafterWeaverNeedleItemView:OnMouseButtonUp(InGeo, InMouseEvent)

	self:ClearDragState()

    self.IsMouseDown = false
	self.IsCheckingDrag = false
end

function CrafterWeaverNeedleItemView:OnMouseMove(InGeo, InMouseEvent)
	if not self.IsCheckingDrag then
        return
    end

	local AbsMousePos = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InMouseEvent)
    if UEMath.Distance2D(self.DragStartPos, AbsMousePos) >= 5 then
        self.IsCheckingDrag = false
        if UKismetInputLibrary.Key_IsValid(UKismetInputLibrary.PointerEvent_GetEffectingButton(InMouseEvent)) then
            self.DragOffset = _G.UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeo, AbsMousePos)
			return UE.UWidgetBlueprintLibrary.DetectDragIfPressed(InMouseEvent, self, UE.FKey("LeftMouseButton"))
		else
            self.IsCheckingDrag = true
            self.IsDragDetected = false
        end
    end
end

-- 检测到拖拽事件
function CrafterWeaverNeedleItemView:OnDragDetected(MyGeometry, PointerEvent, Operation)


    self.IsDragDetected = true
    self.IsMouseDown = false

	self.ParentView:ChangeDragState(true)

	Operation = _G.NewObject(_G.UE.UDragDropOperation, self, nil)
    Operation.DragOffset = self.DragOffset
    Operation.WidgetReference = self
    Operation.Pivot = _G.UE.EDragPivot.CenterCenter

	local DragVisual = _G.UIViewMgr:CreateView(_G.UIViewID.CrafterWeaverNeedleItem, self, true)
	DragVisual:ShowView()
    UIUtil.SetIsVisible(DragVisual, true)
	Operation.DefaultDragVisual = DragVisual

	return Operation
end

-- 拖拽取消
function CrafterWeaverNeedleItemView:OnDragCancelled(PointerEvent, Operation)
	self:ClearDragState()
end

-- 清理拖拽状态
function CrafterWeaverNeedleItemView:ClearDragState()
	UIUtil.SetInputMode_GameAndUI()
	self.ParentView:ChangeDragState(false)
end

function CrafterWeaverNeedleItemView:CancelDragEvent()
	UE.UWidgetBlueprintLibrary.CancelDragDrop()
end

return CrafterWeaverNeedleItemView