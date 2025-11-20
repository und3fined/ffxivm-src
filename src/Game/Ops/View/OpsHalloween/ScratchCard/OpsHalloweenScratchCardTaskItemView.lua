---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-07-09 16:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoCS = require("Protocol/ProtoCS")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")

local RewardStatus = ProtoCS.Game.Activity.RewardStatus

---@class OpsHalloweenScratchCardTaskItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGet UButton
---@field BtnGoto UButton
---@field ImgBG UFImage
---@field ImgBG_1 UFImage
---@field ImgBG_Getted UFImage
---@field TextBtnGet UFTextBlock
---@field TextContent2 UFTextBlock
---@field TextProgress UFTextBlock
---@field TextRewardCount UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsHalloweenScratchCardTaskItemView = LuaClass(UIView, true)

function OpsHalloweenScratchCardTaskItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BtnGet = nil
    --self.BtnGoto = nil
    --self.ImgBG = nil
    --self.ImgBG_1 = nil
    --self.ImgBG_Getted = nil
    --self.TextBtnGet = nil
    --self.TextContent2 = nil
    --self.TextProgress = nil
    --self.TextRewardCount = nil
    --self.TextTitle = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsHalloweenScratchCardTaskItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsHalloweenScratchCardTaskItemView:OnInit()
    self.Binders = {
        {"RewardStatus", UIBinderValueChangedCallback.New(self, nil, self.OnRewardStatusChanged)},
        {"RewardCount", UIBinderValueChangedCallback.New(self, nil, self.OnRewardCountChanged)},
        {"TaskName", UIBinderSetText.New(self, self.TextTitle)}
    }
end

function OpsHalloweenScratchCardTaskItemView:OnRewardStatusChanged(NewValue, OldValue)
    if (NewValue == RewardStatus.RewardStatusNo) then
        -- 不能领取，那么显示前往按钮
        UIUtil.SetIsVisible(self.BtnGet, false)
        UIUtil.SetIsVisible(self.BtnGoto, true, true)
        self.TextProgress:SetText("0/1")
    elseif (NewValue == RewardStatus.RewardStatusWaitGet) then
        -- 可以获取的状态
        UIUtil.SetIsVisible(self.BtnGet, true, true)
        UIUtil.SetIsVisible(self.BtnGoto, false)
        self.TextBtnGet:SetText("领 取")
        self.TextProgress:SetText("1/1")
        self.BtnGet:SetIsEnabled(true)
    elseif (NewValue == RewardStatus.RewardStatusDone) then
        -- 已经领取的状态
        UIUtil.SetIsVisible(self.BtnGet, true, true)
        UIUtil.SetIsVisible(self.BtnGoto, false)
        self.TextProgress:SetText("1/1")
        self.TextBtnGet:SetText("已获取")
        self.BtnGet:SetIsEnabled(false)
    end
end

function OpsHalloweenScratchCardTaskItemView:OnRewardCountChanged(NewValue, OldValue)
    self.TextRewardCount:SetText(string.format("抽奖次数+%s", NewValue))
end

function OpsHalloweenScratchCardTaskItemView:OnDestroy()
end

function OpsHalloweenScratchCardTaskItemView:OnShow()
end

function OpsHalloweenScratchCardTaskItemView:OnHide()
end

function OpsHalloweenScratchCardTaskItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnGoto, self.OnClickBtnGoto)
    UIUtil.AddOnClickedEvent(self, self.BtnGet, self.OnClickBtnGet)
end

function OpsHalloweenScratchCardTaskItemView:OnClickBtnGet()
    -- 这里是获取奖励
    local Data = self.Params.Data
    if (Data == nil or Data.NodeCfg == nil) then
        _G.FLOG_ERROR("OpsHalloweenScratchCardTaskItemView:OnClickBtnGet 错误，数据无效，请检查")
        return
    end

    if (Data.RewardStatus ~= RewardStatus.RewardStatusWaitGet) then
        _G.FLOG_ERROR("当前的状态不是可领取的状态，请检查")
        return
    end

    local TargetNodeID = Data.NodeCfg.NodeID
    OpsActivityMgr:SendActivityNodeGetReward(TargetNodeID)
end

function OpsHalloweenScratchCardTaskItemView:OnClickBtnGoto()
    local Cfg = self.Params.Data.NodeCfg
    OpsActivityMgr:Jump(Cfg.JumpType, Cfg.JumpParam)
end

function OpsHalloweenScratchCardTaskItemView:OnRegisterGameEvent()
end

function OpsHalloweenScratchCardTaskItemView:OnRegisterBinder()
    if (self.Params == nil) then
        return
    end

    local ViewModel = self.Params.Data

    self:RegisterBinders(ViewModel, self.Binders)
end

return OpsHalloweenScratchCardTaskItemView
