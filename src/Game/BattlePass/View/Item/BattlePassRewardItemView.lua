---
--- Author: Administrator
--- DateTime: 2024-01-09 15:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local BattlePassDefine = require("Game/BattlePass/BattlePassDefine")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")


---@class BattlePassRewardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AdvanceReward1 BattlePassRewardSlotItemView
---@field AdvanceReward2 BattlePassRewardSlotItemView
---@field BaseReward BattlePassRewardSlotItemView
---@field ImgARBg UFImage
---@field ImgBRBg UFImage
---@field ImgLevelBg UFImage
---@field TextLevel UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassRewardItemView = LuaClass(UIView, true)

function BattlePassRewardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AdvanceReward1 = nil
	--self.AdvanceReward2 = nil
	--self.BaseReward = nil
	--self.ImgARBg = nil
	--self.ImgBRBg = nil
	--self.ImgLevelBg = nil
	--self.TextLevel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassRewardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AdvanceReward1)
	self:AddSubView(self.AdvanceReward2)
	self:AddSubView(self.BaseReward)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassRewardItemView:OnInit()
	self.Binders = {
		{ "LevelText", UIBinderSetText.New(self, self.TextLevel) },
		{ "CurLevelVisible", UIBinderSetIsVisible.New(self, self.ImgLevelBg) },
		{ "BaseRewardVisible", UIBinderSetIsVisible.New(self, self.BaseReward) },
		{ "AdvanceReward1Visible", UIBinderSetIsVisible.New(self, self.AdvanceReward1) },
		{ "AdvanceReward2Visible", UIBinderSetIsVisible.New(self, self.AdvanceReward2) },
		{ "GoodRewardItem", UIBinderValueChangedCallback.New(self, nil, self.RefreshReward)},
		{ "BetterRewardItem", UIBinderValueChangedCallback.New(self, nil, self.RefreshReward)},
		{ "BestRewardItem", UIBinderValueChangedCallback.New(self, nil, self.RefreshReward)},
	}

	self.Level = 0

end

function BattlePassRewardItemView:OnDestroy()
end

function BattlePassRewardItemView:OnShow()
	if self.Params == nil then
		return
	end

	if self.Params.Data == nil then
		return
	end

	local VM = self.Params.Data
	self.ViewModel = VM
	self.Level = VM.Level
	self:RefreshReward()

end

function BattlePassRewardItemView:OnHide()
end

function BattlePassRewardItemView:OnRegisterUIEvent()

	UIUtil.AddOnClickedEvent(self, self.BaseReward.BtnClick, self.OnClickedBtnBaseReward)
	UIUtil.AddOnClickedEvent(self, self.AdvanceReward1.BtnClick, self.OnClickedBtnAdvanceReward1)
	UIUtil.AddOnClickedEvent(self, self.AdvanceReward2.BtnClick, self.OnClickedBtnAdvanceReward2)

end

function BattlePassRewardItemView:OnRegisterGameEvent()
end

function BattlePassRewardItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self.Level = VM.Level
	self:RegisterBinders(self.ViewModel, self.Binders)

	self:RefreshReward()

end

function BattlePassRewardItemView:OnClickedBtnBaseReward()
	print("BattlePassRewardItemView:OnClickedBtnBaseReward")
	local VM = self.ViewModel
	if VM == nil then
		return
	end

	local Data = VM.GoodRewardItem

	if Data == nil then
		return
	end

	if Data.Available then
		_G.BattlePassMgr:SendBattlePassGetLevelReawrdReq(self.Level, BattlePassDefine.GradeType.Basic)
	else
		ItemTipsUtil.ShowTipsByResID(Data.ID, self.BaseReward)
	end


end

function BattlePassRewardItemView:OnClickedBtnAdvanceReward1()
	local VM = self.ViewModel
	if VM == nil then
		return
	end

	local Data = VM.BetterRewardItem

	if Data == nil then
		return
	end

	if Data.Available then
		_G.BattlePassMgr:SendBattlePassGetLevelReawrdReq(self.Level, BattlePassDefine.GradeType.Middle)
	else
		ItemTipsUtil.ShowTipsByResID(Data.ID, self.AdvanceReward1)
	end
end

function BattlePassRewardItemView:OnClickedBtnAdvanceReward2()
	local VM = self.ViewModel
	if VM == nil then
		return
	end

	local Data = VM.BestRewardItem

	if Data == nil then
		return
	end

	if Data.Available then
		_G.BattlePassMgr:SendBattlePassGetLevelReawrdReq(self.Level, BattlePassDefine.GradeType.Middle)
	else
		ItemTipsUtil.ShowTipsByResID(Data.ID, self.AdvanceReward2)
	end
end

function BattlePassRewardItemView:UpdateView()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Data = Params.Data
	if nil == Data then
		return
	end
	self.ViewModel = Data
	self.Level = Data.Level
	self.TextLevel:SetText(Data.LevelText)
	
	UIUtil.SetIsVisible(self.ImgLevelBg, Data.CurLevelVisible)

	UIUtil.SetIsVisible(self.BaseReward, Data.GoodRewardItem ~= nil and Data.GoodRewardItem.ID ~= 0)
	UIUtil.SetIsVisible(self.AdvanceReward1, Data.BetterRewardItem ~= nil and Data.BetterRewardItem.ID ~= 0)
	UIUtil.SetIsVisible(self.AdvanceReward2, Data.BestRewardItem ~= nil and Data.BestRewardItem.ID ~= 0)

	self.BaseReward:UpdateView(Data.GoodRewardItem)
	self.AdvanceReward1:UpdateView(Data.BetterRewardItem)
	self.AdvanceReward2:UpdateView(Data.BestRewardItem)
end

function BattlePassRewardItemView:RefreshReward()
	local VM = self.ViewModel 
	if VM == nil then
		return
	end

	UIUtil.SetIsVisible(self.BaseReward, VM.GoodRewardItem ~= nil and VM.GoodRewardItem.ID ~= 0)
	UIUtil.SetIsVisible(self.AdvanceReward1, VM.BetterRewardItem ~= nil and VM.BetterRewardItem.ID ~= 0)
	UIUtil.SetIsVisible(self.AdvanceReward2, VM.BestRewardItem ~= nil and VM.BestRewardItem.ID ~= 0)

	self.BaseReward:UpdateView(VM.GoodRewardItem)
	self.AdvanceReward1:UpdateView(VM.BetterRewardItem)
	self.AdvanceReward2:UpdateView(VM.BestRewardItem)


end

return BattlePassRewardItemView