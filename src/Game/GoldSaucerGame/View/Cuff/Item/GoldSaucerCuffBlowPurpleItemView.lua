---
--- Author: Administrator
--- DateTime: 2024-03-01 20:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderCanvasSlotSetSize = require ("Binder/UIBinderCanvasSlotSetSize")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local GoldSaucerMiniGameMgr = _G.GoldSaucerMiniGameMgr
local CuffInteractiveCfg = require("TableCfg/CuffInteractiveCfg") -- 交互物配置表
local CuffDefine = GoldSaucerMiniGameDefine.CuffDefine
local CuffBlowItemBase = require("Game/GoldSaucerGame/View/Cuff/Item/CuffBlowItemBase")

---@class GoldSaucerCuffBlowPurpleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BlowResult GoldSaucerCuffBlowResultItemView
---@field Btn UFButton
---@field FCanvasPanel_26 UFCanvasPanel
---@field P_DX_TheFinerMiner_8 UUIParticleEmitter
---@field P_EFF_particles_GoldSaucer_Cuff_1 UUIParticleEmitter
---@field P_EFF_particles_GoldSaucer_Cuff_2 UUIParticleEmitter
---@field AnimBurst UWidgetAnimation
---@field AnimUnWork UWidgetAnimation
---@field AnimWork UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCuffBlowPurpleItemView = LuaClass(CuffBlowItemBase, true)

function GoldSaucerCuffBlowPurpleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BlowResult = nil
	--self.Btn = nil
	--self.FCanvasPanel_26 = nil
	--self.P_DX_TheFinerMiner_8 = nil
	--self.P_EFF_particles_GoldSaucer_Cuff_1 = nil
	--self.P_EFF_particles_GoldSaucer_Cuff_2 = nil
	--self.AnimBurst = nil
	--self.AnimUnWork = nil
	--self.AnimWork = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffBlowPurpleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BlowResult)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffBlowPurpleItemView:OnInit()
	self.GameType = MiniGameType.Cuff
	self.Binders = {
		{"bBtnVisible", UIBinderSetIsVisible.New(self, self.Btn, false, true)},
		{"bBlowResultVisible", UIBinderSetIsVisible.New(self, self.BlowResult)},
		{"Scale", UIBinderCanvasSlotSetSize.New(self, self.FCanvasPanel_26, true)},
		{"CallBackIndex", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateCallBack)},
	}
end

function GoldSaucerCuffBlowPurpleItemView:OnDestroy()

end

function GoldSaucerCuffBlowPurpleItemView:OnShow()

end

function GoldSaucerCuffBlowPurpleItemView:OnHide()
	self:UnRegisterAllTimer()
	self:StopAllAnimations()

end

function GoldSaucerCuffBlowPurpleItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClick)
end

function GoldSaucerCuffBlowPurpleItemView:OnRegisterGameEvent()

end

function GoldSaucerCuffBlowPurpleItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
	self.BlowResult:SetParams({ Data = ViewModel:GetBlowResultItemVM()})
end


function GoldSaucerCuffBlowPurpleItemView:OnBtnClick()
	self:OnBaseBtnClick(false)
end

-- -- @type 每次更新VM时调用
function GoldSaucerCuffBlowPurpleItemView:OnUpdateCallBack(Value)
	self:OnBaseUpdateCallBack()
end

function GoldSaucerCuffBlowPurpleItemView.ArrivalShowTime(self)
	-- local bVisible = self.ID == self.Pos
	if self.FCanvasPanel_26 ~= nil then
		UIUtil.SetIsVisible(self.FCanvasPanel_26, self.Pos ~= nil, true)
	end
	self.ViewModel.bBtnVisible = true
end

function GoldSaucerCuffBlowPurpleItemView.ArrivalShrinkTime(self)
	local ShrinkSp = self.ShrinkSp
	self:PlayAnimation(self.AnimWork, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, ShrinkSp)

	self.ShrinkTimer = self:RegisterTimer(function() 
		local GameInst = _G.GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
		if GameInst ~= nil then
			GameInst:ResetComboNum()
		end
	end, 2 /ShrinkSp)
end

function GoldSaucerCuffBlowPurpleItemView:UpdateResult(HitResult)
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	ViewModel:UpdateResultTip(HitResult)
end


function GoldSaucerCuffBlowPurpleItemView:GetViewModel()
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


function GoldSaucerCuffBlowPurpleItemView:PlayResultAnimByHitResult(HitResult, ComboNum)
	local InteractResult = GoldSaucerMiniGameDefine.InteractResult
	local NeedAnim
    if HitResult == InteractResult.Fail then
        NeedAnim = self.BlowResult.AnimFail
    elseif HitResult == InteractResult.Excellent then
        NeedAnim = self.BlowResult.AnimExcellent
    elseif HitResult == InteractResult.Perfect then
		if ComboNum > 1 then
			NeedAnim = self.BlowResult.AnimperfectCombo
		else
			NeedAnim = self.BlowResult.AnimPerfect
		end
    end
	self.BlowResult:PlayAnimation(NeedAnim)
end

function GoldSaucerCuffBlowPurpleItemView:OnAnimationFinished(Anim)
	if Anim == self.AnimBurst then
		self:ResetParticles()
	end
end

function GoldSaucerCuffBlowPurpleItemView:ResetParticles()
	self.P_DX_TheFinerMiner_8:ResetParticle()
	self.P_EFF_particles_GoldSaucer_Cuff_1:ResetParticle()
	self.P_EFF_particles_GoldSaucer_Cuff_2:ResetParticle()
end

return GoldSaucerCuffBlowPurpleItemView