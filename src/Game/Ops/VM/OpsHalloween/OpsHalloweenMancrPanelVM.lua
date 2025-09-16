local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ProtoRes = require("Protocol/ProtoRes")
local OpsHalloweenMancrTaskItemVM = require("Game/Ops/VM/OpsHalloween/OpsHalloweenMancrTaskItemVM")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local LocalizationUtil = require("Utils/LocalizationUtil")
local PWorldHelper = require("Game/PWorld/PWorldHelper")
local ProtoCS = require("Protocol/ProtoCS")

local LSTR = _G.LSTR
local OpsActivityMgr = _G.OpsActivityMgr

local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsHalloweenMancrPanelVM : UIViewModel
local OpsHalloweenMancrPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsHalloweenMancrPanelVM:Ctor()
    self.TimeVisible = nil
    self.EstimateWaitTimeDesc = nil
    self.CancelText = nil

    self.ChallengeVisible = nil
	self.MatchVisible = nil
    self.TaskVMList = UIBindableList.New(OpsHalloweenMancrTaskItemVM)
end

function OpsHalloweenMancrPanelVM:ShowTaskByActivityID(Activity)
    local ActivityID = Activity.ActivityID
    local ActivityTitle = Activity.Title
    local Detail = OpsActivityMgr.ActivityNodeMap[ActivityID] or {}
    local NodeList = Detail.NodeList or {}
    local TaskNodeList = {}

    for _, Node in ipairs(NodeList) do
        local NodeID  = Node.Head.NodeID
        if Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
            Node.Level = 3
        elseif  Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
            Node.Level = 2
        elseif  Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
            Node.Level = 1
        end
        local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
        if ActivityNode then
            if ActivityNode.NodeTitle == ActivityTitle then
                table.insert(TaskNodeList, Node)
            end
        end
    end

    table.sort(TaskNodeList,function(A, B) 
        local ANodeCfg = ActivityNodeCfg:FindCfgByKey(A.Head.NodeID)
        local BNodeCfg = ActivityNodeCfg:FindCfgByKey(B.Head.NodeID)
        if A.Level ~= B.Level then
            return A.Level > B.Level
        else
            return ANodeCfg.NodeSort < BNodeCfg.NodeSort
        end
        end )

    self.TaskVMList:UpdateByValues(TaskNodeList)
end

function OpsHalloweenMancrPanelVM:UpdateMatch(EntID)
    local PWorldMatchMgr = _G.PWorldMatchMgr
    self.IsMatching = PWorldMatchMgr:IsPWorldMatching(EntID)
    self.ChallengeVisible = not self.IsMatching

    if self.MatchVisible == not self.IsMatching then
        self.MatchChange = true
    end

	self.MatchVisible = self.IsMatching

    self:UpdateMatchTime(EntID)
end

function OpsHalloweenMancrPanelVM:UpdateMatchTime(EntID)
    if EntID == nil then
        return 
     end

     local MatchTimeData = _G.PWorldMatchMgr:GetMatchTimeDataElement(EntID)
     if MatchTimeData then
        self.EstimateWaitTimeDesc = string.sformat(LSTR(1320117), MatchTimeData.EstDesc)
        self.CancelText = PWorldHelper.pformat("PWORLD_MATCH_CANCEL_REMAIN", LocalizationUtil.GetCountdownTimeForShortTime(MatchTimeData.TotalWaitTime, "mm:ss"))
    else
        self.EstimateWaitTimeDesc = ""
        self.CancelText = LSTR(1320007)
    end
    
end



return OpsHalloweenMancrPanelVM