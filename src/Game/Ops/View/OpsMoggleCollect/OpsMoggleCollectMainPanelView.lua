--[[
Author: jususchen jususchen@tencent.com
Date: 2025-07-31 14:38:39
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-07-31 16:33:15
FilePath: \Script\Game\Ops\View\OpsMoggleCollect\OpsMoggleCollectMainPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local OpsMoggleCollectMgr = require("Game/Ops/OpsMoggleCollectMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class OpsMoggleCollectMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnShop UFButton
---@field IconMoney UFImage
---@field OpsActivityTime OpsActivityTimeItemView
---@field Slot1 OpsMoggleCollectSlotItemView
---@field Slot2 OpsMoggleCollectSlotItemView
---@field Slot3 OpsMoggleCollectSlotItemView
---@field Tab1 OpsMoggleCollectTabItemView
---@field Tab2 OpsMoggleCollectTabItemView
---@field Tab3 OpsMoggleCollectTabItemView
---@field TableViewList UFTreeView
---@field TableViewList_1 UTableView
---@field TextHint UFTextBlock
---@field TextMoney UFTextBlock
---@field TextShop UFTextBlock
---@field TextTask UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimToggleBtnChecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsMoggleCollectMainPanelView = LuaClass(UIView, true)

function OpsMoggleCollectMainPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnShop = nil
	--self.IconMoney = nil
	--self.OpsActivityTime = nil
	--self.Slot1 = nil
	--self.Slot2 = nil
	--self.Slot3 = nil
	--self.Tab1 = nil
	--self.Tab2 = nil
	--self.Tab3 = nil
	--self.TableViewList = nil
	--self.TableViewList_1 = nil
	--self.TextHint = nil
	--self.TextMoney = nil
	--self.TextShop = nil
	--self.TextTask = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimToggleBtnChecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectMainPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.OpsActivityTime)
	self:AddSubView(self.Slot1)
	self:AddSubView(self.Slot2)
	self:AddSubView(self.Slot3)
	self:AddSubView(self.Tab1)
	self:AddSubView(self.Tab2)
	self:AddSubView(self.Tab3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectMainPanelView:OnPostInit()
    self.AdpTableViewNormal = UIAdapterTableView.CreateAdapter(self, self.TableViewList_1)
    self.AdpTableViewOR = UIAdapterTreeView.CreateAdapter(self, self.TableViewList)
    -- self.AdpTableViewOR:SetAutoExpandAll(false)
    self.Tabs = { self.Tab1, self.Tab2, self.Tab3 }

    local function UpdateRedDot(Widget, bShow)
		if Widget.ItemVM == nil then
			Widget:InitData()
		end
        Widget:SetRedDotUIIsShow(bShow)
    end

    self.MoggleMainBinders = {
        { "Title",                UIBinderSetText.New(self, self.TextTitle) },
        { "Info",             UIBinderSetText.New(self, self.TextTask) },
        { "ShopItemText",         UIBinderSetText.New(self, self.TextMoney) },
        { "IconShopItem",         UIBinderSetBrushFromAssetPath.New(self, self.IconMoney) },
        { "TabIndex",             UIBinderValueChangedCallback.New(self, nil, self.OnMainTabIndexChanged) },
        { "NormalTaskItemVMList", UIBinderUpdateBindableList.New(self, self.AdpTableViewNormal) },
        { "WrapTaskItemVMList",   UIBinderUpdateBindableList.New(self, self.AdpTableViewOR) },
        { "Page1Name", UIBinderValueChangedCallback.New(self, nil, function(_, V)
            self.Tab1.TextNormal:SetText(V)
            self.Tab1.TextSelect:SetText(V)
        end) },
        { "Page2Name", UIBinderValueChangedCallback.New(self, nil, function(_, V)
            self.Tab2.TextNormal:SetText(V)
            self.Tab2.TextSelect:SetText(V)
        end) },
        { "Page3Name", UIBinderValueChangedCallback.New(self, nil, function(_, V)
            self.Tab3.TextNormal:SetText(V)
            self.Tab3.TextSelect:SetText(V)
        end) },
        { "HelpInfoID", UIBinderValueChangedCallback.New(self, nil, function(_, V)
            self.OpsActivityTime.InforBtn:SetHelpInfoID(V)
        end) },

        -- red RedDots
        { "RedDotTab1", UIBinderValueChangedCallback.New(self, nil, function(_, V)
            UpdateRedDot(self.Tab1.CommonRedDot, V)
        end) },
        { "RedDotTab2", UIBinderValueChangedCallback.New(self, nil, function(_, V)
            UpdateRedDot(self.Tab2.CommonRedDot, V)
        end) },
        { "RedDotTab3", UIBinderValueChangedCallback.New(self, nil, function(_, V)
            UpdateRedDot(self.Tab3.CommonRedDot, V)
        end) },
    }

	self.Tab1.CommonRedDot:SetIsCustomizeRedDot(true)
	self.Tab2.CommonRedDot:SetIsCustomizeRedDot(true)
	self.Tab3.CommonRedDot:SetIsCustomizeRedDot(true)
end

function OpsMoggleCollectMainPanelView:OnShow()
    if not self.Params then
        _G.FLOG_ERROR("OpsMoggleCollectMainPanelView:OnShow Params is nil")
        return
    end

    local VM = OpsMoggleCollectMgr:GetMainVM()
    VM:UpdateByData(self.Params)
    self.TextHint:SetText(VM:GetSubTitle())
    if VM.RewardNodeVM4 then
        self.TextShop:SetText(VM.RewardNodeVM4.Title)
    end
end

function OpsMoggleCollectMainPanelView:PostShowView()
    self.Super.PostShowView(self)

    local VM = OpsMoggleCollectMgr:GetMainVM()
    for i = 1, 3 do
        local Widget = self["Slot" .. i]
        if Widget then
            Widget:UpdateVM(VM["RewardNodeVM" .. i])
        end
    end
end

function OpsMoggleCollectMainPanelView:OnRegisterUIEvent()
    local function OnToggleChanged(Widget, State)
        if not UIUtil.IsToggleButtonChecked(State) then
            return
        end

        local VM = OpsMoggleCollectMgr:GetMainVM()
        for i, v in ipairs(self.Tabs) do
            if Widget ~= v then
                v.ToggleBtn:SetIsChecked(false, true)
            else
                VM:SetTabIndex(i)
            end
        end
    end

    local function AddToggleCheckEvent(Widget)
        UIUtil.AddOnStateChangedEvent(Widget, Widget.ToggleBtn, function(_, __, State)
            OnToggleChanged(Widget, State)
        end)
    end

    AddToggleCheckEvent(self.Tab1)
    AddToggleCheckEvent(self.Tab2)
    AddToggleCheckEvent(self.Tab3)

    UIUtil.AddOnClickedEvent(self, self.BtnShop, self.OnClickShopButton)
end

function OpsMoggleCollectMainPanelView:OnRegisterBinder()
    local VM = OpsMoggleCollectMgr:GetMainVM()
    VM:UpdateByData(self.Params)
    self:RegisterBinders(VM, self.MoggleMainBinders)
end


function OpsMoggleCollectMainPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.UpdateScore, self.UpdateScoreValue)
end

function OpsMoggleCollectMainPanelView:UpdateScoreValue()
    local VM = OpsMoggleCollectMgr:GetMainVM()
    if VM.RewardNodeVM4 then
        local RewardVM = VM.RewardNodeVM4:GetMoggleRewardItem(1)
        if RewardVM then
            VM.ShopItemText = string.sformat("%s: %d", RewardVM.Name, _G.BagMgr:GetItemNum(RewardVM.ItemID))
        end
    end
end

function OpsMoggleCollectMainPanelView:SwitchToTreeTable()
    UIUtil.SetIsVisible(self.TableViewList, true, true)
    UIUtil.SetIsVisible(self.TableViewList_1, false)
end

function OpsMoggleCollectMainPanelView:SwitchToNormalTable()
    UIUtil.SetIsVisible(self.TableViewList, false)
    UIUtil.SetIsVisible(self.TableViewList_1, true, true)
end

function OpsMoggleCollectMainPanelView:OnMainTabIndexChanged(Index)
    if Index == nil then
        return
    end

    local Tab = self.Tabs[Index]
    if Tab == nil then
        _G.FLOG_ERROR("OpsMoggleCollectMainPanelView:OnMainTabIndexChanged invalid index tab %s", Index)
        return
    end

    Tab.ToggleBtn:SetIsChecked(true, true)
    if Index == 1 then
        self:SwitchToNormalTable()
    else
        self:SwitchToTreeTable()
    end
end

function OpsMoggleCollectMainPanelView:OnClickShopButton()
    local VM = OpsMoggleCollectMgr:GetMainVM()
    _G.OpsMoggleCollectMgr.ClickNodeVM(VM.RewardNodeVM4)
end

return OpsMoggleCollectMainPanelView
