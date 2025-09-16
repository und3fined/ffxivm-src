local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDepotSlotVM = require("Game/Army/ItemVM/ArmyDepotSlotVM")
local ItemCfg = require("TableCfg/ItemCfg")
---@class ArmySelectQuantityWinVM : UIViewModel
local ArmySelectQuantityWinVM = LuaClass(UIViewModel)

---Ctor
function ArmySelectQuantityWinVM:Ctor()
    self.ArmyDepotSlotVM = ArmyDepotSlotVM.New()
    self.NameText = nil
    
end

function ArmySelectQuantityWinVM:UpdateVM(Value)
    self.ArmyDepotSlotVM:UpdateVM(Value)
    self.NameText = ItemCfg:GetItemName(Value.ResID)
end

--要返回当前类
return ArmySelectQuantityWinVM