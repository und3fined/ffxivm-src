---
--- Author: Administrator
--- DateTime: 2025-03-13 14:21
--- Description:玩法说明列表ItemView
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class DepartureBannerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBanner UFImage
---@field TextBanner UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureBannerItemView = LuaClass(UIView, true)

function DepartureBannerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBanner = nil
	--self.TextBanner = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureBannerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureBannerItemView:OnInit()
	self.Binders = {
		{"Title", UIBinderSetText.New(self, self.TextBanner)},
		{"IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgBanner)},
	}
end

function DepartureBannerItemView:OnDestroy()

end

function DepartureBannerItemView:OnShow()

end

function DepartureBannerItemView:OnHide()

end

function DepartureBannerItemView:OnRegisterUIEvent()

end

function DepartureBannerItemView:OnRegisterGameEvent()

end

function DepartureBannerItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end

	self:RegisterBinders(self.ViewModel, self.Binders)
end

return DepartureBannerItemView