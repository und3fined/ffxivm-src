---
--- Author: Administrator
--- DateTime: 2023-09-18 09:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local JumboCactpotMgr = require("Game/JumboCactpot/JumboCactpotMgr")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local LSTR = _G.LSTR

---@class JumboCactpotBuyWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel UFButton
---@field BtnYes UFButton
---@field InputItem01 JumboCactpotInputItemView
---@field InputItem02 JumboCactpotInputItemView
---@field InputItem03 JumboCactpotInputItemView
---@field InputItem04 JumboCactpotInputItemView
---@field PlayStyleCommFrameM_UIBP PlayStyleCommFrameMView
---@field RichText01 URichTextBox
---@field TextCancel UFTextBlock
---@field TextYes UFTextBlock
---@field ToggleGroupInput UToggleGroup
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotBuyWinView = LuaClass(UIView, true)

function JumboCactpotBuyWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnYes = nil
	--self.InputItem01 = nil
	--self.InputItem02 = nil
	--self.InputItem03 = nil
	--self.InputItem04 = nil
	--self.PlayStyleCommFrameM_UIBP = nil
	--self.RichText01 = nil
	--self.TextCancel = nil
	--self.TextYes = nil
	--self.ToggleGroupInput = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotBuyWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.InputItem01)
	self:AddSubView(self.InputItem02)
	self:AddSubView(self.InputItem03)
	self:AddSubView(self.InputItem04)
	self:AddSubView(self.PlayStyleCommFrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotBuyWinView:OnInit()
	self.InputItems = {
		self.InputItem01,
	    self.InputItem02,
		self.InputItem03,
		self.InputItem04,
	}

	-- self.Binders = {
	-- 	{ "OwnJDNum", UIBinderSetTextFormatForMoney.New(self, self.PlayStyleCommFrameM_UIBP.CommCurrency01.TextAmount)},
	-- }
end

function JumboCactpotBuyWinView:OnDestroy()

end

function JumboCactpotBuyWinView:OnShow()
	self.PlayStyleCommFrameM_UIBP.FText_Title:SetText(LSTR(240054)) -- 购买确认
	UIUtil.SetIsVisible(self.PlayStyleCommFrameM_UIBP.CommCurrency02, false)
	local Params = self.Params
	if Params == nil then
		return
	end
	local NeedJdNum = Params.JdCoinNum
	local InputItems = Params.InputItems
	local NeedJdNumRichText = RichTextUtil.GetText(NeedJdNum, "#af4c58")
	local CurrentNumber = ""
    for i = 1, 4 do
        CurrentNumber = string.format("%s%s", CurrentNumber, tostring(InputItems[i].number))
    end
	local PurNumRichText = RichTextUtil.GetText(string.format("【%s】", CurrentNumber), "#af4c58")
	self.RichText01:SetText(string.format(LSTR(240055), NeedJdNumRichText, PurNumRichText)) -- 确定要以%s金碟币的价格购买%s号仙人仙彩吗？"

	for i = 1, #InputItems do
		local Elem = InputItems[i]
		local path = tostring(JumboCactpotDefine.ChangeNumberPath(Elem.number))
		UIUtil.ImageSetBrushFromAssetPath(self.InputItems[i].IconNumber, path)
	end
	self.ToggleGroupInput:SetCheckedIndex(-1)
	self.ToggleGroupInput:SetIsEnabled(false)

	self.TextYes:SetText(LSTR(240052)) -- 确 定
	self.TextCancel:SetText(LSTR(240053)) -- 取 消
end

function JumboCactpotBuyWinView:OnHide()

end

function JumboCactpotBuyWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnHideVIewClick)
	UIUtil.AddOnClickedEvent(self, self.BtnYes, self.OnBtnYesClick)
	UIUtil.AddOnClickedEvent(self, self.PlayStyleCommFrameM_UIBP.ButtonClose, self.OnHideVIewClick)
	UIUtil.AddOnClickedEvent(self, self.PlayStyleCommFrameM_UIBP.CommCurrency01.BtnAdd, self.OnBtnAddJDCoinClicked)

end

function JumboCactpotBuyWinView:OnRegisterGameEvent()

end

function JumboCactpotBuyWinView:OnRegisterBinder()
    -- self:RegisterBinders(JumboCactpotVM, self.Binders)
end

--- @type 点击出现增加金碟币提示
function JumboCactpotBuyWinView:OnBtnAddJDCoinClicked()
    -- local ScoreType = ProtoRes.SCORE_TYPE
    -- local JDCoinID = ScoreType.SCORE_TYPE_KING_DEE
    -- local FunDesc = JumboCactpotMgr:GetAccessByID(JDCoinID)
    local Content = LSTR(240056) -- 参与金碟游乐场玩法可获取金碟币
    JumboCactpotMgr:ShowCommTips(LSTR(240014), Content, JumboCactpotMgr.OnGoGetJDCoinCallBack, nil, false) -- 购买提示
end

function JumboCactpotBuyWinView:OnHideVIewClick()
	self:Hide()
end

function JumboCactpotBuyWinView:OnBtnYesClick()
	JumboCactpotMgr:OnPurchasedCallBack()
	self:Hide()
end

return JumboCactpotBuyWinView