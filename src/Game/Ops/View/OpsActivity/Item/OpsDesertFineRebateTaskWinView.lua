---
--- Author: Administrator
--- DateTime: 2025-01-03 14:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local OpsDesertFineRebateTaskVM = require("Game/Ops/VM/OpsDesertFineRebateTaskVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoCS = require("Protocol/ProtoCS")
local SaveKey = require("Define/SaveKey")
local EventID
---@class OpsDesertFineRebateTaskWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field Comm96Slot1 CommBackpack96SlotView
---@field Comm96Slot2 CommBackpack96SlotView
---@field FProgressBar_70 UFProgressBar
---@field ImgNodeFocus1 UFImage
---@field ImgNodeFocus2 UFImage
---@field PanelSlot1 UFCanvasPanel
---@field PanelSlot2 UFCanvasPanel
---@field TableView_35 UTableView
---@field TextTaskHint UFTextBlock
---@field AnimProBar UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsDesertFineRebateTaskWinView = LuaClass(UIView, true)

function OpsDesertFineRebateTaskWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameL_UIBP = nil
	--self.Comm96Slot1 = nil
	--self.Comm96Slot2 = nil
	--self.FProgressBar_70 = nil
	--self.ImgNodeFocus1 = nil
	--self.ImgNodeFocus2 = nil
	--self.PanelSlot1 = nil
	--self.PanelSlot2 = nil
	--self.TableView_35 = nil
	--self.TextTaskHint = nil
	--self.AnimProBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsDesertFineRebateTaskWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameL_UIBP)
	self:AddSubView(self.Comm96Slot1)
	self:AddSubView(self.Comm96Slot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsDesertFineRebateTaskWinView:OnInit()
	EventID = _G.EventID
	self.ViewModel = OpsDesertFineRebateTaskVM.New()
	self.TaskTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_35)

	self.Binders = {
       	{"TaskProgressText", UIBinderSetText.New(self, self.TextTaskHint)},
		{"TaskProgressPercent", UIBinderSetPercent.New(self, self.FProgressBar_70)},
		{"Finish1Visible", UIBinderSetIsVisible.New(self, self.ImgNodeFocus1)},
		{"Finish2Visible", UIBinderSetIsVisible.New(self, self.ImgNodeFocus2)},
		
		{"TaskVMList", UIBinderUpdateBindableList.New(self, self.TaskTableViewAdapter)},
    }
end

function OpsDesertFineRebateTaskWinView:OnDestroy()

end

function OpsDesertFineRebateTaskWinView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end

	self.ViewModel:Update(self.Params)

	local Percent = self.FProgressBar_70.Percent
	local OpsDesertFireTaskRate = _G.UE.USaveMgr.GetFloat(SaveKey.OpsDesertFireTaskRate, 0, true) or 0
	if OpsDesertFireTaskRate <  Percent then
		if Percent > 0 then
			self:PlayAnimProBar(OpsDesertFireTaskRate, Percent)
		else
			self:PlayAnimationTimeRange(self.AnimProBar, 0, 0.01,1,nil, 1.0, false)
		end

		_G.UE.USaveMgr.SetFloat(SaveKey.OpsDesertFireTaskRate, Percent, true)
	else
		UIUtil.PlayAnimationTimePoint(self, self.AnimProBar, self.FProgressBar_70.Percent, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, false)
	end

end

function OpsDesertFineRebateTaskWinView:OnHide()

end

function OpsDesertFineRebateTaskWinView:OnRegisterUIEvent()
	self.Comm96Slot1:SetClickButtonCallback(self, self.OnGetReward1Clicked)
	self.Comm96Slot2:SetClickButtonCallback(self, self.OnGetReward2Clicked)
end

function OpsDesertFineRebateTaskWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.UpdateNodeGetReward)
end

function OpsDesertFineRebateTaskWinView:UpdateNodeGetReward()
	self.ViewModel:Update(self.Params)
	local RewardNode1 = self.ViewModel.AccumulativeFinishNode1
	local RewardNode2 = self.ViewModel.AccumulativeFinishNode2
	if RewardNode2 then
		if RewardNode2.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
			local NodeID  = RewardNode2.Head.NodeID
            local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
			if ActivityNode then
				local Rewards = ActivityNode.Rewards
				local Params = {}
				Params.ItemList = {}
				if Rewards then
					for i = 1, #Rewards do
						if Rewards[i].ItemID > 0 and Rewards[i].Num > 0  then
							table.insert(Params.ItemList, { ResID = Rewards[i].ItemID, Num = Rewards[i].Num})
						end
					end
				end
			   
				if #Params.ItemList > 0 then
					_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, Params)
		
				end
			end
			return
		end
	end

	if RewardNode1 then
		if RewardNode1.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
			local NodeID  = RewardNode1.Head.NodeID
            local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
			if ActivityNode then
				local Rewards = ActivityNode.Rewards
				local Params = {}
				Params.ItemList = {}
				if Rewards then
					for i = 1, #Rewards do
						if Rewards[i].ItemID > 0 and Rewards[i].Num > 0  then
							table.insert(Params.ItemList, { ResID = Rewards[i].ItemID, Num = Rewards[i].Num})
						end
					end
				end
			   
				if #Params.ItemList > 0 then
					_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, Params)
		
				end
			end
			return
		end
	end

	
end

function OpsDesertFineRebateTaskWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.Comm96Slot1:SetParams({Data = self.ViewModel.ItemVM1})
	self.Comm96Slot2:SetParams({Data = self.ViewModel.ItemVM2})
	self.Comm2FrameL_UIBP:SetTitleText(_G.LSTR(1470011))
end

function OpsDesertFineRebateTaskWinView:OnGetReward1Clicked()
	local ProtoCS = require("Protocol/ProtoCS")
	local ItemTipsUtil = require("Utils/ItemTipsUtil")
	if self.ViewModel == nil or self.ViewModel.AccumulativeFinishNode1 == nil then
		return 
	end
	local Node = self.ViewModel.AccumulativeFinishNode1
	local NodeID  = Node.Head.NodeID
    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    if ActivityNode then
		if Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
			_G.OpsActivityMgr:SendActivityNodeGetReward(NodeID)
		else
			ItemTipsUtil.ShowTipsByResID(ActivityNode.Rewards[1].ItemID, self.Comm96Slot1, nil, nil, 30)
		end
	end
end

function OpsDesertFineRebateTaskWinView:OnGetReward2Clicked()
	local ProtoCS = require("Protocol/ProtoCS")
	local ItemTipsUtil = require("Utils/ItemTipsUtil")
	if self.ViewModel == nil or self.ViewModel.AccumulativeFinishNode2 == nil then
		return 
	end
	local Node = self.ViewModel.AccumulativeFinishNode2
	local NodeID  = Node.Head.NodeID
    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    if ActivityNode then
		if Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
			_G.OpsActivityMgr:SendActivityNodeGetReward(NodeID)
		else
			ItemTipsUtil.ShowTipsByResID(ActivityNode.Rewards[1].ItemID, self.Comm96Slot2, nil, nil, 30)
		end
	end
end

return OpsDesertFineRebateTaskWinView