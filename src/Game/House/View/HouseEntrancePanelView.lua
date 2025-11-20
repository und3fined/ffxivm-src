---
--- Author: muyanli
--- DateTime: 2025-06-06 10:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoRes = require("Protocol/ProtoRes")
local HouseInfoMgr = require("Game/House/HouseInfoMgr")

---@class HouseEntrancePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnHouse_1 UFButton
---@field BtnHouse_2 UFButton
---@field BtnHouse_3 UFButton
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field ImgPersonalLock UFImage
---@field Lottery1 HouseLandPurchaseLotteryItemView
---@field PanelLock_1 UFCanvasPanel
---@field PanelLock_2 UFCanvasPanel
---@field PanelLock_3 UFCanvasPanel
---@field PanelNormal_1 UFCanvasPanel
---@field PanelNormal_2 UFCanvasPanel
---@field PanelNormal_3 UFCanvasPanel
---@field RedDot CommonRedDotView
---@field RedDot1 CommonRedDotView
---@field TextNameLock_1 UFTextBlock
---@field TextNameLock_2 UFTextBlock
---@field TextNameLock_3 UFTextBlock
---@field TextNameNormal_1 UFTextBlock
---@field TextNameNormal_2 UFTextBlock
---@field TextNameNormal_3 UFTextBlock
---@field AnimIn_0 UWidgetAnimation
---@field AnimIn_1 UWidgetAnimation
---@field AnimUnlock1 UWidgetAnimation
---@field AnimUnlock2 UWidgetAnimation
---@field AnimUnlock3 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseEntrancePanelView = LuaClass(UIView, true)

function HouseEntrancePanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnHouse_1 = nil
	--self.BtnHouse_2 = nil
	--self.BtnHouse_3 = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.ImgPersonalLock = nil
	--self.Lottery1 = nil
	--self.PanelLock_1 = nil
	--self.PanelLock_2 = nil
	--self.PanelLock_3 = nil
	--self.PanelNormal_1 = nil
	--self.PanelNormal_2 = nil
	--self.PanelNormal_3 = nil
	--self.RedDot = nil
	--self.RedDot1 = nil
	--self.TextNameLock_1 = nil
	--self.TextNameLock_2 = nil
	--self.TextNameLock_3 = nil
	--self.TextNameNormal_1 = nil
	--self.TextNameNormal_2 = nil
	--self.TextNameNormal_3 = nil
	--self.AnimIn_0 = nil
	--self.AnimIn_1 = nil
	--self.AnimUnlock1 = nil
	--self.AnimUnlock2 = nil
	--self.AnimUnlock3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseEntrancePanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.Lottery1)
	self:AddSubView(self.RedDot)
	self:AddSubView(self.RedDot1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseEntrancePanelView:OnInit()
    self.ViewModel = _G.HouseLandMianPanelVM
    self.MMPViewModel = _G.HouseMineMainPanelVM
    local Num = #self.ViewModel.HouseEntranceConf
    for i = 1, Num do
        local TextNameNormal = self["TextNameNormal_" .. i]
        local TextNameLock = self["TextNameLock_" .. i]
        local Btn = self["BtnHouse_" .. i]
        if TextNameLock then
            TextNameLock:SetText(LSTR(self.ViewModel.HouseEntranceConf[i].Name))
        end
        TextNameNormal:SetText(LSTR(self.ViewModel.HouseEntranceConf[i].Name))
        UIUtil.AddOnClickedEvent(self, Btn, self.OnHouseEntranceClick, i)
    end

    self.TableListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectLandHistroyChanged)
    self.TableViewProcesslAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewProcessl, self.OnSelectChanged)

    self.Binders = {
        { "LandHistroyList", UIBinderUpdateBindableList.New(self, self.TableListAdapter) },
    }
end

function HouseEntrancePanelView:OnDestroy()

end

function HouseEntrancePanelView:OnShow()
    local ArmyID = _G.ArmyMgr:GetArmyID()
    if ArmyID ~= 0 then
        HouseInfoMgr:SendGroupHouseInfo(_G.ArmyMgr:GetArmyID())
    end

    self:RefreshHouseInfo()
    self:ShowRecycleBtn()
    
    if HouseInfoMgr:IsAnimationUltraPlay("EntrancePanelAniIn", true) then
        self:PlayAnimation(self.AnimIn_1)
    else
        self:PlayAnimation(self.AnimIn_0)
    end
end

function HouseEntrancePanelView:ShowRecycleBtn()
    local ShowRecycle = HouseInfoMgr:IsHouseAssetsNeedRecycle()
    UIUtil.SetIsVisible(self.Lottery1, ShowRecycle)
    if ShowRecycle then
        self.Lottery1:SetDataInex(HouseLocalDef.SelectInfoType.RecycleAssets)
    end
end

function HouseEntrancePanelView:OnHide()

end

function HouseEntrancePanelView:OnRegisterUIEvent()
    --UIUtil.AddOnClickedEvent(self, self.BtnHouse_1, self.OnClickPersonal)
    --UIUtil.AddOnClickedEvent(self, self.BtnHouse_2, self.OnClickTeam)
    --UIUtil.AddOnClickedEvent(self, self.BtnHouse_3, self.OnClickShare)
