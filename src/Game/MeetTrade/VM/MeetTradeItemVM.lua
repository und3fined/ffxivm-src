local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")

local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local BagMgr = _G.BagMgr

---@class MeetTradeItrmVM : UIViewModel
local MeetTradeItrmVM = LuaClass(UIViewModel)

---Ctor
function MeetTradeItrmVM:Ctor()
    self.MeetTradeItemQualityIcon = nil
    self.MeetTradeIcon = nil
    self.IsNew = false
    self.NumText = nil
	self.NumTextVisible = nil
    self.IsSelect = nil
    self.IsRecieived = nil
	self.IsMask = nil --遮罩显隐
    self.IsChosen = nil
    self.GID = nil
	self.ResID = nil
	self.Name = nil
    self.LevelVisible = false
    self.ImgAddOpacity = nil
    self.ItemVisible = nil
	self.OtherInfomation = false
end

function MeetTradeItrmVM:IsEqualVM(Value)
	local ImgAddOpacity = Value.ImgAddOpacity or 0
	return nil ~= Value and Value.GID == self.GID and self.ImgAddOpacity == ImgAddOpacity and self.BtnAddVisible == Value.BtnAddVisible and self.Index == Value.Index
end

function MeetTradeItrmVM:UpdateVM(Value, Param)
	local IsValid = nil ~= Value and Value.ResID ~= nil
	if Value == nil then
		self.ImgAddOpacity = 0
	else
		self.ImgAddOpacity = Value.ImgAddOpacity or 0
	end
	self.ItemVisible = IsValid
	self.BtnAddVisible = Value.BtnAddVisible
	if nil == IsValid or IsValid == false then
		self.ResID = nil
		self.NumText = nil
		return
	end
	local ValueResID = Value.ResID
	self.Item = Value
	self.GID = Value.GID
	self.ResID = ValueResID
	self.NumText = Value.Num
	local Cfg = ItemCfg:FindCfgByKey(ValueResID)
	if nil == Cfg then
		FLOG_WARNING("ItemVM:UpdateVM can't find item cfg, ResID =%d", ValueResID)
		return
	end

	self.Name =  ItemCfg:GetItemName(ValueResID)
	self.MeetTradeIcon = UIUtil.GetIconPath(Cfg.IconID)

	self.IsBind = Value.IsBind
	self.IsUnique = Cfg.IsUnique > 0
	self.ItemType = Cfg.ItemType
	self.Classify = Cfg.Classify

	self.NumTextVisible = (Cfg.MaxPile > 1 or self.NumText >1)
	self.MeetTradeItemQualityIcon = ItemUtil.GetItemColorIcon(ValueResID)
	--选中标识
	self.IsSelect = Value.IsSelect or false
	self.OtherInfomation = Param.OtherInfomation or false
end

function MeetTradeItrmVM:ClickedItemVM()
	if self.IsNew == true then
		BagMgr.NewItemRecord[self.GID] = nil
		self.IsNew = false
		--table.sort(BagMgr.ItemList, BagMgr.SortBagItemPredicate)
		--_G.EventMgr:PostEvent(_G.EventID.BagUpdateNew)
	end
end

function MeetTradeItrmVM:UpdateEquipIsInScheme(Value)
	return ItemUtil.ItemIsInScheme(Value)
end

---CheckIsEquipment
---@return boolean 是否装备
function MeetTradeItrmVM:CheckIsEquipment()
	if self.Classify == nil then
		FLOG_ERROR("ItemVM:CheckIsEquipment ItemVM.Classify == nil ResID = %d", self.ResID)
		return -1
	end
	return ItemUtil.CheckIsEquipment(self.Classify)
end

function MeetTradeItrmVM:SetItemSelected(IsSelected)
	self.IsSelect = IsSelected
end

function MeetTradeItrmVM:SetIsAllowDoubleClick(IsAllowDoubleClick)
	self.IsAllowDoubleClick = IsAllowDoubleClick
end

function MeetTradeItrmVM:SetItemRecoverySelected(IsSelected)
	self.PanelMultiChoiceVisible = IsSelected
end



return MeetTradeItrmVM
