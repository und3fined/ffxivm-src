local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ProtoRes = require("Protocol/ProtoRes")
local OpsActivityTaskItemVM = require("Game/Ops/VM/OpsActivityTaskItemVM")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoCS = require("Protocol/ProtoCS")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local LSTR = _G.LSTR
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsActivityTaskPanelVM : UIViewModel
local OpsActivityTaskPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsActivityTaskPanelVM:Ctor()
    self.TextTitle = nil
    self.TextSubTitle = nil
    self.ShareContext = nil
    self.ShareIcon = nil
    self.bShowSubTitle = false
    self.TaskVMList = UIBindableList.New(OpsActivityTaskItemVM)
end

function OpsActivityTaskPanelVM:Update(ActivityData)
    local Activity = ActivityData.Activity
    self.TextTitle = Activity.Title
    local subTitle = Activity.SubTitle
    local Info = Activity.Info
    self.TextSubTitle = (subTitle ~= "" and subTitle) or (Info ~= "" and Info) or ""
    if self.TextSubTitle ~= "" then
        self.bShowSubTitle = true
    else
        self.bShowSubTitle = false
    end
    local NodeList = ActivityData.NodeList
    if ActivityData.NodeList then
        local TotalStatisticNodes = {}
        local AccumulativeFinishNodes = {}
        for _, v in ipairs(NodeList) do
            if not v.Head.EmergencyShutDown then
                local NodeCfg = ActivityNodeCfg:FindCfgByKey(v.Head.NodeID)
                if NodeCfg then
                    if NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeStatistic or 
                       NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeAccumulativeLoginDay or 
                       NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeMountPhoto or
                       NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeMallPurchased or
                       NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeCounter or
                       self:IsStatisticShareNode(NodeCfg) then
                        local Node = {}
                        Node.Index = 0
                        Node.ActivityID = NodeCfg.ActivityID
                        Node.NodeID = v.Head.NodeID
                        Node.NodeDes = NodeCfg.NodeDesc
                        Node.TotalTask = NodeCfg.Target
                        Node.FinishedTask = (v and v.Extra and v.Extra.Progress) and v.Extra.Progress.Value or 0
                        Node.RewardStatus = v.Head.RewardStatus
                        Node.Rewards = NodeCfg.Rewards
                        Node.JumpType = NodeCfg.JumpType
                        Node.JumpParam = NodeCfg.JumpParam
                        Node.JumpButton = NodeCfg.JumpButton
                        Node.NodeSort = NodeCfg.NodeSort
                        table.insert(TotalStatisticNodes,Node)
                    elseif NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeAccumulativeFinishNode then
                        local StatisticNode1 = ActivityNodeCfg:FindCfgByKey(NodeCfg.Params[1])
                        local StatisticNode2 =ActivityNodeCfg:FindCfgByKey(NodeCfg.Params[2])
                        local Node1 = self:GetStatisticNode(NodeList, StatisticNode1.NodeID)
                        local Node2 = self:GetStatisticNode(NodeList, StatisticNode2.NodeID)
                        local Node = {}
                        Node.Index = 1
                        Node.RewardStatus = v.Head.RewardStatus
                        Node.Rewards = NodeCfg.Rewards
                        Node.NodeID = v.Head.NodeID
                        Node.ActivityID = NodeCfg.ActivityID
                        Node.NodeSort = NodeCfg.NodeSort

                        Node.NodeDes1 = StatisticNode1.NodeDesc
                        Node.FinishedTask1 = (Node1 and Node1.Extra and Node1.Extra.Progress) and Node1.Extra.Progress.Value or 0
                        Node.TotalTask1 = StatisticNode1.Target
                        Node.NodeID1 = StatisticNode1.NodeID
                        Node.JumpType1 = StatisticNode1.JumpType
                        Node.JumpParam1 = StatisticNode1.JumpParam
                        Node.JumpButton1 = StatisticNode1.JumpButton

                        Node.NodeDes2 = StatisticNode2.NodeDesc
                        Node.FinishedTask2 = (Node2 and Node2.Extra and Node2.Extra.Progress) and Node2.Extra.Progress.Value or 0
                        Node.TotalTask2 = StatisticNode2.Target
                        Node.NodeID2 = StatisticNode2.NodeID
                        Node.JumpType2 = StatisticNode2.JumpType
                        Node.JumpParam2 = StatisticNode2.JumpParam
                        Node.JumpButton2 = StatisticNode2.JumpButton

                        if NodeCfg.Target > 1 then
                            Node.TaskType = LSTR(OpsActivityDefine.LocalStrID.And)
                        else
                            Node.TaskType = LSTR(OpsActivityDefine.LocalStrID.Or)
                        end
                        table.insert(AccumulativeFinishNodes,Node)
                    end
                end
            end
        end

        local i = 1
        while i <= #TotalStatisticNodes do
            if self:IsStatisticNodeInAccumulativeFinishNode(TotalStatisticNodes[i].NodeID, AccumulativeFinishNodes) then
                table.remove(TotalStatisticNodes, i)
            else
                i = i + 1
            end
        end

        self.Tasks = table.array_concat(TotalStatisticNodes,AccumulativeFinishNodes)
        for _, Task in ipairs(self.Tasks) do
            self:SetTaskLevel(Task)
        end

        table.sort(self.Tasks,function(l, r)
            if l.Level ~= r.Level then
                return l.Level > r.Level
            else
                return l.NodeSort > r.NodeSort
            end
        end)
        self.TaskVMList:UpdateByValues(self.Tasks)
    end
end

function OpsActivityTaskPanelVM:IsStatisticNodeInAccumulativeFinishNode(NodeID, AccumulativeFinishNodes)
    for _, AccumulativeFinishNode in ipairs(AccumulativeFinishNodes) do
        if AccumulativeFinishNode.NodeID1 == NodeID or AccumulativeFinishNode.NodeID2 == NodeID then
            return true
        end
    end
    return false
end

function OpsActivityTaskPanelVM:GetStatisticNode(NodeList, NodeID)
    for _, v in ipairs(NodeList) do
        if v.Head.NodeID == NodeID  then
            return v
        end
    end
end

function OpsActivityTaskPanelVM:SetTaskLevel(Task)
    if Task.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
        Task.Level = 3
    elseif  Task.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
        Task.Level = 2
    elseif  Task.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
        Task.Level = 1
    end
end

function OpsActivityTaskPanelVM:IsStatisticShareNode(NodeCfg)
    if NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypePictureShare and  NodeCfg.Params[2] == 2 then
        return true
    else
        return false
    end
end

return OpsActivityTaskPanelVM