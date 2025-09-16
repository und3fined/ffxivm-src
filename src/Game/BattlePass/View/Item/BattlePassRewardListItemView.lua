---
--- Author: Administrator
--- DateTime: 2024-12-11 16:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local BattlePassDefine = require("Game/BattlePass/BattlePassDefine")

---@class BattlePassRewardListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EffectBGSelect UFCanvasPanel
---@field ImgNumBG UFImage
---@field ImgSelectList UFImage
---@field RewardSlot01 BattlePassRewardSlotView
---@field RewardSlot02 BattlePassRewardSlotView
---@field TextNum UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassRewardListItemView = LuaClass(UIView, true)

function BattlePassRewardListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EffectBGSelect = nil
	--self.ImgNumBG = nil
	--self.ImgSelectList = nil
	--self.RewardSlot01 = nil
	--self.RewardSlot02 = nil
	--self.TextNum = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassRewardListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RewardSlot01)
	self:AddSubView(self.RewardSlot02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassRewardListItemView:OnInit()

end

function BattlePassRewardListItemView:OnDestroy()

end

function BattlePassRewardListItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	if ViewModel.Lv == nil then
		return
	end

	_G.EventMgr:SendEvent(_G.EventID.BattlePassLevelRewardItemShow, ViewModel.Lv)
end

function BattlePassRewardListItemView:OnHide()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	if ViewModel.Lv == nil then
		return
	end

	_G.EventMgr:SendEvent(_G.EventID.BattlePassLevelRewardItemHide, ViewModel.Lv)
end

function BattlePassRewardListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.RewardSlot01.BtnClick, self.OnClickedBtnBaseReward)
	UIUtil.AddOnClickedEvent(self, self.RewardSlot02.BtnClick, self.OnClickedBtnAdvanceReward)
end

function BattlePassRewardListItemView:OnRegisterGameEvent()

end

function BattlePassRewardListItemView:OnRegisterBinder()

	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self.Binders = {
		{ "Lv", UIBinderSetText.New(self, self.TextNum)},
		{ "IsCurLv", UIBinderSetIsVisible.New(self, self.ImgSelectList)},
		{ "IsCurLv", UIBinderSetIsVisible.New(self, self.EffectBGSelect)},

	}

	self:RegisterBinders(ViewModel, self.Binders)
	self.RewardSlot01:SetParams({Data = ViewModel.BaseReward})
	self.RewardSlot02:SetParams({Data = ViewModel.AdvanceReward})
end

function BattlePassRewardListItemView:OnClickedBtnBaseReward()
	local VM = self.ViewModel
	if VM == nil then
		return
	end

	local Data = VM.BaseReward

	if Data == nil then
		return
	end

	if Data.Available then
		_G.BattlePassMgr:SendBattlePassGetLevelReawrdReq(self.Level, BattlePassDefine.GradeType.Basic)
	else
		ItemTipsUtil.ShowTipsByResID(Data.ID, self.BaseReward)
	end
end

function BattlePassRewardListItemView:OnClickedBtnAdvanceReward()
	local VM = self.ViewModel
	if VM == nil then
		return
	end

	local Data = VM.BaseReward

	if Data == nil then
		return
	end

	if Data.Available then
		_G.BattlePassMgr:SendBattlePassGetLevelReawrdReq(self.Level, BattlePassDefine.GradeType.Basic)
	else
		ItemTipsUtil.ShowTipsByResID(Data.ID, self.BaseReward)
	end
end

return BattlePassRewardListItemView