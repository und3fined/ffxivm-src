local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local UIBindableList = require("UI/UIBindableList")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local TimeUtil = require("Utils/TimeUtil")
local OpsVersionNoticeTaskItemVM = require("Game/Ops/VM/OpsVersionNoticeTaskItemVM")
local ItemDefine = require("Game/Item/ItemDefine")

local LSTR = _G.LSTR
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsVersionNoticeMainPanelVM : UIViewModel
local OpsVersionNoticeMainPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsVersionNoticeMainPanelVM:Ctor()
    self.TextTitle = nil
    self.TextInfo = nil
    self.TextTask = nil
    self.TextBtn = nil
    self.RewardSlotNum = nil
    self.RewardSlotNumVisiable = false
    self.RewardSlotIcon = nil
    self.RewardSlotQuality = nil
    self.RewardSlotReceieved = false
    self.ShareTipsVisiable = false

    self.Panel1Visiable = false
    self.Panel2Visiable = false
    self.Panel3Visiable = false
    self.Panel4Visiable = false
    self.Panel1ImgPoster1 = nil
    self.Panel1TextPoster1 = nil
    self.Panel2ImgPoster1 = nil
    self.Panel2TextPoster1 = nil
    self.Panel2ImgPoster2 = nil
    self.Panel2TextPoster2 = nil
    self.Panel3ImgPoster1 = nil
    self.Panel3TextPoster1 = nil
    self.Panel3ImgPoster2 = nil
    self.Panel3TextPoster2 = nil
    self.Panel3ImgPoster3 = nil
    self.Panel3TextPoster3 = nil
    self.Panel4ImgPoster1 = nil
    self.Panel4TextPoster1 = nil
    self.Panel4ImgPoster2 = nil
    self.Panel4TextPoster2 = nil
    self.Panel4ImgPoster3 = nil
    self.Panel4TextPoster3 = nil
    self.Panel4ImgPoster4 = nil
    self.Panel4TextPoster4 = nil
    self.TaskVMList = UIBindableList.New(OpsVersionNoticeTaskItemVM)
end

