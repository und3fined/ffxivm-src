local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local ActivityCutCfg = require("TableCfg/ActivityCutCfg")

-- @class ActivitySequenceMgr : MgrBase
local ActivitySequenceMgr = LuaClass(MgrBase)

function ActivitySequenceMgr:Ctor()
    self.HoldType = nil
    self.HoldID = nil
end

function ActivitySequenceMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.OpsActivityUpdateInfo, self.OpsActivityUpdateInfo)
end


function ActivitySequenceMgr:OpsActivityUpdateInfo(MsgBody)
    --只看节点完成情况，保持通用逻辑
    local SequenceID = 0
    if MsgBody and MsgBody.NodeOperate then
        local NodeOperate = MsgBody.NodeOperate
        if NodeOperate.OpType ~= self.HoldType then
            return
        end
        self.HoldType = nil
        if NodeOperate.ActivityDetail and NodeOperate.ActivityDetail.Nodes and next(NodeOperate.ActivityDetail.Nodes) then
            local Nodes = NodeOperate.ActivityDetail.Nodes
            --从头遍历配置的节点完成情况，协议节点不保序
            local CutCfg = self:FindTrueActivitySeqData(self.HoldID)
            if not CutCfg or not next(CutCfg) then
                _G.FLOG_ERROR("ActivitySequenceMgr, Cant Find SeqData By ID ===="..ID)
                return
            end
            self.HoldID = nil
            if Nodes and next(Nodes) then
                for _ , v in pairs(CutCfg.ActivityCutData) do
                    for _, node in pairs(Nodes) do
                        if tonumber(v.NodeID) and node.Head and node.Head.NodeID and tonumber(v.NodeID) == node.Head.NodeID then
                            if node.Head.Finished then
                                SequenceID = v.SequenceID
                            end
                        end
                    end
                end
            end
        end
    end
    if SequenceID ~= 0 then
        _G.NpcDialogMgr:CheckNeedEndInteraction()
        _G.StoryMgr:PlayDialogueSequence(tonumber(SequenceID))
    end
end

function ActivitySequenceMgr:PlaySeqByActivityNode(ID)
    local CutCfg = self:FindTrueActivitySeqData(ID)
    if not CutCfg or not next(CutCfg) then
        _G.FLOG_ERROR("ActivitySequenceMgr, Cant Find SeqData By ID ===="..ID)
        return
    end
    local NodeID = CutCfg.BaseNodeID
    local NodeType = CutCfg.NodeType
    self.HoldID = ID
    self.HoldType = CutCfg.NodeType
    OpsActivityMgr:SendActivityNodeOperate(tonumber(NodeID),NodeType, {})
end

function ActivitySequenceMgr:FindTrueActivitySeqData(ID)
    local CutCfg = nil
    local DataID = tonumber(ID)
    if DataID then
        --<10000为表头ID查询，Customtalk用，>10000为首节点Seqid,任务用
        if DataID < 10000 then
            CutCfg = ActivityCutCfg:FindCfgByKey(ID)
        else
            local SearchCondition = string.format("HeadSequenceID == %s", ID)
            CutCfg = ActivityCutCfg:FindCfg(SearchCondition)
        end
    end
    return CutCfg
end
return ActivitySequenceMgr