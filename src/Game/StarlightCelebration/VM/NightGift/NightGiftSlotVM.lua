local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local LSTR = _G.LSTR
---@class NightGiftSlotVM : UIViewModel
local NightGiftSlotVM = LuaClass(UIViewModel)

---Ctor
function NightGiftSlotVM:Ctor()
	self.SlotItemVisible = nil
	self.ItemSlotVM = BagSlotVM.New()
end

function NightGiftSlotVM:UpdateVM(Value)
    local IsValid = nil ~= Value and Value.ResID ~= nil
	self.SlotItemVisible  = IsValid
	if not IsValid then
		return
	end

	self.ItemSlotVM:UpdateVM(Value, {IsShowNum = true, IsShowNewFlag = false})
end

function NightGiftSlotVM:IsEqualVM(Value)
	return true
end

--要返回当前类
return NightGiftSlotVM