---
--- Author: Administrator
--- DateTime: 2024-05-20 15:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MysterMerchantMgr = require("Game/MysterMerchant/MysterMerchantMgr")
local MysterMerchantVM = require("Game/MysterMerchant/VM/MysterMerchantVM")
local MysterMerchantDefine = require("Game/MysterMerchant/MysterMerchantDefine")
local MysterMerchantUtils = require("Game/MysterMerchant/MysterMerchantUtils")
local UIViewID = _G.UIViewID

---@class MysterMechantMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field GoodImpression MysterMerchantGoodImpressionItemView
---@field ImgBanner UFImage
---@field MoneySlot CommMoneySlotView
---@field TableViewCommodity UTableView
---@field TextGoodImpression UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MysterMechantMainPanelView = LuaClass(UIView, true)

function MysterMechantMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.GoodImpression = nil
	--self.ImgBanner = nil
	--self.MoneySlot = nil
	--self.TableViewCommodity = nil
	--self.TextGoodImpression = nil
	--self.TextQuantity = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MysterMechantMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.GoodImpression)
	self:AddSubView(self.MoneySlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MysterMechantMainPanelView:OnInit()
	self.GoodsListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCommodity, self.OnSelectedChanged, true, false)
	self.Binders = {
		{"FriendlinessLevel", UIBinderSetText.New(self, self.GoodImpression.TextLv) },
		{"FriendlinessEXPText", UIBinderSetText.New(self, self.TextQuantity) },
		{"GoodsVMList", UIBinderUpdateBindableList.New(self, self.GoodsListAdapter)},
		{"EXPPercent", UIBinderValueChangedCallback.New(self, nil, self.OnEXPPercentChanged)},
	}
end

function MysterMechantMainPanelView:OnDestroy()

end

function MysterMechantMainPanelView:OnShow()
	self:SetLSTR()
	local ScoreID = MysterMerchantVM.CoinID
	self.MerchantID = MysterMerchantVM.MerchantID
	self.FriendlinessLevel = MysterMerchantVM.FriendlinessLevel
	self.MoneySlot:UpdateView(ScoreID, false, nil, true)
	MysterMerchantMgr:PlayActionTimeline(self.MerchantID, MysterMerchantDefine.EATLType.ShopIdle)
	MysterMerchantMgr:PlayBubble(self.MerchantID, MysterMerchantDefine.EBubbleType.Shop)
	self.GoodImpression:UpdateLevel(self.FriendlinessLevel)
	UIUtil.SetIsVisible(self.TextGoodImpression, false) -- 弃用，文本需要动态修改，不能用两个一起显示
end

function MysterMechantMainPanelView:OnHide()
	MysterMerchantMgr:PlayActionTimeline(self.MerchantID, MysterMerchantDefine.EATLType.FinishTaskIdle)
end

function MysterMechantMainPanelView:OnRegisterUIEvent()

end

function MysterMechantMainPanelView:OnRegisterGameEvent()

end

function MysterMechantMainPanelView:OnRegisterBinder()
	self:RegisterBinders(MysterMerchantVM, self.Binders)
end

function MysterMechantMainPanelView:SetLSTR()
	self.TextTitle:SetText(_G.LSTR(1110045)) -- 1110045("冒险游商团")
end

function MysterMechantMainPanelView:OnSelectedChanged(Index, ItemData, ItemView)
	-- local GoodsInfo = MysterMerchantUtils.GetGoodsInfo(ItemData.GoodsId)
	-- if GoodsInfo then
	-- 	_G.ShopMgr.CurOpenMallId = GoodsInfo.MallID
	-- end
	ItemData.BuyCallback = self.ConfirmBuy
	UIViewMgr:ShowView(UIViewID.MysterMerchantBuyPropsWinView, ItemData)
end

function MysterMechantMainPanelView.ConfirmBuy(GoodsId, Count)
	MysterMerchantMgr:SendMsgBuyGoodsReq(GoodsId, Count)
end

function MysterMechantMainPanelView:OnEXPPercentChanged(Percent)
	self.GoodImpression.ImgProgressFull:SetPercent(Percent)
	local Angle = Percent * 360
	self.GoodImpression.PanelProgressLight:SetRenderTransformAngle(Angle)
end

return MysterMechantMainPanelView