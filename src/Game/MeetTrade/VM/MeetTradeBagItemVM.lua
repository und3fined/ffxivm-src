local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")


local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR

---@class MeetTradeBagItemVM : UIViewModel
local MeetTradeBagItemVM = LuaClass(UIViewModel)

---Ctor
function MeetTradeBagItemVM:Ctor()
	self.IsShowNum = true
	self.IsShowLeftCornerFlag = true
	self.Item = nil
	self.IsValid = false
	self.GID = nil
	self.ResID = nil
	self.Num = nil
	self.NumVisible = nil
	self.Name = nil
	self.Icon = nil
	self.ItemType = nil
	self.ItemColor = nil
	self.ItemLevel = nil
	self.IsBind = false
	self.IsUnique = false
	self.IsHQ = false

	self.ItemQualityIcon = nil
	self.IsMask = nil --遮罩显隐
	self.ItemVisible = nil
	self.IsSelect = nil
	self.IsSelectedForTrade = nil
    self.IsShowOtherInfo = false
    self.IsShowDeletButton = nil
	---堆叠上限
	self.MaxPile = 1
end

function MeetTradeBagItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.GID == self.GID
end

function MeetTradeBagItemVM:UpdateVM(Value, Param)
	local IsValid = nil ~= Value and Value.ResID ~= nil
	self.IsValid = IsValid
	self.ItemVisible = IsValid
    ---复用背包Item蓝图，蓝图中存在一些在面对面交易不需要显示的图标，全部默认不显示
    self.IsShowOtherInfo = false
    self.IsShowDeletButton = Value and Value.IsShowDeletButton or false
	if not IsValid then
		self.ResID = nil 
		self.Num = nil
		return
	end

	self:UpdateByParam(Param)
	
	local ValueResID = Value.ResID
	self.Item = Value
	self.GID = Value.GID
	self.IsMask = false
	self.ResID = ValueResID
	self.Num = Value.Num
	local Cfg = ItemCfg:FindCfgByKey(ValueResID)
	if nil == Cfg then
		FLOG_WARNING("ItemVM:UpdateVM can't find item cfg, ResID =%d", ValueResID)
		return
	end

	self.Name =  ItemCfg:GetItemName(ValueResID)
	self.Icon = UIUtil.GetIconPath(Cfg.IconID)

	self.IsBind = Value.IsBind
	self.IsUnique = Cfg.IsUnique > 0
	self.ItemLevel = Cfg.ItemLevel
	self.ItemType = Cfg.ItemType
	self.Classify = Cfg.Classify
	self.MaxPile = Cfg.MaxPile
	self.NumVisible = self.IsShowNum and (Cfg.MaxPile > 1 or self.Num >1)
	self.ItemQualityIcon = ItemUtil.GetItemColorIcon(ValueResID)
	if Cfg.IsCanStore == false or Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
		self.IsMask = true
	end

	--选中标识
	self.IsSelectedForTrade = Value.IsSelectedForTrade
	self.IsSelect = Value.IsSelect
	--设置动画播放参数不检测是否变化
	self.AnimOpticalFeedbackStartAt = 0
	self:SetNoCheckValueChange("AnimOpticalFeedbackStartAt", true)
end


function MeetTradeBagItemVM:UpdateByParam(Param)
	self.IsShowNum = true
	if Param == nil then
		return
	end

	if Param.IsShowNum ~= nil then
		self.IsShowNum = Param.IsShowNum
	end
end

---CheckIsEquipment
---@return boolean 是否装备
function MeetTradeBagItemVM:CheckIsEquipment()
	if self.Classify == nil then
		FLOG_ERROR("ItemVM:CheckIsEquipment ItemVM.Classify == nil ResID = %d", self.ResID)
		return false
	end
	return ItemUtil.CheckIsEquipment(self.Classify)
end

function MeetTradeBagItemVM:SetIsCurSelectItem(IsCurSelectItem)
	self.IsSelect = IsCurSelectItem
end

--改物品是否可堆叠
function MeetTradeBagItemVM:GetIsCanPile()
	return self.MaxPile > 1
end

function MeetTradeBagItemVM:ClickedItemVM()
	
end
return MeetTradeBagItemVM
