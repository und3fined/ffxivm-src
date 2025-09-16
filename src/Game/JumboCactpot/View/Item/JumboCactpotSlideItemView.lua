---
--- Author: Administrator
--- DateTime: 2023-09-18 09:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class JumboCactpotSlideItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgChoose UFImage
---@field ImgNoChoose UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotSlideItemView = LuaClass(UIView, true)

function JumboCactpotSlideItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgChoose = nil
	--self.ImgNoChoose = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotSlideItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotSlideItemView:OnInit()
	self.Binders = {
		{ "bIsSelect", UIBinderSetIsVisible.New(self, self.ImgChoose)},
		{ "bIsNotSelect", UIBinderSetIsVisible.New(self, self.ImgNoChoose)},
	}
end

function JumboCactpotSlideItemView:OnDestroy()

end

function JumboCactpotSlideItemView:OnShow()

end

function JumboCactpotSlideItemView:OnHide()

end

function JumboCactpotSlideItemView:OnRegisterUIEvent()

end

function JumboCactpotSlideItemView:OnRegisterGameEvent()

end

function JumboCactpotSlideItemView:OnRegisterBinder()
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

return JumboCactpotSlideItemView