---
--- Author: Administrator
--- DateTime: 2025-06-27 17:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PhotoUtil = require("Game/Photo/PhotoUtil")
local PhotoDefine = require("Game/Photo/PhotoDefine")

local FVector2D = _G.UE.FVector2D
local LOG = FLOG_INFO
local SetMTScalarParam = UIUtil.ImageSetMaterialScalarParameterValue
local IsUnderLocation = UIUtil.IsUnderLocation

local PhotoResizeCorner ={
    None = 1,
	LeftTop = 2,      -- 左上角
    RightTop = 3,     -- 右上角
    LeftBottom = 4,   -- 左下角
    RightBottom = 5,  -- 右下角
};

local function SetCropDataValues(Data, StartX, StartY, Width, Height, CenterX, CenterY)
	Data.StartX = StartX
	Data.StartY = StartY
	Data.EndX = StartX + Width
	Data.EndY = StartY + Height
	Data.CropWidth = Width
	Data.CropHeight = Height
	Data.CenterX = CenterX
	Data.CenterY = CenterY
end

local function RangeRatioLimit(ResizeCornerType, AspectRatio, Width, Height, NewTopLeft, NewBottomRight)
	if math.abs(Width/Height) > AspectRatio then
		-- 宽度过大 → 高度主导
		Width =  Height * AspectRatio
	else
		-- 高度过大 → 宽度主导
		Height = Width / AspectRatio
	end
	-- 应用新大小
	if ResizeCornerType == PhotoResizeCorner.LeftTop then
		NewTopLeft.X = NewBottomRight.X - Width
		NewTopLeft.Y = NewBottomRight.Y - Height
	elseif ResizeCornerType == PhotoResizeCorner.RightTop then
		NewTopLeft.Y = NewBottomRight.Y - Height
		NewBottomRight.X = NewTopLeft.X + Width
	elseif ResizeCornerType == PhotoResizeCorner.LeftBottom then
		NewTopLeft.X = NewBottomRight.X - Width
        NewBottomRight.Y = NewTopLeft.Y + Height
	elseif ResizeCornerType == PhotoResizeCorner.RightBottom then
		NewBottomRight.X = NewTopLeft.X + Width
		NewBottomRight.Y = NewTopLeft.Y + Height
	end
	return NewTopLeft, NewBottomRight
end

---@class PhotoEditCropContentView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBL UFButton
---@field BtnBR UFButton
---@field BtnTL UFButton
---@field BtnTR UFButton
---@field CanvasPanel_Root UFCanvasPanel
---@field EditTouchItem PhotoEditTouchItemView
---@field ImgPic UFImage
---@field ImgPic_Mask UFImage
---@field LineCanvasPanel UFCanvasPanel
---@field PanelFrame UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoEditCropContentView = LuaClass(UIView, true)

function PhotoEditCropContentView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBL = nil
	--self.BtnBR = nil
	--self.BtnTL = nil
	--self.BtnTR = nil
	--self.CanvasPanel_Root = nil
	--self.EditTouchItem = nil
	--self.ImgPic = nil
	--self.ImgPic_Mask = nil
	--self.LineCanvasPanel = nil
	--self.PanelFrame = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoEditCropContentView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EditTouchItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoEditCropContentView:OnInit()

end

function PhotoEditCropContentView:OnDestroy()

end

function PhotoEditCropContentView:OnShow()
	self:InitTouchItem()
	self:InitCropTexture()
	self:InitFrameSize()
end

function PhotoEditCropContentView:OnHide()

end

function PhotoEditCropContentView:OnRegisterUIEvent()

end

function PhotoEditCropContentView:OnRegisterGameEvent()

end

function PhotoEditCropContentView:OnRegisterBinder()

end

function PhotoEditCropContentView:CheckParamValid()
	if self.Params.SourceTex and self.Params.SourceW and self.Params.SourceH then
		return true
	end
	return false
end

function PhotoEditCropContentView:InitTouchItem()
	self.EditTouchItem.View = self
	--self.EditTouchItem.CapCondFunc = self.CapCondCheck
	self.EditTouchItem.TouchStartCB = self.OnTouchStart
	self.EditTouchItem.TouchMoveCB = self.OnTouchMove
	self.EditTouchItem.TouchEndCB = self.OnTouchEnd
	--self.EditTouchItem.OnScaleChangedCallback = self.OnScaleChanged
end

