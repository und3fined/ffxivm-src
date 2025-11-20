---
--- Author: Administrator
--- DateTime: 2025-07-22 20:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class OpsReturnBannerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBanner UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsReturnBannerItemView = LuaClass(UIView, true)

function OpsReturnBannerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBanner = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsReturnBannerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsReturnBannerItemView:OnInit()
	self.Binders = {
		{"BannerImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgBanner)},
	}

end

function OpsReturnBannerItemView:OnDestroy()

end

function OpsReturnBannerItemView:OnShow()

end

function OpsReturnBannerItemView:OnHide()

end

function OpsReturnBannerItemView:OnRegisterUIEvent()

end

function OpsReturnBannerItemView:OnRegisterGameEvent()

end

function OpsReturnBannerItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	if nil  == self.Binders then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)

end

return OpsReturnBannerItemView