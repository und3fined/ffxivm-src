---
--- Author: jususchen
--- DateTime: 2025-03-04 11:35
--- Description:
---

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

---@class NewShareMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bkg02 CommonBkg02View
---@field BkgMask CommonBkgMaskView
---@field BtnSave UFButton
---@field CloseBtn CommonCloseBtnView
---@field Img UFImage
---@field PanelActivities UFCanvasPanel
---@field PanelImgSize USizeBox
---@field PanelScreenshots UFCanvasPanel
---@field RTImage UFImage
---@field ShareActivityPanel ShareActivityPanelView
---@field SingleBoxQRCode CommSingleBoxView
---@field SingleBoxRoleInfo CommSingleBoxView
---@field TableViewIcon UTableView
---@field TextSave UFTextBlock
---@field AnimIn0 UWidgetAnimation
---@field AnimInPhoto UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewShareMainPanelView = LuaClass(UIView, true)

function NewShareMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bkg02 = nil
	--self.BkgMask = nil
	--self.BtnSave = nil
	--self.CloseBtn = nil
	--self.Img = nil
	--self.PanelActivities = nil
	--self.PanelImgSize = nil
	--self.PanelScreenshots = nil
	--self.RTImage = nil
	--self.ShareActivityPanel = nil
	--self.SingleBoxQRCode = nil
	--self.SingleBoxRoleInfo = nil
	--self.TableViewIcon = nil
	--self.TextSave = nil
	--self.AnimIn0 = nil
	--self.AnimInPhoto = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewShareMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bkg02)
	self:AddSubView(self.BkgMask)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.ShareActivityPanel)
	self:AddSubView(self.SingleBoxQRCode)
	self:AddSubView(self.SingleBoxRoleInfo)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewShareMainPanelView:OnInit()
	self.bShowQRCode = true
	self.bShowRole =  true
	self:SetQRCodeShowStatus()

	self.SingleBoxQRCode.Callback = function (_, bCheckded)
		if self then
			self.bShowQRCode = bCheckded
			self:SetQRCodeShowStatus()
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

function NewShareMainPanelView:OnDestroy()
	self:RemoveContentView()
end

function NewShareMainPanelView:OnShow()
	local DataValues = ShareMgr.CreateShareItemDataList(ShareMgr:GetDefaultAppsForActivityImageShare(), ShareDefine.ShareTypeEnum.IMAGE, {
		--ImagePath = ShareMgr.GetImageLocalSharePath(nil),
		ThumbPath = "http://mat1.gtimg.com/www/qq2018/imgs/qq_logo_2018x2.png",
	})
	for _, V in ipairs(DataValues) do
		V.ShareObject:SetShareCallbackBefore(self.UpdateShareContent, self, true)
	end

	local SizeBox = (self:GetShareID() and self.Params and self.Params.Tex == nil) and self.PanelActivities or self.PanelScreenshots
	_G.UE.UUIUtil.SetWidgetSlot(self.PanelImgSize, SizeBox)

	self.bShowQRCode = ShareMgr:IsShowQRCodeOption()
	self:SetQRCodeShowStatus()
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
	UIUtil.SetIsVisible(self.ShareActivityPanel, false)
	self:UpdateShareContent()

	self:PlayAnimation((self.Params and self.Params.bPhoto) and self.AnimInPhoto or self.AnimIn0)
end

function NewShareMainPanelView:OnHide()
	self:RemoveContentView()
	self.ShareActivityPanel:ResetResourceRef()
	ShareMgr:InitShareInfo()
end

function NewShareMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnBtnSaveClick)
end

function NewShareMainPanelView:OnBtnSaveClick()
	local ViewUpdateCallBack = function (View)
		View:SetWaterMarkText()
		local SX, SY = self:GetSharePictureSize()
		ShareMgr:GenShareImageFileName()
		_G.UE.UUIUtil.CaptureUI(View, self.RTImage.Brush.ResourceObject, SX, SY, true, ShareMgr:GetShareImageFileName())
		_G.ObjectMgr:CollectGarbage(true)
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

function NewShareMainPanelView:UpdateShareContent(bSave)
	local ViewUpdateCallBack = function (View)
		View:SetWaterMarkText()

		if self.Params and self.Params.Tex then
			UIUtil.ImageSetBrushResourceObject(View.ImgBG, self.Params.Tex, true)
		end

		if View.Params and not View.Params.bSkipCapture then
			local SX, SY = self:GetSharePictureSize()
			if bSave then
				ShareMgr:GenShareImageFileName()
				_G.UE.UUIUtil.CaptureUI(View, self.RTImage.Brush.ResourceObject, SX, SY, bSave == true, ShareMgr:GetShareImageFileName())
				_G.ObjectMgr:CollectGarbage(true)
			end
		end
	end

	do
		self.ShareActivityPanel.Params = {
			ShareID = self:GetShareID(),
			bShowRole = self.bShowRole,
			bShowQRCode = self.bShowQRCode,
			QRcodePath = ShareMgr:GetQRCodePath(),
			bSkipCapture = true,
		}
		self.ShareActivityPanel:Update(function()
			ViewUpdateCallBack(self.ShareActivityPanel)
			if not UIUtil.IsVisible(self.ShareActivityPanel) then
				UIUtil.SetIsVisible(self.ShareActivityPanel, true)
			end
		end, self.ShareActivityPanel)
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
	end
end

function NewShareMainPanelView:GetSharePictureSize()
	if self.Params.W and self.Params.H then
		return self.Params.W, self.Params.H
	end

	if self:GetShareID() then
		return 2340, 1080
	end
	return 1920, 1080
end


---@return ShareActivityPanelView | nil
function NewShareMainPanelView:GetShareContentView()
	if self.ContentView and (self.ContentView.bDestroying or self.ContentView.bDestoryed) then
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
function NewShareMainPanelView:RemoveContentView()
	if self.ContentView then
		self.ContentView:ResetResourceRef()
		pcall(function ()
			_G.UnLua.Unref(self.ContentView)
		end)
		WidgetPoolMgr:RecycleWidget(self.ContentView, 1)
	end
	self.ContentView = nil
	-- _G.ObjectMgr:CollectGarbage(true)
end

function NewShareMainPanelView:GetShareID()
	return self.Params and self.Params.ShareID or nil
end

function NewShareMainPanelView:OnShareWithoutQRCode()
	self.bShowQRCode = false
	self:UpdateShareContent()
end

function NewShareMainPanelView:OnGameEventAppEnterForeground()
	self.bShowQRCode = self.bLastShowQRCode
	self:UpdateShareContent()
end

function NewShareMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ShareWithoutQRCode, self.OnShareWithoutQRCode)
	self:RegisterGameEvent(_G.EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
end

function NewShareMainPanelView:OnRegisterBinder()
	self:RegisterBinders(ShareVM, self.Binders)
end

function NewShareMainPanelView:SetQRCodeShowStatus()
	self.bLastShowQRCode = self.bShowQRCode
end

return NewShareMainPanelView