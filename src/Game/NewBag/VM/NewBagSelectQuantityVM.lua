local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local ItemCfg = require("TableCfg/ItemCfg")
---@class NewBagSelectQuantityVM : UIViewModel
local NewBagSelectQuantityVM = LuaClass(UIViewModel)

---Ctor
function NewBagSelectQuantityVM:Ctor()
    self.BagSlotVM = BagSlotVM.New()
    self.NameText = nil
    
end

function NewBagSelectQuantityVM:UpdateVM(Value)
    self.BagSlotVM:UpdateVM(Value)
    self.NameText = ItemCfg:GetItemName(Value.ResID)
end

--要返回当前类
return NewBagSelectQuantityVM