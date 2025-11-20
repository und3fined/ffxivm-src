---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-08-01 10:36
--- Description:
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
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local CommercializationRandCfg = require("TableCfg/CommercializationRandCfg")
local BagMgr = require("Game/Bag/BagMgr")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local SeanceScratchLotteryItemVM = require("Game/Seance/View/VM/SeanceScratchLotteryItemVM")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemSimpleVM = require("Game/Item/ItemSimpleVM")
local MajorUtil = require("Utils/MajorUtil")
local PathMgr = require("Path/PathMgr")
local CommonUtil = require("Utils/CommonUtil")
local SidePopUpDefine = require("Game/SidePopUp/SidePopUpDefine")
local UUIUtil = nil
local TimeUtil = require("Utils/TimeUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")

local LSTR = _G.LSTR
local RewardStatus = ProtoCS.Game.Activity.RewardStatus

local ActivityInfoTable = {} -- 活动数据相关
local ShowRewardCommonPanelTimeDelay = 0.6
local BigPrizeTimeDelay = 1
local MaxPhaseCount = 3 -- 活动最大期数
local MaxSlotCount = 9 -- 刮刮卡最大数量
local HelpID = 18300 -- 帮助按钮的ID

---@class SeanceMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMask UFButton
---@field BtnShowTask UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonRedDot CommonRedDotView
---@field CommonTitle CommonTitleView
---@field EFFBigPrize UFCanvasPanel
---@field GrandPrize1 SeanceGrandPrizeItemView
---@field GrandPrize2 SeanceGrandPrizeItemView
---@field GrandPrize3 SeanceGrandPrizeItemView
---@field HorizontalBoxTime UFHorizontalBox
---@field RichTextHint URichTextBox
---@field TableViewScratchLottery UTableView
---@field TextBtn UFTextBlock
---@field TextLottery UFTextBlock
---@field TextPrizeTitle UFTextBlock
---@field TextSubTitle URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOpenBigPrize UWidgetAnimation
---@field AnimRedDotLoop UWidgetAnimation
---@field ValueAllOpenDelayInterval float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SeanceMainPanelView = LuaClass(UIView, true)

function SeanceMainPanelView:Ctor()
    self.CurPhaseIndex = 1
end

function SeanceMainPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.CommonRedDot)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.GrandPrize1)
	self:AddSubView(self.GrandPrize2)
	self:AddSubView(self.GrandPrize3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SeanceMainPanelView:OnInit()
    UUIUtil = _G.UE.UUIUtil
    self.PhaseRedDotStatusTable = {}
    self.CommonRedDot:SetIsCustomizeRedDot(true)
    self.TabViewList = {}
    self.TabViewList[1] = self.GrandPrize1
    self.TabViewList[2] = self.GrandPrize2
    self.TabViewList[3] = self.GrandPrize3

    self.bCanCloseGetPanel = true
    ActivityInfoTable[1] = {} -- 第一周刮刮乐
    ActivityInfoTable[1].ActivityID = 25061105 -- 活动ID
    ActivityInfoTable[1].TaskNodeInfoTable = {}
    ActivityInfoTable[1].TaskNodeInfoTable[1] = {}
    ActivityInfoTable[1].TaskNodeInfoTable[1].ID = 2506110501 -- 任务1
    ActivityInfoTable[1].TaskNodeInfoTable[1].Status = RewardStatus.RewardStatusNo
    ActivityInfoTable[1].TaskNodeInfoTable[2] = {}
    ActivityInfoTable[1].TaskNodeInfoTable[2].ID = 2506110502 -- 任务2
    ActivityInfoTable[1].TaskNodeInfoTable[2].Status = RewardStatus.RewardStatusNo
    ActivityInfoTable[1].TaskNodeInfoTable[3] = {}
    ActivityInfoTable[1].TaskNodeInfoTable[3].ID = 2506110503 -- 任务3
    ActivityInfoTable[1].TaskNodeInfoTable[3].Status = RewardStatus.RewardStatusNo
    ActivityInfoTable[1].GetRewardNodeID = 2506110504 -- 抽奖节点
    ActivityInfoTable[1].TitleText = LSTR(1720006)
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
    ActivityInfoTable[2].GetRewardNodeID = 2506110508 -- 抽奖节点
    ActivityInfoTable[2].TitleText = LSTR(1720007)
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
    ActivityInfoTable[3].GetRewardNodeID = 2506110512 -- 抽奖节点
    ActivityInfoTable[3].TitleText = LSTR(1720008)
    ActivityInfoTable[3].bSelected = false
    ActivityInfoTable[3].Index = 3
    ActivityInfoTable[3].PrizeDrawCostItemID = 0
    ActivityInfoTable[3].GridDataTable = {} -- 格子信息

    for PhaseIndex = 1, MaxPhaseCount do
        local TargetTable = ActivityInfoTable[PhaseIndex].GridDataTable
        for Index = 1, MaxSlotCount do
            TargetTable[Index] = {}
            TargetTable[Index].SlotIndex = Index
            TargetTable[Index].PhaseIndex = PhaseIndex
            TargetTable[Index].bGetted = false
        end
    end

    for _, Value in pairs(ActivityInfoTable) do
        local TargetCfg = ActivityNodeCfg:FindCfgByKey(Value.GetRewardNodeID)
        local PrizePoolID = TargetCfg.Params[1]
        Value.ActivityCfg = TargetCfg
        Value.StartTimeStamp = TimeUtil.GetTimeFromString(TargetCfg.StartTime)
        Value.EndTimeStamp = TimeUtil.GetTimeFromString(TargetCfg.EndTime)
        Value.StartTimeStampMS = Value.StartTimeStamp * 1000
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
        Value.BigPrizeItemNum = BigPrizeCfg.DropNum
    end

    self.SlotVMList = {}
    for TempIndex = 1, 9 do
        self.SlotVMList[TempIndex] = SeanceScratchLotteryItemVM.New()
    end

    self.AdapterSlotTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewScratchLottery, nil, false)
    self.AdapterTableViewGetTask = UIAdapterTableView.CreateAdapter(self, self.TableViewGet, nil, false)
    self.AdapterSlotTableView:SetOnClickedCallback(self.OnSlotClicked)
end

function SeanceMainPanelView:OnTabSelected(InIndex)
    self.CurPhaseIndex = InIndex

    for Index = 1, 3 do
        self.TabViewList[Index]:SetIsSelected(Index == self.CurPhaseIndex)
    end

    -- 更新抽奖道具次数
    self:InternalRefreshDrawItemCount(false)

    -- 更新一下右边的刮刮乐格子
    self:InternalUpdateScratchCard()

    self:InternalUpdateTaskRedDot()
end

function SeanceMainPanelView:InternalRefreshDrawItemCount(InbRefreshLotterySlot)
    local DrawItemCount = BagMgr:GetItemNum(ActivityInfoTable[self.CurPhaseIndex].PrizeDrawCostItemID)
    self.TextLottery:SetText(string.format(LSTR(1720005), DrawItemCount))

    local DataList = ActivityInfoTable[self.CurPhaseIndex].GridDataTable
    local bCanGet = DrawItemCount > 0
    for Key, Value in pairs(DataList) do
        -- body
        Value.bCanGet = bCanGet
    end

    if (InbRefreshLotterySlot) then
        -- 更新一下右边的刮刮乐格子
        self:InternalUpdateScratchCard()
    end
end

function SeanceMainPanelView:OnSlotClicked(InIndex, InItemData, InItemView, InbByClick)
    if (InItemData.bGetted) then
        -- 这里显示一下
        ItemTipsUtil.ShowTipsByResID(InItemData.ItemID, InItemView)
        return
    end
    self:OnClickScratchSlot(InItemData)
end

function SeanceMainPanelView:OnDestroy()
end

