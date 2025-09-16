---
--- Author: guanjiewu
--- DateTime: 2023-12-13 16:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
---@class FateArchiveNodeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field SwitchNode UFWidgetSwitcher
---@field TextNode UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveNodeItemView = LuaClass(UIView, true)

function FateArchiveNodeItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.SwitchNode = nil
    --self.TextNode = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveNodeItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveNodeItemView:OnInit()
end

function FateArchiveNodeItemView:OnDestroy()
end

function FateArchiveNodeItemView:OnShow()
end

function FateArchiveNodeItemView:OnHide()
end

function FateArchiveNodeItemView:OnRegisterUIEvent()
end

function FateArchiveNodeItemView:OnRegisterGameEvent()
end

function FateArchiveNodeItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
    self.viewModel = ViewModel
    local Binders = {
        {"Target", UIBinderSetText.New(self, self.TextNode)},
        {"TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNode)},
        {"NodeStatus", UIBinderSetActiveWidgetIndex.New(self, self.SwitchNode)}
    }
    self:RegisterBinders(ViewModel, Binders)
end

return FateArchiveNodeItemView
