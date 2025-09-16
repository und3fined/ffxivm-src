local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")


local LSTR = _G.LSTR


---@class CompanySealSlot126pxItemVM : UIViewModel
local CompanySealSlot126pxItemVM = LuaClass(UIViewModel)

---Ctor
function CompanySealSlot126pxItemVM:Ctor()
	self.Icon = nil
	self.ImgEmptyVisible = nil
	self.BtnClosureVisible = nil
	self.CurItemID = nil
	self.ItemQualityIcon = nil
	self.Num = nil
	self.NumVisible = nil
	self.Index = nil
	self.IsSelect = false
	self.Times = nil
	self.IsHQ = false
	self.Type = 1
	self.BackpackSlotVisible = true
	self.IsRare = false
	self.IconReceivedVisible = nil
	self.HasItem = nil
	self.NeedNum = nil
	self.IconChooseVisible = false
	self.HideItemLevel = true
	self.IsMask = nil
	self.IsMatch = false --区分任务可提交的情况下不同道具可提交情况
end

function CompanySealSlot126pxItemVM:OnInit()

end

---UpdateVM
---@param List table
function CompanySealSlot126pxItemVM:UpdateVM(List)
	self.IconReceivedVisible = false
	self.IconChooseVisible = false
	self.Index = List.Index
	self.BtnClosureVisible = false
	self.ImgEmptyVisible = false
	self.IsMask = false
	self.State = List.State
	if List.RareReward ~= nil and List.RareReward then
		self.NumVisible = true
		self.BackpackSlotVisible = true
		local IconID = ItemUtil.GetItemIcon(List.ItemID)
		local Path = UIUtil.GetIconPath(IconID)
		self.Icon = Path
		self.CurItemID = List.ItemID
		self.ItemQualityIcon = ItemUtil.GetItemColorIcon(List.ItemID)
		self.Num = _G.ScoreMgr.FormatScore(List.Num)
		return
	elseif List.IsRare ~= nil and List.IsRare then --用于稀有品任务选中
		self.IsRare = List.IsRare
		self.IsSelect = false
		if List.ItemID == nil then
			self.ImgEmptyVisible = true
			self.BackpackSlotVisible = false
			self.NumVisible = false
			self.ItemQualityIcon = nil
		else
			self.ImgEmptyVisible = false
			self.BackpackSlotVisible = true
			local IconID = ItemUtil.GetItemIcon(List.ItemID)
			local Path = UIUtil.GetIconPath(IconID)
			self.Icon = Path
			self.CurItemID = List.ItemID
			self.ItemQualityIcon = ItemUtil.GetItemColorIcon(List.ItemID)
			self.BtnClosureVisible = true
			self.NumVisible = false
		end
		return
	elseif List.IsReward then   --用于军需品补给品奖励栏显示
		self.IsSelect = false
		self.BackpackSlotVisible = true
		self.IsRare = false
		if self.Index == 1 then
			local IconID = ItemUtil.GetItemIcon(19000099)
			local Path = UIUtil.GetIconPath(IconID)
			self.Icon = Path
			self.CurItemID = 19000099
			self.ItemQualityIcon = ItemUtil.GetItemColorIcon(19000099)	
		else
			local ItemID = CompanySealMgr.CompanySealID
			local IconID = ItemUtil.GetItemIcon(ItemID)
			local Path = UIUtil.GetIconPath(IconID)
			self.Icon = Path
			self.CurItemID = ItemID
			self.ItemQualityIcon = ItemUtil.GetItemColorIcon(ItemID)
		end

		if self.State == 6 then
			self.IconReceivedVisible = true
			self.IsMask = true
		else
			self.IconReceivedVisible = false
			self.IsMask = false
		end

		return
	end

	--用于军需品补给品等任务栏显示
	self.IsRare = false
	self.BackpackSlotVisible = true
	self.NumVisible = true
	self.Times = List.Times
	self.IsHQ = List.IsHQ
	self.IsSelect = self.Index == 1
	local IconID = ItemUtil.GetItemIcon(List.ItemID)
	local Path = UIUtil.GetIconPath(IconID)
	self.Icon = Path
	self.CurItemID = List.ItemID
	self.ItemQualityIcon = ItemUtil.GetItemColorIcon(List.ItemID)
	self.Num = ""

	if self.State == 6 then
		self.ImgEmptyVisible = true
		self.IsSelect = false
		self.IsMask = true
	else
		self.ImgEmptyVisible = false
		self.IsMask = false
	end
	self.HasItem = List.HasItem
	self.NeedNum = List.NeedNum

	self:SetNum()
end

function CompanySealSlot126pxItemVM:SetNum()
	if self.HasItem >= self.NeedNum then
		self.Num = string.format("<span color=\"#d5d5d5\">%d/%d</>", self.HasItem, self.NeedNum)
		self.IsMatch = true
	else
		self.Num = string.format("<span color=\"#dc5868\">%d</>/<span color=\"#d5d5d5\">%d</>", self.HasItem, self.NeedNum)
		self.IsMatch = false
	end
end

function CompanySealSlot126pxItemVM:IsEqualVM(Value)
    return true
end


return CompanySealSlot126pxItemVM