---
--- Author: Administrator
--- DateTime: 2025-07-09 11:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class OpsHalloweenScratchCardSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpack126Slot_UIBP CommBackpack126SlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsHalloweenScratchCardSlotItemView = LuaClass(UIView, true)

function OpsHalloweenScratchCardSlotItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.CommBackpack126Slot_UIBP = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsHalloweenScratchCardSlotItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CommBackpack126Slot_UIBP)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsHalloweenScratchCardSlotItemView:OnInit()
    self.Binders = {
        {"bGetted", UIBinderSetIsVisible.New(self, self.ImgMask, true)}
    }
end

function OpsHalloweenScratchCardSlotItemView:OnDestroy()
end

function OpsHalloweenScratchCardSlotItemView:OnShow()
end

function OpsHalloweenScratchCardSlotItemView:OnHide()
end

function OpsHalloweenScratchCardSlotItemView:OnRegisterUIEvent()
end

function OpsHalloweenScratchCardSlotItemView:OnRegisterGameEvent()
end

function OpsHalloweenScratchCardSlotItemView:OnRegisterBinder()
    if (self.Params == nil) then
        return
    end

    local ViewModel = self.Params.Data

    self:RegisterBinders(ViewModel, self.Binders)
end

return OpsHalloweenScratchCardSlotItemView
