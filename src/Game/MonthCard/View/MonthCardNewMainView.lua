---
--- Author: Administrator
--- DateTime: 2024-04-10 10:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MonthCardMgr = require("Game/MonthCard/MonthCardMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local TimeUtil = require("Utils/TimeUtil")
local UIDefine = require("Define/UIDefine")
local MonthCardDefine = require("Game/MonthCard/MonthCardDefine")
local MonthcardGlobalCfg = require("TableCfg/MonthcardGlobalCfg")
local CommBtnColorType = UIDefine.CommBtnColorType
local ReportButtonType = require("Define/ReportButtonType")
local UIViewID = require("Define/UIViewID")

local RechargeCfg = require("TableCfg/RechargeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local CommonUtil = require("Utils/CommonUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemUtil = require("Utils/ItemUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local MonthCardMainPanelVM = require("Game/MonthCard/VM/MonthCardMainPanelVM")

---@class MonthCardNewMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDailyGift CommBtnLView
---@field BtnInfo CommInforBtnView
---@field BtnPurchase CommBtnLView
---@field Comm96Slot CommBackpack96SlotView
---@field CommRewardSlot CommBackpackSlotView
---@field FCanvasPanel1 UFCanvasPanel
---@field FTextBlock UFTextBlock
---@field FTextBlock_2 UFTextBlock
---@field FTextBlock_226 UFTextBlock
---@field FTextBlock_5 UFTextBlock
---@field ImgBg UFImage
---@field MoneyBar CommMoneySlotView
---@field PanelDailyGift UFCanvasPanel
---@field PanelMonthCard UFCanvasPanel
---@field RichTextRemain URichTextBox
---@field RichTextReward URichTextBox
---@field TableViewRewardSlot UTableView
---@field TextAccumulate UFTextBlock
---@field TextCrystalValue UFTextBlock
---@field TextJiaoYi UFTextBlock
---@field TextJingYan UFTextBlock
---@field TextTanWeiShu UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle01 UFTextBlock
---@field TextTitle02 UFTextBlock
---@field TextTitle03 UFTextBlock
---@field TextTopicTitle UFTextBlock
---@field TextZuoQiShuDu UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MonthCardNewMainView = LuaClass(UIView, true)

function MonthCardNewMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDailyGift = nil
	--self.BtnInfo = nil
	--self.BtnPurchase = nil
	--self.Comm96Slot = nil
	--self.CommRewardSlot = nil
	--self.FCanvasPanel1 = nil
	--self.FTextBlock = nil
	--self.FTextBlock_2 = nil
	--self.FTextBlock_226 = nil
	--self.FTextBlock_5 = nil
	--self.ImgBg = nil
	--self.MoneyBar = nil
	--self.PanelDailyGift = nil
	--self.PanelMonthCard = nil
	--self.RichTextRemain = nil
	--self.RichTextReward = nil
	--self.TableViewRewardSlot = nil
	--self.TextAccumulate = nil
	--self.TextCrystalValue = nil
	--self.TextJiaoYi = nil
	--self.TextJingYan = nil
	--self.TextTanWeiShu = nil
	--self.TextTips = nil
	--self.TextTitle01 = nil
	--self.TextTitle02 = nil
	--self.TextTitle03 = nil
	--self.TextTopicTitle = nil
	--self.TextZuoQiShuDu = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MonthCardNewMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnDailyGift)
	self:AddSubView(self.BtnInfo)
	self:AddSubView(self.BtnPurchase)
	self:AddSubView(self.Comm96Slot)
	self:AddSubView(self.CommRewardSlot)
	self:AddSubView(self.MoneyBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MonthCardNewMainView:OnInit()
	self.MonthCardVM = MonthCardMainPanelVM.New()
	self.MonthCardOverdueTimer = nil
	self.MonthCardDataValidTimer = nil

	-- 装备菜单列表
	self.RewardSlotListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRewardSlot, self.OnClickedDailyItem, true)
end

function MonthCardNewMainView:OnDestroy()
	
end

function MonthCardNewMainView:OnShow()
	MonthCardMgr:ResetPaying()
	MonthCardMgr:SendMonthCardDataReq()
	-- self.CommonRedDot2:SetRedDotIDByID(MonthCardDefine.RedDefines.MonthCard)
	self:OnMonthCardUpdate()
	UIUtil.SetIsVisible(self.PanelMonthCard,  _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMonthCard) and _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MONTHLY_CARD))
	UIUtil.SetIsVisible(self.FCanvasPanel1, _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMonthCard) and _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MONTHLY_CARD))
	self.MoneyBar:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS, true, nil, true)

	self.CommRewardSlot:SetClickButtonCallback(self, self.OnClickedItem)

	self:InitText()

	DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.MonthCard), "2")
	self.BtnPurchase.Button.ClickInterval = 1500
end


function MonthCardNewMainView:InitText()
	self.TextTopicTitle:SetText(_G.LSTR(840014))
	self.TextTitle02:SetText(_G.LSTR(840015))
	self.TextTitle01:SetText(_G.LSTR(840016))
	self.TextJiaoYi:SetText(_G.LSTR(840017))
	self.TextJingYan:SetText(_G.LSTR(840018))
	self.TextTanWeiShu:SetText(_G.LSTR(840019))
	self.TextZuoQiShuDu:SetText(_G.LSTR(840020))
	self.TextTitle03:SetText(_G.LSTR(840021))
end

function MonthCardNewMainView:OnClickedItem()
	local CfgReward = MonthcardGlobalCfg:FindCfgByKey(ProtoRes.MonthCardGlobalParamType.MonthCardGlobalExtendReward)
	if  CfgReward == nil then
		return
	end
	local CrystalID =  CfgReward.Value[1]

	ItemTipsUtil.CurrencyTips(CrystalID, false, self.CommRewardSlot, _G.UE4.FVector2D(-70, 0))
