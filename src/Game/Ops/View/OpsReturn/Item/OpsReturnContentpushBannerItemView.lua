---
--- Author: Administrator
--- DateTime: 2025-07-22 20:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class OpsReturnContentpushBannerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBanner UFImage
---@field TextBanner UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsReturnContentpushBannerItemView = LuaClass(UIView, true)

function OpsReturnContentpushBannerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBanner = nil
	--self.TextBanner = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsReturnContentpushBannerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsReturnContentpushBannerItemView:OnInit()
	self.Binders = {
		{"BannerTitle", UIBinderSetText.New(self, self.TextBanner)},
		{"BannerImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgBanner)},
	}

end

function OpsReturnContentpushBannerItemView:OnDestroy()

end

function OpsReturnContentpushBannerItemView:OnShow()

end

function OpsReturnContentpushBannerItemView:OnHide()

end

function OpsReturnContentpushBannerItemView:OnRegisterUIEvent()

end

function OpsReturnContentpushBannerItemView:OnRegisterGameEvent()

end

function OpsReturnContentpushBannerItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return OpsReturnContentpushBannerItemView