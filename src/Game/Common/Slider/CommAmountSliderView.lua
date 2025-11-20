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
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIViewID = require("Define/UIViewID")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")


---@class CommAmountSliderView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field BtnAddTen UFButton
---@field BtnMax UFButton
---@field BtnMiniKey UFButton
---@field BtnSub UFButton
---@field BtnSubtractTen UFButton
---@field FCanvasPanel UFCanvasPanel
---@field FCanvasPanel_1 UFCanvasPanel
---@field IconMost UFImage
---@field IconMostDisab UFImage
---@field ImgAddTenDisab UFImage
---@field ImgAddTenNormal UFImage
---@field ImgMaxDisab UFImage
---@field ImgMaxNormal UFImage
---@field ImgSubtractTenDisab UFImage
---@field ImgSubtractTenNormal UFImage
---@field PanelTextL UFCanvasPanel
---@field PanelTextR UFCanvasPanel
---@field SliderHorizontal CommSliderHorizontalView
---@field TextAddTen UFTextBlock
---@field TextHint UFTextBlock
---@field TextLeast UFTextBlock
---@field TextMax UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextSubtractTen UFTextBlock
---@field Btn bool
---@field Text bool
---@field Quantity bool
---@field AddSubtract10 bool
---@field Max bool
---@field Hint bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommAmountSliderView = LuaClass(UIView, true)

function CommAmountSliderView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.BtnAddTen = nil
	--self.BtnMax = nil
	--self.BtnMiniKey = nil
	--self.BtnSub = nil
	--self.BtnSubtractTen = nil
	--self.FCanvasPanel = nil
	--self.FCanvasPanel_1 = nil
	--self.IconMost = nil
	--self.IconMostDisab = nil
	--self.ImgAddTenDisab = nil
	--self.ImgAddTenNormal = nil
	--self.ImgMaxDisab = nil
	--self.ImgMaxNormal = nil
	--self.ImgSubtractTenDisab = nil
	--self.ImgSubtractTenNormal = nil
	--self.PanelTextL = nil
	--self.PanelTextR = nil
	--self.SliderHorizontal = nil
	--self.TextAddTen = nil
	--self.TextHint = nil
	--self.TextLeast = nil
	--self.TextMax = nil
	--self.TextQuantity = nil
	--self.TextSubtractTen = nil
	--self.Btn = nil
	--self.Text = nil
	--self.Quantity = nil
	--self.AddSubtract10 = nil
	--self.Max = nil
	--self.Hint = nil
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
	self.MiniKeyState = nil

	self.Binders = {
		{"Percent", UIBinderSetSlider.New(self, self.SliderHorizontal)},
		{ "AddBtnEnabled", UIBinderSetIsDisabledState.New(self, self.BtnAdd, true, true)},
		{ "SubBtnEnabled", UIBinderSetIsDisabledState.New(self, self.BtnSub, true, true)},
		{ "AddTenBtnEnabled", UIBinderSetIsDisabledState.New(self, self.BtnAddTen, true, true)},
		{ "SubTenBtnEnabled", UIBinderSetIsDisabledState.New(self, self.BtnSubtractTen, true, true)},
		{ "SilderEnabled", UIBinderSetIsEnabled.New(self, self.SliderHorizontal)},
		{ "ValueText", UIBinderSetText.New(self, self.TextQuantity)},
		{ "SubtractTenColor", UIBinderSetColorAndOpacity.New(self, self.TextSubtractTen)},
		{ "AddTenColor", UIBinderSetColorAndOpacity.New(self, self.TextAddTen)},
		{ "ImgSubTenDisab", UIBinderSetIsVisible.New(self, self.ImgSubtractTenDisab) },
		{ "ImgSubTenNormal", UIBinderSetIsVisible.New(self, self.ImgSubtractTenNormal) },
		{ "ImgAddTenDisab", UIBinderSetIsVisible.New(self, self.ImgAddTenDisab) },
		{ "ImgAddTenNormal", UIBinderSetIsVisible.New(self, self.ImgAddTenNormal) },
	}

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
	UIUtil.AddOnClickedEvent(self, self.BtnAddTen, self.OnClickedBtnAddTen)
	UIUtil.AddOnClickedEvent(self, self.BtnSub, self.OnClickedSubBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnSubtractTen, self.OnClickedBtnSubtractTen)
	UIUtil.AddOnClickedEvent(self, self.BtnSubtractTen, self.OnClickedBtnSubtractTen)
	UIUtil.AddOnClickedEvent(self, self.BtnMax, self.OnClickedBtnMax)
	UIUtil.AddOnClickedEvent(self, self.BtnMiniKey, self.OnClickedBtnMiniKey)
