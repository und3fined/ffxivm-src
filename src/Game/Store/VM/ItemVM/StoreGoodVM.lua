---
---@author Lucas
---DateTime: 2023-05-6 14:20:00
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreMgr = require("Game/Score/ScoreMgr")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local MathUtil = require("Utils/MathUtil")
local StoreMgr = require("Game/Store/StoreMgr")
local StoreDefine = require("Game/Store/StoreDefine")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")
local StoreUtil = require("Game/Store/StoreUtil")

local StoreMall = ProtoRes.StoreMall
local FLOG_WARNING = _G.FLOG_WARNING
local LSTR =_G.LSTR

---@class StoreGoodVM: UIViewModel
---@field ItemNameText string @商品名称
---@field GoodBg string @商品背景
---@field GoodIcon string @商品图标
---@field bGoodBgVisible bool @是否显示商品背景
---@field bGoodIconVisible bool @是否显示商品图标
---@field StateTextVisible bool @是否显示售罄
---@field HorizontalPriceVisible bool @是否显示水晶数量
---@field OriginalPanelVisible bool @是否显示折扣价格
---@field HotSaleVisible bool @是否显示热卖
---@field PanelOriginalVisible bool @是否显示折扣
---@field PanelDiscountVisible bool @是否显示限时
---@field DiscountPanelVisible bool @是否显示折扣
---@field DeadlinePanelVisible bool @是否显示限时
---@field LimitationVisible bool @是否显示限购
---@field GoodStateText string @商品状态文本
---@field SaleRuleText string @商品活动规则
---@field LimitationText string @限购提示文本       每日/每周
---@field AmountText string @限购提示文本           限购1/1
---@field OriginalPriceText string @折扣价格文本
---@field CrystalText string @水晶数量文本
---@field DiscountText string @折扣文本
---@field TimeSaleText string @限时文本
---
---@field ItemIndex number @索引
local StoreGoodVM = LuaClass(UIViewModel)

function StoreGoodVM:Ctor()
	self.GoodID = 0
    self.ItemNameText = ""
    self.GoodBg = ""
    self.GoodIcon = ""
    self.bGoodBgVisible = false
    self.bGoodIconVisible = false
    self.StateTextVisible = false
    self.HorizontalPriceVisible = false
    self.OriginalPanelVisible = false
    self.HotSaleVisible = false
    self.PanelOriginalVisible = false
	self.DiscountPanelVisible = false
	self.DeadlinePanelVisible = false
	self.IsShowTimeSaleIcon = true
    -- self.PanelDiscountVisible = false
    -- self.LimitationVisible = false
    self.GoodStateText = ""
    self.SaleRuleText = ""
    -- self.LimitationText = ""
    -- self.AmountText = ""
    self.OriginalPriceText = ""
    self.CrystalText = ""
    self.DiscountText = ""
    self.TimeSaleText = ""
    self.bSelected = false
    self.ItemIndex = 0
    self.KerWordStr = nil
	self.IsBringEuip = false
	--- 已拥有 绿色 89bd88   其他  红色 #DD5667FF
	-- self.SoldOutStateColor = "#DD5667FF"
	self.GenderLimit = 0
	self.IsOwned = false
	self.bHasCoupon = false
	self.Items = nil
	self.LabelMain = nil
	self.CouponNum = 0
	self.VideoPath = ""
end

function StoreGoodVM:IsEqualVM(Value)
    if Value == nil then
        return false
    end
    
    local GoodData = Value.GoodData
    local CurrentTime = TimeUtil.GetServerTime()

	local OffTime = StoreMgr:GetTimeInfo(GoodData.OffTime)

    if OffTime and CurrentTime > OffTime then
        return false
    end

    return true
end

