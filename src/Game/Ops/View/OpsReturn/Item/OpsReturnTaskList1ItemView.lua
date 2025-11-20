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
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local JumpUtil = require("Utils/JumpUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class OpsReturnTaskList1ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot CommBtnSView
---@field PanelList UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TableViewSlot UTableView
---@field TextList URichTextBox
---@field TextQuantity UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsReturnTaskList1ItemView = LuaClass(UIView, true)

function OpsReturnTaskList1ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSlot = nil
	--self.PanelList = nil
	--self.RedDot = nil
	--self.TableViewSlot = nil
	--self.TextList = nil
	--self.TextQuantity = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsReturnTaskList1ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnSlot)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsReturnTaskList1ItemView:OnInit()
	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnClickedRewardItem, true)
	self.Binders = {
		{"TaskTitle", UIBinderSetText.New(self, self.TextList)},
		{"TaskProgress", UIBinderSetText.New(self, self.TextQuantity)},
		{"TaskProgress", UIBinderSetText.New(self, self.TextQuantity)},
		{"RewardList", UIBinderUpdateBindableList.New(self, self.RewardListAdapter)},
		{"AwardBtnText", UIBinderSetText.New(self, self.BtnSlot)},
		{"AwardBtnState", UIBinderValueChangedCallback.New(self, nil, self.OnBtnTaskStateChanged)},
		{"NodeID", UIBinderValueChangedCallback.New(self, nil, self.OnBtnTaskStateChanged)},
		{ "IsRed",  UIBinderValueChangedCallback.New(self, nil, self.OnIsRedchanged)},
		{ "IsRed",  UIBinderSetIsVisible.New(self, self.RedDot)},
	}

end

function OpsReturnTaskList1ItemView:OnDestroy()

end

function OpsReturnTaskList1ItemView:OnShow()
	-- local ViewModel = self.Params.Data

	-- if nil == ViewModel then
	-- 	return
	-- end
	-- if ViewModel.NodeID ~= nil then
	-- 	local Cfg = ActivityNodeCfg:FindCfgByKey(ViewModel.NodeID)
	-- 	if Cfg ~= nil and Cfg.NodeSort ~= nil  then
	-- 		local StageIndex = Cfg.NodeSort
	-- 		local RedDotID = _G.OpsReturnMgr:GetStageTaskRedDotID(StageIndex)
	-- 		if RedDotID ~= nil then
	-- 			self.RedDot:SetRedDotIDByID(RedDotID)
	-- 		end
	-- 	end
	-- end
end

function OpsReturnTaskList1ItemView:OnHide()

end

function OpsReturnTaskList1ItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSlot, self.OnClickedBtnSlot)
end

function OpsReturnTaskList1ItemView:OnRegisterGameEvent()

end

function OpsReturnTaskList1ItemView:OnRegisterBinder()
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

--Todo 解锁进行中，前往，领取奖励
function OpsReturnTaskList1ItemView:OnClickedBtnSlot()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local State = ViewModel.AwardBtnState
	if State == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		_G.OpsReturnMgr:SetCurStageTaskNodeID(ViewModel.NodeID)
		_G.OpsReturnMgr:SendGetTaskRewardReq(ViewModel.NodeID)
	elseif State == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(ViewModel.NodeID)
		if NodeCfg ~= nil then
			local JumpType = NodeCfg.JumpType
			if JumpType ~= nil and JumpType ~= 0 then
				JumpUtil.JumpTo(tonumber(NodeCfg.JumpParam), true)
			end
		end
	end
end


function OpsReturnTaskList1ItemView:OnIsRedchanged()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	if ViewModel.NodeID ~= nil then
		local Cfg = ActivityNodeCfg:FindCfgByKey(ViewModel.NodeID)
		if Cfg ~= nil and Cfg.NodeSort ~= nil  then
			local StageIndex = Cfg.NodeSort
			local RedDotID = _G.OpsReturnMgr:GetStageTaskRedDotID(StageIndex)
			if RedDotID ~= nil then
				self.RedDot:SetRedDotIDByID(RedDotID)
			end
		end
	end
end

function OpsReturnTaskList1ItemView:OnBtnTaskStateChanged()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end
	local State = ViewModel.AwardBtnState

	if State == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		ViewModel.AwardBtnText = _G.LSTR(850008)  -- 领取
		self.BtnSlot:SetIsRecommendState(true)
	elseif State == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		ViewModel.AwardBtnText = _G.LSTR(850049) -- 已领取
		self.BtnSlot:SetIsDoneState(true, _G.LSTR(850049))
	elseif State == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(ViewModel.NodeID)
		if NodeCfg ~= nil then
			local JumpType = NodeCfg.JumpType
			if JumpType == nil or JumpType == 0 then
				self.BtnSlot:SetIsDoneState(true,  _G.LSTR(850050)) 
				ViewModel.AwardBtnText = _G.LSTR(850050) -- 进行中
			else
				ViewModel.AwardBtnText = _G.LSTR(850009) -- 前往
				self.BtnSlot:SetIsNormalState(true)
			end
		end
	end
end


function OpsReturnTaskList1ItemView:OnClickedRewardItem(Index, ItemData, ItemView)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	
	if ItemData and ItemData.ResID then
		ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
	end
end


return OpsReturnTaskList1ItemView