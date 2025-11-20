---
--- Author: Administrator
--- DateTime: 2025-07-14 10:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local PhotoEditMainVM = require("Game/Photo/VM/PhotoEdit/PhotoEditMainVM")
local PhotoDefine = require("Game/Photo/PhotoDefine")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderCanvasSlotSetSize = require("Binder/UIBinderCanvasSlotSetSize")
local UIBinderCanvasSlotSetPosition = require("Binder/UIBinderCanvasSlotSetPosition")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetButtonBrush = require("Binder/UIBinderSetButtonBrush")

local FVector2D = _G.UE.FVector2D
local LOG = _G.FLOG_INFO
local LSTR = _G.LSTR
local SetMTScalarParam = UIUtil.ImageSetMaterialScalarParameterValue
local IsUnderLocation = UIUtil.IsUnderLocation
local LocalToAbsolute = UIUtil.LocalToAbsolute
local AbsoluteToLocal = UIUtil.AbsoluteToLocal
local Clamp = math.clamp
local MinFrameSize = 180
local MinFrameFixedRatioSize = 220

local PhotoResizeCorner ={
    None = 1,
	LeftTop = 2,      -- 左上角
    RightTop = 3,     -- 右上角
    LeftBottom = 4,   -- 左下角
    RightBottom = 5,  -- 右下角
}


---@class PhotoEditNewMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bkg CommonBkg01View
---@field BtnBL UFButton
---@field BtnBR UFButton
---@field BtnRefresh UFButton
---@field BtnSave CommBtnLView
---@field BtnTL UFButton
---@field BtnTR UFButton
---@field CanvasPane_Img UFCanvasPanel
---@field CommBackBtn CommBackBtnView
---@field CommSingle CommSingleBoxView
---@field CommonTitle CommonTitleView
---@field EditTouchItem PhotoEditTouchItemView
---@field ImgPic UFImage
---@field ImgPic_Mask UFImage
---@field LineCanvasPanel UFCanvasPanel
---@field PanelFrame UFCanvasPanel
---@field PanelFrame_Copy UFCanvasPanel
---@field PanelImageSize UFCanvasPanel
---@field PanelImgEditRoot UFCanvasPanel
---@field TableViewLeftList UTableView
---@field TextTabTitle UFTextBlock
---@field VerIconTabs CommVerIconTabsView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoEditNewMainView = LuaClass(UIView, true)

function PhotoEditNewMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bkg = nil
	--self.BtnBL = nil
	--self.BtnBR = nil
	--self.BtnRefresh = nil
	--self.BtnSave = nil
	--self.BtnTL = nil
	--self.BtnTR = nil
	--self.CanvasPane_Img = nil
	--self.CommBackBtn = nil
	--self.CommSingle = nil
	--self.CommonTitle = nil
	--self.EditTouchItem = nil
	--self.ImgPic = nil
	--self.ImgPic_Mask = nil
	--self.LineCanvasPanel = nil
	--self.PanelFrame = nil
	--self.PanelFrame_Copy = nil
	--self.PanelImageSize = nil
	--self.PanelImgEditRoot = nil
	--self.TableViewLeftList = nil
	--self.TextTabTitle = nil
	--self.VerIconTabs = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoEditNewMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bkg)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.CommBackBtn)
	self:AddSubView(self.CommSingle)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.EditTouchItem)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoEditNewMainView:OnInit()
	self.AdpSubTab = UIAdapterTableView.CreateAdapter(self, self.TableViewLeftList, self.OnSelectItemSubTab)
	self:InitBinderData()
end

function PhotoEditNewMainView:OnShow()
	self:InitTouchFunc()
	self:InitViewData()
	self.ViewModel:UpdateVM()
	self:InitDisplayScreenshotInBox()
	self.ViewModel:InitCropFrameSize()
	self:UpdateMainTab()

	self:SetRangeMaskValue(0.5, 0.5, 1, 1)
	self:RegisterTimer(function()
		self:FrameValueChange()
	end, 0.01, 0, 1)
end

function PhotoEditNewMainView:OnDestroy()

end

function PhotoEditNewMainView:OnHide()

end

