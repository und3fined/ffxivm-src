---
--- Author: Administrator
--- DateTime: 2023-11-24 19:53
--- Description:匹配成功确认界面 已采用通用，此弃用
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")

---@class CardsTourneyMatchingView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnGo CommBtnLView
---@field PanelLable01 UFCanvasPanel
---@field PanelLable02 UFCanvasPanel
---@field PanelProBar UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field ProgressBarLoading UProgressBar
---@field TextCountDown UFTextBlock
---@field TextDescribe UFTextBlock
---@field TextLable01 UFTextBlock
---@field TextLable02 UFTextBlock
---@field VerticalDescribe UFVerticalBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyMatchingView = LuaClass(UIView, true)

function CardsTourneyMatchingView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnGo = nil
	--self.PanelLable01 = nil
	--self.PanelLable02 = nil
	--self.PanelProBar = nil
	--self.PopUpBG = nil
	--self.ProgressBarLoading = nil
	--self.TextCountDown = nil
	--self.TextDescribe = nil
	--self.TextLable01 = nil
	--self.TextLable02 = nil
	--self.VerticalDescribe = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyMatchingView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnGo)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyMatchingView:OnInit()
	self.Binders = {
		--{"LevelLimit", UIBinderSetText.New(self, self.TextLable01) },
		{"AutoCancelCDPercent", UIBinderSetPercent.New(self, self.ProgressBarLoading) },
		--{"TourneyDescribe", UIBinderSetText.New(self, self.TextDescribe) },
		{"AutoCancelCDTip", UIBinderSetText.New(self, self.TextCountDown) },
	}
end

function CardsTourneyMatchingView:OnDestroy()

end

function CardsTourneyMatchingView:OnShow()

end

function CardsTourneyMatchingView:OnHide()

end

function CardsTourneyMatchingView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,self.BtnCancel,self.CancelEnterTourneyClicked)
	UIUtil.AddOnClickedEvent(self,self.BtnGo,self.EnterTourney)
end

function CardsTourneyMatchingView:OnRegisterGameEvent()

end

function CardsTourneyMatchingView:OnRegisterBinder()
	if TourneyVM then
		self:RegisterBinders(TourneyVM, self.Binders)
	end
end

function CardsTourneyMatchingView:CancelEnterTourneyClicked()
	self:Hide()
	if MagicCardTourneyMgr then
		MagicCardTourneyMgr:OnCancelEnter()
	end
end

function CardsTourneyMatchingView:EnterTourney()
	self:Hide()
	if MagicCardTourneyMgr then
		MagicCardTourneyMgr:OnConfirmEnterTourney()
	end
end

return CardsTourneyMatchingView