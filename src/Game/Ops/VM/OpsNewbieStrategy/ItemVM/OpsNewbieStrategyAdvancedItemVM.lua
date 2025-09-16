local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local OpsNewBieStrategyListItemVM = require("Game/Ops/VM/OpsNewbieStrategy/ItemVM/OpsNewBieStrategyListItemVM")
local OpsNewbieStrategyDefine = require("Game/Ops/OpsNewbieStrategy/OpsNewbieStrategyDefine")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local OpsNewbieStrategyRewardItemVM = require("Game/Ops/VM/OpsNewbieStrategy/ItemVM/OpsNewbieStrategyRewardItemVM")
local OpsNewbieStrategyMgr

---@class OpsNewbieStrategyAdvancedItemVM : UIViewModel
local OpsNewbieStrategyAdvancedItemVM = LuaClass(UIViewModel)

---Ctor
function OpsNewbieStrategyAdvancedItemVM:Ctor()
    OpsNewbieStrategyMgr = _G.OpsNewbieStrategyMgr
    self.Index = nil
    self.Title = nil
    self.InfoDesc = nil
    self.ID = nil
    self.ActiveNodeList = nil
    self.IsFinished = nil
    self.IsExpand = nil
    self.IsShowTextHint = nil
    self.NumText = nil
    self.IsUnLock = nil
    self.Icon = nil
    ---汇总节点
    self.ActivitySummaryNode = nil
    self.RewardItemList = nil
    self.Rewards = nil
    self.NodeID = nil
    self.RewardStatus = nil
    self.RewardItemList = nil
    self.QuestName = nil
end

function OpsNewbieStrategyAdvancedItemVM:UpdateVM(Value)
    if Value then
        if self.ActiveNodeList == nil then
            self.ActiveNodeList = UIBindableList.New( OpsNewBieStrategyListItemVM )
        end
        if self.RewardItemList == nil then
            self.RewardItemList = UIBindableList.New( OpsNewbieStrategyRewardItemVM )
        end
        --self.Index = Value.Index
        -- LSTR string:默认标题
        self.Title = Value.Activity.Title or LSTR(920029)
        -- LSTR string:默认描述
        self.InfoDesc = Value.Activity.Info  or LSTR(920028)
        self.IsUnLock = Value.Effected
        ---节点数据处理
        if Value.NodeList then
            local UIData = OpsNewbieStrategyMgr:GetActivityNodeUIDataByNodeList(Value.NodeList)
            self.MaxNum = UIData.MaxNum or 1
            self.CompletedNum = UIData.CompletedNum or 0
            self.Items = UIData.Items
            self.IsFinished = UIData.IsFinished
            self.QuestName = UIData.QuestName
            self.CompletedNumText = string.format("%s/%s", self.CompletedNum, self.MaxNum)
            table.sort(self.Items, function(a, b) 
               if a.Node.Head.Finished ~= b.Node.Head.Finished then
                    return not a.Node.Head.Finished
               else
                    return a.Node.Head.NodeID < b.Node.Head.NodeID
               end
            end)
            -- LSTR string:完成所有目标可领取
            local Text = UIData.SummaryNodeDesc or LSTR(920010)
            ---防止刷新时闪烁，改成已有item就不走UpdateByValues，目前数量固定，如果后续会有运行中数量变化，需要修改逻辑做增减判断
            local ActiveNodeItems = self.ActiveNodeList:GetItems()
            local IsNotFind = false
            local IsNeedSort = false
            if ActiveNodeItems and #ActiveNodeItems ~= 0 and #ActiveNodeItems == #self.Items then
                for _, NodeItem in ipairs(self.Items) do
                    local ItemVM = table.find_by_predicate(ActiveNodeItems, function(A)
                        return A.NodeID == NodeItem.Node.Head.NodeID
                    end)
                    if ItemVM then
                        local OldIsFinished = ItemVM:GetIsFinished()
                        local NewIsFinished = NodeItem.Node.Head.Finished
                        if OldIsFinished ~= NewIsFinished then
                            IsNeedSort = true
                        end
                        ItemVM:UpdateVM(NodeItem)
                    else
                        IsNotFind = true
                        break 
                    end
                end
            else
                self.ActiveNodeList:UpdateByValues(self.Items)
            end
            if IsNotFind or IsNeedSort then
                self.ActiveNodeList:UpdateByValues(self.Items)
            end
            if self.MaxNum and self.CompletedNum then
                ---规避节点变更更新推送时，无进度数据导致的显示错误，如果已完成，直接手动设置进度为满
                if self.IsFinished then
                    self.NumText = string.format("%s\n(%s/%s)",Text, self.MaxNum, self.MaxNum)
                else
                    self.NumText = string.format("%s\n(%s/%s)",Text, self.CompletedNum, self.MaxNum)
                end
            end
            self.ActivitySummaryNode = UIData.ActivitySummaryNode

            ---奖励数据处理
            if self.ActivitySummaryNode and self.ActivitySummaryNode.Node then
                ---表格数据，注意只读
                local NodeHead = self.ActivitySummaryNode.Node.Head 
                if NodeHead then
                    self.NodeID = NodeHead.NodeID
                    self.RewardStatus =  NodeHead.RewardStatus
                end
                local CfgData = ActivityNodeCfg:FindCfgByKey(self.NodeID)
                if CfgData then
                    --self.Rewards = table.clone(CfgData.Rewards)
                    self.Rewards = {}
                    for _, RewardData in ipairs(CfgData.Rewards ) do
                        if RewardData.ItemID ~= 0 and RewardData.ItemID ~= nil then
                            table.insert(self.Rewards, {ItemID = RewardData.ItemID, Type = RewardData.Type, Num = RewardData.Num, RewardStatus = self.RewardStatus, NodeID = self.NodeID})
                        end
                    end
                    self.RewardItemList:UpdateByValues(self.Rewards)
                end
                --NodeHead.Finished
            end

        end

        self.ID = Value.ActivityID
        if self.ID then
            self.Icon = OpsNewbieStrategyDefine.NewbieStrategyNodeBigIcon[self.ID]
        end
        --self.IsUnLock = OpsNewbieStrategyMgr:GetMenuActivityIsUnlock(OpsNewbieStrategyDefine.PanelKey.AdvancedPanel)
        self.IsShowTextHint = not self.IsFinished and self.IsExpand
        -----------------------------Bug定位逻辑,todo 定位完后删除-----------------------------------
        local ItemVMs = self.ActiveNodeList:GetItems()
        if ItemVMs then
            for _, ItemVM in ipairs(ItemVMs) do
                local NodeID = ItemVM.NodeID
                if NodeID == nil then
                    if self.ID == nil then
                        ---Bug定位日志
                        _G.FLOG_INFO(string.format("OpsNewbieStrategyAdvancedItem NodeID Error Name:%s ID: nil NodeID: nil", self.Title))
                    else
                        ---Bug定位日志
                        _G.FLOG_INFO(string.format("OpsNewbieStrategyAdvancedItem NodeID Error Name:%s ID：%d NodeID: nil", self.Title, self.ID))
                    end
                else
                    local NodeIDStr = tostring(NodeID)
                    local ActivityIDStr = tostring(self.ID)
                    local IsFind = string.find(NodeIDStr, ActivityIDStr)
                    if not IsFind then
                        if self.ID == nil then
                            ---Bug定位日志,
                            _G.FLOG_INFO(string.format("OpsNewbieStrategyAdvancedItem NodeID Error Name:%s ID: nil NodeID:%d, ", self.Title, NodeID))
                        else
                            ---Bug定位日志
                            _G.FLOG_INFO(string.format("OpsNewbieStrategyAdvancedItem NodeID Error Name:%s ID：%d NodeID:%d", self.Title, self.ID, NodeID))
                        end
                    end
                end
            end
        end
        -----------------------------Bug定位逻辑,todo 定位完后删除------------------------------
    end
