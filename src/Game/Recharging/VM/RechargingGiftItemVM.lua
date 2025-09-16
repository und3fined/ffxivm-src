local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local ItemVM = require("Game/Item/ItemVM")
local RechargeRewardCfg = require("TableCfg/RechargeRewardCfg")
local RechargingDefine = require("Game/Recharging/RechargingDefine")
local RechargingMgr = require("Game/Recharging/RechargingMgr")

-- local RewardState = RechargingDefine.RewardState
local RewardItemState = RechargingDefine.RewardItemState

local LSTR = _G.LSTR

---@class RechargingGiftItemVM : UIViewModel
local RechargingGiftItemVM = LuaClass(UIViewModel)

function RechargingGiftItemVM:Ctor()
	self.GiftID = 0
	self.Name = 0
	self.RestAmountToApplyReward = 0
	self.Icon = ""
	self.bIsFirstRecharge = false
	self.bIsSelected = false
	self.bIsSingleItem = false
	self.bIsRestAmount = false
	self.State = RechargingDefine.RewardItemState.Locked
	self.SingleItemVM = nil
	self.ItemVMList = UIBindableList.New(ItemVM)
	self.TextInclude = LSTR(940020)
	self.TextAvailable = LSTR(940021)
end

function RechargingGiftItemVM:OnInit()
end

function RechargingGiftItemVM:OnBegin()
end

function RechargingGiftItemVM:OnEnd()
end

function RechargingGiftItemVM:OnShutdown()
end

function RechargingGiftItemVM:UpdateVM(Value)
	self.GiftID = Value.GiftID
	if nil == self.GiftID then
		return
	end
	local RewardCfgData = RechargeRewardCfg:FindCfg(string.format("ID = %d", self.GiftID))
	if nil == RewardCfgData then
		_G.FLOG_ERROR(string.format("Cannot find reward with ID %d in c_recharge_reward_cfg!"), self.GiftID)
		return
	end
	self.Name = RewardCfgData.Name
	self.Icon = RewardCfgData.Icon
	self.bIsFirstRecharge = self.GiftID == 1

	-- 领取状态
	if RechargingMgr.NextRewardID > 0 and self.GiftID >= RechargingMgr.NextRewardID then
		self.State = RewardItemState.Locked
		if self.GiftID == RechargingMgr.NextRewardID then
			self.bIsRestAmount = true
			self.RestAmountToApplyReward = math.floor(RechargingMgr.RestAmountToApplyReward)
		end
	else
		local bIsGot = nil ~= table.find_item(RechargingMgr.AlreadyGotRewardIDs, self.GiftID)
		self.State = bIsGot and RewardItemState.Got or RewardItemState.Available
	end

	-- 奖品列表
	local ItemVMValues = {}
	local RewardIDList = RewardCfgData.RewardID
	self.bIsSingleItem = nil ~= RewardIDList and #RewardIDList == 1
	if self.bIsSingleItem then
		-- 单个礼物的布局与多个不同
		self.SingleItemVM = ItemVM.New()
		self.SingleItemVM:UpdateVM({ResID = RewardIDList[1], Num = 1})
	else
		for _, RewardID in pairs(RewardIDList) do
			local ItemVMData = {ResID = RewardID, Num = 1}
			table.insert(ItemVMValues, ItemVMData)
		end
		self.ItemVMList:UpdateByValues(ItemVMValues)
	end
end

return RechargingGiftItemVM