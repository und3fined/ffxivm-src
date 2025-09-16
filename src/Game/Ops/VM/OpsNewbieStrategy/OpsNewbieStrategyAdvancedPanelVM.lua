local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local OpsNewbieStrategyAdvancedItemVM = require("Game/Ops/VM/OpsNewbieStrategy/ItemVM/OpsNewbieStrategyAdvancedItemVM")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local OpsNewbieStrategyDefine = require("Game/Ops/OpsNewbieStrategy/OpsNewbieStrategyDefine")
local QuestHelper = require("Game/Quest/QuestHelper")
local ProtoCS = require("Protocol/ProtoCS")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsNewbieStrategyAdvancedPanelVM : UIViewModel
local OpsNewbieStrategyAdvancedPanelVM = LuaClass(UIViewModel)

function OpsNewbieStrategyAdvancedPanelVM:Ctor()
    self.SubActivityList = nil
    self.CompletedNum = nil
    self.MaxNum = nil
    self.CompletedNumText = nil
    self.IsFinished = nil
    self.CurSelectItem = nil
    self.CurSelectIndex = nil
    ---进阶活动数据
    self.ActivityData = nil
    self.IsUnLock = nil
    self.QuestName = nil
end

function OpsNewbieStrategyAdvancedPanelVM:OnInit()
    self.SubActivityList = UIBindableList.New(OpsNewbieStrategyAdvancedItemVM)
end

--- 数据更新处理
function OpsNewbieStrategyAdvancedPanelVM:UpdateOpsNewbieStrategyInfo(Data)
    if Data.ActivityData then
        self.ActivityData = Data.ActivityData
        self.ActivityID = self.ActivityData:GetKey()
        -- LSTR string:默认标题
        self.Title = self.ActivityData.Title or LSTR(920029)
        -- LSTR string:默认描述
        self.InfoDesc = self.ActivityData.Info  or LSTR(920028)
        self.IsUnLock =  self.ActivityData.Effected
        self.NodeList = self.ActivityData.NodeList or {}
        ---获取纯显示节点数据
        for _, Node in ipairs(self.NodeList) do
            local NodeID = Node.Head.NodeID
            local CfgData = ActivityNodeCfg:FindCfgByKey(NodeID)
            if CfgData and CfgData.NodeType == ActivityNodeType.ActivityNodeTypeClientShow then
                if CfgData.Params and #CfgData.Params > 1 then
                    if CfgData.Params[1] == OpsNewbieStrategyDefine.ShowNodeType.ActivityData then
                        local TaskID = CfgData.Params[2]
                        local QuestCfg = QuestHelper.GetQuestCfgItem(TaskID)
                        local Cfg
                        if QuestCfg then
                            Cfg = QuestHelper.GetChapterCfgItem(QuestCfg.ChapterID)
                        end
                        if Cfg then
                            self.QuestName = Cfg.QuestName
                        end
                    end
                end
            end
        end
    end
    if Data.SubActivityList then
        table.sort(Data.SubActivityList, function(a, b) 
            return a.ActivityID < b.ActivityID
        end)
        ---防止刷新时展开被刷掉，改成已有item就不走UpdateByValues，目前运行中数量固定，如果后续会有运行中数量变化，需要修改逻辑做增减判断
        local SubActivityItems = self.SubActivityList:GetItems()
        local IsFind = true
        if SubActivityItems and #SubActivityItems ~= 0 and #SubActivityItems == #Data.SubActivityList then
            for _, SubActivity in ipairs(Data.SubActivityList) do
                local SubItem = table.find_by_predicate(SubActivityItems, function(A)
                    return A.ID == SubActivity.ActivityID
                end)
                if SubItem then
                    SubItem:UpdateVM(SubActivity)
                else
                    IsFind = false
                    break
                end
            end
        else
            self.SubActivityList:UpdateByValues(Data.SubActivityList)
        end
        if not IsFind then
            self.SubActivityList:UpdateByValues(Data.SubActivityList)
        end
        self.MaxNum = #Data.SubActivityList
        self.CompletedNum = 0
        local ActivityItemVMs = self.SubActivityList:GetItems()
        for _, ActivityItemVM in ipairs(ActivityItemVMs) do
            if ActivityItemVM:GetIsFinished() then
                self.CompletedNum = self.CompletedNum + 1
            end
        end
        self.CompletedNumText = string.format("%s/%s", self.CompletedNum, self.MaxNum)
        self.IsFinished = self.CompletedNum >= self.MaxNum
    end
