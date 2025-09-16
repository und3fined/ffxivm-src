---
--- Author: Administrator
--- DateTime: 2024-01-30 10:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PhotoDefine = require("Game/Photo/PhotoDefine")

local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetRenderTransformAngle = require("Binder/UIBinderSetRenderTransformAngle")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")


---@class PhotoTemplateItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field BtnSelect UFButton
---@field ImgPic UFImage
---@field ImgSelect UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoTemplateItemView = LuaClass(UIView, true)

function PhotoTemplateItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.BtnSelect = nil
	--self.ImgPic = nil
	--self.ImgSelect = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoTemplateItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoTemplateItemView:OnInit()
	self.Binders = 
	{
		{ "Name", 				UIBinderSetText.New(self, self.TextName) },
		{ "IsShowDelete", 			UIBinderSetIsVisible.New(self, self.BtnDelete, nil, true) },

		{ "IsCust", 			UIBinderSetIsVisible.New(self, self.ImgPic, true) },
		{ "IsCust", 			UIBinderSetIsVisible.New(self, self.ImgPic02) },
		{ "Icon", 				UIBinderValueChangedCallback.New(self, nil, self.OnBinderPortUrl) },
		{ "IsSelected", 		UIBinderSetIsVisible.New(self, self.ImgSelect) },
	}
end

function PhotoTemplateItemView:OnDestroy()

end

function PhotoTemplateItemView:OnShow()

end

function PhotoTemplateItemView:OnHide()
	local ImageDownloader = self.ImageDownloader
	if ImageDownloader and ImageDownloader:IsValid() then
		ImageDownloader:Stop()
	end

end

function PhotoTemplateItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,              self.BtnDelete,    			self.OnBtnDelete)
end

function PhotoTemplateItemView:OnRegisterGameEvent()

end

function PhotoTemplateItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function PhotoTemplateItemView:OnBinderPortUrl()
	-- self.TextJobLevel:SetText(string.format(_G.LSTR(630001), tostring(V)))
	UIUtil.SetIsVisible(self.ImgPic, not self.ViewModel.IsCust)
	UIUtil.SetIsVisible(self.ImgPic02, self.ViewModel.IsCust)

	if not self.ViewModel.IsCust then
		-- self:SetDefaultTemplateIcon()
		UIUtil.ImageSetBrushFromAssetPath(self.ImgPic, self.ViewModel.Icon)
		return
	end
	
	local ViewModel = self.ViewModel or {}
	local Url = ViewModel.Icon or ""
	_G.FLOG_INFO('[Photo][PhotoTemplateItemView][OnBinderPortUrl] Download image start url = ' .. tostring(Url))

	if string.isnilorempty(Url) then
		self:SetDefaultTemplateIcon()
		return
	end

    local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("TemplateImage" .. tostring(ViewModel.ID), true, PhotoDefine.TemplateDownloadMax)
    ImageDownloader.OnSuccess:Add(ImageDownloader,
		function(_, texture)
			if texture then
				_G.FLOG_INFO('[Photo][PhotoTemplateItemView][OnBinderPortUrl] Download image success' .. tostring(Url))
				-- UIUtil.ImageSetBrushResourceObject(self.ImgPic, texture)
                UIUtil.ImageSetMaterialTextureParameterValue(self.ImgPic02, 'Texture', texture)
				UIUtil.SetIsVisible(self.ImgPic02, true)
			end
		end
    )

    ImageDownloader.OnFail:Add(ImageDownloader,
		function()
			_G.FLOG_ERROR('[Photo][PhotoTemplateItemView][OnBinderPortUrl] Download image failed')
			self:SetDefaultTemplateIcon()
		end
	)
		
    ImageDownloader:Start(Url, "", true)
	self.ImageDownloader = ImageDownloader
end

function PhotoTemplateItemView:SetDefaultTemplateIcon()
	UIUtil.ImageSetBrushFromAssetPath(self.ImgPic, PhotoDefine.TemplateImageDefault)
end

function PhotoTemplateItemView:OnSelectChanged(IsSelected)
	local Params = self.Params
	if nil == Params then
		return
	end

	local VM = Params.Data
	if nil == VM then
		return
	end

	-- print('test iscust = ' .. tostring(VM.IsCust))

	VM.IsSelected = IsSelected
end

function PhotoTemplateItemView:OnBtnDelete()
	local VM = self.ViewModel
	_G.MsgBoxUtil.ShowMsgBoxTwoOp(UIView , _G.LSTR(630006), _G.LSTR(630007), function()
		_G.PhotoMgr:RemCustTemplate(VM.ID)
		_G.MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.TemplateDelete, nil)

	end, nil, _G.LSTR(630008), _G.LSTR(630024))
end

return PhotoTemplateItemView