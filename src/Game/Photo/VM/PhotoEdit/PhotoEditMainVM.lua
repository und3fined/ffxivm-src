local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PhotoDefine = require("Game/Photo/PhotoDefine")
local UIBindableList = require("UI/UIBindableList")
local PhotoEditSubTabItemVM = require("Game/Photo/VM/PhotoEdit/Item/PhotoEditSubTabItemVM")
local PhotoUtil = require("Game/Photo/PhotoUtil")
local BindableVector2D = require("UI/BindableObject/BindableVector2D")

local PhotoEditMainVM = LuaClass(UIViewModel)
local PhotoMgr = _G.PhotoMgr
local FVector2D = _G.UE.FVector2D
local ResetBtnGreyImg = "Texture2D'/Game/UI/Texture/Button/Round/UI_Btn_GeneralControls_RefurbishGrey.UI_Btn_GeneralControls_RefurbishGrey'"
local ResetBtnNormlImg = "Texture2D'/Game/UI/Texture/Button/Round/UI_Btn_GeneralControls_Refurbish.UI_Btn_GeneralControls_Refurbish'"


local function GetSubCropCfg(EditCropType)
    if not EditCropType then
        EditCropType = PhotoDefine.UIEditCropType.Normal
    end
    return PhotoDefine.UIEditSubCropCfg[EditCropType]
end

function PhotoEditMainVM:Ctor()
    self.SubTabList = UIBindableList.New(PhotoEditSubTabItemVM)
    self:Reset()
end

function PhotoEditMainVM:Reset()
    self.SubTabData = {}
    self.MainTabIdx = 1
    self.SubTabIdx  = -1

    self.TabTitleTxt = ""
    self.IsGreyResetBtn = true
    self.ResetBtnIcon = ResetBtnGreyImg
    self.SublineIsVisibility = true

    self.MaxImgScale = 1
    self.InitDisplayImgScale = 1
    self.InitDisplayImgSize = FVector2D(0, 0)
    self.ImageScale = 0
    self.ImageSize = BindableVector2D.New()
    self.ImagePos = BindableVector2D.New()
    self.AspectRatio = 0
    self.IsFrameRatioLimit = true
    self.InitFrameSize = FVector2D(0, 0)
    self.InitFramePos = FVector2D(0, 0)
    self.FrameSize = BindableVector2D.New()
    self.FramePos = BindableVector2D.New()
    self.FrameChangeNum = 0
    self.CropAreaData = {}
    self.CropType = PhotoMgr.EditCropType
end

function PhotoEditMainVM:UpdateVM()
    self:Reset()
    self.SubTabData[PhotoDefine.UITabEditType.Crop] = GetSubCropCfg(PhotoMgr.EditCropType)
    self:SetMainTabIdx(self.MainTabIdx)
end

function PhotoEditMainVM:UpdateSubTabList()
    local CurData = self.SubTabData[self.MainTabIdx]
    if CurData then
        self.SubTabList:UpdateByValues(CurData)
    end
end

function PhotoEditMainVM:SetMainTabIdx(MainIndx, SubIdex)
    self.MainTabIdx = MainIndx
    self:UpdateSubTabList()
    self:SetSubTabIdx(SubIdex or 1)
    self:UpdateUITabTitle()
end

function PhotoEditMainVM:SetSubTabIdx(Idx)
    self.SubTabIdx = Idx
end

function PhotoEditMainVM:UpdateUITabTitle()
    local Title = PhotoDefine.UITabEditTitleCfg[self.MainTabIdx]
    self.TabTitleTxt = Title or ""
end

function PhotoEditMainVM:SetInitImgSizeAndScale(InitScale, InitSize)
	self.InitDisplayImgScale = InitScale
    self.MaxImgScale = InitScale * 2
	self.InitDisplayImgSize = InitSize
    self.ImageScale = self.InitDisplayImgScale
	self.ImageSize:SetValue(InitSize.X, InitSize.Y)
    self.ImagePos:SetValue(0, 0)
end

