local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsLoverFestivalMainVM : UIViewModel
local OpsLoverFestivalMainVM = LuaClass(UIViewModel)
---Ctor
function OpsLoverFestivalMainVM:Ctor()
    self.TextTitle = nil
    self.TextTitle = nil
    self.TaskTitle1 = nil
    self.TaskNumText1 = nil
    self.TaskLimit1 = nil
    self.TaskTitle2 = nil
    self.TaskNumText2 = nil
    self.TaskLimit2 = nil
    self.TaskTitle3 = nil
    self.TaskNumText3 = nil
    self.TaskLimit3 = nil
    self.LoveValue = nil
    self.WaitGetTips = nil
    self.WaitGetPanelVisible = false
end

function OpsLoverFestivalMainVM:Update(Params)
    local ActivityData = Params.Activity
    self.TextTitle = ActivityData.Title
    local NodeList = Params.NodeList
    local TaskNodeListInfo = {}
    local NodeProgressList = {}
    local GetChocoTaskList = {}
    self.WaitGetChocoNum = 0
    for _, Node in ipairs(NodeList) do
        local NodeID  = Node.Head.NodeID
        local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
        if NodeCfg ~= nil then
            if NodeCfg.NodeSort > 0 then
                if NodeCfg.NodeSort == 3 then
                    NodeCfg.TotalValue = NodeCfg.MaxProgressPerDay
                else
                    NodeCfg.TotalValue = NodeCfg.MaxFinTimes * NodeCfg.ProgressFactor
                end
                NodeCfg.ProgressValue = Node.Extra.Progress.DayValue
                table.insert(TaskNodeListInfo, NodeCfg)
            elseif NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeAccChildNodeProgress then
                Node.Target = NodeCfg.Target
                Node.Rewards = NodeCfg.Rewards
                Node.ActivityNodeID = NodeCfg.NodeID
                if NodeCfg.RewardStartTime ~= nil and NodeCfg.RewardStartTime ~= "" then
                    Node.RewardStartTime = NodeCfg.RewardStartTime
                end
                table.insert(NodeProgressList, Node)
            end
        end
    end
    local GuideActivityID = tonumber(ActivityData.ActivityID) + 1
	local GuideNodeList = _G.OpsActivityMgr:GetActivtyNodeInfo(GuideActivityID)
    if GuideNodeList and GuideNodeList.NodeList then
        for _, Node in ipairs(GuideNodeList.NodeList) do
            table.insert(GetChocoTaskList, Node)
            self.WaitGetChocoNum = self.WaitGetChocoNum + (Node.Head.CurrFinTimes - Node.Head.AwardTimes)
        end
    end

    if self.WaitGetChocoNum > 0 then
        self.WaitGetPanelVisible = true
        self.WaitGetTips = string.format(LSTR(100147), self.WaitGetChocoNum)
    else
        self.WaitGetPanelVisible = false
    end
    table.sort(TaskNodeListInfo, function(A, B)
            return A.NodeSort > B.NodeSort
    end)
    table.sort(NodeProgressList, function(A, B)
            return A.Target < B.Target
    end)
    local formats = {LSTR(100148), LSTR(100149), LSTR(100149)}
    if NodeProgressList[4] then
        self.LoveValue = NodeProgressList[4].Extra.Progress.Value
    else
        self.LoveValue = 0
    end
    for i = 1, 3 do
        self["TaskTitle" .. i] = TaskNodeListInfo[i].NodeDesc
        self["TaskNumText" .. i] = "+" .. TaskNodeListInfo[i].ProgressFactor
        self["TaskLimit" .. i] = string.format(formats[i], TaskNodeListInfo[i].ProgressValue, TaskNodeListInfo[i].TotalValue)
    end
    self.NodeProgressList = NodeProgressList
    self.GetChocoTaskList = GetChocoTaskList
end


return OpsLoverFestivalMainVM