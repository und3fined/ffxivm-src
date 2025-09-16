local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ScoreCfg = require("TableCfg/ScoreCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local RechargingDefine = require("Game/Recharging/RechargingDefine")
local RechargingRewardItemVM = require("Game/Recharging/VM/RechargingRewardItemVM")

---@class RechargingRewardVM : UIViewModel
local RechargingRewardVM = LuaClass(UIViewModel)

function RechargingRewardVM:Ctor()
	self.ItemVM = RechargingRewardItemVM.New()
	self.Title = ""
	self.Icon = ""
	self.RewardType = RechargingDefine.RewardType.Crystas
	self.RewardTypeStr = RechargingDefine.RewardTypeStrMap[self.RewardType]
	self.IsQuantity = false
	self.Quantity = 0
end

function RechargingRewardVM:OnInit()
end

function RechargingRewardVM:OnBegin()
end

function RechargingRewardVM:OnEnd()
end

function RechargingRewardVM:OnShutdown()
end

--- 更新类型字符串
--- @param Type RechargingDefine.RewardType
--- @param ItemID 道具表ItemID
function RechargingRewardVM:SetType(Type, ItemID)
	self.RewardType = Type
	if nil == ItemID then
		local Data = ScoreCfg:FindCfgByKey(RechargingDefine.CrystaScoreID)
		self.RewardTypeStr = Data.NameText
		self.ItemVM:UpdateVM({IsScore = true, ResID = RechargingDefine.CrystaScoreID, Num = 1})
		-- self.RewardTypeStr = RechargingDefine.RewardTypeStrMap[Type]
	else
		--local Data = ItemCfg:FindCfgByKey(ItemID)
		self.RewardTypeStr = ItemCfg:GetItemName(ItemID)
		self.ItemVM:UpdateVM({IsScore = false, ResID = ItemID, Num = 1})
	end
end

function RechargingRewardVM:SetQuantity(Quantity)
	self.Quantity = Quantity
end

function RechargingRewardVM:SetTitle(Title)
	self.Title = Title
end

function RechargingRewardVM:UpdateVM(Value)
	if nil == Value then
		return
	end

	self.Title = Value.Title
	self.IsQuantity = Value.IsQuantity
	self.Quantity = Value.Quantity
end

return RechargingRewardVM