function OpsVersionNoticeMainPanelVM:Update(Params, IsUpdateActivity)
    local ActivityData = Params.Activity
    self.TextTitle = ActivityData.Title
    self.TextInfo = ActivityData.SubTitle

    local ClientShowNodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
    local nodeCount = #ClientShowNodeList
    if IsUpdateActivity == nil then
        for i = 1, 4 do
            self["Panel"..i.."Visiable"] = false
        end

        if nodeCount >= 1 and nodeCount <= 4 then
            self["Panel"..nodeCount.."Visiable"] = true

            local SortedNodes = {}
            for i = 1, nodeCount do
                local Node = ClientShowNodeList[i]
                local NodeCfg = ActivityNodeCfg:FindCfgByKey(Node.Head.NodeID)
                if NodeCfg then
                    table.insert(SortedNodes, {
                        Node = Node,
                        Cfg = NodeCfg,
                        Sort = NodeCfg.NodeSort or 0
                    })
                end
            end

            table.sort(SortedNodes, function(A, B)
                return A.Sort > B.Sort
            end)

            for i = 1, #SortedNodes do
                local Item = SortedNodes[i]
                self["Panel"..nodeCount.."ImgPoster"..i] = Item.Cfg.StrParam
                self["Panel"..nodeCount.."TextPoster"..i] = Item.Cfg.NodeDesc
            end
        end
    end

    local Tasks = {}
    local StatisticNodeID= {}
    local NodeList = Params.NodeList
    local AccumulativeNodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeAccumulativeFinishNode)
    local StatisticNodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeStatistic)
    local ShareNodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypePictureShare)
    if #ShareNodeList == 0 or #AccumulativeNodeList == 0 then
        return
    end
    local ShareNodeID = nil
    for _, ShareNode in ipairs(ShareNodeList) do
        local ShareNodeCfg = ActivityNodeCfg:FindCfgByKey(ShareNode.Head.NodeID)
        if ShareNodeCfg.Params[2] == 2 then
            ShareNodeID = ShareNode.Head.NodeID
            break
        end
    end
    if ShareNodeID == nil then
        return
    end
    local MainAccumulativeNode = self:GetMainAccumulativeNode(AccumulativeNodeList, ShareNodeID)
    if MainAccumulativeNode == nil then
        return
     end
    local MainAccumulativeNodeCfg = ActivityNodeCfg:FindCfgByKey(MainAccumulativeNode.Head.NodeID)
    if MainAccumulativeNodeCfg == nil then
        return 
     end
    self.RewardItemID = MainAccumulativeNodeCfg.Rewards[1].ItemID
    self.MainAccumulativeNodeID = MainAccumulativeNodeCfg.NodeID
    self.RewardStatus = MainAccumulativeNode.Head.RewardStatus
    self.RewardSlotNum = MainAccumulativeNodeCfg.Rewards[1].Num
    self.RewardSlotQuality = ItemUtil.GetSlotColorIcon(self.RewardItemID, ItemDefine.ItemSlotType.Item126Slot)
    self.RewardSlotIcon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(self.RewardItemID))
    if self.RewardSlotNum > 1 then
        self.RewardSlotNumVisiable = true
    else
        self.RewardSlotNumVisiable = false
    end
    for i = #AccumulativeNodeList, 1, -1 do
        if AccumulativeNodeList[i].Head.NodeID == MainAccumulativeNodeCfg.NodeID then
            table.remove(AccumulativeNodeList, i)
        end
    end
    self.RewardStatus = MainAccumulativeNode.Head.RewardStatus
    self.TaskDesc = MainAccumulativeNodeCfg.NodeDesc
    self.TextTask = string.format("%s (%d/%d)", self.TaskDesc, MainAccumulativeNode.Extra.Progress.Value, MainAccumulativeNodeCfg.Target)

    local ShareNodeCfg = ActivityNodeCfg:FindCfgByKey(ShareNodeID)
    if ShareNodeCfg == nil then
       return 
    end

    local ProgressText = string.format("(%d/%d)",ShareNodeList[1].Extra.Progress.Value, ShareNodeCfg.Target)
    local ShareTask = {TextTask = ShareNodeCfg.NodeDesc, TextQuantity = ProgressText, TextBtn = LSTR(970006), TaskFinished = ShareNodeList[1].Head.Finished,
                        JumpType = ShareNodeCfg.JumpType, JumpParam = ShareNodeCfg.JumpParam, Index = 0, PanelBtnVisiable = true, 
                        ActivityID = ShareNodeCfg.ActivityID, NodeID =ShareNodeCfg.NodeID, ShareNodeCfg = ShareNodeCfg}
    if ShareTask.TaskFinished then
        self.ShareTipsVisiable = true
    else
        self.ShareTipsVisiable = false
    end
    table.insert(Tasks, ShareTask)

    for _, Node in ipairs(AccumulativeNodeList) do
        local NodeCfg = ActivityNodeCfg:FindCfgByKey(Node.Head.NodeID)
        if NodeCfg then
            local TaskType = nil
            if NodeCfg.Target == 1 then
                TaskType = LSTR(OpsActivityDefine.LocalStrID.Or)
            else
                TaskType = LSTR(OpsActivityDefine.LocalStrID.And)
            end
            local NodeCfg1 = ActivityNodeCfg:FindCfgByKey(NodeCfg.Params[1])
            local NodeCfg2 = ActivityNodeCfg:FindCfgByKey(NodeCfg.Params[2])
            if NodeCfg1 and NodeCfg2 then
                local Node1 = self:GetStatisticNode(NodeList, NodeCfg1.NodeID)
                local Node2 = self:GetStatisticNode(NodeList, NodeCfg2.NodeID)
                local ProgressText1 = string.format("(%d/%d)",Node1.Extra.Progress.Value, NodeCfg1.Target)
                local ProgressText2 = string.format("(%d/%d)",Node2.Extra.Progress.Value, NodeCfg2.Target)
                local TextLockTime1 = ""
                local TextLockTime2 = ""
                local StartTime1 = ""
                local StartTime2 = ""
                if NodeCfg1.StartTime then
                    StartTime1 = string.gsub(NodeCfg1.StartTime, "(%d%d%d%d)-(%d%d)-(%d%d) %d%d:%d%d:%d%d", "%1/%2/%3")
                end
                if NodeCfg2.StartTime then
                    StartTime2 = string.gsub(NodeCfg2.StartTime, "(%d%d%d%d)-(%d%d)-(%d%d) %d%d:%d%d:%d%d", "%1/%2/%3")
                end
                if NodeCfg1.MinVersion == nil or NodeCfg1.MinVersion == "" then
                    TextLockTime1 = string.format(LSTR(100123), StartTime1)
                else
                    TextLockTime1 = string.format(LSTR(100102), StartTime1, NodeCfg1.MinVersion)
                end
                if NodeCfg2.MinVersion == nil or NodeCfg2.MinVersion == "" then
                    TextLockTime2 = string.format(LSTR(100123), StartTime2)
                else
                    TextLockTime2 = string.format(LSTR(100102), StartTime2, NodeCfg2.MinVersion)
                end
                local PanelBtnVisiable1 = self:IsPanelBtnVisiable(NodeCfg1)
                local PanelBtnVisiable2 = self:IsPanelBtnVisiable(NodeCfg2)
                local AccumulativeTask = {TextTask1 = NodeCfg1.NodeDesc, TextTask2 = NodeCfg2.NodeDesc, TextQuantity1 = ProgressText1, TextQuantity2 = ProgressText2, 
                                            TextBtn1 = NodeCfg1.JumpButton, TextBtn2 = NodeCfg2.JumpButton, Task1Finished = Node1.Head.Finished, Task1Finished = Node2.Head.Finished, 
                                            JumpType1 = NodeCfg1.JumpType, JumpParam1 = NodeCfg1.JumpParam, JumpType2 = NodeCfg2.JumpType, JumpParam2 = NodeCfg2.JumpParam,Index = 1,
                                            PanelBtnVisiable1 = PanelBtnVisiable1,PanelBtnVisiable2 = PanelBtnVisiable2, TextLockTime1 = TextLockTime1, TextLockTime2 = TextLockTime2, 
                                            ActivityID = NodeCfg.ActivityID, NodeID = NodeCfg.NodeID,NodeID1 = NodeCfg1.NodeID, NodeID2 = NodeCfg2.NodeID, TextTag = TaskType }
                if Node.Head.Finished then
                    AccumulativeTask.Task1Finished = true
                    AccumulativeTask.Task2Finished = true
                end
                table.insert(Tasks, AccumulativeTask)
                table.insert(StatisticNodeID, NodeCfg1.NodeID)
                table.insert(StatisticNodeID, NodeCfg2.NodeID)
            end
        end
    end

    for _, Node in ipairs(StatisticNodeList) do
        if not table.contain(StatisticNodeID, Node.Head.NodeID) then
            local NodeCfg = ActivityNodeCfg:FindCfgByKey(Node.Head.NodeID)
            if NodeCfg then
                local ProgressText = string.format("(%d/%d)",Node.Extra.Progress.Value, NodeCfg.Target)
                local TextLockTime = ""
                local StartTime = ""
                if NodeCfg.StartTime then
                    StartTime = string.gsub(NodeCfg.StartTime, "(%d%d%d%d)-(%d%d)-(%d%d) %d%d:%d%d:%d%d", "%1/%2/%3")
                end
                if NodeCfg.MinVersion == nil or NodeCfg.MinVersion == "" then
                    TextLockTime = string.format(LSTR(100123), StartTime)
                else
                    TextLockTime = string.format(LSTR(100102), StartTime, NodeCfg.MinVersion)
                end
                local PanelBtnVisiable = self:IsPanelBtnVisiable(NodeCfg)
                local StatisticTask = {TextTask = NodeCfg.NodeDesc, TextQuantity = ProgressText, TextBtn = NodeCfg.JumpButton, TaskFinished = Node.Head.Finished,JumpType = NodeCfg.JumpType, 
                                        JumpParam = NodeCfg.JumpParam, Index = 0, PanelBtnVisiable = PanelBtnVisiable, TextLockTime = TextLockTime, ActivityID = NodeCfg.ActivityID,
                                        NodeID = NodeCfg.NodeID }
                table.insert(Tasks, StatisticTask)
            end
        end
    end

    self.TaskVMList:UpdateByValues(Tasks)
