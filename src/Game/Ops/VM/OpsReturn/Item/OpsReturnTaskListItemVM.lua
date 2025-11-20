---
---@Author: ZhengJanChuan
---@Date: 2025-07-24 17:19:20
---@Description: 回归任务ItemVM
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local OpsReturnSigninRewardItemVM = require("Game/Ops/VM/OpsReturn/Item/OpsReturnSigninRewardItemVM")
local ItemUtil = require("Utils/ItemUtil")
local ProtoCS = require("Protocol/ProtoCS")
local OpsReturnTaskListItemVM = LuaClass(UIViewModel)

---Ctor
function OpsReturnTaskListItemVM:Ctor()
   self.NodeID = 0 
   self.WidgetIndex = 0
   self.TaskTitle = ""
   self.TaskSecTitle = ""
   self.TaskProgress = ""
   self.TaskSecProgress = ""
   self.TaskTarget = 0
   self.TaskProgressNum = 0
   self.TaskVisible = false
   self.TaskSecVisible = false
   self.GetRewardVisible = false
   self.RewardList = UIBindableList.New(OpsReturnSigninRewardItemVM)
   self.BtnText = ""  --diyige
   self.BtnSecText = ""
   self.AwardBtnText = ""
   self.AwardBtnState = ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet
   self.Task1State = -1
   self.Task2State = -1
   self.IsRed = nil
end

function OpsReturnTaskListItemVM:OnInit()
end

function OpsReturnTaskListItemVM:OnBegin()
end

function OpsReturnTaskListItemVM:OnEnd()
end 

function OpsReturnTaskListItemVM:OnShutdown()
end

function OpsReturnTaskListItemVM:UpdateVM(Value)
    self.NodeID = Value.NodeID
    self.TaskTitle = Value.TaskTitle
    self.TaskProgressNum = Value.TaskProgressNum
    self.TaskTarget = Value.TaskTarget
    self.TaskProgress = string.format("%d/%d",  self.TaskProgressNum, self.TaskTarget)
    local IsWillGet = ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet == Value.AwardBtnState
    local IsGot = ProtoCS.Game.Activity.RewardStatus.RewardStatusDone == Value.AwardBtnState
    self.WidgetIndex = Value.WidgetIndex
    -- self.RewardList = Value.RewardList
    self.IsRed = IsWillGet
    if Value.RewardList ~= nil then
        local ItemList = {}
        for _, v in ipairs(Value.RewardList) do
            if v.ItemID and v.ItemID ~= 0 then
                local Item = ItemUtil.CreateItem(v.ItemID, v.Num)
                Item.IsShowNum = true
			    Item.IsReward = false
			    Item.IsMask = IsGot
                table.insert(ItemList, Item)
            end
        end
        self.RewardList:UpdateByValues(ItemList)
    end
    self.AwardBtnState = Value.AwardBtnState
end

-- function OpsReturnTaskListItemVM:AdapterOnGetWidgetIndex()
--     return self.WidgetIndex
-- end

return OpsReturnTaskListItemVM
