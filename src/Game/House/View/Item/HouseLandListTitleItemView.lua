---
--- Author: muyanli
--- DateTime: 2025-06-11 15:23
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLandListWinItemVM = require("Game/House/VM/Item/HouseLandListWinItemVM")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class HouseLandListTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandListTitleItemView = LuaClass(UIView, true)

function HouseLandListTitleItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.TextTime = nil
    -- self.TextTitle = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandListTitleItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLandListTitleItemView:OnInit()
    self.ViewModel = HouseLandListWinItemVM.New()
    self.Binders = {{"PhaseTypeStr", UIBinderSetText.New(self, self.TextTitle)},
                    {"PhaseTimeStr", UIBinderSetText.New(self, self.TextTime)}}
end

function HouseLandListTitleItemView:OnDestroy()

end

function HouseLandListTitleItemView:OnShow()

end

function HouseLandListTitleItemView:OnHide()

end

function HouseLandListTitleItemView:OnRegisterUIEvent()

end

function HouseLandListTitleItemView:OnRegisterGameEvent()

end

function HouseLandListTitleItemView:OnRegisterBinder()
    if nil == self.Params or nil == self.Params.Data then
        return
    end
    local ViewModel = self.Params.Data

    self.ViewModel = ViewModel
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return HouseLandListTitleItemView
