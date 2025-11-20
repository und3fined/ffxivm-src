---
--- Author: Administrator
--- DateTime: 2025-07-08 15:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PhotoDefine = require("Game/Photo/PhotoDefine")

local LSTR = _G.LSTR
local PhotoMgr = _G.PhotoMgr

---@class PhotoEditShowPictureWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field ImgShowPic1_1 UFImage
---@field ImgShowPic1_2 UFImage
---@field ImgShowPic2_1 UFImage
---@field ImgShowPic2_2 UFImage
---@field ImgShowPicH UFImage
---@field ImgShowPicW UFImage
---@field PanelLoading UFCanvasPanel
---@field PanelReplacePicH UFCanvasPanel
---@field PanelReplacePicW UFCanvasPanel
---@field PanelShowPic1_1 UFCanvasPanel
---@field PanelShowPic1_2 UFCanvasPanel
---@field PanelShowPic2_1 UFCanvasPanel
---@field PanelShowPic2_2 UFCanvasPanel
---@field PanelShowPicH UFCanvasPanel
---@field PanelShowPicW UFCanvasPanel
---@field TextLoading UFTextBlock
---@field TextTips UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoEditShowPictureWinView = LuaClass(UIView, true)

function PhotoEditShowPictureWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameL_UIBP = nil
	--self.ImgShowPic1_1 = nil
	--self.ImgShowPic1_2 = nil
	--self.ImgShowPic2_1 = nil
	--self.ImgShowPic2_2 = nil
	--self.ImgShowPicH = nil
	--self.ImgShowPicW = nil
	--self.PanelLoading = nil
	--self.PanelReplacePicH = nil
	--self.PanelReplacePicW = nil
	--self.PanelShowPic1_1 = nil
	--self.PanelShowPic1_2 = nil
	--self.PanelShowPic2_1 = nil
	--self.PanelShowPic2_2 = nil
	--self.PanelShowPicH = nil
	--self.PanelShowPicW = nil
	--self.TextLoading = nil
	--self.TextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoEditShowPictureWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameL_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoEditShowPictureWinView:OnInit()
	self.Comm2FrameL_UIBP:SetTitleText(LSTR(630071))
	self.Comm2FrameL_UIBP.Ben2Left:SetBtnName(LSTR(630072))
	self.Comm2FrameL_UIBP.Btn2Right:SetBtnName(LSTR(10065))
end

function PhotoEditShowPictureWinView:OnDestroy()

end

function PhotoEditShowPictureWinView:OnShow()
	self:UpdateView()
end

function PhotoEditShowPictureWinView:OnHide()

end

function PhotoEditShowPictureWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Comm2FrameL_UIBP.ButtonClose, self.OnClickedClose)
    UIUtil.AddOnClickedEvent(self, self.Comm2FrameL_UIBP.Btn2Right, self.OnClickedBtnSure)
    UIUtil.AddOnClickedEvent(self, self.Comm2FrameL_UIBP.Ben2Left, self.OnClickedBtnCancel)
end

function PhotoEditShowPictureWinView:OnRegisterGameEvent()

end

function PhotoEditShowPictureWinView:OnRegisterBinder()

end

function PhotoEditShowPictureWinView:OnClickedClose()
	self:OnCloseView(true)
end

function PhotoEditShowPictureWinView:OnClickedBtnCancel()
	self:OnCloseView(true)
end

function PhotoEditShowPictureWinView:OnClickedBtnSure()
	local IsHouse = PhotoMgr.EditCropType == PhotoDefine.UIEditCropType.House
	if IsHouse then
		local HouseID = PhotoMgr.EditCropParams and PhotoMgr.EditCropParams.HouseID-- or 5217099501825465
		if HouseID then
			local IsCompare = self:GetIsCompare(IsHouse)
			local ImgWidget = self:GetTargetImageWidget(IsCompare, IsHouse)
			local Size = UIUtil.GetLocalSize(ImgWidget)
			local DataStr = _G.UE.UMediaUtil.GetWidgetScreenshotImageData(ImgWidget, Size, 100, false)
			if string.isnilorempty(DataStr) then
				_G.FLOG_ERROR("PhotoEditShowPictureWinView:OnClickedBtnSure, the widget's screenshot data is empty")
			else
				PhotoMgr.CurIconStream = DataStr
				_G.HouseInfoMgr:SendUploadHousePic(HouseID)
			end
		else
			FLOG_INFO('PhotoEditShowPictureWinView:OnClickedBtnSure HouseID = nil')
		end
	end
	self:OnCloseView(false)
end

