---
--- Author: Administrator
--- DateTime: 2025-03-21 20:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class OpsHalloweenClueItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon UFImage
---@field TextClue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsHalloweenClueItemView = LuaClass(UIView, true)

function OpsHalloweenClueItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon = nil
	--self.TextClue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsHalloweenClueItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsHalloweenClueItemView:OnInit()

end

function OpsHalloweenClueItemView:OnDestroy()

end

function OpsHalloweenClueItemView:OnShow()

end

function OpsHalloweenClueItemView:OnHide()

end

function OpsHalloweenClueItemView:OnRegisterUIEvent()

end

function OpsHalloweenClueItemView:OnRegisterGameEvent()

end

function OpsHalloweenClueItemView:OnRegisterBinder()
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	local Binders = {
		{"IconPath", UIBinderSetImageBrush.New(self, self.Icon)},
		{"ClueText", UIBinderSetText.New(self, self.TextClue)},
		{"IconVisable", UIBinderSetIsVisible.New(self, self.Icon)},
	}

	self:RegisterBinders(ViewModel, Binders)
end

return OpsHalloweenClueItemView