local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeRewardType = ProtoRes.Game.ActivityNodeRewardType
local ProtoCS = require("Protocol/ProtoCS")
local ItemDefine = require("Game/Item/ItemDefine")

---@class OpsTeamUpRewardItemVM : UIViewModel
local OpsTeamUpRewardItemVM = LuaClass(UIViewModel)

---Ctor
function OpsTeamUpRewardItemVM:Ctor()
    self.key = nil
    self.Icon = nil
    self.ItemQualityIcon = nil
    self.Num = nil
    self.ResID = nil
    self.HideItemLevel = true
	self.IconChooseVisible = nil
end

function OpsTeamUpRewardItemVM:UpdateVM(Params)
    if Params then
        self.ResID = Params.ItemID
        self.key = Params.ItemID
        self.ItemType = Params.Type
        self.Num = Params.Num
        self.ItemQualityIcon = ItemUtil.GetSlotColorIcon(self.ResID, ItemDefine.ItemSlotType.Item96Slot)
		self.BtnCheckVisible = ItemUtil.IsCanPreviewByResID(self.ResID)
        if self.ItemType == ActivityNodeRewardType.ActivityNodeRewardTypeItem then
			--道具
			self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(self.ResID))
		elseif self.ItemType == ActivityNodeRewardType.ActivityNodeRewardTypeScore then
			--货币
			self.Icon = _G.ScoreMgr:GetScoreIconName(self.ResID)
			self.Num = _G.ScoreMgr.FormatScore(self.Num)
		elseif self.ItemType == ActivityNodeRewardType.ActivityNodeRewardTypeLoot then
			--掉落(掉落配置有多个item,只显示第一个做容错处理)
			local RewardItemList = ItemUtil.GetLootItems(self.ResID)	
			if RewardItemList and #RewardItemList > 0 then
				self.ResID = RewardItemList[1].ResID
				if RewardItemList[1].IsScore then
					self.Icon = _G.ScoreMgr:GetScoreIconName(self.ResID)
				else
					self.Icon = ItemUtil.GetItemIcon(self.ResID)
				end
				self.Num = RewardItemList[1].Num
			end
		end
    end
end

function OpsTeamUpRewardItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ResID == self.ResID
end

function OpsTeamUpRewardItemVM:GetResID()
	return self.ResID
end

return OpsTeamUpRewardItemVM