--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-02 15:19
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-25 15:04:11
FilePath: \Script\Game\Share\View\ShareMainPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ShareMgr = require("Game/Share/ShareMgr")
local UIViewID = require("Define/UIViewID")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ShareVM = require("Game/Share/VM/ShareVM")
local ShareDefine = require("Game/Share/ShareDefine")
local CommonUtil = require("Utils/CommonUtil")

local PreviewScale = 0.71

---@class ShareMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bkg02 CommonBkg02View
---@field BkgMask CommonBkgMaskView
---@field BtnSave UFButton
---@field CloseBtn CommonCloseBtnView
---@field Img UFImage
---@field PanelImgSize USizeBox
---@field RTImage UFImage
---@field SingleBoxQRCode CommSingleBoxView
---@field SingleBoxRoleInfo CommSingleBoxView
---@field TableViewIcon UTableView
---@field TextSave UFTextBlock
---@field AnimIn0 UWidgetAnimation
---@field AnimInPhoto UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShareMainPanelView = LuaClass(UIView, true)

function ShareMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bkg02 = nil
	--self.BkgMask = nil
	--self.BtnSave = nil
	--self.CloseBtn = nil
	--self.Img = nil
	--self.PanelImgSize = nil
	--self.RTImage = nil
	--self.SingleBoxQRCode = nil
	--self.SingleBoxRoleInfo = nil
	--self.TableViewIcon = nil
	--self.TextSave = nil
	--self.AnimIn0 = nil
	--self.AnimInPhoto = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShareMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bkg02)
	self:AddSubView(self.BkgMask)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.SingleBoxQRCode)
	self:AddSubView(self.SingleBoxRoleInfo)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShareMainPanelView:OnInit()
	self.bShowQRCode = true
	self.bShowRole =  true

	self.SingleBoxQRCode.Callback = function (_, bCheckded)
		if self then
			self.bShowQRCode = bCheckded
			self:UpdateShareContent()
		end
	end

	self.SingleBoxRoleInfo.Callback = function (_, bChecked)
		if self then
			self.bShowRole = bChecked
			self:UpdateShareContent()
		end
	end

	self:GetShareContentView()

	self.TbvImageShare = UIAdapterTableView.CreateAdapter(self, self.TableViewIcon)

	self.Binders = {
		{"AcitivityImageShareItemList", UIBinderUpdateBindableList.New(self, self.TbvImageShare)}
	}

	-- local DataValues = ShareMgr.CreateShareItemDataList(ShareMgr:GetDefaultAppsForActivityImageShare(), ShareDefine.ShareTypeEnum.IMAGE, {
	-- 		ImagePath = ShareMgr.GetImageLocalSharePath(nil),
	-- 		ThumbPath = "http://mat1.gtimg.com/www/qq2018/imgs/qq_logo_2018x2.png",
	-- 	})
	-- for _, V in ipairs(DataValues) do
	-- 	V.ShareObject:SetShareCallbackBefore(self.UpdateShareContent, self, true)
	-- end
	-- ShareVM.AcitivityImageShareItemList:UpdateByValues(DataValues)
end

function ShareMainPanelView:OnRegisterBinder()
	self:RegisterBinders(ShareVM, self.Binders)
end

function ShareMainPanelView:OnShow()
	local DataValues = ShareMgr.CreateShareItemDataList(ShareMgr:GetDefaultAppsForActivityImageShare(), ShareDefine.ShareTypeEnum.IMAGE, {
			--ImagePath = ShareMgr.GetImageLocalSharePath(nil),
			ThumbPath = "http://mat1.gtimg.com/www/qq2018/imgs/qq_logo_2018x2.png",
		})
	for _, V in ipairs(DataValues) do
		V.ShareObject:SetShareCallbackBefore(self.UpdateShareContent, self, true)
	end

	self.bShowQRCode = ShareMgr:IsShowQRCodeOption()
	self.bShowRole = ShareMgr:IsShowRoleInfoOption()
	UIUtil.SetIsVisible(self.SingleBoxRoleInfo, self.bShowRole)
	UIUtil.SetIsVisible(self.SingleBoxQRCode, self.bShowQRCode)
	if self.bShowRole then
		self.SingleBoxRoleInfo:SetChecked(true, false)
		self.SingleBoxRoleInfo.TextContent:SetText(_G.LSTR(1460001))
	end
	if self.bShowQRCode then
		self.SingleBoxQRCode:SetChecked(true, false)
		self.SingleBoxQRCode.TextContent:SetText(_G.LSTR(1460002))
	end
	ShareVM.AcitivityImageShareItemList:UpdateByValues(DataValues)
	self.TextSave:SetText(_G.LSTR(1460004))
	UIUtil.SetIsVisible(self.Img, false)
	self:UpdateShareContent()

	self:PlayAnimation((self.Params and self.Params.bPhoto) and self.AnimInPhoto or self.AnimIn0)
