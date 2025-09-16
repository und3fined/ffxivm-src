
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")

---@class MailSlotItemViewVM : UIViewModel
local MailSlotItemViewVM = LuaClass(UIViewModel)

---Ctor
function MailSlotItemViewVM:Ctor()
	self.Icon = ""
	self.IsValid = true
	self.NumVisible = true
	self.GID = 0
	self.ResID = 0
	self.Num = 0
	self.ItemNameVisible = false
	self.ItemName = ""
	self.IsQualityVisible = true
	self.IconReceivedVisible = false
	self.IsMask = false
	self.ItemLevelVisible = false
	self.IconChooseVisible = false
end

function MailSlotItemViewVM:OnInit()

end

function MailSlotItemViewVM:OnBegin()

end

function MailSlotItemViewVM:IsEqualVM(Value)
	return true
end

function MailSlotItemViewVM:OnEnd()

end

function MailSlotItemViewVM:OnShutdown()

end

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function MailSlotItemViewVM:UpdateVM(Value, Params)
	local Cfg = ItemCfg:FindCfgByKey(Value.ResID)
	if Cfg ~= nil then
		self.Icon = ItemCfg.GetIconPath(Cfg.IconID)
		self.ItemQualityIcon = ItemUtil.GetItemColorIcon(Value.ResID)
		self.IsQualityVisible = true
		self.NumVisible = Value.NumVisible ~= nil and Value.NumVisible or Cfg.MaxPile ~= 1
		if Value.ItemNameVisible then
			self.ItemName = ItemCfg:GetItemName(Value.ResID)
		end
	else
		self.Icon = ""
		self.ItemName = ""
		self.NumVisible = false
		self.IsQualityVisible = false
	end
	self.IsValid = true
	self.GID = 1
	self.ResID = Value.ResID
	self.Num = ItemUtil.GetItemNumText(Value.Num)
	self.IconReceivedVisible = Value.IconReceivedVisible
	self.IsMask = Value.IsMask
	self.ItemNameVisible = Value.ItemNameVisible
end

return MailSlotItemViewVM