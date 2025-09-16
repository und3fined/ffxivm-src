---
--- Author: Leo
--- DateTime: 2024-10-31 10:02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local EventID = require("Define/EventID")
local ProtoRes = require ("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderCanvasSlotSetSize = require ("Binder/UIBinderCanvasSlotSetSize")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIUtil = require("Utils/UIUtil")
local GoldSaucerMiniGameMgr = _G.GoldSaucerMiniGameMgr
local CuffInteractiveCfg = require("TableCfg/CuffInteractiveCfg") -- 交互物配置表
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local CuffDefine = GoldSaucerMiniGameDefine.CuffDefine

local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local FLOG_INFO = _G.FLOG_INFO


---@class CuffBlowItemBase : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY

---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CuffBlowItemBase = LuaClass(UIView, true)

function CuffBlowItemBase:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY

	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CuffBlowItemBase:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CuffBlowItemBase:OnInit()
    self.Binders = {
		{"bBtnVisible", UIBinderSetIsVisible.New(self, self.Btn, false, true)},
		{"bBlowResultVisible", UIBinderSetIsVisible.New(self, self.BlowResult)},
		{"Scale", UIBinderCanvasSlotSetSize.New(self, self.FCanvasPanel_26, true)},
		{"CallBackIndex", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateCallBack)},
	}
end

function CuffBlowItemBase:OnDestroy()
end

function CuffBlowItemBase:OnShow()
end

function CuffBlowItemBase:OnHide()
end

function CuffBlowItemBase:OnRegisterUIEvent()

end

function CuffBlowItemBase:OnRegisterGameEvent()

end

function CuffBlowItemBase:OnRegisterTimer()

end

function CuffBlowItemBase:OnRegisterBinder()
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

function CuffBlowItemBase:OnBaseUpdateCallBack()
    local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self.ViewModel = ViewModel
	local Pos = ViewModel.BindableProperties.Pos.Value
	if Pos == 0 or Pos == nil then
		return
	end
	local GameInst = _G.GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
    if GameInst == nil or not GameInst.IsBegin then
		return
	end
	UIUtil.SetIsVisible(self.FCanvasPanel_26, false)
	self.Pos = Pos
	-- self.ID = ViewModel.BindableProperties.ID.Value
	self.ShrinkSp = ViewModel.BindableProperties.ShrinkSp.Value
	local DelayShowTime = ViewModel.BindableProperties.DelayShowTime.Value / 1000

    self:RegisterTimer(self.ArrivalShowTime, DelayShowTime, 0, 1, self)

	local DelayShrinkTime = ViewModel.BindableProperties.DelayShrinkTime.Value
	self:RegisterTimer(self.ArrivalShrinkTime, DelayShrinkTime + DelayShowTime, 0, 1, self)

	local function OnHideCallBack()
		GameInst:CheckIsFinishRoundAndSend()
		UIUtil.SetIsVisible(self.FCanvasPanel_26, false, false)
		self:UnRegisterAllTimer()
		FLOG_INFO("CuffAlwaysFail: Reason: Item Auto Hide Fail")
	end
	local DelayTime = GoldSaucerMiniGameDefine.DelayTime
	local HideTime = DelayTime.BlowAutoHide / self.ShrinkSp + DelayShowTime + DelayShrinkTime
	-- FLOG_INFO("HideTime = %s ShrinkSp = %s DelayShowTime = %s DelayShrinkTime = %s Color is Blue", HideTime, self.ShrinkSp, DelayShowTime, DelayShrinkTime)
	self.HideTimer = self:RegisterTimer(OnHideCallBack, HideTime , 0, 1)
end

function CuffBlowItemBase:OnBaseBtnClick(bRed)
    local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	UIUtil.SetIsVisible(self.Btn, false)
	if self.HideTimer ~= nil then
		self:UnRegisterAllTimer()
	end

	local PauseTime = self:PauseAnimation(self.AnimWork)
	self:PlayAnimation(self.AnimUnWork)
	-- self:PlayAnimation(self.AnimBurst)

	UIUtil.SetIsVisible(self.FCanvasPanel_26, true, false)

	local MiniGameInst = GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
	local Type = ViewModel.Type
	local HitResult = MiniGameInst:CheckHitResult(Type, PauseTime)
	local InteractResult = GoldSaucerMiniGameDefine.InteractResult
	FLOG_INFO("CuffAlwaysFail: HitResult: ItemType:%s, Rlt:%s, PauseTime:%s", Type, HitResult, PauseTime)
	if HitResult ~= InteractResult.Fail then
		self:PlayAnimation(self.AnimBurst)
	else
		FLOG_INFO("CuffAlwaysFail: Reason: Click Judge Fail")
	end
	MiniGameInst:PlayAudioByHitResult(HitResult, bRed)
	ViewModel:UpdateBlowResultVisible(true)
	
	local InteractionCfg = CuffInteractiveCfg:FindCfgByKey(Type)
	if InteractionCfg == nil then
		return
	end
	local bEndPush = ViewModel.Pos == CuffDefine.CenterBlowID
	if not bEndPush then
		MiniGameInst:AddStrengthValueAndCombos(InteractionCfg, HitResult) -- 增加力量值和连击
	else
		MiniGameInst:MultiplyStrengthValue(InteractionCfg, HitResult)
		MiniGameInst:EnterSlowAnimMode()
	end
	MiniGameInst:AddRewardNum(Type, HitResult)
	MiniGameInst:SetRewardGot()

	self:RegisterTimer(function() 
		ViewModel:UpdateBlowResultVisible(false)
		UIUtil.SetIsVisible(self.FCanvasPanel_26, false, false)
		MiniGameInst:CheckIsFinishRoundAndSend()
	end, MiniGameInst.BlowAnimTime)

	local ResultData = MiniGameInst:ConstructResultData(ViewModel.Pos, HitResult)
	self:UpdateResult(ResultData)
	local CuffVM = MiniGameInst:GetViewModel()
	CuffVM:UpdateData(not bEndPush) -- 刷新主界面数据

	local ComboNum = MiniGameInst:GetComboNum()
	self:PlayResultAnimByHitResult(HitResult, ComboNum)
end

return CuffBlowItemBase