end

function ShareMainPanelView:OnDestroy()
	self:RemoveContentView()
end

function ShareMainPanelView:OnHide()
	self:RemoveContentView()
	ShareMgr:InitShareInfo()
end

function ShareMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnBtnSaveClick)
end

function ShareMainPanelView:OnBtnSaveClick()
	local ViewUpdateCallBack = function (View)
		View:SetWaterMarkText()
		local SX, SY = self:GetSharePictureSize()
		ShareMgr:GenShareImageFileName()
		local Tex = _G.UE.UUIUtil.CaptureUI(View, self.RTImage.Brush.ResourceObject, SX, SY, true, ShareMgr:GetShareImageFileName())
		-- if self.Params.Tex then
		-- 	_G.UE.UUIUtil.SaveTextureAsFile(self.Params.Tex, ShareMgr.GetImageLocalSharePath("share2.jpg"))
		-- end
		if self:GetShareID() then
			local ScreenRes = _G.UE.UUIUtil.GetScreenResolution()
			if SX * ScreenRes.Y ~= SY * ScreenRes.X then
				-- Tex = _G.UE.UUIUtil.CaptureUI(View, self.RTImage.Brush.ResourceObject, ScreenRes.X * 1.0, ScreenRes.Y * 1.0, false)
			end
		end

		CommonUtil.SaveToGallery(ShareMgr.GetImageLocalSharePath())
	end

	local View = self:GetShareContentView()
	if View then
		View.Params = {
			ShareID = self:GetShareID(),
			bShowRole = self.bShowRole,
			bShowQRCode = self.bShowQRCode,
			QRcodePath = ShareMgr:GetQRCodePath()
		}
		View:Update(ViewUpdateCallBack, View)
	else
		ViewUpdateCallBack(View)
	end
end

function ShareMainPanelView:UpdateShareContent(bSave)
	local ViewUpdateCallBack = function (View)
		View:SetWaterMarkText()

		if self.Params and self.Params.Tex then
			UIUtil.ImageSetBrushResourceObject(View.ImgBG, self.Params.Tex, true)
		end

		local Tex
		if self:GetShareID() then
			local ScreenRes = _G.UE.UUIUtil.GetScreenResolution()
			_G.FLOG_INFO("ShareMainPanelView:UpdateShareContent gen preview tex x: %s, y; %s", ScreenRes.X, ScreenRes.Y)
			Tex = _G.UE.UUIUtil.CaptureUI(View, self.RTImage.Brush.ResourceObject, ScreenRes.X * 1.0, ScreenRes.Y * 1.0, false, "preview.jpg")
		end

		local SX, SY = self:GetSharePictureSize()
		if bSave then
			ShareMgr:GenShareImageFileName()
		end
		local Tex2 = _G.UE.UUIUtil.CaptureUI(View, self.RTImage.Brush.ResourceObject, SX, SY, bSave == true, ShareMgr:GetShareImageFileName())
		UIUtil.SetIsVisible(self.Img, true)
		UIUtil.ImageSetBrushResourceObject(self.Img, Tex or Tex2, true)
	end

	local View = self:GetShareContentView()
	if View then
		View.Params = {
			ShareID = self:GetShareID(),
			bShowRole = self.bShowRole,
			bShowQRCode = self.bShowQRCode,
			QRcodePath = ShareMgr:GetQRCodePath()
		}
		View:Update(ViewUpdateCallBack, View)
	else
		ViewUpdateCallBack(View)
	end
end

function ShareMainPanelView:GetSharePictureSize()
	if self.Params.W and self.Params.H then
		return self.Params.W, self.Params.H
	end

	if self:GetShareID() then
		return 2340, 1080
	end
	return 1920, 1080
end

---@return ShareActivityPanelView | nil
function ShareMainPanelView:GetShareContentView()
	if self.ContentView and self.ContentView.bDestoryed then
		self:RemoveContentView()
	end

	if self.ContentView == nil then
		-- self.ContentView =  _G.UE.UWidgetBlueprintLibrary.Create(self, _G.ObjectMgr:LoadClassSync("WidgetBlueprint'/Game/UI/BP/Share/ShareActivityPanel_UIBP.ShareActivityPanel_UIBP_C'"))
		-- self.ContentView:InitView()
		self.ContentView = WidgetPoolMgr:CreateWidgetSyncByViewID(UIViewID.ShareActivity, true)
		_G.UnLua.Ref(self.ContentView)
	end

	return self.ContentView
end

---@private
function ShareMainPanelView:RemoveContentView()
	if self.ContentView then
		pcall(function ()
			_G.UnLua.Unref(self.ContentView)
		end)
	end
	self.ContentView = nil
	-- _G.ObjectMgr:CollectGarbage(true)
end

function ShareMainPanelView:GetShareID()
	return self.Params and self.Params.ShareID or nil
end

return ShareMainPanelView