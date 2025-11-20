---
--- Author: Administrator
--- DateTime: 2025-07-21 14:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local JumpUtil = require("Utils/JumpUtil")
local OpsReturnMgr = require("Game/Ops/OpsReturn/OpsReturnMgr")

---@class OpsReturnTaskList2ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnList1 CommBtnSView
---@field BtnList2 CommBtnSView
---@field BtnSlot CommBtnSView
---@field TableViewSlot UTableView
---@field TextList1 URichTextBox
---@field TextList2 URichTextBox
---@field TextQuantity1 UFTextBlock
---@field TextQuantity2 UFTextBlock
---@field TextTag UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsReturnTaskList2ItemView = LuaClass(UIView, true)

function OpsReturnTaskList2ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnList1 = nil
	--self.BtnList2 = nil
	--self.BtnSlot = nil
	--self.TableViewSlot = nil
	--self.TextList1 = nil
	--self.TextList2 = nil
	--self.TextQuantity1 = nil
	--self.TextQuantity2 = nil
	--self.TextTag = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsReturnTaskList2ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnList1)
	self:AddSubView(self.BtnList2)
	self:AddSubView(self.BtnSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsReturnTaskList2ItemView:OnInit()
	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.Binders = {
		{"TaskTitle", UIBinderSetText.New(self, self.TextList1)},
		{"TaskSecTitle", UIBinderSetText.New(self, self.TextList2)},
		{"TaskProgress", UIBinderSetText.New(self, self.TextQuantity1)},
		{"TaskSecProgress", UIBinderSetText.New(self, self.TextQuantity2)},
		{"TaskVisible", UIBinderSetIsVisible.New(self, self.BtnList1)},
		{"TaskSecVisible", UIBinderSetIsVisible.New(self, self.BtnList2)},
		{"GetRewardVisible", UIBinderSetIsVisible.New(self, self.BtnSlot)},
		{"RewardList", UIBinderUpdateBindableList.New(self, self.RewardListAdapter)},
		{"BtnText", UIBinderSetText.New(self, self.BtnList1)},
		{"BtnSecText", UIBinderSetText.New(self, self.BtnList2)},
		{"AwardBtnText", UIBinderSetText.New(self, self.BtnSlot)},
		{"AwardBtnState", UIBinderValueChangedCallback.New(self, nil, self.OnBtnTaskAwardStateChanged)},
		{"Task1State", UIBinderValueChangedCallback.New(self, nil, self.OnTask1StateChanged)},
		{"Task2State", UIBinderValueChangedCallback.New(self, nil, self.OnTask2StateChanged)},
	}

end

function OpsReturnTaskList2ItemView:OnDestroy()

end

function OpsReturnTaskList2ItemView:OnShow()
	self.TextTag:SetText("且")
end

function OpsReturnTaskList2ItemView:OnHide()

end

function OpsReturnTaskList2ItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnList1, self.OnClickedTask1Btn)
	UIUtil.AddOnClickedEvent(self, self.BtnList2, self.OnClickedTask2Btn)
	UIUtil.AddOnClickedEvent(self, self.BtnSlot, self.OnClickedGetRewardBtn)
end

function OpsReturnTaskList2ItemView:OnRegisterGameEvent()
end

function OpsReturnTaskList2ItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

-- todo 前往任务，进行中，
function OpsReturnTaskList2ItemView:OnClickedTask1Btn()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:HandleTaskBtn(ViewModel.Task1State, ViewModel.Task1NodeID)
end

function OpsReturnTaskList2ItemView:OnClickedTask2Btn()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:HandleTaskBtn(ViewModel.Task2State, ViewModel.Task2NodeID)
end

-- todo 领奖按钮
function OpsReturnTaskList2ItemView:OnClickedGetRewardBtn()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	if ViewModel.NodeID and ViewModel.NodeID ~= 0 then
		OpsReturnMgr:SendGetTaskRewardReq(ViewModel.NodeID)
	end
end

-- 第一个子任务状态
function OpsReturnTaskList2ItemView:OnTask1StateChanged()
	local Params = self.Params
	if nil == Params then return end
	local VM = Params.Data
	if nil == VM then return end
	local State = VM.Task1State
	if State == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet or State == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		self.TaskVisible = false
	else
		self.TaskVisible = true
	end

	if not (State == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet or State == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone) then
		self:ShowTaskText(VM.Task1NodeID, self.BtnList1, VM.BtnText)
	end
end

-- 第二个子任务状态
function OpsReturnTaskList2ItemView:OnTask2StateChanged()
	local Params = self.Params
	if nil == Params then return end
	local VM = Params.Data
	if nil == VM then return end
	local State = VM.Task2State
	if State == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet or State == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		self.TaskVisible = false
	else
		self.TaskVisible = true
	end

	if not (State == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet or State == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone) then
		self:ShowTaskText(VM.Task2NodeID, self.BtnList2, VM.BtnSecText)
	end
end

-- 当前整个任务状态
function OpsReturnTaskList2ItemView:OnBtnTaskAwardStateChanged()
	local Params = self.Params
	if nil == Params then return end
	local VM = Params.Data
	if nil == VM then return end
	local State = VM.AwardBtnState
	if State == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		self.ViewModel.AwardBtnText = _G.LSTR(850008)  -- 领取
		self.BtnSlot:SetIsRecommendState(true)
	elseif State == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		self.ViewModel.AwardBtnText = _G.LSTR(850049) -- 已领取
		self.BtnSlot:SetIsDoneState(true, _G.LSTR(850049))
	end

	if State == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet or State == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		self.GetRewardVisible = true
	else
		self.GetRewardVisible = false
	end

end

function OpsReturnTaskList2ItemView:HandleTaskBtn(State, NodeID)
	if State == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
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

function OpsReturnTaskList2ItemView:ShowTaskText(TaskNodeID, Btn, TextVM)
	if Btn == nil or TextVM == nil then
		return
	end

	local NodeCfg = ActivityNodeCfg:FindCfgByKey(TaskNodeID)
	if NodeCfg ~= nil then
		local NodeUnlockType = NodeCfg.NodeUnlockType
		local JumpType = NodeCfg.JumpType
		if JumpType == nil or JumpType == 0 then
			if NodeUnlockType == nil or NodeUnlockType == 0 then
				Btn:SetIsDoneState(true,  _G.LSTR(850050)) 
				TextVM = _G.LSTR(850050) -- 进行中
			else
				if _G.ModuleOpenMgr:CheckOpenState(NodeCfg.NodeUnlockArg) then
					TextVM = _G.LSTR(850051)  --未达成
					Btn:SetIsNormalState(true)
				else
					TextVM = _G.LSTR(850052)  -- 未解锁
					Btn:SetIsDisabledState(true, true)
				end
			end
		else
			if NodeUnlockType == nil or NodeUnlockType == 0 then
				self.ViewModel.BtnText = _G.LSTR(850009)  -- 前往
				Btn:SetIsNormalState(true) 
			else
				if _G.ModuleOpenMgr:CheckOpenState(NodeCfg.NodeUnlockArg) then
					TextVM = _G.LSTR(850009)
					Btn:SetIsNormalState(true)
				else
					TextVM = _G.LSTR(850052)  -- 未解锁
					Btn:SetIsDisabledState(true, true)
				end
			end
		end
	end
end


return OpsReturnTaskList2ItemView