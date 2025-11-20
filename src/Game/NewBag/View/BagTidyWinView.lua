---
--- Author: yutingzhan
--- DateTime: 2025-05-27 14:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local BagTidyWinVM = require("Game/NewBag/VM/BagTidyWinVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
---@class BagTidyWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field CommBtnM_UIBP CommBtnMView
---@field CommMoneySlot CommMoneySlotView
---@field Consumption1 BagTidyConsumptionItemView
---@field Consumption2 BagTidyConsumptionItemView
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BagTidyWinView = LuaClass(UIView, true)

function BagTidyWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameL_UIBP = nil
	--self.CommBtnM_UIBP = nil
	--self.CommMoneySlot = nil
	--self.Consumption1 = nil
	--self.Consumption2 = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BagTidyWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameL_UIBP)
	self:AddSubView(self.CommBtnM_UIBP)
	self:AddSubView(self.CommMoneySlot)
	self:AddSubView(self.Consumption1)
	self:AddSubView(self.Consumption2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BagTidyWinView:OnInit()
	self.ViewModel = BagTidyWinVM.New()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.Binders = {
		{"BagTidyItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{"ConsumMoney1", UIBinderSetText.New(self, self.Consumption1.TextMoney1) },
		{"ConsumMoney2", UIBinderSetText.New(self, self.Consumption1.TextMoney2) },
		{"ConsumMoney2Color", UIBinderSetColorAndOpacityHex.New(self, self.Consumption1.TextMoney2) },
		{"ConsumMoney1Visiable", UIBinderSetIsVisible.New(self, self.Consumption1.PanelMoney1) },
		{"ConsumMoney2Visiable", UIBinderSetIsVisible.New(self, self.Consumption1.PanelMoney2) },
		{"ObtainMoney1", UIBinderSetText.New(self, self.Consumption2.TextMoney1) },
		{"ObtainMoney2", UIBinderSetText.New(self, self.Consumption2.TextMoney2) },
		{"ObtainMoney1Visiable", UIBinderSetIsVisible.New(self, self.Consumption2.PanelMoney1) },
		{"ObtainMoney2Visiable", UIBinderSetIsVisible.New(self, self.Consumption2.PanelMoney2) },
		{"ObtainLimitVisiable", UIBinderSetIsVisible.New(self, self.Consumption2.TextUpperLimit) },
	}
end

function BagTidyWinView:OnDestroy()

end

function BagTidyWinView:OnShow()
	self.Comm2FrameL_UIBP.FText_Title:SetText(LSTR(990133))
	self.CommBtnM_UIBP:SetButtonText(LSTR(990145))
	self.Consumption1.Text:SetText(LSTR(990122))
	self.Consumption2.Text:SetText(LSTR(990086))
	self.Consumption2.TextUpperLimit:SetText(LSTR(990146))
	self.CommMoneySlot:UpdateView(_G.BagMgr.RecoveryScoreID, false, _G.UIViewID.BagMain, true)
	self.Consumption1.CommInforBtn_UIBP.HelpInfoID = 11204
	self.Consumption2.CommInforBtn_UIBP.HelpInfoID = 11205
    self.IsOnRecycle = false
	UIUtil.SetIsVisible(self.Consumption1.TextUpperLimit, false)
	self:SetConsumIcon()
	self.ViewModel:UpdateVM()
    self:UpdateBtnState()
end

function BagTidyWinView:OnHide()

end

function BagTidyWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtnM_UIBP, self.OnClickTidyBtn)
	UIUtil.AddOnClickedEvent(self, self.Comm2FrameL_UIBP.ButtonClose, self.OnClickCloseBtn)
end

function BagTidyWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.BagTidyWinUpdate, self.OnBagTidyWinUpdate)
end

function BagTidyWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function BagTidyWinView:SetConsumIcon()
    local ScoreID = _G.CompanySealMgr:GetScoreInfo()
    local CompanySealIconId = ItemUtil.GetItemIcon(ScoreID)
    local IconMappings = {
        {
            Control = self.Consumption1.IconMoney1,
            IconId = 26235
        },
        {
            Control = self.Consumption1.IconMoney2,
            IconId = 65002
        },
        {
            Control = self.Consumption2.IconMoney1,
            IconId = 65002
        },
        {
            Control = self.Consumption2.IconMoney2,
            IconId = CompanySealIconId
        }
    }

    for _, Mapping in ipairs(IconMappings) do
        UIUtil.ImageSetBrushFromAssetPath(
            Mapping.Control,
            UIUtil.GetIconPath(Mapping.IconId)
        )
    end
end