function PhotoEditNewMainView:OnRegisterUIEvent()
	self.CommBackBtn:AddBackClick(self, self.OnBtnClose)
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnMainTabChange)
	UIUtil.AddOnStateChangedEvent(self, self.CommSingle, self.OnStateChangedToggle)
	UIUtil.AddOnClickedEvent(self, self.BtnRefresh, self.OnClickButtonRefresh)
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickButtonSave)
end

function PhotoEditNewMainView:OnRegisterGameEvent()

end

function PhotoEditNewMainView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binder)
end

function PhotoEditNewMainView:InitBinderData()
	self.ViewModel = PhotoEditMainVM.New()
	self.Binder = {
		{ "SubTabList", UIBinderUpdateBindableList.New(self, self.AdpSubTab) },
		{ "SubTabIdx", UIBinderSetSelectedIndex.New(self, self.AdpSubTab) },
		{ "TabTitleTxt", UIBinderSetText.New(self, self.TextTabTitle) },
		{ "SublineIsVisibility", UIBinderSetIsVisible.New(self, self.LineCanvasPanel) },
		{ "InitDisplayImgSize", UIBinderCanvasSlotSetSize.New(self, self.PanelImageSize, true) },
		{ "InitDisplayImgSize", UIBinderCanvasSlotSetSize.New(self, self.CanvasPane_Img, true) },
		--{ "InitDisplayImgSize", UIBinderCanvasSlotSetSize.New(self, self.EditTouchItem, true) },
		{ "FrameSize", UIBinderCanvasSlotSetSize.New(self, self.PanelFrame, false) },
		{ "FramePos", UIBinderCanvasSlotSetPosition.New(self, self.PanelFrame, false) },
		{ "ImageSize", UIBinderCanvasSlotSetSize.New(self, self.ImgPic, false) },
		{ "ImagePos", UIBinderCanvasSlotSetPosition.New(self, self.ImgPic, false) },
		{ "FrameChangeNum", UIBinderValueChangedCallback.New(self, nil, self.FrameValueChange) },
		{ "ResetBtnIcon", UIBinderSetButtonBrush.New(self, self.BtnRefresh, nil) },
	}
end

function PhotoEditNewMainView:InitViewData()
	self.CommonTitle:SetTextTitleName(LSTR(630069))
	self.CommonTitle:SetTextSubtitle(LSTR(630070))
	self.BtnSave:SetText(LSTR(630081))
	self.CommSingle:SetChecked(true, true)
	if self.Params.SourceTex then
		UIUtil.ImageSetBrushResourceObject(self.ImgPic, self.Params.SourceTex, false)
	end
end

function PhotoEditNewMainView:InitTouchFunc()
	self.EditTouchItem.View = self
	self.EditTouchItem.TouchStartCB = self.OnTouchStart
	self.EditTouchItem.TouchMoveCB = self.OnTouchMove
	self.EditTouchItem.TouchEndCB = self.OnTouchEnd
	self.EditTouchItem.ScaleChangedCallback = self.OnScaleChangedCallback
end

function PhotoEditNewMainView:OnTouchStart(Pos)
	self.StartScrPos = LocalToAbsolute(self.EditTouchItem, Pos)
	self.CurFramePosType = self:GetClickFramePosType(self.StartScrPos)
	if self.CurFramePosType ~= PhotoResizeCorner.None then
		self.StartFramePosX, self.StartFramePosY = self.ViewModel.FramePos:GetValue()
		self.StartFrameSizeX, self.StartFrameSizeY = self.ViewModel.FrameSize:GetValue()
		self.IsFrameZoom = true
	elseif self:IsClickFrameRange(self.StartScrPos) then
		self.StartFramePosX, self.StartFramePosY = self.ViewModel.FramePos:GetValue()
		self.StartFrameSizeX, self.StartFrameSizeY = self.ViewModel.FrameSize:GetValue()
		self.IsFrameMove = true
	else
		self.StartImgPosX, self.StartImgePosY = self.ViewModel.ImagePos:GetValue()
		self.StartImgSizeX, self.StartImgSizeY = self.ViewModel.ImageSize:GetValue()
		self.IsImageMove = true
	end
end

