---
--- Author: Administrator
--- DateTime: 2024-02-19 15:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local ProtoCS = require("Protocol/ProtoCS")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local Anim = MiniGameClientConfig[MiniGameType.MonsterToss].Anim

local EventMgr = _G.EventMgr
local EventID = _G.EventID
local BasketballType = ProtoCS.BasketballType

---@class GoldSaucerMonsterTossBallItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBall UFImage
---@field P_DX_GoldSaucerGame_MonsterToss_3 UUIParticleEmitter
---@field AnimBombReady UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimResume UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMonsterTossBallItemView = LuaClass(UIView, true)

function GoldSaucerMonsterTossBallItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBall = nil
	--self.P_DX_GoldSaucerGame_MonsterToss_3 = nil
	--self.AnimBombReady = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimResume = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMonsterTossBallItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMonsterTossBallItemView:OnInit()
	self.MiniGameVM = nil
	self.Binders = {
		{"ImgPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgBall)},
		-- {"bBallVisible", UIBinderSetIsVisible.New(self, self.ImgBall)},

	}
end

function GoldSaucerMonsterTossBallItemView:OnDestroy()

end

function GoldSaucerMonsterTossBallItemView:OnShow()

end

function GoldSaucerMonsterTossBallItemView:OnHide()

end

function GoldSaucerMonsterTossBallItemView:OnRegisterUIEvent()

end

function GoldSaucerMonsterTossBallItemView:OnRegisterGameEvent()

end

function GoldSaucerMonsterTossBallItemView:OnRegisterBinder()
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

function GoldSaucerMonsterTossBallItemView:GetViewModel()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	return ViewModel
end

function GoldSaucerMonsterTossBallItemView:OnAnimationFinished(Animation)
	if Animation == self.AnimBombReady then
		self:ResetParticle()
	end
end

function GoldSaucerMonsterTossBallItemView:SetMiniGameVM(MiniGameVM)
	self.MiniGameVM = MiniGameVM
end

function GoldSaucerMonsterTossBallItemView:ResetParticle()
	if self.P_DX_GoldSaucerGame_MonsterToss_3 == nil then
		return
	end
	if not self.P_DX_GoldSaucerGame_MonsterToss_3.IsPlaying then
		return
	end
	self.P_DX_GoldSaucerGame_MonsterToss_3:ResetParticle()
	_G.ObjectMgr:CollectGarbage(false)
end

return GoldSaucerMonsterTossBallItemView