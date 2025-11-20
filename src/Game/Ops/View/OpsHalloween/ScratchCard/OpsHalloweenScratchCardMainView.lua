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
local UIBindableList = require("UI/UIBindableList")
local ProtoCS = require("Protocol/ProtoCS")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local OpsHalloweenScratchCardTabVM = require("Game/Ops/View/OpsHalloween/ScratchCard/VM/OpsHalloweenScratchCardTabVM")
local OpsHalloweenScratchCardSlotVM = require("Game/Ops/View/OpsHalloween/ScratchCard/VM/OpsHalloweenScratchCardSlotVM")
local OpsHalloweenScratchCardTaskVM = require("Game/Ops/View/OpsHalloween/ScratchCard/VM/OpsHalloweenScratchCardTaskVM")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local CommercializationRandCfg = require("TableCfg/CommercializationRandCfg")
local BagMgr = require("Game/Bag/BagMgr")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemSimpleVM = require("Game/Item/ItemSimpleVM")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local RewardStatus = ProtoCS.Game.Activity.RewardStatus

local ActivityInfoTable = {} -- 活动数据相关

local MaxPhaseCount = 3 -- 活动最大期数
local MaxSlotCount = 9 -- 刮刮卡最大数量

---@class OpsHalloweenScratchCardMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnGet UButton
---@field BtnGetBGMask UFButton
---@field CommonTitle CommonTitleView
---@field ImgBG UFImage
---@field PanelCardGrid UFCanvasPanel
---@field PanelTab UFCanvasPanel
---@field RichTextBox_Info URichTextBox
---@field SlotTableView UTableView
---@field TableViewGet UTableView
---@field TableViewPhaseTab UTableView
---@field TextContent2_1 UFTextBlock
---@field TextRemainTimes UFTextBlock
---@field AnimHideGetPanel UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimShowGetPanel UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsHalloweenScratchCardMainView = LuaClass(UIView, true)

function OpsHalloweenScratchCardMainView:Ctor()
    self.CurPhaseIndex = 1
end

