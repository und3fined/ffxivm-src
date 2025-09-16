---
--- Author: yutingzhan
--- DateTime: 2025-03-13 15:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")


---@class UpgradeTaskItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImage_98 UFImage
---@field IconCompleted UFImage
---@field IconTask UFImage
---@field TextTask UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local UpgradeTaskItemView = LuaClass(UIView, true)

function UpgradeTaskItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImage_98 = nil
	--self.IconCompleted = nil
	--self.IconTask = nil
	--self.TextTask = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function UpgradeTaskItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function UpgradeTaskItemView:OnInit()
	self.Binders = {
		{"TaskText", UIBinderSetText.New(self, self.TextTask)},
		{"IsTaskCompleted", UIBinderSetIsVisible.New(self, self.IconCompleted)},
		{"ImageColor", UIBinderSetColorAndOpacityHex.New(self, self.FImage_98)},
		{"IconTask", UIBinderSetImageBrush.New(self, self.IconTask)},
	}
end

function UpgradeTaskItemView:OnDestroy()

end

function UpgradeTaskItemView:OnShow()

end

function UpgradeTaskItemView:OnHide()

end

function UpgradeTaskItemView:OnRegisterUIEvent()

end

function UpgradeTaskItemView:OnRegisterGameEvent()

end

function UpgradeTaskItemView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	local ViewModel = self.Params.Data

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
end

return UpgradeTaskItemView