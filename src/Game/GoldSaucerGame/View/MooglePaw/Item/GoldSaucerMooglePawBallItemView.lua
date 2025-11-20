---
--- Author: Administrator
--- DateTime: 2024-02-28 17:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local MogulBallType = ProtoRes.Game.MogulBallType
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MoogleBallShowState = GoldSaucerMiniGameDefine.MoogleBallShowState
local FLOG_INFO = _G.FLOG_INFO

---@class GoldSaucerMooglePawBallItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field MI_DX_Common_GoldSaucerGame_MonsterToss_4a UFImage
---@field MI_DX_Common_GoldSaucerGame_MonsterToss_4b UFImage
---@field P_DX_GoldSaucerGame_MonsterToss UUIParticleEmitter
---@field P_DX_GoldSaucerGame_MonsterToss_1 UUIParticleEmitter
---@field P_DX_GoldSaucerGame_MonsterToss_4 UUIParticleEmitter
---@field PanelBallBlue UFCanvasPanel
---@field PanelBallEffectPurple UFCanvasPanel
---@field PanelBallEffectRed UFCanvasPanel
---@field PanelBallGreen UFCanvasPanel
---@field PanelBallPurple UFCanvasPanel
---@field PanelBallRad UFCanvasPanel
---@field AnimEffectCloseGreen UWidgetAnimation
---@field AnimEffectClosePuple UWidgetAnimation
---@field AnimEffectCloseRed UWidgetAnimation
---@field AnimEffectGreen1 UWidgetAnimation
---@field AnimEffectGreen2 UWidgetAnimation
---@field AnimEffectGreen3 UWidgetAnimation
---@field AnimEffectPuple UWidgetAnimation
---@field AnimEffectRed UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMooglePawBallItemView = LuaClass(UIView, true)

function GoldSaucerMooglePawBallItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MI_DX_Common_GoldSaucerGame_MonsterToss_4a = nil
	--self.MI_DX_Common_GoldSaucerGame_MonsterToss_4b = nil
	--self.P_DX_GoldSaucerGame_MonsterToss = nil
	--self.P_DX_GoldSaucerGame_MonsterToss_1 = nil
	--self.P_DX_GoldSaucerGame_MonsterToss_4 = nil
	--self.PanelBallBlue = nil
	--self.PanelBallEffectPurple = nil
	--self.PanelBallEffectRed = nil
	--self.PanelBallGreen = nil
	--self.PanelBallPurple = nil
	--self.PanelBallRad = nil
	--self.AnimEffectCloseGreen = nil
	--self.AnimEffectClosePuple = nil
	--self.AnimEffectCloseRed = nil
	--self.AnimEffectGreen1 = nil
	--self.AnimEffectGreen2 = nil
	--self.AnimEffectGreen3 = nil
	--self.AnimEffectPuple = nil
	--self.AnimEffectRed = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawBallItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawBallItemView:OnInit()
	self.Binders = {
		{"Position", UIBinderValueChangedCallback.New(self, nil, self.OnBallPositionChange)},
		--{"ShowStateChange", UIBinderValueChangedCallback.New(self, nil, self.OnShowStateChange)},
		{"BallType", UIBinderValueChangedCallback.New(self, nil, self.OnBallTypeChange)},
	}
end

function GoldSaucerMooglePawBallItemView:OnDestroy()

end

function GoldSaucerMooglePawBallItemView:OnShow()
	
end

function GoldSaucerMooglePawBallItemView:OnHide()

end

function GoldSaucerMooglePawBallItemView:OnRegisterUIEvent()

end

function GoldSaucerMooglePawBallItemView:OnRegisterGameEvent()

end

function GoldSaucerMooglePawBallItemView:OnRegisterBinder()
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

function GoldSaucerMooglePawBallItemView:OnBallPositionChange(NewValue)
	if nil == NewValue then
		return
	end
	local Vector = NewValue:GetVector2D()
	UIUtil.CanvasSlotSetPosition(self.PanelBallBlue, Vector)
	UIUtil.CanvasSlotSetPosition(self.PanelBallPurple, Vector)
	UIUtil.CanvasSlotSetPosition(self.PanelBallRad, Vector)
	UIUtil.CanvasSlotSetPosition(self.PanelBallGreen, Vector)
end

function GoldSaucerMooglePawBallItemView:OnBallTypeChange(_, _)
	self:UpdateBallShow()
end

function GoldSaucerMooglePawBallItemView:OnShowStateChange(NewValue)
	if not NewValue then
		return
	end
	if NewValue == MoogleBallShowState.Strong then
		-- 2024.10.23 隐藏抓中球体，使用莫古力主体抓住的球代替
		UIUtil.SetIsVisible(self.PanelBallBlue, false)
		UIUtil.SetIsVisible(self.PanelBallPurple, false)
		UIUtil.SetIsVisible(self.PanelBallRad, false)
		UIUtil.SetIsVisible(self.PanelBallGreen, false)
	elseif NewValue == MoogleBallShowState.Weak then
		-- TODO 弱化或者隐藏球体的显示
	elseif NewValue == MoogleBallShowState.Normal then
		-- 正常显示
		self:UpdateBallShow()
	end
