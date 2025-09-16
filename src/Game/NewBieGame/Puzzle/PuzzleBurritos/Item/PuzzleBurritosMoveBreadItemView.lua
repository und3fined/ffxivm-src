---
--- Author: Administrator
--- DateTime: 2024-08-02 11:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PuzzleMgr = require("Game/NewBieGame/Puzzle/PuzzleMgr")
local PuzzleDefine = require("Game/NewBieGame/Puzzle/PuzzleDefine")
local AudioUtil = require("Utils/AudioUtil")
local AudioPath = PuzzleDefine.BurritoAudioPath
local UE = _G.UE
local FLOG_INFO = _G.FLOG_INFO

local UKismetInputLibrary = UE.UKismetInputLibrary
---@class PuzzleBurritosMoveBreadItemView : UIView
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
local PuzzleBurritosMoveBreadItemView = LuaClass(UIView, true)

function PuzzleBurritosMoveBreadItemView:Ctor()
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

function PuzzleBurritosMoveBreadItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PuzzleBurritosMoveBreadItemView:OnInit()
	self.ID = -1
	self.bNeedType = false
	self.InitLocation = nil
	self.FinishLocation = nil
	self.ConfirmRange = nil
	self.AssetPath = ""
	self.Angle = 0
	self.bIsDrag = false
	self.bFinish = false
	self.Size = nil
	self.PuzzleGameInst = nil
	
end

function PuzzleBurritosMoveBreadItemView:OnDestroy()

end

function PuzzleBurritosMoveBreadItemView:OnShow()

end

function PuzzleBurritosMoveBreadItemView:OnHide()

end

function PuzzleBurritosMoveBreadItemView:OnRegisterUIEvent()

end

function PuzzleBurritosMoveBreadItemView:OnRegisterGameEvent()

end

function PuzzleBurritosMoveBreadItemView:OnRegisterBinder()

end

function PuzzleBurritosMoveBreadItemView:GetID()
	return self.ID
end

function PuzzleBurritosMoveBreadItemView:Initlize(Value)
	self.bFinish = false
	self.ID = Value.ID
	self.bNeedType = Value.bNeedType
	self.InitLocation = Value.InitLocation
	self.FinishLocation = Value.FinishLocation
	self.ConfirmRange = Value.ConfirmRange
	self.AssetPath = Value.AssetPath
	self.Angle = Value.Angle
	self:UpdateIcon(Value.AssetPath)
	self.PuzzleGameInst = PuzzleMgr:GetGameInst()
end

function PuzzleBurritosMoveBreadItemView:SetSize(NewSize)
	self.Size = NewSize

	UIUtil.CanvasSlotSetSize(self, NewSize)
	UIUtil.CanvasSlotSetSize(self.PanelMoveBread, NewSize)
	UIUtil.CanvasSlotSetSize(self.ImgPiece, NewSize)

end

function PuzzleBurritosMoveBreadItemView:UpdateIcon(AssetPath)
	UIUtil.ImageSetMaterialTextureFromAssetPathSync(self.ImgPiece, AssetPath, "Texture")
end

function PuzzleBurritosMoveBreadItemView:OnMouseButtonDown(InGeo, InMouseEvent)
	if self.PuzzleGameInst == nil or self.PuzzleGameInst:GetbAutoPuzzleInEnd() then
		return false
	end
	FLOG_INFO("OnMouseButtonDown")

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
		self.ParentView:UpdateSelectBread(self.ID)
	end
	self.ParentView.bOpenClickDetect = true
	return true	
end

function PuzzleBurritosMoveBreadItemView:OnMouseButtonUp(InGeo, InMouseEvent)
	if self.PuzzleGameInst:GetbAutoPuzzleInEnd() then
		return false
	end
	FLOG_INFO("OnMouseButtonUp")
	self.bIsDrag = false
	self.PuzzleGameInst:SetIsDraging(false)
	PuzzleMgr:ReCheckIsFinish()   -- 倒计时要结束时候Check一下

	return true
end

function PuzzleBurritosMoveBreadItemView:OnMouseMove(InGeo, InMouseEvent)
	if not self.bIsDrag or self.bFinish then
		return false
	end

	if self.PuzzleGameInst:GetbAutoPuzzleInEnd() then
		return false
	end
	-- FLOG_INFO("OnMouseMove")

	return UE.UWidgetBlueprintLibrary.DetectDragIfPressed(InMouseEvent, self, UE.FKey("LeftMouseButton"))

end

function PuzzleBurritosMoveBreadItemView:OnDragDetected(MyGeometry, PointerEvent, Operation)
	if not self.bIsDrag or self.bFinish then
		return
	end

	if self.PuzzleGameInst:GetbAutoPuzzleInEnd() then
		return
	end
	PuzzleMgr:ResetNoRightOpTime()
	FLOG_INFO("OnDragDetected")

    Operation = _G.NewObject(UE.UDragDropOperation, self, nil)
    Operation.DragOffset = self.DragOffset
    Operation.WidgetReference = self
    Operation.Pivot = UE.EDragPivot.CenterCenter

	local DragVisual = _G.UIViewMgr:CreateView(_G.UIViewID.PuzzleBurritosMoveBreadView, self, true)
	DragVisual:HighLightInstantly()
	DragVisual:UpdateIcon(self.AssetPath)
	DragVisual:SetRenderTransformAngle(self.Angle)
	DragVisual:SetSize(self.Size)
	DragVisual.ID = self.ID
	DragVisual:ShowView()
    UIUtil.SetIsVisible(DragVisual, true)
    Operation.DefaultDragVisual = DragVisual

    return Operation
