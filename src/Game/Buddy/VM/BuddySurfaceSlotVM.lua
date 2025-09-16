local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local BagMgr = require("Game/Bag/BagMgr")
local RichTextUtil = require("Utils/RichTextUtil")

local BuddyMgr
---@class BuddySurfaceSlotVM : UIViewModel
local BuddySurfaceSlotVM = LuaClass(UIViewModel)

---Ctor
function BuddySurfaceSlotVM:Ctor()
	BuddyMgr = _G.BuddyMgr
	self.ItemVM = ItemVM.New()
	self.ImgCheckVisible = nil

	self.ResID = nil
end

function BuddySurfaceSlotVM:UpdateVM(Value, Param)
	self.IsValid = Value ~= nil and Value.ResID ~= nil

	if not self.IsValid then
		self.ItemVM:UpdateVM(Value, Param)
		self.ImgCheckVisible = false
		return
	end

	self.ResID = Value.ResID
	self.Item = ItemUtil.CreateItem(Value.ResID, BagMgr:GetItemNum(Value.ResID))
	
	self.ItemVM:UpdateVM(self.Item, Param)
	self:SetNumProgress(Value.ResID, 0)

	local Armor = BuddyMgr:GetSurfaceArmor()
	if Armor == nil then
		self.ImgCheckVisible = false
		return 
	end

	self.ImgCheckVisible = Value.ResID == Armor.Head or Value.ResID == Armor.Body or Value.ResID == Armor.Feet

	self:ResetSelected()
end

function BuddySurfaceSlotVM:UpdateIconState(ID)
	self.ItemVM[self.ItemVM.SelectMode.Select] = ID == self.ResID
end

function BuddySurfaceSlotVM:ResetSelected()
	self.ItemVM[self.ItemVM.SelectMode.Select] = false
end

function BuddySurfaceSlotVM:SetNumProgress(ID, Value)
	if ID == self.ResID and self.Item then
		local TotalNum = self.Item.Num
		if TotalNum > 0 then
			self.ItemVM.Num = string.format("%d/%d", TotalNum, Value)
		else
			local curNumRichText = RichTextUtil.GetText(string.format("%d", TotalNum), "dc5868", 0, nil)
			self.ItemVM.Num = string.format("%s/%d", curNumRichText, Value)
		end
	end
end

function BuddySurfaceSlotVM:IsEqualVM(Value)
	return nil ~= Value and Value.ResID == self.ResID
end


--要返回当前类
return BuddySurfaceSlotVM