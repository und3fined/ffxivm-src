---
--- Author: Administrator
--- DateTime: 2024-06-13 18:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MainPanelVM = require("Game/Main/MainPanelVM")
local MainPanelConfig = require("Game/Main/MainPanelConfig")
local UIBinderSetText = require("Binder/UIBinderSetText")
local LocalizationUtil = require("Utils/LocalizationUtil")
local MysterMerchantVM = require("Game/MysterMerchant/VM/MysterMerchantVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MysterMerchantDefine = require("Game/MysterMerchant/MysterMerchantDefine")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class MainLimitedTimeInfoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFold UToggleButton
---@field ImgDown UFImage
---@field ImgPlayStyleType UFImage
---@field ImgTime UFImage
---@field ImgTime24h UFImage
---@field ImgUp UFImage
---@field PanelAvoid UFCanvasPanel
---@field PanelCountDown UFCanvasPanel
---@field PanelCountDown24h UFCanvasPanel
---@field PanelGateInfo UFCanvasPanel
---@field PanelTime UFWidgetSwitcher
---@field RichTextAvoidTime URichTextBox
---@field TextTime UFTextBlock
---@field TextTime24h UFTextBlock
---@field TextTitle UFTextBlock
---@field VerticalGateInfo UFVerticalBox
---@field AnimIn UWidgetAnimation
---@field AnimTaskNameUpdate UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainLimitedTimeInfoItemView = LuaClass(UIView, true)

function MainLimitedTimeInfoItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFold = nil
	--self.ImgDown = nil
	--self.ImgPlayStyleType = nil
	--self.ImgTime = nil
	--self.ImgTime24h = nil
	--self.ImgUp = nil
	--self.PanelAvoid = nil
	--self.PanelCountDown = nil
	--self.PanelCountDown24h = nil
	--self.PanelGateInfo = nil
	--self.PanelTime = nil
	--self.RichTextAvoidTime = nil
	--self.TextTime = nil
	--self.TextTime24h = nil
	--self.TextTitle = nil
	--self.VerticalGateInfo = nil
	--self.AnimIn = nil
	--self.AnimTaskNameUpdate = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainLimitedTimeInfoItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainLimitedTimeInfoItemView:OnInit()
	self.ViewModel = MysterMerchantVM.TaskInfoVM
	self.Status = 0
	self.Binders = 
	{
		{ "TaskName", UIBinderSetText.New(self, self.TextTitle) },--任务情报名
		{ "TaskProgressText", UIBinderSetText.New(self, self.RichTextAvoidTime) },--任务进度
		--{ "CountDown", UIBinderSetText.New(self, self.TextTime) },--倒计时
		--{ "CountDownVisible", UIBinderSetIsVisible.New(self, self.PanelCountDown) },
		{ "TaskStatus", UIBinderValueChangedCallback.New(self, nil, self.OnTaskStatusChanged)},
		{ "CountDownVisible", UIBinderValueChangedCallback.New(self, nil, self.OnCountDownVisibleChanged)},
	}
end

function MainLimitedTimeInfoItemView:OnDestroy()

end

function MainLimitedTimeInfoItemView:OnShow()

end

function MainLimitedTimeInfoItemView:OnHide()
	self.BtnFold:SetIsChecked(false, true)
end

function MainLimitedTimeInfoItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.BtnFold, self.OnBtnFoldStateChanged)
end

function MainLimitedTimeInfoItemView:OnRegisterGameEvent()

end

function MainLimitedTimeInfoItemView:OnRegisterBinder()
	if self.ViewModel == nil then
		return
	end
	self.EndTime = self.ViewModel.EndTime
	self.CountDownVisible = self.ViewModel.CountDownVisible
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function MainLimitedTimeInfoItemView:OnBtnFoldStateChanged(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	MainPanelVM:SetFunctionVisible(IsChecked, MainPanelConfig.TopRightInfoType.MysterMerchantTask)
	if not IsChecked then
		UIUtil.SetIsVisible(self.VerticalGateInfo, true)
		self:PlayAnimation(self.AnimUnfold, 0, 1, nil, 1.0, true)
	else
		--self:PlayAnimationTimeRange(self.AnimUnfold, 0.0, 0.01, 1, nil, 1.0, false)
		UIUtil.SetIsVisible(self.VerticalGateInfo, false)
	end
end

function MainLimitedTimeInfoItemView:OnTaskStatusChanged(Status)
	if self.Status ~= Status and Status == MysterMerchantDefine.MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH then
		self.Status = Status
		self:PlayAnimation(self.AnimTaskNameUpdate)
	end
end

---@type 更新任务倒计时
function MainLimitedTimeInfoItemView:UpdateTaskCD()
	local EndTime = self.ViewModel.EndTime
    local LocalTime = _G.TimeUtil.GetServerLogicTime()
	local RemainTime = EndTime - LocalTime
	local CountDown = ""
	if RemainTime <= 3600 then
		self.PanelTime:SetActiveWidgetIndex(0)
		CountDown = LocalizationUtil.GetCountdownTime(RemainTime, "mm:ss")
	else
		self.PanelTime:SetActiveWidgetIndex(1)
		CountDown = LocalizationUtil.GetCountdownTime(RemainTime, "hh:mm:ss")
	end
	self.TextTime:SetText(CountDown)
	self.TextTime24h:SetText(CountDown)

	local TaskState = self.ViewModel.TaskStatus
	if TaskState == MysterMerchantDefine.MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH then
		--提示商品交易即将结束
		if RemainTime == 30 or RemainTime == 10 then
			_G.MsgTipsUtil.ShowTipsByID(MysterMerchantDefine.TipID.NearEndTrade)
		elseif RemainTime <= 0 then
			_G.MsgTipsUtil.ShowTipsByID(MysterMerchantDefine.TipID.EndTrade)
			if self.TaskCDTimer then
				self:UnRegisterTimer(self.TaskCDTimer)
				self.TaskCDTimer = nil
			end
		end
    end
end

function MainLimitedTimeInfoItemView:OnCountDownVisibleChanged(IsVisible)
	UIUtil.SetIsVisible(self.PanelCountDown, IsVisible)
	if IsVisible then
		self.TaskCDTimer = self:RegisterTimer(self.UpdateTaskCD, 0, 1, 0)
	end
end

return MainLimitedTimeInfoItemView