end

function OpsNewbieStrategyAdvancedItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function OpsNewbieStrategyAdvancedItemVM:AdapterOnGetWidgetIndex()
    return self.Index
end

---更新当前界面完成状态
function OpsNewbieStrategyAdvancedItemVM:UpdateIsFinished()
    if self.CompletedNum and self.MaxNum then 
        self.IsFinished = self.CompletedNum >= self.MaxNum
    end
end

---设置当前界面完成状态
function OpsNewbieStrategyAdvancedItemVM:SetIsFinished(IsFinished)
    self.IsFinished = IsFinished
end

---获取当前界面完成状态
function OpsNewbieStrategyAdvancedItemVM:GetIsFinished()
    return self.IsFinished
end

--- 同一时间只有一个可以展开
function OpsNewbieStrategyAdvancedItemVM:ItemExpandChanged()
    self.IsExpand = not self.IsExpand
    self.IsShowTextHint = not self.IsFinished and self.IsExpand
end

function OpsNewbieStrategyAdvancedItemVM:SetItemExpand(InIsExpand)
    self.IsExpand = InIsExpand
    self.IsShowTextHint = not self.IsFinished and self.IsExpand
end

function OpsNewbieStrategyAdvancedItemVM:GetRewardStatus()
    return self.RewardStatus
end

function OpsNewbieStrategyAdvancedItemVM:GetNodeID()
    return self.NodeID
end

function OpsNewbieStrategyAdvancedItemVM:GetIsUnLock()
    return self.IsUnLock
end

function OpsNewbieStrategyAdvancedItemVM:GetIsExpand()
    return self.IsExpand
end

function OpsNewbieStrategyAdvancedItemVM:SetAnimfoldEndScroll(IsScrollTop)
    self.IsScrollTop = IsScrollTop
end

function OpsNewbieStrategyAdvancedItemVM:GetAnimfoldEndScroll()
    return self.IsScrollTop
end


return OpsNewbieStrategyAdvancedItemVM