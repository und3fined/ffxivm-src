---
--- Author: Administrator
--- DateTime: 2024-03-08 19:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class GoldSaucerCrystalTowerStrikerScoreFeedbackItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFFExcellent UFCanvasPanel
---@field EFFPerfect UFCanvasPanel
---@field HorizontalMultiple UFHorizontalBox
---@field P_DX_CrystalTowerStriker_4 UUIParticleEmitter
---@field P_DX_CrystalTowerStriker_5 UUIParticleEmitter
---@field P_DX_CrystalTowerStriker_6 UUIParticleEmitter
---@field PanelExcellent UFCanvasPanel
---@field PanelMistake UFCanvasPanel
---@field PanelPerfect UFHorizontalBox
---@field TextExcellent UFTextBlock
---@field TextMistake UFTextBlock
---@field TextMultiple1 UFTextBlock
---@field TextPerfect UFTextBlock
---@field TextX UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCrystalTowerStrikerScoreFeedbackItemView = LuaClass(UIView, true)

function GoldSaucerCrystalTowerStrikerScoreFeedbackItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFFExcellent = nil
	--self.EFFPerfect = nil
	--self.HorizontalMultiple = nil
	--self.P_DX_CrystalTowerStriker_4 = nil
	--self.P_DX_CrystalTowerStriker_5 = nil
	--self.P_DX_CrystalTowerStriker_6 = nil
	--self.PanelExcellent = nil
	--self.PanelMistake = nil
	--self.PanelPerfect = nil
	--self.TextExcellent = nil
	--self.TextMistake = nil
	--self.TextMultiple1 = nil
	--self.TextPerfect = nil
	--self.TextX = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerScoreFeedbackItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerScoreFeedbackItemView:OnInit()
	self.Binders = {
		{"bProfectVisible", UIBinderSetIsVisible.New(self, self.PanelPerfect)},
		{"bExcellentVisible", UIBinderSetIsVisible.New(self, self.PanelExcellent)},
		{"bProfectVisible", UIBinderSetIsVisible.New(self, self.EFFPerfect)},
		{"bExcellentVisible", UIBinderSetIsVisible.New(self, self.EFFExcellent)},
		{"bMissVisible", UIBinderSetIsVisible.New(self, self.PanelMistake)},
		{"bMultipleVisible", UIBinderSetIsVisible.New(self, self.HorizontalMultiple)}, --
		{"ComboNum", UIBinderSetText.New(self, self.TextMultiple1)},
		-- {"ChooseVisibleIndex", UIBinderSetActiveWidgetIndex.New(self, self.FWidgetSwitcher_0)},
		{"CallBackIndex", UIBinderValueChangedCallback.New(self, nil, self.PlayAnimIn)},

	}
end

function GoldSaucerCrystalTowerStrikerScoreFeedbackItemView:OnDestroy()

end

function GoldSaucerCrystalTowerStrikerScoreFeedbackItemView:OnShow()
	local LSTR = _G.LSTR
	self.TextMistake:SetText(LSTR(250020)) -- 失误
	self.TextPerfect:SetText(LSTR(250018)) -- 完美
	self.TextExcellent:SetText(LSTR(250019)) -- 优秀
	self.TextX:SetText("x") -- × 用来表示几连击

end

function GoldSaucerCrystalTowerStrikerScoreFeedbackItemView:OnHide()

end

function GoldSaucerCrystalTowerStrikerScoreFeedbackItemView:OnRegisterUIEvent()

end

function GoldSaucerCrystalTowerStrikerScoreFeedbackItemView:OnRegisterGameEvent()

end

function GoldSaucerCrystalTowerStrikerScoreFeedbackItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

function GoldSaucerCrystalTowerStrikerScoreFeedbackItemView:PlayAnimIn()
	self:PlayAnimation(self.AnimIn)
end

function GoldSaucerCrystalTowerStrikerScoreFeedbackItemView:OnAnimationFinished(Animation)
	if Animation == self.AnimIn then
		self.P_DX_CrystalTowerStriker_4:ResetParticle()
		self.P_DX_CrystalTowerStriker_5:ResetParticle()
		self.P_DX_CrystalTowerStriker_6:ResetParticle()
	end
end


return GoldSaucerCrystalTowerStrikerScoreFeedbackItemView