function OpsHalloweenScratchCardMainView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnBack)
    self:AddSubView(self.CommonTitle)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsHalloweenScratchCardMainView:OnInit()
    self.bCanCloseGetPanel = true
    ActivityInfoTable[1] = {} -- 第一周刮刮乐
    ActivityInfoTable[1].ActivityID = 25061105 -- 活动ID
    ActivityInfoTable[1].TaskNodeInfoTable = {}
    ActivityInfoTable[1].TaskNodeInfoTable[1] = {}
    ActivityInfoTable[1].TaskNodeInfoTable[1].ID = 2506110501 -- 任务1
    ActivityInfoTable[1].TaskNodeInfoTable[2] = {}
    ActivityInfoTable[1].TaskNodeInfoTable[2].ID = 2506110502 -- 任务2
    ActivityInfoTable[1].TaskNodeInfoTable[3] = {}
    ActivityInfoTable[1].TaskNodeInfoTable[3].ID = 2506110503 -- 任务3
    ActivityInfoTable[1].GetRewardNodeID = 2506110504 -- 获取奖励节点
    ActivityInfoTable[1].TitleText = "第一期"
    ActivityInfoTable[1].bSelected = true
    ActivityInfoTable[1].Index = 1
    ActivityInfoTable[1].PrizeDrawCostItemID = 0
    ActivityInfoTable[1].GridDataTable = {} -- 格子信息

    ActivityInfoTable[2] = {} -- 第二周刮刮乐
    ActivityInfoTable[2].ActivityID = 25061106 -- 活动ID
    ActivityInfoTable[2].TaskNodeInfoTable = {}
    ActivityInfoTable[2].TaskNodeInfoTable[1] = {}
    ActivityInfoTable[2].TaskNodeInfoTable[1].ID = 2506110505 -- 任务1
    ActivityInfoTable[2].TaskNodeInfoTable[2] = {}
    ActivityInfoTable[2].TaskNodeInfoTable[2].ID = 2506110506 -- 任务2
    ActivityInfoTable[2].TaskNodeInfoTable[3] = {}
    ActivityInfoTable[2].TaskNodeInfoTable[3].ID = 2506110507 -- 任务3
    ActivityInfoTable[2].GetRewardNodeID = 2506110508 -- 获取奖励节点
    ActivityInfoTable[2].TitleText = "第二期"
    ActivityInfoTable[2].bSelected = false
    ActivityInfoTable[2].Index = 2
    ActivityInfoTable[2].PrizeDrawCostItemID = 0
    ActivityInfoTable[2].GridDataTable = {} -- 格子信息

    ActivityInfoTable[3] = {} -- 第三周刮刮乐
    ActivityInfoTable[3].ActivityID = 25061107 -- 活动ID
    ActivityInfoTable[3].TaskNodeInfoTable = {}
    ActivityInfoTable[3].TaskNodeInfoTable[1] = {}
    ActivityInfoTable[3].TaskNodeInfoTable[1].ID = 2506110509 -- 任务1
    ActivityInfoTable[3].TaskNodeInfoTable[2] = {}
    ActivityInfoTable[3].TaskNodeInfoTable[2].ID = 2506110510 -- 任务2
    ActivityInfoTable[3].TaskNodeInfoTable[3] = {}
    ActivityInfoTable[3].TaskNodeInfoTable[3].ID = 2506110511 -- 任务3
    ActivityInfoTable[3].GetRewardNodeID = 2506110512 -- 获取奖励节点
    ActivityInfoTable[3].TitleText = "第三期"
    ActivityInfoTable[3].bSelected = false
    ActivityInfoTable[3].Index = 3
    ActivityInfoTable[3].PrizeDrawCostItemID = 0
    ActivityInfoTable[3].GridDataTable = {} -- 格子信息

    for PhaseIndex = 1, MaxPhaseCount do
        local TargetTable = ActivityInfoTable[PhaseIndex].GridDataTable
        for Index = 1, MaxSlotCount do
            TargetTable[Index] = {}
            TargetTable[Index].bGetted = false
            TargetTable[Index].SlotIndex = Index
            TargetTable[Index].PhaseIndex = PhaseIndex
        end
    end

    for Key, Value in pairs(ActivityInfoTable) do
        local TargetCfg = ActivityNodeCfg:FindCfgByKey(Value.GetRewardNodeID)
        local PrizePoolID = TargetCfg.Params[1]
        Value.ActivityCfg = TargetCfg
        for _, TaskNodeData in pairs(Value.TaskNodeInfoTable) do
            local NodeCfg = ActivityNodeCfg:FindCfgByKey(TaskNodeData.ID)
            TaskNodeData.RewardCount = NodeCfg.Rewards[1].Num
            TaskNodeData.TaskName = NodeCfg.NodeTitle
            TaskNodeData.NodeCfg = NodeCfg
        end
        Value.PrizeDrawCostItemID = OpsActivityMgr:GetPrizeDrawCostItemID(PrizePoolID)
        local PrizeDataList = CommercializationRandCfg:FindAllCfg("PrizePoolID = " .. PrizePoolID)
        local BigPrizeCfg = nil

        for _, TableCfg in pairs(PrizeDataList) do
            if (TableCfg.GetSendAllReward == 1) then
                BigPrizeCfg = TableCfg
                break
            end
            if (BigPrizeCfg == nil or TableCfg.DropWeight < BigPrizeCfg.DropWeight) then
                BigPrizeCfg = TableCfg
            end
        end

        Value.BigPrizeItemID = BigPrizeCfg.DropID
    end

    self.TabVMList = UIBindableList.New(OpsHalloweenScratchCardTabVM)
    self.SlotVMList = UIBindableList.New(OpsHalloweenScratchCardSlotVM)
    self.TaskVMList = UIBindableList.New(OpsHalloweenScratchCardTaskVM)

    self.AdapterTableViewTab = UIAdapterTableView.CreateAdapter(self, self.TableViewPhaseTab, self.OnTabSelected, false)
    self.AdapterTableViewSlot = UIAdapterTableView.CreateAdapter(self, self.SlotTableView, nil, false)
    self.AdapterTableViewGetTask = UIAdapterTableView.CreateAdapter(self, self.TableViewGet, nil, false)
    self.AdapterTableViewSlot:SetOnClickedCallback(self.OnSlotClicked)

    self.BtnBack:AddBackClick(self, self.OnClickedBtnBack)
