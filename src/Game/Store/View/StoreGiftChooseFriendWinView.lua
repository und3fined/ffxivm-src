
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local StoreMainVM = require("Game/Store/VM/StoreMainVM")
local StoreMgr = require("Game/Store/StoreMgr")
local FriendVM = require("Game/Social/Friend/FriendVM")
local FriendDefine = require("Game/Social/Friend/FriendDefine")
local RichTextUtil = require("Utils/RichTextUtil")
local CounterMgr = require("Game/Counter/CounterMgr")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ProtoRes = require("Protocol/ProtoRes")
local StoreCfg = require("TableCfg/StoreCfg")
local StorePropsItemVM = require("Game/Store/VM/ItemVM/StorePropsItemVM")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetTextFormatForScore = require("Binder/UIBinderSetTextFormatForScore")
local UIBinderSetScoreIcon = require("Binder/UIBinderSetScoreIcon")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local ItemTipsUtil = require("Utils/ItemTipsUtil")

local AllGroupID = FriendDefine.AllGroupID
local AllGroupName = FriendDefine.AllGroupName
local LSTR = _G.LSTR

---@class StoreGiftChooseFriendWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field CommEmpty CommBackpackEmptyView
---@field DropDownFilter CommDropDownListView
---@field HorizontalPrice UFHorizontalBox
---@field ImgBlackBg UFImage
---@field ImgDeadline UFImage
---@field ImgGoods UFImage
---@field ImgMoney UFImage
---@field PanelDeadline UFCanvasPanel
---@field PanelDiscount UFCanvasPanel
---@field PanelGoodsShow UFCanvasPanel
---@field PanelInclude UFCanvasPanel
---@field PanelInfor UFCanvasPanel
---@field PanelOriginal UFCanvasPanel
---@field PanelPropsShow UFCanvasPanel
---@field RichTextLimit URichTextBox
---@field RichTextRequest URichTextBox
---@field SearchBar CommSearchBarView
---@field ShopGoods ShopGoodsListItemView
---@field TableViewFriendList UTableView
---@field TableViewInclude UTableView
---@field TextCurrentPrice UFTextBlock
---@field TextDeadline UFTextBlock
---@field TextDiscount UFTextBlock
---@field TextInclude UFTextBlock
---@field TextItemName UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextTitle UFTextBlock
---@field VerticalBoxInfo UFVerticalBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimUpdateFriendList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreGiftChooseFriendWinView = LuaClass(UIView, true)

function StoreGiftChooseFriendWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.CommEmpty = nil
	--self.DropDownFilter = nil
	--self.HorizontalPrice = nil
	--self.ImgBlackBg = nil
	--self.ImgDeadline = nil
	--self.ImgGoods = nil
	--self.ImgMoney = nil
	--self.PanelDeadline = nil
	--self.PanelDiscount = nil
	--self.PanelGoodsShow = nil
	--self.PanelInclude = nil
	--self.PanelInfor = nil
	--self.PanelOriginal = nil
	--self.PanelPropsShow = nil
	--self.RichTextLimit = nil
	--self.RichTextRequest = nil
	--self.SearchBar = nil
	--self.ShopGoods = nil
	--self.TableViewFriendList = nil
	--self.TableViewInclude = nil
	--self.TextCurrentPrice = nil
	--self.TextDeadline = nil
	--self.TextDiscount = nil
	--self.TextInclude = nil
	--self.TextItemName = nil
	--self.TextOriginalPrice = nil
	--self.TextTitle = nil
	--self.VerticalBoxInfo = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimUpdateFriendList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreGiftChooseFriendWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.DropDownFilter)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.ShopGoods)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFYs
end