function PhotoEditCropContentView:InitCropTexture()
	local IsValid = self:CheckParamValid()
	UIUtil.SetIsVisible(self, IsValid)
	if not IsValid then
		return
	end

	UIUtil.ImageSetBrushResourceObject(self.ImgPic, self.Params.SourceTex, true)
	UIUtil.CanvasSlotSetSize(self.ImgPic, FVector2D(self.Params.SourceW, self.Params.SourceH))
	UIUtil.CanvasSlotSetSize(self.ImgPic_Mask, FVector2D(self.Params.SourceW, self.Params.SourceH))
	self.CropType = _G.PhotoMgr.EditCropType
	LOG("[PhotoEdit][PhotoEditCropContentView:InitCropTexture] W=%f, H=%f", self.Params.SourceW, self.Params.SourceH)
	self:SetRangeMaskValue(0.5, 0.5, 1, 1)
end

function PhotoEditCropContentView:InitFrameSize()
	local FrameSizeX, FrameSizeY = self.Params.SourceW, self.Params.SourceH
	local CropData = PhotoUtil.GetCropDataByCropType(self.CropType)
	if not table.is_nil_empty(CropData) then
		self.AspectRatio = CropData.AspectRatioWidth / CropData.AspectRatioHeight
		self.CropRangeData = PhotoUtil.GetCropRangeDataByAspectRatio(FrameSizeX, FrameSizeY, self.AspectRatio )
		if not table.is_nil_empty(self.CropRangeData) then
			FrameSizeX = self.CropRangeData.CropWidth
			FrameSizeY = self.CropRangeData.CropHeight
		end
	end
	UIUtil.SetIsVisible(self.PanelFrame, false)
	self:RegisterTimer(function ()
		UIUtil.CanvasSlotSetPosition(self.PanelFrame, FVector2D(0, 0))
		UIUtil.CanvasSlotSetSize(self.PanelFrame, FVector2D(FrameSizeX, FrameSizeY))
		UIUtil.SetIsVisible(self.PanelFrame, true)
		self:UpdateCropMaskRange()
	end, 0.01, 0, 1)
end

function PhotoEditCropContentView:IsWithinRange(LocalPos)
	if LocalPos.X >= self.CropRangeData.StartX and LocalPos.X <= self.CropRangeData.EndX and
		LocalPos.Y >= self.CropRangeData.StartY and LocalPos.Y <= self.CropRangeData.EndY then
		return true
	end
end

function PhotoEditCropContentView:GetResizeCornerType(ScreenPosition)
	if IsUnderLocation(self.BtnTL, ScreenPosition) then
		return PhotoResizeCorner.LeftTop
	elseif IsUnderLocation(self.BtnTR, ScreenPosition) then
		return PhotoResizeCorner.RightTop
	elseif IsUnderLocation(self.BtnBL, ScreenPosition) then
		return PhotoResizeCorner.LeftBottom
	elseif IsUnderLocation(self.BtnBR, ScreenPosition) then
		return PhotoResizeCorner.RightBottom
	else
		return PhotoResizeCorner.None
	end
end

function PhotoEditCropContentView:CapCondCheck(LocalPosition)
	local ScreenPosition = UIUtil.LocalToAbsolute(self.EditTouchItem, LocalPosition)
	self.ResizeCornerType = self:GetResizeCornerType(ScreenPosition)
	return self.ResizeCornerType ~= PhotoResizeCorner.None
end

function PhotoEditCropContentView:OnTouchStart(Pos)
	local ScreenPosition = UIUtil.LocalToAbsolute(self.EditTouchItem, Pos)
	local LocalPos = UIUtil.AbsoluteToLocal(self.ImgPic, ScreenPosition)
	if not table.is_nil_empty(self.CropRangeData) then
		self.ResizeCornerType = self:GetResizeCornerType(ScreenPosition)
		if self.ResizeCornerType ~= PhotoResizeCorner.None then
			self.IsSelectedRangeZoom = true
			self.StartTouchPos = LocalPos
		elseif self:IsWithinRange(LocalPos) then
			self.IsDragging = true
			self.TouchStartPos = LocalPos
			self.DragOffset = {X = LocalPos.X - self.CropRangeData.StartX, Y = LocalPos.Y - self.CropRangeData.StartY}
		-- else
		-- 	local ImgeTLPos = UIUtil.GetWidgetAbsolutePosition(self.ImgPic)
		-- 	self.StartImageMouseOffsetPosX = ScreenPosition.X - ImgeTLPos.X
		-- 	self.StartImageMouseOffsetPosY = ScreenPosition.Y - ImgeTLPos.Y
		end
	end
end

