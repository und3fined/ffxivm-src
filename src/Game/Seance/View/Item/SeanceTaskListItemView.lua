---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-08-01 11:18
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
local UIViewID = require("Define/UIViewID")
local UIDefine = require("Define/UIDefine")

local RewardStatus = ProtoCS.Game.Activity.RewardStatus
local CommBtnColorType = UIDefine.CommBtnColorType
local LSTR = _G.LSTR

---@class SeanceTaskListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnApply CommBtnSView
---@field ImgBG UFImage
---@field TextProgress UFTextBlock
---@field TextRewardInfo UFTextBlock
---@field TextTaskName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SeanceTaskListItemView = LuaClass(UIView, true)

function SeanceTaskListItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BtnApply = nil
    --self.ImgBG = nil
    --self.TextProgress = nil
    --self.TextRewardInfo = nil
    --self.TextTaskName = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SeanceTaskListItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnApply)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SeanceTaskListItemView:OnInit()
    self.Binders = {
        {"RewardStatus", UIBinderValueChangedCallback.New(self, nil, self.OnRewardStatusChanged)},
        {"RewardCount", UIBinderValueChangedCallback.New(self, nil, self.OnRewardCountChanged)},
        {"TaskName", UIBinderSetText.New(self, self.TextTaskName)}
    }
end

function SeanceTaskListItemView:OnRewardStatusChanged(NewValue, OldValue)
    if (NewValue == RewardStatus.RewardStatusNo) then
        -- 不能领取，那么显示前往按钮
        self.Status = RewardStatus.RewardStatusNo
        self.TextProgress:SetText("0/1")
        local Cfg = self.Params.Data.NodeCfg
        if (Cfg.JumpType and Cfg.JumpParam) then
            -- 可以前往显示前往
            self.BtnApply:SetText(LSTR(1720013))
            self.BtnApply:UpdateImage(CommBtnColorType.Normal)
        else
            -- 不能前往显示进行中
            self.BtnApply:SetText(LSTR(1720016))
            self.BtnApply:UpdateImage(CommBtnColorType.Disable)
        end
    elseif (NewValue == RewardStatus.RewardStatusWaitGet) then
        -- 可以获取的状态
        self.Status = RewardStatus.RewardStatusWaitGet
        self.BtnApply:SetText(LSTR(1720012))
        self.TextProgress:SetText("1/1")
        self.BtnApply:SetIsEnabled(true)
        self.BtnApply:UpdateImage(CommBtnColorType.Recommend)
    elseif (NewValue == RewardStatus.RewardStatusDone) then
        -- 已经领取的状态
        self.Status = RewardStatus.RewardStatusDone
        self.TextProgress:SetText("1/1")
        self.BtnApply:SetText(LSTR(1720011))
        self.BtnApply:SetIsEnabled(false)
        self.BtnApply:UpdateImage(CommBtnColorType.Disable)
    end
end

function SeanceTaskListItemView:OnRewardCountChanged(NewValue, OldValue)
    self.TextRewardInfo:SetText(string.format(LSTR(1720014), NewValue))
end

function SeanceTaskListItemView:OnDestroy()
end

function SeanceTaskListItemView:OnShow()
end

function SeanceTaskListItemView:OnHide()
end

function SeanceTaskListItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnApply, self.OnClickBtnApply)
end

function SeanceTaskListItemView:OnClickBtnApply()
    if (self.Status == RewardStatus.RewardStatusWaitGet) then
        -- 获取奖励
        local Data = self.Params.Data
        if (Data == nil or Data.NodeCfg == nil) then
            _G.FLOG_ERROR("SeanceTaskListItemView:OnClickBtnGet 错误，数据无效，请检查")
            return
        end

        if (Data.RewardStatus ~= RewardStatus.RewardStatusWaitGet) then
            _G.FLOG_ERROR("当前的状态不是可领取的状态，请检查")
            return
        end

        local TargetNodeID = Data.NodeCfg.NodeID
        OpsActivityMgr:SendActivityNodeGetReward(TargetNodeID)
    elseif (self.Status == RewardStatus.RewardStatusNo) then
        -- 前往
        local Cfg = self.Params.Data.NodeCfg
        OpsActivityMgr:Jump(Cfg.JumpType, Cfg.JumpParam)
        _G.UIViewMgr:HideView(UIViewID.OpsSeanceScratchCardTaskView)
    else
        _G.FLOG_ERROR("当前状态不可点击，状态是 : %s", self.Status)
    end
end

function SeanceTaskListItemView:OnRegisterGameEvent()
end

function SeanceTaskListItemView:OnRegisterBinder()
    if (self.Params == nil) then
        return
    end

    local ViewModel = self.Params.Data

    self:RegisterBinders(ViewModel, self.Binders)
end

return SeanceTaskListItemView
