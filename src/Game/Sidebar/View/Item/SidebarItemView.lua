---
--- Author: xingcaicao
--- DateTime: 2023-06-29 19:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local EventID = require("Define/EventID")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")

local FLOG_ERROR = _G.FLOG_ERROR
local SidebarType = SidebarDefine.SidebarType

---@class SidebarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UImage
---@field ImgTimeBg UImage
---@field ImgTypeIcon UImage
---@field RaidalCD URadialImage
---@field Text02 UFTextBlock
---@field TextTips UFTextBlock
---@field TextTypeName UFTextBlock
---@field AnimDefault UWidgetAnimation
---@field AnimGreen UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimRed UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SidebarItemView = LuaClass(UIView, true)

function SidebarItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgTimeBg = nil
	--self.ImgTypeIcon = nil
	--self.RaidalCD = nil
	--self.Text02 = nil
	--self.TextTips = nil
	--self.TextTypeName = nil
	--self.AnimDefault = nil
	--self.AnimGreen = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimRed = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SidebarItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SidebarItemView:OnInit()
	self.Binders = {
		{ "Tips", 		UIBinderSetText.New(self, self.TextTips) },
		{ "TypeName", 	UIBinderSetText.New(self, self.TextTypeName) },
		{ "ItemBg",		UIBinderSetBrushFromAssetPath.New(self, self.ImgBg) },
		{ "Icon",		UIBinderSetBrushFromAssetPath.New(self, self.ImgTypeIcon) },
		{ "Text2",		UIBinderSetText.New(self, self.Text02)},

		{ "Type", 				UIBinderValueChangedCallback.New(self, nil, self.OnTypeChanged) },
		{ "CountDown", 			UIBinderValueChangedCallback.New(self, nil, self.OnCountDownChanged) },
		{ "LoopAnimName", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedLoopAnimName) },

		{ "TransData",			UIBinderValueChangedCallback.New(self, nil, self.OnTransDataChanged)},
	}

	self.CountDownTimerID = nil
	self.ExtraTimerID = nil
end

function SidebarItemView:OnDestroy()

end

function SidebarItemView:OnShow()

end

function SidebarItemView:OnHide()

end

function SidebarItemView:OnRegisterUIEvent()

end

function SidebarItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SidebarPlayAnimation, self.OnEventPlayAnimation)
end

function SidebarItemView:OnRegisterBinder()
	local Data = (self.Params or {}).Data
	if nil == Data then
		return
	end

	self.ViewModel = Data
	self:RegisterBinders(Data, self.Binders)
end

function SidebarItemView:OnTypeChanged(Type)
	if nil == Type then
		return
	end

	if Type == SidebarType.Revive then -- 他人救助
		self:PlayAnimation(self.AnimGreen)
	elseif Type == SidebarType.Death then -- 死亡复活
		self:PlayAnimation(self.AnimRed)
	else
		self:PlayAnimation(self.AnimDefault)
	end

	UIUtil.SetIsVisible(self.Text02, Type == SidebarType.PWorldMatch)
end

function SidebarItemView:OnCountDownChanged(CountDown)
	self:ClearCountDownTimer()

	self.CountDown = CountDown or 0
	local IsHasTime = self.CountDown > 0
	UIUtil.SetIsVisible(self.ImgTimeBg, IsHasTime)
	UIUtil.SetIsVisible(self.RaidalCD, IsHasTime)

	if not IsHasTime then
		return
	end

	local StartTime = self.ViewModel.StartTime or 0
	self.LossTime = TimeUtil.GetServerTime() - StartTime
	if self.LossTime >= self.CountDown then
		self.RaidalCD:SetPercent(0)
		return
	end

	self:SetRaidalCD(self.LossTime)
	self.CountDownTimerID = self:RegisterTimer(self.OnCountDownTimer, 0, 0.3, 0)
end

function SidebarItemView:SetRaidalCD( ElapsedTime )
	local Percent  = math.clamp(1 - ElapsedTime / self.CountDown, 0, 1)
	self.RaidalCD:SetPercent(Percent)
end

function SidebarItemView:OnCountDownTimer( _, ElapsedTime )
	local CountDown = self.CountDown
	if nil == CountDown or CountDown <= 0 then
		return
	end

	ElapsedTime = (self.LossTime or 0) + ElapsedTime
	if ElapsedTime >= CountDown then
		self:ClearCountDownTimer()
		return
	end

	self:SetRaidalCD(ElapsedTime)
end

function SidebarItemView:ResetRegisterBinder( ViewModel )
	self:UnRegisterAllBinder()
	self:StopAllAnimations()

	if ViewModel then
		self.ViewModel = ViewModel
		self:RegisterBinders(ViewModel, self.Binders)
	end
end

function SidebarItemView:HideTypeName()
	UIUtil.SetIsVisible(self.TextTypeName, false)
end

function SidebarItemView:OnValueChangedLoopAnimName(NewAnimName, OldAnimName)
	if not string.isnilorempty(OldAnimName) then
		local Anim = self[OldAnimName]
		if Anim then
			self:StopAnimation(Anim)
		end
	end

	if string.isnilorempty(NewAnimName) then
		return
	end

	local NewAnim = self[NewAnimName]
	if NewAnim then
		self:PlayAnimation(NewAnim, 0, 0)
	end
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

---@param Type SidebarType @侧边栏类型
---@param AnimName string @动效名
function SidebarItemView:OnEventPlayAnimation(Type, AnimName)
	if nil == self.ViewModel or Type ~= self.ViewModel.Type or string.isnilorempty(AnimName) then
		return
	end

	local Anim = self[AnimName]
	if nil == Anim then
		FLOG_ERROR(string.format("SidebarItemView:OnEventPlayAnimation, No %s Animation", AnimName))
		return
	end

	self:PlayAnimation(Anim)
end

function SidebarItemView:ClearCountDownTimer()
	if self.CountDownTimerID ~= nil then
		self:UnRegisterTimer(self.CountDownTimerID)
		self.CountDownTimerID = nil
	end
end

function SidebarItemView:ClearExtraTimer()
	if self.ExtraTimerID ~= nil then
		self:UnRegisterTimer(self.ExtraTimerID)
		self.ExtraTimerID = nil
	end
end

function SidebarItemView:OnTransDataChanged(NewTransData)
	self:ClearExtraTimer()

	if type(NewTransData) ~= 'table' then
		return
	end

	if NewTransData.TimerData then
		self.ExtraTimerID = self:RegisterTimer(function()
			NewTransData.TimerData.Callback(self.ViewModel)
		end, NewTransData.TimerData.Delay, NewTransData.TimerData.Interval, NewTransData.TimerData.LoopNumber, nil)
	end
end

return SidebarItemView