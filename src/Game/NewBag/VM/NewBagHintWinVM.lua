local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local ItemUtil = require("Utils/ItemUtil")

---@class NewBagHintWinVM : UIViewModel
local NewBagHintWinVM = LuaClass(UIViewModel)

---Ctor
function NewBagHintWinVM:Ctor()
    self.BagSlotVM = BagSlotVM.New()
    self.TipsText = nil
    self.NameText = nil
    self.SingleBoxVisible = nil
end

function NewBagHintWinVM:UpdateVM(Value)
    local Item = Value.Item
    if Item ~= nil then
        self.BagSlotVM:UpdateVM(Item, {IsShowNewFlag = false})
        local NumText = Item.NumText
        if NumText then
            self.BagSlotVM:SetTheNumText(NumText)
        end
        self.NameText = ItemUtil.GetItemName(Item.ResID)
    end

    local Message = Value.Message
    if not string.isnilorempty(Message) then
        self.TipsText = Message
    end

    self.SingleBoxVisible = Value.SingleBoxVisible
end



--要返回当前类
return NewBagHintWinVM