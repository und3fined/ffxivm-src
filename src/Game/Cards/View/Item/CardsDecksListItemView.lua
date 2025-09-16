---
--- Author: Administrator
--- DateTime: 2023-10-23 15:02
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class CardsDecksListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgChecked UFImage
---@field ImgSelect UFImage
---@field ImgWarning UFImage
---@field TableViewCard UTableView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsDecksListItemView = LuaClass(UIView, true)

function CardsDecksListItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnClick = nil
    -- self.ImgChecked = nil
    -- self.ImgSelect = nil
    -- self.ImgWarning = nil
    -- self.TableViewCard = nil
    -- self.TextName = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsDecksListItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsDecksListItemView:OnInit()
    self.TableViewCardAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCard, nil, true)

    local Binders = {
        {
            "GroupName",
            UIBinderSetText.New(self, self.TextName)
        },
        {
            "IsDefaultGroup",
            UIBinderSetIsVisible.New(self, self.ImgChecked)
        },
        {
            "IsAllRulePass",
            UIBinderSetIsVisible.New(self, self.ImgWarning, true)
        },
        {
            "IsCurrentSelect",
            UIBinderSetIsVisible.New(self, self.ImgSelect)
        },
        {
            "GroupCardList",
            UIBinderUpdateBindableList.New(self, self.TableViewCardAdapter)
        }
    }
    self.Binders = Binders
end

function CardsDecksListItemView:OnDestroy()

end

function CardsDecksListItemView:OnShow()

end

function CardsDecksListItemView:OnHide()

end

function CardsDecksListItemView:OnRegisterUIEvent()

end

function CardsDecksListItemView:OnRegisterGameEvent()

end

function CardsDecksListItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end
    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    self.ViewModel = ViewModel
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return CardsDecksListItemView
