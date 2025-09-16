---
--- Author: Administrator
--- DateTime: 2024-05-28 11:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local JumboCactpotVM = require("Game/JumboCactpot/JumboCactpotVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local EventID = _G.EventID
---@class JumboCactpotInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFold UToggleButton
---@field BtnTips CommInforBtnView
---@field ImgDown UFImage
---@field ImgType UFImage
---@field ImgUp UFImage
---@field PanelBuy UFCanvasPanel
---@field PanelCountDown_1 UFCanvasPanel
---@field PanelGateInfo UFCanvasPanel
---@field PanelSummary UFCanvasPanel
---@field PanelTicket UFCanvasPanel
---@field RichTextBuyTime URichTextBox
---@field RichTextTicket URichTextBox
---@field TextName UFTextBlock
---@field TextSummary UFTextBlock
---@field TextTime_1 UFTextBlock
---@field TextUntilTime UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotInfoPanelView = LuaClass(UIView, true)

function JumboCactpotInfoPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFold = nil
	--self.BtnTips = nil
	--self.ImgDown = nil
	--self.ImgType = nil
	--self.ImgUp = nil
	--self.PanelBuy = nil
	--self.PanelCountDown_1 = nil
	--self.PanelGateInfo = nil
	--self.PanelSummary = nil
	--self.PanelTicket = nil
	--self.RichTextBuyTime = nil
	--self.RichTextTicket = nil
	--self.TextName = nil
	--self.TextSummary = nil
	--self.TextTime_1 = nil
	--self.TextUntilTime = nil
	--self.AnimIn = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotInfoPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotInfoPanelView:OnInit()
	self.LastCheck = false
	self.Binders = {
		{ "BuyCountText", UIBinderSetText.New(self, self.RichTextBuyTime)},
		{ "BuyCountVisible", UIBinderSetIsVisible.New(self, self.PanelBuy)},

		{ "XCTickNumText", UIBinderSetText.New(self, self.RichTextTicket)},
		{ "XCTickNumVisible", UIBinderSetIsVisible.New(self, self.PanelTicket)},

		{ "RemainTimeText", UIBinderSetText.New(self, self.TextTime_1)},
		{ "RemainTimeVisible", UIBinderSetIsVisible.New(self, self.PanelCountDown_1)},

		{ "InfoDescText", UIBinderSetText.New(self, self.TextSummary)},
    }

end

function JumboCactpotInfoPanelView:OnDestroy()

end

function JumboCactpotInfoPanelView:OnShow()
	self.TextName:SetText(_G.LSTR(240060)) -- 仙人仙彩
	self:SetCheckState()
end

function JumboCactpotInfoPanelView:OnHide()

end

function JumboCactpotInfoPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFold, self.OnBtnFoldClicked)

end

function JumboCactpotInfoPanelView:OnRegisterGameEvent()
end

function JumboCactpotInfoPanelView:OnRegisterBinder()
	self:RegisterBinders(JumboCactpotVM, self.Binders)
end

function JumboCactpotInfoPanelView:SetCheckState()
	self.LastCheck = true
	self:OnBtnFoldClicked()
end

function JumboCactpotInfoPanelView:OnBtnFoldClicked()
	local NeedCheck = not self.LastCheck
	self.BtnFold:SetIsChecked(NeedCheck)
	self.LastCheck = NeedCheck

	local bInfoVisible = not NeedCheck
	local MainPanelVM = require("Game/Main/MainPanelVM")
	local MainPanelConfig = require("Game/Main/MainPanelConfig")

	UIUtil.SetIsVisible(self.PanelGateInfo, bInfoVisible)
	MainPanelVM:SetFunctionVisible(not bInfoVisible, MainPanelConfig.TopRightInfoType.JumboInfo)
	if (bInfoVisible) then
        self:PlayAnimation(self.AnimUnfold)
    end
end


return JumboCactpotInfoPanelView