end

function OpsVersionNoticeMainPanelVM:IsPanelBtnVisiable(NodeCfg)
    local GameVersion = _G.UE.UVersionMgr.GetGameVersion()
    local IsVersionInRange = self:IsVersionInRange(GameVersion, NodeCfg.MinVersion, NodeCfg.MaxVersion)
    local IsTimeInRange = self:IsTimeInRange(NodeCfg.StartTime, NodeCfg.EndTime)
    return (IsVersionInRange and IsTimeInRange) and true or false
end

function OpsVersionNoticeMainPanelVM:GetStatisticNode(NodeList, NodeID)
    for _, v in ipairs(NodeList) do
        if v.Head.NodeID == NodeID  then
            return v
        end
    end
end

function  OpsVersionNoticeMainPanelVM:GetMainAccumulativeNode(AccumulativeNodeList, ShareNodeID)
    for _, Node in ipairs(AccumulativeNodeList) do
        local NodeCfg = ActivityNodeCfg:FindCfgByKey(Node.Head.NodeID)
        local i = 1
        while i <= NodeCfg.ParamNum do
            if ShareNodeID == NodeCfg.Params[i] then
                return Node
            end
            i = i + 1
        end
    end
end

function OpsVersionNoticeMainPanelVM:IsTimeInRange(StartTime, EndTime)
    local ServerTimeStamp = TimeUtil.GetServerLogicTime()

    local StartTimeStamp = -1
    if StartTime and StartTime ~= "" then
        StartTimeStamp = TimeUtil.GetTimeFromString(StartTime)
    end

    local EndTimeStamp = math.huge
    if EndTime and EndTime ~= "" then
        EndTimeStamp = TimeUtil.GetTimeFromString(EndTime)
    end

    return ServerTimeStamp >= StartTimeStamp and ServerTimeStamp <= EndTimeStamp
end


function OpsVersionNoticeMainPanelVM:SplitVersion(version)
    local t = {}
    for num in string.gmatch(version, "%d+") do
        table.insert(t, tonumber(num))
    end
    return t
end

function OpsVersionNoticeMainPanelVM:CompareVersions(v1, v2)
    for i = 1, math.max(#v1, #v2) do
        local num1 = v1[i] or 0
        local num2 = v2[i] or 0
        if num1 < num2 then
            return -1
        elseif num1 > num2 then
            return 1
        end
    end
    return 0
end

function OpsVersionNoticeMainPanelVM:IsVersionInRange(GameVersion, minVersion, maxVersion)
    if not GameVersion or GameVersion == "" then
        return false
    end

    local appV = self:SplitVersion(GameVersion)

    if minVersion and minVersion ~= "" then
        local minV = self:SplitVersion(minVersion)
        if self:CompareVersions(appV, minV) < 0 then
            return false
        end
    end

    if maxVersion and maxVersion ~= "" then
        local maxV = self:SplitVersion(maxVersion)
        if self:CompareVersions(appV, maxV) > 0 then
            return false
        end
    end

    return true
end

return OpsVersionNoticeMainPanelVM