function PhotoEditNewMainView:OnTouchMove(Pos)
	self.EndScrPo = LocalToAbsolute(self.EditTouchItem, Pos)
	local DeltaX = self.EndScrPo.X - self.StartScrPos.X
	local DeltaY = self.EndScrPo.Y - self.StartScrPos.Y
	if self.IsFrameZoom then
		self:UpdateFrameRnage(DeltaX, DeltaY, true)
	elseif self.IsFrameMove then
		self:UpdateFramePos(DeltaX, DeltaY, true)
	elseif self.IsImageMove then
		self:UpdateImagePos(DeltaX, DeltaY, true)
	end
	self.StartScrPos.X = self.EndScrPo.X
	self.StartScrPos.Y = self.EndScrPo.Y
end

function PhotoEditNewMainView:OnTouchEnd(Pos)
	self.StartScrPos = nil
	self.EndScrPo = nil
	self.IsFrameZoom = nil
	self.IsFrameMove = nil
	self.CurFramePosType = nil
	self.StartFramePosX, self.StartFramePosY = nil, nil
	self.StartFrameSizeX, self.StartFrameSizeY  = nil, nil
	self.IsImageMove = nil
	self.StartImgPosX, self.StartImgePosY = nil, nil
	self.StartImgSizeX, self.StartImgSizeY = nil, nil

	LOG("PhotoEditNewMainView:OnTouchEnd(Pos)")
	self.PanelImageSize:InvalidateLayoutAndVolatility()
	if self.MaskExtraUpdateTimerHandle then
		self:UnRegisterTimer(self.MaskExtraUpdateTimerHandle)
		self.MaskExtraUpdateTimerHandle = nil
	end
	self.MaskExtraUpdateTimerHandle = self:RegisterTimer(self.FrameValueChange, 0.01, 0, 3)
end

function PhotoEditNewMainView:OnScaleChangedCallback(Scale, ScreenPosition)
	local InitDisplayScale = self.ViewModel.InitDisplayImgScale
	local CurImgScale = self.ViewModel.ImageScale
	local NewImgScale = Clamp(CurImgScale * Scale, InitDisplayScale, self.ViewModel.MaxImgScale)
	if CommonUtil.FloatIsEqual(CurImgScale, NewImgScale, 0.01) then
		return
	end

	local NewImgSizeX = self.Params.SourceW * NewImgScale
	local NewImgSizeY = self.Params.SourceH * NewImgScale

	-- 计算缩放后相对鼠标的位置
	local LocalPosition = AbsoluteToLocal(self.ImgPic, ScreenPosition)
	local ImgSizeX, ImgSizeY = self.ViewModel.ImageSize:GetValue()
	local ImgPosX, ImgPosY = self.ViewModel.ImagePos:GetValue()
	local RelativeMouseNorPosX = LocalPosition.X / ImgSizeX
	local RelativeMouseNorPosY = LocalPosition.Y / ImgSizeY
	local NewMousePosInImageX = RelativeMouseNorPosX * NewImgSizeX
	local NewMousePosInImageY = RelativeMouseNorPosY * NewImgSizeY
	ImgPosX = ImgPosX - (NewMousePosInImageX - LocalPosition.X)
	ImgPosY = ImgPosY - (NewMousePosInImageY - LocalPosition.Y)

	-- 将位置限制在裁剪范围外
	local ImgBottomRightX = ImgPosX + NewImgSizeX
	local ImgBottomRightY = ImgPosY + NewImgSizeY
	local FramePosX, FramePosY = self.ViewModel.FramePos:GetValue()
	local FrameSizeX, FrameSizeY = self.ViewModel.FrameSize:GetValue()
	local FrameBottomRightX = FramePosX + FrameSizeX
	local FrameBottomRightY = FramePosY + FrameSizeY
	if ImgPosX > FramePosX then
		ImgPosX = FramePosX
	end
	if ImgBottomRightX < FrameBottomRightX then
		ImgPosX = FrameBottomRightX - NewImgSizeX
	end
	if ImgPosY > FramePosY then
		ImgPosY = FramePosY
	end
	if ImgBottomRightY < FrameBottomRightY then
		ImgPosY = FrameBottomRightY - NewImgSizeY
	end

	self.ViewModel:SetPhotoImageData(NewImgScale, ImgPosX, ImgPosY, NewImgSizeX, NewImgSizeY)
