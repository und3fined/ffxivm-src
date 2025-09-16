---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local AchievementUtil = require("Game/Achievement/AchievementUtil")
local ItemUtil = require("Utils/ItemUtil")

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
	self.ResID = Value.ResID
	local IsTitle = Value.RewardType == 2
	self.NumVisible = not IsTitle
	self.IsQualityVisible = true
	self.ImgEmptyVisible = self.IsQualityVisible
	self.RewardType = Value.RewardType
	self.Icon = AchievementUtil.GetAwardIconPath(Value.ResID, self.RewardType)
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