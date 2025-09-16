--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-03-31 11:22:01
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-03-31 11:23:09
FilePath: \Script\Game\Ops\View\OpsSkateboard\VM\OpsSkateBoardMainVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local OpsActivityWhaleMonutVM = require("Game/Ops/VM/OpsActivityWhaleMonutVM")
local LuaClass = require("Core/LuaClass")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local OpsSkateBoardMainVM = LuaClass(OpsActivityWhaleMonutVM)
local ProtoCS = require("Protocol/ProtoCS")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local LSTR = _G.LSTR

local StrParamIndexDefine ={
    MountName = 1,
    MountDes = 2,
    BuyDes = 3,
    BuyRewardID = 4,
    MoviePath = 5
}

function OpsSkateBoardMainVM:Ctor()
    self.Super.Ctor(self)
end

local function MakeNode(Index, Data, NodeCfg, Activity)
    local RedDotName = _G.OpsActivityMgr:GetRedDotName(Activity.ClassifyID, Activity.ActivityID, string.format("Reward/Task%s", Index))
    local RewardStatus = Data.Head.RewardStatus
    local Node = {
        Index = 0,
        NodeID = Data.Head.NodeID,
        NodeDes = NodeCfg.NodeDesc,
        TotalTask = NodeCfg.Target,
        FinishedTask = Data.Extra.Progress.Value,
        RewardStatus = RewardStatus,
        Rewards = NodeCfg.Rewards,
        JumpType = NodeCfg.JumpType,
        JumpID = tonumber(NodeCfg.JumpParam) or 0,
        RedDotName = RedDotName,
        Sort = RewardStatus ~= ProtoCS.Game.Activity.RewardStatus.RewardStatusDone and NodeCfg.NodeSort or NodeCfg.NodeSort - 999999,
        Locked = Data.Head.Locked,
        JumpButton = NodeCfg.JumpButton
    }

    return Node
end

function OpsActivityWhaleMonutVM:Update(ActivityData)
    local Activity = ActivityData.Activity
    local TotalStatisticNodes = {}
  
    local NodeList = ActivityData.NodeList
    for i, v in ipairs(NodeList) do
        if not v.Head.EmergencyShutDown then
            local NodeCfg = ActivityNodeCfg:FindCfgByKey(v.Head.NodeID) or {}
            if NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeMallPurchased then
                self:SetGoodsID(NodeCfg.Params and NodeCfg.Params[1] or 0)
                self:SetActGoodsHasBought(v.Extra.Progress)
                local SplitList = string.split(NodeCfg.StrParam, "|")
                for i, v in ipairs(SplitList) do
                    if self["StrParamText".. i] then
                        self["StrParamText".. i] = tonumber(v) and _G.LSTR(tonumber(v)) or v
                    end
                end

                self.PreviewMonutJumpID = NodeCfg.JumpParam
                self.PreviewMonutJumpType = NodeCfg.JumpType
                if SplitList[StrParamIndexDefine.BuyRewardID] then
                    self.BuyRewardItemID = tonumber(SplitList[StrParamIndexDefine.BuyRewardID])
                end

                if SplitList[StrParamIndexDefine.MoviePath] then
                    self.MoviePath = SplitList[StrParamIndexDefine.MoviePath]
                end
                
            elseif NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeStatistic or NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeAccumulativeFinishNode then
                table.insert(TotalStatisticNodes, MakeNode(i, v, NodeCfg, Activity))
            elseif NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypePictureShare then
                self.ShareNodeParams = NodeCfg.Params
            else

            end
        end
    end

    self.Tasks = TotalStatisticNodes
    self.StrParamText3Visible = not self:GetActGoodsHasBought()
    table.sort(self.Tasks,function(l, r) return l.Sort > r.Sort end)
    self.TaskVMList:UpdateByValues(self.Tasks)
    self:UpdateRed()
end

function OpsSkateBoardMainVM:GetBuyRewardItemID()
    return self.BuyRewardItemID
end

function OpsSkateBoardMainVM:GetMoviePath()
    return self.MoviePath
end

function OpsSkateBoardMainVM:GetShareNodeParams()
    return self.ShareNodeParams
end

return OpsSkateBoardMainVM