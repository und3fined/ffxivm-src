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
---@field P_DX_GoldSaucerGame_MonsterToss_4 UUIParticleEmitter
---@field PanelBallBlue UFCanvasPanel
---@field PanelBallEffectPurple UFCanvasPanel
---@field PanelBallEffectRed UFCanvasPanel
---@field PanelBallPurple UFCanvasPanel
---@field PanelBallRad UFCanvasPanel
---@field AnimEffectClosePuple UWidgetAnimation
---@field AnimEffectCloseRed UWidgetAnimation
---@field AnimEffectPuple UWidgetAnimation
---@field AnimEffectRed UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMooglePawBallItemView = LuaClass(UIView, true)

function GoldSaucerMooglePawBallItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MI_DX_Common_GoldSaucerGame_MonsterToss_4a = nil
	--self.MI_DX_Common_GoldSaucerGame_MonsterToss_4b = nil
	--self.P_DX_GoldSaucerGame_MonsterToss = nil
	--self.P_DX_GoldSaucerGame_MonsterToss_4 = nil
	--self.PanelBallBlue = nil
	--self.PanelBallEffectPurple = nil
	--self.PanelBallEffectRed = nil
	--self.PanelBallPurple = nil
	--self.PanelBallRad = nil
	--self.AnimEffectClosePuple = nil
	--self.AnimEffectCloseRed = nil
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
		{"ShowStateChange", UIBinderValueChangedCallback.New(self, nil, self.OnShowStateChange)},
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
	FLOG_INFO("MoogleRedBallHide: Reason: PositionError  Position:%s, %s", Vector.X, Vector.Y)
end

function GoldSaucerMooglePawBallItemView:OnBallTypeChange(NewType, OldType)
	-- Red
	UIUtil.SetIsVisible(self.PanelBallRad, NewType == MogulBallType.MogulBallTypeRed)
	UIUtil.SetIsVisible(self.PanelBallEffectRed, NewType == MogulBallType.MogulBallTypeRed)
	-- Blue
	UIUtil.SetIsVisible(self.PanelBallBlue, NewType == MogulBallType.MogulBallTypeBlue)
	-- Purple
	UIUtil.SetIsVisible(self.PanelBallPurple, NewType == MogulBallType.MogulBallTypeOrange)
	UIUtil.SetIsVisible(self.PanelBallEffectPurple, NewType == MogulBallType.MogulBallTypeOrange)

	-- 处理旧类型
	if OldType == MogulBallType.MogulBallTypeRed then
		self:PlayAnimation(self.AnimEffectCloseRed)
		FLOG_INFO("MoogleRedBallHide: Reason: TypeChangeAnim OldHide Time:%s", TimeUtil.GetServerLogicTime())
	elseif OldType == MogulBallType.MogulBallTypeOrange then
		self:PlayAnimation(self.AnimEffectClosePuple)
	end
	-- 处理新的类型
	if NewType == MogulBallType.MogulBallTypeRed then
		self:PlayAnimation(self.AnimEffectRed)
		FLOG_INFO("MoogleRedBallHide: Reason: TypeChangeAnim NewShow Time:%s", TimeUtil.GetServerLogicTime())
	else
		self:ResetRedParticle()
	end
	if NewType == MogulBallType.MogulBallTypeOrange then
		self:PlayAnimation(self.AnimEffectPuple)
	else
		self:ResetPurpleParticle()
	end
end

function GoldSaucerMooglePawBallItemView:OnShowStateChange(NewValue)
	if NewValue == MoogleBallShowState.Strong then
		-- 2024.10.23 隐藏抓中球体，使用莫古力主体抓住的球代替
		UIUtil.SetIsVisible(self.PanelBallBlue, false)
		UIUtil.SetIsVisible(self.PanelBallPurple, false)
		UIUtil.SetIsVisible(self.PanelBallRad, false)
	elseif NewValue == MoogleBallShowState.Weak then
		-- TODO 弱化或者隐藏球体的显示
	elseif NewValue == MoogleBallShowState.Normal then
		-- 正常显示

	end
end

function GoldSaucerMooglePawBallItemView:OnAnimationFinished(Anim)
	if Anim == self.AnimEffectPuple then
		self:PlayAnimation(self.AnimEffectClosePuple)
	elseif Anim == self.AnimEffectClosePuple then
		self:ResetPurpleParticle()
	elseif Anim == self.AnimEffectCloseRed then
		self:ResetRedParticle()
	end
end

function GoldSaucerMooglePawBallItemView:ShowCatchResult(BallType)
	UIUtil.SetIsVisible(self.PanelBallBlue, false)
	UIUtil.SetIsVisible(self.PanelBallPurple, false)
	UIUtil.SetIsVisible(self.PanelBallRad, false)

	if BallType == MogulBallType.MogulBallTypeBlue then
		UIUtil.SetIsVisible(self.PanelBallBlue, true)
	elseif BallType == MogulBallType.MogulBallTypeOrange then
		UIUtil.SetIsVisible(self.PanelBallPurple, true)
	elseif BallType == MogulBallType.MogulBallTypeRed then
		UIUtil.SetIsVisible(self.PanelBallRad, true)
		UIUtil.SetIsVisible(self.MI_DX_Common_GoldSaucerGame_MonsterToss_4a, false)
		self:PlayAnimation(self.AnimEffectRed)
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

return GoldSaucerMooglePawBallItemView