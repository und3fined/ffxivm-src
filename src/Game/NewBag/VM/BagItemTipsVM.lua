local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemDefine = require("Game/Item/ItemDefine")

local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL

---@class BagItemTipsVM : UIViewModel
local BagItemTipsVM = LuaClass(UIViewModel)

---Ctor
function BagItemTipsVM:Ctor()
	self.DepositBtnVisible = nil
	self.TakeBtnVisible = nil

	self.DepositBtnEnabled = nil
	self.TakeBtnEnabled = nil

	self.Value = nil
end

function BagItemTipsVM:UpdateVM(Value, DepotIndex)
	self.Value = Value
	self.DepotIndex = DepotIndex
	local ItemResID = Value.ResID
	local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if Cfg == nil then
		return
	end
	self.DepositBtnVisible = DepotIndex == nil
	self.TakeBtnVisible = DepotIndex ~= nil

	self.DepositBtnEnabled = Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY or Cfg.IsCanStore == false
	self.TakeBtnEnabled = Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY or Cfg.IsCanStore == false
end

--要返回当前类
return BagItemTipsVM