function StoreGiftChooseFriendWinView:OnInit()
	self.TableAdapterFriendList = UIAdapterTableView.CreateAdapter(self, self.TableViewFriendList)
	self.TreeAdapterInclude = UIAdapterTableView.CreateAdapter(self, self.TableViewInclude, self.OnIncludeSelectedChanged, true)

	self.SearchBar:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnClickCancelSearchBar)
	local TextLevel = RichTextUtil.GetText(StoreMgr.DoneeLevelLimit, "#bd8213")
	local TextTime = RichTextUtil.GetText(string.format("%d", StoreMgr.FriendDuration), "#bd8213")
	--- 赠礼要求：双方达到%d级，且互为好友%d天
	self.RichTextRequest:SetText(string.format(LSTR(950036), TextLevel, TextTime))

	self.MainBinders =
	{
		{ "PropsPanelVisible", 			UIBinderSetIsVisible.New(self, self.PanelGoodsShow, true) },
		{ "PropsPanelVisible", 			UIBinderSetIsVisible.New(self, self.PanelInclude, true) },
		{ "BuyGoodIcon", 					UIBinderSetBrushFromAssetPath.New(self, self.ImgGoods, true) },

		{ "FriendItemVMList", 				    UIBinderUpdateBindableList.New(self, self.TableAdapterFriendList) },
		{ "FriendNum",                      UIBinderValueChangedCallback.New(self, nil, self.OnFriendNumChanged) },
		{ "ContainsItemList", 				UIBinderUpdateBindableList.New(self, self.TreeAdapterInclude) },
		{ "DiscountText", 					UIBinderSetText.New(self, self.TextDiscount) },
		{ "TimeSaleText", 					UIBinderSetText.New(self, self.TextDeadline) },
		{ "DiscountPanelVisible", 			UIBinderSetIsVisible.New(self, self.PanelDiscount) },--- 
		{ "DeadlinePanelVisible", 			UIBinderSetIsVisible.New(self, self.PanelDeadline) },--- 
		{ "PropsPanelVisible", 				UIBinderSetIsVisible.New(self, self.PanelPropsShow) },
		{ "IsShowTimeSaleIcon", 			UIBinderSetIsVisible.New(self, self.ImgDeadline) },
		{ "GiftChooseImgBlackLucency", 		UIBinderSetColorAndOpacityHex.New(self, self.ImgBlackBg) },
	}

	self.PriceBinders =
	{
		{ "ScoreID", UIBinderSetScoreIcon.New(self, self.ImgMoney) },
		{ "BuyPrice", UIBinderSetTextFormatForScore.New(self, self.TextCurrentPrice) },
		{ "RawPrice", UIBinderSetTextFormatForScore.New(self, self.TextOriginalPrice) },
		{ "bShowRawPrice", UIBinderSetIsVisible.New(self, self.PanelOriginal) },
	}

	self.PriceVM = StoreMgr:GetGiftPriceVM()
	self.StorePropsItemVM = StorePropsItemVM.New()

	self.GoodsID = 0
end

function StoreGiftChooseFriendWinView:OnDestroy()

end

function StoreGiftChooseFriendWinView:OnShow()
	if nil ~= self.Params then
		self.GoodsID = self.Params.GoodsID or 0
	end

	-- 初始化好友列表
	FriendVM:FilterFriendVMByGroupID(AllGroupID)
	StoreMainVM:UpdateFriendList()

	-- 搜索框
	self.SearchBar:SetHintText(LSTR(950089))

	-- 背景图
	self.CommEmpty:SetTipsContent(LSTR(950090)) -- 暂无搜索结果

	self.TextTitle:SetText(LSTR(950057))	--- 选择好友赠送
	self.TextInclude:SetText(LSTR(950058))		--- 包含以下物品
	_G.FriendMgr:SendGetFriendListMsg()
	self.GiftCounterID = StoreMgr.GiftCounterID
	local GiftLimit = CounterMgr:GetCounterRestore(self.GiftCounterID) or 0		-- 每天最大赠送次数
	local CurrentNum = CounterMgr:GetCounterCurrValue(self.GiftCounterID) or 0	-- 今日已赠送次数
	local RemindTimeNumber = StoreMgr.RemindTimeNumber							-- 触发提醒次数
	local UsedNum = string.format("%s%s%s", CurrentNum, "/", GiftLimit)
	local RemainingTime = self:GetRemainingTime()
	local TimeStr = LocalizationUtil.GetCountdownTimeForSimpleTime(RemainingTime, "s")
	if CurrentNum >= RemindTimeNumber then
		UIUtil.SetIsVisible(self.RichTextLimit, true)
		if CurrentNum == GiftLimit then
			self.RichTextLimit:SetText(string.format(LSTR(950038), UsedNum, TimeStr))
		else
			self.RichTextLimit:SetText(string.format(LSTR(950037), UsedNum, TimeStr))
		end
	else
		UIUtil.SetIsVisible(self.RichTextLimit, false)
	end
	_G.UIViewMgr:HideView(_G.UIViewID.StoreBuyGoodsWin)
	_G.UIViewMgr:HideView(_G.UIViewID.StoreBuyPropsWin)

	local GoodsCfgData = StoreCfg:FindCfgByKey(self.GoodsID)
	self.StorePropsItemVM:UpdateVM({PropsData = {Cfg = GoodsCfgData}})
	self.ShopGoods:SetParams({Data = self.StorePropsItemVM})
	self.ShopGoods:SetBuyViewItemStateEx(false)
	if nil ~= GoodsCfgData then
		self.TextItemName:SetText(GoodsCfgData.Name)
	end
	StoreMainVM:UpdateGoodIcon()

	self:UpdateDropDownListItems(1)