end

---@param Operation MagicCardItemDragDropOperation
function PuzzleBurritosMoveBreadItemView:OnDragCancelled(PointerEvent, Operation)
	if self.PuzzleGameInst:GetbAutoPuzzleInEnd() then
		return false
	end
	FLOG_INFO("OnDragCancelled")
	self.bIsDrag = false
	UIUtil.SetIsVisible(self.PanelMoveBread, true, true)
	PuzzleMgr:ResetNoRightOpTime()
	self.bFinish = self:CheckIsRightLoc(PointerEvent, Operation)

	self.PuzzleGameInst:SetIsDraging(false)
end

 ---@param Operation MagicCardItemDragDropOperation
function PuzzleBurritosMoveBreadItemView:OnDragEnter(MyGeometry, PointerEvent, Operation)
	if self.PuzzleGameInst:GetbAutoPuzzleInEnd() then
		return false
	end
	FLOG_INFO("OnDragEnter")
	if Operation.DefaultDragVisual.ID == self.ID then
		UIUtil.SetIsVisible(self.PanelMoveBread, false)
	end
end

function PuzzleBurritosMoveBreadItemView:OnDragLeave(PointerEvent, Operation)
	FLOG_INFO("OnDragLeave")
end

function PuzzleBurritosMoveBreadItemView:CheckIsRightLoc(PointerEvent, Operation)
	if self.bNeedType == 0 and not PuzzleMgr.bIsDebug then
		UIUtil.CanvasSlotSetPosition(self, self.InitLocation)
		self.ParentView:OnCheckPuzzleItemFinish(false)
		return false
	end
	local TouchPos = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(PointerEvent) --UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(_G.FWORLD())
	local Size = UIUtil.GetLocalSize(self)
	if PuzzleMgr.bIsDebug then						-- Debug模式
		local SetPos = UIUtil.AbsoluteToLocal(self.ParentView.PanelMoveBread, TouchPos)
		SetPos = UE.FVector2D(SetPos.X - Size.X / 2, SetPos.Y - Size.Y / 2)
		UIUtil.CanvasSlotSetPosition(self, SetPos)
		self.ParentView.PuzzleGM:UpdateSelectPuzzleItemData()
		return
	end
	local bSuccess = false
	FLOG_INFO("TouchPos.X = %s  TouchPos.Y = %s", TouchPos.X, TouchPos.Y)
	local LocalPos = UIUtil.AbsoluteToLocal(self.ParentView.PanelYesBread, TouchPos)
	FLOG_INFO("LocalPos.X = %s  LocalPos.Y = %s", LocalPos.X, LocalPos.Y)

	local NeedLocalPos = UE.FVector2D(LocalPos.X - Size.X / 2, LocalPos.Y - Size.Y / 2)
	FLOG_INFO("NeedLocalPos.X = %s  NeedLocalPos.Y = %s", NeedLocalPos.X, NeedLocalPos.Y)
	FLOG_INFO("FinishLocation.X = %s  FinishLocation.Y = %s", self.FinishLocation.X, self.FinishLocation.Y)

	if PuzzleMgr:bIsPuzzleRange(NeedLocalPos) then
		local FinishLocation = self.FinishLocation
		local DistanceToRightLoc = UE.FVector.Dist2D(UE.FVector(NeedLocalPos.X, NeedLocalPos.Y, 0), UE.FVector(FinishLocation.X, FinishLocation.Y, 0))
		if DistanceToRightLoc <= self.ConfirmRange then
			bSuccess = true
			UIUtil.CanvasSlotSetPosition(self, NeedLocalPos)
			UIUtil.SetIsVisible(self.PanelMoveBread, true, true)
			-- local Offset = UE.FVector2D(FinishLocation.X - NeedLocalPos.X, FinishLocation.Y - NeedLocalPos.Y)
			local MoveToTargetOp = PuzzleDefine.MoveToTargetOp			
			PuzzleMgr:OnMoveToTarget(self, bSuccess, MoveToTargetOp.ByDrag)
		else
			UIUtil.SetIsVisible(self, true)
			PuzzleMgr:ReCheckIsFinish()
		end
		self.ParentView:OnCheckPuzzleItemFinish(bSuccess)
	else
		PuzzleMgr:ReCheckIsFinish()
	end
	
	return bSuccess
end

function PuzzleBurritosMoveBreadItemView:BeginHighLight()
	if not self:IsAnimationPlaying(self.AnimHighlight) then
		self:PlayAnimation(self.AnimHighlight)
	end
end

function PuzzleBurritosMoveBreadItemView:HighLightInstantly()
	if not self:IsAnimationPlaying(self.AnimHighlight) then
		self:PlayAnimation(self.AnimHighlight, 0.1)
	end
end

function PuzzleBurritosMoveBreadItemView:EndHighLight()
	if not self:IsAnimationPlaying(self.AnimNormal) then
		self:PlayAnimation(self.AnimNormal)
	end
end

function PuzzleBurritosMoveBreadItemView:GetIsNeedType()
	return self.bNeedType == 1
end

--- @type 获取AnimPuzzleRestore动画持续时间
function PuzzleBurritosMoveBreadItemView:GetAnimPuzzleRestoreTime()
	return self.AnimPuzzleRestore:GetEndTime()
end

return PuzzleBurritosMoveBreadItemView