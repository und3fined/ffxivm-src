---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local AchievementUtil = require("Game/Achievement/AchievementUtil")
local ItemUtil = require("Utils/ItemUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local ProtoRes = require("Protocol/ProtoRes")
local ITEM_COLOR_TYPE = ProtoRes.ITEM_COLOR_TYPE

---@class AchieveCommRewardsSlotVM : UIViewModel
local AchieveCommRewardsSlotVM = LuaClass(UIViewModel)

---Ctor
function AchieveCommRewardsSlotVM:Ctor()
	self.ResID = 0
	self.NumVisible = true
	self.HideItemLevel = true
	self.IsSelect = false
	self.IconReceivedVisible = false
	self.IconChooseVisible = false
	self.IsMask = false
	self.Icon = ""
	self.Num = ""
	self.RewardType = 1
	self.IsQualityVisible = true
	self.ImgEmptyVisible = true
	self.IsMask = false
	self.IconReceivedVisible = false
end

function AchieveCommRewardsSlotVM:OnInit()

end

function AchieveCommRewardsSlotVM:OnBegin()

end

function AchieveCommRewardsSlotVM:IsEqualVM(Value)
	return true
end

function AchieveCommRewardsSlotVM:OnEnd()

end

function AchieveCommRewardsSlotVM:OnShutdown()

end

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function AchieveCommRewardsSlotVM:UpdateVM(Value, Params)
	local IsTitle = Value.RewardType == 2
	if IsTitle then
		self.ResID = nil
		self.TitleID = Value.ResID
	else
		self.ResID = Value.ResID
		self.TitleID = nil
	end
	self.NumVisible = not IsTitle
	self.RewardType = Value.RewardType
	self.Icon = AchievementUtil.GetAwardIconPath(Value.ResID, self.RewardType)
	self.ItemQualityIcon = IsTitle and ItemDefine.Item96SlotColotType[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] or ItemUtil.GetSlotColorIcon(Value.ResID, ItemDefine.ItemSlotType.Item96Slot)
	if self.NumVisible then
		self.Num = ItemUtil.GetItemNumText(Value.Num)
	end
	self:ReceiveAward(Value.Received)
end

function AchieveCommRewardsSlotVM:ReceiveAward(Received)
	self.IsMask = Received
	self.IconReceivedVisible = Received
end

return AchieveCommRewardsSlotVM