end

function StoreGiftChooseFriendWinView:OnFriendNumChanged(Value)
	UIUtil.SetIsVisible(self.CommEmpty, Value == 0)
end

--- 刷新时间凌晨五点
--- 获取距离下一次刷新还有多少秒
function StoreGiftChooseFriendWinView:GetRemainingTime()
	local Now = os.date("*t")
	local TargetHour = 5
	local TargetMin = 0
	local TargetSec = 0
	local Now_ts = os.time(Now)

	if Now.hour >= TargetHour or (Now.hour == TargetHour and (Now.min > TargetMin or (Now.min == TargetMin and Now.sec >= TargetSec))) then
		Now.day = Now.day + 1
	end

	local Target = {
		year = Now.year,
		month = Now.month,
		day = Now.day,
		hour = TargetHour,
		min = TargetMin,
		sec = TargetSec,
		isdst = Now.isdst
	}
	local Target_ts = os.time(Target)
	local Seconds_Until_Target = Target_ts - Now_ts
	-- print("距离下一天凌晨五点还有 " .. Seconds_Until_Target .. " 秒")
	return Seconds_Until_Target
end

function StoreGiftChooseFriendWinView:OnHide()
	FriendVM:ClearFilterData()
end

function StoreGiftChooseFriendWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownFilter, self.OnSelectionChangedDropDownList)

end

function StoreGiftChooseFriendWinView:OnRegisterGameEvent()

end

function StoreGiftChooseFriendWinView:OnIncludeSelectedChanged(Index, ItemData, ItemView)
	ItemData.IsSelect = false
	ItemTipsUtil.ShowTipsByResID(StoreMainVM.ContainsItemList.Items[Index].ResID, ItemView, {X = -self.TableViewInclude.EntrySpacing, Y = 0})
end
	
---@param SearchText string @回调的文本
function StoreGiftChooseFriendWinView:OnSearchTextCommitted(SearchText)
	self.DropDownFilter:ResetDropDown()
	if not string.isnilorempty(SearchText) then
		FriendVM:FilterFriendByKeyword(SearchText)
		StoreMainVM:UpdateFriendList()
	else
		self:OnClickCancelSearchBar()
	end
	self:PlayAnimation(self.AnimUpdateFriendList)
end

function StoreGiftChooseFriendWinView:OnClickCancelSearchBar()
	self.SearchBar:SetText("")
	FriendVM:ClearFilterData()

	StoreMainVM:UpdateFriendList()
end

function StoreGiftChooseFriendWinView:OnSelectionChangedDropDownList(Index, _, _, bIsByClick)
	if nil == self.DropDownListData or nil == Index or self.CurDropDownIdx == Index then
		return
	end
	if not bIsByClick then
		return
	end
	self:PlayAnimation(self.AnimUpdateFriendList)
	self.CurDropDownIdx = Index
	local GroupID = (self.DropDownListData[Index] or {}).GroupID
	if GroupID then
		FriendVM:FilterFriendVMByGroupID(GroupID)
		self.SearchBar:SetText("")
		StoreMainVM:UpdateFriendList()
	end
	
end

function StoreGiftChooseFriendWinView:UpdateDropDownListItems(Index)
	local ListData = FriendVM:GetDropDownItems()
	-- 去除黑名单分组
	for Index, Data in ipairs(ListData) do
		if Data.GroupID == FriendDefine.BlackGroupID then
			table.remove(ListData, Index)
			break
		end
	end
	self.DropDownFilter:UpdateItems(ListData, Index or self.CurDropDownIdx)

	self.DropDownListData = ListData
end

function StoreGiftChooseFriendWinView:OnRegisterBinder()
	self:RegisterBinders(StoreMainVM, self.MainBinders)
	self:RegisterBinders(self.PriceVM, self.PriceBinders)
end

return StoreGiftChooseFriendWinView