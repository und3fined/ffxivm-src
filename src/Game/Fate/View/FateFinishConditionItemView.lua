---
--- Author: chunfengluo
--- DateTime: 2023-02-21 10:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local FateDefine = require("Game/Fate/FateDefine")

---@class FateFinishConditionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgComplete UFImage
---@field ImgCycle UFImage
---@field ImgMissed UFImage
---@field TextCondition UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateFinishConditionItemView = LuaClass(UIView, true)

function FateFinishConditionItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgComplete = nil
    --self.ImgCycle = nil
    --self.ImgMissed = nil
    --self.TextCondition = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateFinishConditionItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateFinishConditionItemView:OnInit()
end

function FateFinishConditionItemView:OnDestroy()
end

function FateFinishConditionItemView:OnShow()
end

function FateFinishConditionItemView:OnHide()
end

function FateFinishConditionItemView:OnRegisterUIEvent()
end

function FateFinishConditionItemView:OnRegisterGameEvent()
end

function FateFinishConditionItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    local Binders = {
        {"PanelStatus", UIBinderValueChangedCallback.New(self, nil, self.OnSetPanelStatus)},
        {"ConditionText", UIBinderSetText.New(self, self.TextCondition)}
    }

    self:RegisterBinders(ViewModel, Binders)
end

function FateFinishConditionItemView:OnSetPanelStatus(Value)
    UIUtil.SetIsVisible(self.ImgMissed, Value == FateDefine.HiddenCondiState.Hide, false, false)
    UIUtil.SetIsVisible(self.ImgCycle, Value == FateDefine.HiddenCondiState.Cycle, false, false)
    UIUtil.SetIsVisible(self.ImgComplete, Value == FateDefine.HiddenCondiState.Complete, false, false)

    if (self.Params ~= nil and self.Params.Data ~= nil and self.Params.Data.ShowEffect == true) then
        self:RegisterTimer(
            function()
                self:PlayAnimation(self.AnimFirst)
                EventMgr:SendEvent(EventID.FateFinishCondition)
            end,
            1,
            0,
            1
        )
    end
end

return FateFinishConditionItemView
