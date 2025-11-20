---
--- Author: haialexzhou
--- DateTime: 2023-03-02 16:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class CommonFadeView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FadeImage UImage
---@field BlackFadeAnimation UWidgetAnimation
---@field ReverseBlackFadeAnimation UWidgetAnimation
---@field WhiteFadeAnimation UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonFadeView = LuaClass(UIView, true)

function CommonFadeView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FadeImage = nil
	--self.BlackFadeAnimation = nil
	--self.ReverseBlackFadeAnimation = nil
	--self.WhiteFadeAnimation = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonFadeView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonFadeView:OnInit()
	self.TimerShowMajor = nil
	self.TimerAutoHide = nil
	self.CurPlayEffectID = 0 -- 当前正在播放的
	self.bHidedMajor = false
end

function CommonFadeView:OnDestroy()

end

function CommonFadeView:ShowMajor()
	self:HideMajor(false)
	self.TimerShowMajor = nil
end

function CommonFadeView:OnShow()
	_G.FLOG_INFO("显示黑幕界面")
	--_G.FLOG_INFO(debug.traceback())
	if not self.Params then --填充默认数值
		self.Params = {}
		self.Params.FadeColorType = 3
		self.Params.Duration = 1
	end
	self:PlayFade(self.Params)
end

function CommonFadeView:OnHide()
	_G.FLOG_INFO("黑幕消失")
	--_G.FLOG_INFO(debug.traceback())
	if (self.bHidedMajor) then
		self:HideMajor(false)
		self.bHidedMajor = false
	end

	self.TimerShowMajor = nil
	self.TimerAutoHide = nil
	self.CurPlayEffectID = 0 -- 当前正在播放的
end


function CommonFadeView:HideMajor(bIsHide)
	local UActorManager = _G.UE.UActorManager:Get()
	UActorManager:HideMajor(bIsHide)
	_G.HUDMgr:SetPlayerInfoVisible(not bIsHide)
end

function CommonFadeView:OnRegisterUIEvent()

end

function CommonFadeView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.CommonFadePanelFadeOut, self.OnGameEventFadeOut)
end

