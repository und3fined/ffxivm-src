---
--- Author: muyanli
--- DateTime: 2025-05-30 20:51
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLandInformationPanelVM = require("Game/House/VM/HouseLandInformationPanelVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ProtoCS = require("Protocol/ProtoCS")
local HouseInfoMgr = require("Game/House/HouseInfoMgr")

---@class HouseLandInformationPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnJoinSelect CommBtnLView
---@field BtnReciveMoney CommBtnLView
---@field BtnTransmit CommBtnLView
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field IconState UFImage
---@field ImgSelectedFlag UFImage
---@field Money CommMoneySlotView
---@field TableViewList UTableView
---@field TextLandInformation UFTextBlock
---@field TextState UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandInformationPanelView = LuaClass(UIView, true)

function HouseLandInformationPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.Btn1 = nil
    -- self.Btn2L = nil
    -- self.Btn2R = nil
    -- self.CloseBtn = nil
    -- self.CommonBkg02_UIBP = nil
    -- self.CommonBkgMask_UIBP = nil
    -- self.IconState = nil
    -- self.Money = nil
    -- self.PanelBtn2 = nil
    -- self.TableViewList = nil
    -- self.TextLandInformation = nil
    -- self.TextState = nil
    -- self.TextTime = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandInformationPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnJoinSelect)
    self:AddSubView(self.BtnTransmit)
    self:AddSubView(self.BtnReciveMoney)
    self:AddSubView(self.CloseBtn)
    self:AddSubView(self.CommonBkg02_UIBP)
    self:AddSubView(self.CommonBkgMask_UIBP)
    self:AddSubView(self.Money)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLandInformationPanelView:OnInit()
    self.ViewModel = HouseLandInformationPanelVM.New()
    self.TextLandInformation:SetText(HouseLocalDef.LandInfoStr.LandInfo)
    self.BtnTransmit:SetText(HouseLocalDef.LandInfoStr.Transmit)
    self.BtnReciveMoney:SetText(HouseLocalDef.LandInfoStr.ReceiveMoney)
    self.LandInfoTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
    self.Binders = 
    {
        {"LandInfoVMList", UIBinderUpdateBindableList.New(self, self.LandInfoTableViewAdapter)},
        {"IconState", UIBinderSetBrushFromAssetPath.New(self, self.IconState)},
        {"TextState", UIBinderSetText.New(self, self.TextState)},
        {"TextTime", UIBinderSetText.New(self, self.TextTime)},
        {"BtnJoinSelectVisible", UIBinderSetIsVisible.New(self, self.BtnJoinSelect)},
        {"BtnReciveMoneyVisible", UIBinderSetIsVisible.New(self, self.BtnReciveMoney)},
        {"BtnTransmitVisible", UIBinderSetIsVisible.New(self, self.BtnTransmit)},
        {"ImgSelectedFlagVisible", UIBinderSetIsVisible.New(self, self.ImgSelectedFlag)},
    }
end

function HouseLandInformationPanelView:OnDestroy()

end

function HouseLandInformationPanelView:OnShow()
   self:QueryLandAreaInfo()
end

function HouseLandInformationPanelView:QueryLandAreaInfo()
    local Params = self.Params
    if not Params then return end

    _G.HouseLandMgr:SendLandQueryArea(Params.ResidenceNumber, Params.AreaNumber, 0, 0,
        Params.LandNumberList, HouseLocalDef.LandQuerySceneType.LandInfo)
end

function HouseLandInformationPanelView:OnHide()

end

function HouseLandInformationPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnTransmit, self.OnBtnTransmitClick)
    UIUtil.AddOnClickedEvent(self, self.BtnJoinSelect, self.OnBtnJoinSelectClick)
    UIUtil.AddOnClickedEvent(self, self.BtnReciveMoney.Button, self.OnClickBtnReciveMoney)
end

function HouseLandInformationPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.HouseLandInfoUpdate, self.OnHouseLandInfoUpdate)
    self:RegisterGameEvent(_G.EventID.HouseLandSelectRet, self.OnHouseLandSelectRet)
    self:RegisterGameEvent(_G.EventID.HouseTransAreaChange, self.HouseTransAreaChange)
    self:RegisterGameEvent(_G.EventID.LandBuyStatusNotify, self.OnLandBuyStatusNotify)
