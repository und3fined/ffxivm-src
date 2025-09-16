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
end

function CommonFadeView:OnDestroy()

end

function CommonFadeView:OnShow()
	if self.TimerShowMajor ~= nil then
		self:UnRegisterTimer(self.TimerShowMajor)
		self.TimerShowMajor = nil
		self:HideMajor(false)
	end

	if self.TimerAutoHide ~= nil then
		self:UnRegisterTimer(self.TimerAutoHide)
		self.TimerAutoHide = nil
	end

	if not self.Params then --填充默认数值
		self.Params = {}
		self.Params.FadeColorType = 3
		self.Params.Duration = 1
		self.Params.bAutoHide = false
	end

	local FadeColorType = self.Params.FadeColorType
	local Duration = self.Params.Duration
	local bAutoHide = (self.Params.bAutoHide ~= false) -- 谨慎关闭此参数

	local DelayHide = Duration
	if (FadeColorType == 2) then
		if (Duration == nil) then
			Duration = self.ReverseBlackFadeAnimation:GetEndTime()
		end
		local PlaySpeed = self.ReverseBlackFadeAnimation:GetEndTime() / Duration
		self:PlayAnimation(self.ReverseBlackFadeAnimation, 0, 1, _G.UE.EUMGSequencePlayMode.PingPong, PlaySpeed)
		DelayHide = Duration * 2

		if (self.Params.HideMajor ~= nil) then
			local function ShowMajor()
				self:HideMajor(false)
				self.TimerShowMajor = nil
			end
			self.TimerShowMajor = self:RegisterTimer(ShowMajor, Duration)
		end
		
	elseif (FadeColorType == 1) then
		if (Duration == nil) then
			Duration = self.BlackFadeAnimation:GetEndTime()
		end
		local PlaySpeed = self.BlackFadeAnimation:GetEndTime() / Duration
		self:PlayAnimation(self.BlackFadeAnimation, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, PlaySpeed)
		
	elseif (FadeColorType == 3) then
		if (Duration == nil) then
			Duration = self.BlackFadeAnimation:GetEndTime()
		end
		local PlaySpeed = self.BlackFadeAnimation:GetEndTime() / Duration
		self:PlayAnimation(self.BlackFadeAnimation, 0, 1, _G.UE.EUMGSequencePlayMode.Reverse, PlaySpeed)

	elseif (FadeColorType == nil) then
		local LinearColor = _G.UE.FLinearColor.FromHex("000000FF")
		self.FadeImage:SetColorAndOpacity(LinearColor)

	else
		if (Duration == nil) then
			Duration = self.WhiteFadeAnimation:GetEndTime()
		end
		local PlaySpeed = self.WhiteFadeAnimation:GetEndTime() / Duration
		self:PlayAnimation(self.WhiteFadeAnimation, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, PlaySpeed)
	end

	if (self.Params.HideMajor ~= nil) then
		self:HideMajor(true)
	end

	if bAutoHide then
		self.TimerAutoHide = self:RegisterTimer(self.OnTimer, DelayHide)
	else
		self.TimerAutoHide = self:RegisterTimer(self.OnTimer, 5) -- 兜底保证界面隐藏
	end
end

function CommonFadeView:OnHide()
	if (self.Params.HideMajor ~= nil) then
		self:HideMajor(false)
	end
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

function CommonFadeView:OnRegisterBinder()

end

function CommonFadeView:OnTimer()
	self.TimerAutoHide = nil
	self:Hide()
end

function CommonFadeView:OnGameEventFadeOut()
	local Params = self.Params
	if Params and Params.FadeColorType == 3 then --如果是fadein
		local TempParams = {}
		TempParams.FadeColorType = 1
		TempParams.Duration = 0.6
		TempParams.bAutoHide = true
		self.Params = TempParams
		self:OnShow()
	end
end

return CommonFadeView