--
-- Author: anypkvcai
-- Date: 2020-08-14 14:49:31
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetAnimPlayPercentage : UIBinder
local UIBinderSetAnimPlayPercentage = LuaClass(UIBinder)

local PlayAnimationName <const> = "PlayAnimationTimeRange"
local PlayAnimationToEndName <const> = "PlayAnimationTimeRangeToEndTime"

---Ctor
---@param View UIView
---@param Widget UUserWidget
---@param Animation UWidgetAnimation
---@param bStopToEnd boolean
function UIBinderSetAnimPlayPercentage:Ctor(View, Widget, Animation, bStopToEnd)
	self.Animation = Animation
	self.FuncName = bStopToEnd and PlayAnimationToEndName or PlayAnimationName
	--self.FuncName = PlayAnimationName
	self.AnimationEndTime = tonumber(string.format("%.2f", Animation:GetEndTime()))
end

---OnValueChanged
---@param NewValue boolean
---@param OldValue boolean
function UIBinderSetAnimPlayPercentage:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget or NewValue == nil then
		return
	end
	local Name = self.FuncName
	local View = self.View
	if NewValue == 0 then
		View[Name](View, self.Animation, 0.0, 0.01, 1, nil, 1.0)
		--self.View:PlayAnimationTimeRange(self.Animation, 0.0, 0.01, 1, nil, 1.0, false)
		return
	end

	if NewValue < 0 then
		View:StopAnimation(self.Animation)
		return
	end

	if OldValue ~= nil then
		if OldValue < NewValue then
			View[Name](View, self.Animation, math.max(OldValue, 0) * self.AnimationEndTime, self.AnimationEndTime * NewValue, 1, nil, 1.0)
			--self.View:PlayAnimationTimeRange(self.Animation, math.max(OldValue, 0) * self.AnimationEndTime, self.AnimationEndTime * NewValue, 1, nil, 1.0, false)
		else
			View[Name](View, self.Animation, 0, self.AnimationEndTime * NewValue, 1, nil, 1.0)
			--self.View:PlayAnimationTimeRange(self.Animation, 0, self.AnimationEndTime * NewValue, 1, nil, 1.0, false)
		end
	else
		View[Name](View, self.Animation, 0, self.AnimationEndTime * NewValue, 1, nil, 1.0)
		--self.View:PlayAnimationTimeRange(self.Animation, 0, self.AnimationEndTime * NewValue, 1, nil, 1.0, false)
	end
end

return UIBinderSetAnimPlayPercentage