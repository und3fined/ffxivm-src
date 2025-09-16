---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-08-30 11:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIconItemAndScore = require("Binder/UIBinderSetIconItemAndScore")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class FateFinishRewardNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgReward UFImage
---@field TextValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateFinishRewardNewItemView = LuaClass(UIView, true)

function FateFinishRewardNewItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgReward = nil
    --self.TextValue = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateFinishRewardNewItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateFinishRewardNewItemView:OnInit()
end

function FateFinishRewardNewItemView:OnDestroy()
end

function FateFinishRewardNewItemView:OnShow()
end

function FateFinishRewardNewItemView:OnHide()
end

function FateFinishRewardNewItemView:OnRegisterUIEvent()
end

function FateFinishRewardNewItemView:OnRegisterGameEvent()
end

function FateFinishRewardNewItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    local Binders = {
        {"ItemResID", UIBinderSetIconItemAndScore.New(self, self.ImgReward)},
        {"Num", UIBinderSetText.New(self, self.TextValue)}
    }

    self:RegisterBinders(ViewModel, Binders)
end

return FateFinishRewardNewItemView