function BagTidyWinView:OnClickCloseBtn()
    local function ConfirmClose()
        _G.UIViewMgr:HideView(_G.UIViewID.BagTidyWin)
    end
    if self.IsOnRecycle then
        self.IsOnRecycle = false    -- 暂停回收
        for _, TimerID in ipairs(self.TimerIDs) do
            _G.TimerMgr:PauseTimer(TimerID)
        end
        _G.TimerMgr:PauseTimer(self.Timer1)
        local function ResumeCycle()
            for _, TimerID in ipairs(self.TimerIDs) do
                _G.TimerMgr:ResumeTimer(TimerID)
            end
            _G.TimerMgr:ResumeTimer(self.Timer1)
            _G.UIViewMgr:HideView(_G.UIViewID.CommonMsgBox)
        end
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), LSTR(990147), ConfirmClose, nil, LSTR(10003), LSTR(10002), nil, ResumeCycle)
    else
        ConfirmClose()
    end
end

function BagTidyWinView:OnClickTidyBtn()
    if not self.ViewModel.IsToggleChecked then
        MsgTipsUtil.ShowTips(LSTR(990148))
        return
    elseif not self.ViewModel.IsGoldEnough then
        MsgTipsUtil.ShowTips(LSTR(990149))
        return
    elseif self.ViewModel.IsGoldAtMaxLimit then
        MsgTipsUtil.ShowTips(LSTR(990158))
        return
    elseif self.ViewModel.IsCompanySealAtMaxLimit then
        MsgTipsUtil.ShowTips(LSTR(990157))
        return
    elseif not self.ViewModel.ItemsData[2].IsToggle2Enabled and self.ViewModel.ItemsData[2].Value2 > 0 then
        local Msg = string.format(LSTR(990152), self.ViewModel.ItemsData[2].Value2)
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), Msg, self.ConfirmTidy, nil, LSTR(10003), LSTR(10002))
        return
    elseif self.IsOnRecycle then
        MsgTipsUtil.ShowTips(LSTR(990150))
        return
    end
    self:ConfirmTidy()
end

function BagTidyWinView:ConfirmTidy()
    local function UpdateChoiceState(choiceView, showLoading, showComplete)
        UIUtil.SetIsVisible(choiceView.CommSingleBox, false)
        UIUtil.SetIsVisible(choiceView.ImgLoading, showLoading)
        UIUtil.SetIsVisible(choiceView.IconComplete, showComplete)
    end

    local function ShowState(Index, showLoading, showComplete)
        local ItemView = self.TableViewAdapter:GetChildWidget(Index)

        if not self.ViewModel.ShowRecycleCompanySeal and Index == 4 then
            ItemView = self.TableViewAdapter:GetChildWidget(Index - 1)
        end

        if not ItemView then return end

        local ItemData = self.ViewModel.ItemsData[Index]
        if ItemData.IsToggle1Enabled then
            UpdateChoiceState(ItemView.Choose1, showLoading, showComplete)
        end
        if ItemData.IsToggle2Enabled then
            UpdateChoiceState(ItemView.Choose2, showLoading, showComplete)
        end
    end

	local BagTidyFun = {
        [1] = function()
            _G.EquipmentMgr:ChangeAllProfSchemeForStrongest()
        end,

        [2] = function()
            if self.ViewModel.ConsumMoney2Visiable and self.ViewModel.IsGoldEnough then
                 _G.ShopMgr:SendMsgMallInfoBuy(10050031, self.ViewModel.PurchasePrismNum)
            end
            _G.WardrobeMgr:SetUnlockGidsList(self.ViewModel.UnlockGIDs)
            _G.WardrobeMgr:SendClosetUnLockReq(self.ViewModel.UnlockItems)
        end,

        [3] = function()
            _G.CompanySealMgr:SendMsgExchangeCompanySeal(self.ViewModel.RecordRareItems)
        end,

        [4] = function()
            _G.BagMgr:SendMsgBatchRecoveryReq(self.ViewModel.RecoveryItems)
        end
    }
    local Delay = 1
    self.IsOnRecycle = true
    self.CommBtnM_UIBP:SetIsDisabledState(true, true)
    self:SetRecycleState(true)
    self.TimerIDs = {}
    for Index, ItemData in ipairs(self.ViewModel.ItemsData) do
        if not self.ViewModel.ShowRecycleCompanySeal and Index == 3 then
            goto continue
        end
        if ItemData.IsToggle1Enabled or ItemData.IsToggle2Enabled then
            local func = BagTidyFun[Index]
            if func then
                ShowState(Index, true, false)
                local TimerID = self:RegisterTimer(function()
                    func()
                    ShowState(Index, false, true)
                end, Delay)
                table.insert(self.TimerIDs, TimerID)
                Delay = Delay + 1
            end
        end
        ::continue::
    end
    self.Timer1 = self:RegisterTimer(function()
        self.IsOnRecycle = false
        self:SetRecycleState(false)
        _G.UIViewMgr:HideView(_G.UIViewID.BagTidyWin)

        local EquipCount, TransformCount = 0, 0

        for i = 3, 4 do
            local Item = self.ViewModel.ItemsData[i]
            EquipCount = EquipCount + (Item.IsToggle1Enabled and Item.Value1 or 0)
            EquipCount = EquipCount + (Item.IsToggle2Enabled and Item.Value2 or 0)
        end

        local Item = self.ViewModel.ItemsData[2]
        TransformCount = TransformCount + (Item.IsToggle1Enabled and Item.Value1 or 0)
        TransformCount = TransformCount + (Item.IsToggle2Enabled and Item.Value2 or 0)

        if EquipCount > 0 or TransformCount > 0 then
            MsgTipsUtil.ShowTips(string.format(LSTR(990153), EquipCount, TransformCount))
        end
        if _G.UIViewMgr:IsViewVisible(_G.UIViewID.CommonMsgBox) then
            _G.UIViewMgr:HideView(_G.UIViewID.CommonMsgBox)
        end
        self:ShowAppearanceReward()
    end, Delay)
