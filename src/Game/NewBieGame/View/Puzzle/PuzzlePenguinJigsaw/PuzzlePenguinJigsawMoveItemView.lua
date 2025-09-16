---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-12-26 11:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PuzzleMgr = require("Game/NewBieGame/Puzzle/PuzzleMgr")
local PuzzleDefine = require("Game/NewBieGame/Puzzle/PuzzleDefine")

local UE = _G.UE
local FLOG_INFO = _G.FLOG_INFO

local UKismetInputLibrary = UE.UKismetInputLibrary
---@class PuzzlePenguinJigsawMoveItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgPiece UFImage
---@field PanelMoveBread UFCanvasPanel
---@field AnimHighlight UWidgetAnimation
---@field AnimNormal UWidgetAnimation
---@field AnimPuzzleRestore UWidgetAnimation
---@field VarAnimOffsetX float
---@field VarAnimOffsetY float
---@field VarAnimOffsetRotation float
---@field VarAnimPlayPercent float
---@field VarAnimCurve CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PuzzlePenguinJigsawMoveItemView = LuaClass(UIView, true)

function PuzzlePenguinJigsawMoveItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgPiece = nil
    --self.PanelMoveBread = nil
    --self.AnimHighlight = nil
    --self.AnimNormal = nil
    --self.AnimPuzzleRestore = nil
    --self.VarAnimOffsetX = nil
    --self.VarAnimOffsetY = nil
    --self.VarAnimOffsetRotation = nil
    --self.VarAnimPlayPercent = nil
    --self.VarAnimCurve = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PuzzlePenguinJigsawMoveItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PuzzlePenguinJigsawMoveItemView:OnInit()
    self.ID = -1
    self.bNeedType = false
    self.FinishLocation = nil
    self.ConfirmRange = nil
    self.AssetPath = ""
    self.Angle = 0
    self.bIsDrag = false
    self.bFinish = false
    self.Size = nil
    self.PuzzleGameInst = nil
    self:EndHighLight()
end

function PuzzlePenguinJigsawMoveItemView:OnDestroy()
end

function PuzzlePenguinJigsawMoveItemView:OnShow()
    if (self.InitLocation == nil) then
        self.InitLocation = UIUtil.CanvasSlotGetPosition(self)
    end

    self:ResetToInitLocation()
end

function PuzzlePenguinJigsawMoveItemView:GetInitLocation()
    return self.InitLocation
end

function PuzzlePenguinJigsawMoveItemView:SetShowPos(TargetPos)
    if (TargetPos == nil) then
        return
    end
    UIUtil.CanvasSlotSetPosition(self, TargetPos)
end

function PuzzlePenguinJigsawMoveItemView:OnHide()
end

function PuzzlePenguinJigsawMoveItemView:OnRegisterUIEvent()
end

function PuzzlePenguinJigsawMoveItemView:OnRegisterGameEvent()
end

function PuzzlePenguinJigsawMoveItemView:OnRegisterBinder()
end

function PuzzlePenguinJigsawMoveItemView:GetID()
    return self.ID
end

function PuzzlePenguinJigsawMoveItemView:Initlize(Value)
    self.bFinish = false
    self.ID = Value.ID
    self.Index = Value.Index
    self.bNeedType = Value.bNeedType
    self.FinishLocation = Value.FinishLocation
    self.ConfirmRange = Value.ConfirmRange
    self.AssetPath = Value.AssetPath
    self.Angle = Value.Angle or 0
    self:UpdateIcon(Value.AssetPath)
    self.PuzzleGameInst = PuzzleMgr:GetGameInst()
end

function PuzzlePenguinJigsawMoveItemView:SetSize(NewSize)
end

function PuzzlePenguinJigsawMoveItemView:UpdateIcon(AssetPath)
    UIUtil.ImageSetMaterialTextureFromAssetPathSync(self.ImgPiece, AssetPath, "Texture")
end

