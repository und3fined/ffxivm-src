---
--- Author: jususchen
--- DateTime: 2025-07-29 17:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ProtoCS = require("Protocol/ProtoCS")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local ActivityRewardStatus = ProtoCS.Game.Activity.RewardStatus

---@class OpsMoggleCollectTaskList1ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnList1 CommBtnXSView
---@field BtnList2 CommBtnXSView
---@field BtnSlot CommBtnXSView
---@field Icon1 UFImage
---@field Icon2 UFImage
---@field RichTextTask1 URichTextBox
---@field RichTextTask2 URichTextBox
---@field TableViewSlot UTableView
---@field TextQuantity1 UFTextBlock
---@field TextQuantity2 UFTextBlock
---@field TextTag UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTitle2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsMoggleCollectTaskList1ItemView = LuaClass(UIView, true)

function OpsMoggleCollectTaskList1ItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BtnList1 = nil
    --self.BtnList2 = nil
    --self.BtnSlot = nil
    --self.Icon1 = nil
    --self.Icon2 = nil
    --self.RichTextTask1 = nil
    --self.RichTextTask2 = nil
    --self.TableViewSlot = nil
    --self.TextQuantity1 = nil
    --self.TextQuantity2 = nil
    --self.TextTag = nil
    --self.TextTitle = nil
    --self.TextTitle2 = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectTaskList1ItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnList1)
    self:AddSubView(self.BtnList2)
    self:AddSubView(self.BtnSlot)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectTaskList1ItemView:OnPostInit()
    self.Binders1 = {
        { "Title",      UIBinderSetText.New(self, self.TextTitle) },
        { "Content",    UIBinderSetText.New(self, self.RichTextTask1) },
        { "ButtonText", UIBinderSetText.New(self, self.BtnList1.TextContent) },
        { "TargetText", UIBinderSetText.New(self, self.TextQuantity1) },
        { "RewardStatus", UIBinderValueChangedCallback.New(self, nil, function(_, Value)
            local VM = self:GetViewModel()
            if VM then
                _G.OpsMoggleCollectMgr.OnNodeRewardStatusChanged(Value, self.BtnList1, VM.Item1)
            end
        end) },
        { "Icon", UIBinderSetBrushFromAssetPath.New(self, self.Icon1) },
        { "bLock",  UIBinderSetIsVisible.New(self, self.BtnList1,true)},
    }

    self.Binders2 = {
        { "Title",      UIBinderSetText.New(self, self.TextTitle2) },
        { "Content",    UIBinderSetText.New(self, self.RichTextTask2) },
        { "ButtonText", UIBinderSetText.New(self, self.BtnList2.TextContent) },
        { "TargetText", UIBinderSetText.New(self, self.TextQuantity2) },
        { "RewardStatus", UIBinderValueChangedCallback.New(self, nil, function(_, Value)
            local VM = self:GetViewModel()
            if VM then
                _G.OpsMoggleCollectMgr.OnNodeRewardStatusChanged(Value, self.BtnList2, VM.Item2)
            end
        end) },
        { "Icon", UIBinderSetBrushFromAssetPath.New(self, self.Icon2) },
        { "bLock",  UIBinderSetIsVisible.New(self, self.BtnList2,true)},
    }

    self.AdpTableRewards = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
    self.AdpTableRewards:SetOnClickedCallback(self.OnRewardItemClicked)
    self.Binders = {
        { "RewardVMs",  UIBinderUpdateBindableList.New(self, self.AdpTableRewards) },
        { "ButtonText", UIBinderSetText.New(self, self.BtnSlot.TextContent) },
        { "RewardStatus", UIBinderValueChangedCallback.New(self, nil, function(_, Value)
            _G.OpsMoggleCollectMgr.OnNodeRewardStatusChanged(Value, self.BtnSlot, self:GetViewModel())
            UIUtil.SetIsVisible(self.BtnSlot, Value == ActivityRewardStatus.RewardStatusDone or Value == ActivityRewardStatus.RewardStatusWaitGet)
        end) },
        { "bLock",  UIBinderSetIsVisible.New(self, self, true)},
    }
end

function OpsMoggleCollectTaskList1ItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnList1.Button, function()
        local VM = self:GetViewModel()
        if VM then
            _G.OpsMoggleCollectMgr.ClickNodeVM(VM.Item1)
        end
    end)

    UIUtil.AddOnClickedEvent(self, self.BtnList2.Button, function()
        local VM = self:GetViewModel()
        if VM then
            _G.OpsMoggleCollectMgr.ClickNodeVM(VM.Item2)
        end
    end)

    UIUtil.AddOnClickedEvent(self, self.BtnSlot.Button, function()
        _G.OpsMoggleCollectMgr.ClickNodeVM(self:GetViewModel())
    end)
end

function OpsMoggleCollectTaskList1ItemView:OnRegisterBinder()
    local VM = self.Params and self.Params.Data or nil
    self.VM = VM
    if VM then
        if VM.Item1 then
            self:RegisterBinders(VM.Item1, self.Binders1)
        end
        if VM.Item2 then
            self:RegisterBinders(VM.Item2, self.Binders2)
        end

        self:RegisterBinders(VM, self.Binders)
    end
end

function OpsMoggleCollectTaskList1ItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.MoggleUpdateNormal, self.OnRefreshData)
end

function OpsMoggleCollectTaskList1ItemView:OnShow()
	local VM = self:GetViewModel()
	if VM then
		if VM:IsAndNode() then
			self.TextTag:SetText(_G.LSTR(1740002))
		elseif VM:IsOrNode() then
			self.TextTag:SetText(_G.LSTR(1740001))
		end
	end
end

function OpsMoggleCollectTaskList1ItemView:GetViewModel()
    return self.VM
end

function OpsMoggleCollectTaskList1ItemView:OnRewardItemClicked(Index, ItemData, ItemView)
	if ItemView then
        ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView)
    end
end

function OpsMoggleCollectTaskList1ItemView:OnRefreshData(NodeValues)
    if self.VM then
        for _, v in ipairs(NodeValues) do
            if v.NodeID == self.VM.NodeID then
               self.VM:UpdateVM(v) 
               break
            end
        end
    end
end

return OpsMoggleCollectTaskList1ItemView
