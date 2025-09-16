--
-- Author: ZhengJianChuan
-- Date: 2024-12-03 19:20:07
-- Description:
--
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local GameNetworkMgr

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Game.Activity.Cmd

---@class OpsActivityFirstChargeMgr : MgrBase
local OpsActivityFirstChargeMgr = LuaClass(MgrBase)

---OnInit
function OpsActivityFirstChargeMgr:OnInit()
    self.RewardStatus = ProtoCS.Game.Activity.RewardStatus.RewardStatusNo
    self.ActivityID = nil
    self.NodeID = nil
end

---OnBegin
function OpsActivityFirstChargeMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
end

function OpsActivityFirstChargeMgr:OnEnd()
end

function OpsActivityFirstChargeMgr:OnShutdown()
end

function OpsActivityFirstChargeMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, SUB_MSG_ID.Reward, self.OnSendGetFirstChargeReward) -- 领取奖励
end

function OpsActivityFirstChargeMgr:OnRegisterGameEvent()
end

function OpsActivityFirstChargeMgr:SetActivityID(ActivityID)
    self.ActivityID = ActivityID
end

function OpsActivityFirstChargeMgr:GetActivityID()
    return self.ActivityID
end

function OpsActivityFirstChargeMgr:SetNodeID(NodeID)
    self.NodeID = NodeID
end

function OpsActivityFirstChargeMgr:GetNodeID()
    return self.NodeID
end

-- 发送领取首充奖励
function OpsActivityFirstChargeMgr:SendGetFirstChargeReward()
    if self.ActivityID == nil then return end
    if self.NodeID == nil then return end
    local NodeCfg = ActivityNodeCfg:FindCfgByKey(self.NodeID)
    if NodeCfg == nil then return end
    _G.LootMgr:SetDealyState(true)
    local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
    local SubMsgID = SUB_MSG_ID.Reward
    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    MsgBody.Reward = {NodeID = NodeCfg.NodeID}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--领取首充回调
function OpsActivityFirstChargeMgr:OnSendGetFirstChargeReward(MsgBody)
    if nil == MsgBody then
        return
    end

    if self.ActivityID == nil then
        return
    end

    if self.NodeID == nil then
        return
    end

    local NodeCfg = ActivityNodeCfg:FindCfgByKey(self.NodeID)
    if NodeCfg == nil then return end

    local Data = MsgBody.Reward
    if Data == nil then
        _G.FLOG_INFO("OpsActivityFirstChargeMgr:OnSendGetFirstChargeReward Data Is nil")
        return
    end
    local Detail = Data.Detail
    if Detail == nil then
        _G.FLOG_INFO("OpsActivityFirstChargeMgr:OnSendGetFirstChargeReward Detail Is nil")
        return
    end

    if  table.is_nil_empty(Detail.Nodes) then
        _G.FLOG_INFO("OpsActivityFirstChargeMgr:OnSendGetFirstChargeReward Detail.Nodes Is nil")
        return 
    end
    local Node = Detail.Nodes[1]
    local Head = Detail.Head

    local ActivityID = Head.ActivityID
    if not (ActivityID ==  self.ActivityID and NodeCfg.NodeID == Node.Head.NodeID)  then
        return 
    end

    -- 奖励道具弹窗
    local Params = {}
    Params.ItemList = {}
    for _, v in ipairs(NodeCfg.Rewards) do
        if  v.ItemID ~= 0 then
            table.insert(Params.ItemList, { ResID = v.ItemID, Num = v.Num})
        end
    end
    local Status = Node.Head.RewardStatus
	OpsActivityFirstChargeMgr:SetFirstChargerStatus(Status)

    _G.EventMgr:SendEvent(_G.EventID.OpsActivityNodeGetReward, MsgBody)
    
    --奖励列表
    _G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, Params)
end


-------------------------------------------------------------------------------------------------------
function OpsActivityFirstChargeMgr:GetFirstChargerStatus()
    return self.RewardStatus
end

function OpsActivityFirstChargeMgr:SetFirstChargerStatus(Status)
    self.RewardStatus = Status
end


--要返回当前类
return OpsActivityFirstChargeMgr
