---
--- Author: yutingzhan
--- DateTime: 2025-08-27 14:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
---@class OpsGirlsDayStarTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconLock UFImage
---@field IconReceive UFImage
---@field ImgSelect UFImage
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsGirlsDayStarTabItemView = LuaClass(UIView, true)

function OpsGirlsDayStarTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconLock = nil
	--self.IconReceive = nil
	--self.ImgSelect = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsGirlsDayStarTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsGirlsDayStarTabItemView:OnInit()
	self.Binders = {
		{ "TaskTitle", UIBinderSetText.New(self, self.TextTitle) },
		{ "LockVisible", UIBinderSetIsVisible.New(self, self.IconLock) },
		{ "bIsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "ReveivedVisible", UIBinderSetIsVisible.New(self, self.IconReceive) },
	}
end

function OpsGirlsDayStarTabItemView:OnDestroy()

end

function OpsGirlsDayStarTabItemView:OnShow()

end

function OpsGirlsDayStarTabItemView:OnHide()

end

function OpsGirlsDayStarTabItemView:OnRegisterUIEvent()

end

function OpsGirlsDayStarTabItemView:OnRegisterGameEvent()

end

function OpsGirlsDayStarTabItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end


	local ViewModel = Params.Data
	self:RegisterBinders(ViewModel, self.Binders)
end

return OpsGirlsDayStarTabItemView