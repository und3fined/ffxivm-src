---
--- Author: ZhengJanChuan
--- DateTime: 2023-11-30 20:34
--- Description: 福利界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local MonthCardMgr = require("Game/MonthCard/MonthCardMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local TimeUtil = require("Utils/TimeUtil")
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType

local RechargeCfg = require("TableCfg/RechargeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local CommonUtil = require("Utils/CommonUtil")
local MonthCardMainPanelVM = require("Game/MonthCard/VM/MonthCardMainPanelVM")

local TabIndex = {
	BP = 1,
	MonthCard = 2,
}


local MainTabs = {
    -- {
    --     Index = TabIndex.BP,
    --     PageName = _G.LSTR("战令"),
    -- },
    {
        Index = TabIndex.MonthCard,
        PageName = _G.LSTR("月卡"),
		LockedIndex = ProtoCommon.ModuleID.ModuleIDMonthCard,
    },
}

---@class MonthCardMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnDailyGift CommBtnSView
---@field BtnInfo CommInforBtnView
---@field BtnPurchase UFButton
---@field ImgBg UFImage
---@field ImgCrystallBall2 UFImage
---@field ImgFeather UFImage
---@field Menu CommMenuView
---@field PanelMonthCard UFCanvasPanel
---@field RichTextDescription1 URichTextBox
---@field RichTextDescription2 URichTextBox
---@field RichTextRemain URichTextBox
---@field TextAccumulate UFTextBlock
---@field TextCrystalValue UFTextBlock
---@field TextDailyCrystal UFTextBlock
---@field TextDailyFeather UFTextBlock
---@field TextDailyGift UFTextBlock
---@field TextDiscountValue UFTextBlock
---@field TextEffective UFTextBlock
---@field TextPrice UFTextBlock
---@field TextStallValue UFTextBlock
---@field TextTips UFTextBlock
---@field TextTopicTitle UFTextBlock
---@field TextWorthValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MonthCardMainPanelView = LuaClass(UIView, true)

function MonthCardMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnDailyGift = nil
	--self.BtnInfo = nil
	--self.BtnPurchase = nil
	--self.ImgBg = nil
	--self.ImgCrystallBall2 = nil
	--self.ImgFeather = nil
	--self.Menu = nil
	--self.PanelMonthCard = nil
	--self.RichTextDescription1 = nil
	--self.RichTextDescription2 = nil
	--self.RichTextRemain = nil
	--self.TextAccumulate = nil
	--self.TextCrystalValue = nil
	--self.TextDailyCrystal = nil
	--self.TextDailyFeather = nil
	--self.TextDailyGift = nil
	--self.TextDiscountValue = nil
	--self.TextEffective = nil
	--self.TextPrice = nil
	--self.TextStallValue = nil
	--self.TextTips = nil
	--self.TextTopicTitle = nil
	--self.TextWorthValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MonthCardMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnDailyGift)
	self:AddSubView(self.BtnInfo)
	self:AddSubView(self.Menu)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MonthCardMainPanelView:OnInit()
	self.MonthCardVM = MonthCardMainPanelVM.New()
	self.MonthCardOverdueTimer = nil
	self.MonthCardDataValidTimer = nil
end

function MonthCardMainPanelView:OnDestroy()
	if self.MonthCardOverdueTimer ~= nil then
		self:UnRegisterTimer(self.MonthCardOverdueTimer)
		self.MonthCardOverdueTimer = nil
	end
	if self.MonthCardDataValidTimer ~= nil then
		self:UnRegisterTimer(self.MonthCardDataValidTimer)
		self.MonthCardDataValidTimer = nil
	end
end

function MonthCardMainPanelView:OnShow()

	self.IsTest = false

	self.Tabs = {}
	for _, v in ipairs(MainTabs) do
		if v.LockedIndex == nil or _G.ModuleOpenMgr:CheckOpenState(v.LockedIndex) then
			table.insert(self.Tabs, {Key = v.Index, Name = v.PageName})
		end
	end

	self.Menu:UpdateItems(self.Tabs, false)

	-- 判断哪个标签能获得奖励 切换到哪个标签
	self:CheckTabReward()
	MonthCardMgr:SendMonthCardDataReq()
	self.MonthCardVM:Refresh()
	UIUtil.SetIsVisible(self.PanelMonthCard, _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMonthCard))

end

function MonthCardMainPanelView:OnHide()
end

function MonthCardMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.Menu, self.OnSelectionChangedCommMenu)
	UIUtil.AddOnClickedEvent(self, self.BtnPurchase, self.OnClickedPurchase)
	UIUtil.AddOnClickedEvent(self, self.BtnDailyGift, self.OnClickedDailyGift)
