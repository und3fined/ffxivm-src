---
--- Author: Administrator
--- DateTime: 2023-11-30 14:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local BuddyUseAccelerateWinVM = require("Game/Buddy/VM/BuddyUseAccelerateWinVM")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local BuddyMgr
local LSTR

---@class BuddyUseAccelerateWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btnaccelerate CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommCurrency CommMoneySlotView
---@field CommSlot CommBackpack126SlotView
---@field EFF UFCanvasPanel
---@field HorizontalUseCoin UFHorizontalBox
---@field ProbarOrange UProgressBar
---@field ProbarYellow UProgressBar
---@field RichTextTips URichTextBox
---@field RichTextUseCoin_2 URichTextBox
---@field TextAccelerate UFTextBlock
---@field TextAccelerateCountDown UFTextBlock
---@field TextCountDown UFTextBlock
---@field TextSlotName UFTextBlock
---@field TextTime UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimMaxSpeedLightLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProBarYellow UWidgetAnimation
---@field AnimProBarYellowControl UWidgetAnimation
---@field ValueAnimProBarYellowStart float
---@field ValueAnimProBarYellowEnd float
---@field ValueAnimProBarYellow float
---@field CurveAnimProgressBar CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddyUseAccelerateWinView = LuaClass(UIView, true)

function BuddyUseAccelerateWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btnaccelerate = nil
	--self.Comm2FrameM_UIBP = nil
	--self.CommCurrency = nil
	--self.CommSlot = nil
	--self.EFF = nil
	--self.HorizontalUseCoin = nil
	--self.ProbarOrange = nil
	--self.ProbarYellow = nil
	--self.RichTextTips = nil
	--self.RichTextUseCoin_2 = nil
	--self.TextAccelerate = nil
	--self.TextAccelerateCountDown = nil
	--self.TextCountDown = nil
	--self.TextSlotName = nil
	--self.TextTime = nil
	--self.AnimIn = nil
	--self.AnimMaxSpeedLightLoop = nil
	--self.AnimOut = nil
	--self.AnimProBarYellow = nil
	--self.AnimProBarYellowControl = nil
	--self.ValueAnimProBarYellowStart = nil
	--self.ValueAnimProBarYellowEnd = nil
	--self.ValueAnimProBarYellow = nil
	--self.CurveAnimProgressBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddyUseAccelerateWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btnaccelerate)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CommCurrency)
	self:AddSubView(self.CommSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddyUseAccelerateWinView:OnInit()
	BuddyMgr = _G.BuddyMgr
	LSTR = _G.LSTR
	self.ViewModel = BuddyUseAccelerateWinVM

	self.Binders = {
		{ "AccelerateProgressPercent", UIBinderSetPercent.New(self, self.ProbarOrange) },
		{ "NormalProgressPercent", UIBinderSetPercent.New(self, self.ProbarYellow) },
		{ "AccelerateTimeText", UIBinderSetText.New(self, self.TextAccelerateCountDown) },
		{ "CDTimeText", UIBinderSetText.New(self, self.TextTime) },
		{ "ItemDesc", UIBinderSetText.New(self, self.TextSlotName) },
		{ "Desc", UIBinderSetText.New(self, self.RichTextTips) },
		
		{ "UseCoinVisible", UIBinderSetIsVisible.New(self, self.HorizontalUseCoin) },
		{ "UseCoinDescText", UIBinderSetText.New(self, self.RichTextUseCoin_2) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgCoin)},

		{ "EFFVisible", UIBinderSetIsVisible.New(self, self.EFF) },

		{ "BtnaccelerateEnabled",UIBinderSetIsEnabled.New(self,self.Btnaccelerate, false , true)}, 
	}
end

function BuddyUseAccelerateWinView:OnDestroy()

end

function BuddyUseAccelerateWinView:OnShow()
	if self.ViewModel then
		self.ViewModel:UpdateVM()
	end
	self:OnMoneyUpdate()
	self:PlayAnimation(self.AnimMaxSpeedLightLoop, 0, 0)
end

function BuddyUseAccelerateWinView:OnHide()
	self:StopAnimation(self.AnimMaxSpeedLightLoop)
end

function BuddyUseAccelerateWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btnaccelerate.Button, self.OnClickedAccelerateBtn)
	UIUtil.AddOnClickedEvent(self, self.CommSlot.Btn, self.OnBtnSlotClick)
end

function BuddyUseAccelerateWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BuddyCDOnTime, self.OnUpdateBuddyCDOnTime)
	self:RegisterGameEvent(EventID.ScoreUpdate, self.OnMoneyUpdate)
end

function BuddyUseAccelerateWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.CommSlot:SetParams({Data = self.ViewModel.ItemVM})

	self.Comm2FrameM_UIBP:SetTitleText(LSTR(1000062))
	self.TextCountDown:SetText(LSTR(1000063))
	self.TextAccelerate:SetText(LSTR(1000064))
	self.Btnaccelerate:SetText(LSTR(1000011))
end

function BuddyUseAccelerateWinView:OnMoneyUpdate()
	if self.ViewModel == nil then
		return
	end
	local ScoreID = self.ViewModel:GetItemAccelerateCoin()
	self.CommCurrency:UpdateView(ScoreID, false, UIViewID.BuddyUseAccelerateWin, true)
	self.ViewModel.NeedRefresh = true
end

function BuddyUseAccelerateWinView:OnUpdateBuddyCDOnTime()
	local LetfTime = BuddyMgr:GetSurfaceCDTime()
	if  LetfTime > 0 then
		self.ViewModel:SetCDOnTime()
	else
		self:Hide()
	end
end

function BuddyUseAccelerateWinView:OnClickedAccelerateBtn() 
	if self.ViewModel.BtnaccelerateEnabled == false then
		_G.MsgTipsUtil.ShowTips(LSTR(1000071))
		return
	end 
	if self.AccelerateAni then
		return
	end
	self.ValueAnimProBarYellowStart = math.clamp(self.ViewModel.NormalProgressPercent, 0, 1)
	self.ValueAnimProBarYellowEnd = math.clamp(self.ViewModel.AccelerateProgressPercent, 0, 1)
	self:PlayAnimation(self.AnimProBarYellowControl)
	self.AccelerateAni = true
end

function BuddyUseAccelerateWinView:OnAnimationFinished(Animation)
	if Animation == self.AnimProBarYellowControl then
		self.AccelerateAni = false
		self:StopAnimation(self.AnimProBarYellow)
		local ConsumeCoin = 1
		if self.ViewModel.UseCoinVisible == true then
			ConsumeCoin = 0
		end
		BuddyMgr:ReqReduceCD(BuddyMgr.SurfaceViewCurID, ConsumeCoin, BuddyMgr.AccelerateItemID)
		if self.ViewModel.EFFVisible == true then
			self:Hide()
		end
	end
end

function BuddyUseAccelerateWinView:SequenceEvent_AnimProBarYellow()
	self.ViewModel.NormalProgressPercent = self.ValueAnimProBarYellow
	if self.ValueAnimProBarYellow > self.ValueAnimProBarYellowEnd then
		self.ViewModel.NormalProgressPercent = self.ValueAnimProBarYellowEnd
	end
end

function BuddyUseAccelerateWinView:OnBtnSlotClick()
	ItemTipsUtil.ShowTipsByResID(BuddyMgr.AccelerateItemID, self.CommSlot)
end


return BuddyUseAccelerateWinView