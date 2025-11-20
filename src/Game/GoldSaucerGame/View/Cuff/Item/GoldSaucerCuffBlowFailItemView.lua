---
--- Author: Alex
--- DateTime: 2025-07-07 11:21
--- Description:新增负面交互物
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CuffBlowItemBase = require("Game/GoldSaucerGame/View/Cuff/Item/CuffBlowItemBase")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderCanvasSlotSetSize = require ("Binder/UIBinderCanvasSlotSetSize")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType

---@class GoldSaucerCuffBlowFailItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BlowResult GoldSaucerCuffBlowResultItemView
---@field Btn UFButton
---@field FCanvasPanel_26 UFCanvasPanel
---@field AnimUnWork UWidgetAnimation
---@field AnimWork UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCuffBlowFailItemView = LuaClass(CuffBlowItemBase, true)

function GoldSaucerCuffBlowFailItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BlowResult = nil
	--self.Btn = nil
	--self.FCanvasPanel_26 = nil
	--self.AnimUnWork = nil
	--self.AnimWork = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffBlowFailItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BlowResult)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffBlowFailItemView:OnInit()
	self.GameType = MiniGameType.Cuff
	self.Binders = {
		{"bBtnVisible", UIBinderSetIsVisible.New(self, self.Btn, false, true)},
		{"bBlowResultVisible", UIBinderSetIsVisible.New(self, self.BlowResult)},
		{"Scale", UIBinderCanvasSlotSetSize.New(self, self.FCanvasPanel_26, true)},
		{"CallBackIndex", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateCallBack)},
	}
end

function GoldSaucerCuffBlowFailItemView:OnDestroy()

end

function GoldSaucerCuffBlowFailItemView:OnShow()

end

function GoldSaucerCuffBlowFailItemView:OnHide()
	self:UnRegisterAllTimer()
	self:StopAllAnimations()
end

function GoldSaucerCuffBlowFailItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClick)
end

function GoldSaucerCuffBlowFailItemView:OnRegisterGameEvent()

end

function GoldSaucerCuffBlowFailItemView:OnRegisterBinder()
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

function GoldSaucerCuffBlowFailItemView:OnBtnClick()
	self:OnBaseBtnClick(false)
end

function GoldSaucerCuffBlowFailItemView.ArrivalShowTime(self)
	if self.FCanvasPanel_26 ~= nil then
		UIUtil.SetIsVisible(self.FCanvasPanel_26, self.Pos ~= nil, true)
	end
	self.ViewModel.bBtnVisible = true
end

function GoldSaucerCuffBlowFailItemView.ArrivalShrinkTime(self)
	local ShrinkSp = self.ShrinkSp
	self:PlayAnimation(self.AnimWork, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, ShrinkSp)
end

-- -- @type 每次更新VM时调用
function GoldSaucerCuffBlowFailItemView:OnUpdateCallBack()
	self:OnBaseUpdateCallBack()
end

function GoldSaucerCuffBlowFailItemView:UpdateResult(HitResult)
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

function GoldSaucerCuffBlowFailItemView:GetViewModel()
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

function GoldSaucerCuffBlowFailItemView:PlayResultAnimByHitResult(HitResult, ComboNum)
	local InteractResult = GoldSaucerMiniGameDefine.InteractResult
	local NeedAnim
    if HitResult == InteractResult.Fail or HitResult == InteractResult.Error then
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

return GoldSaucerCuffBlowFailItemView