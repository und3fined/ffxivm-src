---
--- Author: Administrator
--- DateTime: 2024-10-21 15:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local LSTR = _G.LSTR

---@class ChocoboExchangeRacerPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAuto CommBtnMView
---@field BtnRandom UFButton
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field DropDownSort CommDropDownListView
---@field TableViewChocobo UTableView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimRefresh UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboExchangeRacerPageView = LuaClass(UIView, true)

function ChocoboExchangeRacerPageView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAuto = nil
	--self.BtnRandom = nil
	--self.CommSidebarFrameS_UIBP = nil
	--self.DropDownSort = nil
	--self.TableViewChocobo = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimRefresh = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboExchangeRacerPageView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAuto)
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	self:AddSubView(self.DropDownSort)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboExchangeRacerPageView:OnInit()
    self.SelectIndex = 1
    self.SelectChocoboID = 0
    self.ShowChocoboVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewChocobo, nil, true)
    self.ShowChocoboVMAdapter:SetOnSelectChangedCallback(self.OnChocoboItemChange)
end

function ChocoboExchangeRacerPageView:OnDestroy()

end

function ChocoboExchangeRacerPageView:OnShow()
    self:InitConstInfo()
    self.SelectIndex = 1

    local Types = ChocoboDefine.OVERVIEW_FILTER_TYPE
    local FilterTypes = { Types.LEVEL, Types.FEATHER_VALUE }
    local FilterTypeList = {}
    for Index, FilterType in ipairs(FilterTypes) do
        FilterTypeList[Index] = {}
        FilterTypeList[Index].Name = ChocoboDefine.OVERVIEW_FILTER_TYPE_NAME[FilterType]
    end
    self.DropDownSort:UpdateItems(FilterTypeList, 1)

    _G.ChocoboMainVM:FilterShowChocoboVMList("Item.IsRent == false")
    _G.ChocoboMainVM:SetCurFilterType(ChocoboDefine.OVERVIEW_FILTER_TYPE.LEVEL)
    _G.ChocoboMainVM:RefreshByCurFilterType()
    self.ShowChocoboVMAdapter:ScrollToIndex(self.SelectIndex)
    self.ShowChocoboVMAdapter:SetSelectedIndex(self.SelectIndex)
end

function ChocoboExchangeRacerPageView:InitConstInfo()
    -- LSTR string: 更换参赛陆行鸟
    self.CommSidebarFrameS_UIBP.CommonTitle:SetTextTitleName(_G.LSTR(420002))
    
    if self.IsInitConstInfo then
        return
    end

    self.IsInitConstInfo = true

    -- LSTR string: 更  换
    self.BtnAuto:SetText(LSTR(420003))
end

function ChocoboExchangeRacerPageView:OnHide()

end

function ChocoboExchangeRacerPageView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnAuto, self.OnClickChangeBtn)
    UIUtil.AddOnClickedEvent(self, self.BtnRandom, self.OnClickBtnRefresh)
    UIUtil.AddOnSelectionChangedEvent(self, self.DropDownSort, self.OnSelectionChangedDropDownList)
end

function ChocoboExchangeRacerPageView:OnRegisterGameEvent()

end

function ChocoboExchangeRacerPageView:OnRegisterBinder()
    local PanelBinders = {
        { "ShowChocoboVMList", UIBinderUpdateBindableList.New(self, self.ShowChocoboVMAdapter) },
    }
    self:RegisterBinders(_G.ChocoboMainVM, PanelBinders)
end

function ChocoboExchangeRacerPageView:OnClickChangeBtn()
    _G.ChocoboMgr:ReqOut(self.SelectChocoboID, true)
    self.BtnAuto:SetIsEnabled(false, false)
end

function ChocoboExchangeRacerPageView:OnChocoboItemChange(Index, ItemData, ItemView, IsByClick)
    self.SelectIndex = Index
    self.SelectChocoboID = ItemData.ChocoboID

    if self.SelectChocoboID == _G.ChocoboMainVM.CurRaceEntryID then
        self.BtnAuto:SetIsEnabled(false, false)
    else
        self.BtnAuto:SetIsEnabled(true, true)
    end
end

function ChocoboExchangeRacerPageView:OnSelectionChangedDropDownList(Index)
    local FilterType = { ChocoboDefine.OVERVIEW_FILTER_TYPE.LEVEL, ChocoboDefine.OVERVIEW_FILTER_TYPE.FEATHER_VALUE }
    _G.ChocoboMainVM:SetCurFilterType(FilterType[Index])
end

function ChocoboExchangeRacerPageView:OnClickBtnRefresh()
    _G.ChocoboMainVM:RefreshByCurFilterType()
end

return ChocoboExchangeRacerPageView