function PuzzlePenguinJigsawMoveItemView:OnMouseButtonDown(InGeo, InMouseEvent)
    if self.PuzzleGameInst:GetbAutoPuzzleInEnd() then
        return false
    end

    if self.bFinish then
        return false
    end

    local AbsMousePos = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InMouseEvent)
    self.DragOffset = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeo, AbsMousePos)
    self.bIsDrag = true
    self.PuzzleGameInst:SetIsDraging(true)
    local SelectMoveBread = self.ParentView.SelectMoveBread
    if not SelectMoveBread or SelectMoveBread.ID ~= self.ID then
        self.ParentView:EndHelpTip()
        self.ParentView:ResetSelectBread()
        self.ParentView:UpdateSelectBread(self)
    end
    self.ParentView.bOpenClickDetect = true
    return true
end

function PuzzlePenguinJigsawMoveItemView:OnMouseMove(InGeo, InMouseEvent)
    if not self.bIsDrag or self.bFinish then
        return false
    end

    if self.PuzzleGameInst:GetbAutoPuzzleInEnd() then
        return false
    end

    return UE.UWidgetBlueprintLibrary.DetectDragIfPressed(InMouseEvent, self, UE.FKey("LeftMouseButton"))
end

function PuzzlePenguinJigsawMoveItemView:OnDragDetected(MyGeometry, PointerEvent, Operation)
    if (not PuzzleMgr:HasGameStarted()) then
        return
    end

    if (PuzzleMgr:bIsSuccess()) then
        return
    end

    if not self.bIsDrag or self.bFinish then
        return
    end

    if self.PuzzleGameInst:GetbAutoPuzzleInEnd() then
        return
    end
    PuzzleMgr:ResetNoRightOpTime()

    Operation = _G.NewObject(UE.UDragDropOperation, self, nil)
    Operation.DragOffset = self.DragOffset
    Operation.WidgetReference = self
    Operation.Pivot = UE.EDragPivot.CenterCenter

    local DragVisual = self.ParentView:GetDragVisualItem() -- _G.UIViewMgr:CreateView(_G.UIViewID.PuzzlePenguinJigsawMoveItemView, self, true)
    DragVisual:HighLightInstantly()
    DragVisual:UpdateIcon(self.AssetPath)
    DragVisual:SetRenderTransformAngle(self.Angle)
    DragVisual.ID = self.ID
    DragVisual:ShowView()
    UIUtil.SetIsVisible(DragVisual, true)
    Operation.DefaultDragVisual = DragVisual
    PuzzleMgr:SetMoveBreadVisible(self.Index, false)

    return Operation
end

---@param Operation MagicCardItemDragDropOperation
function PuzzlePenguinJigsawMoveItemView:OnDragCancelled(PointerEvent, Operation)
    if self.PuzzleGameInst:GetbAutoPuzzleInEnd() then
        return false
    end

    if (self.ParentView == nil) then
        return
    end

    local SelectMoveBread = self.ParentView.SelectMoveBread
    if SelectMoveBread and SelectMoveBread.ID == self.ID then
        self.ParentView:ResetSelectBread()
    end

    self.bIsDrag = false
    PuzzleMgr:SetMoveBreadVisible(self.Index, true)
    PuzzleMgr:ResetNoRightOpTime()
    self.bFinish = self:CheckIsRightLoc(PointerEvent, Operation)

    self.PuzzleGameInst:SetIsDraging(false)
    local bNotForceCancelDrag = true
    PuzzleMgr:ReCheckIsFinish(bNotForceCancelDrag)

    return true
end

---@param Operation MagicCardItemDragDropOperation
function PuzzlePenguinJigsawMoveItemView:OnDragEnter(MyGeometry, PointerEvent, Operation)
    if self.PuzzleGameInst:GetbAutoPuzzleInEnd() then
        return false
    end

    if Operation.DefaultDragVisual.ID == self.ID then
        PuzzleMgr:SetMoveBreadVisible(self.Index, false)
    end
