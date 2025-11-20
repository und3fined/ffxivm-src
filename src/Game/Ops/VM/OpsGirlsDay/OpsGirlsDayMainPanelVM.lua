local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")

local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsGirlsDayMainPanelVM : UIViewModel
local OpsGirlsDayMainPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsGirlsDayMainPanelVM:Ctor()
    self.TextTitle = nil
    self.TextSubTitle = nil
    self.TaskTitle = nil
    self.TextShop = nil
    self.TextStage = nil
    self.TextFate = nil
    self.SnowRiceFruitNum = nil
    self.TaskFinished = false
end

function OpsGirlsDayMainPanelVM:Update(ActivityData)
    local Activity = ActivityData.Activity
    self.TextTitle = Activity.Title
    self.TextSubTitle = Activity.SubTitle

    local NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeStatistic)
    local TaskListInfo = {}
    if NodeList then
        for _, Node in ipairs(NodeList) do
            local NodeID  = Node.Head.NodeID
		    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode then
                if ActivityNode.NodeSort == 1 then
                    TaskListInfo[1] = {Node = Node, NodeCfg = ActivityNode}
                elseif ActivityNode.NodeSort == 2 then
                    TaskListInfo[2] = {Node = Node, NodeCfg = ActivityNode}
                elseif ActivityNode.NodeSort == 3 then
                    TaskListInfo[3] = {Node = Node, NodeCfg = ActivityNode}
                end
            end
	    end
    end

    for Index, TaskInfo in ipairs(TaskListInfo) do
        local Finished = TaskInfo.Node.Head.Finished
        if not Finished then
            self.TaskTitle = TaskInfo.NodeCfg.NodeTitle
            self.CurrentTaskIndex = Index
            self.TaskFinished = false
            break
        elseif Index == 3 then
            self.TaskTitle = TaskInfo.NodeCfg.NodeTitle
            self.CurrentTaskIndex = Index
            self.TaskFinished = true
        end
    end

    self.TaskListInfo = TaskListInfo

    NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
    if NodeList then
        for _, Node in ipairs(NodeList) do
            local NodeID  = Node.Head.NodeID
		    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode then
                if ActivityNode.NodeSort == 4 then
                    self.TextShop = ActivityNode.NodeTitle
                    self.ShopJumpInfo =  {JumpType = ActivityNode.JumpType, JumpParam =  ActivityNode.JumpParam}
                elseif ActivityNode.NodeSort == 5 then
                    self.TextStage = ActivityNode.NodeTitle
                    self.StageJumpInfo =  {JumpType = ActivityNode.JumpType, JumpParam =  ActivityNode.JumpParam}
                else
                    self.TextFate = ActivityNode.NodeTitle
                    self.FateInfo = {Node = Node, NodeCfg = ActivityNode}
                end
            end
	    end
    end

    NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeDaughterDayUpdateProgress)
    self.DaughterDayUpdateProgressNodeID = NodeList[1].Head.NodeID

end


return OpsGirlsDayMainPanelVM