---
--- Author: richyczhou
--- DateTime: 2025-03-13 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

local FLOG_INFO = _G.FLOG_INFO

---@class SettingsDeregisterAccountListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextExplain UFTextBlock
---@field TextState UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsDeregisterAccountListItemView = LuaClass(UIView, true)

function SettingsDeregisterAccountListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextExplain = nil
	--self.TextState = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsDeregisterAccountListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsDeregisterAccountListItemView:OnInit()
    FLOG_INFO("[SettingsDeregisterAccountListItemView:OnInit]")
    self.Binders = {
        { "TitleText", UIBinderSetText.New(self, self.TextTitle) },
        { "ContentText", UIBinderSetText.New(self, self.TextExplain) },
        { "CheckResultText", UIBinderSetText.New(self, self.TextState) },
        { "CheckResultColor", UIBinderSetColorAndOpacityHex.New(self, self.TextState) },
    }
end

function SettingsDeregisterAccountListItemView:OnDestroy()

end

function SettingsDeregisterAccountListItemView:OnShow()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Data = Params.Data
    if nil == Data then
        return
    end

    FLOG_INFO("[SettingsDeregisterAccountListItemView:OnShow]")
end

function SettingsDeregisterAccountListItemView:OnHide()

end

function SettingsDeregisterAccountListItemView:OnRegisterUIEvent()

end

function SettingsDeregisterAccountListItemView:OnRegisterGameEvent()

end

function SettingsDeregisterAccountListItemView:OnRegisterBinder()
    if nil == self.Params or  nil == self.Params.Data then
        return
    end

    ---@type AccountRoleItemVM
    local ViewModel = self.Params.Data
    self.ViewModel = ViewModel
    self:RegisterBinders(self.ViewModel, self.Binders)
    --self:RegisterBinders(AccountRoleItemVM, self.Binders)
end

return SettingsDeregisterAccountListItemView