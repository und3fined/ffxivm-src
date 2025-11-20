--[[
Author: jususchen jususchen@tencent.com
Date: 2025-07-30 14:55:38
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-07-30 14:57:00
FilePath: \Script\Game\Ops\OpsMoggleCollectMgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local LogableMgr = require("Common/LogableMgr")
local OpsMoggleCollectMainVM = require("Game/Ops/VM/OpsMoggleCollect/OpsMoggleCollectMainVM")
local ProtoCS = require("Protocol/ProtoCS")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")

local ActivityRewardStatus = ProtoCS.Game.Activity.RewardStatus

---@class OpsMoggleCollectMgr: LogableMgr
local OpsMoggleCollectMgr = LuaClass(LogableMgr)

---@return OpsMoggleCollectMainVM
function OpsMoggleCollectMgr:GetMainVM()
    if self.MainVM == nil then
        self.MainVM = OpsMoggleCollectMainVM:New()
    end

    return self.MainVM
end

function OpsMoggleCollectMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.OnGetNodeReward)
    self:RegisterGameEvent(_G.EventID.OpsActivityUpdate, self.OnActivityUpdate)
end

function OpsMoggleCollectMgr:OnGetNodeReward(MsgBody)
    if MsgBody == nil or MsgBody.Reward == nil then
        return
    end

    local Data = MsgBody.Reward.Detail
    local ActivityHead = Data.Head
    local ActivityID = ActivityHead.ActivityID
    self:GetMainVM():UpdateActivityData(ActivityID)
end

function OpsMoggleCollectMgr:OnActivityUpdate()
    self:GetMainVM():UpdateRedDots()
end

---@param VM OpsMoggleCollectNodeVM
function OpsMoggleCollectMgr.ClickNodeVM(VM)
    if VM == nil then
        return
    end

    local RewardStatus = VM.RewardStatus
    local NodeID = VM.NodeID
    if RewardStatus == ActivityRewardStatus.RewardStatusNo or RewardStatus == nil or VM:IsRepeateFinishNode() then
        --
        local JumpData = VM:GetJumpData()
        if JumpData and VM:IsJumpNode() then
            OpsActivityMgr:Jump(JumpData.JumpType, JumpData.JumpParam)
        else
            _G.FLOG_ERROR("missing jump data for node %s", NodeID)
        end
    elseif RewardStatus == ActivityRewardStatus.RewardStatusWaitGet then
        ---未领奖，领奖
        OpsActivityMgr:SendActivityNodeGetReward(NodeID)
    end
end

---@param RewardStatus any
---@param Widget any
---@param VM OpsMoggleCollectNodeVM
function OpsMoggleCollectMgr.OnNodeRewardStatusChanged(RewardStatus, Widget, VM)
    if VM == nil then
        return
    end

    if Widget == nil then
        return
    end

    if RewardStatus == ActivityRewardStatus.RewardStatusNo or RewardStatus == nil or VM:IsRepeateFinishNode() then
        if VM:IsNodeFinished() then
            Widget:SetIsDoneState(true, LSTR(920012))
        else
            ---在这里判断是否有配置前往
            if VM:IsJumpNode() then
                -- LSTR string:前往
                Widget:SetText(LSTR(920002))
                Widget:SetIsNormalState(true)
            else
                ---未完成
                -- LSTR string:未完成
                Widget:SetIsDoneState(true, LSTR(920049))
            end
        end
    elseif RewardStatus == ActivityRewardStatus.RewardStatusWaitGet then
        -- LSTR string:领取
        Widget:SetText(LSTR(920026))
        Widget:SetIsRecommendState(true)
    elseif RewardStatus == ActivityRewardStatus.RewardStatusDone then
        -- LSTR string:已领取
        Widget:SetIsDoneState(true, LSTR(920045))
    end
end

return OpsMoggleCollectMgr
