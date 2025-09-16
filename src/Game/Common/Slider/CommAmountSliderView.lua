---
--- Author: Administrator
--- DateTime: 2023-11-16 12:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIBinderSetIsDisabledState = require("Binder/UIBinderSetIsDisabledState")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local CommAmountSliderVM = require("Game/Common/Slider/CommAmountSliderVM")

---@class CommAmountSliderView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field BtnNumber1 UFButton
---@field BtnNumber2 UFButton
---@field BtnSub UFButton
---@field NumberPanel1 UCanvasPanel
---@field NumberPanel1_1 UCanvasPanel
---@field SliderHorizontal CommSliderHorizontalView
---@field TextLeast UFTextBlock
---@field TextLeast_1 UFTextBlock
---@field TextLeast_2 UFTextBlock
---@field TextMax UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommAmountSliderView = LuaClass(UIView, true)

function CommAmountSliderView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.BtnNumber1 = nil
	--self.BtnNumber2 = nil
	--self.BtnSub = nil
	--self.NumberPanel1 = nil
	--self.NumberPanel1_1 = nil
	--self.SliderHorizontal = nil
	--self.TextLeast = nil
	--self.TextLeast_1 = nil
	--self.TextLeast_2 = nil
	--self.TextMax = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommAmountSliderView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SliderHorizontal)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommAmountSliderView:OnInit()
	self.ViewModel = CommAmountSliderVM.New()
	self.MaxValueTips = nil
	self.MinValueTips = nil
end

function CommAmountSliderView:OnDestroy()

end

function CommAmountSliderView:OnShow()
	self.SliderHorizontal:SetValueChangedCallback(function (v)
		self:OnValueChangedSlider(v)
	end)
end

function CommAmountSliderView:OnHide()

end

function CommAmountSliderView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnClickedAddBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnSub, self.OnClickedSubBtn)
end

function CommAmountSliderView:OnRegisterGameEvent()

end

function CommAmountSliderView:OnRegisterBinder()
	local Binders = {
		{"Percent", UIBinderSetSlider.New(self, self.SliderHorizontal)},
		{ "AddBtnEnabled", UIBinderSetIsDisabledState.New(self,self.BtnAdd, true, true)},
		{ "SubBtnEnabled", UIBinderSetIsDisabledState.New(self,self.BtnSub, true, true)},

		{ "SilderEnabled", UIBinderSetIsEnabled.New(self,self.SliderHorizontal)},

	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function CommAmountSliderView:SetSliderValueMaxMin(MaxValue, MinValue)
	self.ViewModel:SetSliderValueMaxMin(MaxValue, MinValue)
	self.TextMax:SetText(MaxValue)
	self.TextLeast:SetText(MinValue)
	
	if self.ViewModel.Percent == 1 then
		self:SetSliderClickVisible(false)
	else
		self:SetSliderClickVisible(true)
	end
end

function CommAmountSliderView:SetSliderValueMaxTips(tips)
	self.MaxValueTips = tips
end

function CommAmountSliderView:SetSliderValueMinTips(tips)
	self.MinValueTips = tips
end

function CommAmountSliderView:SetSliderValue(Value)
	self.ViewModel:SetSliderValue(Value)
end

function CommAmountSliderView:OnValueChangedSlider( Percent )
	self.ViewModel:SetSliderPercent(Percent)
end

function CommAmountSliderView:OnClickedAddBtn()
	if self.ViewModel.AddBtnEnabled == false then
		if nil ~= self.MaxValueTips then
			_G.MsgTipsUtil.ShowTips(self.MaxValueTips)
		end
		return
	end
	self.ViewModel:AddSliderValue(1)
end

function CommAmountSliderView:OnClickedSubBtn()
	if self.ViewModel.SubBtnEnabled == false then
		if nil ~= self.MinValueTips then
			_G.MsgTipsUtil.ShowTips(self.MinValueTips)
		end
		return
	end
	self.ViewModel:SubSliderValue(1)
end

function CommAmountSliderView:SetAddVlue(value)
	self.ViewModel:AddSliderValue(value)
end

function CommAmountSliderView:SetSubVlue(value)
	self.ViewModel:SubSliderValue(value)
end

function CommAmountSliderView:SetValueChangedCallback( func )
	self.ViewModel:SetValueChangedCallback(func) 
end

function CommAmountSliderView:SetCanChangedCallback( func )
	self.ViewModel:SetCanChangedCallback(func) 
end

function CommAmountSliderView:SetCaptureEndCallBack( func )
	self.SliderHorizontal:SetCaptureEndCallBack( func )
end 

function CommAmountSliderView:SetCaptureBeginCallBack( func )
	self.SliderHorizontal:SetCaptureBeginCallBack( func )
end

function CommAmountSliderView:SetBtnIsShow(IsShow)
	UIUtil.SetIsVisible(self.BtnSub, IsShow, true)
	UIUtil.SetIsVisible(self.BtnAdd, IsShow, true)
	UIUtil.SetIsVisible(self.TextLeast, IsShow, true)
	UIUtil.SetIsVisible(self.TextMax, IsShow, true)
end

function CommAmountSliderView:SetSliderClickVisible(Value)
	self.SliderHorizontal:SetSliderClickVisible(Value)
end

return CommAmountSliderView