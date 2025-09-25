---
--- Author: chriswang
--- DateTime: 2025-06-18 11:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LSTR = _G.LSTR
local TimeDefine = require("Define/TimeDefine")
local UITimeType = TimeDefine.TimeType.Local

---@class SettingsPowerSavingModeView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonBkg02_UIBP CommonBkg02View
---@field FTextBlock_188 UFTextBlock
---@field ImgLight UFImage
---@field ProgressBar UProgressBar
---@field Slider USlider
---@field TextLabel UFTextBlock
---@field TextTime UFTextBlock
---@field TextTips UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsPowerSavingModeView = LuaClass(UIView, true)

function SettingsPowerSavingModeView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonBkg02_UIBP = nil
	--self.FTextBlock_188 = nil
	--self.ImgLight = nil
	--self.ProgressBar = nil
	--self.Slider = nil
	--self.TextLabel = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsPowerSavingModeView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonBkg02_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsPowerSavingModeView:OnInit()
	
end

function SettingsPowerSavingModeView:OnDestroy()

end

function SettingsPowerSavingModeView:OnShow()
	self.TextLabel:SetText(LSTR(110084))
	self.FTextBlock_188:SetText(LSTR(110085))
	self.TextTips:SetText(LSTR(110086))

	local LocalTime = _G.TimeUtil.GetTimeFormatByType(UITimeType, "%H:%M")
	self.TextTime:SetText(LocalTime)

	self:Reset()

	self:RegisterTimer(self.OnTick, 0, 0.1, 0)
	-- self.ImgLight
	-- self.LastImgLightAngle = 0
end

function SettingsPowerSavingModeView:Reset(bAnim)
	-- if bAnim then
	-- 	local Pct = self.Slider:GetValue()
	-- 	FLOG_INFO("pcw Reset:%.2f", Pct)
		
	-- 	UIUtil.PlayAnimationTimePointPct(self, self.AnimProBar, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, false)
	-- 	-- self:PlayAnimationTimeRange(self.AnimProBar, Pct, 0, 1, _G.UE.EUMGSequencePlayMode.Reverse, 1, false)
	-- 	self.LastPercent = 0
	-- 	return
	-- end

	self.LastPercent = 0

	if _G.CommonUtil.IsObjectValid(self.Object) and self.ProgressBar and _G.CommonUtil.IsObjectValid(self.ProgressBar) then
		self.ProgressBar:SetPercent(0)
		self.Slider:SetValue(0)
		UIUtil.PlayAnimationTimePointPct(self, self.AnimProBar, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, false)
	end
end

function SettingsPowerSavingModeView:OnHide()
	_G.PowerSavingMgr:ExitPowerSavingState(true)
end

function SettingsPowerSavingModeView:OnRegisterUIEvent()
	UIUtil.AddOnValueChangedEvent(self, self.Slider, self.OnValueChangedSlider)

end

function SettingsPowerSavingModeView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)

end

function SettingsPowerSavingModeView:OnRegisterBinder()

end

function SettingsPowerSavingModeView:OnTick()
	-- self.ImgLight:SetRenderTransformAngle(self.LastImgLightAngle)
	-- self.LastImgLightAngle = self.LastImgLightAngle + 5

	local LocalTime = _G.TimeUtil.GetTimeFormatByType(UITimeType, "%H:%M")
	self.TextTime:SetText(LocalTime)
end

function SettingsPowerSavingModeView:OnValueChangedSlider(_, Percent)
	if Percent == self.LastPercent then  -- 用于解决超出滑动区域后，仍然会触发函数值变化
		return
	end

	self.LastPercent = Percent

	self.Slider:SetValue(Percent)
	self.ProgressBar:SetPercent(Percent)

	-- FLOG_INFO("pcw OnValueChangedSlider:%.2f", Percent)

	UIUtil.PlayAnimationTimePointPct(self, self.AnimProBar, Percent, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, false)
	-- self:PlayAnimationTimeRange(self.AnimProBar, Percent, Percent + 0.01, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, false)
end

function SettingsPowerSavingModeView:OnPreprocessedMouseButtonUp(MouseEvent)
	if self.LastPercent >= 0.95 then
		_G.PowerSavingMgr:ExitPowerSavingState()

		self:Hide()
        -- local function DelayHide()
		-- 	self:Hide()
        -- end

        -- _G.TimerMgr:AddTimer(nil, DelayHide, 0.1, 0.1, 1)
	else
        local function DelayReset()
			self:Reset(true)
        end

		-- FLOG_INFO("pcw OnValueChangedSlider:%.2f", self.Slider:GetValue())
        _G.TimerMgr:AddTimer(nil, DelayReset, 0.1, 0.1, 1)
	end
end

return SettingsPowerSavingModeView