function PhotoEditMainVM:InitCropFrameSize()
    local CropData = PhotoUtil.GetCropDataByCropType(self.CropType)
    if not CropData then
        return
    end
    local ImgSize = self.InitDisplayImgSize
    self.AspectRatio = CropData.AspectRatioWidth / CropData.AspectRatioHeight
    self.CropAreaData = PhotoUtil.GetCropRangeDataByAspectRatio(ImgSize.X, ImgSize.Y, self.AspectRatio)
    if not table.is_nil_empty(self.CropAreaData) then
        self.InitFrameSize = FVector2D(self.CropAreaData.CropWidth, self.CropAreaData.CropHeight)
        self.InitFramePos = FVector2D(self.CropAreaData.StartX, self.CropAreaData.StartY)
        self.FrameSize:SetValue(self.CropAreaData.CropWidth, self.CropAreaData.CropHeight)
        self.FramePos:SetValue(self.CropAreaData.StartX, self.CropAreaData.StartY)
        self.CropAreaData.CenterX = (self.CropAreaData.EndX - self.CropAreaData.StartX) * 0.5
        self.CropAreaData.CenterY = (self.CropAreaData.EndY - self.CropAreaData.StartY) * 0.5
    end
end

function PhotoEditMainVM:SetFramePos(NewPosX, NewPosY)
    self.FramePos:SetValue(NewPosX, NewPosY)
    self:SetResetBtnIcon(false)
    if not table.is_nil_empty(self.CropAreaData) then
        self.CropAreaData.StartX = NewPosX
        self.CropAreaData.StartY = NewPosY
        self.CropAreaData.EndX = NewPosX + self.CropAreaData.CropWidth
        self.CropAreaData.EndY = NewPosY + self.CropAreaData.CropHeight
        self.CropAreaData.CenterX = (self.CropAreaData.EndX - self.CropAreaData.StartX) * 0.5
        self.CropAreaData.CenterY = (self.CropAreaData.EndY - self.CropAreaData.StartY) * 0.5
        self.FrameChangeNum = self.FrameChangeNum + 1
    end
end

function PhotoEditMainVM:SetFrameSize(NewSizeX, NewSizeY)
    self.FrameSize:SetValue(NewSizeX, NewSizeY)
    self:SetResetBtnIcon(false)
    if not table.is_nil_empty(self.CropAreaData) then
        self.CropAreaData.CropWidth = NewSizeX
        self.CropAreaData.CropHeight = NewSizeY
        self.CropAreaData.EndX = self.CropAreaData.StartX + NewSizeX
        self.CropAreaData.EndY = self.CropAreaData.StartY + NewSizeY
        self.CropAreaData.CenterX = (self.CropAreaData.EndX - self.CropAreaData.StartX) * 0.5
        self.CropAreaData.CenterY = (self.CropAreaData.EndY - self.CropAreaData.StartY) * 0.5
        self.FrameChangeNum = self.FrameChangeNum + 1
    end
end

function PhotoEditMainVM:RestoreEditInitialValues()
    self.ImageSize:SetValue(self.InitDisplayImgSize.X, self.InitDisplayImgSize.Y)
    self.ImagePos:SetValue(0, 0)
    self.ImageScale = self.InitDisplayImgScale
    self:SetFramePos(self.InitFramePos.X, self.InitFramePos.Y)
    self:SetFrameSize(self.InitFrameSize.X, self.InitFrameSize.Y)
    self:SetResetBtnIcon(true)
end

function PhotoEditMainVM:SetPhotoImageData(Scale, ImgPosX, ImgPosY, NewImgSizeX, NewImgSizeY)
	self.ImageScale = Scale
	self.ImagePos:SetValue(ImgPosX, ImgPosY)
	self.ImageSize:SetValue(NewImgSizeX, NewImgSizeY)
    self:SetResetBtnIcon(false)
end

function PhotoEditMainVM:SetPhotoImagePosData(ImgPosX, ImgPosY)
	self.ImagePos:SetValue(ImgPosX, ImgPosY)
    self:SetResetBtnIcon(false)
end

function PhotoEditMainVM:SetResetBtnIcon(isGrey)
    if self.IsGreyResetBtn == isGrey then
        return
    end
    local Icon = isGrey and ResetBtnGreyImg or ResetBtnNormlImg
    self.IsGreyResetBtn = isGrey
    self.ResetBtnIcon = Icon
end

return PhotoEditMainVM