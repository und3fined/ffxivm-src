---
--- Author: Administrator
--- DateTime: 2023-05-09 20:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIBinderSetIsDisabledState = require("Binder/UIBinderSetIsDisabledState")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local CommCountSliderVM = require("Game/Common/Slider/CommCountSliderVM")

---@class CommCountSliderView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field BtnSub UFButton
---@field SliderHorizontal CommSliderHorizontalView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommCountSliderView = LuaClass(UIView, true)

function CommCountSliderView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.BtnSub = nil
	--self.SliderHorizontal = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommCountSliderView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SliderHorizontal)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommCountSliderView:OnInit()
	self.ViewModel = CommCountSliderVM.New()
	self.MaxValueTips = nil
	self.MinValueTips = nil
end

function CommCountSliderView:OnDestroy()

end

function CommCountSliderView:OnShow()
	self.SliderHorizontal:SetValueChangedCallback(function (v)
		self:OnValueChangedSlider(v)
	end)
end

function CommCountSliderView:OnHide()

end

function CommCountSliderView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnClickedAddBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnSub, self.OnClickedSubBtn)
end

function CommCountSliderView:OnRegisterGameEvent()

end

function CommCountSliderView:OnRegisterBinder()
	local Binders = {
		{"Percent", UIBinderSetSlider.New(self, self.SliderHorizontal)},
		{ "AddBtnEnabled", UIBinderSetIsDisabledState.New(self,self.BtnAdd, true, true)},
		{ "SubBtnEnabled", UIBinderSetIsDisabledState.New(self,self.BtnSub, true, true)},
		{ "SilderEnabled", UIBinderSetIsEnabled.New(self,self.SliderHorizontal)},

	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function CommCountSliderView:SetSliderValueMaxMin(MaxValue, MinValue)
	self.ViewModel:SetSliderValueMaxMin(MaxValue, MinValue)
end

function CommCountSliderView:SetSliderValueMaxTips(tips)
	self.MaxValueTips = tips
end

function CommCountSliderView:SetSliderValueMinTips(tips)
	self.MinValueTips = tips
end


function CommCountSliderView:SetSliderValue(Value)
	self.ViewModel:SetSliderValue(Value)
end

function CommCountSliderView:OnValueChangedSlider( Percent )
	self.ViewModel:SetSliderPercent(Percent)
end

function CommCountSliderView:OnClickedAddBtn()
	if self.ViewModel.AddBtnEnabled == false then
		if nil ~= self.MaxValueTips then
			_G.MsgTipsUtil.ShowTips(self.MaxValueTips)
		end
		return
	end
	self.ViewModel:AddSliderValue()
end

function CommCountSliderView:OnClickedSubBtn()
	if self.ViewModel.SubBtnEnabled == false then
		if nil ~= self.MinValueTips then
			_G.MsgTipsUtil.ShowTips(self.MinValueTips)
		end
		return
	end
	self.ViewModel:SubSliderValue()
end

function CommCountSliderView:SetValueChangedCallback( func )
	self.ViewModel:SetValueChangedCallback(func) 
end

function CommCountSliderView:SetCanChangedCallback( func )
	self.ViewModel:SetCanChangedCallback(func) 
end

function CommCountSliderView:SetCaptureEndCallBack( func )
	self.SliderHorizontal:SetCaptureEndCallBack( func )
end 

function CommCountSliderView:SetCaptureBeginCallBack( func )
	self.SliderHorizontal:SetCaptureBeginCallBack( func )
end

return CommCountSliderView