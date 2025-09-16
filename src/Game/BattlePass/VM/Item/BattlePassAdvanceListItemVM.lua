--
-- Author: ZhengJanChuan
-- Date: 2024-12-25 15:40
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ItemVM = require("Game/Item/ItemVM")
local BattlePassRewardSlotVM = require("Game/BattlePass/VM/Item/BattlePassRewardSlotVM")


---@class BattlePassAdvanceListItemVM : UIViewModel
local BattlePassAdvanceListItemVM = LuaClass(UIViewModel)

---Ctor
function BattlePassAdvanceListItemVM:Ctor()
    self.ResID = nil
    self.ItemName = nil
    self.Num = 0
    self.ItemVM = BattlePassRewardSlotVM.New()
    self.IsGetNow = false
    self.IsPreview = false
    self.IsShowLevel = nil
    self.JumpID = nil
    self.GetLevel = ""
end

function BattlePassAdvanceListItemVM:OnInit()
end

function BattlePassAdvanceListItemVM:OnBegin()
end

function BattlePassAdvanceListItemVM:OnEnd()
end

function BattlePassAdvanceListItemVM:OnShutdown()
end

function BattlePassAdvanceListItemVM:UpdateVM(Value)
    self.ItemName = ItemUtil.GetItemName(Value.ResID)
    self.ResID = Value.ResID
    self.Num  = Value.Num
    self.IsGetNow = Value.IsGetNow
    self.JumpID = Value.JumpID
    self.IsPreview =  Value.JumpID ~= nil or ItemUtil.IsCanPreviewByResID(Value.ResID)
    local ItemVM = {}
    ItemVM.ResID = Value.ResID
    ItemVM.IsShowLevel = Value.IsShowLevel
    ItemVM.Num = Value.Num
    ItemVM.Lv = Value.Level
    -- ItemVM.IsGot = false
    self.ItemVM:UpdateVM(ItemVM)
    -- self.GetLevel = string.format(_G.LSTR(850006), Value.Level)
end


--要返回当前类
return BattlePassAdvanceListItemVM