function PhotoEditCropContentView:OnTouchMove(Pos)
	local ScreenPosition = UIUtil.LocalToAbsolute(self.EditTouchItem, Pos)
	local LocalPos = UIUtil.AbsoluteToLocal(self.ImgPic_Mask, ScreenPosition)
	if self.IsSelectedRangeZoom then
		self:UpdateSelectedRange(LocalPos, true)
	elseif self.IsDragging then
		self:DraggingSelectedRange(LocalPos)
	-- else
	-- 	local OffsetX = ScreenPosition.X - self.StartImageMouseOffsetPosX
	-- 	local OffsetY = ScreenPosition.Y - self.StartImageMouseOffsetPosY
	-- 	self:LimitSourceImageTransform(FVector2D(OffsetX, OffsetY))
		-- local LastPos = UIUtil.CanvasSlotGetPosition(self.ImgPic)
		-- UIUtil.CanvasSlotSetPosition(self.ImgPic, FVector2D(LastPos.X + Offset.X, LastPos.Y + Offset.Y))
	end
end

function PhotoEditCropContentView:OnTouchEnd(Pos)
	self.IsSelectedRangeZoom = false
	self.IsDragging = false
	self.TouchStartPos = nil
	self.DragOffset = nil
	self.ResizeCornerType = nil
end

function PhotoEditCropContentView:OnScaleChanged(Scale)
	self.ImgPic:SetRenderScale(Scale)
	local ImgSize = UIUtil.GetLocalSize(self.ImgPic)
	local AbsoluteSize = UIUtil.GetAbsoluteSize(self.ImgPic)
	LOG("ImgSize.X = %f, ImgSize.Y=%f", ImgSize.X, ImgSize.Y)
	LOG("ImgSize.AbsoluteSizeX = %f, ImgSize.AbsoluteSizeY=%f", AbsoluteSize.X, AbsoluteSize.Y)
end

function PhotoEditCropContentView:UpdateSelectedRange(LocalPos, IsRatioLimit)
	local NewTopLeft = FVector2D(self.CropRangeData.StartX, self.CropRangeData.StartY)
	local NewBottomRight = FVector2D(self.CropRangeData.EndX, self.CropRangeData.EndY)
	local RootSize = UIUtil.GetLocalSize(self.ImgPic_Mask)
	LocalPos.X = math.clamp(LocalPos.X, 0, RootSize.X)
	LocalPos.Y = math.clamp(LocalPos.Y, 0, RootSize.Y)
	if self.ResizeCornerType == PhotoResizeCorner.LeftTop then
		NewTopLeft = LocalPos
		-- 超界反推
		-- if NewTopLeft.X < 0 then
		-- 	NewTopLeft.X = 0
		-- 	NewBottomRight.X = LocalPos
		-- end
	elseif self.ResizeCornerType == PhotoResizeCorner.RightTop then
		NewTopLeft.Y = LocalPos.Y
		NewBottomRight.X = LocalPos.X
	elseif self.ResizeCornerType == PhotoResizeCorner.LeftBottom then
		NewTopLeft.X = LocalPos.X
        NewBottomRight.Y = LocalPos.Y
	elseif self.ResizeCornerType == PhotoResizeCorner.RightBottom then
		NewBottomRight = LocalPos
	end

	LOG("NewTopLeftX=%f, NewTopLeftY=%f",NewTopLeft.X, NewTopLeft.Y)
	local BoxSizeX = math.abs(NewBottomRight.X - NewTopLeft.X)
	local BoxSizeY = math.abs(NewBottomRight.Y - NewTopLeft.Y)

	if IsRatioLimit and self.AspectRatio then
		NewTopLeft, NewBottomRight = RangeRatioLimit(self.ResizeCornerType, self.AspectRatio, BoxSizeX, BoxSizeY, NewTopLeft, NewBottomRight)
	end

	BoxSizeX = NewBottomRight.X - NewTopLeft.X
	BoxSizeY = NewBottomRight.Y - NewTopLeft.Y

	local CenterX = NewTopLeft.X + BoxSizeX * 0.5
	local CenterY = NewTopLeft.Y + BoxSizeY * 0.5
	SetCropDataValues(self.CropRangeData, NewTopLeft.X, NewTopLeft.Y, BoxSizeX, BoxSizeY, CenterX, CenterY)
	LOG("[PhotoEditCropContentView:UpdateSelectedRange] NewTopLeft.X=%f, NewTopLeft.Y=%f", NewTopLeft.X, NewTopLeft.Y)
	self:UpdateFrameSizeAndPos()
	self:UpdateCropMaskRange()
end