function SeanceMainPanelView:OnShow()
    self:InternalSetCanOperate(true)
    self:LoadPhaseRedPointStatus()
    self.CommonTitle.CommInforBtn:SetHelpInfoID(HelpID)
    for Index = 1, 3 do
        self.TabViewList[Index]:SetClickCallback(self, self.OnTabSelected)
    end
    self.TextPrizeTitle:SetText(LSTR(1720002))
    self.TextBtn:SetText(LSTR(1720009))
    for Key, Value in pairs(ActivityInfoTable) do
        if (OpsActivityMgr:IsActivityOpen(Value.ActivityID)) then
            Value.bActivityOpen = true
            OpsActivityMgr:SendQueryActivity(Value.ActivityID)
        else
            Value.bActivityOpen = false
        end
    end

    self.RichTextHint:SetText(LSTR(1720015))

    self.CommonTitle:SetTextTitleName(LSTR(1720001))
    self.TextSubTitle:SetText("2026/02/09 - 2026/03/01")
    self.bCanCloseGetPanel = true

    -- 更新左侧
    self:InternalUpadteTab(self.CurPhaseIndex)
end

function SeanceMainPanelView:OnHide()
    _G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.LotteryDraw, false)
end

function SeanceMainPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnShowTask, self.OnClickBtnGet)
end

function SeanceMainPanelView:OnClickBtnGet()
    -- 打开任务界面
    local DataList = ActivityInfoTable[self.CurPhaseIndex].TaskNodeInfoTable
    local Params = {}
    Params.DataList = DataList
    Params.ActivityCfg = ActivityInfoTable[self.CurPhaseIndex].ActivityCfg
    Params.StartTimeStamp = ActivityInfoTable[self.CurPhaseIndex].StartTimeStamp
    Params.EndTimeStamp = ActivityInfoTable[self.CurPhaseIndex].EndTimeStamp
    _G.UIViewMgr:ShowView(UIViewID.OpsSeanceScratchCardTaskView, Params)
end

function SeanceMainPanelView:OnClickCloseGetPanelMask()
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

function SeanceMainPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.OpsActivityUpdate, self.OnOpsActivityUpdate)
    self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.OnOpsActivityNodeGetReward)
    self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.OnOpsActivityUpdateInfo)
    self:RegisterGameEvent(EventID.BagUpdate, self.OnBagUpdate)
end

function SeanceMainPanelView:OnBagUpdate(Params)
    self:InternalRefreshDrawItemCount(true)
end

function SeanceMainPanelView:InternalSetBigPrizeEffectPos(InTargetWidget)
    if nil == InTargetWidget then
        return
    end

    local ScreenSize = UIUtil.GetScreenSize()
    local ViewportSize = UIUtil.GetViewportSize()
	local TipsWidgetSize = UIUtil.CanvasSlotGetSize(self.EFFBigPrize)
    local TargetWidgetSize = UUIUtil.GetLocalSize(InTargetWidget)
    local Scale = InTargetWidget.RenderTransform and InTargetWidget.RenderTransform.Scale or 1
    TargetWidgetSize = TargetWidgetSize * Scale
    local TargetAbsolutePos = UIUtil.GetWidgetAbsolutePosition(InTargetWidget)
    local WidgetPixelPosition = UIUtil.AbsoluteToViewport(TargetAbsolutePos)
    WidgetPixelPosition.X = WidgetPixelPosition.X * ScreenSize.X / ViewportSize.X
    WidgetPixelPosition.Y = WidgetPixelPosition.Y * ScreenSize.Y / ViewportSize.Y

    local Position = _G.UE.FVector2D(0, 0)
    local Alignment = _G.UE.FVector2D(0, 0)

    Position.X = WidgetPixelPosition.X - TargetWidgetSize.X * 0.65
    Position.Y = WidgetPixelPosition.Y + TargetWidgetSize.Y * 0.65
    local Slot = UIUtil.SlotAsCanvasSlot(self.EFFBigPrize)
    if nil == Slot then
        return
    end

    Slot:SetAlignment(Alignment)
    Slot:SetPosition(Position)