end

--- 计算缩放比例使其适配指定容器
function PhotoEditNewMainView:InitDisplayScreenshotInBox()
	if not self.Params.SourceW or not self.Params.SourceH then
		return
	end
	local TextureWidth = self.Params.SourceW
	local TextureHeight = self.Params.SourceH
	local WidgetSize = UIUtil.GetWidgetSize(self.PanelImgEditRoot)
	local ScaleX = WidgetSize.X / TextureWidth
	local ScaleY = WidgetSize.Y / TextureHeight
	local FinalScale = math.min(ScaleX, ScaleY)
	local DisplaySize = FVector2D(TextureWidth * FinalScale, TextureHeight * FinalScale)
	self.ViewModel:SetInitImgSizeAndScale(FinalScale, DisplaySize)
	LOG("[PhotoEditNewMainView] FinalScale = %f", FinalScale)
end

function PhotoEditNewMainView:UpdateMainTab()
	self.VerIconTabs:UpdateItems(PhotoDefine.UITabEditCfg, 1)
end

function PhotoEditNewMainView:OnMainTabChange(MainIndex)
	self.ViewModel:SetMainTabIdx(MainIndex)
end

function PhotoEditNewMainView:OnSelectItemSubTab(SubIndex, ItemVM)
	self.ViewModel:SetSubTabIdx(SubIndex)
end

function PhotoEditNewMainView:OnBtnClose()
	self:Hide()
end

function PhotoEditNewMainView:OnStateChangedToggle(ToggleButton, State)
	local IsShow = UIUtil.IsToggleButtonChecked(State)
	self.ViewModel.SublineIsVisibility = IsShow
end

function PhotoEditNewMainView:OnClickButtonRefresh()
	if self.ViewModel.IsGreyResetBtn then
		MsgTipsUtil.ShowTips(LSTR(630085))
	else
		MsgTipsUtil.ShowTips(LSTR(630086))
		self.ViewModel:RestoreEditInitialValues()
		self:FrameValueChange(nil, nil, true)
	end
end

function PhotoEditNewMainView:OnClickButtonSave()
	local CropAreaData = self.ViewModel.CropAreaData
	if table.is_nil_empty(CropAreaData) then
		return
	end

	local FramePosX, FramePosY = self.ViewModel.FramePos:GetValue()
	local FrameSizeX, FrameSizeY = self.ViewModel.FrameSize:GetValue()
	local ImgPosX, ImgPosY = self.ViewModel.ImagePos:GetValue()
	local ImgSizeX, ImgSizeY = self.ViewModel.ImageSize:GetValue()

	-- 相对位置
	local DeltaX = FramePosX - ImgPosX
	local DeltaY = FramePosY - ImgPosY

	-- 归一化
	local UVStartX = DeltaX / ImgSizeX
	local UVStartY= DeltaY / ImgSizeY
	local UVEndX = (DeltaX + FrameSizeX) / ImgSizeX
	local UVEndY = (DeltaY + FrameSizeY) / ImgSizeY

	-- 转到像素位置
	local TextureWidth, TextureHeight = self.Params.SourceW, self.Params.SourceH
	local ImgCropStartX = math.floor(UVStartX * TextureWidth)
	local ImgCropStartY = math.floor(UVStartY * TextureHeight)
	local CropWidth = math.floor((UVEndX - UVStartX) * TextureWidth)
	local CropHeight = math.floor((UVEndY - UVStartY) * TextureHeight)

	local Tex = _G.UE.UMediaUtil.CropTexture(self.Params.SourceTex, CropWidth, CropHeight, ImgCropStartX, ImgCropStartY)
	if not Tex then
		_G.FLOG_WARNING("[PhotoEdit][CalculateCropRange] StartX=%f, StartY=%f, CropWidth=%f, CropHeight=%f, SourceW=%f, SourceH=%f",
		ImgCropStartX, ImgCropStartY, CropWidth, CropHeight, self.Params.SourceW, self.Params.SourceH)
		return
	end

	_G.UIViewMgr:ShowView(_G.UIViewID.PhotoEditShowPictureWin, {Tex = Tex})
	self:Hide()
end

