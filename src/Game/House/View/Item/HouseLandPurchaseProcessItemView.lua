---
--- Author: muyanli
--- DateTime: 2025-05-30 20:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local DateTimeTools = require("Common/DateTimeTools")
local ProtoCS = require("Protocol/ProtoCS")

local LandCS = ProtoCS

---@class HouseLandPurchaseProcessItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field BtnSwitch UFButton
---@field IconState UFImage
---@field ImgFocus UFImage
---@field ImgLine UFImage
---@field TextState UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandPurchaseProcessItemView = LuaClass(UIView, true)

function HouseLandPurchaseProcessItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.Btn = nil
    --self.BtnSwitch = nil
    --self.IconState = nil
    --self.ImgFocus = nil
    --self.ImgLine = nil
    --self.TextState = nil
    --self.TextTitle = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandPurchaseProcessItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLandPurchaseProcessItemView:OnInit()
    UIUtil.SetIsVisible(self.BtnSwitch, false)
end

function HouseLandPurchaseProcessItemView:OnDestroy()

end

function HouseLandPurchaseProcessItemView:OnShow()

end

function HouseLandPurchaseProcessItemView:OnHide()

end

function HouseLandPurchaseProcessItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.Btn, self.OnPanelClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnBtnSwitchBuyCondition)
end

function HouseLandPurchaseProcessItemView:OnRegisterGameEvent()
end

function HouseLandPurchaseProcessItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params or Params.Data == nil then
        return
    end
    local TitleStr = HouseLocalDef.BuyHouseStateType[Params.Index]
    if Params.Index == 1 then
        UIUtil.SetIsVisible(self.BtnSwitch, true, true)
    else
        self.TextTitle:SetText(TitleStr)
    end
    self:RefreshState()
end

-- // 不可参选 未参选 已参选 已中奖
-- enum ApplyStatus {
--   ApplyStatus_Min             = 0;
--   ApplyStatus_Unable          = 1; // 不可参选
--   ApplyStatus_NotApply        = 2; // 未参选
--   ApplyStatus_Apply           = 3; // 已参选
--   ApplyStatus_Award           = 4; // 已中奖
--   ApplyStatus_NoReturn        = 5; // 未退钱
--   ApplyStatus_Return          = 6; // 已退钱
-- }

-- enum BuildStatusType {
--     BuildStatus_Min             = 0;
--     BuildStatus_CanNotBuild     = 1; // 不可建造
--     BuildStatus_CanBuild        = 2; // 可建造
--     BuildStatus_Built           = 3; // 已建造
--     BuildStatus_Overdue         = 4; // 已逾期
--   }
function HouseLandPurchaseProcessItemView:OnPanelClicked()
    local Params = self.Params
    if nil == Params and _G.HouseLandMianPanelVM.CurBuyStateInfo == nil then
        return
    end

    local IsCurPhase = _G.HouseLandMianPanelVM.PhaseCnt > 0 and
        _G.HouseLandMianPanelVM.PhaseCnt == _G.HouseLandMianPanelVM.CurSelectPhase

    local IsCurPhaseEnd = _G.HouseLandMianPanelVM.CurBuyStateInfo.Stage ==
        LandCS.LandStatusType.LandStatusType_Ready

    local TipsIndex = 0
    if Params.Index == 1 then
        if not IsCurPhaseEnd then
            UIViewMgr:ShowView(UIViewID.HousePurchaseConditionsWinView)
        end
    end

    if IsCurPhase and not IsCurPhaseEnd then
        if Params.Index == 2 or Params.Index == 3 then
            if _G.HouseLandMianPanelVM.CurBuyStateInfo.AplStatus >= LandCS.ApplyStatus.ApplyStatus_Apply then
                local Index = _G.HouseLandMianPanelVM.CurBuyConditionsBelongType
                local BuyStateInfo = _G.HouseLandMianPanelVM.BuyStateInfoShow
                local IsPersonJoin = BuyStateInfo.IsPersonJoin
                local IsArmyJoin = BuyStateInfo.IsArmyJoin
                if Index == HouseLocalDef.BuyHouseBelongType.Personal and IsPersonJoin and _G.HouseLandMianPanelVM.LandSelectInfo[Index] then
                    _G.HouseLandMgr:OpenHouseOrLandPanel(_G.HouseLandMianPanelVM.LandSelectInfo[Index])
                end

                if Index == HouseLocalDef.BuyHouseBelongType.Army and IsArmyJoin and _G.HouseLandMianPanelVM.LandSelectInfo[Index] then
                    _G.HouseLandMgr:OpenHouseOrLandPanel(_G.HouseLandMianPanelVM.LandSelectInfo[Index])
                end
            else
                TipsIndex = 2
            end
        elseif Params.Index == 4 then
            if _G.HouseLandMianPanelVM.CurBuyStateInfo.BuildStatus <= LandCS.BuildStatusType.BuildStatus_CanNotBuild then
                TipsIndex = 3
            else
                --UIViewMgr:ShowView(UIViewID.HousePurchaseConditionsWinView) --打开土地资料界面
            end
        end
    end
    if IsCurPhaseEnd then
        TipsIndex = 1
    end
    local BuyStateTips = HouseLocalDef.BuyStateTips[TipsIndex]
    if BuyStateTips ~= nil and IsCurPhase then
        _G.MsgTipsUtil.ShowTips(BuyStateTips)
    end
