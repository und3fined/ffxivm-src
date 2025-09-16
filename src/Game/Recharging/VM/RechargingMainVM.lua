local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local CommonUtil = require("Utils/CommonUtil")
local ProtoRes = require("Protocol/ProtoRes")

local RechargeCfg = require("TableCfg/RechargeCfg")
local RechargingDefine = require("Game/Recharging/RechargingDefine")
local RechargingTradeItemVM = require("Game/Recharging/VM/RechargingTradeItemVM")

local FLOG_ERROR = _G.FLOG_ERROR
local LSTR = _G.LSTR

---@class RechargingMainVM : UIViewModel
local RechargingMainVM = LuaClass(UIViewModel)

function RechargingMainVM:Ctor()
	self.RewardState = RechargingDefine.RewardState.Exhausted
	self.bIsRewardIcon = false
	self.bIsRewardTips = false
	self.RewardTips = ""
	self.RestAmountToApplyReward = 0
	self.RechargedStall = 0
    self.TradeItemVMList = UIBindableList.New(RechargingTradeItemVM)
	self.TextTitle = LSTR(940017)
	self.TextSubtitle = LSTR(940018)
	self.TextGiftEntry = LSTR(940011)
end

function RechargingMainVM:OnInit()
end

function RechargingMainVM:OnBegin()
end

function RechargingMainVM:OnEnd()
end

function RechargingMainVM:OnShutdown()
end

function RechargingMainVM:GenerateCommodities(CommodityCount)
	if self.TradeItemVMList:Length() == CommodityCount then
		-- 充值档位内容不会改变，无需重复生成
		return
	end

	local TradeItemVMValues = {}
	for DisplayOrder = 1, CommodityCount do
		local Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_NULL
		if CommonUtil.GetPlatformName() == "Android" then
			Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID
		elseif CommonUtil.GetPlatformName() == "IOS" then
			Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_IOS
		end

		local SearchConditions = string.format("DisplayOrder=%d", DisplayOrder)
		if Platform ~= ProtoRes.DevicePlatform.DEVICE_PLATFORM_NULL then
			SearchConditions = string.format("DisplayOrder=%d AND Platform=%d", DisplayOrder, Platform)
		end

		local Data = RechargeCfg:FindCfg(SearchConditions)
		if nil == Data then
			FLOG_ERROR("Condition \"%s\" in c_recharge_cfg not found!", SearchConditions)
		else
			local Value = {Order = DisplayOrder, Icon = Data.Icon, Crystas = Data.Gain, ProductID = Data.ProductID, Bonus = Data.Bonus,
				DoDisplayBonusRate = Data.DoDisplayBonusRate}
			table.insert(TradeItemVMValues, Value)
		end
	end
	
	self.TradeItemVMList:UpdateByValues(TradeItemVMValues)
end

function RechargingMainVM:SwitchRewardState(NewState, RestAmountToApplyReward)
	self.RewardState = NewState

	-- 奖励提示图标
	self.bIsRewardIcon = NewState == RechargingDefine.RewardState.Ready

	-- 奖励提示文字
	self.bIsRewardTips = true
	if NewState == RechargingDefine.RewardState.NotReady and nil ~= RestAmountToApplyReward then
		if RestAmountToApplyReward > RechargingDefine.RewardTipsThreshold then
			self.bIsRewardTips = false
		else
			self.RewardTips = string.format(LSTR(940014), math.ceil(RestAmountToApplyReward))
		end
		self.RestAmountToApplyReward = RestAmountToApplyReward
	elseif NewState == RechargingDefine.RewardState.Ready then
		self.RewardTips = LSTR(940015)
	else
		self.RewardTips = LSTR(940016)
	end
end

function RechargingMainVM:RechargeStall(Stall)
	self.RechargedStall = Stall
end

return RechargingMainVM
