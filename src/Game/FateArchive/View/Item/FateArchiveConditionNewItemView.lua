---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-08-28 14:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")

---@class FateArchiveConditionNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgComplete UFImage
---@field ImgCycle UFImage
---@field ImgMissed UFImage
---@field SwitchStatus UFWidgetSwitcher
---@field TextCondition UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveConditionNewItemView = LuaClass(UIView, true)

function FateArchiveConditionNewItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgComplete = nil
    --self.ImgCycle = nil
    --self.ImgMissed = nil
    --self.SwitchStatus = nil
    --self.TextCondition = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveConditionNewItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveConditionNewItemView:OnInit()
end

function FateArchiveConditionNewItemView:OnDestroy()
end

function FateArchiveConditionNewItemView:OnShow()
end

function FateArchiveConditionNewItemView:OnHide()
end

function FateArchiveConditionNewItemView:OnRegisterUIEvent()
end

function FateArchiveConditionNewItemView:OnRegisterGameEvent()
end

function FateArchiveConditionNewItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    local Binders = {
        {"PanelStatus", UIBinderSetActiveWidgetIndex.New(self, self.SwitchStatus)},
        {"ConditionText", UIBinderSetText.New(self, self.TextCondition)}
    }

    self:RegisterBinders(ViewModel, Binders)
end

return FateArchiveConditionNewItemView