function PhotoEditNewMainView:IsClickFrameRange(ScreenPosition)
	local AreaData = self.ViewModel.CropAreaData
	if table.is_nil_empty(AreaData) then
        return
    end
	local LocalPos = AbsoluteToLocal(self.PanelImageSize, ScreenPosition)
	if LocalPos.X >= AreaData.StartX and LocalPos.X <= AreaData.EndX and LocalPos.Y >= AreaData.StartY and LocalPos.Y <= AreaData.EndY then
		return true
	end
end

function PhotoEditNewMainView:UpdateFramePos(DeltaX, DeltaY, IsTryMoveImg)
	local MaxWidgetSize = UIUtil.GetLocalSize(self.EditTouchItem)
	local NewPosX, NewPosY = self.ViewModel.FramePos:GetValue()
	local StartSizeX = self.StartFrameSizeX
	local StartSizeY = self.StartFrameSizeY
	if not StartSizeX or not StartSizeY then
		StartSizeX, StartSizeY = self.ViewModel.FrameSize:GetValue()
	end
	NewPosX = Clamp(NewPosX + DeltaX, 0, MaxWidgetSize.X - StartSizeX)
	NewPosY = Clamp(NewPosY + DeltaY, 0, MaxWidgetSize.Y - StartSizeY)

	local bFrameWithinImg = self:IsFrameWithinImage(NewPosX, NewPosY)
	if not bFrameWithinImg and IsTryMoveImg then
		self:UpdateImagePos(DeltaX, DeltaY, false)
		bFrameWithinImg = self:IsFrameWithinImage(NewPosX, NewPosY)
	end

	if bFrameWithinImg then
		self.ViewModel:SetFramePos(NewPosX, NewPosY)
	end
end

function PhotoEditNewMainView:GetClickFramePosType(ScreenPosition)
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

function PhotoEditNewMainView:GetFrameMinSize()
	local MinSizeX, MinSizeY
	if self.BPV_IsUseBPFrameMinCfg then
		if self.ViewModel.IsFrameRatioLimit then
			MinSizeX = self.BPV_FrameFixedMinSize.X
			MinSizeY = self.BPV_FrameFixedMinSize.Y
		else
			MinSizeX = self.BPV_FrameMinSize.X
			MinSizeY = self.BPV_FrameMinSize.Y
		end
	else
		MinSizeX = self.ViewModel.InitFrameSize.X / 3
		MinSizeY = self.ViewModel.InitFrameSize.Y / 3
		if self.ViewModel.IsFrameRatioLimit then
			MinSizeX = MinSizeX + 60
			MinSizeY = MinSizeY + 60
		end
	end
	return MinSizeX, MinSizeY
end

