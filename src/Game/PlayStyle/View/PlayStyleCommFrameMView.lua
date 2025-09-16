---
--- Author: Administrator
--- DateTime: 2023-09-18 14:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local JumboCactpotVM = require("Game/JumboCactpot/JumboCactpotVM")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local ProtoRes = require("Protocol/ProtoRes")

---@class PlayStyleCommFrameMView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonClose UFButton
---@field CommCurrency01 CommMoneySlotView
---@field CommCurrency02 CommMoneySlotView
---@field FText_Title UFTextBlock
---@field NamedSlotChild UNamedSlot
---@field PanelCurrency UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PlayStyleCommFrameMView = LuaClass(UIView, true)

function PlayStyleCommFrameMView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonClose = nil
	--self.CommCurrency01 = nil
	--self.CommCurrency02 = nil
	--self.FText_Title = nil
	--self.NamedSlotChild = nil
	--self.PanelCurrency = nil
	--self.PopUpBG = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PlayStyleCommFrameMView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommCurrency01)
	self:AddSubView(self.CommCurrency02)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PlayStyleCommFrameMView:OnInit()
	-- self.Binders = {
	-- 	{ "OwnJDNum", UIBinderSetTextFormatForMoney.New(self, self.CommCurrency01.TextMoneyAmount)},
    --     { "XCTicksNum", UIBinderSetText.New(self, self.CommCurrency02.TextMoneyAmount)},
	-- }

	self.View = nil
	self.CloseCallBack = nil
	self.CurrencyID1 = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE
	self.CurrencyID2 = ProtoRes.SCORE_TYPE.SCORE_TYPE_FAIRY_COLOR_COUPONS
	self.bShowBtnAdd1 = true
	self.bShowBtnAdd2 = true
end

function PlayStyleCommFrameMView:OnDestroy()

end

function PlayStyleCommFrameMView:OnShow()
	local IconPath = JumboCactpotDefine.IconPath

	local ScoreFirst = self.CurrencyID1
	if ScoreFirst then
		self.CommCurrency01:UpdateView(ScoreFirst, self.bShowBtnAdd1, -1, true)
	end

	local ScoreSecond = self.CurrencyID2
	if ScoreSecond then
		self.CommCurrency02:UpdateView(ScoreSecond, self.bShowBtnAdd2, -1, true)
	end

end

function PlayStyleCommFrameMView:OnHide()

end

function PlayStyleCommFrameMView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonClose, self.OnButtonCloseClick)
end

function PlayStyleCommFrameMView:OnRegisterGameEvent()

end

function PlayStyleCommFrameMView:OnRegisterBinder()
    -- self:RegisterBinders(JumboCactpotVM, self.Binders)
end

function PlayStyleCommFrameMView:OnButtonCloseClick()
	if self.CloseCallBack ~= nil then
		self.CloseCallBack(self.View)
	else
		self:Hide()
	end
end

function PlayStyleCommFrameMView:SetCloseCallBack(View, CallBack)
	self.View = View
	self.CloseCallBack = CallBack
end

function PlayStyleCommFrameMView:SetTitle(Title)
	local TitleWidget = self.FText_Title
	if not TitleWidget then
		return
	end
	TitleWidget:SetText(Title)
end

function PlayStyleCommFrameMView:SetCurrencyVisible(bVisible)
	UIUtil.SetIsVisible(self.PanelCurrency, bVisible)
end

function PlayStyleCommFrameMView:SetCurrency2Visible(bVisible)
	UIUtil.SetIsVisible(self.CommCurrency02, bVisible)
end

function PlayStyleCommFrameMView:SetCurrency1Type(ScoreType)
	self.CurrencyID1 = ScoreType
end

function PlayStyleCommFrameMView:SetCurrency2Type(ScoreType)
	self.CurrencyID2 = ScoreType
end

function PlayStyleCommFrameMView:SetCurrency1BtnAddVisible(bVisible)
	self.bShowBtnAdd1 = bVisible
end

function PlayStyleCommFrameMView:SetCurrency2BtnAddVisible(bVisible)
	self.bShowBtnAdd2 = bVisible
end


return PlayStyleCommFrameMView