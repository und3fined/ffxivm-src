---
--- Author: Administrator
--- DateTime: 2024-09-09 14:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local LSTR = _G.LSTR

---@class GoldSauserMainPanelExchangeWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnNormal UFButton
---@field BtnRecom UFButton
---@field Comm126Slot1 CommBackpack126SlotView
---@field Comm126Slot2 CommBackpack126SlotView
---@field RichTextHint URichTextBox
---@field TextCancel UFTextBlock
---@field TextConfirm UFTextBlock
---@field TextGold UFTextBlock
---@field TextGoldSauser UFTextBlock
---@field WinBG PlayStyleCommFrameMView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelExchangeWinView = LuaClass(UIView, true)

function GoldSauserMainPanelExchangeWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnNormal = nil
	--self.BtnRecom = nil
	--self.Comm126Slot1 = nil
	--self.Comm126Slot2 = nil
	--self.RichTextHint = nil
	--self.TextCancel = nil
	--self.TextConfirm = nil
	--self.TextGold = nil
	--self.TextGoldSauser = nil
	--self.WinBG = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelExchangeWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm126Slot1)
	self:AddSubView(self.Comm126Slot2)
	self:AddSubView(self.WinBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelExchangeWinView:InitConstStringInfo()
	self.TextCancel:SetText(LSTR(350048))
	self.TextConfirm:SetText(LSTR(350049))
end

function GoldSauserMainPanelExchangeWinView:OnInit()
	self:InitConstStringInfo()
end

function GoldSauserMainPanelExchangeWinView:OnDestroy()

end

function GoldSauserMainPanelExchangeWinView:OnShow()
	local Params = self.Params
	
	if Params.Title ~= nil then
		self.WinBG:SetTitle(Params.Title)
	end
	self.ConfirmCallBack = Params.ConfirmCallBack
	self.CancelCallBack = Params.CancelCallBack
	self.ConfirmParams = Params.ConfirmParams
	self.CancleParams = Params.CancelParams

	self:UpdateCurrencyExchangeInfo(Params.SrcScoreType, Params.SrcScoreValue, Params.DstScoreType, Params.DstScoreValue)
end

function GoldSauserMainPanelExchangeWinView:OnHide()
	
end

function GoldSauserMainPanelExchangeWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRecom, self.OnBtnYesClick)
	UIUtil.AddOnClickedEvent(self, self.BtnNormal, self.OnBtnNoClick)
end

function GoldSauserMainPanelExchangeWinView:OnRegisterGameEvent()

end

function GoldSauserMainPanelExchangeWinView:OnRegisterBinder()
	local WinBG = self.WinBG
	WinBG:SetCurrency1Type(SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
	WinBG:SetCurrency2Type(SCORE_TYPE.SCORE_TYPE_KING_DEE)
	WinBG:SetCurrency1BtnAddVisible(false)
	WinBG:SetCurrency2BtnAddVisible(false)
end

function GoldSauserMainPanelExchangeWinView:OnBtnYesClick()
	if self.ConfirmCallBack ~= nil then
		self.ConfirmCallBack(self.View, self.ConfirmParams)
	end
	self:Hide()
end

function GoldSauserMainPanelExchangeWinView:OnBtnNoClick()
	if self.CancelCallBack ~= nil then
		self.CancelCallBack(self.View, self.CancleParams)
	end
	self:Hide()
end

--- 刷新货币兑换面板
function GoldSauserMainPanelExchangeWinView:UpdateCurrencyExchangeInfo(SrcScoreType,
    SrcScoreValue,
    DstScoreType,
    DstScoreValue)

	local SrcScoreName = ScoreMgr:GetScoreNameText(SrcScoreType) or ""
	local DstScoreName = ScoreMgr:GetScoreNameText(DstScoreType) or ""
	--<span color=\"#d1ba8e\">%s方%s米</>
	self.RichTextHint:SetText(
		string.format(LSTR(350027)
		, tostring(SrcScoreValue), SrcScoreName, tostring(DstScoreValue), DstScoreName))

	local SrcCurrencyWidget = self.Comm126Slot1
	if SrcCurrencyWidget then
		local SrcIconName = ScoreMgr:GetScoreIconName(SrcScoreType)
		SrcCurrencyWidget:SetIconImg(SrcIconName)
		SrcCurrencyWidget:SetNumVisible(true)
		SrcCurrencyWidget:SetNum(SrcScoreValue)
		SrcCurrencyWidget:SetItemLevel("")
		SrcCurrencyWidget:SetIconChooseVisible(false)
	 	SrcCurrencyWidget:SetClickButtonCallback(SrcCurrencyWidget, function(View)
			ItemTipsUtil.ShowTipsByResID(SrcScoreType, View)
		end)
	end

	local DstCurrencyWidget = self.Comm126Slot2
	if DstCurrencyWidget then
		local DstIconName = ScoreMgr:GetScoreIconName(DstScoreType)
		DstCurrencyWidget:SetIconImg(DstIconName)
		DstCurrencyWidget:SetNumVisible(true)
		DstCurrencyWidget:SetNum(DstScoreValue)
		DstCurrencyWidget:SetItemLevel("")
		DstCurrencyWidget:SetIconChooseVisible(false)
		DstCurrencyWidget:SetClickButtonCallback(DstCurrencyWidget, function(View)
			ItemTipsUtil.ShowTipsByResID(DstScoreType, View)
		end)
	end

	self.TextGold:SetText(SrcScoreName)
	self.TextGoldSauser:SetText(DstScoreName)
end

return GoldSauserMainPanelExchangeWinView