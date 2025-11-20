local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local HouseLandInformationListItemVM = require("Game/House/VM/Item/HouseLandInformationListItemVM")
local UIBindableList = require("UI/UIBindableList")
local ProtoCS = require("Protocol/ProtoCS")
local DateTimeTools = require("Common/DateTimeTools")
local TimeUtil = require("Utils/TimeUtil")
local UIViewMgr = require("UI/UIViewMgr")
local ProtoRes = require("Protocol/ProtoRes")
local UILayer = require("UI/UILayer")

local HouseLandInformationPanelVM = LuaClass(UIViewModel)

function HouseLandInformationPanelVM:Ctor()
    self.LandInfoVMList = UIBindableList.New(HouseLandInformationListItemVM)
    self.IconState = nil
    self.TextState = nil
    self.TextTime = nil
    self.MoneyType = nil
    self.LandStatus = nil
    self.CanApply = false
    self.HasApply = false
    self.BtnJoinSelectTxt = nil
    self.BtnJoinSelectVisible = nil
    self.BtnReciveMoneyVisible = false
    self.ImgSelectedFlagVisible  = false
    self.BtnTransmitVisible = true
    self.ApplyNumber = nil
    self.LandInfo = nil
    self.ResidenceNumber = nil
    self.AreaNumber = nil
    self.AplType = 1
    self.HasSelecedAward = false
end

