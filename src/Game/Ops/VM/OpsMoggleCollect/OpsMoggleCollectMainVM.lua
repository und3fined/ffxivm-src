--[[
Author: jususchen jususchen@tencent.com
Date: 2025-07-30 14:53:45
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-07-30 15:02:08
FilePath: \Script\Game\Ops\VM\OpsMoggleCollect\OpsMoggleCollectMainVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local OpsMoggleCollectNodeVM = require("Game/Ops/VM/OpsMoggleCollect/OpsMoggleCollectNodeVM")
-- local OpsMoggleCollectNormalItemVM = require("Game/Ops/VM/OpsMoggleCollect/OpsMoggleCollectNormalItemVM")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local OpsCommTabChildItemVM = require("Game/Ops/VM/OpsCommTabChildItemVM")
local OpsMoggleCollectParentItemVM = require("Game/Ops/VM/OpsMoggleCollect/OpsMoggleCollectParentItemVM")
local CfgBase = require("TableCfg/CfgBase")
local ActivityCfg = require("TableCfg/ActivityCfg")
local ProtoCS = require("Protocol/ProtoCS")

local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local ActivityRewardStatus = ProtoCS.Game.Activity.RewardStatus

---@class OpsMoggleCollectMainVM: UIViewModel
---@field MoggleActivityItemVMs table<number, OpsCommTabChildItemVM>
local OpsMoggleCollectMainVM = LuaClass(UIViewModel)

local TabActivities <const> = {
    [1] = 25072901,
    [2] = 25072902,
    [3] = 25072903
}

local function GetRedDotTabKeyString(Index)
    return "RedDotTab" .. Index
end

function OpsMoggleCollectMainVM:Ctor()
    self.Title = ""
    self.SubTitle = ""
    self.TabIndex = 1

    self.NormalTaskItemVMList = UIBindableList.New(OpsMoggleCollectNodeVM)
    self.WrapTaskItemVMList = UIBindableList.New(OpsMoggleCollectParentItemVM)
    rawset(self,"MoggleActivityItemVMs", {})

    self.RewardNodeVM1 = OpsMoggleCollectNodeVM.New()
    self.RewardNodeVM2 = OpsMoggleCollectNodeVM.New()
    self.RewardNodeVM3 = OpsMoggleCollectNodeVM.New()
    self.RewardNodeVM4 = OpsMoggleCollectNodeVM.New()

    for i = 1, 3 do
        self[GetRedDotTabKeyString(i)] = nil
    end

    self.Page1Name = nil
    self.Page2Name = nil
    self.Page3Name = nil
    self.HelpInfoID = nil

    self.ShopItemText = ""
    self.IconShopItem = ""
end

---@param Data OpsCommTabChildItemVM
function OpsMoggleCollectMainVM:UpdateByData(Data)
    self.Data = Data
    
    local ActivityID = Data.ActivityID
    
    rawset(self,"MoggleActivityItemVMs", {})

    local MoggleActivityItems = {}
    local ActivityDatas = _G.OpsActivityMgr:GetActivityListByClassify(Data.Activity.ClassifyID)
    for _, v in ipairs(ActivityDatas) do
        if v.Activity and v.Activity.FatherID == ActivityID then
            table.insert(MoggleActivityItems, v)
        end
    end
    for _, v in ipairs(MoggleActivityItems) do
        local VM = OpsCommTabChildItemVM.New()
        VM:UpdateVM(v)
        table.insert(self.MoggleActivityItemVMs, VM)
        local __, Idx = table.find_item(TabActivities, v.Activity.ActivityID)
        if Idx then
           self[string.sformat("Page%dName", Idx)] = v.Activity.SubPageName 
        end
    end

    self:SetTabIndex(self.TabIndex)

    local MainActiviyID = TabActivities[1]
    local NodeCfgs = CfgBase.FindAllCfg(ActivityNodeCfg, string.sformat("ActivityID=%s and NodeType=%s", MainActiviyID, ActivityNodeType.ActivityNodeTypeClientShow))
    if NodeCfgs then
        for i, v in ipairs(NodeCfgs) do
            local Cfg = ActivityNodeCfg:FindCfgByKey(v.NodeID)
            local k = string.format("RewardNodeVM%d", i)
            if self[k] == nil then
                local VM = OpsMoggleCollectNodeVM.New()
                self[k] = VM
            end
            self[k]:UpdateVM({NodeID = v.NodeID, NodeCfg=Cfg}) 
        end
    end

    self:UpdateShop()
    self:UpdateRedDots()
end

function OpsMoggleCollectMainVM:SetTabIndex(Index)
    self.TabIndex = Index

    if Index == nil then
       return 
    end

    local ActivityID = TabActivities[Index]
    if ActivityID == nil then
        _G.FLOG_ERROR("OpsMoggleCollectMainVM:SetTabIndex missing activity id %s %s", Index, debug.traceback())
       return 
    end

    local MoggoleActivityItem = table.find_by_predicate(self.MoggleActivityItemVMs, function(v)
        return v.ActivityID == ActivityID
    end)
    if MoggoleActivityItem == nil then
        _G.FLOG_ERROR("OpsMoggleCollectMainVM:SetTabIndex mising moggle activity item %s", ActivityID)
       return  
    end

    self.Title = MoggoleActivityItem.Activity.Title
    self.SubTitle = MoggoleActivityItem.Activity.SubTitle
    self.Info = MoggoleActivityItem.Activity.Info

    local NodeData = _G.OpsActivityMgr:GetActivtyNodeInfo(ActivityID)
    if NodeData and NodeData.NodeList then
        if ActivityID == TabActivities[1] then
            self:UpdateNormalTaskList(NodeData.NodeList)
        elseif ActivityID == TabActivities[2] then
            self:UpdateWrapTaskList(NodeData.NodeList, ActivityNodeType.ActivityNodeTypeAccumulativeFinishNode)
        elseif ActivityID == TabActivities[3] then
            self:UpdateWrapTaskList(NodeData.NodeList, ActivityNodeType.ActivityNodeTypeClientShow)
        end
    else
        _G.FLOG_ERROR("missing node data for activity %s", ActivityID)
    end

    self.HelpInfoID  = MoggoleActivityItem.Activity.ChinaActivityHelpInfoID
end

function OpsMoggleCollectMainVM:UpdateNormalTaskList(NodeList)
    local NodeValues = {}
    for _, Node in ipairs(NodeList) do
        local NodeID
        if Node.Head then
            NodeID = Node.Head.NodeID
        end
        local CfgData = ActivityNodeCfg:FindCfgByKey(NodeID)
        if CfgData and CfgData.NodeType == ActivityNodeType.ActivityNodeTypeStatistic then
            table.insert(NodeValues, {NodeID=NodeID, NodeCfg=CfgData, Node=Node})
        end
    end

    self.NormalTaskItemVMList:UpdateByValues(NodeValues, function(a, b)
        return a.NodeID < b.NodeID
    end)

    _G.EventMgr:SendEvent(_G.EventID.MoggleUpdateNormal, NodeValues)
end

function OpsMoggleCollectMainVM:UpdateWrapTaskList(NodeList, SpecType)
    local Values = {}
    for _, Node in ipairs(NodeList) do
        local NodeID
        if Node.Head then
            NodeID = Node.Head.NodeID
        end
        local CfgData = ActivityNodeCfg:FindCfgByKey(NodeID)
        if CfgData and CfgData.NodeType == SpecType then
            local v = {NodeID=NodeID, NodeCfg=CfgData, Node=Node, SubNodes = {}}
            table.insert(Values, v)
            for _, SubNodeID in ipairs(CfgData.Params) do
                local SubNode = table.find_by_predicate(NodeList, function(e)
                    return e.Head and e.Head.NodeID == SubNodeID
                end)
                if SubNode then
                   local SubNodeCfg = ActivityNodeCfg:FindCfgByKey(SubNodeID)
                   if SubNodeCfg and SubNodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeStatistic then
                        table.insert(v.SubNodes, {NodeID=SubNodeID, Node=SubNode, NodeCfg=SubNodeCfg, ParentNode=Node}) 
                   end
                end
            end
        end
    end

    self.WrapTaskItemVMList:UpdateByValues(Values, function(a, b)
        local AStartTime = a.StartTime or 0
        local BStartTime = b.StartTime or 0
        if AStartTime ~= BStartTime then
            return AStartTime > BStartTime
        end
        return a.NodeID < b.NodeID
    end)
end

function OpsMoggleCollectMainVM:UpdateActivityData(ActivityID)
    local MoggoleActivityItem = table.find_by_predicate(self.MoggleActivityItemVMs, function(v)
        return v.ActivityID == ActivityID
    end)

    if MoggoleActivityItem == nil then
       return 
    end

    local ActivityDatas = _G.OpsActivityMgr:GetActivityListByClassify(MoggoleActivityItem.Activity.ClassifyID)
    for _, v in ipairs(ActivityDatas) do
        if v.Activity and v.Activity.ActivityID == ActivityID then
            MoggoleActivityItem:UpdateVM(v)
            break
        end
    end
    
    local NodeData = _G.OpsActivityMgr:GetActivtyNodeInfo(ActivityID)
    if NodeData and NodeData.NodeList and self.TabIndex and TabActivities[self.TabIndex] == ActivityID then
        if ActivityID == TabActivities[1] or ActivityID == TabActivities[3] then
            self:UpdateNormalTaskList(NodeData.NodeList)
        else
            self:UpdateWrapTaskList(NodeData.NodeList)
        end
    else
        _G.FLOG_ERROR("missing node data for activity %s", ActivityID)
    end

    self:UpdateShop()
    self:UpdateRedDots()
end

function OpsMoggleCollectMainVM:GetSubTitle()
    local Cfg = ActivityCfg:FindCfgByKey(TabActivities[1])
    if Cfg then
       return Cfg.SubTitle 
    end
end

function OpsMoggleCollectMainVM:UpdateShop()
    if self.RewardNodeVM4 then
        local RewardVM = self.RewardNodeVM4:GetMoggleRewardItem(1)
        if RewardVM then
			self.ShopItemText = string.sformat("%s: %d", RewardVM.Name, _G.BagMgr:GetItemNum(RewardVM.ItemID))
            self.IconShopItem = RewardVM.Icon
        end
    end
end

function OpsMoggleCollectMainVM:UpdateRedDots()
    local bFlag = false
    for i, ActivityID in ipairs(TabActivities) do
        local NodeData = _G.OpsActivityMgr:GetActivtyNodeInfo(ActivityID)
        local k = GetRedDotTabKeyString(i)
        local bUnGot
        if NodeData and NodeData.NodeList then
            for _, Node in ipairs(NodeData.NodeList) do
                if Node.Head then
                    if Node.Head.RewardStatus == ActivityRewardStatus.RewardStatusWaitGet then
                        bUnGot = true
                        bFlag = true
                        break
                    end
                end
            end
        end
        self[k] = bUnGot
    end

    if self.Data then
        local Key = _G.OpsActivityMgr:GetRedDotName(self.Data.Activity.ClassifyID, self.Data.ActivityID)
        if bFlag then
            _G.RedDotMgr:AddRedDotByName(Key)
        else
            _G.RedDotMgr:DelRedDotByName(Key)
        end
    end
end


return OpsMoggleCollectMainVM