end

function OpsNewbieStrategyAdvancedPanelVM:GetIsUnlock()
    return self.IsUnLock
end

function OpsNewbieStrategyAdvancedPanelVM:SetIsUnlock(IsUnLock)
    self.IsUnLock = IsUnLock
end
--- 更新某个子活动数据
function OpsNewbieStrategyAdvancedPanelVM:UpdateOpsNewbieStrategySubActivity(Data)
    if Data and Data.Activity and Data.Detail then
        local ActivityID = Data.Activity.ActivityID
        ---结构与全量更新不一致，转化一下
        local VMData = {Activity = Data.Activity, NodeList = Data.Detail.NodeList, Effected = Data.Detail.Effected, ActivityFinish = Data.Detail.ActivityFinish}
        local Items = self.SubActivityList:GetItems()
        local SubItem = table.find_by_predicate(Items, function(A)
            return A.ID == ActivityID
        end)
        if SubItem then
            SubItem:UpdateVM(VMData)
        end
    end
end

--- 更新当前界面完成状态
function OpsNewbieStrategyAdvancedPanelVM:UpdateIsFinished()
    if self.CompletedNum and self.MaxNum then 
        self.IsFinished = self.CompletedNum >= self.MaxNum
    end
end

--- 设置当前界面完成状态
function OpsNewbieStrategyAdvancedPanelVM:SetIsFinished(IsFinished)
    self.IsFinished = IsFinished
end

--- 获取当前界面完成状态
function OpsNewbieStrategyAdvancedPanelVM:GetIsFinished()
    return self.IsFinished
end

---获取当前界面领奖状态
function OpsNewbieStrategyAdvancedPanelVM:GetIsGetAllReward()
    ---进阶界面本身无汇总节点，检查子活动的领取情况
    local IsGetAllReward = true
    local Items = self.SubActivityList:GetItems()
    for _, ItemVM in ipairs(Items) do
        if  ItemVM:GetRewardStatus() ~= ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
            IsGetAllReward = false
            break
        end
    end
    return IsGetAllReward
end

function OpsNewbieStrategyAdvancedPanelVM:OnReset()

end

function OpsNewbieStrategyAdvancedPanelVM:OnBegin()

end

function OpsNewbieStrategyAdvancedPanelVM:OnEnd()

end

function OpsNewbieStrategyAdvancedPanelVM:OnShutdown()

end

function OpsNewbieStrategyAdvancedPanelVM:SetSelectedItem(Index, ItemData, ItemView)
    local OldIndex = self.CurSelectIndex
    local OldItemData = self.CurSelectItem
    self.CurSelectIndex = Index
    --无论是否点击到自己，都会取消选中
    if OldItemData then
        OldItemData:SetItemExpand(false)
    end
    if OldIndex ~= self.CurSelectIndex then
        self.CurSelectItem = ItemData
        if self.CurSelectItem then
            self.CurSelectItem:SetItemExpand(true)
        end
    else
        ---选中同一个视为取消选中
        self.CurSelectIndex = nil
    end
end

function OpsNewbieStrategyAdvancedPanelVM:GetCurSelectedIndex()
    return self.CurSelectIndex
end

function OpsNewbieStrategyAdvancedPanelVM:SetCurSelectedIndex(Index)
    self.CurSelectIndex = Index
end

function OpsNewbieStrategyAdvancedPanelVM:GetQuestName()
    return self.QuestName or ""
end

function OpsNewbieStrategyAdvancedPanelVM:ClearCurSelected()
    if self.CurSelectItem then
        self.CurSelectItem:SetItemExpand(false)
        self.CurSelectItem:SetAnimfoldEndScroll(false)
    end
    self.CurSelectItem = nil
    self.CurSelectIndex = nil
end

--要返回当前类
return OpsNewbieStrategyAdvancedPanelVM