function HouseLandInformationPanelVM:UpdateVM(Params, FromSelectRsp)
    if FromSelectRsp == nil then
        FromSelectRsp = false
    end

    if Params == nil or (not FromSelectRsp and (Params.LandList == nil or #Params.LandList <= 0)) then
        return
    end

    if FromSelectRsp then
        if self.ResidenceNumber == Params.ResidenceNumber and self.AreaNumber == Params.AreaNumber and
            self.LandInfo.LandNumber == Params.LandNumber then
        end
        self.LandInfo.ApplyNumber = Params.ApplyNumber
        self.LandInfo.ApplyCount = Params.ApplyCount
        Params.PhaseEndTime = Params.ShowTime
    else
        self.LandInfo = Params.LandList[1]
        self.HasApply = _G.HouseLandMianPanelVM.CurBuyStateInfo.AplStatus >= ProtoCS.ApplyStatus.ApplyStatus_Apply
    end

    self.LandStatus = self.LandInfo.LandStatus
    if self.LandStatus == nil then return end
    self.ResidenceNumber = Params.ResidenceNumber
    self.AreaNumber = Params.AreaNumber
    self.CanApply = self.LandInfo.CanApply
    local LandSelectInfo = _G.HouseLandMianPanelVM.LandSelectInfo
    local SelfApply = LandSelectInfo[HouseLocalDef.BuyHouseBelongType.Personal] or {}

    local HasReturnInfo = next(SelfApply) and SelfApply.ReturnMoney and SelfApply.ReturnMoney > 0 and SelfApply.AplStatus ~= ProtoCS.ApplyStatus.ApplyStatus_Return
    local IsSelfAplLand = next(SelfApply) and SelfApply.ResidenceNumber == self.LandInfo.ResidenceNumber and SelfApply.LandNumber == self.LandInfo.LandNumber

    self.TextState = HouseLocalDef.LandListPhaseTypeStr[self.LandStatus]
    self.IconState = string.format(HouseLocalDef.LandStatuIconPath, self.LandInfo.LandStatus, self.LandInfo.LandStatus)
    self.MoneyType = self.LandInfo.MoneyType
    self.ApplyNumber = self.LandInfo.ApplyNumber

    local SelfHasJoinSelect = self.LandInfo.ApplyNumber > 0
    local ArmyHasJoinSelect = self.LandInfo.GroupAplNumber > 0
    local SelfHasSelected = self.LandInfo.AwardNumber > 0 and self.LandInfo.ApplyNumber == self.LandInfo.AwardNumber and IsSelfAplLand -- 个人在这片土地是否中选
    local ArmyHasSelected = self.LandInfo.GroupID ~= 0 and self.LandInfo.GroupID == _G.ArmyMgr:GetArmyID()-- 部队这片土地是否中选
    local HasJoinSelect = SelfHasJoinSelect or SelfHasJoinSelect -- 是否参选
    local HasSelected
    if self.LandInfo.GroupID ~= 0 then
        HasSelected = ArmyHasSelected and self.LandStatus >= ProtoCS.LandStatusType.LandStatusType_Public 
    else
        HasSelected = SelfHasSelected and self.LandStatus >= ProtoCS.LandStatusType.LandStatusType_Public
    end

    self.ImgSelectedFlagVisible = HasSelected
    self.HasSelecedAward = HasSelected
    local PhaseTimeStr = ""
    local InfoItemNum = 0
    local ServerTime = TimeUtil.GetServerTime()
    if self.LandStatus == ProtoCS.LandStatusType.LandStatusType_Ready then
        InfoItemNum = 3
        local LeftTime = Params.ReadyEndTime - ServerTime
        local TimeStr = DateTimeTools.TimeFormat(LeftTime, "dd:hh", true)
        PhaseTimeStr = string.format(HouseLocalDef.LandInfoStr.ReadyTimeTips, TimeStr)
    elseif self.LandStatus == ProtoCS.LandStatusType.LandStatusType_Sale then
        InfoItemNum = 5
        local LeftTime = Params.PhaseEndTime - ServerTime
        local TimeStr = DateTimeTools.TimeFormat(LeftTime, "dd:hh", true)
        PhaseTimeStr = string.format(HouseLocalDef.LandInfoStr.PublicTimeTips, TimeStr)
        if self.HasApply then
            InfoItemNum = 6
            if HasSelected then
                InfoItemNum = 7
            end
        end
    elseif self.LandStatus >= ProtoCS.LandStatusType.LandStatusType_Public then
        PhaseTimeStr = string.format(LSTR("公示期剩余:%s"),  DateTimeTools.TimeFormat(_G.HouseLandMianPanelVM.CurBuyStateInfo.LeftTime, "dd:hh", true))
        if HasJoinSelect then
            InfoItemNum = HasSelected and 8 or 7
        else
            InfoItemNum = 5
        end
    end

    self.TextTime = PhaseTimeStr
    self.BtnJoinSelectVisible = self.LandInfo.LandStatus == ProtoCS.LandStatusType.LandStatusType_Sale
    self.BtnReciveMoneyVisible = HasReturnInfo and IsSelfAplLand
    self.BtnTransmitVisible = not self.BtnReciveMoneyVisible

    local BtnJoinSelectTxt = ""
    if self.HasApply then
        BtnJoinSelectTxt = HouseLocalDef.LandInfoStr.HasJoinSelect
    elseif self.CanApply then
        BtnJoinSelectTxt = HouseLocalDef.LandInfoStr.JoinSelect
    else
        BtnJoinSelectTxt = HouseLocalDef.LandInfoStr.CannotSelect
    end

    self.BtnJoinSelectTxt = BtnJoinSelectTxt

    local LandInfoVMList = {}
    for i = 1, InfoItemNum do
        table.insert(LandInfoVMList, i, {
            Index = i,
            ResidenceNumber = Params.ResidenceNumber,
            AreaNumber = Params.AreaNumber,
            LandInfo = self.LandInfo,
            SelfHasJoinSelect = SelfHasJoinSelect,
            ArmyHasJoinSelect = ArmyHasJoinSelect,
            HasJoinSelect = HasJoinSelect,
            SelfHasSelected = SelfHasSelected,
            ArmyHasSelected = ArmyHasSelected,
            HasSelected = HasSelected
        })
    end
    self.LandInfoVMList:UpdateByValues(LandInfoVMList)
end

function HouseLandInformationPanelVM:SendBuyLandReq(AplType)
    _G.HouseLandMgr:SendBuyLandReq(self.ResidenceNumber, self.AreaNumber, self.LandInfo.LandNumber, AplType)
end

function HouseLandInformationPanelVM:OpenSelectSurePanel(BelongType)
    if BelongType == nil then
        BelongType = self.LandInfo.BuyType
    end
    local HelpInfoUtil = require("Utils/HelpInfoUtil")
    local DisCountMoney = _G.HouseLandMgr:GetDisCountMoney(self.MoneyType)

    if BelongType ~=  HouseLocalDef.BuyHouseBelongType.Personal then
        DisCountMoney = 0
    end

    local ExtraParam = {
        CheckBoxNoReminderStr = HouseLocalDef.LocalTxtStr.LandBuyReminderStr,
        CommTipsBtn1Str = HouseLocalDef.LocalTxtStr.BtnCancel,
        CommTipsBtn2Str = HouseLocalDef.LocalTxtStr.BtnSure,
        CostItemID = self.MoneyType,
        CostNum = self.LandInfo.Price - DisCountMoney,
        NoReminderTips = HouseLocalDef.LocalTxtStr.NoReminderTips
    }

    ExtraParam.Btn2Callback = function(TipsPanel)
        local ScoreValue = _G.ScoreMgr:GetScoreValueByID(ExtraParam.CostItemID)
        if ScoreValue >= ExtraParam.CostNum then
            self:SendBuyLandReq(BelongType)
            if TipsPanel then
                TipsPanel:Hide()
            end
        elseif self.MoneyType == ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS then
            _G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(950032), --- "代币不足"
            string.format(_G.LSTR(950034), "水晶"), --- "%s不足，是否前往充值？"
            function()
                if _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_REBATE, true) then
                    -- 打开充值界面
                    _G.RechargingMgr:ShowMainPanel()
                    _G.RechargingMgr:OnChangedMainPanelCloseBtnToBack(true)
                end
            end, nil, _G.LSTR(950030), --- "取消"
            _G.LSTR(950033) --- "确认"
            )
        else
            _G.MsgTipsUtil.ShowTips(_G.LSTR(1110044))
        end
    end
    local MoneyTypeName = _G.ScoreMgr:GetScoreNameText(self.MoneyType)
    local BelongTypeStr = HouseLocalDef.BuyHouseBelongTypeStr[BelongType]
    local FilterTitleIDs
    if DisCountMoney == 0 then
        FilterTitleIDs = {3}
    end

    if BelongType == HouseLocalDef.BuyHouseBelongType.Army and _G.HouseLandMgr:IsArmySelectionFirstJoin() then
        if FilterTitleIDs and next(FilterTitleIDs) then
           table.insert(FilterTitleIDs, 2)
        else
            FilterTitleIDs = {2}
        end
    end
    
    local ViewID = HelpInfoUtil.ShowHelpInfoByID(11208, ExtraParam, FilterTitleIDs, BelongTypeStr, MoneyTypeName,
        DisCountMoney, MoneyTypeName, self.LandInfo.Price - DisCountMoney, MoneyTypeName, BelongTypeStr)
    UIViewMgr:ChangeLayer(ViewID, UILayer.Normal)
end

return HouseLandInformationPanelVM
