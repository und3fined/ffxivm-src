local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyMainVM =  require("Game/Army/VM/ArmyMainVM")
local ArmyMgr = nil

local ArmyDepotPageVM = nil
local ArmyDepotPanelVM = nil

local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")

local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL

---@class ArmyItemTipsVM : UIViewModel
local ArmyItemTipsVM = LuaClass(UIViewModel)

---Ctor
function ArmyItemTipsVM:Ctor()

	self.DepositBtnVisible = nil
	self.TakeBtnVisible = nil

	self.DepositBtnEnabled = nil
	self.TakeBtnEnabled = nil
	self.bPanelBtn = nil

	self.Value = nil
end

---Ctor
function ArmyItemTipsVM:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	ArmyDepotPanelVM = ArmyMainVM:GetDepotPanelVM()
	ArmyDepotPageVM = ArmyDepotPanelVM:GetDepotPageVM()
	self.bPanelBtn = true
end


function ArmyItemTipsVM:UpdateVM(Value, DepotIndex)
	self.Value = Value
	self.DepotIndex = DepotIndex
	local ItemResID = Value.ResID
	local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if Cfg == nil then
		return
	end
	self.DepositBtnVisible = DepotIndex == nil
	self.TakeBtnVisible = DepotIndex ~= nil
	---限时物品判断
	local IsTimeLimitItem =  _G.BagMgr:IsTimeLimitItem(Value)
	self.DepositBtnEnabled = Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY and ArmyDepotPanelVM:IsAvailableCurDepot() and not Value.IsBind and not IsTimeLimitItem
	self.TakeBtnEnabled = Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY and ArmyDepotPanelVM:IsAvailableCurDepot() and not Value.IsBind and not IsTimeLimitItem
	--策划需求，无权限也显示按钮
	self.IsAvailableCurDepot = ArmyDepotPanelVM:IsAvailableCurDepot()
	--self.bPanelBtn = ArmyDepotPanelVM:IsAvailableCurDepot()

end

function ArmyItemTipsVM:GetDepositBtnEnabled()
	return self.DepositBtnEnabled
end

function ArmyItemTipsVM:GetTakeBtnEnabled()
	return self.TakeBtnEnabled
end

function ArmyItemTipsVM:GetIsAvailableCurDepot()
	return self.IsAvailableCurDepot
end

--要返回当前类
return ArmyItemTipsVM