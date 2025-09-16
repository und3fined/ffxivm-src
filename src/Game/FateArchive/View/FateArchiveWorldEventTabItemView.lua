---
--- Author: guanjiewu
--- DateTime: 2023-12-25 11:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local EventID = require("Define/EventID")

---@class FateArchiveWorldEventTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field TextInfo UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveWorldEventTabItemView = LuaClass(UIView, true)

function FateArchiveWorldEventTabItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgIcon = nil
    --self.TextInfo = nil
    --self.ToggleBtn = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveWorldEventTabItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveWorldEventTabItemView:OnInit()
end

function FateArchiveWorldEventTabItemView:OnDestroy()
end

function FateArchiveWorldEventTabItemView:OnShow()
end

function FateArchiveWorldEventTabItemView:OnHide()
end

function FateArchiveWorldEventTabItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnClickButtonItem)
end

function FateArchiveWorldEventTabItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.FateWorldEventItemClick, self.OnFateEventItemClick)
end

function FateArchiveWorldEventTabItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
    self.viewModel = ViewModel
    -- if FateEventStatisticsVM.SelectID ~= nil then
    -- 	self:OnFateEventItemClick(FateEventStatisticsVM.SelectID)
    -- else
    self:OnFateEventItemClick(1)
    -- end

    local Binders = {
        {"TitleText", UIBinderSetText.New(self, self.TextInfo)},
        {"TitleIcon", UIBinderSetImageBrush.New(self, self.ImgIcon)}
    }
    self:RegisterBinders(ViewModel, Binders)
end

function FateArchiveWorldEventTabItemView:OnFateEventItemClick(Type)
    local ViewModel = self.Params.Data
    if ViewModel.Type == Type then
        self.ToggleBtn:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
    else
        self.ToggleBtn:SetCheckedState(_G.UE.EToggleButtonState.Unchecked, false)
    end
    print("FateArchiveWorldEventTabItemView:OnFateEventItemClick", ViewModel.Type, Type)
end

function FateArchiveWorldEventTabItemView:OnClickButtonItem()
    self.viewModel:ClickedItemVM()
end

return FateArchiveWorldEventTabItemView
