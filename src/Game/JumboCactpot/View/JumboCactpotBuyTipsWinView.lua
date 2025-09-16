---
--- Author: Administrator
--- DateTime: 2023-09-18 09:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LSTR = _G.LSTR

---@class JumboCactpotBuyTipsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel UFButton
---@field BtnCancel02 UFButton
---@field BtnYes UFButton
---@field PlayStyleCommFrameS_UIBP PlayStyleCommFrameSView
---@field RichText01 URichTextBox
---@field TextCancel UFTextBlock
---@field TextCancel02 UFTextBlock
---@field TextYes UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotBuyTipsWinView = LuaClass(UIView, true)

function JumboCactpotBuyTipsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnCancel02 = nil
	--self.BtnYes = nil
	--self.PlayStyleCommFrameS_UIBP = nil
	--self.RichText01 = nil
	--self.TextCancel = nil
	--self.TextCancel02 = nil
	--self.TextYes = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotBuyTipsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayStyleCommFrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotBuyTipsWinView:OnInit()
	self.ConfirmCallBack = nil

	-- self.Binders = {
	-- 	{ "OwnJDNum", UIBinderSetTextFormatForMoney.New(self, self.PlayStyleCommFrameS_UIBP.CommCurrency01.TextAmount)},
    --     { "XCTicksNum", UIBinderSetText.New(self, self.PlayStyleCommFrameS_UIBP.CommCurrency02.TextAmount)},
	-- }
end

function JumboCactpotBuyTipsWinView:OnDestroy()

end

function JumboCactpotBuyTipsWinView:OnShow()
	local Params = self.Params
	self.PlayStyleCommFrameS_UIBP.RichTextBox_Title:SetText(Params.Title)
	self.ConfirmCallBack = Params.CallBack
	self.CallBackParams = Params.CallBackParams
	local bShowTwoBtn = Params.bShowTwoBtn
	local bSingleConfirmOrCancel = Params.bSingleConfirmOrCancel
	if bShowTwoBtn then
		UIUtil.SetIsVisible(self.BtnCancel, true, true)
		UIUtil.SetIsVisible(self.BtnYes, true, true)
		UIUtil.SetIsVisible(self.BtnCancel02, false, false)
	else
		UIUtil.SetIsVisible(self.BtnCancel, false, false)
		UIUtil.SetIsVisible(self.BtnYes, false, false)
		UIUtil.SetIsVisible(self.BtnCancel02, true, true)
	end
	self.RichText01:SetText(Params.Content)
	local SingleBtnName = bSingleConfirmOrCancel and LSTR(240052) or LSTR(10039) -- 确 定	 10039 = 好 的
	self.TextCancel02:SetText(SingleBtnName)

	self.TextYes:SetText(LSTR(240052)) -- 确 定
	self.TextCancel:SetText(LSTR(240053)) -- 取 消
end

function JumboCactpotBuyTipsWinView:OnHide()
	
end

function JumboCactpotBuyTipsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnHideViewClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel02, self.OnHideViewClick)
	UIUtil.AddOnClickedEvent(self, self.BtnYes, self.OnBtnYesClick)
	UIUtil.AddOnClickedEvent(self, self.PlayStyleCommFrameS_UIBP.ButtonClose, self.OnHideViewClick)
end

function JumboCactpotBuyTipsWinView:OnRegisterGameEvent()

end

function JumboCactpotBuyTipsWinView:OnRegisterBinder()
    -- self:RegisterBinders(JumboCactpotVM, self.Binders)
end

function JumboCactpotBuyTipsWinView:OnHideViewClick()
	self:Hide()
end

function JumboCactpotBuyTipsWinView:OnBtnYesClick()
	if self.ConfirmCallBack ~= nil then
		self.ConfirmCallBack(self.CallBackParams)
	end

	self:Hide()
end

return JumboCactpotBuyTipsWinView