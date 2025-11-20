---
--- Author: muyanli
--- DateTime: 2025-06-06 10:58
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local DateTimeTools = require("Common/DateTimeTools")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local HouseInfoMgr = require("Game/House/HouseInfoMgr")
local ProtoRes = require("Protocol/ProtoRes")
local GroupPermissionType = ProtoRes.GroupPermissionType
local EToggleButtonState = _G.UE.EToggleButtonState

---@class HouseLandPurchasePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn_1 UFButton
---@field Btn_2 UFButton
---@field Btn_3 UFButton
---@field BuyHouseInfoPanel UFCanvasPanel
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field LockTag_1 HouseLandLockTagItemView
---@field LockTag_2 HouseLandLockTagItemView
---@field LockTag_3 HouseLandLockTagItemView
---@field Lottery1 HouseLandPurchaseLotteryItemView
---@field Lottery2 HouseLandPurchaseLotteryItemView
---@field PaneLock_1 UFCanvasPanel
---@field PaneLock_2 UFCanvasPanel
---@field PaneLock_3 UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field PanelLottery UFHorizontalBox
---@field PanelNormal_1 UFCanvasPanel
---@field PanelNormal_2 UFCanvasPanel
---@field PanelNormal_3 UFCanvasPanel
---@field TableViewList UTableView
---@field TableViewProcessl UTableView
---@field TextNameLock_1 UFTextBlock
---@field TextNameLock_2 UFTextBlock
---@field TextNameLock_3 UFTextBlock
---@field TextNameNormal_1 UFTextBlock
---@field TextNameNormal_2 UFTextBlock
---@field TextNameNormal_3 UFTextBlock
---@field TextTheTerm UFTextBlock
---@field TextTime UFTextBlock
---@field ToggleBtnExpand UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandPurchasePanelView = LuaClass(UIView, true)

function HouseLandPurchasePanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.Btn_1 = nil
    -- self.Btn_2 = nil
    -- self.Btn_3 = nil
    -- self.BuyHouseInfoPanel = nil
    -- self.CommonBkg02_UIBP = nil
    -- self.CommonBkgMask_UIBP = nil
    -- self.LockTag_1 = nil
    -- self.LockTag_2 = nil
    -- self.LockTag_3 = nil
    -- self.Lottery1 = nil
    -- self.Lottery2 = nil
    -- self.PaneLock_1 = nil
    -- self.PaneLock_2 = nil
    -- self.PaneLock_3 = nil
    -- self.PanelList = nil
    -- self.PanelLottery = nil
    -- self.PanelNormal_1 = nil
    -- self.PanelNormal_2 = nil
    -- self.PanelNormal_3 = nil
    -- self.TableViewList = nil
    -- self.TableViewProcessl = nil
    -- self.TextNameLock_1 = nil
    -- self.TextNameLock_2 = nil
    -- self.TextNameLock_3 = nil
    -- self.TextNameNormal_1 = nil
    -- self.TextNameNormal_2 = nil
    -- self.TextNameNormal_3 = nil
    -- self.TextTheTerm = nil
    -- self.TextTime = nil
    -- self.ToggleBtnExpand = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandPurchasePanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CommonBkg02_UIBP)
    self:AddSubView(self.CommonBkgMask_UIBP)
    self:AddSubView(self.LockTag_1)
    self:AddSubView(self.LockTag_2)
    self:AddSubView(self.LockTag_3)
    self:AddSubView(self.Lottery1)
    self:AddSubView(self.Lottery2)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLandPurchasePanelView:OnInit()
    self.ViewModel = _G.HouseLandMianPanelVM
    local estateInfo = self.ViewModel:GetEstateCfg()
    local Num = #estateInfo
    for i = 1, Num do
        local TextNameNormal = self["TextNameNormal_" .. i]
        local TextNameLock = self["TextNameLock_" .. i]
        local LockTag = self["LockTag_" .. i]
        local Btn = self["Btn_" .. i]
        TextNameLock:SetText(LSTR(estateInfo[i].EstateName))
        TextNameNormal:SetText(LSTR(estateInfo[i].EstateName))
        LockTag.TextTag:SetText(HouseLocalDef.LocalTxtStr.UnLockByTask)
        UIUtil.AddOnClickedEvent(self, Btn, self.OnEstateBtnClick, i)
    end
    self.Lottery1:SetDataInex(HouseLocalDef.SelectInfoType.MySelect)
    self.Lottery2:SetDataInex(HouseLocalDef.SelectInfoType.ArmySelect)

    self.TableListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectLandHistroyChanged)
    self.TableViewProcesslAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewProcessl)

    self.Binders = {
        {"LandHistroyList", UIBinderUpdateBindableList.New(self, self.TableListAdapter)},
        {"BuyInfoList", UIBinderUpdateBindableList.New(self, self.TableViewProcesslAdapter)},
        {"CurSelectPhase", UIBinderValueChangedCallback.New(self, nil, self.RefreshBuyInfo)},
        {"LandSelectInfo", UIBinderValueChangedCallback.New(self, nil, self.RefreshSelectInfo)}
    }
