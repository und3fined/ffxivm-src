---
--- Author: Administrator
--- DateTime: 2024-04-01 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class FootPrintListContentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Horizontalschedule UFHorizontalBox
---@field IconCheck UFImage
---@field IconDot UFImage
---@field TextDate UFTextBlock
---@field TextSchedule UFTextBlock
---@field TextSubtitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FootPrintListContentItemView = LuaClass(UIView, true)

function FootPrintListContentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Horizontalschedule = nil
	--self.IconCheck = nil
	--self.IconDot = nil
	--self.TextDate = nil
	--self.TextSchedule = nil
	--self.TextSubtitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FootPrintListContentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FootPrintListContentItemView:OnInit()
	self.Binders = {
		{"ItemCompleteName", UIBinderSetText.New(self, self.TextSubtitle)},
		{"Score", UIBinderSetText.New(self, self.TextSchedule)},
		{"AccomplishTime", UIBinderSetText.New(self, self.TextDate)},
		{"bComplete", UIBinderSetIsVisible.New(self, self.IconCheck)},
		{"bComplete", UIBinderSetIsVisible.New(self, self.Horizontalschedule)},
		{"bComplete", UIBinderSetIsVisible.New(self, self.IconDot, true)},
	}
end

function FootPrintListContentItemView:OnDestroy()

end

function FootPrintListContentItemView:OnShow()

end

function FootPrintListContentItemView:OnHide()

end

function FootPrintListContentItemView:OnRegisterUIEvent()

end

function FootPrintListContentItemView:OnRegisterGameEvent()

end

function FootPrintListContentItemView:OnRegisterBinder()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return FootPrintListContentItemView