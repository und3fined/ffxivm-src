local DataReportUtil = require("Utils/DataReportUtil")
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

return StoreUtil