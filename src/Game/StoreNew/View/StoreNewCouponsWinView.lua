---
--- Author: ds_tianjiateng
--- DateTime: 2024-12-18 15:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local StoreDefine = require("Game/Store/StoreDefine")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormatForScore = require("Binder/UIBinderSetTextFormatForScore")
local StoreMgr = require("Game/Store/StoreMgr")

---@class StoreNewCouponsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommBtnL_UIBP CommBtnLView
---@field PanelMoney UFHorizontalBox
---@field PanelOriginalPrice UFCanvasPanel
---@field RichTextPrice URichTextBox
---@field TableViewCoupons UTableView
---@field TextOriginalPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreCouponsWinView = LuaClass(UIView, true)

function StoreCouponsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameM_UIBP = nil
	--self.CommBtnL_UIBP = nil
	--self.PanelMoney = nil
	--self.PanelOriginalPrice = nil
	--self.RichTextPrice = nil
	--self.TableViewCoupons = nil
	--self.TextOriginalPrice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreCouponsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CommBtnL_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreCouponsWinView:OnInit()
	self.AdapterTreeViewTabs = UIAdapterTableView.CreateAdapter(self, self.TableViewCoupons, self.OnTableViewCouponsSelectChanged)

	self.Binders =
	{
		{"BuyPrice", 		UIBinderSetTextFormatForScore.New(self, self.RichTextPrice)},
        {"RawPrice", 		UIBinderSetTextFormatForScore.New(self, self.TextOriginalPrice)},
		{"bShowRawPrice", 		UIBinderSetIsVisible.New(self, self.PanelOriginalPrice) },
	}

	self.BuyPriceVM = StoreMgr:GetBuyPriceVM()
end

function StoreCouponsWinView:OnDestroy()

end

function StoreCouponsWinView:OnShow()
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(StoreDefine.LSTRTextKey.ChooseCoupons))	--- 选择优惠券
	self.CommBtnL_UIBP:SetButtonText(LSTR(950033))	--- 确认
	self.AdapterTreeViewTabs:UpdateAll(_G.StoreMainVM.CouponList)
end

function StoreCouponsWinView:OnHide()

end

function StoreCouponsWinView:OnRegisterUIEvent()

end

function StoreCouponsWinView:OnRegisterGameEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtnL_UIBP.Button, self.OnClickBtnSubMit)
end

function StoreCouponsWinView:OnClickBtnSubMit()
	self:Hide()
end

function StoreCouponsWinView:OnRegisterBinder()
	self:RegisterBinders(self.BuyPriceVM, self.Binders)
end

return StoreCouponsWinView