end

function OpsHalloweenScratchCardMainView:OnTabSelected(InIndex, InItemData, InItemView, InbByClick)
    self.CurPhaseIndex = InIndex

    for Key, Value in pairs(self.TabVMList.Items) do
        Value.bSelected = Value.Index == self.CurPhaseIndex
    end

    -- 更新一下右边的刮刮乐格子
    self:InternalUpdateScratchCard()

    -- 更新抽奖道具次数
    self:InternalRefreshDrawItemCount()
end

function OpsHalloweenScratchCardMainView:InternalRefreshDrawItemCount()
    local DrawItemCount = BagMgr:GetItemNum(ActivityInfoTable[self.CurPhaseIndex].PrizeDrawCostItemID)
    self.TextRemainTimes:SetText(string.format("刮刮乐剩余次数：%s", DrawItemCount))
end

function OpsHalloweenScratchCardMainView:OnSlotClicked(InIndex, InItemData, InItemView, InbByClick)
    if (InItemData.bGetted) then
        -- 这里显示一下
        ItemTipsUtil.ShowTipsByResID(InItemData.ItemID, InItemView)
        return
    end
    self:OnClickScratchSlot(InItemData)
end

function OpsHalloweenScratchCardMainView:OnClickedBtnBack()
    self:Hide()
end

function OpsHalloweenScratchCardMainView:OnDestroy()
end

function OpsHalloweenScratchCardMainView:OnShow()
    for Key, Value in pairs(ActivityInfoTable) do
        if (OpsActivityMgr:IsActivityOpen(Value.ActivityID)) then
            Value.bActivityOpen = true
            OpsActivityMgr:SendQueryActivity(Value.ActivityID)
        else
            Value.bActivityOpen = false
        end
    end

    self.CommonTitle:SetTextTitleName("降神刮刮乐")
    self.CommonTitle:SetTextSubtitle("2026.02.09 - 2026.03.01")
    self.bCanCloseGetPanel = true

    -- 更新左侧
    self:InternalUpadteTab(self.CurPhaseIndex)
end

function OpsHalloweenScratchCardMainView:OnHide()
end

function OpsHalloweenScratchCardMainView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnGet, self.OnClickBtnGet)
    UIUtil.AddOnClickedEvent(self, self.BtnGetBGMask, self.OnClickCloseGetPanelMask)
end

function OpsHalloweenScratchCardMainView:OnClickBtnGet()
    self:PlayAnimation(self.AnimShowGetPanel)
    self.bCanCloseGetPanel = false
    self:RegisterTimer(
        function()
            self.bCanCloseGetPanel = true
        end,
        0.5
    )

    -- 这里刷新一下任务
    self:InternalUpdateTask()
end

function OpsHalloweenScratchCardMainView:OnClickCloseGetPanelMask()
    if (self.bCanCloseGetPanel) then
        self.bCanCloseGetPanel = false
        self:PlayAnimation(self.AnimHideGetPanel)
        self:RegisterTimer(
            function()
                self.bCanCloseGetPanel = true
            end,
            0.5
        )
    end
end

