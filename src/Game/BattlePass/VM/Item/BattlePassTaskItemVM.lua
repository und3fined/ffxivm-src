---
---@Author: ZhengJanChuan
---@Date: 2024-01-17 09:58:16
---@Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIDefine = require("Define/UIDefine")
local ItemVM = require("Game/BattlePass/VM/Item/BattlePassRewardSlotVM")
local ItemUtil = require("Utils/ItemUtil")
local BattlePassTaskItemVM = LuaClass(UIViewModel)

---Ctor
function BattlePassTaskItemVM:Ctor()
    self.TaskName = ""
    self.TaskID = 0
    self.BtnText = ""
    self.Reward = ItemVM.New()
    self.BtnState = -1
    self.NodeID = 0
end

function BattlePassTaskItemVM:OnInit()
end

function BattlePassTaskItemVM:OnBegin()
end

function BattlePassTaskItemVM:OnEnd()
end 

function BattlePassTaskItemVM:OnShutdown()
end

function BattlePassTaskItemVM:UpdateVM(Value)
    self.TaskID = Value.TaskID
    self.NodeID = Value.NodeID
    self.TaskName = Value.TaskName
    self.BtnState = Value.BtnState
    self.RewardVisible = true
    
    if Value.ResID and Value.Num then
        local ItemVM = {}
        ItemVM.Lv = 1
        ItemVM.ResID = Value.ResID
        ItemVM.Num = Value.Num
        ItemVM.IsUnlock = false
        self.Reward:UpdateVM(ItemVM)
    end
end

function BattlePassTaskItemVM:UpdateChangeState(IsSelected)
   self.IsSelected = IsSelected
end

function BattlePassTaskItemVM:IsEqualVM(Value)
    return self.TaskID == Value.TaskID
end

return BattlePassTaskItemVM