end

function SeanceMainPanelView:InternalGetSlotViewBySlotID(InSlotID)
    for _, Value in pairs(self.AdapterSlotTableView.ItemViewList) do
        if (Value:GetSlotID() == InSlotID) then
            return Value
        end
    end
    _G.FLOG_ERROR("无法获取 SlotView, ID 是 : %s", InSlotID)
    return nil
end

function SeanceMainPanelView:OnOpsActivityUpdateInfo(Params)
    if (Params == nil) then
        return
    end

    local NodeOperate = Params.NodeOperate
    if (NodeOperate == nil) then
        return
    end

    if (NodeOperate.Result ~= nil) then
        -- 表现抽奖的时候，不让操作，弹出禁止操作的MASK
        self:InternalSetCanOperate(false)

        -- 这里做一个保底，避免中途出错导致无法点击
        self:RegisterTimer(
            function()
                self:InternalSetCanOperate(true)
            end,
            10,
            1
        )

        -- 这里是刮刮乐抽奖的结果，弹窗口显示一下
        local RewardData = NodeOperate.Result.LotteryDrawGetReward
        if (RewardData and RewardData.LotteryDrawReward) then
            local BigPrizeIndex = -1

            local ActivityData = ActivityInfoTable[self.CurPhaseIndex]

            for Key, Value in pairs(RewardData.LotteryDrawReward) do
                if (Value.ItemID == ActivityData.BigPrizeItemID) then
                    BigPrizeIndex = Key
                    break
                end
            end

            if (BigPrizeIndex > 0) then
                local ShowDrawRewardDataList = {}
                local TempBigPrizeDrawData = {}
                TempBigPrizeDrawData.ItemID = RewardData.LotteryDrawReward[1].ItemID
                TempBigPrizeDrawData.ItemNum = RewardData.LotteryDrawReward[1].ItemNum
                table.insert(ShowDrawRewardDataList, TempBigPrizeDrawData)
                -- 如果是大奖，需要做表现
                local TotalShowRewardPanelDelay = BigPrizeTimeDelay
                local DataList = ActivityData.GridDataTable
                ActivityData.bGetBigPrize = true
                local bFirstNormal = true
                local NormalTimeDelay = 0
                for Key, Value in pairs(RewardData.LotterySlotRecords) do
                    local SlotID = Value.SlotID
                    local SlotVMData = self.SlotVMList[SlotID]
                    if (not SlotVMData.bGetted) then
                        -- 更新单个数据
                        local SlotLogicData = DataList[SlotID]
                        SlotLogicData.bGetted = true
                        SlotLogicData.bCanGet = false
                        SlotLogicData.ItemID = Value.LotteryDrawRewards[1].ItemID
                        SlotLogicData.Num = Value.LotteryDrawRewards[1].ItemNum

                        if (SlotLogicData.ItemID ~= ActivityData.BigPrizeItemID) then
                            local NewDrawRewardData = {}
                            NewDrawRewardData.ItemID = SlotLogicData.ItemID
                            NewDrawRewardData.ItemNum = SlotLogicData.Num
                            table.insert(ShowDrawRewardDataList, NewDrawRewardData)
                            -- 普通奖励槽位
                            SlotLogicData.bGetBigPrize = false
                            if (bFirstNormal) then
                                bFirstNormal = false
                                NormalTimeDelay = NormalTimeDelay + BigPrizeTimeDelay
                            else
                                NormalTimeDelay = NormalTimeDelay + ShowRewardCommonPanelTimeDelay
                            end
                            TotalShowRewardPanelDelay = TotalShowRewardPanelDelay + ShowRewardCommonPanelTimeDelay
                            self:RegisterTimer(
                                function()
                                    SlotVMData:SetItemData(SlotLogicData.ItemID, SlotLogicData.Num)
                                    local TargetView = self:InternalGetSlotViewBySlotID(SlotID)
                                    if (TargetView) then
                                        TargetView:PlayNormalOpenAnim()
                                    end
                                end,
                                NormalTimeDelay,
                                1
                            )
                        else
                            SlotVMData:SetItemData(SlotLogicData.ItemID, SlotLogicData.Num)
                            SlotLogicData.bGetBigPrize = true

                            -- 大奖
                            local TargetView = self:InternalGetSlotViewBySlotID(SlotID)
                            if (TargetView) then
                                TargetView:PlayBigPrizeOpenAnim()
                            end
                            self:InternalSetBigPrizeEffectPos(TargetView)
                            self:PlayAnimation(self.AnimOpenBigPrize)
                        end
                    end
                end

                -- 弹出通用获得弹窗
                self:RegisterTimer(
                    function()
                        local InDataVMList = UIBindableList.New(ItemSimpleVM)
                        InDataVMList:UpdateByValues(ShowDrawRewardDataList)
                        UIViewMgr:ShowView(
                            UIViewID.CommonRewardPanel,
                            {
                                ItemVMList = InDataVMList,
                                CloseCallback = function()
                                    _G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.LotteryDraw, false)
                                end
                            }
                        )

                        -- 更新左侧
                        self:InternalUpadteTab(self.CurPhaseIndex)

                        self:OnOpsActivityUpdate(NodeOperate.ActivityDetail)

                        self:InternalSetCanOperate(true)
                    end,
                    TotalShowRewardPanelDelay,
                    1
                )
            else
                local TargetIndex = 0
                if (#RewardData.LotterySlotRecords < 1) then
                    _G.FLOG_ERROR("抽奖数据记录为空，请检查!")
                    self:InternalSetCanOperate(true)
                    return
                end

                for Key, Value in pairs(RewardData.LotterySlotRecords) do
                    if (not self.SlotVMList[Value.SlotID].bGetted) then
                        TargetIndex = Value.SlotID
                        break
                    end
                end

                if (TargetIndex <= 0) then
                    _G.FLOG_ERROR("错误，无法获取 TargetIndex，请检查")
                    self:InternalSetCanOperate(true)
                    return
                end

                -- 更新单个数据
                local DataList = ActivityData.GridDataTable
                local LocalSlotData = DataList[TargetIndex]
                LocalSlotData.bGetted = true
                LocalSlotData.bCanGet = false
                LocalSlotData.ItemID = RewardData.LotteryDrawReward[1].ItemID
                LocalSlotData.Num = RewardData.LotteryDrawReward[1].ItemNum
                ActivityData.bGetBigPrize = false
                LocalSlotData.bGetBigPrize = false

                -- 这里只要单独刷新一下物品ICON，避免动画被中断
                self.SlotVMList[TargetIndex]:SetItemData(LocalSlotData.ItemID, LocalSlotData.Num)

                local TargetView = self:InternalGetSlotViewBySlotID(TargetIndex)
                if (TargetView) then
                    TargetView:PlayNormalOpenAnim()
                end
                self:RegisterTimer(
                    function()
                        self.SlotVMList[TargetIndex]:UpdateVM(LocalSlotData)
                        local InDataVMList = UIBindableList.New(ItemSimpleVM)
                        InDataVMList:UpdateByValues(RewardData.LotteryDrawReward)
                        UIViewMgr:ShowView(
                            UIViewID.CommonRewardPanel,
                            {
                                ItemVMList = InDataVMList,
                                CloseCallback = function()
                                    _G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.LotteryDraw, false)
                                end
                            }
                        )
                        self:InternalSetCanOperate(true)
                    end,
                    ShowRewardCommonPanelTimeDelay,
                    1
                )
            end
        end
    else
        self:OnOpsActivityUpdate(NodeOperate.ActivityDetail)
    end
