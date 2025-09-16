---
--- Author: Administrator
--- DateTime: 2024-12-11 16:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local JumpUtil = require("Utils/JumpUtil")

---@class BattlePassTaskNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn CommBtnSView
---@field Rewards CommBackpack96SlotView
---@field Rewards02 BattlePassRewardSlotView
---@field TextContent UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassTaskNewItemView = LuaClass(UIView, true)

function BattlePassTaskNewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Rewards = nil
	--self.Rewards02 = nil
	--self.TextContent = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassTaskNewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn)
	self:AddSubView(self.Rewards)
	self:AddSubView(self.Rewards02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassTaskNewItemView:OnInit()
	self.Binders = {
		{ "TaskName", UIBinderSetText.New(self, self.TextContent)},
		{ "BtnText", UIBinderSetText.New(self, self.Btn)},
		{ "BtnState", UIBinderValueChangedCallback.New(self, nil, self.OnBtnTaskStateChanged)},
	}

end

function BattlePassTaskNewItemView:OnDestroy()

end

function BattlePassTaskNewItemView:OnShow()
	-- self.Btn:SetButtonTextOutlineEnable(false)
end

function BattlePassTaskNewItemView:OnHide()

end

function BattlePassTaskNewItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickedBtn)
end

function BattlePassTaskNewItemView:OnRegisterGameEvent()
end

function BattlePassTaskNewItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.Rewards02:SetParams({Data = self.ViewModel.Reward})
end

function BattlePassTaskNewItemView:OnClickedBtn()
	if self.ViewModel == nil then
		return
	end

	local ID = self.ViewModel.NodeID
	if ID == nil then
		return
	end

	local State = self.ViewModel.BtnState
	if State == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		_G.BattlePassMgr:SendBattlePassGetTaskRewardReq(ID)
	elseif State == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(self.ViewModel.NodeID)
		if NodeCfg ~= nil then
			local NodeUnlockType = NodeCfg.NodeUnlockType
			local JumpType = NodeCfg.JumpType
			if JumpType == nil or JumpType == 0 then
				if not (NodeUnlockType == nil or NodeUnlockType == 0) and not (_G.ModuleOpenMgr:CheckOpenState(NodeCfg.NodeUnlockArg)) then
					if _G.ModuleOpenMgr:CheckIDType(NodeCfg.NodeUnlockArg) ~= ProtoCommon.ModuleType.ModuleTypeScene and  _G.ModuleOpenMgr:CheckIDType(NodeCfg.NodeUnlockArg) ~= ProtoCommon.ModuleType.ModuleTypeProf then
						MsgTipsUtil.ShowTips(_G.LSTR(850106)) -- 任务未开放
					else
						MsgTipsUtil.ShowTips(_G.LSTR(850107)) -- 副本未开放
					end
				end
			else
				if NodeUnlockType == nil or NodeUnlockType == 0 then
					JumpUtil.JumpTo(tonumber(NodeCfg.JumpParam), true)
				else
					if not (_G.ModuleOpenMgr:CheckOpenState(NodeCfg.NodeUnlockArg)) then
						if _G.ModuleOpenMgr:CheckIDType(NodeCfg.NodeUnlockArg) ~= ProtoCommon.ModuleType.ModuleTypeScene and _G.ModuleOpenMgr:CheckIDType(NodeCfg.NodeUnlockArg) ~= ProtoCommon.ModuleType.ModuleTypeProf then
							MsgTipsUtil.ShowTips(_G.LSTR(850106)) -- 任务未开放
						else
							MsgTipsUtil.ShowTips(_G.LSTR(850107)) -- 副本未开放
						end
					end
				end
			end
		end
	end
end

function BattlePassTaskNewItemView:OnBtnTaskStateChanged()
	local Params = self.Params
	if nil == Params then return end
	local VM = Params.Data
	if nil == VM then return end
	local State = VM.BtnState
	-- self.Btn:SetButtonTextOutlineEnable(true)
	if State == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		self.ViewModel.BtnText = _G.LSTR(850008)  -- 领取
		self.Btn:SetIsRecommendState(true)
	elseif State == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		self.ViewModel.BtnText = _G.LSTR(850049) -- 已领取
		-- self.Btn:SetButtonTextOutlineEnable(false)
		self.Btn:SetIsDoneState(true, _G.LSTR(850049))
	elseif State == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(self.ViewModel.NodeID)
		if NodeCfg ~= nil then
			local NodeUnlockType = NodeCfg.NodeUnlockType
			local JumpType = NodeCfg.JumpType
			if JumpType == nil or JumpType == 0 then
				if NodeUnlockType == nil or NodeUnlockType == 0 then
					-- self.Btn:SetButtonTextOutlineEnable(false)
					self.Btn:SetIsDoneState(true,  _G.LSTR(850050)) 
					self.ViewModel.BtnText = _G.LSTR(850050) -- 进行中
				else
					if _G.ModuleOpenMgr:CheckOpenState(NodeCfg.NodeUnlockArg) then
						self.ViewModel.BtnText = _G.LSTR(850051)  --未达成
						self.Btn:SetIsNormalState(true)
					else
						self.ViewModel.BtnText = _G.LSTR(850052)  -- 未解锁
						self.Btn:SetIsDisabledState(true, true)
					end
				end
			else
				if NodeUnlockType == nil or NodeUnlockType == 0 then
					self.ViewModel.BtnText = _G.LSTR(850009)  -- 前往
					self.Btn:SetIsNormalState(true) 
				else
					if _G.ModuleOpenMgr:CheckOpenState(NodeCfg.NodeUnlockArg) then
						self.ViewModel.BtnText = _G.LSTR(850009)
						self.Btn:SetIsNormalState(true)
					else
						self.ViewModel.BtnText = _G.LSTR(850052)  -- 未解锁
						self.Btn:SetIsDisabledState(true, true)
					end
				end
			end
		end
	end
end

return BattlePassTaskNewItemView