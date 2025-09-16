---
--- Author: chriswang
--- DateTime: 2023-08-31 17:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local TimeUtil = require("Utils/TimeUtil")

---@class CrafterStrengthItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Slider USlider
---@field Text0 UFTextBlock
---@field Text100 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterStrengthItemView = LuaClass(UIView, true)

function CrafterStrengthItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Slider = nil
	--self.Text0 = nil
	--self.Text100 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterStrengthItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterStrengthItemView:OnInit()
	self.AnimInfo = {Last = 0, To = 1, LifeTime = 120, CurTime = 0}
	self.TimeInterval = 0.01
end

function CrafterStrengthItemView:OnDestroy()

end

function CrafterStrengthItemView:OnShow()
	if self.Params then
		local StartMakeRsp = self.Params
		self.AnimInfo.Last = 0
		self.Slider:SetValue(0)
		--反应强度
		local Value = StartMakeRsp.Features[ProtoCS.FeatureType.FEATURE_TYPE_REACTION_INTENSITY] or 0
		self:UpdateReactionIntensity(Value)	
	end
end

function CrafterStrengthItemView:OnHide()
	self:CloseAnimTimer()
end

function CrafterStrengthItemView:OnRegisterUIEvent()

end

function CrafterStrengthItemView:OnRegisterGameEvent()

end

function CrafterStrengthItemView:OnRegisterBinder()

end

function CrafterStrengthItemView:UpdateSkillRsp(CrafterSkillRsp)
	if CrafterSkillRsp then
		--反应强度
		local Value = CrafterSkillRsp.Features[ProtoCS.FeatureType.FEATURE_TYPE_REACTION_INTENSITY] or 0
		self:UpdateReactionIntensity(Value)	
	end
end

function CrafterStrengthItemView:UpdateReactionIntensity(Value)
	local To = Value / 100
	local bAnim = true

	if Value >= 35 and Value <= 65 then --绿色区间
		UIUtil.SetIsVisible(self.EFF_RED, false)
		UIUtil.SetIsVisible(self.EFF_Green, true)
		self:PlayAnimation(self.AnimReachGreen)
	elseif Value > 65 then				--红色区间
		UIUtil.SetIsVisible(self.EFF_RED, true)
		UIUtil.SetIsVisible(self.EFF_Green, false)
		local Opacity = (Value - 65) / 35
		print("Crafter Opacity: ", Opacity)
		UIUtil.SetRenderOpacity(self.EFF_RED, Opacity)
		-- self:PlayAnimation(self.AnimReachRed)
	else
		UIUtil.SetIsVisible(self.EFF_RED, false)
		UIUtil.SetIsVisible(self.EFF_Green, false)
	end

	if To > self.AnimInfo.Last then
		self.AnimInfo.To = To
        self.AnimInfo.CurTime = 0
        self.AnimInfo.Last = self.Slider:GetValue()
		-- FLOG_INFO("crafter  To:%d", Value)
	elseif To < self.AnimInfo.Last then
        self.AnimInfo.Last = self.Slider:GetValue()
		self.AnimInfo.To = To
		-- FLOG_INFO("crafter  To:%d", Value)
	else
		bAnim = false
		-- self.Slider:SetValue(To)
	end

	if bAnim then
		self:StartAnimTimer()
	end
end

function CrafterStrengthItemView:StartAnimTimer()
    self.LastUpdateTime = TimeUtil.GetLocalTimeMS()
    if not self.AnimTimerID then
		-- FLOG_INFO("crafter Start Anim Timer")
        self.AnimTimerID = _G.TimerMgr:AddTimer(self, self.ProgressAnimUpdate
			, self.TimeInterval, self.TimeInterval, 0)
    end
end

function CrafterStrengthItemView:CloseAnimTimer()
    if self.AnimTimerID then
		-- FLOG_INFO("crafter Close Anim Timer")
        _G.TimerMgr:CancelTimer(self.AnimTimerID)
        self.AnimTimerID = nil
    end
end

function CrafterStrengthItemView:ProgressAnimUpdate()
    local CurLocalTime = TimeUtil.GetLocalTimeMS()
    local ElapsedTime = CurLocalTime - self.LastUpdateTime
    local AnimOver = true
	local AnimInfo = self.AnimInfo

	AnimInfo.CurTime = AnimInfo.CurTime + ElapsedTime
	local X = AnimInfo.CurTime / AnimInfo.LifeTime
	if X > 1 then
		X = 1
		AnimInfo.Last = AnimInfo.To
		AnimInfo.CurTime = 0
	else
		AnimOver = false
	end

	X = 1 - X

	local CurStep = (1 - X * X * X) * (AnimInfo.To - AnimInfo.Last)
	local To = AnimInfo.Last + CurStep

	-- print("crafter, To: ", To, " Last: ", AnimInfo.Last, " CurStep: ", CurStep
	-- , " CurTime: ", AnimInfo.CurTime, " X: ", X, " ElapsedTime: ", ElapsedTime)
	
	self.Slider:SetValue(To)

    if AnimOver then
        self:CloseAnimTimer()
    end
    
    self.LastUpdateTime = CurLocalTime
end

return CrafterStrengthItemView