local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local UIBindableList = require("UI/UIBindableList")

---@class NewBagRecycleWinVM : UIViewModel
local NewBagRecycleWinVM = LuaClass(UIViewModel)

---Ctor
function NewBagRecycleWinVM:Ctor()
    self.MultiTableBindableList = UIBindableList.New(BagSlotVM, {IsShowCanRecovery = true})
    self.SingleTableBindableList = UIBindableList.New(BagSlotVM, {IsShowCanRecovery = true})
    self.TipsText = nil
    self.MultiItemVisible = nil
    self.SingleItemVisible = nil
end

function NewBagRecycleWinVM:UpdateVM(Value)
    local Message = Value.Message
    if not string.isnilorempty(Message) then
        self.TipsText = Message
    end

    local MultiItemList = Value.MultiItemList
    self.MultiItemVisible = MultiItemList ~= nil
    if MultiItemList ~= nil then
        self.MultiTableBindableList:UpdateByValues(MultiItemList)
    end
    
    local SingleItemList = Value.SingleItemList
    self.SingleItemVisible = SingleItemList ~= nil
    if SingleItemList ~= nil then
        self.SingleTableBindableList:UpdateByValues(SingleItemList)
    end
end

--要返回当前类
return NewBagRecycleWinVM