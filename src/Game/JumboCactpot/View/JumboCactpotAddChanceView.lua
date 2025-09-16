---
--- Author: Administrator
--- DateTime: 2023-09-18 09:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local JumboCactpotMgr = require("Game/JumboCactpot/JumboCactpotMgr")
local RichTextUtil = require("Utils/RichTextUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local LSTR = _G.LSTR

---@class JumboCactpotAddChanceView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel UFButton
---@field BtnYes UFButton
---@field CommSlot CommBackpack126SlotView
---@field CountSlider CommCountSliderView
---@field PlayStyleCommFrameM_UIBP PlayStyleCommFrameMView
---@field RichTextMake URichTextBox
---@field RichTextTime URichTextBox
---@field RichTextUse URichTextBox
---@field TextCancel UFTextBlock
---@field TextExchangeNumber UFTextBlock
---@field TextNumberBig UFTextBlock
---@field TextYes UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotAddChanceView = LuaClass(UIView, true)

function JumboCactpotAddChanceView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnYes = nil
	--self.CommSlot = nil
	--self.CountSlider = nil
	--self.PlayStyleCommFrameM_UIBP = nil
	--self.RichTextMake = nil
	--self.RichTextTime = nil
	--self.RichTextUse = nil
	--self.TextCancel = nil
	--self.TextExchangeNumber = nil
	--self.TextNumberBig = nil
	--self.TextYes = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotAddChanceView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSlot)
	self:AddSubView(self.CountSlider)
	self:AddSubView(self.PlayStyleCommFrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotAddChanceView:OnInit()
	JumboCactpotMgr.OneTimeExNum = 0
	self.bCanCountDown = false
	-- self.Binders = {
	-- 	--{ "OwnJDNum", UIBinderSetTextFormatForMoney.New(self, self.PlayStyleCommFrameM_UIBP.CommCurrency01.TextAmount)},
    --     { "XCTicksNum", UIBinderSetText.New(self, self.PlayStyleCommFrameM_UIBP.CommCurrency02.TextAmount)},
	-- }
end

function JumboCactpotAddChanceView:OnDestroy()

end

function JumboCactpotAddChanceView:OnShow()
	UIUtil.SetIsVisible(self.PlayStyleCommFrameM_UIBP.CommCurrency01, false, nil, true)
	self.PlayStyleCommFrameM_UIBP.FText_Title:SetText(LSTR(240014)) -- 购买提示

	local CurCanXCTickExNum = JumboCactpotMgr.CurCanXCTickExNum
	local XCTickNum = JumboCactpotMgr.XCTickNum
	--local MaxValue = XCTickNum <= 3 and XCTickNum or CurCanXCTickExNum
	local MaxValue = math.min(CurCanXCTickExNum, XCTickNum)
	if MaxValue == 0 then
		MaxValue = 1
	end
	self.CountSlider:SetSliderValueMaxMin(MaxValue, 0)
	local RichText = string.format(LSTR(240044), CurCanXCTickExNum) -- 本周剩余兑换次数: %s/3
	self.RichTextMake:SetText(RichText)

	local function OnValueChange(Value)
		JumboCactpotMgr.OneTimeExNum = Value
		self.TextNumberBig:SetText(tostring(Value))
		-- self.TextNumber:SetText(tostring(Value))
		local Text = string.format(LSTR(240045), Value) -- 仙彩购买次数 +%s
		self.RichTextTime:SetText(Text)

		local TempText1 = string.format(LSTR(240046), Value) -- %s张仙彩券
		local RichText1 = RichTextUtil.GetText(TempText1, "#af4c58")
		local TempText2 = string.format(LSTR(240047), Value) -- %s次购买次数
		local RichText2 = RichTextUtil.GetText(TempText2, "#af4c58")
		local UseText = string.format(LSTR(240048), RichText1, RichText2) -- 确定使用%s增加%s吗？
		self.RichTextUse:SetText(UseText)
		if self.bCanCountDown then
			local SliderVM = self.CountSlider.ViewModel
			SliderVM.Percent = JumboCactpotMgr.OneTimeExNum / MaxValue
		end

	end

	self.CountSlider:SetValueChangedCallback(OnValueChange)
	self.CountSlider:SetSliderValue(1)


	local function CaptureBegin()
		self.bCanCountDown = false
	end

	self.CountSlider:SetCaptureBeginCallBack(CaptureBegin)

	local function CaptureEnd()
		local SliderVM = self.CountSlider.ViewModel
		SliderVM.Percent = JumboCactpotMgr.OneTimeExNum / MaxValue
		self.bCanCountDown = true
	end
	self.CountSlider:SetCaptureEndCallBack(CaptureEnd)
	self:InitXCTickSlot()

	self.TextExchangeNumber:SetText(LSTR(240074)) -- 兑换数量
	self.TextCancel:SetText(LSTR(240053)) -- 取 消
	self.TextYes:SetText(LSTR(240075)) -- 兑 换
end

function JumboCactpotAddChanceView:OnHide()

end

function JumboCactpotAddChanceView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnYes, self.OnBtnConfirmClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnBtnCancelClick)
	UIUtil.AddOnClickedEvent(self, self.PlayStyleCommFrameM_UIBP.ButtonClose, self.OnBtnCancelClick)
	UIUtil.AddOnClickedEvent(self, self.PlayStyleCommFrameM_UIBP.CommCurrency02.BtnAdd, self.OnBtnAddXCTicketClicked)

end

function JumboCactpotAddChanceView:OnRegisterGameEvent()

end

function JumboCactpotAddChanceView:OnRegisterBinder()
    --self:RegisterBinders(JumboCactpotVM, self.Binders)
end

function JumboCactpotAddChanceView:OnBtnConfirmClick()
	if JumboCactpotMgr.OneTimeExNum == 0 then
		MsgTipsUtil.ShowActiveTips(LSTR(240049)) -- 兑换数量不能为0
		return
	end
	JumboCactpotMgr:XCTicketExchangePurNum(JumboCactpotMgr.OneTimeExNum)
	self:Hide()
end

function JumboCactpotAddChanceView:OnBtnCancelClick()
	self:Hide()
end

function JumboCactpotAddChanceView:OnBtnAddXCTicketClicked()
    JumboCactpotMgr:OnBtnAddXCTick()
end

function JumboCactpotAddChanceView:InitXCTickSlot()
	local XCTickID = ProtoRes.SCORE_TYPE.SCORE_TYPE_FAIRY_COLOR_COUPONS
	local Cfg = ItemCfg:FindCfgByKey(XCTickID)
	if Cfg ~= nil then
		local IconPath = ItemCfg.GetIconPath(Cfg.IconID)
		self.CommSlot:SetIconImg(IconPath)
		self.CommSlot:SetNum(1)
	else
		FLOG_ERROR("XCTikc Cfg = nil! ItemID = %d", XCTickID)
	end
	self.CommSlot:SetIconChooseVisible(false)
	self.CommSlot:SetItemLevel("")

	self.CommSlot:SetClickButtonCallback(self.CommSlot, function(TargetItemView)
		ItemTipsUtil.CurrencyTips(ProtoRes.SCORE_TYPE.SCORE_TYPE_FAIRY_COLOR_COUPONS, false, TargetItemView)
	end)
end
return JumboCactpotAddChanceView