---
--- Author: Administrator
--- DateTime: 2025-03-13 14:21
--- Description:玩法说明兴趣点列表ItemView
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class DepartureBannerWinListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FTextBlock_55 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureBannerWinListItemView = LuaClass(UIView, true)

function DepartureBannerWinListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FTextBlock_55 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureBannerWinListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureBannerWinListItemView:OnInit()
	self.Binders = {
		{"Content", UIBinderSetText.New(self, self.FTextBlock_55)},
	}
end

function DepartureBannerWinListItemView:OnDestroy()

end

function DepartureBannerWinListItemView:OnShow()

end

function DepartureBannerWinListItemView:OnHide()

end

function DepartureBannerWinListItemView:OnRegisterUIEvent()

end

function DepartureBannerWinListItemView:OnRegisterGameEvent()

end

function DepartureBannerWinListItemView:OnRegisterBinder()
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

return DepartureBannerWinListItemView