function PhotoEditShowPictureWinView:OnCloseView(IsBackPhoto)
	local ImageDownloader = self.ImageDownloader
	if ImageDownloader and ImageDownloader:IsValid() then
		ImageDownloader:Stop()
	end
	self:Hide()
	if IsBackPhoto then
		PhotoMgr:OpenPhotoAndLogCropType(PhotoMgr.EditCropType, PhotoMgr.EditCropParams)
	else
		PhotoMgr:ClosePhotoUI()
	end
end

function PhotoEditShowPictureWinView:UpdateView()
	local IsHouse = PhotoMgr.EditCropType == PhotoDefine.UIEditCropType.House
	local IsCompare = self:GetIsCompare(IsHouse)
	self:SetTipText(IsCompare, IsHouse)
	self:SetWidgetVisiable(IsCompare, IsHouse)
	self:SetWidgetTexture(IsCompare, IsHouse)

	local Url = PhotoMgr.EditCropParams and PhotoMgr.EditCropParams.Url
	self:GetAlreadyTextureByUrl(Url)
end

function PhotoEditShowPictureWinView:SetTipText(IsCompare, IsHouse)
	local TipTxt
	if IsHouse then
		TipTxt = IsCompare and LSTR(630074) or LSTR(630073)
	else
		TipTxt = IsCompare and LSTR(630076) or LSTR(630075)
	end
	self.TextTips:SetText(TipTxt)
end

function PhotoEditShowPictureWinView:SetWidgetVisiable(IsCompare, IsHouse)
	local IsHanhua = not IsHouse
	UIUtil.SetIsVisible(self.PanelShowPicW, not IsCompare and IsHouse)
	UIUtil.SetIsVisible(self.PanelShowPicH, not IsCompare and IsHanhua)
	UIUtil.SetIsVisible(self.PanelReplacePicW, IsCompare and IsHouse)
	UIUtil.SetIsVisible(self.PanelReplacePicH, IsCompare and IsHanhua)
	UIUtil.SetIsVisible(self.PanelLoading, IsCompare)
end

function PhotoEditShowPictureWinView:SetWidgetTexture(IsCompare, IsHouse)
	local Texture = self.Params.Tex
	if not Texture then
		return
	end
	if IsCompare then
		if IsHouse then
			--UIUtil.ImageSetBrushResourceObject(self.ImgShowPic1_1, , true)
			UIUtil.ImageSetBrushResourceObject(self.ImgShowPic1_2, Texture, true)
		else
			--UIUtil.ImageSetBrushResourceObject(self.ImgShowPic2_1, , true)
			UIUtil.ImageSetBrushResourceObject(self.ImgShowPic2_2, Texture, true)
		end
	else
		local ImageWidget = IsHouse and self.ImgShowPicW or self.ImgShowPicH
		UIUtil.ImageSetBrushResourceObject(ImageWidget, Texture, true)
	end
end

function PhotoEditShowPictureWinView:GetTargetImageWidget(IsCompare, IsHouse)
	if IsHouse then
		return IsCompare and self.ImgShowPic1_2 or self.ImgShowPicW
	else
		return IsCompare and self.ImgShowPic2_2 or self.ImgShowPicH
	end
end

function PhotoEditShowPictureWinView:GetIsCompare(IsHouse)
	if IsHouse then
		if PhotoMgr.EditCropParams and not string.isnilorempty(PhotoMgr.EditCropParams.Url) then
			return true
		end
	--else-- 幻化
	end
	return false
end

function PhotoEditShowPictureWinView:GetAlreadyTextureByUrl(Url)
	self.TextLoading:SetText("")
	if not Url then
		return
	end
	local MaxRequest = PhotoDefine.CropAlreadyImgDownloadMax
	local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("PhotoCropAlreadyImg", true, MaxRequest)
    ImageDownloader.OnSuccess:Add(ImageDownloader,
		function(_, texture)
			if texture then
				UIUtil.SetIsVisible(self.PanelLoading, false)
				FLOG_INFO("[PhotoEditShowPictureWinView] download image success. = %s", Url)
				local IsHouse = PhotoMgr.EditCropType == PhotoDefine.UIEditCropType.House
				local AlreadyWidget = IsHouse and self.ImgShowPic1_1 or self.ImgShowPic2_1
				UIUtil.ImageSetMaterialTextureParameterValue(AlreadyWidget, 'Texture', texture)
			end
		end
    )
    ImageDownloader.OnFail:Add(ImageDownloader,
		function()
			FLOG_INFO("[PhotoEditShowPictureWinView] download image failed. = %s", Url)
			self.TextLoading:SetText(LSTR(630077))
		end
	)
    ImageDownloader:Start(Url, "", true)
	self.ImageDownloader = ImageDownloader
end

return PhotoEditShowPictureWinView