end

function HouseLandInformationPanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function HouseLandInformationPanelView:OnHouseLandInfoUpdate(Params, FromSelectRsp)
    if self.ViewModel then
        self.ViewModel:UpdateVM(Params, FromSelectRsp)
        self.Money:UpdateView(self.ViewModel.MoneyType, false, nil, true)
        self.BtnJoinSelect:SetText(self.ViewModel.BtnJoinSelectTxt)
        self.BtnJoinSelect:SetIsDisabledState(not self.ViewModel.CanApply or self.ViewModel.HasApply, true)
        local LandSelectInfo = _G.HouseLandMianPanelVM.LandSelectInfo
        local LatestApply = LandSelectInfo[HouseLocalDef.BuyHouseBelongType.Personal] or {}
        local IsReturn = LatestApply.ReturnMoney and LatestApply.ReturnMoney > 0 and LatestApply.AplStatus ~= ProtoCS.ApplyStatus.ApplyStatus_Return
        self.BtnReciveMoney:SetIsDisabledState(not IsReturn, true)
        if self.ViewModel.HasSelecedAward and not HouseInfoMgr:IsAnimationUltraPlay("LandInfoAward".. _G.HouseLandMianPanelVM.PhaseCnt, false) then
            self:PlayAnimation(self.AnimWin)
            _G.EventMgr:SendEvent(_G.EventID.HouseLandInfotmationItemAni)
        end
    end
end

function HouseLandInformationPanelView:OnHouseLandSelectRet(Params)
    self.ViewModel.CanApply = false
    self.ViewModel.HasApply = true
    self:OnHouseLandInfoUpdate(Params, true)
    self.BtnJoinSelect:SetIsDisabledState(true, true)
    UIViewMgr:ShowView(UIViewID.HouseLandPurchaseCandidateWinView, Params)
end

function HouseLandInformationPanelView:OnBtnTransmitClick()
    if self.ViewModel then
        _G.HouseLandMgr:SendLandTransmit(HouseLocalDef.LandTransmitType.Land, self.ViewModel.LandInfo)
    end
end

function HouseLandInformationPanelView:HouseTransAreaChange()
    self:Hide()
end

function HouseLandInformationPanelView:OnLandBuyStatusNotify()
    self:QueryLandAreaInfo()
end

function HouseLandInformationPanelView:OnBtnJoinSelectClick()
    if self.ViewModel == nil then
        return
    end

    if self.ViewModel.CanApply and not self.ViewModel.HasApply then
        if self.ViewModel.LandInfo.BuyType == ProtoCS.LandBuyType.LandBuyType_All then
            local NotNeedSelectOwner =
                _G.HouseLandMianPanelVM.CanApplyLandArr[HouseLocalDef.BuyHouseBelongType.Personal] and
                    _G.HouseLandMianPanelVM.CanApplyLandArr[HouseLocalDef.BuyHouseBelongType.Army]
            if NotNeedSelectOwner then
                UIViewMgr:ShowView(UIViewID.HouseLandPurchaseCandidateStatusWinView,self)
            else
                local BelongType = _G.HouseLandMianPanelVM.CanApplyLandArr[HouseLocalDef.BuyHouseBelongType.Personal] ==
                                       true and HouseLocalDef.BuyHouseBelongType.Personal or
                                       HouseLocalDef.BuyHouseBelongType.Army
                self.ViewModel:OpenSelectSurePanel(BelongType)
            end
        else
            self.ViewModel:OpenSelectSurePanel(self.ViewModel.LandInfo.BuyType)
        end
    else
        local Tips = ""
        if _G.HouseLandMgr:IsVisitWorld() then
            Tips = HouseLocalDef.LandInfoStr.CannotVisitorSelect
        elseif self.ViewModel.HasApply then
            Tips = HouseLocalDef.LandInfoStr.HasJoinSelect
        else
            Tips = HouseLocalDef.LandInfoStr.NoSelecCondition
        end
        _G.MsgTipsUtil.ShowTips(Tips)
    end
end

function HouseLandInformationPanelView:OnClickBtnReciveMoney()
    _G.HouseLandMgr:GetReturnAssets()
end

return HouseLandInformationPanelView
