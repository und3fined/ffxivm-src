---
--- Author: Administrator
--- DateTime: 2023-11-10 16:04
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class CardsReadinessRuleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelTitle UFCanvasPanel
---@field TableViewRuleDetail UTableView
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsReadinessRuleItemView = LuaClass(UIView, true)

function CardsReadinessRuleItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.TextRule01 = nil
    -- self.TextRule01Content = nil
    -- self.TextTitle = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsReadinessRuleItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsReadinessRuleItemView:OnInit()
    self.TableViewRuleDetailAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRuleDetail, nil, true)
    local Binders = {
        {
            "TextTitle",
            UIBinderSetText.New(self, self.TextTitle)
        },
        {
            "CardsRuleItemVMList",
            UIBinderUpdateBindableList.New(self, self.TableViewRuleDetailAdapter)
        }
    }
    self.Binders = Binders
end

function CardsReadinessRuleItemView:OnDestroy()

end

function CardsReadinessRuleItemView:OnShow()
end

function CardsReadinessRuleItemView:OnHide()

end

function CardsReadinessRuleItemView:OnRegisterUIEvent()

end

function CardsReadinessRuleItemView:OnRegisterGameEvent()

end

--- ViewModel 是 CardsRuleDetailVM
function CardsReadinessRuleItemView:OnRegisterBinder()
    self.ViewModel = self.Params.Data
    if (self.ViewModel == nil) then
        return
    end
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return CardsReadinessRuleItemView
