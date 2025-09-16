---
--- Author: Administrator
--- DateTime: 2024-02-04 11:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class GoldSaucerCuffchallengeBeginsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Begins UScaleBox
---@field P_EFF_particles_GoldSaucer_Cuff_9 UUIParticleEmitter
---@field Prepare UScaleBox
---@field TextBegins UFTextBlock
---@field TextPrepare UFTextBlock
---@field AnimBegins UWidgetAnimation
---@field AnimPrepare UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCuffchallengeBeginsItemView = LuaClass(UIView, true)

function GoldSaucerCuffchallengeBeginsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Begins = nil
	--self.P_EFF_particles_GoldSaucer_Cuff_9 = nil
	--self.Prepare = nil
	--self.TextBegins = nil
	--self.TextPrepare = nil
	--self.AnimBegins = nil
	--self.AnimPrepare = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffchallengeBeginsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffchallengeBeginsItemView:OnInit()
	self.PrepareEndCallBack = nil
	self.BeginEndCallBack = nil
end

function GoldSaucerCuffchallengeBeginsItemView:OnDestroy()

end

function GoldSaucerCuffchallengeBeginsItemView:OnShow()
	local LSTR = _G.LSTR
	self.TextPrepare:SetText(LSTR(250021)) -- 准备
	self.TextBegins:SetText(LSTR(250022)) -- 开始

end

function GoldSaucerCuffchallengeBeginsItemView:OnHide()
	self:StopAllAnimations()
	self.PrepareEndCallBack = nil
	self.BeginEndCallBack = nil
end

function GoldSaucerCuffchallengeBeginsItemView:OnRegisterUIEvent()

end

function GoldSaucerCuffchallengeBeginsItemView:OnRegisterGameEvent()

end

function GoldSaucerCuffchallengeBeginsItemView:OnRegisterBinder()

end

function GoldSaucerCuffchallengeBeginsItemView:SetPrepare(CallBack)
	UIUtil.SetIsVisible(self.Begins, false)
	UIUtil.SetIsVisible(self.Prepare, true)
	self:PlayAnimation(self.AnimPrepare)
	self.PrepareEndCallBack = CallBack
end

function GoldSaucerCuffchallengeBeginsItemView:SetBegin(CallBack)
	UIUtil.SetIsVisible(self.Begins, true)
	UIUtil.SetIsVisible(self.Prepare, false)
	self:PlayAnimation(self.AnimBegins)
	self.BeginEndCallBack = CallBack
end

function GoldSaucerCuffchallengeBeginsItemView:OnAnimationFinished(Anim)
	if Anim == self.AnimPrepare then
		local PrepareCallBack = self.PrepareEndCallBack
		if PrepareCallBack then
			PrepareCallBack()
			self.PrepareEndCallBack = nil
		end
	elseif Anim == self.AnimBegins then
		local BeginCallBack = self.BeginEndCallBack
		if BeginCallBack then
			BeginCallBack()
			self.BeginCallBack = nil
		end
		self:ResetParticle()
	end
end

function GoldSaucerCuffchallengeBeginsItemView:ResetParticle()
	self.P_EFF_particles_GoldSaucer_Cuff_9:ResetParticle()
	_G.ObjectMgr:CollectGarbage(false)
end

return GoldSaucerCuffchallengeBeginsItemView