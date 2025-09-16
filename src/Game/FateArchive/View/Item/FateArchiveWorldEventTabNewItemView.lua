---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-08-28 14:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local EventID = require("Define/EventID")

---@class FateArchiveWorldEventTabNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field TextInfo UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveWorldEventTabNewItemView = LuaClass(UIView, true)

function FateArchiveWorldEventTabNewItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgNormal = nil
    --self.ImgSelect = nil
    --self.TextInfo = nil
    --self.ToggleBtn = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveWorldEventTabNewItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveWorldEventTabNewItemView:OnInit()
    self.Binders = {
        {"TitleText", UIBinderSetText.New(self, self.TextInfo)},
        {"NewTitleIconSelect", UIBinderSetImageBrush.New(self, self.ImgSelect)},
        {"NewTitleIconNormal", UIBinderSetImageBrush.New(self, self.ImgNormal)}
    }
end

function FateArchiveWorldEventTabNewItemView:OnDestroy()
end

function FateArchiveWorldEventTabNewItemView:OnShow()
end

function FateArchiveWorldEventTabNewItemView:OnHide()
end

function FateArchiveWorldEventTabNewItemView:OnRegisterUIEvent()
end

function FateArchiveWorldEventTabNewItemView:OnRegisterGameEvent()
end

function FateArchiveWorldEventTabNewItemView:OnRegisterBinder()
    -- ViewModel is  : require("Game/FateArchive/VM/FateArchiveWorldEventTabItemVM")
    local ViewModel = self.Params.Data
    self:RegisterBinders(ViewModel, self.Binders)
end

function FateArchiveWorldEventTabNewItemView:OnSelectChanged(IsSelected)
    if IsSelected then
        self:StopAnimation(self.AnimIn)
        self:StopAnimation(self.AnimSwitcherNormalBg)
        self:PlayAnimation(self.AnimSwitcherSelectBg)
        UIUtil.SetIsVisible(self.ImgSelect, true)
        UIUtil.SetIsVisible(self.ImgNormal, false)
    else
        self:StopAnimation(self.AnimIn)
        self:StopAnimation(self.AnimSwitcherSelectBg)
        self:PlayAnimation(self.AnimSwitcherNormalBg)
        UIUtil.SetIsVisible(self.ImgSelect, false)
        UIUtil.SetIsVisible(self.ImgNormal, true)
    end
end

return FateArchiveWorldEventTabNewItemView