end

function HouseLandPurchasePanelView:OnDestroy()

end

function HouseLandPurchasePanelView:OnShow()
    if HouseInfoMgr:IsAnimationUltraPlay("LandPurchaseAniIn", true) then
        self:PlayAnimation(self.AnimIn_1)
    else
        self:PlayAnimation(self.AnimIn_0)
    end

    _G.HouseLandMgr:SendQueryBuyStatus()
    self:RefreshEstateInfo()
    local IsVisitWorld = _G.HouseLandMgr:IsVisitWorld()
    UIUtil.SetIsVisible(self.BuyHouseInfoPanel, not IsVisitWorld)
end

function HouseLandPurchasePanelView:OnHide()
    _G.HouseLandMianPanelVM:SetCurBuyConditionsBelongType(1)
end

function HouseLandPurchasePanelView:OnRegisterUIEvent()
    UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnExpand, self.OnToggleBtnExpandStateChanged)
end

function HouseLandPurchasePanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.HouseGetReturnAssets, self.OnGetReturnAssets)
end

function HouseLandPurchasePanelView:OnGetReturnAssets()
    self:RefreshSelectInfo()
end

function HouseLandPurchasePanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function HouseLandPurchasePanelView:RefreshEstateInfo()
    UIUtil.SetIsVisible(self.PanelList, false)
    local estateInfo = self.ViewModel:GetEstateCfg()
    local Num = #estateInfo
    for i = 1, Num do
        local isUnLock = self.ViewModel:GetEstateIsUnlock(i)
        local PaneLock = self["PaneLock_" .. i]
        local PanelNormal = self["PanelNormal_" .. i]
        UIUtil.SetIsVisible(PanelNormal, isUnLock)
        UIUtil.SetIsVisible(PaneLock, not isUnLock)
        if isUnLock and not HouseInfoMgr:IsAnimationUltraPlay("HouseLandPaneLock_" .. i, false) then
            self:RegisterTimer(function()
                self:PlayAnimation(self["AnimUnlock" .. i])
            end, 1, 0, 1)
        end
    end

    self:SwitchLandHistoryExpand(false, false)
end

function HouseLandPurchasePanelView:OnEstateBtnClick(Index)
    local estateInfo = self.ViewModel:GetEstateCfg()
    local isUnLock = self.ViewModel:GetEstateIsUnlock(Index)
    if not isUnLock then
        _G.MsgTipsUtil.ShowTipsByID(estateInfo[Index].LockTipsID)
        return
    else
        local MapID = _G.HouseLandMgr:GetMapID(Index)
        if MapID then
            _G.WorldMapMgr:ShowIndividualHouseMap(MapID)
        end
    end
end

function HouseLandPurchasePanelView:OnToggleBtnExpandStateChanged(ToggleButton, State)
    self:SwitchLandHistoryExpand(UIUtil.IsToggleButtonChecked(State), true)
end

function HouseLandPurchasePanelView:SwitchLandHistoryExpand(IsExpand, FromToggleChange)
    UIUtil.SetIsVisible(self.PanelList, IsExpand)
    local State = IsExpand and EToggleButtonState.Checked or EToggleButtonState.UnChecked
    if not FromToggleChange and self.ToggleBtnExpand ~= nil then
        UIUtil.SetToggleButtonState(self.ToggleBtnExpand, State)
    end
end

function HouseLandPurchasePanelView:OnSelectLandHistroyChanged(Index, ItemData, ItemView)
    FLOG_INFO("HouseLandPurchasePanelView:OnClickedTermItem %d", ItemData.PhaseID)
    self.ViewModel:SwitchSelectPhase(ItemData.PhaseID)
    self:SwitchLandHistoryExpand(false, false)
end

