---
--- Author: yutingzhan
--- DateTime: 2025-02-21 19:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")

---@class OpsVersionNoticeContentListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgPoster UFImage
---@field TextTitle UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsVersionNoticeContentListItemView = LuaClass(UIView, true)

function OpsVersionNoticeContentListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgPoster = nil
	--self.TextTitle = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsVersionNoticeContentListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsVersionNoticeContentListItemView:OnInit()
	self.Binders = {
		{"TextTaskTitle", UIBinderSetText.New(self, self.TextTitle)},
	}
end

function OpsVersionNoticeContentListItemView:OnDestroy()
end

function OpsVersionNoticeContentListItemView:OnShow()
	if self.Params == nil or self.Params.Data == nil then
		return
	end
	local ImgPoster = self.Params.Data.ImgPoster
	if ImgPoster == nil then
		return
	end

	if string.match(ImgPoster, "http") then
		self:SetUrlPic(ImgPoster)
	else
		UIUtil.ImageSetBrushFromAssetPath(self.ImgPoster, ImgPoster)
	end
end

function OpsVersionNoticeContentListItemView:OnHide()
	local ImageDownloader = self.ImageDownloader
	if ImageDownloader and ImageDownloader:IsValid() then
		ImageDownloader:Stop()
	end
end

function OpsVersionNoticeContentListItemView:OnRegisterUIEvent()

end

function OpsVersionNoticeContentListItemView:OnRegisterGameEvent()
end

function OpsVersionNoticeContentListItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local VM = Params.Data
	if VM == nil then
		return
	end
	self:RegisterBinders(VM, self.Binders)
end

function OpsVersionNoticeContentListItemView:OnSelectChanged(IsSelected)
	self.ToggleBtn:SetChecked(IsSelected)
end

function OpsVersionNoticeContentListItemView:SetUrlPic(Url)

	if string.isnilorempty(Url) then
		return
	end

    local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("OpsVersionContentCDNPoster", true, 100)
    ImageDownloader.OnSuccess:Add(ImageDownloader,
		function(_, texture)
			if texture then
				UIUtil.ImageSetBrushResourceObject(self.ImgPoster, texture)
				UIUtil.SetIsVisible(self.ImgPoster, true)
			end
		end
    )

    ImageDownloader.OnFail:Add(ImageDownloader,
		function()
			UIUtil.SetIsVisible(self.ImgPoster, false)
		end
	)

    ImageDownloader:Start(Url, "", true)
	self.ImageDownloader = ImageDownloader
end

return OpsVersionNoticeContentListItemView