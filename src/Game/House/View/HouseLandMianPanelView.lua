---
--- Author: muyanli
--- DateTime: 2025-06-03 09:59
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local LoginNewVM = require("Game/LoginNew/VM/LoginNewVM")
local HouseLocalDef = require("Game/House/HouseLocalDef")
---@class HouseLandMianPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field HouseEntrancePanel_UIBP HouseEntrancePanelView
---@field HouseLandPurchasePanel_UIBP HouseLandPurchasePanelView
---@field HouseTab HouseLandPurchaseTabItemView
---@field TextServer UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandMianPanelView = LuaClass(UIView, true)

function HouseLandMianPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.CloseBtn = nil
    -- self.CommonBkg02_UIBP = nil
    -- self.CommonBkgMask_UIBP = nil
    -- self.CommonTitle = nil
    -- self.HouseEntrancePanel_UIBP = nil
    -- self.HouseLandPurchasePanel_UIBP = nil
    -- self.HouseTab = nil
    -- self.TextServer = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandMianPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CloseBtn)
    self:AddSubView(self.CommonBkg02_UIBP)
    self:AddSubView(self.CommonBkgMask_UIBP)
    self:AddSubView(self.CommonTitle)
    self:AddSubView(self.HouseEntrancePanel_UIBP)
    self:AddSubView(self.HouseLandPurchasePanel_UIBP)
    self:AddSubView(self.HouseTab)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLandMianPanelView:OnInit()
    self.ViewModel = _G.HouseLandMianPanelVM
    self:InitInfo()
end


function HouseLandMianPanelView:OnShow()
    if self.Params then
        if self.Params.TabIndex then
            self.ViewModel.CurSelectTabIndex = self.Params.TabIndex
        end
        if self.Params.SubTabIndex then
            self.ViewModel.CurSelectSubTabIndex = self.Params.SubTabIndex
        end
    else
        self.ViewModel.CurSelectTabIndex = self.ViewModel:GetDefaultTabIndex()
    end

    self:RefreshInfo()
    _G.HouseInfoMgr:SaveFirstSeen()
    _G.HouseInfoMgr:UpdateAllRed()
end


function HouseLandMianPanelView:OnRegisterUIEvent()
end

function HouseLandMianPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.HouseLandBuyTabSwitch, self.OnHouseLandBuyTabSwitch)
    self:RegisterGameEvent(EventID.HouseDestroyNotify, self.OnDestroyHouse)
    self:RegisterGameEvent(EventID.HouseAbandonLand, self.OnAbandonLand)
end

function HouseLandMianPanelView:OnDestroyHouse(HouseID)
	if HouseID == _G.HouseInfoMgr.ArmyHouseID or HouseID == _G.HouseInfoMgr.MajorHouseID then
		self:Hide()
	end
end

function HouseLandMianPanelView:OnAbandonLand()
	self:Hide()
end

function HouseLandMianPanelView:OnRegisterBinder()
end

function HouseLandMianPanelView:InitInfo()
    self.TextServer:SetText(LSTR(LoginNewVM:GetCurWorldName() or ""))
end

function HouseLandMianPanelView:RefreshInfo()
    self.HouseTab:SetSelectedIndex(self.ViewModel.CurSelectTabIndex)
    local isLandPurchase = self.ViewModel.CurSelectTabIndex == HouseLocalDef.HouseTabIndex.LandBuy
    UIUtil.SetIsVisible(self.HouseEntrancePanel_UIBP, not isLandPurchase)
    UIUtil.SetIsVisible(self.HouseLandPurchasePanel_UIBP, isLandPurchase)

    local TitleName = HouseLocalDef.HouseTabData[self.ViewModel.CurSelectTabIndex].Name
    self.CommonTitle:SetTextTitleName(TitleName)
    local HelpInfoID = 11210
    if self.ViewModel.CurSelectTabIndex == HouseLocalDef.HouseTabIndex.LandBuy then
        HelpInfoID = 11209
    end
    self.CommonTitle.CommInforBtn:SetHelpInfoID(HelpInfoID)
end

function HouseLandMianPanelView:OnHouseLandBuyTabSwitch(Index)
    self.ViewModel.CurSelectTabIndex = Index
    self:RefreshInfo()
end

function HouseLandMianPanelView:OnDestroy()
end

function HouseLandMianPanelView:OnHide()
end

return HouseLandMianPanelView
