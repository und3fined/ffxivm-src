---
--- Author: Administrator
--- DateTime: 2024-02-04 11:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class GoldSaucerCuffChallengeResultsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field P_DX_CrystalTowerStriker_12aa UUIParticleEmitter
---@field P_EFF_particles_GoldSaucer_Cuff_10 UUIParticleEmitter
---@field P_EFF_particles_GoldSaucer_Cuff_11 UUIParticleEmitter
---@field P_EFF_particles_GoldSaucer_Cuff_3 UUIParticleEmitter
---@field P_EFF_particles_GoldSaucer_Cuff_4 UUIParticleEmitter
---@field P_EFF_particles_GoldSaucer_Cuff_9 UUIParticleEmitter
---@field TextFail UFTextBlock
---@field TextSuccess UFTextBlock
---@field TextTimesup UFTextBlock
---@field AnimFaill UWidgetAnimation
---@field AnimSuccess UWidgetAnimation
---@field AnimTimesup UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCuffChallengeResultsItemView = LuaClass(UIView, true)

function GoldSaucerCuffChallengeResultsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.P_DX_CrystalTowerStriker_12aa = nil
	--self.P_EFF_particles_GoldSaucer_Cuff_10 = nil
	--self.P_EFF_particles_GoldSaucer_Cuff_11 = nil
	--self.P_EFF_particles_GoldSaucer_Cuff_3 = nil
	--self.P_EFF_particles_GoldSaucer_Cuff_4 = nil
	--self.P_EFF_particles_GoldSaucer_Cuff_9 = nil
	--self.TextFail = nil
	--self.TextSuccess = nil
	--self.TextTimesup = nil
	--self.AnimFaill = nil
	--self.AnimSuccess = nil
	--self.AnimTimesup = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffChallengeResultsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffChallengeResultsItemView:OnInit()

end

function GoldSaucerCuffChallengeResultsItemView:OnDestroy()

end

function GoldSaucerCuffChallengeResultsItemView:OnShow()
	local LSTR = _G.LSTR
	self.TextTimesup:SetText(LSTR(250023)) -- 时间结束
	self.TextSuccess:SetText(LSTR(250024)) -- 挑战成功
	self.TextFail:SetText(LSTR(250025))		-- 挑战失败

end

function GoldSaucerCuffChallengeResultsItemView:OnHide()

end

function GoldSaucerCuffChallengeResultsItemView:OnRegisterUIEvent()

end

function GoldSaucerCuffChallengeResultsItemView:OnRegisterGameEvent()

end

function GoldSaucerCuffChallengeResultsItemView:OnRegisterBinder()

end

function GoldSaucerCuffChallengeResultsItemView:OnAnimationFinished(Anim)
	if Anim == self.AnimFaill or Anim == self.AnimSuccess or Anim == self.AnimTimesup then
		self:ResetParticles()
	end
end

function GoldSaucerCuffChallengeResultsItemView:ResetParticles()
	self.P_DX_CrystalTowerStriker_12aa:ResetParticle()
	self.P_EFF_particles_GoldSaucer_Cuff_10:ResetParticle()
	self.P_EFF_particles_GoldSaucer_Cuff_11:ResetParticle()
	self.P_EFF_particles_GoldSaucer_Cuff_3:ResetParticle()
	self.P_EFF_particles_GoldSaucer_Cuff_4:ResetParticle()
	self.P_EFF_particles_GoldSaucer_Cuff_9:ResetParticle()
	_G.ObjectMgr:CollectGarbage(false)
end

return GoldSaucerCuffChallengeResultsItemView