end

function SeanceMainPanelView:OnOpsActivityNodeGetReward(Params)
    if (Params == nil) then
        _G.FLOG_ERROR("SeanceMainPanelView:OnOpsActivityNodeGetReward 错误，Params为空")
        return
    end

    local Reward = Params.Reward
    if (Reward == nil) then
        _G.FLOG_ERROR("错误 OnOpsActivityNodeGetReward， Params.Reward 为空，请检查")
        return
    end
    self:OnOpsActivityUpdate(Reward.Detail)
end

function SeanceMainPanelView:OnOpsActivityUpdate(Params)
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
                for _, SlotInfo in pairs(NodeInfo.Extra.Lottery.LotterySlotRecords) do
                    -- body
                    local LocalSlotData = Value.GridDataTable[SlotInfo.SlotID]
                    local TargetReward = SlotInfo.LotteryDrawRewards[1]
                    LocalSlotData.bGetted = true
                    LocalSlotData.bCanGet = false
                    LocalSlotData.ItemID = TargetReward.ItemID
                    LocalSlotData.Num = TargetReward.ItemNum
                    if (LocalSlotData.ItemID == Value.BigPrizeItemID) then
                        Value.bGetBigPrize = true
                        LocalSlotData.bGetBigPrize = true
                    else
                        Value.bGetBigPrize = false
                        LocalSlotData.bGetBigPrize = false
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