-- 拖动裁剪框移动
function PhotoEditCropContentView:DraggingSelectedRange(LocalPos)
	local NewStartPosX = LocalPos.X - self.DragOffset.X
	local NewStartPosY = LocalPos.Y - self.DragOffset.Y
	local BoxSizeX = self.CropRangeData.EndX - self.CropRangeData.StartX
	local BoxSizeY = self.CropRangeData.EndY - self.CropRangeData.StartY
	NewStartPosX = math.clamp(NewStartPosX, 0, self.Params.SourceW - BoxSizeX)
	NewStartPosY = math.clamp(NewStartPosY, 0, self.Params.SourceH - BoxSizeY)
	local CenterX = NewStartPosX + BoxSizeX * 0.5
	local CenterY = NewStartPosY + BoxSizeY * 0.5
	SetCropDataValues(self.CropRangeData, NewStartPosX, NewStartPosY, BoxSizeX, BoxSizeY, CenterX, CenterY)
	self:UpdateFrameSizeAndPos()
	self:UpdateCropMaskRange()
end

function PhotoEditCropContentView:UpdateFrameSizeAndPos()
	if table.is_nil_empty(self.CropRangeData) then
		return
	end
	local BoxLeftTop = FVector2D(self.CropRangeData.StartX, self.CropRangeData.StartY)
	local BoxSizeX = self.CropRangeData.CropWidth
	local BoxSizeY = self.CropRangeData.CropHeight

	local AbsoluteLeftTop = UIUtil.LocalToAbsolute(self.ImgPic_Mask, BoxLeftTop)
	local RootLocalLeftTop = UIUtil.AbsoluteToLocal(self.CanvasPanel_Root, AbsoluteLeftTop)
	local ImageParentSize = UIUtil.GetLocalSize(self.ImgPic:GetParent())

	local ClampedPos = RootLocalLeftTop
	local ClampedSize  = FVector2D(BoxSizeX, BoxSizeY)
	-- local ClampedSize  = FVector2D(math.min(BoxSizeX, ImageParentSize.X), math.min(BoxSizeY, ImageParentSize.Y))
	-- ClampedPos.X = math.clamp(ClampedPos.X, 0, math.max(0, ImageParentSize.X - ClampedSize.X));
	-- ClampedPos.Y = math.clamp(ClampedPos.Y, 0, math.max(0, ImageParentSize.Y - ClampedSize.Y));

	local CenterOffsetX = ClampedPos.X + (ClampedSize.X * 0.5) - (ImageParentSize.X * 0.5);
	local CenterOffsetY = ClampedPos.Y + (ClampedSize.Y * 0.5) - (ImageParentSize.Y * 0.5);
	-- local Anchor = _G.UE.FAnchors()
	-- Anchor.Minimum = _G.UE.FVector2D(0, 0)
	-- Anchor.Maximum = _G.UE.FVector2D(0, 0)
	-- UIUtil.CanvasSlotSetAlignment(self.PanelFrame, FVector2D(0, 0))
	-- UIUtil.CanvasSlotSetAnchors(self.PanelFrame, Anchor)

	UIUtil.CanvasSlotSetPosition(self.PanelFrame, FVector2D(CenterOffsetX, CenterOffsetY))
	UIUtil.CanvasSlotSetSize(self.PanelFrame, ClampedSize)

	LOG("[PhotoEdit][PhotoEditCropContentView:UpdateFrameSizeAndPos] SourceW=%f, SourceH=%f", self.Params.SourceW,  self.Params.SourceH)
	LOG("[PhotoEdit][PhotoEditCropContentView:UpdateFrameSizeAndPos] BoxSizeX=%f, BoxSizeX=%f", BoxSizeX,  BoxSizeX)
	LOG("[PhotoEdit][PhotoEditCropContentView:UpdateFrameSizeAndPos] ImageParentSize=%f, ImageParentSize=%f", ImageParentSize.X, ImageParentSize.Y)
end

function PhotoEditCropContentView:UpdateCropMaskRange()
	if table.is_nil_empty(self.CropRangeData) then
		return
	end
	local NormalData = PhotoUtil.GetNormalCropRengeData(
			self.Params.SourceW, self.Params.SourceH,
			self.CropRangeData.CropWidth, self.CropRangeData.CropHeight,
			self.CropRangeData.CenterX, self.CropRangeData.CenterY
		)
	self:SetRangeMaskValue(NormalData.NormalCX, NormalData.NormalCY,  NormalData.NormalSX,  NormalData.NormalSY)
end

