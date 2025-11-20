---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-07-07 19:30
--- Description: 刮刮乐
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local ProtoCS = require("Protocol/ProtoCS")

local RewardStatus = ProtoCS.Game.Activity.RewardStatus

local ActivityInfoTable = {} -- 活动数据相关

---@class OpsHalloweenScratchCardPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsHalloweenScratchCardPanelView = LuaClass(UIView, true)

function OpsHalloweenScratchCardPanelView:Ctor()
end

function OpsHalloweenScratchCardPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsHalloweenScratchCardPanelView:OnInit()
    ActivityInfoTable[1] = {} -- 第一周刮刮乐
    ActivityInfoTable[1].ActivityID = 25061103 -- 活动ID
    ActivityInfoTable[1].TaskNodeIDTable = {}
    ActivityInfoTable[1].TaskNodeIDTable[1] = 2506110301 -- 任务1
    ActivityInfoTable[1].TaskNodeIDTable[2] = 2506110302 -- 任务2
    ActivityInfoTable[1].TaskNodeIDTable[3] = 2506110303 -- 任务3
    ActivityInfoTable[1].GetRewardNodeID = 2506110304 -- 获取奖励节点

    ActivityInfoTable[2] = {} -- 第二周刮刮乐
    ActivityInfoTable[2].ActivityID = 25061103 -- 活动ID
    ActivityInfoTable[2].TaskNodeIDTable = {}
    ActivityInfoTable[2].TaskNodeIDTable[1] = 2506110305 -- 任务1
    ActivityInfoTable[2].TaskNodeIDTable[2] = 2506110306 -- 任务2
    ActivityInfoTable[2].TaskNodeIDTable[3] = 2506110307 -- 任务3
    ActivityInfoTable[2].GetRewardNodeID = 2506110308 -- 获取奖励节点

    ActivityInfoTable[3] = {} -- 第三周刮刮乐
    ActivityInfoTable[3].ActivityID = 25061103 -- 活动ID
    ActivityInfoTable[3].TaskNodeIDTable = {}
    ActivityInfoTable[3].TaskNodeIDTable[1] = 2506110309 -- 任务1
    ActivityInfoTable[3].TaskNodeIDTable[2] = 2506110310 -- 任务2
    ActivityInfoTable[3].TaskNodeIDTable[3] = 2506110311 -- 任务3
    ActivityInfoTable[3].GetRewardNodeID = 2506110312 -- 获取奖励节点
end

function OpsHalloweenScratchCardPanelView:OnDestroy()
end

function OpsHalloweenScratchCardPanelView:OnShow()
    
end

function OpsHalloweenScratchCardPanelView:OnHide()
end

function OpsHalloweenScratchCardPanelView:OnRegisterUIEvent()
end

function OpsHalloweenScratchCardPanelView:OnRegisterGameEvent()
end

function OpsHalloweenScratchCardPanelView:OnRegisterBinder()
end

-- 点击了刮刮乐的位置
function OpsHalloweenScratchCardPanelView:OnClickScratchSlot(InViewData)
    local PhaseIndex = InViewData.PhaseIndex -- 第几期
    local InfoTable = ActivityInfoTable[PhaseIndex]
    if (InfoTable == nil) then
        _G.FLOG_ERROR("OpsHalloweenScratchCardPanelView:OnClickScratchSlot 错误，期数无效，数值是：%s", PhaseIndex)
        return
    end

    local ActivityID = InfoTable.ActivityID
    local GetRewardNodeID = InfoTable.GetRewardNodeID

    local SlotIndex = InViewData.SlotIndex -- 刮的位置
    if (SlotIndex == nil or SlotIndex <= 0 or SlotIndex > 9) then
        _G.FLOG_ERROR("OpsHalloweenScratchCardPanelView:OnClickScratchSlot 错误，传入的SlotIndex，无效，数值是:%s", SlotIndex)
        return
    end

    local NodeExtraData = OpsActivityMgr:GetNodeExtraData(ActivityID, GetRewardNodeID)
    if (NodeExtraData == nil or NodeExtraData.Lottery == nil) then
        _G.FLOG_ERROR("错误，无法获得活动节点的抽奖数据,NodeID 是 : %s", GetRewardNodeID)
        return
    end

    local bGetted = false -- 判断一下是否已经获取了
    if (NodeExtraData.LotterySlotRecords ~= nil and #NodeExtraData.LotterySlotRecords > 0) then
        -- 有抽奖数据，那么判断一下，是否已经抽取过了
        for Key, Value in pairs(NodeExtraData.LotterySlotRecords) do
            if (Value.SlotID == SlotIndex) then
                bGetted = true
                break
            end
        end
    end

    if (bGetted) then
        _G.FLOG_WARNING("尝试领取刮刮乐，但是已经获取了，位置是：%s", SlotIndex)
        return
    end

    local Data = {
        NodeID = GetRewardNodeID,
        SlotID = SlotIndex
    }

    OpsActivityMgr:SendActivityNodeOperate(
        GetRewardNodeID,
        ProtoCS.Game.Activity.NodeOpType.NodeOpTypeLotteryDrawNoLayBack,
        {
            LotteryDrawGetReward = Data
        }
    )
end

-- 点击获取每期任务奖励
function OpsHalloweenScratchCardPanelView:OnClickTask(InViewData)
    local PhaseIndex = InViewData.PhaseIndex -- 第几期
    local InfoTable = ActivityInfoTable[PhaseIndex]
    if (InfoTable == nil) then
        _G.FLOG_ERROR("OpsHalloweenScratchCardPanelView:OnClickScratchSlot 错误，期数无效，数值是：%s", PhaseIndex)
        return
    end

    local ActivityID = InfoTable.ActivityID
    if (ActivityID == nil or ActivityID<= 0) then
        _G.FLOG_ERROR("OpsHalloweenScratchCardPanelView:OnClickTask 错误，ActivityID无效，数值是:%s", ActivityID)
        return
    end

    local TaskNodeID = InViewData.TaskNodeID
    if (TaskNodeID == nil or TaskNodeID <= 0) then
        _G.FLOG_ERROR("chCardPanelView:OnClickTask 错误， TaskNodeID 无效，数值:%s", TaskNodeID)
        return
    end

    local NodeStatus = OpsActivityMgr:GetActivityNodeStatus(ActivityID, TaskNodeID)
    local bCanGet = NodeStatus == RewardStatus.RewardStatusWaitGet
    if (not bCanGet) then
        _G.FLOG_WARNING("尝试领取节点 : %s 的奖励，但状态不是可领取状态:%s", TaskNodeID, NodeStatus)
        return
    end

    OpsActivityMgr:SendActivityNodeGetReward(TaskNodeID)
end

return OpsHalloweenScratchCardPanelView