end

function HouseEntrancePanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.HouseGroupInfoUpdate, self.OnHouseGroupInfoUpdate)
	self:RegisterGameEvent(_G.EventID.PullSelfRoleHouseInfo, self.OnHouseInfoUpdate)
    self:RegisterGameEvent(_G.EventID.ArmyExit, self.OnExitArmy)
end

function HouseEntrancePanelView:OnRegisterBinder()

end

function HouseEntrancePanelView:RefreshHouseInfo()
    local Num = #self.ViewModel.HouseEntranceConf
    for i = 1, Num do
        local PanelNormal = self["PanelNormal_" .. i]
        local PanelLock = self["PanelLock_" .. i]
        local IsUnlock = self.ViewModel:GetHouseEntranceIsUnlock(i)
        UIUtil.SetIsVisible(PanelNormal, IsUnlock)
        UIUtil.SetIsVisible(PanelLock, not IsUnlock)

        if IsUnlock and not HouseInfoMgr:IsAnimationUltraPlay("EntrancePanelLock_" .. i, false) then
            self:RegisterTimer(function()
                self:PlayAnimation(self["AnimUnlock" .. i])
            end, 1, 0, 1)
        end
    end

    self.RedDot:SetRedDotIDByID(HouseLocalDef.RedDotDefine.ShareEntranceRedDot)
end

function HouseEntrancePanelView:OnHouseEntranceClick(Index)
    local IsUnlock = self.ViewModel:GetHouseEntranceIsUnlock(Index)
    if IsUnlock == true then
        if Index == 1 then
            HouseInfoMgr:OpenHouseInfoPanel(0)
        elseif Index == 2 then
            HouseInfoMgr:OpenHouseInfoPanel(2)
        end
    else
        if Index == 1 then
            local DisCountStampMoney = _G.HouseLandMgr:GetDisCountMoney(ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS)
            local DisCountGoldMoney = _G.HouseLandMgr:GetDisCountMoney(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
            if DisCountStampMoney ~= 0 or DisCountGoldMoney ~= 0 then
                self:DicountComfirm(DisCountStampMoney, DisCountGoldMoney)
            else
                MsgTipsUtil.ShowTips(HouseLocalDef.HouseEntranceTips.MajorNoHouse)
            end
        elseif Index == 2 then
            if _G.ArmyMgr:CheckIsArmyUnlockLevel() ~= true then
                MsgTipsUtil.ShowTips(HouseLocalDef.HouseEntranceTips.ArmyUnlock)
            elseif _G.ArmyMgr:GetArmyID() == 0 then
                MsgTipsUtil.ShowTips(HouseLocalDef.HouseEntranceTips.MajorNoArmy)
            elseif _G.ArmyMgr:GetArmyLevel() < 8 then                                  --目前部队只有8级 后续需要改成9级
                MsgTipsUtil.ShowTips(HouseLocalDef.HouseEntranceTips.ArmyUnderLevel)
            elseif HouseInfoMgr.ArmyHouseID == 0 then
                MsgTipsUtil.ShowTips(HouseLocalDef.HouseEntranceTips.ArmyNoHouse)
            end
        end
    end
    if Index == 3 then
        HouseInfoMgr:OpenHouseInfoPanel(5)
    end
    FLOG_INFO("HouseEntrancePanelView:OnHouseEntranceClick %d", Index)
end

function HouseEntrancePanelView:OnHouseGroupInfoUpdate(MsgBody)
    self:RefreshHouseInfo()
    self:ShowRecycleBtn()
end

function HouseEntrancePanelView:OnHouseInfoUpdate()
    self:ShowRecycleBtn()
end

function HouseEntrancePanelView:OnExitArmy()
    self:RefreshHouseInfo()
end

function HouseEntrancePanelView:DicountComfirm(DisCountStampMoney, DisCountGoldMoney)
    local ExtraParam = {
        CommTipsBtn1Str = HouseLocalDef.LocalTxtStr.BtnCancel,
        CommTipsBtn2Str = HouseLocalDef.LocalTxtStr.BtnSure,
        Btn2Callback = function(TipsPanel)
            _G.EventMgr:SendEvent(_G.EventID.HouseLandBuyTabSwitch, 2)
            TipsPanel:Hide()
        end
    }

    local Discount = DisCountStampMoney ~= 0 and DisCountStampMoney or DisCountGoldMoney
    local MoneyType = DisCountStampMoney ~= 0 and ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS or ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE
    local MoneyTypeName = _G.ScoreMgr:GetScoreNameText(MoneyType)
    local BelongTypeStr = HouseLocalDef.BuyHouseBelongTypeStr[1]
    local HelpInfoUtil = require("Utils/HelpInfoUtil")
    HelpInfoUtil.ShowHelpInfoByID(11224, ExtraParam, nil, BelongTypeStr, MoneyTypeName, Discount, MoneyTypeName) 
end

return HouseEntrancePanelView