end

function GoldSaucerMooglePawBallItemView:OnAnimationFinished(Anim)
	if Anim == self.AnimEffectPuple then
		self:PlayAnimation(self.AnimEffectClosePuple)
	elseif Anim == self.AnimEffectClosePuple then
		self:ResetPurpleParticle()
	elseif Anim == self.AnimEffectCloseRed then
		self:ResetRedParticle()
	elseif Anim == self.AnimEffectCloseGreen then
		self:ResetStarParticle()
	end
end

--- 莫古力上显示抓取结果
---@param AnimIndex number@BallItemVM里存储的AnimIndex，保持动画一致
function GoldSaucerMooglePawBallItemView:ShowCatchResult(BallType, AnimIndex)
	UIUtil.SetIsVisible(self.PanelBallBlue, false)
	UIUtil.SetIsVisible(self.PanelBallPurple, false)
	UIUtil.SetIsVisible(self.PanelBallRad, false)
	UIUtil.SetIsVisible(self.PanelBallGreen, false)

	if BallType == MogulBallType.MogulBallTypeBlue then
		UIUtil.SetIsVisible(self.PanelBallBlue, true)
	elseif BallType == MogulBallType.MogulBallTypeOrange then
		UIUtil.SetIsVisible(self.PanelBallPurple, true)
	elseif BallType == MogulBallType.MogulBallTypeRed then
		UIUtil.SetIsVisible(self.PanelBallRad, true)
		UIUtil.SetIsVisible(self.MI_DX_Common_GoldSaucerGame_MonsterToss_4a, false)
		self:PlayAnimation(self.AnimEffectRed)
	elseif BallType == MogulBallType.MogulBallTypeStar then
		UIUtil.SetIsVisible(self.PanelBallGreen, true)
		local AnimToPlay = self[string.format("AnimEffectGreen%d", AnimIndex)]
		self:PlayAnimation(AnimToPlay)
	end
end

function GoldSaucerMooglePawBallItemView:ResetRedParticle()
	if self.P_DX_GoldSaucerGame_MonsterToss_4 == nil then
		return
	end
	if not self.P_DX_GoldSaucerGame_MonsterToss_4.IsPlaying then
		return
	end
	self.P_DX_GoldSaucerGame_MonsterToss_4:ResetParticle()
end

function GoldSaucerMooglePawBallItemView:ResetPurpleParticle()
	if self.P_DX_GoldSaucerGame_MonsterToss == nil then
		return
	end
	if not self.P_DX_GoldSaucerGame_MonsterToss.IsPlaying then
		return
	end
	self.P_DX_GoldSaucerGame_MonsterToss:ResetParticle()
end

function GoldSaucerMooglePawBallItemView:ResetStarParticle()
	if self.P_DX_GoldSaucerGame_MonsterToss_1 == nil then
		return
	end
	if not self.P_DX_GoldSaucerGame_MonsterToss_1.IsPlaying then
		return
	end
	self.P_DX_GoldSaucerGame_MonsterToss_1:ResetParticle()
end

function GoldSaucerMooglePawBallItemView:UpdateBallShow()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	local BallType = ViewModel.BallType or MogulBallType.MogulBallTypeInvalid
	-- Red
	UIUtil.SetIsVisible(self.PanelBallRad, BallType == MogulBallType.MogulBallTypeRed)
	UIUtil.SetIsVisible(self.PanelBallEffectRed, BallType == MogulBallType.MogulBallTypeRed)
	-- Blue
	UIUtil.SetIsVisible(self.PanelBallBlue, BallType == MogulBallType.MogulBallTypeBlue)
	-- Purple
	UIUtil.SetIsVisible(self.PanelBallPurple, BallType == MogulBallType.MogulBallTypeOrange)
	UIUtil.SetIsVisible(self.PanelBallEffectPurple, BallType == MogulBallType.MogulBallTypeOrange)
	-- Star
	UIUtil.SetIsVisible(self.PanelBallGreen, BallType == MogulBallType.MogulBallTypeStar)

	-- 处理特效
	self:PlayAnimation(self.AnimEffectCloseRed)
	self:PlayAnimation(self.AnimEffectClosePuple)
	self:PlayAnimation(self.AnimEffectCloseGreen)
	self:ResetRedParticle()
	self:ResetPurpleParticle()
	self:ResetStarParticle()
	if BallType == MogulBallType.MogulBallTypeRed then
		self:PlayAnimation(self.AnimEffectRed)
	elseif BallType == MogulBallType.MogulBallTypeOrange then
		self:PlayAnimation(self.AnimEffectPuple)
	elseif BallType == MogulBallType.MogulBallTypeStar then
		local AnimIndex = ViewModel.StarAnimIndex
		if type(AnimIndex) == "number" then
			local AnimToPlay = self[string.format("AnimEffectGreen%d", AnimIndex)]
			if AnimToPlay then
				self:PlayAnimation(AnimToPlay)
			end
		end
	end
end

return GoldSaucerMooglePawBallItemView