end

function  MonthCardNewMainView:OnClickedDailyItem(Index, ItemData, ItemView, bByClick)
	if ItemData and ItemData.ResID then
		local ItemID = ItemData.ResID
		if ItemUtil.ItemIsScore(ItemID) then
			ItemTipsUtil.CurrencyTips(ItemID, false, ItemView, _G.UE4.FVector2D(-30, 0))
		else	
			ItemTipsUtil.ShowTipsByResID(ItemID, ItemView, _G.UE4.FVector2D(-30, 0))
		end
	end
end

function MonthCardNewMainView:OnHide()
	if self.MonthCardOverdueTimer ~= nil then
		self:UnRegisterTimer(self.MonthCardOverdueTimer)
		self.MonthCardOverdueTimer = nil
	end
	if self.MonthCardDataValidTimer ~= nil then
		self:UnRegisterTimer(self.MonthCardDataValidTimer)
		self.MonthCardDataValidTimer = nil
	end

	_G.EventMgr:SendEvent(_G.EventID.MonthCardUIClose)

	DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.MonthCard), "3")

	MonthCardMgr:ResetPaying()
end

function MonthCardNewMainView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnPurchase, self.OnClickedPurchase)
	UIUtil.AddOnClickedEvent(self, self.BtnDailyGift, self.OnClickedDailyGift)
end

function MonthCardNewMainView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MonthCardUpdate, self.OnMonthCardUpdate)
end

function MonthCardNewMainView:OnRegisterBinder()
	local Binders = {
		{ "DailyRewardList",  UIBinderUpdateBindableList.New(self, self.RewardSlotListAdapter)},
		{ "TotalTips", UIBinderSetText.New(self, self.RichTextReward)},
		{ "MonthCardAwardNum", UIBinderSetText.New(self, self.TextCrystalValue) },
		{ "MaxTips", UIBinderSetText.New(self, self.TextTips) },
		{ "PlayerAddedupNum", UIBinderSetText.New(self, self.TextAccumulate) },
		{ "PlayerAddedupVisible", UIBinderSetIsVisible.New(self, self.TextAccumulate)},
		{ "MonthCardRemainDays", UIBinderSetText.New(self, self.RichTextRemain) },
		{ "MonthCardVaildVisible", UIBinderSetIsVisible.New(self, self.RichTextRemain)},
		{ "BtnDailyGiftVisible", UIBinderSetIsVisible.New(self, self.BtnDailyGift)},


		{ "PaytTax", UIBinderSetText.New(self, self.FTextBlock_226) },
		{ "Exp", UIBinderSetText.New(self, self.FTextBlock) },
		{ "StallNum", UIBinderSetText.New(self, self.FTextBlock_2) },
		{ "MountSpeed", UIBinderSetText.New(self, self.FTextBlock_5) },
		{ "TotalValue", UIBinderSetText.New(self, self.FTextBlock_156)},

		


	}

	self:RegisterBinders(self.MonthCardVM, Binders)
	self.CommRewardSlot:SetParams({Data = self.MonthCardVM.GainItemVM})
end

function MonthCardNewMainView:StartMonthCardTimer()
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

function MonthCardNewMainView:OnMonthCardDataValid()
	local Time = TimeUtil.GetServerLogicTime()
	if Time > MonthCardMgr:GetDataValidTime() then
		MonthCardMgr:SendMonthCardDataReq()
		self:UnRegisterTimer(self.MonthCardDataValidTimer)
	end
end

function MonthCardNewMainView:OnMonthCardOverdue()
	local Time = TimeUtil.GetServerLogicTime()
	if Time > MonthCardMgr:GetMonthCardValidTime() then
		MonthCardMgr:SendMonthCardDataReq()
		self:UnRegisterTimer(self.MonthCardOverdueTimer)
	end
end

-- 点击购买, 调用直购逻辑
function MonthCardNewMainView:OnClickedPurchase()
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
function MonthCardNewMainView:GetCardByVouchers()
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
				CostInfo = math.ceil(VouchersNum)
			}
			UIViewMgr:ShowView(_G.UIViewID.RechargingVoucherWin,Params)
		end
	end
end

-- 点击领取日常奖励
function MonthCardNewMainView:OnClickedDailyGift()
	MonthCardMgr:SendGetMonthCardDayRewardReq()
end

-- 刷新月卡数据
function MonthCardNewMainView:OnMonthCardUpdate()
	self.MonthCardVM:Refresh()

	if MonthCardMgr:GetMonthCardReward() then
		-- self.BtnDailyGift:SetColorType(CommBtnColorType.Recommend)
		-- self.BtnDailyGift.TextContent.Font.OutlineSettings.OutlineSize = 2
		self.BtnDailyGift:SetIsRecommendState(true)
		self.BtnDailyGift:SetText(_G.LSTR(840001)) ---领取奖励
		
	else
		-- self.BtnDailyGift:SetColorType(CommBtnColorType.Disable)
		self.BtnDailyGift:SetIsDoneState(true,_G.LSTR(840002))
		-- self.BtnDailyGift.TextContent.Font.OutlineSettings.OutlineSize = 0
		self.BtnDailyGift:SetText(_G.LSTR(840002)) ---今日已领取
	end

	local Str1 = string.format(_G.LSTR(840003))--- ￥30   开通30天
	local Str2 = string.format(_G.LSTR(840004)) --- ￥30   再续30天
	self.BtnPurchase:SetText(MonthCardMgr:GetMonthCardStatus() and Str2 or Str1)

	self:StartMonthCardTimer()
end

return MonthCardNewMainView