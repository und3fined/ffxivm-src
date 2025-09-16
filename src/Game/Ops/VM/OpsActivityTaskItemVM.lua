local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ProtoCS = require("Protocol/ProtoCS")
local OpsActivityRewardItemVM = require("Game/Ops/VM/OpsActivityRewardItemVM")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local ItemDefine = require("Game/Item/ItemDefine")

---@class OpsActivityTaskItemVM : UIViewModel
local OpsActivityTaskItemVM = LuaClass(UIViewModel)

---Ctor
function OpsActivityTaskItemVM:Ctor()
    self.TaskContent = nil
    self.TaskProgress = nil
    self.TaskContent1 = nil
    self.TaskContent2 = nil
    self.TaskProgress1 = nil
    self.TaskProgress2 = nil
    self.TaskType = nil
    self.Index = nil
    self.TaskState = nil
    self.NodeID = nil
    self.bShowBtn1 = false
    self.bShowBtn2 = false
    self.bShowBtnGo = true
    self.JumpType = nil
    self.JumpParam = nil
    self.RewardList = UIBindableList.New(OpsActivityRewardItemVM)
    self.TextBtnGo = nil
end

function OpsActivityTaskItemVM:UpdateVM(TaskItem)
    self.Index = TaskItem.Index
    self.ActivityID = TaskItem.ActivityID
    self.TaskState = TaskItem.RewardStatus
    self.NodeID = TaskItem.NodeID
    local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
    local ActivityNode = ActivityNodeCfg:FindCfgByKey(self.NodeID)
    -- 简单任务
    if self.Index == 0 then
        self.TaskContent = TaskItem.NodeDes
        self.TaskProgress = string.format("(%d/%d)", tonumber(TaskItem.FinishedTask) or 0,  tonumber(TaskItem.TotalTask) or 1)
        self.JumpType = TaskItem.JumpType
        self.JumpParam = TaskItem.JumpParam
        self.JumpButton = TaskItem.JumpButton
        self.NodeDescColor = ActivityNode.NodeDescColor ~= "" and ActivityNode.NodeDescColor or "FFFFFF"
        self.ProgressColor = ActivityNode.ProgressColor ~= "" and ActivityNode.ProgressColor or "FFFFFF"
        self:RefreshBtnGoText()
    end

    -- 复杂任务
    if self.Index == 1 then
        self.TaskContent1 = TaskItem.NodeDes1
        self.TaskContent2 = TaskItem.NodeDes2
        self.TaskProgress1 = string.format("(%d/%d)", tonumber(TaskItem.FinishedTask1) or 0,  tonumber(TaskItem.TotalTask1) or 1)
        self.TaskProgress2 = string.format("(%d/%d)", tonumber(TaskItem.FinishedTask2) or 0,  tonumber(TaskItem.TotalTask2) or 1)
        self.JumpType1 = TaskItem.JumpType1
        self.JumpParam1 = TaskItem.JumpParam1
        self.JumpButton1 = TaskItem.JumpButton1
        self.JumpType2 = TaskItem.JumpType2
        self.JumpParam2 = TaskItem.JumpParam2
        self.JumpButton2 = TaskItem.JumpButton2
        self.TaskType = TaskItem.TaskType
        self.NodeID1 = TaskItem.NodeID1
        self.NodeID2 = TaskItem.NodeID2
        local ActivityNode1 = ActivityNodeCfg:FindCfgByKey(self.NodeID1)
        local ActivityNode2 = ActivityNodeCfg:FindCfgByKey(self.NodeID2)
        self.NodeDescColor1 = ActivityNode1.NodeDescColor ~= "" and ActivityNode1.NodeDescColor or "FFFFFF"
        self.NodeDescColor2 = ActivityNode2.NodeDescColor ~= "" and ActivityNode2.NodeDescColor or "FFFFFF"
        self.ProgressColor1 = ActivityNode1.ProgressColor ~= "" and ActivityNode1.ProgressColor or "FFFFFF"
        self.ProgressColor2 = ActivityNode2.ProgressColor ~= "" and ActivityNode2.ProgressColor or "FFFFFF"
        if self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
            if TaskItem.FinishedTask1 < TaskItem.TotalTask1 and self.JumpButton1 ~= "" then
                self.bShowBtn1 = true
            else
                self.bShowBtn1 = false
            end
            if TaskItem.FinishedTask2 < TaskItem.TotalTask2 and self.JumpButton2 ~= "" then
                self.bShowBtn2 = true
            else
                self.bShowBtn2 = false
            end
        else
            self.bShowBtn1 = false
            self.bShowBtn2 = false
        end
    end

    for i = #TaskItem.Rewards, 1, -1 do
        if TaskItem.Rewards[i].ItemID == 0 then
            table.remove(TaskItem.Rewards, i)
        else
            TaskItem.Rewards[i].RewardStatus = self.TaskState
            TaskItem.Rewards[i].ItemSlotType = ItemDefine.ItemSlotType.Item74Slot
        end
    end

    self.RewardList:UpdateByValues(TaskItem.Rewards)
end


function OpsActivityTaskItemVM:AdapterOnGetWidgetIndex()
    return self.Index
end

function OpsActivityTaskItemVM:RefreshBtnGoText()
    self.bShowBtnGo = true
    if self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
        if self.JumpButton and self.JumpButton ~= "" then
		    self.TextBtnGo = self.JumpButton
        end
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		self.TextBtnGo = LSTR(100036)
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
        self.TextBtnGo = LSTR(100037)
	end
end

function OpsActivityTaskItemVM:SetBtnState(BtnWidget)
    if not BtnWidget then return end

    if self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
        if self.JumpButton and self.JumpButton ~= "" then
            BtnWidget:SetIsNormalState(true)
        else
            BtnWidget:SetIsDoneState(true, LSTR(100044))
        end
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		BtnWidget:SetIsRecommendState(true)
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		BtnWidget:SetIsDoneState(true, LSTR(100037))
	end
end

function OpsActivityTaskItemVM:OnClickedGoHandle()
    if self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		OpsActivityMgr:Jump(self.JumpType, self.JumpParam)
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		OpsActivityMgr:SendActivityNodeGetReward(self.NodeID)
	    _G.LootMgr:SetDealyState(true)
	end
end

function OpsActivityTaskItemVM:IsEqualVM(Value)
    return false
end

return OpsActivityTaskItemVM