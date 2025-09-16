---
--- Author: peterxie
--- DateTime:
--- Description: 玩家肖像显示 参考PersonInfoPortraitItemView
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local FLOG_INFO = _G.FLOG_INFO
local UImageDownloader = _G.UE.UImageDownloader
local MaxSavedFileNum = PersonPortraitDefine.MaxSavedPortraitImageNum


---@class CommonPlayerPortraitItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgPortrait UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonPlayerPortraitItemView = LuaClass(UIView, true)

function CommonPlayerPortraitItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgPortrait = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonPlayerPortraitItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonPlayerPortraitItemView:OnInit()
	self.Binders = {
		{ "PortraitUrlID", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedPortraitUrlFlag) },
	}

	self.RichTextNone:SetText(LSTR(620135))
	self.TextLogin:SetText(LSTR(620140))
end

function CommonPlayerPortraitItemView:OnDestroy()

end

function CommonPlayerPortraitItemView:OnShow()

end

function CommonPlayerPortraitItemView:OnHide()
	local ImageDownloader = self.ImageDownloader
	if ImageDownloader and ImageDownloader:IsValid() then
		ImageDownloader:Stop()
	end
end

function CommonPlayerPortraitItemView:OnRegisterUIEvent()

end

function CommonPlayerPortraitItemView:OnRegisterGameEvent()

end

function CommonPlayerPortraitItemView:OnRegisterBinder()
	local ViewModel = self.Params and self.Params.Data or nil
	if not ViewModel then
		return
	end
	local RoleVM = _G.RoleInfoMgr:FindRoleVM(ViewModel.RoleID, true)
	self.RoleVM = RoleVM
	self:RegisterBinders(self.RoleVM, self.Binders)
end

function CommonPlayerPortraitItemView:SetDefaultIcon()
	local RoleVM = self.RoleVM
	if nil == RoleVM then
		return
	end

	local DefaultIcon = RoleVM.PortraitDefaultIcon
	if string.isnilorempty(DefaultIcon) then
		return
	end

	-- UIUtil.ImageSetBrushFromAssetPath(self.ImgPortrait, DefaultIcon)
	-- UIUtil.SetIsVisible(self.ImgPortrait, true)

	UIUtil.SetIsVisible(self.ScaleBoxEnpty, true)
end

function CommonPlayerPortraitItemView:OnValueChangedPortraitUrlFlag()
	UIUtil.SetIsVisible(self.ImgPortrait, false)
	UIUtil.SetIsVisible(self.ScaleBoxEnpty, false)
	UIUtil.SetIsVisible(self.ScaleBoxLogin, true)

	local RoleVM = self.RoleVM or {}
	local Url = RoleVM.PortraitUrl
	if string.isnilorempty(Url) then
		self:SetDefaultIcon()
		return
	end

    local ImageDownloader = UImageDownloader.MakeDownloader("PortraitImage", true, MaxSavedFileNum)
    ImageDownloader.OnSuccess:Add(ImageDownloader,
		function(_, texture)
			FLOG_INFO("[CommonPlayerPortraitItemView:OnValueChangedPortraitUrlFlag] OnSuccess")

			if texture then
				UIUtil.SetIsVisible(self.ScaleBoxLogin, false)
				UIUtil.ImageSetBrushResourceObject(self.ImgPortrait, texture)
				UIUtil.SetIsVisible(self.ImgPortrait, true)
			end
		end
    )

    ImageDownloader.OnFail:Add(ImageDownloader,
		function()
			FLOG_INFO("[CommonPlayerPortraitItemView:OnValueChangedPortraitUrlFlag] OnFail")

			self:SetDefaultIcon()
		end
	)

    ImageDownloader:Start(Url, RoleVM.PortraitUrlHashEx or "", true)
	self.ImageDownloader = ImageDownloader
end

return CommonPlayerPortraitItemView