function OpsHalloweenScratchCardMainView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.OpsActivityUpdate, self.OnOpsActivityUpdate)
    self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.OnOpsActivityNodeGetReward)
    self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.OnOpsActivityUpdateInfo)
    self:RegisterGameEvent(EventID.BagUpdate, self.OnBagUpdate)
end

function OpsHalloweenScratchCardMainView:OnBagUpdate(Params)
    self:InternalRefreshDrawItemCount()
end

function OpsHalloweenScratchCardMainView:OnOpsActivityUpdateInfo(Params)
    if (Params == nil) then
        return
    end

    local NodeOperate = Params.NodeOperate
    if (NodeOperate == nil) then
        return
    end

    if (NodeOperate.Result ~= nil) then
        -- 这里是刮刮乐抽奖的结果，弹窗口显示一下
        local RewardData = NodeOperate.Result.LotteryDrawGetReward
        if (RewardData and RewardData.LotteryDrawReward) then
            local InDataVMList = UIBindableList.New(ItemSimpleVM)
            InDataVMList:UpdateByValues(RewardData.LotteryDrawReward)
            UIViewMgr:ShowView(
                UIViewID.CommonRewardPanel,
                {
                    ItemVMList = InDataVMList
                }
            )
        end
    end

    self:OnOpsActivityUpdate(NodeOperate.ActivityDetail)
end

function OpsHalloweenScratchCardMainView:OnOpsActivityNodeGetReward(Params)
    if (Params == nil) then
        _G.FLOG_ERROR("OpsHalloweenScratchCardMainView:OnOpsActivityNodeGetReward 错误，Params为空")
        return
    end

    local Reward = Params.Reward
    -- 这里去更新一下任务的信息
    self:OnOpsActivityUpdate(Reward.Detail)
end

function OpsHalloweenScratchCardMainView:OnOpsActivityUpdate(Params)
    if (Params == nil) then
        return
    end

    local ActivityHead = Params.Head
    local ActivityID = ActivityHead.ActivityID
    local ActivityData = OpsActivityMgr:GetActivtyNodeInfo(ActivityID)
    if (ActivityData == nil) then
        -- 没有数据就不刷新了
        return
    end

    for _, NodeInfo in pairs(ActivityData.NodeList) do
        -- body
        for _, Value in pairs(ActivityInfoTable) do
            -- 这里更新一下任务情况
            for _, TaskNode in pairs(Value.TaskNodeInfoTable) do
                if (TaskNode.ID == NodeInfo.Head.NodeID) then
                    TaskNode.Status = NodeInfo.Head.RewardStatus
                end
            end

            -- 这里更新一下抽奖刮刮卡的情况
            if (NodeInfo.Head.NodeID == Value.GetRewardNodeID) then
                local b = 0
                for _, SlotInfo in pairs(NodeInfo.Extra.Lottery.LotterySlotRecords) do
                    -- body
                    local LocalSlotData = Value.GridDataTable[SlotInfo.SlotID]
                    local TargetReward = SlotInfo.LotteryDrawRewards[1]
                    LocalSlotData.bGetted = true
                    LocalSlotData.ItemID = TargetReward.ItemID
                    LocalSlotData.Num = TargetReward.ItemNum
                    if (LocalSlotData.ItemID == Value.BigPrizeItemID) then
                        Value.bGetBigPrize = true
                    end
                end
            end
        end
    end

    -- 更新任务
    self:InternalUpdateTask()

    -- 更新一下右边的刮刮乐格子
    self:InternalUpdateScratchCard()

    -- 更新左侧
    self:InternalUpadteTab(self.CurPhaseIndex)
end

-- 更新抽奖卡数据
function OpsHalloweenScratchCardMainView:InternalUpdateScratchCard()
    local DataList = ActivityInfoTable[self.CurPhaseIndex].GridDataTable
    self.SlotVMList:UpdateByValues(DataList)
    self.AdapterTableViewSlot:UpdateAll(self.SlotVMList)
end