function PhotoEditCropContentView:LimitSourceImageTransform(Offset)
	local Scale = self:GetSourceImageScale()
	local CropTLPos = FVector2D(self.CropRangeData.StartX, self.CropRangeData.StartY)
	local CropBRPos = FVector2D(self.CropRangeData.EndX, self.CropRangeData.EndY)

	local CropSTLPos = UIUtil.LocalToAbsolute(self.ImgPic_Mask, CropTLPos)
	local CropSBRPos = UIUtil.LocalToAbsolute(self.ImgPic_Mask, CropBRPos)

	local ImgSize = UIUtil.GetAbsoluteSize(self.ImgPic)

	local TargetStartPos = Offset
	local TargetEndPos = FVector2D(Offset.X + ImgSize.X, Offset.Y + ImgSize.Y)

	local ImgeTLPos = UIUtil.GetWidgetAbsolutePosition(self.ImgPic)
	local ImgeBRPos = FVector2D(ImgeTLPos.X + ImgSize.X, ImgeTLPos.Y + ImgSize.Y)
	LOG("[PhotoEdit][LimitSourceImageTransform] CropSTLPos.X=%f, CropSTLPos.Y=%f", CropSTLPos.X, CropSTLPos.Y)
	LOG("[PhotoEdit][LimitSourceImageTransform] ImgeTLPos.X=%f, ImgeTLPos.Y=%f", ImgeTLPos.X, ImgeTLPos.Y)
	LOG("[PhotoEdit][LimitSourceImageTransform] CropSBRPos.X=%f, CropSBRPos.Y=%f", CropSBRPos.X, CropSBRPos.Y)
	LOG("[PhotoEdit][LimitSourceImageTransform] ImgeBRPos.X=%f, ImgeBRPos.Y=%f", ImgeBRPos.X, ImgeBRPos.Y)

	-- if TargetStartPos.X >= CropSTLPos.X then
	-- 	return
	-- elseif TargetEndPos.X <= CropSBRPos.X then
	-- 	return
	-- end

	-- if TargetStartPos.Y >= CropSTLPos.Y then
	-- 	return
	-- elseif TargetEndPos.Y <= CropSBRPos.Y then
	-- 	return
	-- end

	local LocalPos = UIUtil.AbsoluteToLocal(self.CanvasPane_Img, TargetStartPos)
	UIUtil.CanvasSlotSetPosition(self.ImgPic, LocalPos)
	-- local Offsets = UIUtil.CanvasSlotGetOffsets(self.ImgPic)
	-- Offsets.Left = LocalPos.X
	-- Offsets.Top = LocalPos.Y
	-- UIUtil.CanvasSlotSetOffsets(self.ImgPic, Offsets)
	-- local LastPos = UIUtil.CanvasSlotGetPosition(self.ImgPic)
	-- UIUtil.CanvasSlotSetPosition(self.ImgPic, FVector2D(LastPos.X + Offset.X, LastPos.Y + Offset.Y))
end

function PhotoEditCropContentView:GetSourceImageScale()
    local Transform = self.ImgPic.RenderTransform
    return Transform and Transform.Scale.X or 1
end

function PhotoEditCropContentView:SetRangeMaskValue(CenterX, CenterY, SizeX, SizeY)
	SetMTScalarParam(self.ImgPic_Mask, "CenterX", CenterX)
	SetMTScalarParam(self.ImgPic_Mask, "CenterY", CenterY)
	SetMTScalarParam(self.ImgPic_Mask, "SizeX", SizeX)
	SetMTScalarParam(self.ImgPic_Mask, "SizeY", SizeY)
end

function PhotoEditCropContentView:CalculateCropRange()
	local CropWidth = math.floor(self.CropRangeData.CropWidth)
	local CropHeight = math.floor(self.CropRangeData.CropHeight)
	local StartX = math.floor(self.CropRangeData.StartX)
	local StartY = math.floor(self.CropRangeData.StartY)
	local Tex = _G.UE.UMediaUtil.CropTexture(self.Params.SourceTex, CropWidth, CropHeight, StartX, StartY)
	if not Tex then
		LOG("[PhotoEdit][CalculateCropRange] StartX=%f, StartY=%f, CropWidth=%f, CropHeight=%f, SourceW=%f, SourceH=%f",
			StartX, StartY, CropWidth, CropHeight, self.Params.SourceW, self.Params.SourceH)
		return
	end
	_G.UIViewMgr:ShowView(_G.UIViewID.PhotoEditShowPictureWin, {Tex = Tex})
	--UIUtil.ImageSetBrushResourceObject(self.ImgPic, Tex, true)
end


function PhotoEditCropContentView:SetLinesVisiable(IsShow)
	UIUtil.SetIsVisible(self.LineCanvasPanel, IsShow)
end

return PhotoEditCropContentView