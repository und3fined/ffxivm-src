---
--- Author: MichaelYang_LightPaw
--- DateTime: 2023-11-08 10:01
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class CardsSidebarPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAuto CommBtnMView
---@field CommSidebarFrameS CommSidebarFrameSView
---@field TableViewCard UTableView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsSidebarPanelView = LuaClass(UIView, true)

function CardsSidebarPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnAuto = nil
    -- self.TableViewCard = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsSidebarPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnAuto)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsSidebarPanelView:SetParentViewModel(TargetViewModel)
    self.ParentViewModel = TargetViewModel
end

function CardsSidebarPanelView:OnInit()
    self.TableViewCardAdapter = UIAdapterTableView.CreateAdapter(
                                    self, self.TableViewCard, self.OnTableViewCardSelectChanged, true
                                )
    local Binders = {
        {
            "CardGroupList",
            UIBinderUpdateBindableList.New(self, self.TableViewCardAdapter)
        },
        {
            "HasAutoGroup",
            UIBinderValueChangedCallback.New(self, nil, self.OnHasAutoGroupChange)
        }
    }
    self.Binders = Binders
    
end

function CardsSidebarPanelView:OnHasAutoGroupChange()
    self.BtnAuto:SetIsEnabled(not self.ParentViewModel.HasAutoGroup)
end

function CardsSidebarPanelView:OnTableViewCardSelectChanged(Index, ItemData, ItemView)
    self.ParentViewModel:SetSelectCardGroup(ItemData)
end

function CardsSidebarPanelView:OnClickCloseBtn()
    UIUtil.SetIsVisible(self, false)
end

function CardsSidebarPanelView:OnDestroy()

end

function CardsSidebarPanelView:SetLSTR()
    self.CommSidebarFrameS:SetTitleText(_G.LSTR(1130087))--("卡组一览")
    self.BtnAuto:SetButtonText(_G.LSTR(1130042)) --自动组卡
end

function CardsSidebarPanelView:OnShow()
    self:SetLSTR()
end

function CardsSidebarPanelView:OnHide()
    self.ParentViewModel:NotifyModity()
end

function CardsSidebarPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnAuto, self.OnClickBtnAuto)
    --UIUtil.AddOnClickedEvent(self, self.Btn_CloseArea, self.OnClickCloseBtn)
    UIUtil.AddOnClickedEvent(self, self.CommSidebarFrameS.BtnClose.Btn_Close, self.OnClickCloseBtn)
end

function CardsSidebarPanelView:OnClickBtnAuto()
    self.ParentViewModel:OnClickBtnAuto()
end

function CardsSidebarPanelView:OnRegisterGameEvent()

end

function CardsSidebarPanelView:OnRegisterBinder()
    self:RegisterBinders(self.ParentViewModel, self.Binders)
end

return CardsSidebarPanelView