end

function MonthCardMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MonthCardUpdate, self.OnMonthCardUpdate)
end

function MonthCardMainPanelView:OnRegisterBinder()
	local Binders = {
		{ "TotalValue", UIBinderSetText.New(self, self.TextWorthValue) },
		{ "ShopDiscount", UIBinderSetText.New(self, self.TextDiscountValue) },
		{ "ShopNum", UIBinderSetText.New(self, self.TextStallValue) },
		{ "AddupCrystalNum", UIBinderSetText.New(self, self.TextDailyCrystal) },
		{ "AddupGiftNum", UIBinderSetText.New(self, self.TextDailyFeather) },
		{ "MonthCardAwardNum", UIBinderSetText.New(self, self.TextCrystalValue) },
		{ "MonthCardMaxAddupTxt", UIBinderSetText.New(self, self.TextTips) },
		{ "PlayerAddedupNum", UIBinderSetText.New(self, self.TextAccumulate) },
		{ "MonthCardRemainDays", UIBinderSetText.New(self, self.RichTextRemain) },
		{ "MonthCardVaildVisible", UIBinderSetIsVisible.New(self, self.RichTextRemain)},
		{ "BtnDailyGiftVisible", UIBinderSetIsVisible.New(self, self.BtnDailyGift)},
		{ "ShopDiscountDesc", UIBinderSetText.New(self, self.RichTextDescription1)},
		{ "MonthCardVaildVisible", UIBinderSetIsVisible.New(self, self.TextEffective)},
		{ "PlayerAddedupVisible", UIBinderSetIsVisible.New(self, self.TextAccumulate)},
		{ "TextPrice", UIBinderSetText.New(self, self.TextPrice)},
		{ "ImgFeather", UIBinderSetImageBrush.New(self, self.ImgFeather)},
		{ "RichTextDescription2", UIBinderSetText.New(self, self.RichTextDescription2)},
		--{ "BtnDailyGiftDone", UIBinderSetIsDone.New(self, self.BtnDailyGift)},
		--{ "BtnDailyGiftState", UIBinderCommBtnUpdateImage.New(self, self.BtnDailyGift)},
	}

	self:RegisterBinders(self.MonthCardVM, Binders)
end

function MonthCardMainPanelView:CheckTabReward()
	local DefaultKey = TabIndex.MonthCard
	local ConditionTable = {
		---[TabIndex.BP] = function () return false end,
		[TabIndex.MonthCard] = MonthCardMgr:GetMonthCardReward(),
	}
	local RewardTable = {}

	-- 判断是否有奖励，暂时只有月卡
	for index, v in pairs(MainTabs) do
		if ConditionTable[index] and (v.LockedIndex == nil or _G.ModuleOpenMgr:CheckOpenState(v.LockedIndex)) then
			table.insert(RewardTable, index)
		end
	end

	DefaultKey = #RewardTable > 0 and RewardTable[1] or DefaultKey
	self.Menu:SetSelectedKey(DefaultKey, true)
end

function MonthCardMainPanelView:OnSelectionChangedCommMenu(Index, ItemData, ItemView)

	local Key = ItemData:GetKey()

	UIUtil.SetIsVisible(self.PanelMonthCard, false)
	
	if Key == TabIndex.BP then
		
	elseif Key == TabIndex.MonthCard then
		UIUtil.SetIsVisible(self.PanelMonthCard, true)
		self.MonthCardVM:Refresh()
	end

end

function MonthCardMainPanelView:StartMonthCardTimer()
	if self.MonthCardOverdueTimer ~= nil then
		self:UnRegisterTimer(self.MonthCardOverdueTimer)
		self.MonthCardOverdueTimer = nil
	end

	if MonthCardMgr:GetMonthCardStatus() then
		-- 月卡过期问题
		self.MonthCardOverdueTimer = self:RegisterTimer(self.OnMonthCardOverdue, 0, 1, 1)
	end

	if self.MonthCardDataValidTimer ~= nil then
		self:UnRegisterTimer(self.MonthCardDataValidTimer)
		self.MonthCardDataValidTimer = nil
	end

	-- 月卡数据超时刷新
	if MonthCardMgr:GetDataValidTime() > 0 then
		self.MonthCardDataValidTimer = self:RegisterTimer(self.OnMonthCardDataValid, 0, 1, 1)
	end

end

function MonthCardMainPanelView:OnMonthCardDataValid()
	local Time = TimeUtil.GetServerTime()
	if Time > MonthCardMgr:GetDataValidTime() then
		MonthCardMgr:SendMonthCardDataReq()
		self:UnRegisterTimer(self.MonthCardDataValidTimer)
	end
