---
--- Author: v_vvxinchen
--- DateTime: 2025-06-30 09:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local LSTR = _G.LSTR

---@class OpsSkiFreePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy OpsCommBtnLView
---@field CommBackBtn CommBackBtnView
---@field CommonTitle CommonTitleView
---@field FreePoster1 OpsSkiFreeItemView
---@field FreePoster2 OpsSkiFreeItemView
---@field FreePoster3 OpsSkiFreeItemView
---@field OpsCommMoney OpsCommMoneySlotView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsSkiFreePanelView = LuaClass(UIView, true)

function OpsSkiFreePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.CommBackBtn = nil
	--self.CommonTitle = nil
	--self.FreePoster1 = nil
	--self.FreePoster2 = nil
	--self.FreePoster3 = nil
	--self.OpsCommMoney = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsSkiFreePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.CommBackBtn)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.FreePoster1)
	self:AddSubView(self.FreePoster2)
	self:AddSubView(self.FreePoster3)
	self:AddSubView(self.OpsCommMoney)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsSkiFreePanelView:OnInit()
	self.BtnBuy.BtnText = LSTR(100040) --立即购买
end

function OpsSkiFreePanelView:OnDestroy()

end

function OpsSkiFreePanelView:OnShow()
	self.CommonTitle:SetTextTitleName(LSTR(100128)) --套装三选一
	local ViewModel = self.Params.ViewModel
	self.ViewModel = ViewModel
	for i = 1, 3 do
		self["FreePoster"..i]:SetParams({SuitData = ViewModel.SuitData[i], ViewModel = ViewModel})
	end
	local SelectedSuitGoodsID = ViewModel.SelectedSuitGoodsID
	local GoodsID = SelectedSuitGoodsID ~= 0 and SelectedSuitGoodsID or ViewModel.SuitData[1].GoodsID
	ViewModel:OnSelectedSuit(GoodsID)
end

function OpsSkiFreePanelView:OnHide()
	self.ViewModel:SaveSelectedSuit()
end

function OpsSkiFreePanelView:OnRegisterUIEvent()
	self.CommBackBtn:AddBackClick(self.CommBackBtn, self.OnClickedBackBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy.CommBtnL, self.OnClickedBtnBuy)
end

function OpsSkiFreePanelView:OnClickedBackBtn()
	_G.UIViewMgr:HideView(_G.UIViewID.OpsSkiFreePanel)
end

function OpsSkiFreePanelView:OnClickedBtnBuy()
	local TimeStamp = TimeUtil.GetServerLogicTime()
	local EndTime = self.Params:GetActivityTimeCountdown()
	if EndTime <= TimeStamp then
		--活动结束后，点击购买不响应
		return
	end
	self.ViewModel:BuyNow()
end

function OpsSkiFreePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsSkiSelectSuit, self.OnSelectSuit)
end

function OpsSkiFreePanelView:OnSelectSuit(GoodsID)
	self.BtnBuy:SetBtnPriceByGoodsID(GoodsID, true)
end

function OpsSkiFreePanelView:OnRegisterBinder()

end

return OpsSkiFreePanelView