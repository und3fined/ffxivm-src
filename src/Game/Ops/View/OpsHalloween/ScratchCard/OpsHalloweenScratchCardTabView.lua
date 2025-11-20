---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-07-09 11:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class OpsHalloweenScratchCardTabView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BigPrizeItem CommBackpack126SlotView
---@field TextPhaseDate UFTextBlock
---@field TextPhaseTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsHalloweenScratchCardTabView = LuaClass(UIView, true)

function OpsHalloweenScratchCardTabView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BigPrizeItem = nil
    --self.TextPhaseDate = nil
    --self.TextPhaseTitle = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsHalloweenScratchCardTabView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BigPrizeItem)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsHalloweenScratchCardTabView:OnInit()
    self.BigPrizeItem:SetClickButtonCallback(self, self.OnBigPrizeItemClicked)
    self.Binders = {
        {"PhaseTitleText", UIBinderSetText.New(self, self.TextPhaseTitle)},
        {"ItemID", UIBinderValueChangedCallback.New(self, nil, self.OnBigPrizeItemIDChanged)},
        {"bSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
        {"bShowPhaseDate", UIBinderSetIsVisible.New(self, self.TextPhaseDate)},
        {"PhaseDataText", UIBinderSetText.New(self, self.TextPhaseDate)},
    }
end

function OpsHalloweenScratchCardTabView:OnBigPrizeItemIDChanged(NewValue, OldValue)
    -- self.IconPath = UIUtil.GetItemIconPath(NewValue)
    -- self.BigPrizeItem:SetIconImg(self.IconPath)
end

function OpsHalloweenScratchCardTabView:OnBigPrizeItemClicked(InView, InIndex)
    ItemTipsUtil.ShowTipsByResID(InView.Params.Data.ItemID, InView)
end

function OpsHalloweenScratchCardTabView:OnDestroy()
end

function OpsHalloweenScratchCardTabView:OnShow()
    self.BigPrizeItem:SetIconChooseVisible(false) -- 隐藏选中ICON
    self.BigPrizeItem:SetNumVisible(false)
end

function OpsHalloweenScratchCardTabView:OnHide()
end

function OpsHalloweenScratchCardTabView:OnRegisterUIEvent()
end

function OpsHalloweenScratchCardTabView:OnRegisterGameEvent()
end

function OpsHalloweenScratchCardTabView:OnRegisterBinder()
    if (self.Params == nil) then
        return
    end

    local ViewModel = self.Params.Data

    self:RegisterBinders(ViewModel, self.Binders)
end

return OpsHalloweenScratchCardTabView