function PhotoEditNewMainView:UpdateFrameRnage(DeltaX, DeltaY, IsTryMoveImg)
	local NewPosX, NewPosY = self.ViewModel.FramePos:GetValue()
	local NewSizeX, NewSizeY = self.ViewModel.FrameSize:GetValue()
	local MaxWidgetSize = UIUtil.GetLocalSize(self.EditTouchItem)
	if self.CurFramePosType == PhotoResizeCorner.LeftTop then
		NewSizeX = NewSizeX - DeltaX
		NewSizeY = NewSizeY - DeltaY
		NewPosX = NewPosX + DeltaX
		NewPosY = NewPosY + DeltaY
	elseif self.CurFramePosType == PhotoResizeCorner.RightTop then
		NewSizeX = NewSizeX + DeltaX
		NewSizeY = NewSizeY - DeltaY
		NewPosY = NewPosY + DeltaY
	elseif self.CurFramePosType == PhotoResizeCorner.LeftBottom then
		NewSizeX = NewSizeX - DeltaX
		NewSizeY = NewSizeY + DeltaY
		NewPosX = NewPosX + DeltaX
	elseif self.CurFramePosType == PhotoResizeCorner.RightBottom then
		NewSizeX = NewSizeX + DeltaX
		NewSizeY = NewSizeY + DeltaY
	end

	local MinSizeX, MinSizeY = self:GetFrameMinSize()
	NewSizeX = Clamp(NewSizeX, MinSizeX, MaxWidgetSize.X)
	NewSizeY = Clamp(NewSizeY, MinSizeY, MaxWidgetSize.Y)
	LOG("[PhotoEditNewMainView:UpdateFrameRnage] #MinSize# IsFrameRatioLimit=%s, MinSizeX=%f, MinSizeY=%f",
		tostring(self.ViewModel.IsFrameRatioLimit), MinSizeX, MinSizeY)

	-- 如果启用固定比例缩放，调整尺寸以匹配目标宽高比
	if self.ViewModel.IsFrameRatioLimit and self.ViewModel.AspectRatio then
		local CurRatio = NewSizeX / NewSizeY
		if CurRatio > self.ViewModel.AspectRatio then
			-- 高度相对较大，保持宽度，调整高度
			NewSizeX = NewSizeY * self.ViewModel.AspectRatio
		else
			-- 宽度相对较大，保持高度，调整宽度
			NewSizeY = NewSizeX / self.ViewModel.AspectRatio
		end
		LOG("[PhotoEditNewMainView:UpdateFrameRnage] #MinSize# NewMinSize.X=%f, NewMinSize.X=%f", NewSizeX, NewSizeY)
		if self.CurFramePosType == PhotoResizeCorner.LeftTop then
			NewPosX = self.StartFramePosX + (self.StartFrameSizeX - NewSizeX)
			NewPosY = self.StartFramePosY + (self.StartFrameSizeY - NewSizeY)
		elseif self.CurFramePosType == PhotoResizeCorner.RightTop then
			NewPosY = self.StartFramePosY + (self.StartFrameSizeY - NewSizeY)
		elseif self.CurFramePosType == PhotoResizeCorner.LeftBottom then
			NewPosX = self.StartFramePosX + (self.StartFrameSizeX - NewSizeX)
		end
	end

	NewPosX = Clamp(NewPosX, 0, MaxWidgetSize.X - NewSizeX)
	NewPosY = Clamp(NewPosY, 0, MaxWidgetSize.Y - NewSizeY)

	local bFrameWithinImg = self:IsFrameWithinImage(NewPosX, NewPosY, NewSizeX, NewSizeY)
	if not bFrameWithinImg and IsTryMoveImg then
		self:UpdateImagePos(DeltaX, DeltaY, false)
		bFrameWithinImg = self:IsFrameWithinImage(NewPosX, NewPosY, NewSizeX, NewSizeY)
	end

	if bFrameWithinImg then
		self.ViewModel:SetFramePos(NewPosX, NewPosY)
		self.ViewModel:SetFrameSize(NewSizeX, NewSizeY)
		LOG("[PhotoEditNewMainView:UpdateFrameRnage] FrameSize.X = %f, FrameSize.Y = %f", NewSizeX, NewSizeY)
	end
end

function PhotoEditNewMainView:UpdateImagePos(DeltaX, DeltaY, IsTryMoveFrame)
	local NewImgPosX, NewImgPosY = self.ViewModel.ImagePos:GetValue()
	NewImgPosX = NewImgPosX + DeltaX
	NewImgPosY = NewImgPosY + DeltaY

	local bImgCanContainFrame = self:IsImgCanContainFrame(NewImgPosX, NewImgPosY)
	if not bImgCanContainFrame and IsTryMoveFrame then
		--尝试移动裁剪框一次
		self:UpdateFramePos(DeltaX, DeltaY, false)
		bImgCanContainFrame = self:IsImgCanContainFrame(NewImgPosX, NewImgPosY)
	end
	if bImgCanContainFrame then
		self.ViewModel:SetPhotoImagePosData(NewImgPosX, NewImgPosY)
	end

	LOG("[PhotoEditNewMainView] UpdateImagePos ImagePos.X=%f, ImagePos.Y=%f", NewImgPosX, NewImgPosY)
	LOG("[PhotoEditNewMainView] UpdateImagePos bImgCanContainFrame=%s", tostring(bImgCanContainFrame))
end

local function IsImgContainFrame(ImgPosX, ImgPosY, ImgSizeX, ImgSizeY, FramePosX, FramePosY, FrameSizeX, FrameSizeY)
	local ImgBottomRightX = ImgPosX + ImgSizeX
	local ImgBottomRightY = ImgPosY + ImgSizeY
	local FrameBottomRightX = FramePosX + FrameSizeX
	local FrameBottomRightY = FramePosY + FrameSizeY
	if ImgPosX <= FramePosX and ImgBottomRightX >= FrameBottomRightX and
		ImgPosY <= FramePosY and ImgBottomRightY >= FrameBottomRightY then
		return true
	end
