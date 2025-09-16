---
--- Author: Administrator
--- DateTime: 2024-02-04 11:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderCanvasSlotSetSize = require ("Binder/UIBinderCanvasSlotSetSize")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local DelayTime = GoldSaucerMiniGameDefine.DelayTime
local MiniGameVM = require("Game/GoldSaucerMiniGame/MiniGameVM")
local GoldSaucerMiniGameMgr = _G.GoldSaucerMiniGameMgr
local CuffInteractiveCfg = require("TableCfg/CuffInteractiveCfg") -- 交互物配置表

local CuffBatterCfg = require("TableCfg/CuffBatterCfg")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local CuffBlowItemBase = require("Game/GoldSaucerGame/View/Cuff/Item/CuffBlowItemBase")

local CuffDefine = GoldSaucerMiniGameDefine.CuffDefine
---@class GoldSaucerCuffBlowRedItemView : UIView
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
local GoldSaucerCuffBlowRedItemView = LuaClass(CuffBlowItemBase, true)

function GoldSaucerCuffBlowRedItemView:Ctor()
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

function GoldSaucerCuffBlowRedItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BlowResult)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffBlowRedItemView:OnInit()
	self.GameType = MiniGameType.Cuff
	self.Binders = {
		{"bBtnVisible", UIBinderSetIsVisible.New(self, self.Btn, false, true)},
		{"bBlowResultVisible", UIBinderSetIsVisible.New(self, self.BlowResult)},
		{"Scale", UIBinderCanvasSlotSetSize.New(self, self.FCanvasPanel_26, true)},
		{"CallBackIndex", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateCallBack)},
	}
end

function GoldSaucerCuffBlowRedItemView:OnDestroy()

end

function GoldSaucerCuffBlowRedItemView:OnShow()
	-- local Params = self.Params
	-- if Params == nil then
	-- 	return
	-- end
	-- local ViewModel = Params.Data
	-- if ViewModel == nil then
	-- 	return
	-- end
	-- local DelayShowTime = ViewModel.BindableProperties.DelayShowTime.Value + DelayTime.PerpareToBegin
    -- self:RegisterTimer(self.ArrivalShowTime, DelayShowTime, 0, 1, ViewModel)

	-- local DelayShrinkTime = ViewModel.BindableProperties.DelayShrinkTime.Value + DelayTime.PerpareToBegin
	-- self:RegisterTimer(self.ArrivalShrinkTime, DelayShrinkTime, 0, 1, ViewModel)

	-- -- 60s后自动消失算失败
	-- local function OnHideCallBack()
	-- 	local GameInst = GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
	-- 	GameInst:CheckIsFinishRoundAndSend(ViewModel.ID)
	-- 	UIUtil.SetIsVisible(self.FCanvasPanel_26, false)
	-- end
	-- self:RegisterTimer(OnHideCallBack, DelayTime.BlowAutoHide, 0, 1)
end

function GoldSaucerCuffBlowRedItemView:OnHide()
	-- UIUtil.SetIsVisible(self.FCanvasPanel_26, false)
	self:UnRegisterAllTimer()
	self:StopAllAnimations()

end

function GoldSaucerCuffBlowRedItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClick)
end

function GoldSaucerCuffBlowRedItemView:OnRegisterGameEvent()

end

function GoldSaucerCuffBlowRedItemView:OnRegisterBinder()
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

-- -- -- @type 每次更新VM时调用
function GoldSaucerCuffBlowRedItemView:OnUpdateCallBack(Value)
	self:OnBaseUpdateCallBack()
end

function GoldSaucerCuffBlowRedItemView:OnBtnClick()
	self:OnBaseBtnClick(true)
end

function GoldSaucerCuffBlowRedItemView.ArrivalShowTime(self)
	-- local bVisible = self.ID == self.Pos
	if self.FCanvasPanel_26 ~= nil then
		UIUtil.SetIsVisible(self.FCanvasPanel_26, self.Pos ~= nil, true)
	end
end

function GoldSaucerCuffBlowRedItemView.ArrivalShrinkTime(self)
	local ShrinkSp = self.ShrinkSp
	self:PlayAnimation(self.AnimWork, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, ShrinkSp)

	self.ShrinkTimer = self:RegisterTimer(function() 
		local GameInst = _G.GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
		if GameInst ~= nil then
			GameInst:ResetComboNum()
		end
	end, 2 /ShrinkSp)
end

function GoldSaucerCuffBlowRedItemView:UpdateResult(HitResult)
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

function GoldSaucerCuffBlowRedItemView:GetViewModel()
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

function GoldSaucerCuffBlowRedItemView:PlayResultAnimByHitResult(HitResult, ComboNum)
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

function GoldSaucerCuffBlowRedItemView:OnAnimationFinished(Anim)
	if Anim == self.AnimBurst then
		self:ResetParticles()
	end
end

function GoldSaucerCuffBlowRedItemView:ResetParticles()
	self.P_DX_TheFinerMiner_8:ResetParticle()
	self.P_EFF_particles_GoldSaucer_Cuff_1:ResetParticle()
	self.P_EFF_particles_GoldSaucer_Cuff_2:ResetParticle()
end

return GoldSaucerCuffBlowRedItemView