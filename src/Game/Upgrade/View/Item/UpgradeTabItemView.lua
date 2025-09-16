---
--- Author: yutingzhan
--- DateTime: 2025-03-12 19:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
---@class UpgradeTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconLock USizeBox
---@field ImgSelect UFImage
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local UpgradeTabItemView = LuaClass(UIView, true)

function UpgradeTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconLock = nil
	--self.ImgSelect = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function UpgradeTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function UpgradeTabItemView:OnInit()
	self.Binders = {
		{"TextTime", UIBinderSetText.New(self, self.TextTime)},
		{"IsLock", UIBinderSetIsVisible.New(self, self.IconLock)},
	}
end

function UpgradeTabItemView:OnDestroy()

end

function UpgradeTabItemView:OnShow()

end

function UpgradeTabItemView:OnHide()

end

function UpgradeTabItemView:OnRegisterUIEvent()

end

function UpgradeTabItemView:OnRegisterGameEvent()

end

function UpgradeTabItemView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	local ViewModel = self.Params.Data

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
end

function UpgradeTabItemView:OnSelectChanged(IsSelected)
	if IsSelected and not self.ViewModel.IsLock then
		UIUtil.SetIsVisible(self.ImgSelect, true)
	else
		UIUtil.SetIsVisible(self.ImgSelect, false)
	end
end

return UpgradeTabItemView