function SeanceMainPanelView:InternalSetCanOperate(InValue)
    if (InValue) then
        UIUtil.SetIsVisible(self.BtnMask, false, false)
    else
        UIUtil.SetIsVisible(self.BtnMask, true, true)
    end
end

-- 更新抽奖卡数据
function SeanceMainPanelView:InternalUpdateScratchCard()
    local DataList = ActivityInfoTable[self.CurPhaseIndex].GridDataTable
    for Index = 1, 9 do
        self.SlotVMList[Index]:UpdateVM(DataList[Index])
    end
    self.AdapterSlotTableView:UpdateAll(self.SlotVMList)
end

-- 更新任务数据
function SeanceMainPanelView:InternalUpdateTask()
    -- 打开任务界面
    local DataList = ActivityInfoTable[self.CurPhaseIndex].TaskNodeInfoTable
    local Params = {}
    Params.DataList = DataList
    Params.ActivityCfg = ActivityInfoTable[self.CurPhaseIndex].ActivityCfg
    local TargetView = _G.UIViewMgr:FindView(UIViewID.OpsSeanceScratchCardTaskView)
    if (TargetView and TargetView:IsValid()) then
        TargetView:UpdateInfo(Params)
    end

    self:InternalUpdateTaskRedDot()
end

function SeanceMainPanelView:InternalUpdateTaskRedDot()
    local DataList = ActivityInfoTable[self.CurPhaseIndex].TaskNodeInfoTable
    local bAnyTaskCanGet = false
    for _, Value in pairs(DataList) do
        if (Value.Status == RewardStatus.RewardStatusWaitGet) then
            bAnyTaskCanGet = true
            break
        end
    end

    if (bAnyTaskCanGet) then
        self.CommonRedDot:SetRedDotUIIsShow(true)
        self:PlayAnimation(self.AnimRedDotLoop, 0, 0)
    else
        self.CommonRedDot:SetRedDotUIIsShow(false)
        self:StopAnimation(self.AnimRedDotLoop)
    end
end

-- 更新左边的TAB
function SeanceMainPanelView:InternalUpadteTab(InTargetIndex)
    local bAnySave = false
    for Index = 1, 3 do
        self.TabViewList[Index]:UpdateInfo(ActivityInfoTable[Index])
        if (ActivityInfoTable[Index].bActivityOpen) then
            -- 如果活动开启了，去看一下本地是否已经播放过了
            if (not self.PhaseRedDotStatusTable[Index]) then
                local TempIndex = Index
                -- 播放一下动效
                self:RegisterTimer(
                    function()
                        self.TabViewList[Index]:PlayUnlockAnimation()
                    end,
                    0.5 * TempIndex,
                    1
                )
                self.PhaseRedDotStatusTable[Index] = 1
                bAnySave = true
            end
        end
    end

    if (bAnySave) then
        self:SavePhaseRedPointStatus()
    end

    self:OnTabSelected(InTargetIndex)
