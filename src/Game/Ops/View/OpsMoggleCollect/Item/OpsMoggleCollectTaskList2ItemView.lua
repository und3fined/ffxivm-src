--[[
Author: jususchen jususchen@tencent.com
Date: 2025-07-29 17:11:20
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-07-31 16:49:47
FilePath: \Script\Game\Ops\View\OpsMoggleCollect\Item\OpsMoggleCollectTaskList2ItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

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
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local ActivityRewardStatus = ProtoCS.Game.Activity.RewardStatus

---@class OpsMoggleCollectTaskList2ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnList1 CommBtnXSView
---@field Icon1 UFImage
---@field RichTextTask URichTextBox
---@field TableViewSlot UTableView
---@field TextQuantity1 UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsMoggleCollectTaskList2ItemView = LuaClass(UIView, true)

function OpsMoggleCollectTaskList2ItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BtnList1 = nil
    --self.Icon1 = nil
    --self.RichTextTask = nil
    --self.TableViewSlot = nil
    --self.TextQuantity1 = nil
    --self.TextTitle = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectTaskList2ItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnList1)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectTaskList2ItemView:OnPostInit()
    self.AdpTableRewards = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
    self.AdpTableRewards:SetOnClickedCallback(self.OnRewardItemClicked)
    self.Binders = {
        { "RewardVMs",    UIBinderUpdateBindableList.New(self, self.AdpTableRewards) },
        { "Title",        UIBinderSetText.New(self, self.TextTitle) },
        { "Content",      UIBinderSetText.New(self, self.RichTextTask) },
        { "ButtonText",   UIBinderSetText.New(self, self.BtnList1.TextContent) },
        { "TargetText",   UIBinderSetText.New(self, self.TextQuantity1) },
        { "RewardStatus", UIBinderValueChangedCallback.New(self, nil, self.OnRewardStatusChanged) },
        { "Icon",         UIBinderSetBrushFromAssetPath.New(self, self.Icon1) },
        { "bLock",        UIBinderSetIsVisible.New(self, self, true)},
    }
end

function OpsMoggleCollectTaskList2ItemView:OnRegisterBinder()
    local Data = self.Params and self.Params.Data or nil
    if Data then
        self:RegisterBinders(Data, self.Binders)
    end
end

function OpsMoggleCollectTaskList2ItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnList1.Button, self.OnClick)
end

function OpsMoggleCollectTaskList2ItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.MoggleUpdateNormal, self.OnRefreshData)
end

function OpsMoggleCollectTaskList2ItemView:OnRewardStatusChanged(RewardStatus)
    _G.OpsMoggleCollectMgr.OnNodeRewardStatusChanged(RewardStatus, self.BtnList1, self:GetCorespondingVM())
end

function OpsMoggleCollectTaskList2ItemView:OnClick()
    _G.OpsMoggleCollectMgr.ClickNodeVM(self:GetCorespondingVM())
end

function OpsMoggleCollectTaskList2ItemView:GetCorespondingVM()
    if self.Params then
        return self.Params.Data
    end
end

function OpsMoggleCollectTaskList2ItemView:OnRewardItemClicked(Index, ItemData, ItemView)
    if ItemView then
        ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView)
    end
end

function OpsMoggleCollectTaskList2ItemView:OnRefreshData(NodeValues)
    local VM = self:GetCorespondingVM()
    if VM then
        for _, v in ipairs(NodeValues) do
            if v.NodeID == VM.NodeID then
               VM:UpdateVM(v) 
               break
            end
        end
    end
end

return OpsMoggleCollectTaskList2ItemView