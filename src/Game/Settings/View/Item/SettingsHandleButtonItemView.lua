---
--- Author: kanohchen
--- DateTime: 2025-05-24 15:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local SettingsHandleButtonItemVM = require("Game/Settings/VM/SettingsHandleButtonItemVM")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local EventID = require("Define/EventID")

---@class SettingsHandleButtonItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextL1 UFTextBlock
---@field TextL10 UFTextBlock
---@field TextL11 UFTextBlock
---@field TextL12 UFTextBlock
---@field TextL13 UFTextBlock
---@field TextL14 UFTextBlock
---@field TextL2 UFTextBlock
---@field TextL3 UFTextBlock
---@field TextL4 UFTextBlock
---@field TextL5 UFTextBlock
---@field TextL6 UFTextBlock
---@field TextL7 UFTextBlock
---@field TextL8 UFTextBlock
---@field TextL9 UFTextBlock
---@field TextR1 UFTextBlock
---@field TextR10 UFTextBlock
---@field TextR12 UFTextBlock
---@field TextR13 UFTextBlock
---@field TextR14 UFTextBlock
---@field TextR15 UFTextBlock
---@field TextR16 UFTextBlock
---@field TextR2 UFTextBlock
---@field TextR3 UFTextBlock
---@field TextR4 UFTextBlock
---@field TextR5 UFTextBlock
---@field TextR6 UFTextBlock
---@field TextR7 UFTextBlock
---@field TextR8 UFTextBlock
---@field TextR9 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsHandleButtonItemView = LuaClass(UIView, true)

function SettingsHandleButtonItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextL1 = nil
	--self.TextL10 = nil
	--self.TextL11 = nil
	--self.TextL12 = nil
	--self.TextL13 = nil
	--self.TextL14 = nil
	--self.TextL2 = nil
	--self.TextL3 = nil
	--self.TextL4 = nil
	--self.TextL5 = nil
	--self.TextL6 = nil
	--self.TextL7 = nil
	--self.TextL8 = nil
	--self.TextL9 = nil
	--self.TextR1 = nil
	--self.TextR10 = nil
	--self.TextR12 = nil
	--self.TextR13 = nil
	--self.TextR14 = nil
	--self.TextR15 = nil
	--self.TextR16 = nil
	--self.TextR2 = nil
	--self.TextR3 = nil
	--self.TextR4 = nil
	--self.TextR5 = nil
	--self.TextR6 = nil
	--self.TextR7 = nil
	--self.TextR8 = nil
	--self.TextR9 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsHandleButtonItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsHandleButtonItemView:OnInit()
	self.VM = SettingsHandleButtonItemVM.New()
	self.Binders = {
		{"HandleLTB", UIBinderSetText.New(self, self.TextL1)},
		{"HandleLTY", UIBinderSetText.New(self, self.TextL2)},
		{"HandleLTA", UIBinderSetText.New(self, self.TextL3)},
		{"HandleLTX", UIBinderSetText.New(self, self.TextL4)},
		{"HandleLTRight", UIBinderSetText.New(self, self.TextL5)},
		{"HandleLTUp", UIBinderSetText.New(self, self.TextL6)},
		{"HandleLTDown", UIBinderSetText.New(self, self.TextL7)},
		{"HandleLTLeft", UIBinderSetText.New(self, self.TextL8)},
		{"HandleLB", UIBinderSetText.New(self, self.TextL9)},
		{"HandleL", UIBinderSetText.New(self, self.TextL10)},
		{"HandleRight", UIBinderSetText.New(self, self.TextL14)},
		{"HandleUp", UIBinderSetText.New(self, self.TextL11)},
		{"HandleDown", UIBinderSetText.New(self, self.TextL13)},
		{"HandleLeft", UIBinderSetText.New(self, self.TextL12)},
		{"HandleRTB", UIBinderSetText.New(self, self.TextR1)},
		{"HandleRTY", UIBinderSetText.New(self, self.TextR2)},
		{"HandleRTA", UIBinderSetText.New(self, self.TextR3)},
		{"HandleRTX", UIBinderSetText.New(self, self.TextR4)},
		{"HandleRTRight", UIBinderSetText.New(self, self.TextR5)},
		{"HandleRTUp", UIBinderSetText.New(self, self.TextR6)},
		{"HandleRTDown", UIBinderSetText.New(self, self.TextR7)},
		{"HandleRTLeft", UIBinderSetText.New(self, self.TextR8)},
		{"HandleRB", UIBinderSetText.New(self, self.TextR9)},
		{"HandleY", UIBinderSetText.New(self, self.TextR10)},
		{"HandleB", UIBinderSetText.New(self, self.TextR12)},
		{"HandleA", UIBinderSetText.New(self, self.TextR13)},
		{"HandleX", UIBinderSetText.New(self, self.TextR14)},
		{"HandleR", UIBinderSetText.New(self, self.TextR15)},
		{"HandleRS", UIBinderSetText.New(self, self.TextR16)},
		{"HandleSpecialLeft", UIBinderSetText.New(self, self.TextTop1)},
		{"HandleSpecialRight", UIBinderSetText.New(self, self.TextTop2)},
	}
end

function SettingsHandleButtonItemView:OnDestroy()

end

function SettingsHandleButtonItemView:OnShow()
	if self.Params then
		if not string.isnilorempty(self.Params.Data.GetValueFunc) then
			self.VM.GetValueFunc = self.Params.Data.GetValueFunc
		end
	end
	for _, value in pairs(self.Binders) do
		local CurActionText = SettingsUtils.GetValue(self.VM.GetValueFunc, {}, value[1])
		self.VM:SetCusActionText(value[1], CurActionText)
	end
end

function SettingsHandleButtonItemView:OnHide()

end

function SettingsHandleButtonItemView:OnRegisterUIEvent()

end

function SettingsHandleButtonItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OnUpdateHandleCusAction, self.OnUpdateHandleCusAction)
end

function SettingsHandleButtonItemView:OnRegisterBinder()
	if self.VM then
		self:RegisterBinders(self.VM, self.Binders)
	end
end

function SettingsHandleButtonItemView:OnUpdateHandleCusAction(Params)
	if Params then
		self.VM:SetCusActionText(Params.SaveKey, Params.CurActionText)
	end
end

function SettingsHandleButtonItemView:GetVM()
	return self.VM
end

return SettingsHandleButtonItemView