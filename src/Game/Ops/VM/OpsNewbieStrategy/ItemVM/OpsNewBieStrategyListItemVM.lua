local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local OpsNewbieStrategyDefine = require("Game/Ops/OpsNewbieStrategy/OpsNewbieStrategyDefine")
---@class OpsNewBieStrategyListItemVM : UIViewModel
local OpsNewBieStrategyListItemVM = LuaClass(UIViewModel)

---Ctor
function OpsNewBieStrategyListItemVM:Ctor()
    self.Index = nil
    self.NodeTitle = nil
    self.NodeID = nil
    self.ParentActivityID = nil
    self.Rewards = nil
    self.Quantity1NumText = nil
    self.RewardStatus = nil
    self.RewardType = nil
    self.FirstNodeDesc = nil
    self.SecondNodeDesc = nil
    self.IsCompositeNode = nil
    self.Rewards = nil
    self.IsFinished = nil
    self.IsShowBtnStrategy = nil
    self.JumpData = nil
    self.Icon = nil
    self.IconColor = nil
end

-- // 活动节点
-- message ActivityNode {
--   NodeHead Head = 1;    // 节点头
--   NodeExtra Extra = 2;  // 自定义数据
-- }

-- message NodeHead {
--   int64 NodeID = 1;               // 节点ID
--   bool Locked = 2;                // 是否已锁定
--   bool Finished = 3;              // 是否已完成
--   RewardStatus RewardStatus = 4;  // 奖励领取状态
--   bool EmergencyShutDown = 5;     // 紧急关闭
-- }

-- // 活动结点自定义数据
-- message NodeExtra {
--   oneof Data {
--     NodeExtraProgress Progress = 1;  // 进度数据
--     NodeExtraShareBuy ShareBuy = 2;  // 分享购买
--   }
-- }