end

-- 当前图片是否包含住了裁剪区域
function PhotoEditNewMainView:IsImgCanContainFrame(ImgPosX, ImgPosY)
	local ImgSizeX, ImgSizeY = self.ViewModel.ImageSize:GetValue()
	local FramePosX, FramePosY = self.ViewModel.FramePos:GetValue()
	local FrameSizeX, FrameSizeY = self.ViewModel.FrameSize:GetValue()

	return IsImgContainFrame(ImgPosX, ImgPosY, ImgSizeX, ImgSizeY, FramePosX, FramePosY, FrameSizeX, FrameSizeY)
end

-- 裁剪区域是否在图片内
function PhotoEditNewMainView:IsFrameWithinImage(FramePosX, FramePosY, FrameSizeX, FrameSizeY)
	local ImgPosX, ImgPosY = self.ViewModel.ImagePos:GetValue()
	local ImgSizeX, ImgSizeY = self.ViewModel.ImageSize:GetValue()

	if not FramePosX or not FramePosY then
		FramePosX, FramePosY = self.ViewModel.FramePos:GetValue()
	end
	if not FrameSizeX or not FrameSizeY then
		FrameSizeX, FrameSizeY = self.ViewModel.FrameSize:GetValue()
	end

	return IsImgContainFrame(ImgPosX, ImgPosY, ImgSizeX, ImgSizeY, FramePosX, FramePosY, FrameSizeX, FrameSizeY)
end

function PhotoEditNewMainView:FrameValueChange(NewValue, OldValue, IsInit)
	local AreaData = self.ViewModel.CropAreaData
	if table.is_nil_empty(AreaData) then
        return
    end
	local ScrSPos = LocalToAbsolute(self.PanelFrame, FVector2D(AreaData.StartX, AreaData.StartY))
	local ScrEPos = LocalToAbsolute(self.PanelFrame, FVector2D(AreaData.EndX, AreaData.EndY))
	local ScrCPos = LocalToAbsolute(self.PanelFrame, FVector2D(AreaData.CenterX, AreaData.CenterY))
	if IsInit == true and self.InitMaskSPos and self.InitMaskEPos and self.InitMaskCPos then
		ScrSPos = self.InitMaskSPos
		ScrEPos = self.InitMaskEPos
		ScrCPos = self.InitMaskCPos
	else
		if not self.InitMaskSPos or not self.InitMaskEPos or not self.InitMaskCPos then
			self.InitMaskSPos = ScrSPos
			self.InitMaskEPos = ScrEPos
			self.InitMaskCPos = ScrCPos
		end
	end
	local LocalSPos = AbsoluteToLocal(self.ImgPic_Mask, ScrSPos)
	local LocalEPos = AbsoluteToLocal(self.ImgPic_Mask, ScrEPos)
	local LocalCPos = AbsoluteToLocal(self.ImgPic_Mask, ScrCPos)
	local Size = UIUtil.GetLocalSize(self.ImgPic_Mask)

	local BoxSizeX = LocalEPos.X - LocalSPos.X
	local BoxSizeY = LocalEPos.Y - LocalSPos.Y
	local CenterX = LocalCPos.X / Size.X
	local CenterY = LocalCPos.Y / Size.Y
	local SizeX = BoxSizeX / Size.X
	local SizeY = BoxSizeY / Size.Y

	self:SetRangeMaskValue(CenterX, CenterY, SizeX, SizeY)
end

function PhotoEditNewMainView:SetRangeMaskValue(CenterX, CenterY, SizeX, SizeY)
	SetMTScalarParam(self.ImgPic_Mask, "CenterX", CenterX)
	SetMTScalarParam(self.ImgPic_Mask, "CenterY", CenterY)
	SetMTScalarParam(self.ImgPic_Mask, "SizeX", SizeX)
	SetMTScalarParam(self.ImgPic_Mask, "SizeY", SizeY)
end

return PhotoEditNewMainView