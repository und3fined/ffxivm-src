---
--- Author: chriswang
--- DateTime: 2024-11-20 15:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")

---@class CrafterAlchemistItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgPointer UFImage
---@field ImgScale1 UFImage
---@field ImgScale2 UFImage
---@field Text0 UFTextBlock
---@field Text100 UFTextBlock
---@field AnimGreenHide UWidgetAnimation
---@field AnimGreenShow UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimPointer UWidgetAnimation
---@field AnimPointerControl UWidgetAnimation
---@field AnimRedHide UWidgetAnimation
---@field AnimRedShow UWidgetAnimation
---@field CurveAnimProgressBar CurveFloat
---@field ValueAnimPointerStart float
---@field ValueAnimPointerEnd float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterAlchemistItemView = LuaClass(UIView, true)
local GreenV = 0.35
local RedV = 0.65

function CrafterAlchemistItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgPointer = nil
	--self.ImgScale1 = nil
	--self.ImgScale2 = nil
	--self.Text0 = nil
	--self.Text100 = nil
	--self.AnimGreenHide = nil
	--self.AnimGreenShow = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimPointer = nil
	--self.AnimPointerControl = nil
	--self.AnimRedHide = nil
	--self.AnimRedShow = nil
	--self.CurveAnimProgressBar = nil
	--self.ValueAnimPointerStart = nil
	--self.ValueAnimPointerEnd = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterAlchemistItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterAlchemistItemView:OnInit()

end

function CrafterAlchemistItemView:OnDestroy()

end

function CrafterAlchemistItemView:OnShow()
	if self.Params then
		self:StopAnimation(self.AnimGreenShow)
		self:StopAnimation(self.AnimRedShow)
		
		self.ToValue = 0
		self:PlayAnimPointer(0, self.ToValue)
		local StartMakeRsp = self.Params
		self.UpdateSkillRsp(StartMakeRsp)
	end

	self.Text0:SetText("0")
	self.Text100:SetText("100")
	
	self:PlayAnimation(self.AnimRedHide)
	self:PlayAnimation(self.AnimGreenHide)
end

function CrafterAlchemistItemView:OnHide()
	if self.ToValue >= RedV then
		-- FLOG_WARNING("AlchemistItem PlayAnimation(self.AnimRedHide)")
		self:PlayAnimation(self.AnimRedHide)
	elseif self.ToValue >= GreenV then
		-- FLOG_WARNING("AlchemistItem PlayAnimation(self.AnimGreenHide)")
		self:PlayAnimation(self.AnimGreenHide)
	end
end

function CrafterAlchemistItemView:OnRegisterUIEvent()

end

function CrafterAlchemistItemView:OnRegisterGameEvent()

end

function CrafterAlchemistItemView:OnRegisterBinder()

end

function CrafterAlchemistItemView:UpdateSkillRsp(CrafterSkillRsp)
	if CrafterSkillRsp then
		--反应强度
		local Value = CrafterSkillRsp.Features[ProtoCS.FeatureType.FEATURE_TYPE_REACTION_INTENSITY] or 0

		local LastValue = self.ToValue or 0
		self.ToValue = Value / 100
		if self.ToValue > 1 then
			self.ToValue = 1
		end

		-- FLOG_WARNING("AlchemistItem UpdateSkillRsp Last:%.2f To:%.2f", LastValue, self.ToValue)
		if LastValue ~= self.ToValue then
			self:PlayAnimPointer(LastValue, self.ToValue)
		end

		if LastValue >= RedV and self.ToValue < RedV then
			-- FLOG_WARNING("AlchemistItem PlayAnimation(self.AnimRedHide)")
			self:PlayAnimation(self.AnimRedHide)
		end
		
		if LastValue >= GreenV and LastValue < RedV 
			and (self.ToValue >= RedV or self.ToValue < GreenV) then
			self:PlayAnimation(self.AnimGreenHide)
			-- FLOG_WARNING("AlchemistItem PlayAnimation(self.AnimGreenHide)")
		end

		if self.ToValue >= GreenV and self.ToValue < RedV and (LastValue < GreenV or LastValue >= RedV) then
			self:PlayAnimation(self.AnimGreenShow)
			-- FLOG_WARNING("AlchemistItem PlayAnimation(self.AnimGreenShow)")
		elseif self.ToValue >= RedV and self.ToValue <= 1 and LastValue < RedV then
			-- FLOG_WARNING("AlchemistItem PlayAnimation(self.AnimRedShow)")
			self:PlayAnimation(self.AnimRedShow)
		end
	end
end

return CrafterAlchemistItemView