function StoreGoodVM:UpdateVM(Value, Params)
    if Value == nil then
        FLOG_WARNING("StoreGoodVM:InitVM Value is nil")
        return
    end
	--- 发型盲盒 ProtoRes.StoreMall.STORE_MALL_MYSTERYBOX
    self.bSelected = false
    self.ItemIndex = Value.ItemIndex or 0
	if nil == Value.GoodData then
		return
	end
    local GoodCfgData = Value.GoodData.Cfg
	if nil == GoodCfgData then
		return
	end
	self.Type = GoodCfgData.Type
	self.GoodID = GoodCfgData.ID
	self.VideoPath = GoodCfgData.VideoPath
	self.Items = GoodCfgData.Items
	self.LabelMain = GoodCfgData.LabelMain
	local Discount = GoodCfgData.Discount
	self.GenderLimit = GoodCfgData.GenderLimit
    self.ItemNameText = GoodCfgData.Name
    self:UpdateIcon(GoodCfgData.Icon, GoodCfgData.Background)
    local CurrentTime = TimeUtil.GetServerTime()
	local DiscountStart = StoreMgr:GetTimeInfo(GoodCfgData.DiscountDurationStart)
	local DiscountEnd = StoreMgr:GetTimeInfo(GoodCfgData.DiscountDurationEnd)
    self.PanelOriginalVisible = false
	self.DiscountPanelVisible = false
    self.HotSaleVisible = false
    self.DeadlinePanelVisible = false
	local IsCan, CanNotReason = StoreMgr:IsCanBuy(GoodCfgData.ID)
    local bIsDuringSaleTime = StoreMgr:IsDuringSaleTime(GoodCfgData)
	if not IsCan and _G.StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
		self.HorizontalPriceVisible = false
		self.StateTextVisible = true
		self.GoodStateText = CanNotReason
		self.IsOwned = CanNotReason == LSTR(StoreDefine.SecondScreenType.Owned)
		self.SoldOutStateColor = self.IsOwned and "#89bd88" or "#DD5667FF"

        if _G.StoreMainVM.CurrentSelectedTabType == ProtoRes.StoreMall.STORE_MALL_MYSTERYBOX then
            self:UpdateDiscount(Discount, 1, bIsDuringSaleTime)
        end
	else
		self.IsOwned = false
		--- 没配置限制时间或在限制时间内
		

		self:UpdateDiscount(Discount, GoodCfgData.ShowDiscount, bIsDuringSaleTime)
		--- Params {IsCalculateDisCount} 为true时才计算折扣   否则只显示原价
		self:UpdatePrice(GoodCfgData, Params)
		if GoodCfgData.AdvType ~= 0 then
			self:UpdateSaleRule(GoodCfgData.AdvType)
		end
		if Discount ~= 0 and CurrentTime > DiscountStart and CurrentTime < DiscountEnd then
			self:UpdateTimeSale(DiscountEnd)
		end
		self:UpdatePurchaseLimit(GoodCfgData.ID)
	end
	self.IsBringEquip = GoodCfgData.IsBringEquip
end

---@type 更新图标
---@param Icon string @图标
---@param Background string @背景
function StoreGoodVM:UpdateIcon(Icon, Background)
    self.bGoodBgVisible = false
    self.bGoodIconVisible = tonumber(Icon) ~= nil

	--- 部位Icon
	if tonumber(Icon) then
		-- local ItemIconID = ItemUtil.GetItemIcon(Icon)
		self.GoodIcon = UIUtil.GetIconPath(Icon)
    else
		--- 显示海报
        self.GoodIcon = Icon
    end

    if type(Background) ~= "string" then
        FLOG_WARNING(string.format("StoreGoodVM:UpdateIcon, Background is nil, ItemIndex: %d", self.ItemIndex))
    else
        if Background ~= "" then
            self.bGoodBgVisible = true
        end
		self.KerWordStr = Background
    end
end