function OpsNewBieStrategyListItemVM:UpdateVM(Value)
    ---数据更新
    if Value and Value.Node then
        ---NodeHead数据
        local NodeHead = Value.Node.Head
        if NodeHead then
            self.NodeID = NodeHead.NodeID
            self.RewardStatus =  NodeHead.RewardStatus
            self.IsFinished =  NodeHead.Finished
        else
            return
        end
        ---NodeExtra数据
        local NodeExtra = Value.Node.Extra
        if NodeExtra then
            self.Progress = NodeExtra.Progress
        else
            self.Progress = {
                 Value = 0,
                 Day = 0 ,
                 DayValue = 0,
            }
        end
        ---没有ID
        if self.NodeID == nil then
            return
        end
        ---表格数据/注意只读
        local CfgData = Value.CfgData or ActivityNodeCfg:FindCfgByKey(self.NodeID)
        if  CfgData == nil then
            return
        end
        local Str = CfgData.StrParam
        self.IsShowBtnStrategy = false
        self.Icon = nil
        self.JumpData = nil
        self.StrategyJumpData = nil
        self.ShieldCrystalIDList = {}
        if Str then
            local JumpData = {}
            local StrategyJumpData = {}
            local JumpStrList = string.split(Str, ",")
            for _, JumpStr in ipairs(JumpStrList) do
                local JumpParams = string.split(JumpStr, "|")
                if JumpParams and JumpParams[1] then
                    local NewbieStrategyStrParamType = tonumber(JumpParams[1])
                    if NewbieStrategyStrParamType == OpsNewbieStrategyDefine.NewbieStrategyStrParamType.StrategyJump then
                        self.IsShowBtnStrategy = true
                        for i = 2, #JumpParams do
                           table.insert(StrategyJumpData, JumpParams[i])
                        end
                    elseif NewbieStrategyStrParamType == OpsNewbieStrategyDefine.NewbieStrategyStrParamType.PluralJump then
                        local JumpValueList = {}
                        for i = 2, #JumpParams do
                           table.insert(JumpValueList, JumpParams[i])
                        end
                        table.insert(JumpData,JumpValueList)
                    elseif NewbieStrategyStrParamType == OpsNewbieStrategyDefine.NewbieStrategyStrParamType.Icon then
                        self.Icon = JumpParams[2]
                    elseif NewbieStrategyStrParamType == OpsNewbieStrategyDefine.NewbieStrategyStrParamType.ShieldCrystalID then
                        ---以太水晶id屏蔽
                        self.ShieldCrystalIDList = JumpParams[2]
                    end
                end
            end
            ---前往跳转
            if #JumpData > 0 then
                self.JumpData = JumpData
            end
            ---攻略跳转
            if #StrategyJumpData > 0 then
                self.StrategyJumpData = StrategyJumpData
            end
        end
        self.ParentActivityID = CfgData.ActivityID
        -- LSTR string:默认标题
        self.NodeTitle = CfgData.NodeTitle or LSTR(920029)
        -- LSTR string:默认描述
        self.FirstNodeDesc = CfgData.NodeDesc or LSTR(920028)
        self.Target = CfgData.Target
        self.Rewards = table.clone(CfgData.Rewards)
        if self.Rewards and self.Rewards[1] then
            self.RewardType = self.Rewards[1].ItemType
        end
        self.IsCompositeNode = false
        local NodeType = CfgData.NodeType
        if CfgData.Params and #CfgData.Params > 1 and NodeType ==  ActivityNodeType.ActivityNodeTypeAccumulativeFinishNode and (CfgData.NodeDesc == nil or CfgData.NodeDesc == "") then
            self.IsCompositeNode = true
        end
        ---如果是复合节点，获取子节点的数据来显示(暂时不考虑嵌套复合节点)
        if  self.IsCompositeNode then
            local FirstNodeID = CfgData.Params[1]
            local FirstNodeCfgData = ActivityNodeCfg:FindCfgByKey(FirstNodeID)
            local FirstTarget = FirstNodeCfgData.Target

            local SecondNodeID = CfgData.Params[2]
            local SecondNodeCfgData = ActivityNodeCfg:FindCfgByKey(SecondNodeID)
            local SecondTarget = SecondNodeCfgData.Target

            local FirstProgress
            local SecondProgress
            -- LSTR string:默认描述
            self.FirstNodeDesc = FirstNodeCfgData.NodeDesc or LSTR(920028)
            -- LSTR string:默认描述
            self.SecondNodeDesc = SecondNodeCfgData.NodeDesc or LSTR(920028)
            ---规避节点变更更新推送时，无进度数据导致的显示错误，如果已完成，直接手动设置进度为满
            if self.IsFinished then
                self.Quantity1NumText = string.format("%s/%s",FirstTarget, FirstTarget)
                self.Quantity2NumText = string.format("%s/%s",SecondTarget, SecondTarget)
            else
                    if Value.SubNodeList then
                    for _, SubNode in ipairs(Value.SubNodeList) do
                        if  SubNode.Node and SubNode.Node.Head and SubNode.Node.Extra then
                            local SubNodeID = SubNode.Node.Head.NodeID
                            if SubNodeID == FirstNodeID then
                                FirstProgress = SubNode.Node.Extra.Progress
                            elseif SubNodeID == SecondNodeID then
                                SecondProgress = SubNode.Node.Extra.Progress
                            end
                        end
                    end
                end
                if FirstTarget and FirstProgress and FirstProgress.Value then
                    self.Quantity1NumText = string.format("%s/%s",FirstProgress.Value, FirstTarget)
                end
                if SecondTarget and SecondProgress and SecondProgress.Value then
                    self.Quantity2NumText = string.format("%s/%s",SecondProgress.Value, SecondTarget)
                end
            end

        else
            if self.Target and self.Progress and self.Progress.Value then
                ---规避节点变更更新推送时，无进度数据导致的显示错误，如果已完成，直接手动设置进度为满
                if self.IsFinished then
                    self.Quantity1NumText = string.format("%s/%s",self.Target, self.Target)
                else
                    self.Quantity1NumText = string.format("%s/%s",self.Progress.Value ,self.Target)
                end
            end
        end
        ---UI数据
        self.Index = Value.Index
        -- if self.Target and self.Progress and self.Progress.Value then
        --     self.Quantity1NumText = self.Quantity1NumText or string.format("%s/%s",self.Progress.Value ,self.Target)
        -- end
        local IsAetherLightNode = false
        for Key, _ in pairs(OpsNewbieStrategyDefine.AetherLightNodeJumpPanelData) do
            if Key == self.NodeID then
                IsAetherLightNode = true
            end
        end
        if IsAetherLightNode then
            self.IconColor = OpsNewbieStrategyDefine.NewbieStrategyNodeIconColor.AetherLightColor
        else
            self.IconColor = OpsNewbieStrategyDefine.NewbieStrategyNodeIconColor.NormalColor
        end
    end
end

function OpsNewBieStrategyListItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.NodeID == self.NodeID
end

function OpsNewBieStrategyListItemVM:AdapterOnGetWidgetIndex()
    return self.Index
end

function OpsNewBieStrategyListItemVM:GetRewardStatus()
    return self.RewardStatus
end

function OpsNewBieStrategyListItemVM:GetRewards()
    return self.Rewards
end

function OpsNewBieStrategyListItemVM:GetRewardType()
    return self.RewardType
end

function OpsNewBieStrategyListItemVM:GetIsAdvancedEthericActivityNode()
    return self.ParentActivityID == OpsNewbieStrategyDefine.ActivityID.AdvancedEthericActivityID
end

function OpsNewBieStrategyListItemVM:GetNodeID()
    return self.NodeID
end

function OpsNewBieStrategyListItemVM:GetIsFinished()
    return self.IsFinished
end

function OpsNewBieStrategyListItemVM:GetJumpData()
    return self.JumpData
end

function OpsNewBieStrategyListItemVM:GetStrategyJumpData()
    return self.StrategyJumpData
end

function OpsNewBieStrategyListItemVM:GetNodeTitle()
    return self.NodeTitle
end

function OpsNewBieStrategyListItemVM:GetShieldCrystalIDList()
    return self.ShieldCrystalIDList
end

function OpsNewBieStrategyListItemVM:GetParentActivityID()
    return self.ParentActivityID
end

return OpsNewBieStrategyListItemVM