end

function HouseLandPurchaseProcessItemView:OnBtnSwitchBuyCondition()
    local Params = self.Params
    if nil == Params or Params.Index ~= 1 then
        return
    end

    if _G.HouseLandMianPanelVM.CurBuyConditionsBelongType == 1 then
        _G.HouseLandMianPanelVM:SetCurBuyConditionsBelongType(2)
    else
        _G.HouseLandMianPanelVM:SetCurBuyConditionsBelongType(1)
    end
   
    _G.HouseLandMianPanelVM:SetCurSelectPhase(_G.HouseLandMianPanelVM.CurSelectPhase)
end

function HouseLandPurchaseProcessItemView:RefreshState(Index)
    local Params = self.Params
    if nil == Params and _G.HouseLandMianPanelVM.CurBuyStateInfo == nil then
        return
    end
    local IsCurPhase = _G.HouseLandMianPanelVM.PhaseCnt > 0 and
        _G.HouseLandMianPanelVM.PhaseCnt == _G.HouseLandMianPanelVM.CurSelectPhase

    local IsCurPhaseEnd = _G.HouseLandMianPanelVM.CurBuyStateInfo.Stage ==
        LandCS.LandStatusType.LandStatusType_Ready

    local IsSalePhase = _G.HouseLandMianPanelVM.CurBuyStateInfo.Stage ==
        LandCS.LandStatusType.LandStatusType_Sale

    local IsPublicPhase = _G.HouseLandMianPanelVM.CurBuyStateInfo.Stage ==
        LandCS.LandStatusType.LandStatusType_Public

    local SwitchBelongType = _G.HouseLandMianPanelVM.CurBuyConditionsBelongType
    local StateStr, IsAllPass = _G.HouseLandMianPanelVM:GetBuyConditionPassResultStr(SwitchBelongType)
    local BuyStateInfo = _G.HouseLandMianPanelVM.BuyStateInfoShow
    local IsPersonJoin = BuyStateInfo.IsPersonJoin
    local IsArmyJoin = BuyStateInfo.IsArmyJoin

    local HasJoined = (IsPersonJoin and SwitchBelongType == HouseLocalDef.BuyHouseBelongType.Personal) or 
    (IsArmyJoin and SwitchBelongType == HouseLocalDef.BuyHouseBelongType.Army)

    local FocusIndex = 0
    local StateIconIndex = 2
    local StateColcorIndex = 1
    local IconPath = ""

    if Params.Index == 1 then
        local TitleStr = HouseLocalDef.BuyHouseStateType[Params.Index]
        self.TextTitle:SetText(string.format(TitleStr,
            HouseLocalDef.BuyHouseBelongTypeStr[SwitchBelongType]))
        if not IsAllPass then
            StateColcorIndex = 3
            StateStr = StateStr .. HouseLocalDef.BuyHouseState[1]
            if IsSalePhase then
                StateIconIndex = 2
            else
                StateIconIndex = 3
            end
        else
            StateColcorIndex = 2
            StateIconIndex = 4
        end
    elseif Params.Index == 2 then
        if HasJoined then
            StateStr = HouseLocalDef.BuyHouseState[5]
            StateColcorIndex = 2
            StateIconIndex = 4
        else
            StateColcorIndex = 3
            StateIconIndex = 3
            if not IsAllPass then
                StateStr = HouseLocalDef.BuyHouseState[4]
            else
                StateStr = HouseLocalDef.BuyHouseState[3]
            end
        end

        if IsCurPhase and IsSalePhase then
            if _G.HouseLandMianPanelVM.CurBuyStateInfo.AplStatus < LandCS.ApplyStatus.ApplyStatus_Apply then
                local TimeStr = DateTimeTools.TimeFormat(_G.HouseLandMianPanelVM.CurBuyStateInfo.LeftTime, "dd:hh",
                    true)
                StateStr = string.format(HouseLocalDef.BuyHouseState[2], TimeStr)
                StateColcorIndex = 1
                StateIconIndex = 2
                if not IsAllPass and not HasJoined then
                    StateIconIndex = 1
                end
            end
        end
    elseif Params.Index == 3 then
        if BuyStateInfo.AplStatus == LandCS.ApplyStatus.ApplyStatus_Award and HasJoined then
            StateStr = HouseLocalDef.BuyHouseState[10]
            StateColcorIndex = 2
            StateIconIndex = 4
        else
            StateStr = HouseLocalDef.BuyHouseState[9]
            StateColcorIndex = 3
            StateIconIndex = 3
        end

        if IsCurPhase then
            if HasJoined then
                if IsSalePhase then
                    StateColcorIndex = 1
                    StateIconIndex = 2
                    StateStr = string.format(HouseLocalDef.BuyHouseState[7],
                        DateTimeTools.TimeFormat(_G.HouseLandMianPanelVM.CurBuyStateInfo.LeftTime, "dd:hh", true))
                else
                    if BuyStateInfo.AplStatus == LandCS.ApplyStatus.ApplyStatus_Award then
                        StateStr = HouseLocalDef.BuyHouseState[10]
                        StateColcorIndex = 2
                        StateIconIndex = 4
                    else
                        StateStr = HouseLocalDef.BuyHouseState[9]
                        StateColcorIndex = 3
                        StateIconIndex = 3
                    end
                end
            else
                if IsSalePhase then
                    StateColcorIndex = 1
                    StateIconIndex = 1
                    StateStr = HouseLocalDef.BuyHouseState[6]
                else 
                    StateColcorIndex = 1
                    StateIconIndex = 3
                    StateStr = HouseLocalDef.BuyHouseState[8]
                end
            end
        end
    elseif Params.Index == 4 then
        if HasJoined and IsCurPhase and BuyStateInfo.BuildStatus == LandCS.BuildStatusType.BuildStatus_CanBuild then
            StateStr = string.format(HouseLocalDef.BuyHouseState[2], DateTimeTools.TimeFormat(BuyStateInfo.LeftTime, "dd:hh", true))
            StateColcorIndex = 1
            StateIconIndex = 2
        else
            if HasJoined and BuyStateInfo.BuildStatus == LandCS.BuildStatusType.BuildStatus_Built then
                StateColcorIndex = 2
                StateIconIndex = 4
            else
                StateColcorIndex = 3
                StateIconIndex = 3
                if IsCurPhase and IsSalePhase then
                    StateColcorIndex = 1
                    StateIconIndex = 1
                end
            end

            if HasJoined then
                StateStr = HouseLocalDef.BuyHouseState[10 + BuyStateInfo.BuildStatus]
            else
                StateStr = HouseLocalDef.BuyHouseState[11]
            end
        end
    end

    if IsSalePhase then
        if not _G.HouseLandMianPanelVM.CanApplyLand then
            FocusIndex = 1
        elseif _G.HouseLandMianPanelVM.CurBuyStateInfo.AplStatus < LandCS.ApplyStatus.ApplyStatus_Apply then
            FocusIndex = 2
        elseif _G.HouseLandMianPanelVM.CurBuyStateInfo.AplStatus == LandCS.ApplyStatus.ApplyStatus_Apply then
            FocusIndex = 3
        end
    end

    if HasJoined and IsPublicPhase and _G.HouseLandMianPanelVM.CurBuyStateInfo.BuildStatus == LandCS.BuildStatusType.BuildStatus_CanBuild then
        FocusIndex = 4
    end

    IconPath = string.format(HouseLocalDef.BuyHouseProcessIconPrePath,
        HouseLocalDef.BuyHouseProcessIconType[StateIconIndex],
        HouseLocalDef.BuyHouseProcessIconType[StateIconIndex])
    UIUtil.SetIsVisible(self.ImgFocus, IsCurPhase and FocusIndex == Params.Index)
    UIUtil.ImageSetBrushFromAssetPath(self.IconState, IconPath)
    self.TextState:SetText(StateStr)
    UIUtil.TextBlockSetColorAndOpacityHex(self.TextState,
        HouseLocalDef.BuyHouseStateTxtColor[StateColcorIndex] or "d5d5d5")
end

return HouseLandPurchaseProcessItemView
