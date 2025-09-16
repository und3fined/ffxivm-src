local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local TimeUtil = require("Utils/TimeUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")

local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local BagMgr

---@class QuestRewardItemVM : UIViewModel
local QuestRewardItemVM = LuaClass(UIViewModel)

---Ctor
function QuestRewardItemVM:Ctor()
	BagMgr = _G.BagMgr

	self.Item = nil
	self.IsValid = false

	self.GID = nil
	self.ResID = nil
	self.Num = nil
	self.ItemNum = nil
	self.NumVisible = nil

	self.Name = nil
	self.Icon = nil

	self.IconChooseVisible = false

	self.ItemType = nil
	self.ItemColor = nil
	self.ItemLevel = nil

	self.ItemQualityIcon = nil
end

function QuestRewardItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.GID == self.GID
end

function QuestRewardItemVM:UpdateVM(Value, Param)
	local IsValid = nil ~= Value and Value.ResID ~= nil
	self.IsValid = IsValid
	self.PanelBagVisible = IsValid
	if not IsValid then
		self.ResID = nil
		self.Num = nil
		return
	end

	local ValueResID = Value.ResID
	self.Item = Value
	self.GID = Value.GID
	self.IsMask = false
	if ValueResID ~= self.ResID then
		self.ResID = ValueResID

		local Cfg = ItemCfg:FindCfgByKey(ValueResID)
		if nil == Cfg then
			FLOG_WARNING("QuestRewardItemVM:UpdateVM can't find item cfg, ResID =%d", ValueResID)
			return
		end

		self.Name =  ItemCfg:GetItemName(ValueResID)
		self.Icon = UIUtil.GetIconPath(Cfg.IconID)

		self.ItemType = Cfg.ItemType

		self.NumVisible = Cfg.MaxPile > 1 or Value.Num > 1
		self.ItemQualityIcon = ItemUtil.GetItemColorIcon(ValueResID)
	end
	self.Num = Value.Num
	self.ItemNum = Value.Num

	self.IsSelect = false
end

function QuestRewardItemVM:ClickedItemVM()
	if self.IsNew == true then
		BagMgr.NewItemRecord[self.GID] = nil
		self.IsNew = false

		--table.sort(BagMgr.ItemList, BagMgr.SortBagItemPredicate)
		--_G.EventMgr:PostEvent(_G.EventID.BagUpdateNew)
	end
end

function QuestRewardItemVM:SetItemSelected(IsSelected)
	self.IsSelect = IsSelected
end

return QuestRewardItemVM