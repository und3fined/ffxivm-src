---
--- Author: Administrator
--- DateTime: 2024-03-28 09:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class GoldSaucerCrystalTowerStrikerCrystalItemEFFView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field EFFPanel01 UFCanvasPanel
---@field EFFPanel02 UFCanvasPanel
---@field EFFPanel03 UFCanvasPanel
---@field FWidgetSwitcher_0 UFWidgetSwitcher
---@field P_DX_CrystalTowerStriker_13 UUIParticleEmitter
---@field P_DX__CrystalTowerStriker_7_a UUIParticleEmitter
---@field P_DX__CrystalTowerStriker_8_a UUIParticleEmitter
---@field AnimArrive UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCrystalTowerStrikerCrystalItemEFFView = LuaClass(UIView, true)

function GoldSaucerCrystalTowerStrikerCrystalItemEFFView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.EFFPanel01 = nil
	--self.EFFPanel02 = nil
	--self.EFFPanel03 = nil
	--self.FWidgetSwitcher_0 = nil
	--self.P_DX_CrystalTowerStriker_13 = nil
	--self.P_DX__CrystalTowerStriker_7_a = nil
	--self.P_DX__CrystalTowerStriker_8_a = nil
	--self.AnimArrive = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerCrystalItemEFFView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerCrystalItemEFFView:OnInit()

end

function GoldSaucerCrystalTowerStrikerCrystalItemEFFView:OnDestroy()

end

function GoldSaucerCrystalTowerStrikerCrystalItemEFFView:OnShow()

end

function GoldSaucerCrystalTowerStrikerCrystalItemEFFView:OnHide()

end

function GoldSaucerCrystalTowerStrikerCrystalItemEFFView:OnRegisterUIEvent()

end

function GoldSaucerCrystalTowerStrikerCrystalItemEFFView:OnRegisterGameEvent()

end

function GoldSaucerCrystalTowerStrikerCrystalItemEFFView:OnRegisterBinder()

end

function GoldSaucerCrystalTowerStrikerCrystalItemEFFView:ActiveSwitcherAndPlayAnim(NewIndex)
	self.FWidgetSwitcher_0:SetActiveWidgetIndex(NewIndex)
	self:PlayAnimation(self.AnimArrive)
	local bEffectVisible01 = NewIndex and NewIndex > 0 and NewIndex ~= 4--CT_CATEGORY_ERROR
	local bEffectVisible02 = NewIndex and NewIndex > 0 and NewIndex < 4--CT_CATEGORY_LOW,CT_CATEGORY_MIDDLE,CT_CATEGORY_HIGH
	local bEffectVisible03 = NewIndex and NewIndex == 5 --CT_CATEGORY_FINAL_ONE
	UIUtil.SetIsVisible(self.EFFPanel01, bEffectVisible01)
	UIUtil.SetIsVisible(self.EFFPanel02, bEffectVisible02)
	UIUtil.SetIsVisible(self.EFFPanel03, bEffectVisible03)
end

function GoldSaucerCrystalTowerStrikerCrystalItemEFFView:OnAnimationFinished(Animation)
	if Animation == self.AnimArrive then
		self.P_DX_CrystalTowerStriker_13:ResetParticle()
		self.P_DX__CrystalTowerStriker_7_a:ResetParticle()
		self.P_DX__CrystalTowerStriker_8_a:ResetParticle()
	end
end

return GoldSaucerCrystalTowerStrikerCrystalItemEFFView