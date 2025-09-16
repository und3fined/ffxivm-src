---
--- Author: xingcaicao
--- DateTime: 2023-04-21 14:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local UImageDownloader = _G.UE.UImageDownloader
local MaxSavedFileNum = PersonPortraitDefine.MaxSavedPortraitImageNum

---@class PersonInfoPortraitItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpackEmpty CommBackpackEmptyView
---@field EmptyPanel UFCanvasPanel
---@field ImgPortrait UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoPortraitItemView = LuaClass(UIView, true)

function PersonInfoPortraitItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackpackEmpty = nil
	--self.EmptyPanel = nil
	--self.ImgPortrait = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoPortraitItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpackEmpty)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoPortraitItemView:OnInit()
	self.Binders = {
		{ "PortraitUrlID", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedPortraitUrlFlag) },
	}

	-- 暂未编辑肖像
	self.CommBackpackEmpty:SetTipsContent(_G.LSTR(620119))
end

function PersonInfoPortraitItemView:OnDestroy()

end

function PersonInfoPortraitItemView:OnShow()

end

function PersonInfoPortraitItemView:OnHide()
	local ImageDownloader = self.ImageDownloader
	if ImageDownloader and ImageDownloader:IsValid() then
		ImageDownloader:Stop()
	end
end

function PersonInfoPortraitItemView:OnRegisterUIEvent()

end

function PersonInfoPortraitItemView:OnRegisterGameEvent()

end

function PersonInfoPortraitItemView:OnRegisterBinder()
	local RoleVM = PersonInfoVM.RoleVM
	self.RoleVM = RoleVM
	if nil == RoleVM then
		return
	end

	self:RegisterBinders(RoleVM, self.Binders)
end

function PersonInfoPortraitItemView:OnValueChangedPortraitUrlFlag()
	UIUtil.SetIsVisible(self.EmptyPanel, false)
	UIUtil.SetIsVisible(self.ImgPortrait, false)

	local RoleVM = self.RoleVM or {}
	local Url = RoleVM.PortraitUrl
	if string.isnilorempty(Url) then
		UIUtil.SetIsVisible(self.EmptyPanel, true)
		return
	end

    local ImageDownloader = UImageDownloader.MakeDownloader("PortraitImage", true, MaxSavedFileNum)
    ImageDownloader.OnSuccess:Add(ImageDownloader,
		function(_, texture)
			if texture then
				print("download image success.")

				UIUtil.ImageSetBrushResourceObject(self.ImgPortrait, texture)
				UIUtil.SetIsVisible(self.ImgPortrait, true)
			end
		end
    )

    ImageDownloader.OnFail:Add(ImageDownloader,
		function()
			print("download image failed.")

			UIUtil.SetIsVisible(self.EmptyPanel, true)
		end
	)
		
    ImageDownloader:Start(Url, RoleVM.PortraitUrlHashEx or "", true)
	self.ImageDownloader = ImageDownloader
end

-- function PersonInfoPortraitItemView:OnBinderPortUrl()
-- 	-- self.TextJobLevel:SetText(string.format(_G.LSTR(620001), tostring(V)))
-- 	-- UIUtil.SetIsVisible(self.ImgPlayerAppearance, false)

-- 	local ViewModel = self.ViewModel or {}
-- 	local Url = ViewModel.Icon or ""
-- 	_G.FLOG_INFO('[Photo][PhotoTemplateItemView][OnBinderPortUrl] Download image start url = ' .. tostring(Url))

-- 	if string.isnilorempty(Url) then
-- 		self:SetDefaultTemplateIcon()
-- 		return
-- 	end

--     local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("TemplateImage" .. tostring(ViewModel.ID), true, PhotoDefine.TemplateDownloadMax)
--     ImageDownloader.OnSuccess:Add(ImageDownloader,
-- 		function(_, texture)
-- 			if texture then
-- 				_G.FLOG_INFO('[Photo][PhotoTemplateItemView][OnBinderPortUrl] Download image success')
-- 				UIUtil.ImageSetBrushResourceObject(self.ImgPic, texture)
-- 				UIUtil.SetIsVisible(self.ImgPic, true)
-- 			end
-- 		end
--     )

--     ImageDownloader.OnFail:Add(ImageDownloader,
-- 		function()
-- 			_G.FLOG_ERROR('[Photo][PhotoTemplateItemView][OnBinderPortUrl] Download image failed')
-- 			self:SetDefaultTemplateIcon()
-- 		end
-- 	)
		
--     ImageDownloader:Start(Url, "", true)
-- end

return PersonInfoPortraitItemView