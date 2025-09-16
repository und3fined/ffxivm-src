---
--- Author: Administrator
--- DateTime: 2023-04-14 15:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIBinderSetText = require("Binder/UIBinderSetText")

---@class FishIngholeWindowsTimeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextEndDate UFTextBlock
---@field TextEndTime UFTextBlock
---@field TextMinute UFTextBlock
---@field TextStartDate UFTextBlock
---@field TextStartTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeWindowsTimeItemView = LuaClass(UIView, true)

function FishIngholeWindowsTimeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextEndDate = nil
	--self.TextEndTime = nil
	--self.TextMinute = nil
	--self.TextStartDate = nil
	--self.TextStartTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeWindowsTimeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeWindowsTimeItemView:OnInit()
	self.Binders = {
		{ "StartDate", UIBinderSetText.New(self, self.TextStartDate) },
		{ "StartTime", UIBinderSetText.New(self, self.TextStartTime) },
		{ "Duration", UIBinderSetText.New(self, self.TextMinute) },
		{ "EndDate", UIBinderSetText.New(self, self.TextEndDate) },
		{ "EndTime", UIBinderSetText.New(self, self.TextEndTime) },
	}
end

function FishIngholeWindowsTimeItemView:OnDestroy()

end

function FishIngholeWindowsTimeItemView:OnShow()

end

function FishIngholeWindowsTimeItemView:OnHide()

end

function FishIngholeWindowsTimeItemView:OnRegisterUIEvent()

end

function FishIngholeWindowsTimeItemView:OnRegisterGameEvent()

end

function FishIngholeWindowsTimeItemView:OnRegisterBinder()
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

return FishIngholeWindowsTimeItemView