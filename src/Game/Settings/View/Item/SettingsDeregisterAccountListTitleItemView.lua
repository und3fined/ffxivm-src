---
--- Author: richyczhou
--- DateTime: 2025-03-13 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

local FLOG_INFO = _G.FLOG_INFO

---@class SettingsDeregisterAccountListTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextState UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsDeregisterAccountListTitleItemView = LuaClass(UIView, true)

function SettingsDeregisterAccountListTitleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextState = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsDeregisterAccountListTitleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsDeregisterAccountListTitleItemView:OnInit()
    FLOG_INFO("[SettingsDeregisterAccountListTitleItemView:OnInit]")
    self.Binders = {
        { "RoleIndexText", UIBinderSetText.New(self, self.TextTitle) },
        { "RoleName", UIBinderSetText.New(self, self.TextState) },
    }
end

function SettingsDeregisterAccountListTitleItemView:OnDestroy()

end

function SettingsDeregisterAccountListTitleItemView:OnShow()
    --local Params = self.Params
    --if nil == Params then
    --    return
    --end
    --
    --local Data = Params.Data
    --if nil == Data then
    --    return
    --end
    --
    FLOG_INFO("[SettingsDeregisterAccountListTitleItemView:OnShow]")
    ----47159 角色
    --self.TextTitle:SetText(string.format("%s%d", LSTR(47159), Data.Index))
    --self.TextState:SetText(Data.RoleName)
end

function SettingsDeregisterAccountListTitleItemView:OnHide()

end

function SettingsDeregisterAccountListTitleItemView:OnRegisterUIEvent()

end

function SettingsDeregisterAccountListTitleItemView:OnRegisterGameEvent()

end

function SettingsDeregisterAccountListTitleItemView:OnRegisterBinder()
    if nil == self.Params or  nil == self.Params.Data then
        return
    end

    ---@type AccountRoleItemVM
    local ViewModel = self.Params.Data
    self.ViewModel = ViewModel
    self:RegisterBinders(self.ViewModel, self.Binders)
    --self:RegisterBinders(AccountRoleItemVM, self.Binders)
end

return SettingsDeregisterAccountListTitleItemView