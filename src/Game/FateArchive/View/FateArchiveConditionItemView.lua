---
--- Author: guanjiewu
--- DateTime: 2023-12-05 16:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")

---@class FateArchiveConditionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgComplete UFImage
---@field ImgCycle UFImage
---@field SwitchStatus UFWidgetSwitcher
---@field TextCondition UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveConditionItemView = LuaClass(UIView, true)

function FateArchiveConditionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgComplete = nil
	--self.ImgCycle = nil
	--self.SwitchStatus = nil
	--self.TextCondition = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveConditionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveConditionItemView:OnInit()

end

function FateArchiveConditionItemView:OnDestroy()

end

function FateArchiveConditionItemView:OnShow()

end

function FateArchiveConditionItemView:OnHide()

end

function FateArchiveConditionItemView:OnRegisterUIEvent()

end

function FateArchiveConditionItemView:OnRegisterGameEvent()

end

function FateArchiveConditionItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	local Binders = {
		{ "PanelStatus", UIBinderSetActiveWidgetIndex.New(self, self.SwitchStatus) },
		{ "ConditionText", UIBinderSetText.New(self, self.TextCondition) },
	}

	self:RegisterBinders(ViewModel, Binders)
end

return FateArchiveConditionItemView