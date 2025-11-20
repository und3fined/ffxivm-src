---
--- Author: muyanli
--- DateTime: 2025-06-11 15:23
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local HouseLandListWinViewVM = require("Game/House/VM/HouseLandListWinViewVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
---@class HouseLandListWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommDropDown1 CommDropDownListView
---@field CommDropDown2 CommDropDownListView
---@field CommEmpty CommBackpackEmptyView
---@field CommSidebarTabFrame_UIBP CommSidebarTabFrameView
---@field CommTab CommVerIconTabsView
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandListWinView = LuaClass(UIView, true)

function HouseLandListWinView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.CommDropDown1 = nil
    -- self.CommDropDown2 = nil
    -- self.CommSidebarTabFrame_UIBP = nil
    -- self.CommTab = nil
    -- self.TableViewList = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandListWinView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CommDropDown1)
    self:AddSubView(self.CommDropDown2)
    self:AddSubView(self.CommSidebarTabFrame_UIBP)
    self:AddSubView(self.CommTab)
    self:AddSubView(self.CommEmpty)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLandListWinView:OnInit()
    self.ViewModel = HouseLandListWinViewVM.New()
    self.LandListTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
    self.Binders = {
        {"LandVMList", UIBinderUpdateBindableList.New(self, self.LandListTableViewAdapter)},
        {"EmptyVisible", UIBinderSetIsVisible.New(self, self.CommEmpty)},
    }
end

function HouseLandListWinView:OnDestroy()

end

function HouseLandListWinView:OnShow()
    local VM = self.ViewModel
    VM.ResidenceNumber = self.Params and self.Params.ResidenceNumber or 1
    VM.AreaNumber = self.Params and self.Params.AreaNumber or 1
    VM.SubAreaNumber = self.Params and self.Params.SubAreaNumber or 1
    self.CommSidebarTabFrame_UIBP.CommonTitle:SetTextTitleName(HouseLocalDef.LocalTxtStr.LandListTitle)
    local BuyTypeData = {}
    for i, v in ipairs(HouseLocalDef.LandBuyTabTypeStr) do
        if i ~= #HouseLocalDef.LandBuyTabTypeStr then
            table.insert(BuyTypeData, v)
        end
    end
    self.CommDropDown1:UpdateItems(BuyTypeData, 1)
    self.CommDropDown2:UpdateItems(HouseLocalDef.LandSizeTabTypeStr, 1)
    local Tablist = {}
    for i, v in ipairs(HouseLocalDef.LandStateTabList) do
        if (v.TabCanShow and v.TabCanShow()) or not v.TabCanShow then
            table.insert(Tablist, v)
        end
    end

    self.CommEmpty:SetTipsContent(HouseLocalDef.EmptyLandList)
    self.CommTab:UpdateItems(Tablist, 1)
end

function HouseLandListWinView:OnHide()

end

function HouseLandListWinView:OnRegisterUIEvent()
    UIUtil.AddOnSelectionChangedEvent(self, self.CommDropDown1, self.OnCommDropDownLandBuyTypeChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.CommDropDown2, self.OnCommDropDownLandSizeChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.CommTab, self.OnCommDropDownLandStateChanged)
end

function HouseLandListWinView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.HouseLandListUpdate, self.OnHouseLandListUpdate)
    self:RegisterGameEvent(_G.EventID.HouseLandMapDataUpdate, self.OnChangeMapLandUpdate)
end

function HouseLandListWinView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function HouseLandListWinView:OnHouseLandListUpdate()
    if self.ViewModel ~= nil then
        self.ViewModel:UpdateVM()
    end
end

function HouseLandListWinView:OnChangeMapLandUpdate()
    local VM = self.ViewModel
    local MapLandData = _G.HouseLandMgr.CurLandListData
    if VM and MapLandData then
        VM.ResidenceNumber = MapLandData.ResidenceNumber or 1
        VM.AreaNumber = MapLandData.AreaNumber or 1
        VM.SubAreaNumber = MapLandData.SubAreaNumber or 1
        VM:UpdateVM()
    end
end

function HouseLandListWinView:OnCommDropDownLandBuyTypeChanged(Index, ItemData, ItemView, IsByClick)
    FLOG_INFO("HouseLandListWinView:OnCommDropDownLandBuyTypeChanged  %d", Index)
    self.ViewModel:SetTabIndex(1, Index)
end

function HouseLandListWinView:OnCommDropDownLandSizeChanged(Index, ItemData, ItemView, IsByClick)
    self.ViewModel:SetTabIndex(2, Index)
    FLOG_INFO("HouseLandListWinView:OnCommDropDownLandSizeChanged  %d", Index)
end

function HouseLandListWinView:OnCommDropDownLandStateChanged(Index, _, _, IsByClick)
    local ItemData = HouseLocalDef.LandStateTabList[Index]
    if ItemData == nil then
        _G.FLOG_ERROR("HouseLandListWinView:OnCommDropDownLandStateChanged ItemData=nil")
        return
    end
    self.ViewModel:SetLandStatuTabIndex(Index,ItemData.LandStatu)
    FLOG_INFO("HouseLandListWinView:OnCommDropDownLandStateChanged  %d", Index)
end

return HouseLandListWinView
