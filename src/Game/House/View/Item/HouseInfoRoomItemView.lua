---
--- Author: mingyyzhang
--- DateTime: 2025-06-17 19:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local RoomItemVM = require("Game/House/VM/Item/HouseInfoRoomItemVM")
local PhotoDefine = require("Game/Photo/PhotoDefine")

---@class HouseInfoRoomItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommHead CommHeadView
---@field Icon UFImage
---@field ImgPhoto UFImage
---@field PanelAvailability UFCanvasPanel
---@field PanelLikeTag UFCanvasPanel
---@field PanelRoomHide UFCanvasPanel
---@field TextAvailability UFTextBlock
---@field TextHide UFTextBlock
---@field TextLike UFTextBlock
---@field TextName UFTextBlock
---@field TextRoomNumber UFTextBlock
---@field imgPaper UFImage
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoRoomItemView = LuaClass(UIView, true)

function HouseInfoRoomItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommHead = nil
	--self.Icon = nil
	--self.ImgPhoto = nil
	--self.PanelAvailability = nil
	--self.PanelLikeTag = nil
	--self.PanelRoomHide = nil
	--self.TextAvailability = nil
	--self.TextHide = nil
	--self.TextLike = nil
	--self.TextName = nil
	--self.TextRoomNumber = nil
	--self.imgPaper = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoRoomItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommHead)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoRoomItemView:OnInit()
	self.Binders = { {"PanelAvailabilityVisibility", UIBinderSetIsVisible.New(self, self.PanelAvailability) },
					{"PanelRoomHideVisibility", UIBinderSetIsVisible.New(self, self.PanelRoomHide) },
					{"ImgPhotoVisibility", UIBinderSetIsVisible.New(self, self.ImgPhoto) },
					 {"ImgPaperVisibility", UIBinderSetIsVisible.New(self, self.imgPaper) },
					 {"PanelLikeTagVisibility", UIBinderSetIsVisible.New(self, self.PanelLikeTag) },
					 {"CommHeadVisibility", UIBinderSetIsVisible.New(self, self.CommHead) },
					{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.Icon) },
					{"TextLike", UIBinderSetText.New(self, self.TextLike) },
					{"TextHide", UIBinderSetText.New(self, self.TextHide) },
					{"TextName", UIBinderSetText.New(self, self.TextName) },
					{"RoomNumber", UIBinderSetText.New(self, self.TextRoomNumber) },
					{"TextAvailability", UIBinderSetText.New(self, self.TextAvailability) },}
	
end

function HouseInfoRoomItemView:OnDestroy()

end

function HouseInfoRoomItemView:OnShow()
	if self.ViewModel.OwnerID then
		self.CommHead:SetInfo(self.ViewModel.OwnerID)
	end

	if self.ViewModel.Url and self.ViewModel.Url ~= "" then
		self:DownloadPic(self.ViewModel.Url)
	end
end

function HouseInfoRoomItemView:OnHide()

end

function HouseInfoRoomItemView:OnRegisterUIEvent()

end

function HouseInfoRoomItemView:OnRegisterGameEvent()

end

function HouseInfoRoomItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = self.Params.Data
	if nil == self.ViewModel then
		return
	end
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function HouseInfoRoomItemView:DownloadPic(Url)
	if not Url then
		return
	end
	local MaxRequest = PhotoDefine.CropAlreadyImgDownloadMax
	local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("PhotoArmyMemberImg", true, MaxRequest)
	ImageDownloader.OnSuccess:Add(ImageDownloader,
			function(_, texture)
				if texture then
					self.ViewModel.ImgPhotoVisibility = true
					self.ViewModel.PanelLoadingVisibility = false
					FLOG_INFO("[HouseInfoRoomItemView] download image success. = %s", Url)
					local AlreadyWidget = self.ImgPhoto
					UIUtil.ImageSetMaterialTextureParameterValue(AlreadyWidget, 'Texture', texture)
				end
			end
	)
	ImageDownloader.OnFail:Add(ImageDownloader,
			function()
				FLOG_INFO("[HouseInfoRoomItemView] download image failed. = %s", Url)
			end
	)
	ImageDownloader:Start(Url, "", true)
	self.ImageDownloader = ImageDownloader
end

return HouseInfoRoomItemView