end


function BagTidyWinView:SetRecycleState(IsOnRecycle)
    local TEXT_COLOR = IsOnRecycle and "696969FF" or "D6D6D6FF"
    local ICON_PATH = IsOnRecycle and
        "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Comm_Img_Goto2_png.UI_Comm_Img_Goto2_png'" or
        "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Comm_Img_Goto_png.UI_Comm_Img_Goto_png'"
    local Views = {
        self.TableViewAdapter:GetChildWidget(2),
        self.TableViewAdapter:GetChildWidget(3)
    }
    for _, View in ipairs(Views) do
        UIUtil.TextBlockSetColorAndOpacityHex(View.TextGoto, TEXT_COLOR)
        UIUtil.ImageSetBrushFromAssetPath(View.IconGoto, ICON_PATH)
        if IsOnRecycle then
            View.BtnGoto:SetIsEnabled(false)
        else
            View.BtnGoto:SetIsEnabled(true)
        end
    end
end

function BagTidyWinView:ShowAppearanceReward()
    local Item = self.ViewModel.ItemsData[2]
    local AppearanceRewards = {}
    if Item.IsToggle1Enabled or Item.IsToggle2Enabled then
        for _, UnlockItem in ipairs(self.ViewModel.UnlockItems) do
            table.insert(AppearanceRewards, {AppearanceID = UnlockItem.ID})
        end
    end
    if next(AppearanceRewards) then
        _G.WardrobeMgr:OpenAppearanceRewardView(AppearanceRewards)
    end
end

function BagTidyWinView:OnBagTidyWinUpdate(Param)
    if self.IsOnRecycle then return end
	self.ViewModel:UpdateItemsData(Param)
	self.ViewModel:UpdateTidyWin(Param)  -- 传递参数以支持增量更新
    self:UpdateBtnState()
end

function BagTidyWinView:UpdateBtnState()
    if not self.ViewModel.IsToggleChecked or not self.ViewModel.IsGoldEnough or self.ViewModel.ObtainLimitVisiable then
        self.CommBtnM_UIBP:SetIsDisabledState(true, true)
    else
        self.CommBtnM_UIBP:SetIsRecommendState(true)
    end
end

function BagTidyWinView:IsAllProfSchemeStrongest()
    local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
    local currentProfID = MajorUtil.GetMajorProfID()
    for _, profData in pairs(RoleDetail.Prof.ProfList) do
        if profData.ProfID ~= currentProfID then
            local Strongest = _G.EquipmentMgr:GetStrongest(profData.ProfID)
            if not Strongest or not next(Strongest) then
                goto continue
            end
            for part = ProtoCommon.equip_part.EQUIP_PART_NONE + 1, ProtoCommon.equip_part.EQUIP_PART_MAX - 1 do
                for _, strongEquip in pairs(Strongest) do
                    if part == strongEquip.Part then
                        local currentEquip = profData.EquipScheme[part]
                        if not currentEquip or currentEquip.GID ~= strongEquip.Strongest.GID then
                            return false
                        end
                        break
                    end
                end
            end
        end
        ::continue::
    end
    return true
end

return BagTidyWinView