end

function SeanceMainPanelView:OnRegisterBinder()
end

-- 点击了刮刮乐的位置
function SeanceMainPanelView:OnClickScratchSlot(InViewData)
    local PhaseIndex = InViewData.PhaseIndex -- 第几期
    local InfoTable = ActivityInfoTable[PhaseIndex]
    if (InfoTable == nil) then
        _G.FLOG_ERROR("SeanceMainPanelView:OnClickScratchSlot 错误，期数无效，数值是：%s", PhaseIndex)
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
        _G.FLOG_ERROR("SeanceMainPanelView:OnClickScratchSlot 错误，传入的SlotIndex，无效，数值是:%s", SlotIndex)
        return
    end

    -- 这里去检测一下，如果最后一期已经开启，并且当前抽奖数 + 潜在可以获取的抽奖数 = 9，那么提醒一次
    local LastInfoTable = ActivityInfoTable[3]
    local bLastActivityOpen = OpsActivityMgr:IsActivityOpen(LastInfoTable.ActivityID)

    if (bLastActivityOpen) then
        local NotGetRewardCount = 0
        for Key, Value in pairs(LastInfoTable.TaskNodeInfoTable) do
            if (Value.Status ~= RewardStatus.RewardStatusDone) then
                NotGetRewardCount = NotGetRewardCount + Value.RewardCount
            end
        end

        local CountCanGet = DrawItemCount + NotGetRewardCount
        local MentionCount = 9
        if (CountCanGet == MentionCount) then
            local DrawMention = 1720017
            MsgBoxUtil.ShowMsgBoxTwoOp(
                self,
                LSTR(10004), -- 标题：提示
                LSTR(DrawMention), -- 内容
                function()
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

                    _G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.LotteryDraw, true)
                end -- 右边，确认回调
            )
            return
        end
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

    _G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.LotteryDraw, true)
end

local function StringToTable(str)
    if not str or type(str) ~= "string" then
        return
    end

    local flag, result = xpcall(load("return " .. str), CommonUtil.XPCallLog)
    if flag then
        return result
    else
        return
    end
end

function SeanceMainPanelView:SavePhaseRedPointStatus()
    local Text = _G.TableToString(self.PhaseRedDotStatusTable)
    local FilePath = self:GetSeanceRedDotPath()
    local File = io.open(FilePath, "w")

    if File then
        if not File:write(Text) then
            File:close()
            os.remove(FilePath)
            return
        end

        File:flush()
        File:close()
    end
end

-- 读取本地阶段红点及配置
function SeanceMainPanelView:LoadPhaseRedPointStatus()
    local Ret = {}

    local Path = self:GetSeanceRedDotPath()
    local File = io.open(Path, "r")
    if not File then
        return Ret
    end
    local Text = File:read("*a")
    if not Text or "" == Text then
        File:close()
        return Ret
    end

    local T = StringToTable(Text)
    if not T then
        File:close()
        os.remove(Path)
        return Ret
    end
    File:close()
    self.PhaseRedDotStatusTable = T
end

function SeanceMainPanelView:GetSeanceRedDotPath()
    -- 检查私聊缓存文件目录
    local FilePath = string.format("%s/Seance.dat", self.GetSaveDirDir())

    return FilePath
end

function SeanceMainPanelView.GetSaveDirDir()
    -- 检查私聊缓存文件目录
    local Dir = string.format("%s/Activity/%s", _G.FDIR_PERSISTENT(), MajorUtil.GetMajorRoleID())

    if not PathMgr.ExistDir(Dir) then
        PathMgr.CreateDir(Dir, false)
    end

    return Dir
end

return SeanceMainPanelView