function CommonFadeView:PlayFade(Params)
	local TargetParams = Params
	if (TargetParams == nil) then
		_G.FLOG_INFO("错误，传入的参数为空，请检查")
		return
	end

	local bForcePlay = TargetParams.ForcePlay or false
	if (self.CurPlayEffectID ~= 0 and not bForcePlay) then
		_G.FLOG_INFO("当前正在播放黑幕效果：%s , 无法播放其他", self.CurPlayEffectID)
		--_G.FLOG_INFO(debug.traceback())
		return
	end

	if (bForcePlay) then
		-- 如果是强制播放，那么先停止所有的播放
		self:StopAnimation(self.ReverseBlackFadeAnimation)
		self:StopAnimation(self.BlackFadeAnimation)
		self:StopAnimation(self.WhiteFadeAnimation)
	end

	if self.TimerShowMajor ~= nil then
		self:UnRegisterTimer(self.TimerShowMajor)
		self:ShowMajor()
	end

	if self.TimerAutoHide ~= nil then
		self:UnRegisterTimer(self.TimerAutoHide)
		self.TimerAutoHide = nil
	end

	local FadeColorType = TargetParams.FadeColorType
	local Duration = TargetParams.Duration
	local bAutoHide = (TargetParams.bAutoHide ~= false) -- 谨慎关闭此参数

	local DelayHide = Duration + 0.5
	if (Params.DelayHide ~= nil) then
		DelayHide = Params.DelayHide
	end

	if (FadeColorType == nil) then
		-- 没有动画，固定隐藏
		_G.FLOG_INFO("黑幕播放动画4")
		--_G.FLOG_INFO(debug.traceback())
		local LinearColor = _G.UE.FLinearColor.FromHex("000000FF")
		self.FadeImage:SetColorAndOpacity(LinearColor)
		self.CurPlayEffectID = 0
	else
		if (FadeColorType == 2) then
			-- 这里是渐渐显示，然后渐渐隐藏
			if (Duration == nil) then
				Duration = self.ReverseBlackFadeAnimation:GetEndTime()
			end
			_G.FLOG_INFO("黑幕播放动画2")
			--_G.FLOG_INFO(debug.traceback())
			local PlaySpeed = self.ReverseBlackFadeAnimation:GetEndTime() / Duration
			self:PlayAnimation(self.ReverseBlackFadeAnimation, 0, 1, _G.UE.EUMGSequencePlayMode.PingPong, PlaySpeed)
			DelayHide = Duration * 2
			if (TargetParams.HideMajor) then
				self.TimerShowMajor = self:RegisterTimer(
					self.ShowMajor,
					Duration
				)
			end
			-- 这里是循环的，是一个整体
			self.CurPlayEffectID = 2
			self.bPlayingFadeIn = true
			self.bPlayingFadeOut = true
			self:RegisterTimer(
				function()
					self.CurPlayEffectID = 0
				end,
				Duration
			)
		elseif (FadeColorType == 1) then
			-- 这里是 FadeOut ，黑幕渐渐隐藏
			_G.FLOG_INFO("黑幕播放动画1")
			-- _G.FLOG_INFO(debug.traceback())
			if (Duration == nil) then
				Duration = self.BlackFadeAnimation:GetEndTime()
			end
			local PlaySpeed = self.BlackFadeAnimation:GetEndTime() / Duration
			self:PlayAnimation(self.BlackFadeAnimation, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, PlaySpeed)
			self.CurPlayEffectID = 1
			self:RegisterTimer(
				function()
					self.CurPlayEffectID = 0
				end,
				Duration
			)
		elseif (FadeColorType == 3) then
			-- 这里是 FadeIn ，黑幕渐渐显示
			_G.FLOG_INFO("黑幕播放动画3")
			-- _G.FLOG_INFO(debug.traceback())
			if (Duration == nil) then
				Duration = self.BlackFadeAnimation:GetEndTime()
			end
			local PlaySpeed = self.BlackFadeAnimation:GetEndTime() / Duration
			self:PlayAnimation(self.BlackFadeAnimation, 0, 1, _G.UE.EUMGSequencePlayMode.Reverse, PlaySpeed)
			self.CurPlayEffectID = 3
			self:RegisterTimer(
				function()
					self.CurPlayEffectID = 0
				end,
				Duration
			)
		elseif (FadeColorType == 4) then
			-- 白幕渐渐显示
			_G.FLOG_INFO("黑幕播放动画5")
			-- _G.FLOG_INFO(debug.traceback())
			if (Duration == nil) then
				Duration = self.WhiteFadeAnimation:GetEndTime()
			end
			local PlaySpeed = self.WhiteFadeAnimation:GetEndTime() / Duration
			self:PlayAnimation(self.WhiteFadeAnimation, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, PlaySpeed)
			self.CurPlayEffectID = 4
			self:RegisterTimer(
				function()
					self.CurPlayEffectID = 0
				end,
				Duration
			)
		elseif(FadeColorType == 5) then
			-- 白幕渐渐隐藏
			_G.FLOG_INFO("黑幕播放动画5")
			-- _G.FLOG_INFO(debug.traceback())
			if (Duration == nil) then
				Duration = self.WhiteFadeAnimation:GetEndTime()
			end
			local PlaySpeed = self.WhiteFadeAnimation:GetEndTime() / Duration
			self:PlayAnimation(self.WhiteFadeAnimation, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, PlaySpeed)
			self.CurPlayEffectID = 4
			self:RegisterTimer(
				function()
					self.CurPlayEffectID = 0
				end,
				Duration
			)
		end
	end

	if (TargetParams.HideMajor) then
		self:HideMajor(true)
		self.bHidedMajor = true
	end

	if (self.TimerAutoHide ~= nil) then
		self:UnRegisterTimer(self.TimerAutoHide)
		self.TimerAutoHide = nil
	end

	if bAutoHide then
		self.TimerAutoHide = self:RegisterTimer(self.OnTimer, DelayHide)
	else
		self.TimerAutoHide = self:RegisterTimer(self.OnTimer, 5) -- 兜底保证界面隐藏
	end
end

function CommonFadeView:OnRegisterBinder()

end

function CommonFadeView:OnTimer()
	_G.FLOG_INFO("时间到了，自动关闭黑幕")
	self.TimerAutoHide = nil
	self:Hide()
end

function CommonFadeView:OnGameEventFadeOut()
	_G.FLOG_INFO("收到关闭黑幕消息 ，CurPlayEffectID ： %s", self.CurPlayEffectID)
	if (self.CurPlayEffectID == 3 or self.CurPlayEffectID == 0) then
		_G.FLOG_INFO("关闭黑幕1")
		-- 黑幕渐隐
		local TempParams = {}
		TempParams.FadeColorType = 1
		TempParams.Duration = 1

		self:PlayFade(TempParams)
	elseif (self.CurPlayEffectID == 4) then
		-- 白幕渐隐
		_G.FLOG_INFO("关闭白幕1")
		local TempParams = {}
		TempParams.FadeColorType = 5
		TempParams.Duration = 1

		self:PlayFade(TempParams)
	else
		_G.FLOG_INFO("没有关闭黑幕")
	end
end

return CommonFadeView