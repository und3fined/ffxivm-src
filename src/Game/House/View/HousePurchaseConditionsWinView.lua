---
--- Author: muyanli
--- DateTime: 2025-05-30 20:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local HousePurchaseConditionsWinVM = require("Game/House/VM/HousePurchaseConditionsWinVM")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class HousePurchaseConditionsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field Menu CommMenuView
---@field TableViewList UTableView
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HousePurchaseConditionsWinView = LuaClass(UIView, true)

function HousePurchaseConditionsWinView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.Comm2FrameL_UIBP = nil
    --self.Menu = nil
    --self.TableViewList = nil
    --self.Text = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HousePurchaseConditionsWinView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.Comm2FrameL_UIBP)
    self:AddSubView(self.Menu)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HousePurchaseConditionsWinView:OnInit()
    self.ViewModel = HousePurchaseConditionsWinVM.New()
    self.TableListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
    self.Binders = {
        { "BuyConditions", UIBinderUpdateBindableList.New(self, self.TableListAdapter) },
        { "TextSubTitle", UIBinderSetText.New(self, self.Text) },
    }
    self.Comm2FrameL_UIBP:SetTitleText(HouseLocalDef.LocalTxtStr.HousePurchaseConditionTitle)
end

function HousePurchaseConditionsWinView:OnDestroy()

end

function HousePurchaseConditionsWinView:OnShow()
	self.Menu:UpdateItems(HouseLocalDef.BuyConditionTabs)
	self.Menu:SetSelectedIndex(_G.HouseLandMianPanelVM.CurBuyConditionsBelongType)
end

function HousePurchaseConditionsWinView:OnHide()

end

function HousePurchaseConditionsWinView:OnRegisterUIEvent()
    UIUtil.AddOnSelectionChangedEvent(self, self.Menu, self.OnSelectionChangedCommMenu)
end

function HousePurchaseConditionsWinView:OnRegisterGameEvent()

end

function HousePurchaseConditionsWinView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function HousePurchaseConditionsWinView:OnSelectionChangedCommMenu(Index)
    if self.ViewModel ~= nil then
        self.ViewModel:SetBuyConditons(Index)
    end
end
return HousePurchaseConditionsWinView