end

function PuzzlePenguinJigsawMoveItemView:OnDragLeave(PointerEvent, Operation)
end

function PuzzlePenguinJigsawMoveItemView:ResetToInitLocation()
    if (self.InitLocation ~= nil) then
        UIUtil.CanvasSlotSetPosition(self, self.InitLocation)
    end
end

function PuzzlePenguinJigsawMoveItemView:CheckIsRightLoc(PointerEvent, Operation)
    if self.bNeedType == 0 then
        self:ResetToInitLocation()
        self.ParentView:OnCheckPuzzleItemFinish(false)
        return false
    end
    local Size = UIUtil.GetLocalSize(self)

    local bSuccess = false

    if (PuzzleMgr:GetIsTimeOut()) then
        local TouchPos = _G.UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(_G.FWORLD())
        local LocalPos = UIUtil.ViewportToLocal(self.ParentView.PanelDestination, TouchPos)
        local NeedLocalPos = UE.FVector2D(LocalPos.X - Size.X / 2, LocalPos.Y - Size.Y / 2)
        UIUtil.CanvasSlotSetPosition(self, NeedLocalPos)
        self:PlayAnimPuzzleRestore(self.InitLocation.X, self.InitLocation.Y, self.InitLocation.Z, false)
    else
        local TouchPos = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(PointerEvent)
        local LocalPos = UIUtil.AbsoluteToLocal(self.ParentView.PanelDestination, TouchPos)
        local NeedLocalPos = UE.FVector2D(LocalPos.X - Size.X / 2, LocalPos.Y - Size.Y / 2)
        if PuzzleMgr:bIsPuzzleRange(LocalPos) then
            local FinishLocation = self.FinishLocation
            local DistanceToRightLoc = UE.FVector.Dist2D(
                UE.FVector(NeedLocalPos.X, NeedLocalPos.Y, 0),
                UE.FVector(FinishLocation.X, FinishLocation.Y, 0)
            )
            if DistanceToRightLoc <= self.ConfirmRange then
                bSuccess = true
                UIUtil.CanvasSlotSetPosition(self, NeedLocalPos)
                local MoveToTargetOp = PuzzleDefine.MoveToTargetOp
                PuzzleMgr:OnMoveToTarget(self, bSuccess, MoveToTargetOp.ByDrag)
            else
                UIUtil.CanvasSlotSetPosition(self, NeedLocalPos)
                self:PlayAnimPuzzleRestore(self.InitLocation.X, self.InitLocation.Y, self.InitLocation.Z, false)
            end
        else
            UIUtil.CanvasSlotSetPosition(self, NeedLocalPos)
            self:PlayAnimPuzzleRestore(self.InitLocation.X, self.InitLocation.Y, self.InitLocation.Z, false)
        end
    end

    self.ParentView:OnCheckPuzzleItemFinish(bSuccess)

    return bSuccess
end

function PuzzlePenguinJigsawMoveItemView:BeginHighLight()
    if not self:IsAnimationPlaying(self.AnimHighlight) then
        self:PlayAnimation(self.AnimHighlight)
    end
end

function PuzzlePenguinJigsawMoveItemView:HighLightInstantly()
    if not self:IsAnimationPlaying(self.AnimHighlight) then
        self:PlayAnimation(self.AnimHighlight, 0.1)
    end
end

function PuzzlePenguinJigsawMoveItemView:EndHighLight()
    if not self:IsAnimationPlaying(self.AnimNormal) then
        self:PlayAnimation(self.AnimNormal)
    end
end

function PuzzlePenguinJigsawMoveItemView:GetIsNeedType()
    return self.bNeedType == 1
end

--- @type 获取AnimPuzzleRestore动画持续时间
function PuzzlePenguinJigsawMoveItemView:GetAnimPuzzleRestoreTime()
    return self.AnimPuzzleRestore:GetEndTime()
end

return PuzzlePenguinJigsawMoveItemView