end

function CommAmountSliderView:OnRegisterGameEvent()

end

function CommAmountSliderView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

---@param SingleState boolean @单个加减按钮
---@param SingleTextState boolean @单个加减号旁边文本
---@param MaxState boolean @最大值按钮
---@param ValueState boolean @进度条上方显示文本
function CommAmountSliderView:SetBaseVisible(SingleState, SingleTextState, ValueState, MaxState)
	UIUtil.SetIsVisible(self.BtnSub, SingleState or false, true)
	UIUtil.SetIsVisible(self.BtnAdd, SingleState or false, true)
	UIUtil.SetIsVisible(self.TextLeast, SingleTextState or false)
	UIUtil.SetIsVisible(self.TextMax, SingleTextState or false)
	UIUtil.SetIsVisible(self.BtnMax, MaxState or false, true)
	UIUtil.SetIsVisible(self.TextQuantity, ValueState or false)
	self:SetMiniKeyState(ValueState)
end

--加减多个按钮
function CommAmountSliderView:SetMultipleBtn(Value)
	UIUtil.SetIsVisible(self.BtnSubtractTen, Value, true)
	UIUtil.SetIsVisible(self.BtnAddTen, Value, true)
	self.ViewModel:SetMultipleBtnState(Value)
end

--进度条下方显示文本
function CommAmountSliderView:SetHintState(Value)
	UIUtil.SetIsVisible(self.TextHint, Value)
end

--设置小键盘
function CommAmountSliderView:SetMiniKeyState(Value)
	self.MiniKeyState = Value
end

function CommAmountSliderView:SetSliderValueMaxMin(MaxValue, MinValue, BatchValue)
	self.ViewModel:SetSliderValueMaxMin(MaxValue, MinValue, BatchValue)
	self.TextMax:SetText(MaxValue)
	self.TextLeast:SetText(MinValue)
	if BatchValue then
		self.TextSubtractTen:SetText(string.format("%s%d", "-", BatchValue))
		self.TextAddTen:SetText(string.format("%s%d", "+", BatchValue))
	end

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

function CommAmountSliderView:OnClickedBtnAddTen()
	if self.ViewModel.AddTenBtnEnabled == false then
		if nil ~= self.MaxValueTips then
			_G.MsgTipsUtil.ShowTips(self.MaxValueTips)
		end
		return
	end
	self.ViewModel:AddBatchValue()
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

function CommAmountSliderView:OnClickedBtnSubtractTen()
	if self.ViewModel.SubTenBtnEnabled == false then
		if nil ~= self.MinValueTips then
			_G.MsgTipsUtil.ShowTips(self.MinValueTips)
		end
		return
	end
	self.ViewModel:SubBatchValue()
end

function CommAmountSliderView:OnClickedBtnMax()
	self.ViewModel:SetMaxValue()
end

function CommAmountSliderView:OnClickedBtnMiniKey()
	if not self.MiniKeyState then
		return
	end

	local ConfirmCallback =
	function(Num)
	 	self.ViewModel:SetSliderValue(Num)
	end
	local ShowCallback = 
	function(Num)
		self.TextQuantity:SetText(tostring(Num))
   	end

	local Params = { CutValue = self.ViewModel.Value, ConfirmCallback = ConfirmCallback , 
					ShowCallback = ShowCallback, LowerLimit = self.ViewModel.MinValue, UpperLimit = self.ViewModel.MaxValue, }
	local View = _G.UIViewMgr:ShowView(UIViewID.CommMiniKeypadWin, Params)
	local KetpadSize = UIUtil.CanvasSlotGetSize(View.FCanvasPanel_3)
	local BtnSize = UIUtil.GetWidgetSize(self.BtnMiniKey)
	local InOffset = _G.UE.FVector2D( -BtnSize.X - KetpadSize.X + 40, -KetpadSize.Y)
	TipsUtil.AdjustTipsPosition(View.FCanvasPanel_3, self.BtnMiniKey, InOffset, _G.UE.FVector2D(-1, 0))
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