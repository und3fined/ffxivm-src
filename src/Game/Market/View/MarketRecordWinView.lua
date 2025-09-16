---
--- Author: Administrator
--- DateTime: 2023-07-11 14:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MarketRecordWinVM = require("Game/Market/VM/MarketRecordWinVM")
local MarketMgr = require("Game/Market/MarketMgr")
local ProtoCS = require("Protocol/ProtoCS")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LSTR = _G.LSTR
local EventID = _G.EventID

---@class MarketRecordWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameLView
---@field PanelPurchaseHistory UFCanvasPanel
---@field PanelSalesRecord UFCanvasPanel
---@field Tab CommHorTabsView
---@field TableViewRecords UTableView
---@field TableViewSalesRecord UTableView
---@field TextAmount UFTextBlock
---@field TextIncome UFTextBlock
---@field TextItem UFTextBlock
---@field TextItemTime UFTextBlock
---@field TextPrice UFTextBlock
---@field TextPurchaser UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextTaxRate UFTextBlock
---@field TextTime UFTextBlock
---@field TextTips UFTextBlock
---@field AnimUpdateRecords UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketRecordWinView = LuaClass(UIView, true)

function MarketRecordWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.PanelPurchaseHistory = nil
	--self.PanelSalesRecord = nil
	--self.Tab = nil
	--self.TableViewRecords = nil
	--self.TableViewSalesRecord = nil
	--self.TextAmount = nil
	--self.TextIncome = nil
	--self.TextItem = nil
	--self.TextItemTime = nil
	--self.TextPrice = nil
	--self.TextPurchaser = nil
	--self.TextQuantity = nil
	--self.TextTaxRate = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--self.AnimUpdateRecords = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketRecordWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.Tab)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketRecordWinView:OnInit()
	self.BuyTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRecords, nil, false)
	self.SellTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSalesRecord, nil, false)
	self.Binders = {
		{ "BuyRecordItemVMList", UIBinderUpdateBindableList.New(self, self.BuyTableViewAdapter) },
		{ "SellRecordItemVMList", UIBinderUpdateBindableList.New(self, self.SellTableViewAdapter) },
		{ "PurchaseRecordVisible", UIBinderSetIsVisible.New(self, self.PanelPurchaseHistory) },
		{ "SalesRecordVisible", UIBinderSetIsVisible.New(self, self.PanelSalesRecord) },
	}
end

function MarketRecordWinView:OnDestroy()

end

function MarketRecordWinView:OnShow()
	self.IsOnShow = true
	if MarketRecordWinVM.CurType == ProtoCS.MarketRecordType.MarketRecordType_Sell then
		self.Tab:SetSelectedIndex(2)
	else
		self.Tab:SetSelectedIndex(1)
	end
end

function MarketRecordWinView:OnHide()
	self.IsOnShow = nil
end

function MarketRecordWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.Tab, self.OnSelectionChangedDropDownList)
end

function MarketRecordWinView:OnSelectionChangedDropDownList(Index, ItemData, ItemView)
	if MarketRecordWinVM.CurType == ProtoCS.MarketRecordType.MarketRecordType_Sell and not self.IsOnShow then
		return
	end

	if Index == 1 then
		MarketRecordWinVM:SetType(ProtoCS.MarketRecordType.MarketRecordType_Buy)
		MarketMgr:SendRecordListMessage(0, ProtoCS.MarketRecordType.MarketRecordType_Buy)
	elseif Index == 2 then
		MarketRecordWinVM:SetType(ProtoCS.MarketRecordType.MarketRecordType_Sell)
		MarketMgr:SendRecordListMessage(0, ProtoCS.MarketRecordType.MarketRecordType_Sell)
	end
	
	self:PlayAnimation(self.AnimUpdateRecords)
end

function MarketRecordWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MarketRecordList, self.OnMarketRecordListUpdata)
end

function MarketRecordWinView:OnMarketRecordListUpdata(RecordInfo)
	MarketRecordWinVM:UpdateListInfo(RecordInfo)
end

function MarketRecordWinView:OnRegisterBinder()
	if nil == self.Binders then return end
	self:RegisterBinders(MarketRecordWinVM, self.Binders)

	self.Bg:SetTitleText(LSTR(1010077))

	local TabList = {}
	table.insert(TabList, {Name = LSTR(1010078)})
	table.insert(TabList, {Name = LSTR(1010079)})
	self.Tab:UpdateItems(TabList)

	self.TextTips:SetText(LSTR(1010080))
	self.TextItem:SetText(LSTR(1010081))
	self.TextAmount:SetText(LSTR(1010071))
	self.TextPrice:SetText(LSTR(1010082))
	self.TextTime:SetText(LSTR(1010083))
	self.TextItemTime:SetText(LSTR(1010084))
	self.TextQuantity:SetText(LSTR(1010071))
	self.TextIncome:SetText(LSTR(1010085))
	self.TextPurchaser:SetText(LSTR(1010086))
	self.TextTaxRate:SetText(LSTR(1010087))
end

return MarketRecordWinView