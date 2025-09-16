local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
-- local ShopMgr = require("Game/Shop/ShopMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local GoodsCfg = require("TableCfg/GoodsCfg")
local ShopDefine = require("Game/Shop/ShopDefine")
local ShopGoodsMoneyItemNewVM =  require("Game/Shop/ItemVM/ShopGoodsMoneyItemNewVM")
local TimeUtil = require("Utils/TimeUtil")
local CounterMgr = require("Game/Counter/CounterMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")

local LSTR = _G.LSTR
local ShopMgr = _G.ShopMgr
local ItemType = ProtoCommon.ITEM_TYPE_DETAIL

---@class ShopGoodsListItemVM : UIViewModel
local ShopGoodsListItemVM = LuaClass(UIViewModel)

---Ctor
function ShopGoodsListItemVM:Ctor()
	self.Name = nil
	self.ItemQuality = nil
	self.Icon = nil
	self.QuotaVisible = nil
	--self.FVerticalBoxVisible = nil
	self.HQVisible = nil
	self.QuotaNum = nil
	self.TagVisible = nil
	self.TimeVisible = nil
	self.DiscountText = nil
	self.TimeText = nil
	self.MaskVisible = nil
	self.TipsText = nil
	self.HQImage = nil
	self.MoneyList = nil
	self.IsDiscount = nil
	self.GoodsId = nil
	self.BoughtCount = nil
	--self.TaskVisible = nil
	-- self.Img1 = nil
    -- self.Img2 = nil
    -- self.Img3 = nil
    -- self.Money2Visible = nil
    -- self.Money3Visible = nil
    -- self.Money1Num = nil
    -- self.Money2Num = nil
    -- self.Money3Num = nil
    -- self.CostPricePanelVisible = nil
    -- self.CostPriceNum = nil
    -- self.GoodsId = nil
    -- self.Discount = nil
    -- self.IsDiscount = nil
	self.ShopGoodsMoneyItemNewVM = ShopGoodsMoneyItemNewVM.New()
	self.RestrictionType = nil
	self.CounterInfo = nil
	self.GoodsItemInfo = nil
	self.IsCanBuy = nil
	self.bBuyDesc = nil
	self.GoldCoinPrice = nil
	self.ItemID = nil
	self.SpeciaIcon = nil
	self.ArrowIconVisible = nil
	self.MallID = nil
	self.PanelTaskVisible = nil
	self.FirstType = nil
	self.InitialState = false

	self.HQColor = nil
	self.TextconditionText = ""

	self.ImgXColor = ShopMgr:GetTextColor_Blue()
	self.ImgXVisible = false
	self.SortDisPlayID = 3				--- 默认状态排在第三个

	self.IsCanPreView = false
end

function ShopGoodsListItemVM:OnInit()

end
 
---UpdateVM
---@param List table
function ShopGoodsListItemVM:UpdateVM(List)
	self:UpdateGoodsState(List)
end

function ShopGoodsListItemVM:UpdateGoodsState(List)
	self.ArrowIconVisible = false
	--FLOG_ERROR("TEst GOODSLISTITEM LIST = %s",table_to_string(List))
	local Cfg = List.ItemInfo
	if Cfg == nil then
		Cfg = ItemCfg:FindCfgByKey(List.ItemID)
		List.ItemInfo = Cfg
	end
	if Cfg == nil then
		FLOG_ERROR("ShopGoodsListItemVM: Cfg = nil ID = %d ", List.ItemID)
		return
	end
	
	local IconID = tonumber(Cfg.IconID)
	local ItemName = ItemCfg:GetItemName(Cfg.ItemID)
	local ItemColor = Cfg.ItemColor
	local IsHQ = Cfg.IsHQ
	local GoodsId = List.GoodsId
	local DiscountInfo = {}
	DiscountInfo.Discount = List.Discount
	DiscountInfo.DiscountDurationStart = List.DiscountDurationStart
	DiscountInfo.DiscountDurationEnd = List.DiscountDurationEnd
	local QuotaInfo = {}
	QuotaInfo.RestrictionType = List.RestrictionType
	QuotaInfo.BoughtCount = List.BoughtCount
	QuotaInfo.CounterInfo = List.CounterInfo
	self.FirstType = List.FirstType
	self.RestrictionType = List.RestrictionType
	self.ItemID = Cfg.ItemID
	self.Icon = IconID
	self.GoodsId = GoodsId
	self.BoughtCount = List.BoughtCount
	self.CounterInfo = List.CounterInfo
	self.GoldCoinPrice = Cfg.GoldCoinPrice
	self.ItemMainType = Cfg.ItemMainType
	self.Classify = Cfg.Classify
	self.ItemLevel = Cfg.ItemLevel
	self.MallID = List.MallID
	self.Name = ItemName

	if List.Items ~= nil and List.Items[1] ~= nil then
		local OverlayNum = List.Items[1].Num or 0
		if OverlayNum > 1 then
			self.Name = string.format("%s x%s", ItemName, OverlayNum)
		end
	end

	if not table.is_nil_empty(DiscountInfo) then
		self:SetDiscount(DiscountInfo)
		self:SetDiscountTime(DiscountInfo)
	end
	self:SetLitmitTime(List.OnTime, List.OffTime)
	self:SetHQandColorImg(IsHQ,ItemColor)
	self:SetSpeciaIcon(List.IsSpecial)
	local Price = {}
	Price.CoinInfo = List.Price
	Price.GoodsId = GoodsId
	Price.Discount = List.Discount
	Price.IsDiscount = self.IsDiscount
	Price.DiscountDurationStart = List.DiscountDurationStart
	Price.DiscountDurationEnd = List.DiscountDurationEnd
	Price.GoldCoinPrice = self.GoldCoinPrice
	self.MallID = List.MallID or ShopMgr.CurOpenMallId
	self.MoneyList = Price
	self.MoneyList.MallID = List.MallID or ShopMgr.CurOpenMallId or ShopMgr.CurQueryShopID
	if Price.CoinInfo ~= nil then
		self.ShopGoodsMoneyItemNewVM:UpdateVM(self.MoneyList)
	end
	local IsWeapon = not (Cfg.ItemMainType == ProtoCommon.ItemMainType.ItemArm) and (Cfg.EquipmentID == 0 or (EquipmentCfg:FindCfgByKey(Cfg.EquipmentID) or {}).ItemMainType ~= ProtoCommon.ItemMainType.ItemArm)
	--- 坐骑、宠物、时装（时装里武器不预览）显示预览
	self.IsCanPreView = (Cfg.ItemType == ItemType.COLLAGE_FASHION and IsWeapon) or Cfg.ItemType == ItemType.COLLAGE_MOUNT or Cfg.ItemType == ItemType.COLLAGE_MINION
	self:UpdateItemInfoState(List, Cfg, QuotaInfo)
end

function ShopGoodsListItemVM:SetBuyViewItemState(Value)
	self.GoodsMoneyVisible = Value
	self.SizeBoxNameVisible = Value
end

function ShopGoodsListItemVM:SetDiscount(Info)
	if Info.DiscountDurationEnd > 0 and Info.DiscountDurationStart > 0 then
		local ServerTime = TimeUtil.GetServerTime() --秒
		local IsStart = ServerTime - Info.DiscountDurationStart
        local RemainSeconds = Info.DiscountDurationEnd - ServerTime
        local DayCostSec = 24 * 60 * 60
        local RemainDay = math.ceil(RemainSeconds / DayCostSec)
        if RemainDay > 0 and IsStart > 0 then
		end
	end
	if Info.Discount == 0 or Info.Discount == 100 then
		self.TagVisible = false
		self.IsDiscount = false
	else
		self.TagVisible = true
		self.IsDiscount = true
		local DiscountNum = math.floor(Info.Discount / 10) or 0
		self.DiscountText = string.format(LSTR(1200002), DiscountNum)
	end
end

function ShopGoodsListItemVM:SetDiscountTime(Info)
	if Info.DiscountDurationEnd > 0 and Info.DiscountDurationStart > 0 then
        local ServerTime = TimeUtil.GetServerTime() --秒
		local IsStart = ServerTime - Info.DiscountDurationStart
        local RemainSeconds = Info.DiscountDurationEnd - ServerTime
		local TimeString = LocalizationUtil.GetCountdownTimeForSimpleTime(RemainSeconds, "d")
        --local DayCostSec = 24 * 60 * 60
        --local RemainDay = math.ceil(RemainSeconds / DayCostSec)
        if RemainSeconds > 0 and IsStart > 0 then
			self.TimeVisible = true
            self.TimeText = TimeString--string.format(LSTR(1200001), RemainDay)
		else
			self.TagVisible = false
        end
	else
		self.TimeVisible = false
    end
end

function ShopGoodsListItemVM:SetLitmitTime(OnTime, OffTime)
	if self.TimeVisible then
		return
	end

	local OnTime =  ShopMgr:GetTimeInfo(OnTime)
    local OffTime = ShopMgr:GetTimeInfo(OffTime)
	local ServerTime = TimeUtil.GetServerLogicTime() --秒
	local TenyearsTime = 10 * 365 * 86400	--- 十年的秒数
	if OnTime > 0 and OffTime > 0 and OffTime - ServerTime <= TenyearsTime then
        local IsStart = ServerTime - OnTime
        local RemainSeconds = OffTime - ServerTime
        if RemainSeconds > 0 then
			local TimeString = LocalizationUtil.GetCountdownTimeForSimpleTime(RemainSeconds, "d")
			self.TimeVisible = true
            self.TimeText = TimeString
		else
			self.TimeVisible = false
        end
	else
		self.TimeVisible = false
    end
end

function ShopGoodsListItemVM:SetHQandColorImg(IsHQ, ItemColor)
	if IsHQ == 1 then
		self.HQVisible = true
		self.HQColor = ShopDefine.HQColor[ItemColor]
	else
		self.HQVisible = false
	end
	
	self.HQImage = ShopDefine.ItemColor[ItemColor]
end

function ShopGoodsListItemVM:SetSpeciaIcon(IsSpacia)
	if IsSpacia == 1 then
		self.SpeciaIcon = true
	else
		self.SpeciaIcon = false
	end
end

--- 更新卡片状态 最新顺序为 > 7-6-1-4-3-2-5
function ShopGoodsListItemVM:UpdateItemInfoState(List, Cfg, QuotaInfo)
	self.TextconditionText = ""
	self.QuotaNum = ""
	self.ImgXVisible = false
	local IsEquipment = false
	if self:SetTaskState(List.TaskState) then
		self.SortDisPlayID = 1
	elseif self.ItemMainType ~= ProtoCommon.ItemMainType.ItemMainTypeNone and self.ItemMainType < ProtoCommon.ItemMainType.ItemConsumables then
		IsEquipment = true
		if self:SetEquipUpIcon(self.ItemID) then
			self.SortDisPlayID = 2
		elseif not _G.EquipmentMgr:CanEquiped(Cfg.ItemID) then
			self.SortDisPlayID = self:UpdateImgXColor(Cfg) and 4 or 5
		end
	end
	if self:SetBuyState(List.bBuy, List.bBuyDesc, IsEquipment) then
		self.SortDisPlayID = 6
	elseif self:SetQuota(List.bBuy, QuotaInfo) then
		self.SortDisPlayID = 7
	end
end

--- 状态2 各种条件不足
function ShopGoodsListItemVM:SetBuyState(IsCanbuy, bBuyDesc, IsEquipment)
	local isCanUse = ShopMgr:IsCanUse(self.MallID, self.GoodsId)
	self.MaskVisible = not IsCanbuy and (not isCanUse or not IsEquipment)
	self.IsCanBuy = IsCanbuy
	self.bBuyDesc = bBuyDesc
	if self.MaskVisible then
		self.TipsText = LSTR(1200056)
	end
	return not IsCanbuy and not isCanUse
end

--- 状态3 4  X图片颜色
function ShopGoodsListItemVM:UpdateImgXColor(Cfg)
	local HasSatisfyingProf = false
	local ClassLimit = Cfg.ClassLimit
	local ProfLimit = Cfg.ProfLimit
	if ClassLimit == ProtoCommon.class_type.CLASS_TYPE_NULL and table.is_nil_empty(ProfLimit) then
		return false
	end
	if ClassLimit ~= ProtoCommon.class_type.CLASS_TYPE_NULL then
		ProfLimit = ShopMgr:GetProfLimitListByClassLimit(ClassLimit)
	end
	for _, value in ipairs(ProfLimit) do
		local Level = ShopMgr:GetProfLevel(value)
		if Level > 0 then
			if not HasSatisfyingProf and _G.EquipmentMgr:CanEquiped(Cfg.ItemID, false, value, Level) then
				HasSatisfyingProf = true
				break
			end
		end
	end

	self.ImgXColor = HasSatisfyingProf and ShopMgr:GetTextColor_Blue() or ShopMgr:GetTextColor_Red()
	self.ImgXVisible = true
	return HasSatisfyingProf
end

--- 状态5 限购相关
function ShopGoodsListItemVM:SetQuota(IsCanBuy, Info)
	if Info.RestrictionType and Info.RestrictionType ~= 0 then
		local CanBuyCount = Info.BoughtCount
		if CanBuyCount > 0 and IsCanBuy then
			self.QuotaVisible = true
			local CurrentRestore = CounterMgr:GetCounterRestore(Info.CounterInfo.CounterFirst.CounterID)
			local Title = ShopDefine.LimitBuyType[Info.RestrictionType]
			self.QuotaNum = string.format("%s%d/%d", Title, CanBuyCount, CurrentRestore)
			self.MaskVisible = false
		elseif CanBuyCount > 0 and not IsCanBuy then
			self.QuotaNum = ""
			self.MaskVisible = true
			self.TipsText = LSTR(1200056)
			self.TextconditionText = ""
		elseif CanBuyCount <= 0 and not IsCanBuy then
			self.QuotaVisible = true
			self.QuotaNum = ""
			self.MaskVisible = true
			self.TipsText = LSTR(1200032)
			self.TextconditionText = ""
		end
	else
		self.QuotaNum = ""
		-- self.MaskVisible = false
		self.QuotaVisible = false
	end
	self.InitialState = self.QuotaVisible

	return Info.RestrictionType and Info.RestrictionType ~= 0
end

--- 状态7 任务状态
function ShopGoodsListItemVM:SetTaskState(State)
	self.PanelTaskVisible = State--_G.QuestMgr:IsQuestGoods(ItemID)
	return State
end

function ShopGoodsListItemVM:UpdateTaskState(ItemID)
	self.PanelTaskVisible = _G.QuestMgr:IsQuestGoods(ItemID)
end

--- 6 职业提升标识
function ShopGoodsListItemVM:SetEquipUpIcon(ItemID)
	local ProfID = MajorUtil.GetMajorProfID()
	local CanNotUseArr = _G.EquipmentMgr:CanEquiped(ItemID, false, ProfID, nil)
    if CanNotUseArr then
		local EquipPart = ShopMgr:GetGoodsPartByEquipPart(self.Classify)
		if EquipPart then
			for i = 1, #EquipPart do
				local EquipmentInfo = _G.EquipmentMgr:GetEquipedItemByPart(EquipPart[i])
				local CurEquipItemLevel
				if EquipmentInfo then
					CurEquipItemLevel = ItemCfg:FindCfgByKey(EquipmentInfo.ResID).ItemLevel
				else
					CurEquipItemLevel = 0
				end
				
				if self.TextconditionText == "" and self.ItemLevel > CurEquipItemLevel then
					self.ArrowIconVisible = true
				else
					self.ArrowIconVisible = false
				end
				
				if self.ArrowIconVisible then
					return
				end
			end
		else
			FLOG_ERROR("ShopGoodsListItemVM SetEquipUpIcon EquipPart = nil")
			self.ArrowIconVisible = false
		end
	else
		self.ArrowIconVisible = false
	end
	return self.ArrowIconVisible
end

function ShopGoodsListItemVM:IsEqualVM(Value)
    --return nil ~= Value and Value.ID == self.ShopItemData.ID
end

function ShopGoodsListItemVM:OnValueChanged(Value)
	if ShopMgr.JumpToGoodsState or ShopMgr.IsJumpAgain then
		self.GoodsId = Value.GoodsId
		self.BoughtCount = Value.BoughtCount
		self.CounterInfo = Value.CounterInfo
		self.IsCanBuy = Value.bBuy
		self.bBuyDesc = Value.bBuyDesc
		self.ItemID = Value.ItemID
		self.RestrictionType = Value.RestrictionType or 0
	end
end

function ShopGoodsListItemVM:SetQuotaVisible(Value)
	if Value then
		self.QuotaVisible = self.InitialState
	else
		self.QuotaVisible = Value
	end
	
end

function ShopGoodsListItemVM:SetBuyViewState(Value)
	if Value then
		self.ArrowIconVisible = false
		self.ImgXVisible = false
		self.QuotaVisible = false
	end
end
return ShopGoodsListItemVM