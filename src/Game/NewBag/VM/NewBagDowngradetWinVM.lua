local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local ItemUtil = require("Utils/ItemUtil")
local ItemCfg = require("TableCfg/ItemCfg")

---@class NewBagDowngradetWinVM : UIViewModel
local NewBagDowngradetWinVM = LuaClass(UIViewModel)

---Ctor
function NewBagDowngradetWinVM:Ctor()
    self.IsShowTag = nil
    self.NoConfirm = nil
    self.BagSlotVM1 = BagSlotVM.New()
    self.BagSlotVM2 = BagSlotVM.New()
    self.Name1Text = nil
    self.Name2Text = nil
end

function NewBagDowngradetWinVM:UpdateVM(Value)
    local Item1 = Value.Item
    self.BagSlotVM1:UpdateVM(Item1)
    self.Name1Text = ItemUtil.GetItemName(Item1.ResID)

    local Cfg = ItemCfg:FindCfgByKey(Item1.ResID)
    if Cfg == nil then
        return
    end

    local Item2 = ItemUtil.CreateItem(Cfg.NQHQItemID, Item1.Num)
    self.BagSlotVM2:UpdateVM(Item2)
    self.Name2Text = ItemUtil.GetItemName(Item2.ResID)

end


--要返回当前类
return NewBagDowngradetWinVM