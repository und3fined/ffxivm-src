---
--- Author: Administrator
--- DateTime: 2024-11-29 16:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")

---@class PVPPerformanceDetailItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ProgressBar UFProgressBar
---@field TextDesc UFTextBlock
---@field TextValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPPerformanceDetailItemView = LuaClass(UIView, true)

function PVPPerformanceDetailItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ProgressBar = nil
	--self.TextDesc = nil
	--self.TextValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPPerformanceDetailItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPPerformanceDetailItemView:OnInit()
	self.Binders = {
		{ "Desc", UIBinderSetText.New(self, self.TextDesc) },
		{ "Value", UIBinderSetText.New(self, self.TextValue) },
		{ "Percent", UIBinderSetPercent.New(self, self.ProgressBar) },
	}
end

function PVPPerformanceDetailItemView:OnDestroy()

end

function PVPPerformanceDetailItemView:OnShow()

end

function PVPPerformanceDetailItemView:OnHide()

end

function PVPPerformanceDetailItemView:OnRegisterUIEvent()

end

function PVPPerformanceDetailItemView:OnRegisterGameEvent()

end

function PVPPerformanceDetailItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local VM = Params.Data
	if VM == nil then return end

	self:RegisterBinders(VM, self.Binders)
end

return PVPPerformanceDetailItemView