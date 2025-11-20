local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemVM = require("Game/Item/ItemVM")
local LSTR = _G.LSTR
---@class NightGetGiftSlotVM : UIViewModel
local NightGetGiftSlotVM = LuaClass(UIViewModel)

---Ctor
function NightGetGiftSlotVM:Ctor()
	self.ImgTitleVisible = nil
	self.ItemSlotVM = ItemVM.New()
end

function NightGetGiftSlotVM:UpdateVM(Value)
	self.ImgTitleVisible = Value.SystemItem ~= nil
	self.ItemSlotVM:UpdateVM(Value.Item or Value.SystemItem, {IsShowNum = true})
end

function NightGetGiftSlotVM:IsEqualVM(Value)
	return true
end

--要返回当前类
return NightGetGiftSlotVM