---@type 更新显示的价格
function StoreGoodVM:UpdatePrice(GoodCfgData, Params)
	if nil == GoodCfgData then
		return
	end

	local bUseDiscount = true
	if Params ~= nil and Params.IsCalculateDisCount ~= nil then
		bUseDiscount = Params.IsCalculateDisCount
	end
    self.HorizontalPriceVisible = true
	self.OriginalPanelVisible = false

	local RawPrice, PriceWithDiscount, PriceWithCoupon, bHasCoupon =
		StoreMgr:GetGoodPriceInfo(GoodCfgData, bUseDiscount, _G.StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy)
	self.bHasCoupon = bHasCoupon
	local FinalPrice = MathUtil.RoundOff(PriceWithCoupon)
	if bUseDiscount == false then
		FinalPrice = MathUtil.RoundOff(RawPrice)
	elseif RawPrice ~= PriceWithCoupon then
		self.OriginalPanelVisible = true
		self.OriginalPriceText = ScoreMgr.FormatScore(MathUtil.RoundOff(RawPrice))
		self.CouponNum = MathUtil.RoundOff(PriceWithDiscount - FinalPrice)
	end
	self.CrystalText = ScoreMgr.FormatScore(FinalPrice)
end

---@type 更新显示的限购
---@param GoodsID number
function StoreGoodVM:UpdatePurchaseLimit(GoodsID)
    -- self.LimitationVisible = false
    self.StateTextVisible = false

	if _G.StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Gift then
		-- FLOG_INFO("Purchase status does not display purchase restriction information")
		return
	end

    if StoreMgr:GetRemainQuantity(GoodsID) == StoreDefine.PurchasedMinValue then
        self:SetSoldOutState(StoreMgr:GetCounterType(GoodsID))
    end
end

---@type 设置已售罄状态
---@param PurchasedType number @已售罄类型
function StoreGoodVM:SetSoldOutState(PurchasedType)
	if _G.StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Gift then
		FLOG_INFO("Purchase status does not show purchase sold out information")
		return
	end
    local PurchasedText = LSTR(StoreDefine.SoldOutText[PurchasedType])
    if PurchasedText == nil then
        FLOG_WARNING(string.format("StoreGoodVM:SetSoldOutState, PurchasedText is nil, ItemIndex: %d", self.ItemIndex))
        return
    end
	
    -- self.LimitationVisible = false
    self.HorizontalPriceVisible = false
    self.StateTextVisible = true
    self.GoodStateText = PurchasedText
end

---@type 更新显示的活动规则
---@param AdvType number @活动类型
function StoreGoodVM:UpdateSaleRule(AdvType)

    local SaleType = AdvType or 0
    local RuleText = ProtoEnumAlias.GetAlias(ProtoRes.GoodsAdvType, SaleType)
    if RuleText == nil then
        -- FLOG_WARNING(string.format("StoreGoodVM:UpdateSaleRule, RuleText is nil, ItemIndex: %d", self.ItemIndex))
        return
    end

    self.HotSaleVisible = true
    self.SaleRuleText = RuleText
end

--- @type 更新显示的折扣
---@param Discount number @折扣
function StoreGoodVM:UpdateDiscount(Discount, ShowDiscount, IsOnTime)
    if Discount == nil then
        FLOG_WARNING(string.format("StoreGoodVM:UpdateDiscount, Discount is nil, ItemIndex: %d", self.ItemIndex))
        return
    end

    if Discount ~= StoreDefine.DiscountMaxValue and Discount ~= StoreDefine.DiscountMinValue then
        self.PanelOriginalVisible = true
		self.DiscountPanelVisible = ShowDiscount == 1 and IsOnTime
		self.DiscountText = StoreUtil.GetDiscountText(Discount)
	else
		self.DiscountPanelVisible = false
    end
end

---@type 更新显示的限时
function StoreGoodVM:UpdateTimeSale(Time)

    if Time == nil then
        FLOG_WARNING(string.format("StoreGoodVM:UpdateTimeSale, Time is nil, ItemIndex: %d", self.ItemIndex))
        return
    end

    local IsShowTimeSaleIcon, ShowTime = StoreMgr:GetTimeLimit(Time)
    if ShowTime == nil then
        return
    end

	self.IsShowTimeSaleIcon = IsShowTimeSaleIcon
    self.DeadlinePanelVisible = true
    self.TimeSaleText = ShowTime
end

return StoreGoodVM