-- 更新任务数据
function OpsHalloweenScratchCardMainView:InternalUpdateTask()
    -- 这里刷新一下任务
    local DataList = ActivityInfoTable[self.CurPhaseIndex].TaskNodeInfoTable
    self.TaskVMList:UpdateByValues(DataList)
    self.AdapterTableViewGetTask:UpdateAll(self.TaskVMList)
end

-- 更新左边的TAB
function OpsHalloweenScratchCardMainView:InternalUpadteTab(InTargetIndex)
    self.TabVMList:UpdateByValues(ActivityInfoTable)
    self.AdapterTableViewTab:UpdateAll(self.TabVMList)
    self.AdapterTableViewTab:SetSelectedIndex(InTargetIndex)
end

function OpsHalloweenScratchCardMainView:OnRegisterBinder()
end

-- 点击了刮刮乐的位置
function OpsHalloweenScratchCardMainView:OnClickScratchSlot(InViewData)
    local PhaseIndex = InViewData.PhaseIndex -- 第几期
    local InfoTable = ActivityInfoTable[PhaseIndex]
    if (InfoTable == nil) then
        _G.FLOG_ERROR("OpsHalloweenScratchCardMainView:OnClickScratchSlot 错误，期数无效，数值是：%s", PhaseIndex)
        return
    end

    local ActivityID = InfoTable.ActivityID
    if (not OpsActivityMgr:IsActivityOpen(ActivityID)) then
        _G.FLOG_WARNING("当前活动没有开启，活动ID:%s", ActivityID)
        MsgTipsUtil.ShowTips("当前活动没有开启，无法进行抽奖")
        return
    end

    local DrawItemCount = BagMgr:GetItemNum(ActivityInfoTable[self.CurPhaseIndex].PrizeDrawCostItemID)
    if (DrawItemCount < 1) then
        _G.FLOG_INFO("抽奖消耗品数量不足，无法抽奖")
        MsgTipsUtil.ShowTips("抽奖消耗品数量不足，无法抽奖")
        return
    end

    local GetRewardNodeID = InfoTable.GetRewardNodeID
    local SlotIndex = InViewData.SlotIndex -- 刮的位置
    if (SlotIndex == nil or SlotIndex <= 0 or SlotIndex > 9) then
        _G.FLOG_ERROR("OpsHalloweenScratchCardMainView:OnClickScratchSlot 错误，传入的SlotIndex，无效，数值是:%s", SlotIndex)
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
function OpsHalloweenScratchCardMainView:OnClickTask(InViewData)
    local PhaseIndex = InViewData.PhaseIndex -- 第几期
    local InfoTable = ActivityInfoTable[PhaseIndex]
    if (InfoTable == nil) then
        _G.FLOG_ERROR("OpsHalloweenScratchCardMainView:OnClickTask 错误，期数无效，数值是：%s", PhaseIndex)
        return
    end

    local ActivityID = InfoTable.ActivityID
    if (ActivityID == nil or ActivityID <= 0) then
        _G.FLOG_ERROR("OpsHalloweenScratchCardMainView:OnClickTask 错误，ActivityID无效，数值是:%s", ActivityID)
        return
    end

    local TaskNodeID = InViewData.TaskNodeID
    if (TaskNodeID == nil or TaskNodeID <= 0) then
        _G.FLOG_ERROR("chCardPanelView:OnClickTask 错误， TaskNodeID 无效，数值:%s", TaskNodeID)
        return
    end

    local NodeStatus = OpsActivityMgr:GetNodeExtraData(ActivityID, TaskNodeID)
    local bCanGet = NodeStatus == RewardStatus.RewardStatusWaitGet
    if (not bCanGet) then
        _G.FLOG_WARNING("尝试领取节点 : %s 的奖励，但状态不是可领取状态:%s", TaskNodeID, NodeStatus)
        return
    end

    OpsActivityMgr:SendActivityNodeGetReward(TaskNodeID)
end

return OpsHalloweenScratchCardMainView
