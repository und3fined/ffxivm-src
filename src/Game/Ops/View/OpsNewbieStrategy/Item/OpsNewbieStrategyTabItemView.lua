---
--- Author: Administrator
--- DateTime: 2024-11-18 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class OpsNewbieStrategyTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconLockFocus USizeBox
---@field IconLockNoraml_1 USizeBox
---@field RedDot CommonRedDotView
---@field TextNoraml UFTextBlock
---@field TextSelect UFTextBlock
---@field ToggleButton UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewbieStrategyTabItemView = LuaClass(UIView, true)

function OpsNewbieStrategyTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconLockFocus = nil
	--self.IconLockNoraml_1 = nil
	--self.RedDot = nil
	--self.TextNoraml = nil
	--self.TextSelect = nil
	--self.ToggleButton = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyTabItemView:OnInit()
	self.Binders = {
		{"Name", UIBinderSetText.New(self, self.TextNoraml)},
		{"Name", UIBinderSetText.New(self, self.TextSelect)},
		{"bSelected", UIBinderSetIsChecked.New(self, self.ToggleButton)},
		{"RedDotName", UIBinderValueChangedCallback.New(self, nil, self.OnRedDotNameChanged) },
		{"RedDotStyle", UIBinderValueChangedCallback.New(self, nil, self.OnRedDotStyleChanged) },
		{"IsUnLock", UIBinderSetIsVisible.New(self, self.IconLockFocus, true) },
		{"IsUnLock", UIBinderSetIsVisible.New(self, self.IconLockNoraml_1, true) },
	}
end

function OpsNewbieStrategyTabItemView:OnDestroy()

end

function OpsNewbieStrategyTabItemView:OnShow()

end

function OpsNewbieStrategyTabItemView:OnHide()

end

function OpsNewbieStrategyTabItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleButton, self.OnClickedItem)
end

function OpsNewbieStrategyTabItemView:OnRegisterGameEvent()

end

function OpsNewbieStrategyTabItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local VM = Params.Data
	if VM == nil then
		return
	end
	self:RegisterBinders(VM, self.Binders)
end

function OpsNewbieStrategyTabItemView:OnClickedItem()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	Adapter:OnItemClicked(self, Params.Index)
end

function OpsNewbieStrategyTabItemView:OnRedDotNameChanged(RedDotName)
	self.RedDot:SetRedDotNameByString(RedDotName)
end

function OpsNewbieStrategyTabItemView:OnRedDotStyleChanged(RedDotStyle)
	if RedDotStyle then
		self.RedDot:SetStyle(RedDotStyle)
	end
end
return OpsNewbieStrategyTabItemView