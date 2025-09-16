
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ScoreCfg = require("TableCfg/ScoreCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local TimeUtil = require("Utils/TimeUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ItemDefine = require("Game/Item/ItemDefine")
local StoreDefine = require("Game/Store/StoreDefine")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local StoreMgr = require("Game/Store/StoreMgr")
local StoreNewPropsItemMoneyVM = require("Game/Store/VM/ItemVM/StoreNewPropsItemMoneyVM")
local StoreUtil = require("Game/Store/StoreUtil")

local FLOG_WARNING = _G.FLOG_WARNING
local LSTR = _G.LSTR

---@class StorePropsItemVM: UIViewModel
---@field ItemQuality					string	@背景
---@field Icon				number	@道具图标ID
---@field Name							string	@名称
---@field TagVisible			boolean	@是否显示折扣
---@field DiscountText					string	@几折
---@field TimeText					string	@折扣剩余时间
---@field LimitationText				string	@折扣限时 -- 每周/每日
---@field PropsPriceType				string	@价格类型  水晶点/银币/金币……
---@field MaskVisible				boolean	@遮罩显隐
---@field TipsText						string	@遮罩提示
---@field GoodsId						number	@道具ID
---@field LimitPanelVisible				boolean	@限购panel显隐
---@field HotSaleVisible 				bool @是否显示热卖
---@field IsCanBuy 						bool @是否可以购买
local StorePropsItemVM = LuaClass(UIViewModel)

function StorePropsItemVM:Ctor()
	self.Icon = 0
	self.Name = ""
	self.GoodsId = 0
	self.HQVisible = false
	self.SpeciaIcon = false			--- 复用商店蓝图  多出来的一个图片  不知道干啥的  暂时隐藏
	self.TagVisible = false
	self.TimeVisible = false
	self.DiscountText = ""
	self.TimeText = ""
	self.MaskVisible = false
	self.TipsText = ""
	self.HQImage = ""		--- 商城3期优化里 道具蓝图用的是商店的，然后商店绑定的背景字段 是 HQImage
	self.HQColor = ""		--- HQ的图标
	self.QuotaNum = ""
	self.QuotaVisible = true
	self.ArrowIconVisible = false
	self.TextconditionText = ""
	self.PanelTaskVisible = false

	self.ShopGoodsMoneyItemNewVM = StoreNewPropsItemMoneyVM.New()

	self.MoneyVisible2 = false
	self.MoneyVisible3 = false
end

function StorePropsItemVM:IsEqualVM(Value)
	return nil ~= Value
end

function StorePropsItemVM:UpdateVM(Value)
	if Value == nil then
		FLOG_WARNING("StorePropsItemVM:InitVM, Value is nil")
		return
	end
	
	local PropsData = Value.PropsData
	local PropsCfgData = Value.PropsData.Cfg
	self.GoodsId = PropsCfgData.ID
	local TempScoreCfg = ScoreCfg:FindCfgByKey(PropsCfgData.Price[1].ID)
	if TempScoreCfg ~= nil then
		self.PropsPriceType = TempScoreCfg.IconName
	end
	self.ItemIndex = Value.ItemIndex
	local TempItem = ItemCfg:FindCfgByKey(PropsCfgData.Items[1].ID)
	if TempItem == nil then
		return
	end
	self.Icon = TempItem.IconID
	self.HQImage = PropsCfgData.PropQualityIconPath
	self.Name = PropsCfgData.Name
	self.HotSaleVisible = false
	local TempItemCfg = ItemCfg:FindCfgByKey(PropsCfgData.Items[1].ID)
	if TempItemCfg ~= nil then
		self.HQVisible = TempItemCfg.IsHQ == 1
		self.HQColor = ItemDefine.HQItemIconColorType[TempItemCfg.ItemColor]
	end
	
	--- 限购信息
	local RemainGoodsQuantity = StoreMgr:GetRemainQuantity(self.GoodsId)
	if RemainGoodsQuantity >= 0 and PropsCfgData.RestrictionDisplay == 1 and _G.StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
		local PurchasedText = LSTR(StoreDefine.RestrictionTypeText[StoreMgr:GetCounterType(self.GoodsId)])
		self.QuotaNum = string.format(PurchasedText, RemainGoodsQuantity, StoreMgr:GetCounterRestore(self.GoodsId))
		self.LimitPanelVisible = true
	else
		self.QuotaNum = ""
		self.LimitPanelVisible = false
	end
	if RemainGoodsQuantity == 0 and _G.StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
		self.TipsText = LSTR(950021)	--- "已售罄"
	end

	local IsCan, CanNotReason = StoreMgr:IsCanBuy(PropsCfgData.ID)
	self.MaskVisible = (not IsCan or RemainGoodsQuantity == 0) and
		_G.StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy
	self.LimitPanelVisible = _G.StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy
	if not IsCan then
		self.TipsText = CanNotReason
	end
	self:SetPrice(PropsCfgData)
	self.IsBringEquip = PropsCfgData.IsBringEquip
end

function StorePropsItemVM:SetPrice(PropsData)
	self.TagVisible = false
	if nil == PropsData then
		return
	end
	if PropsData.ShowDiscount ~= 0 and PropsData.Discount ~= 0 then
		self.DiscountText = StoreUtil.GetDiscountText(PropsData.Discount)
		self.TagVisible = true
	end
	self.ShopGoodsMoneyItemNewVM:UpdateVM(PropsData)
	if PropsData.AdvType ~= 0 then
		self:UpdateSaleRule(PropsData.AdvType)
	end
end

---@type 更新显示的活动规则
---@param AdvType number @活动类型
function StorePropsItemVM:UpdateSaleRule(AdvType)

	local SaleType = AdvType or 0
	local RuleText = ProtoEnumAlias.GetAlias(ProtoRes.GoodsAdvType, SaleType)
	if RuleText == nil then
		-- FLOG_WARNING(string.format("StoreGoodVM:UpdateSaleRule, RuleText is nil, ItemIndex: %d", self.ItemIndex))
		return
	end

	self.HotSaleVisible = true
	self.SaleRuleText = RuleText
end

return StorePropsItemVM