end

function MonthCardMainPanelView:OnMonthCardOverdue()
	local Time = TimeUtil.GetServerTime()
	if Time > MonthCardMgr:GetMonthCardValidTime() then
		MonthCardMgr:SendMonthCardDataReq()
		self:UnRegisterTimer(self.MonthCardOverdueTimer)
	end
end

-- 点击购买, 调用直购逻辑
function MonthCardMainPanelView:OnClickedPurchase()
	local RechargingMgr = require("Game/Recharging/RechargingMgr")
	if RechargingMgr:CheckCanUseVoucher() then
		self:GetCardByVouchers()
	else
		-- local Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_NULL
		local Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID
		local Type = ProtoRes.RechargeType.RECHARGE_TYPE_MONTH_CARD
		local CountryType = ProtoRes.Purchase_Country_Type.COUNTRY_TYPE_CN
		if CommonUtil.GetPlatformName() == "Android" then
			Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID

		elseif CommonUtil.GetPlatformName() == "IOS" then
			Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_IOS
		else
			_G.FLOG_ERROR("Platform is Null!")
			return
		end

		local Data = RechargeCfg:FindAllCfg(string.format("Type == %d AND Platform == %d",Type, Platform))
		if Data == nil then
			_G.FLOG_ERROR("Condition \"%s\" in c_recharge_cfg not found!")
			return
		end

		if not table.empty(Data) then
			MonthCardMgr:BuyMonthCard(Data[1].DisplayOrder, Data[1].Fund, Data[1].Bonus, self)
		end

	end
end

---代金券购买
function MonthCardMainPanelView:GetCardByVouchers()
	local UIViewMgr = require("UI/UIViewMgr")
	local RechargingMgr = require("Game/Recharging/RechargingMgr")
	local ProtoRes = require("Protocol/ProtoRes")
	local VouchersCfg = require("TableCfg/RechargeCfg")
	local ExchangeRateCfg = require("TableCfg/MultiNationalVouchersCfg")
	--获取登录平台
	local Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID
	if CommonUtil.GetPlatformName() == "Android" then
		Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID
	elseif CommonUtil.GetPlatformName() == "IOS" then
		Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_IOS
	end
	local CountryType = ProtoRes.Purchase_Country_Type.COUNTRY_TYPE_CN
	local PurchaseType = ProtoRes.RechargeType.RECHARGE_TYPE_MONTH_CARD
	local CurrentExchangeCfg = ExchangeRateCfg:FindAllCfg(string.format("Country = %d", CountryType))
	local CurrentVouchersCfg = VouchersCfg:FindAllCfg(string.format("Type = %d and Platform = %d", PurchaseType, Platform))
	--双条件查找判空
	if CurrentVouchersCfg and next(CurrentVouchersCfg) and CurrentExchangeCfg and next(CurrentExchangeCfg) then
		local CostCoin = tonumber(CurrentVouchersCfg[1].Gain / 100)
		local ExchangeRate = tonumber(CurrentExchangeCfg[1].Value[1])
		local ProductID = CurrentVouchersCfg[1].ProductID
		--这里需要判断下除数被除数合法
		if CostCoin and ExchangeRate and CostCoin > 0 and ExchangeRate > 0 then
			--获取所需要代金券数量
			local VouchersNum = CostCoin / ExchangeRate
			local IsEnough = RechargingMgr:CheckVoucherIsEnough(VouchersNum)
			--代金券不足弹tips退出流程
			if not IsEnough then return end
			local Params = {
				ProductID = ProductID,
				CostInfo =  math.ceil(VouchersNum)
			}
			UIViewMgr:ShowView(UIViewID.RechargingVoucherWin,Params)
		end
	end
end

-- 点击领取日常奖励
function MonthCardMainPanelView:OnClickedDailyGift()
	MonthCardMgr:SendGetMonthCardDayRewardReq()
end

-- 刷新月卡数据
function MonthCardMainPanelView:OnMonthCardUpdate()
	self.MonthCardVM:Refresh()

	if MonthCardMgr:GetMonthCardReward() then
		self.BtnDailyGift:SetColorType(CommBtnColorType.Recommend)
		self.BtnDailyGift:SetText(_G.LSTR("领取奖励"))
	else
		self.BtnDailyGift:SetColorType(CommBtnColorType.Done)
		self.BtnDailyGift:SetText(_G.LSTR("今日已领取"))
	end

	self:StartMonthCardTimer()

end



return MonthCardMainPanelView