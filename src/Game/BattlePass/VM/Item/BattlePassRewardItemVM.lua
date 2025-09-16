---
---@Author: ZhengJanChuan
---@Date: 2024-01-10 14:37:21
---@Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BattlePassRewardSlotItemVM = require("Game/BattlePass/VM/Item/BattlePassRewardSlotItemVM")
local BattlePassRewardItemVM = LuaClass(UIViewModel)

---Ctor
function BattlePassRewardItemVM:Ctor()
    self.ID = 0
    self.Level = 0
    self.LevelText = ""
    self.CurLevelVisible = false
    self.BaseRewardVisible = true
    self.AdvanceReward1Visible = true
    self.AdvanceReward2Visible = true

    self.GoodRewardItem = BattlePassRewardSlotItemVM.New()
    self.BetterRewardItem = BattlePassRewardSlotItemVM.New()
    self.BestRewardItem = BattlePassRewardSlotItemVM.New()

end

function BattlePassRewardItemVM:OnInit()
end

function BattlePassRewardItemVM:OnBegin()
end

function BattlePassRewardItemVM:OnEnd()
end 

function BattlePassRewardItemVM:OnShutdown()
end

function BattlePassRewardItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.Level = Value.Level
    self.LevelText = string.format(_G.LSTR(850006),Value.Level)
    self.CurLevelVisible = Value.CurLevelVisible
    self.BaseRewardVisible = Value.GoodRewardItem and Value.GoodRewardItem.ID ~= 0
    self.AdvanceReward1Visible = Value.BetterRewardItem and Value.BetterRewardItem.ID ~= 0
    self.AdvanceReward2Visible =  Value.BestRewardItem and Value.BestRewardItem.ID ~= 0

    self.GoodRewardItem = Value.GoodRewardItem
    self.BetterRewardItem = Value.BetterRewardItem
    self.BestRewardItem = Value.BestRewardItem
end


return BattlePassRewardItemVM
