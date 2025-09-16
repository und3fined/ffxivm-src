local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local BagMgr = require("Game/Bag/BagMgr")
local BuddyMgr = require("Game/Buddy/BuddyMgr")

local EToggleButtonState = _G.UE.EToggleButtonState

---@class BuddyFeedItemVM : UIViewModel
local BuddyFeedItemVM = LuaClass(UIViewModel)

---Ctor
function BuddyFeedItemVM:Ctor()
	self.ID = nil
	self.LoveImgVisible = nil
	self.ItemVM = ItemVM.New()
	self.Item = nil
end

function BuddyFeedItemVM:UpdateVM(Value)
	if Value == nil then
		return
	end
	
	self.ID = Value.ItemID
	local Num = BagMgr:GetItemNum(Value.ItemID)

	local Item = ItemUtil.CreateItem(Value.ItemID, Num)
	self.ItemVM:UpdateVM(Item, {IsShowNum = true})
	self.Item = Item

	self.ItemVM.IsMask = Num == 0

	self:UpdateFeedItemLove(BuddyMgr:GetBuddyFavFood())
end

function BuddyFeedItemVM:UpdateIconState(ID)
	self.ItemVM[self.ItemVM.SelectMode.Select] = ID  == self.ID 
end

function BuddyFeedItemVM:UpdateFeedItemLove(ItemID)
	self.LoveImgVisible = ItemID == self.Item.ResID
end

function BuddyFeedItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.ItemID == self.ID
end


--要返回当前类
return BuddyFeedItemVM