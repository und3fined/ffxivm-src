local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local OpsMoggleCollectRewardItemVM = require("Game/Ops/VM/OpsMoggleCollect/OpsMoggleCollectRewardItemVM")
local UIBindableList = require("UI/UIBindableList")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")

local OPS_JUMP_TYPE = ProtoRes.Game.OPS_JUMP_TYPE
local ActivityRewardStatus = ProtoCS.Game.Activity.RewardStatus
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

local KEY_VALUE <const> = {}

---@class OpsMoggleCollectNodeVM: UIViewModel
local OpsMoggleCollectNodeVM = LuaClass(UIViewModel)

function OpsMoggleCollectNodeVM:Ctor()
    self.Icon = nil
    self.Title = nil
    self.Content = nil
    self.bShowButton = nil
    self.ButtonText = nil
    self.NodeID = nil
    self.RewardVMs = nil
    self.TargetText = ""
    self.RewardStatus = nil
    self.bFinished = nil
    self.bCompositeNode = nil
    self.bRewardUnGot = nil

    -- timer related
    self.bLock = nil
    self.bExpired = nil
    self.TimeComingStart = nil
    self.TimeComingEnd = nil
    self.StartTime = nil
    self.EndTime = nil
end

function OpsMoggleCollectNodeVM:UpdateVM(Value)
    rawset(self, KEY_VALUE, Value)

    self.NodeID = Value.NodeID
    self.bCompositeNode = Value.SubNodes and #Value.SubNodes > 0
    local NodeCfg = Value.NodeCfg
    self.Title = NodeCfg.NodeTitle
    self.Content = NodeCfg.NodeDesc
    
    local NodeTarget <const> = NodeCfg.Target

    local bFinished
    local RewardStatus
    ---NodeHead数据
    local NodeHead
    if Value.Node then
        NodeHead = Value.Node.Head
        if NodeHead then
            RewardStatus =  NodeHead.RewardStatus
            bFinished =  NodeHead.Finished
        end

        ---NodeExtra数据
        local NodeExtra = Value.Node.Extra
        if NodeExtra then
            self.Progress = NodeExtra.Progress
        end
    end
    self.bFinished = bFinished
    self.RewardStatus = RewardStatus
    self.Progress = self.Progress or {
        Value = 0,
        Day = 0 ,
        DayValue = 0,
    }

    -- rewards
    if self.RewardVMs == nil and #NodeCfg.Rewards > 0 then
        self.RewardVMs = UIBindableList.New(OpsMoggleCollectRewardItemVM)
    end
    local bRepeateFinishNode <const> = self:IsRepeateFinishNode()
    local Rewards = {}
    local TheRewardStatus = RewardStatus
    if bRepeateFinishNode then
        TheRewardStatus = nil
    end
    for _, RewardData in ipairs(NodeCfg.Rewards ) do
        if RewardData.ItemID ~= 0 and RewardData.ItemID ~= nil then
            table.insert(Rewards, {ItemID = RewardData.ItemID, Type = RewardData.Type, Num = RewardData.Num, RewardStatus = TheRewardStatus, NodeID = Value.NodeID})
        end
    end
    if self.RewardVMs then
        self.RewardVMs:UpdateByValues(Rewards)
    end
    self.bRewardNotGot = (RewardStatus == ActivityRewardStatus.RewardStatusWaitGet)

    -- Target 
    if self.bFinished then
        self.TargetText = string.sformat("%s/%s",NodeTarget, NodeTarget)
    else
        if  bRepeateFinishNode then
            self.TargetText = string.sformat(_G.LSTR(1740006),NodeHead and NodeHead.CurrFinTimes or 0)
        else
            self.TargetText = string.sformat("%s/%s",self.Progress.Value ,NodeTarget)
        end
    end

    self.Icon = self:GetIcon()

    if NodeCfg.StartTime and #NodeCfg.StartTime > 0 then
        self.StartTime = TimeUtil.ParseBeijingTime(NodeCfg.StartTime)
    end
    if NodeCfg.EndTime and #NodeCfg.EndTime > 0 then
        self.EndTime = TimeUtil.ParseBeijingTime(NodeCfg.EndTime)
    end

    self:TimerUpdate()
end

function OpsMoggleCollectNodeVM:GetNodeID()
    return self.NodeID
end

function OpsMoggleCollectNodeVM:GetNode()
    local Value = rawget(self, KEY_VALUE)
    if Value then
       return Value.Node 
    end
end

function OpsMoggleCollectNodeVM:GetNodeCfg()
    local Value = rawget(self, KEY_VALUE)
    if Value then
       return Value.NodeCfg
    end
end

function OpsMoggleCollectNodeVM:GetJumpData()
    local NodeCfg = self:GetNodeCfg()
    if not NodeCfg then
       return 
    end

    return {
        StrParam = NodeCfg.StrParam,
        JumpType = NodeCfg.JumpType,
        JumpParam = NodeCfg.JumpParam
    }
    
end

function OpsMoggleCollectNodeVM:GetIcon()
    local NodeCfg = self:GetNodeCfg()
    if NodeCfg then
        local StrCells = string.split(NodeCfg.StrParam, "|")
        if StrCells then
           return StrCells[1] 
        end
    end
end

---@return OpsMoggleCollectRewardItemVM | nil
function OpsMoggleCollectNodeVM:GetMoggleRewardItem(Index)
    if self.RewardVMs then
       return self.RewardVMs:Get(Index) 
    end
end

function OpsMoggleCollectNodeVM:IsJumpNode()
    if self.NodeID == nil then
        return
    end

    local JumpData = self:GetJumpData()
    return JumpData and JumpData.JumpType and JumpData.JumpType ~= OPS_JUMP_TYPE.NONE_JUMP
end


function OpsMoggleCollectNodeVM:IsRewardNotGot()
    return self.bRewardNotGot
end

function OpsMoggleCollectNodeVM:IsOrNode()
    local NodeCfg = self:GetNodeCfg()
    if NodeCfg then
        local Target = NodeCfg.Target or 0
        local Param = #NodeCfg.Params
        return Target > 0 and Param > Target
    end
end

function OpsMoggleCollectNodeVM:IsAndNode()
    local NodeCfg = self:GetNodeCfg()
    if NodeCfg then
        local Target = NodeCfg.Target or 0
        local Param = #NodeCfg.Params
        return Param == Target and Param > 1
    end
end

function OpsMoggleCollectNodeVM:IsNodeFinished()
    return self.bFinished
end

function OpsMoggleCollectNodeVM:IsRepeateFinishNode()
    local NodeCfg = self:GetNodeCfg()
    if NodeCfg then
        return NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeStatistic and  NodeCfg.MaxFinTimes > 0
    end
end

function OpsMoggleCollectNodeVM:IsEqualVM(Value)
    return Value and self.NodeID == Value.NodeID and Value.NodeID ~= nil
end

function OpsMoggleCollectNodeVM:TimerUpdate()
    local t = TimeUtil.GetServerLogicTime()
    self.bExpired = (self.EndTime and t >= self.EndTime)
    self.bLock = (self.StartTime and self.StartTime > t)

    if self.bLock then
        self.TimeComingStart = math.max(self.StartTime - t, 0)
    end
    if self.EndTime then
       self.TimeComingEnd = math.max(self.EndTime - t) 
    end
end


return OpsMoggleCollectNodeVM