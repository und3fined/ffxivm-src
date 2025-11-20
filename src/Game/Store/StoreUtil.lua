local DataReportUtil = require("Utils/DataReportUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ShopDefine = require("Game/Shop/ShopDefine")
local StoreCfg = require("TableCfg/StoreCfg")
local StoreDefine = require("Game/Store/StoreDefine")

local LSTR = _G.LSTR

local StoreUtil = {}

---@param OperationType StoreDefine.InterfaceOperationType
---@param NewTab ProtoRes.StoreMall
---@param OldTab ProtoRes.StoreMall
---@param Arg1 number @GoodsID
---@param Arg2 number @BrowseOperationType | ProtoCommon.equip_part
function StoreUtil.ReportInterfaceFlow(OperationType, NewTab, OldTab, Arg1, Arg2)
	NewTab = NewTab or ""
	OldTab = OldTab or ""
	Arg1 = Arg1 or ""
	Arg2 = Arg2 or ""
	DataReportUtil.ReportData("MallInterfaceFlow", true, false, true,
		"OpType", tostring(OperationType),
		"OpTab", tostring(NewTab),
		"OpTabOld", tostring(OldTab),
		"Arg1", tostring(Arg1),
		"Arg2", tostring(Arg2))
end

---@param GoodsID number
---@param OperationType StoreDefine.PurchaseOperationType
function StoreUtil.ReportPurchaseClickFlow(GoodsID, OperationType)
	DataReportUtil.ReportData("PurchaseClickFlow", true, false, true,
		"Shopid", tostring(GoodsID),
		"Operation", tostring(OperationType))
end

---@param GoodsID number
---@param OperationType StoreDefine.GiftOperationType
function StoreUtil.ReportGiftClickFlow(GoodsID, OperationType)
	DataReportUtil.ReportData("GiveClickFlow", true, false, true,
	"Shopid", tostring(GoodsID),
	"Operation", tostring(OperationType))
end

---@param TabType StoreDefine.MailTabType
function StoreUtil.ReportMailFlow(TabType)
	DataReportUtil.ReportData("MailFlow", false, false, false,
	"MailTab", tostring(TabType))
end

--region 折扣

function StoreUtil.GetDiscountText(Discount)
	if Discount ~= StoreDefine.DiscountMaxValue and Discount ~= StoreDefine.DiscountMinValue then
        if Discount % 10 == 0 then
			return string.format(_G.LSTR(950042), Discount / 10)	--- "%d折"
		else
			return string.format(_G.LSTR(950080), Discount / 10)	--- "%.1f折"
		end
	else
		return ""
    end
	return ""
end

--endregion

--region 提示文本

local CannotBuyReasonMap =
{
	[LSTR(StoreDefine.SecondScreenType.SoldOut)] = LSTR(StoreDefine.SecondScreenType.SoldOut),
	[LSTR(StoreDefine.SecondScreenType.Owned)] = LSTR(950091)
}

function StoreUtil.GetTipsByCannotBuyReason(CannotBuyReason)
	local Tips = CannotBuyReasonMap[CannotBuyReason]
	if nil == Tips then
		return CannotBuyReason
	end
	return Tips
end

--endregion

-- 获取商品所包含的排序过的道具列表
function StoreUtil.GetSortedItems(Items)
	if table.is_nil_empty(Items) then
		return {}
	end
	local SortedItems = {}
	local BundleCurrentIndex = 1
	for _, Item in ipairs(Items) do
		local Index = Item.IsBundled and BundleCurrentIndex or (#SortedItems + 1) -- 捆绑销售的商品放前面
		table.insert(SortedItems, Index, Item)
		if Item.IsBundled then
			BundleCurrentIndex = BundleCurrentIndex + 1
		end
	end
	return SortedItems
end

--region 商品信息查询
function StoreUtil.GetGoodsName(GoodsID)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	if nil == GoodsCfgData then
		return ""
	end
	local DescItemID = StoreUtil.GetDescItemID(GoodsCfgData)
	if DescItemID > 0 then
		return ItemCfg:GetItemName(DescItemID)
	end
	return GoodsCfgData.Name
end

function StoreUtil.GetGoodsDesc(GoodsID)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	if nil == GoodsCfgData then
		return ""
	end
	local DescItemID = StoreUtil.GetDescItemID(GoodsCfgData)
	if DescItemID > 0 then
		return ItemCfg:GetItemDesc(DescItemID)
	end
	return GoodsCfgData.Desc
end

function StoreUtil.GetDescItemID(GoodsCfgData)
	if nil == GoodsCfgData or GoodsCfgData.DescID == 0 then
		return 0
	end
	local Item = GoodsCfgData.Items[GoodsCfgData.DescID]
	return Item and Item.ID or 0
end

---@param GoodsID number
---@return number @ITEM_COLOR_TYPE
function StoreUtil.GetGoodsQualityColor(GoodsID)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	if nil == GoodsCfgData or nil == GoodsCfgData.Items[1] then
		return 0
	end
	local ItemCfgData = ItemCfg:FindCfgByKey(GoodsCfgData.Items[1].ID)
	return ItemCfgData and ItemCfgData.ItemColor or 0
end

function StoreUtil.GetGoodsQualityImagePath(GoodsID)
	local Color = StoreUtil.GetGoodsQualityColor(GoodsID)
	return ShopDefine.ItemColor[Color] or ""
end

function StoreUtil.GetGoodsDiscountedPrice(GoodsID)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	if nil == GoodsCfgData or nil == GoodsCfgData.Items[1] then
		return 0
	end
	local Price = 0
	if GoodsCfgData.DisCountedPrice > 0 then
		Price = GoodsCfgData.DisCountedPrice
	else
		Price = math.floor(GoodsCfgData.Price[StoreDefine.PriceDefaultIndex].Count * GoodsCfgData.Discount * 0.01)
	end
	return Price
end
--endregion

return StoreUtil