function HouseLandPurchasePanelView:RefreshBuyInfo()
    if self.ViewModel == nil then
        return
    end
    self.TextTheTerm:SetText(LSTR(string.format("第%d期", self.ViewModel.CurSelectPhase)))
    UIUtil.SetIsVisible(self.TextTime, self.ViewModel.CurSelectPhase == #_G.HouseLandMianPanelVM.LandHistroyList.Items)
    if self.ViewModel.CurBuyStateInfo ~= nil then
        local isApplyStage = _G.HouseLandMianPanelVM.CurBuyStateInfo.Stage == ProtoCS.LandStatusType.LandStatusType_Sale
        local TheTermStr = isApplyStage == true and LSTR("申请期剩余:%s") or LSTR("公示期剩余:%s")
        local TimeStr = DateTimeTools.TimeFormat(_G.HouseLandMianPanelVM.CurBuyStateInfo.LeftTime, "dd:hh", true)
        local TimeTxt = string.format(TheTermStr, TimeStr)
        self.TextTime:SetText(TimeTxt)
    end
end

function HouseLandPurchasePanelView:IsShowLotteryButton(Type)
    local IsSelectLand = _G.HouseLandMgr:IsParticipatePersonalLandSelection(Type)
    local HasLandRecovery = _G.HouseLandMgr:IsHaveLandRecoveryCompensation(Type)
    local HasBuild
    
    if Type == HouseLocalDef.BuyHouseBelongType.Army then
        HasBuild = HouseInfoMgr.ArmyHouseID ~= 0 and not HouseInfoMgr:IsMajorArmyHouseDestroied()
    else
        local LandSelectionData =  _G.HouseLandMianPanelVM.LandSelectInfo and _G.HouseLandMianPanelVM.LandSelectInfo[Type] or {}
        if LandSelectionData.GroupID and LandSelectionData.GroupID ~= 0 then
            HasBuild = HouseInfoMgr.ArmyHouseID ~= 0 and not HouseInfoMgr:IsMajorArmyHouseDestroied()
        else
            HasBuild = HouseInfoMgr.MajorHouseID ~= 0 and not HouseInfoMgr:IsPersonalHouseDestroied()
        end
    end

    local IsVisitWorld = _G.HouseLandMgr:IsVisitWorld()
    return ((IsSelectLand and not HasBuild) or HasLandRecovery) and not IsVisitWorld
end

function HouseLandPurchasePanelView:RefreshSelectInfo()
    local ShowLottery1, ShowLottery2 = false, false
    if _G.HouseLandMianPanelVM.LandSelectInfo then
        ShowLottery1 = self:IsShowLotteryButton(HouseLocalDef.BuyHouseBelongType.Personal)
        ShowLottery2 = self:IsShowLotteryButton(HouseLocalDef.BuyHouseBelongType.Army)
        UIUtil.SetIsVisible(self.Lottery1, ShowLottery1, ShowLottery1)
        UIUtil.SetIsVisible(self.Lottery2, ShowLottery2, ShowLottery2)

        local ReturnInfo = _G.HouseLandMianPanelVM.ReturnInfo
        if ReturnInfo then
            if not UIViewMgr:IsViewVisible(UIViewID.HouseThingWinView) then
                UIViewMgr:ShowView(UIViewID.HouseThingWinView, ReturnInfo)
                return
            end
        else
            if UIViewMgr:IsViewVisible(UIViewID.HouseThingWinView) then
                UIViewMgr:HideView(UIViewID.HouseThingWinView)
            end
        end

        if UIViewMgr:IsViewVisible(UIViewID.CommonRewardPanel) then return end
        local IsVisitWorld = _G.HouseLandMgr:IsVisitWorld()
        if not IsVisitWorld then
            local HasPrivilege = _G.ArmyMgr:GetSelfIsHavePermisstion(GroupPermissionType.PermissionTypeEstatePurchaseLandAndBuild)
            local GroupNoBuild, _, GroupIsDestroy = _G.HouseLandMgr.GroupHasLandNoBuild()
            local SelfNoBuild, _, SelfIsDestroy = _G.HouseLandMgr.SelfHasLandNoBuild()
            if HasPrivilege and GroupNoBuild and not GroupIsDestroy then
                if not UIViewMgr:IsViewVisible(UIViewID.HouseLandInformationPanel) then
                    _G.HouseLandMgr:OpenHouseOrLandPanel(_G.HouseLandMianPanelVM.LandSelectInfo[ProtoCS.HouseType.HouseType_HouseType_Personal])
                end 
            elseif SelfNoBuild and not SelfIsDestroy then
                if not UIViewMgr:IsViewVisible(UIViewID.HouseLandInformationPanel) then
                    _G.HouseLandMgr:OpenHouseOrLandPanel(_G.HouseLandMianPanelVM.LandSelectInfo[ProtoCS.HouseType.HouseType_HouseType_Personal])
                end  
            end
        end
    end
end

return HouseLandPurchasePanelView
