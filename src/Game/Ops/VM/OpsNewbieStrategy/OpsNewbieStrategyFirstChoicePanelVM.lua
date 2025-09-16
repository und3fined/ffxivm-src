local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local OpsNewBieStrategyListItemVM = require("Game/Ops/VM/OpsNewbieStrategy/ItemVM/OpsNewBieStrategyListItemVM")
local OpsNewbieStrategyMgr 

---@class OpsNewbieStrategyFirstChoicePanelVM : UIViewModel
local OpsNewbieStrategyFirstChoicePanelVM = LuaClass(UIViewModel)

function OpsNewbieStrategyFirstChoicePanelVM:Ctor()
    self.ActiveNodeList = nil
    self.CompletedNum = nil
    self.MaxNum = nil
    self.CompletedNumText = nil
    self.IsFinished = nil
    self.IsGetAllReward = nil
end

function OpsNewbieStrategyFirstChoicePanelVM:OnInit()
    self.ActiveNodeList = UIBindableList.New( OpsNewBieStrategyListItemVM )
    OpsNewbieStrategyMgr = _G.OpsNewbieStrategyMgr
end

--- 数据更新处理
function OpsNewbieStrategyFirstChoicePanelVM:UpdateOpsNewbieStrategyInfo(Data)
    self.ActivityID = Data:GetKey()
    if Data.NodeList then
        local UIData = OpsNewbieStrategyMgr:GetActivityNodeUIDataByNodeList(Data.NodeList)
        self.MaxNum = UIData.MaxNum or 1
        self.CompletedNum = UIData.CompletedNum or 0
        self.Items = UIData.Items
        self.IsFinished = UIData.IsFinished
        self.IsGetAllReward = UIData.IsGetAllReward
        local RewardNum = OpsNewbieStrategyMgr:GetFirstRewardNumByNodeID(UIData.ActivitySummaryNode.Node.Head.NodeID)
        local GetNum = 0
        if self.IsFinished then
            GetNum = RewardNum
        end
        self.CompletedNumText = string.format("%s/%s", GetNum, RewardNum)
        self.ActiveNodeList:UpdateByValues(self.Items)
    end
end

--- 数据更新处理/非OpsCommTabParentItemVM/OpsCommTabChildItemVM类型，为活动中心查询到的活动数据
function OpsNewbieStrategyFirstChoicePanelVM:UpdateOpsNewbieStrategyInfoByActivityData(Data)
    self.ActivityID = Data.Activity.ActivityID
    if Data.Detail.NodeList then
        local UIData = OpsNewbieStrategyMgr:GetActivityNodeUIDataByNodeList(Data.Detail.NodeList)
        self.MaxNum = UIData.MaxNum or 1
        self.CompletedNum = UIData.CompletedNum or 0
        self.Items = UIData.Items
        self.IsFinished = UIData.IsFinished
        self.IsGetAllReward = UIData.IsGetAllReward
        local RewardNum = OpsNewbieStrategyMgr:GetFirstRewardNumByNodeID(UIData.ActivitySummaryNode.Node.Head.NodeID)
        local GetNum = 0
        if self.IsFinished then
            GetNum = RewardNum
        end
        self.CompletedNumText = string.format("%s/%s", GetNum, RewardNum)
        self.ActiveNodeList:UpdateByValues(self.Items)
    end
end

---更新当前界面完成状态
function OpsNewbieStrategyFirstChoicePanelVM:UpdateIsFinished()
    if self.CompletedNum and self.MaxNum then 
        self.IsFinished = self.CompletedNum >= self.MaxNum
    end
end

---设置当前界面完成状态
function OpsNewbieStrategyFirstChoicePanelVM:SetIsFinished(IsFinished)
    self.IsFinished = IsFinished
end

---获取当前界面完成状态
function OpsNewbieStrategyFirstChoicePanelVM:GetIsFinished()
    return self.IsFinished
end

---获取当前界面领奖状态
function OpsNewbieStrategyFirstChoicePanelVM:GetIsGetAllReward()
    return self.IsGetAllReward
end


function OpsNewbieStrategyFirstChoicePanelVM:OnReset()

end

function OpsNewbieStrategyFirstChoicePanelVM:OnBegin()

end

function OpsNewbieStrategyFirstChoicePanelVM:OnEnd()

end

function OpsNewbieStrategyFirstChoicePanelVM:OnShutdown()

end

--要返回当前类
return OpsNewbieStrategyFirstChoicePanelVM