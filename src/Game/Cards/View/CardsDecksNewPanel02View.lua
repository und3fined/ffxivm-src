---
--- Author: MichaelYang_LightPaw
--- DateTime: 2024-01-15 10:14
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CardsDecksPageVM = require("Game/Cards/VM/CardsDecksPageVM")

---@class CardsDecksNewPanel02View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDefault CommBtnLView
---@field BtnEdit CommBtnLView
---@field TableViewDecksList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsDecksNewPanel02View = LuaClass(UIView, true)

function CardsDecksNewPanel02View:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnDefault = nil
    -- self.BtnEdit = nil
    -- self.TableViewDecksList = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsDecksNewPanel02View:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnDefault)
    self:AddSubView(self.BtnEdit)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsDecksNewPanel02View:OnInit()
    self.GroupTableViewAdapter = UIAdapterTableView.CreateAdapter(
                                     self, self.TableViewDecksList, self.OnCardGroupItemSelectChanged, true
                                 )
    local Binders = {
        {
            "CardGroupList",
            UIBinderUpdateBindableList.New(self, self.GroupTableViewAdapter)
        }
    }
	self.Binders = Binders
end

function CardsDecksNewPanel02View:OnCardGroupItemSelectChanged(Index, ItemData, ItemView)
    self.ParentView.ViewModel:SetItemSelected(ItemData)
end

function CardsDecksNewPanel02View:OnDestroy()

end

function CardsDecksNewPanel02View:SetLSTR()
    self.BtnDefault:SetButtonText(_G.LSTR(1130081))--("设为默认")
	self.BtnEdit:SetButtonText(_G.LSTR(1130040))--1130040("编辑卡组")
end

function CardsDecksNewPanel02View:OnShow()
    self:SetLSTR()
end

function CardsDecksNewPanel02View:OnHide()

end

function CardsDecksNewPanel02View:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnEdit.Button, self.OnClickEditBtn)
    UIUtil.AddOnClickedEvent(self, self.BtnDefault, self.OnClickBtnDefault)
end

function CardsDecksNewPanel02View:OnClickEditBtn()
    -- TODO : 这里要去通知父界面，播放一下动画
    self.ParentView:OnClickEditBtn()
end

function CardsDecksNewPanel02View:OnClickBtnDefault()
    local _isAllOk = self.ParentView.ViewModel.CardsDecksPageVM.CurrentSelectItemVM.IsAllRulePass
    if (not _isAllOk) then
        -- 这里弹出提示，编组没有OK的，就直接掠过
        return
    end

    self.ParentView.ViewModel:SetCurrentSelectItemDefault()
end

function CardsDecksNewPanel02View:OnRegisterGameEvent()

end

function CardsDecksNewPanel02View:OnRegisterBinder()
	self:RegisterBinders(self.ParentView.ViewModel.CardsDecksPageVM, self.Binders)
end

return CardsDecksNewPanel02View
