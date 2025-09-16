---
--- Author: Administrator
--- DateTime: 2024-11-18 14:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeRewardType = ProtoRes.Game.ActivityNodeRewardType
local ItemUtil = require("Utils/ItemUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ProtoCS = require("Protocol/ProtoCS")
local ActivityRewardStatus = ProtoCS.Game.Activity.RewardStatus
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetColorAndOpacityHex  = require("Binder/UIBinderSetColorAndOpacityHex")
local DataReportUtil = require("Utils/DataReportUtil")
local OpsNewbieStrategyDefine = require("Game/Ops/OpsNewbieStrategy/OpsNewbieStrategyDefine")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local OPS_JUMP_TYPE = ProtoRes.Game.OPS_JUMP_TYPE
local JumpUtil = require("Utils/JumpUtil")
local ItemDefine = require("Game/Item/ItemDefine")

---@class OpsNewBieStrategyListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnStrategy UFButton
---@field CommBtn CommBtnSView
---@field CommSlot CommBackpack74SlotView
---@field Icon UFImage
---@field PanelText2 UFCanvasPanel
---@field Text1 URichTextBox
---@field Text2 URichTextBox
---@field TextQuantity1 UFTextBlock
---@field TextQuantity2 UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewBieStrategyListItemView = LuaClass(UIView, true)

function OpsNewBieStrategyListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnStrategy = nil
	--self.CommBtn = nil
	--self.CommSlot = nil
	--self.Icon = nil
	--self.PanelText2 = nil
	--self.Text1 = nil
	--self.Text2 = nil
	--self.TextQuantity1 = nil
	--self.TextQuantity2 = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewBieStrategyListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBtn)
	self:AddSubView(self.CommSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewBieStrategyListItemView:OnInit()
	self.Binders = 
	{
		{ "NodeTitle", UIBinderSetText.New(self, self.TextTitle)},
		{ "FirstNodeDesc", UIBinderSetText.New(self, self.Text1)},
		{ "SecondNodeDesc", UIBinderSetText.New(self, self.Text2)},
		{ "Quantity1NumText", UIBinderSetText.New(self, self.TextQuantity1)},
		{ "Quantity2NumText", UIBinderSetText.New(self, self.TextQuantity2)},
		{ "IsCompositeNode", UIBinderSetIsVisible.New(self, self.PanelText2) },
		{ "Rewards", UIBinderValueChangedCallback.New(self, nil, self.OnRewardsChanged) },
		{ "RewardStatus", UIBinderValueChangedCallback.New(self, nil, self.OnRewardStatusChanged) },
		{ "IsShowBtnStrategy", UIBinderSetIsVisible.New(self, self.BtnStrategy, false, true) },
		{ "Icon", UIBinderSetImageBrush.New(self, self.Icon)},
		{ "IconColor", UIBinderSetColorAndOpacityHex.New(self, self.Icon) },
		{ "IsFinished", UIBinderValueChangedCallback.New(self, nil, self.OnIsFinishedChanged) },

	}
	self.CommSlot:SetClickButtonCallback(self, self.OnRewardItemClicked)
end

function OpsNewBieStrategyListItemView:OnRewardsChanged(Rewards)
	---todo 后续确认下通用道具框的规范接入
	if Rewards == nil or #Rewards == 0 then
		UIUtil.SetIsVisible(self.CommSlot, false)
	else
		---隐藏无用UI
		self.CommSlot:SetRichTextLevelVisible(false)
		---和策划确认过非汇总节点，奖励只有一个
		---设置图标和数量
		local ItemType = Rewards[1].Type
		local ItemID = Rewards[1].ItemID
		local ItemNum = Rewards[1].Num
		local Icon
		---设置品质框
		local ItemQualityIcon = ItemUtil.GetSlotColorIcon(ItemID, ItemDefine.ItemSlotType.Item74Slot)
		if ItemQualityIcon then
			self.CommSlot:SetQualityImg(ItemQualityIcon)
		end

		if ItemType == ActivityNodeRewardType.ActivityNodeRewardTypeItem then
			--道具
			Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(ItemID))
		elseif ItemType == ActivityNodeRewardType.ActivityNodeRewardTypeScore then
			--货币
			Icon = ScoreMgr:GetScoreIconName(ItemID)
			ItemNum = _G.ScoreMgr.FormatScore(ItemNum)
		elseif ItemType == ActivityNodeRewardType.ActivityNodeRewardTypeLoot then
			--掉落(掉落配置有多个item,只显示第一个做容错处理，策划确认不会配置掉落)
			local RewardItemList = ItemUtil.GetLootItems(ItemID)	
			if RewardItemList and #RewardItemList > 0 then
				ItemID = RewardItemList[1].ResID
				if RewardItemList[1].IsScore then
					Icon = ScoreMgr:GetScoreIconName(ItemID)
				else
					Icon = ItemUtil.GetItemIcon(ItemID)
				end
				ItemNum = RewardItemList[1].Num
			end

		end
		if Icon and ItemNum then
			UIUtil.SetIsVisible(self.CommSlot, true)
			--UIUtil.SetIsVisible(self.CommSlot.RichTextLevel, false)
			--self.CommSlot:SetRichTextLevelVisible(false)
			self.CommSlot:SetNum(ItemNum)
			self.CommSlot:SetIconImg(Icon)
		else
			UIUtil.SetIsVisible(self.CommSlot, false)
		end
	end
end

function OpsNewBieStrategyListItemView:OnRewardStatusChanged(RewardStatus)
	--设置奖励item
	self.CommSlot:SetIsGet(false)
	self.CommSlot:SetRewardShow(false)
	self.CommSlot:SetIconChooseVisible(false)
	self.CommBtn:SetButtonTextOutlineEnable(true)
	self.CommBtn:SetButtonTextShadowEnable(true)
	--设置按钮
	if RewardStatus == ActivityRewardStatus.RewardStatusNo then
		local IsFinished = false
		---以太之光的特殊逻辑 进度
		local IsAdvancedEthericActivityNode = false
		local Params = self.Params
		if Params and Params.Data then
			local VM = Params.Data
			IsAdvancedEthericActivityNode = VM:GetIsAdvancedEthericActivityNode()
			IsFinished = VM:GetIsFinished()
		end

		if IsFinished then
			-- LSTR string:已完成
			--self.CommBtn:SetText(LSTR(920012))
			--self.CommBtn:SetButtonTextOutlinebEnable(false)
			-- LSTR string:已完成
			self.CommBtn:SetIsDoneState(true, LSTR(920012))
			self.CommBtn:SetButtonTextOutlineEnable(false)
			self.CommBtn:SetButtonTextShadowEnable(false)
		elseif IsAdvancedEthericActivityNode then
			-- LSTR string:进度
			self.CommBtn:SetText(LSTR(920024))
			self.CommBtn:SetIsNormalState(true)
		else
			---在这里判断是否有配置前往
			local IsJumpType =self:IsHaveJumpData()
			if IsJumpType then
				-- LSTR string:前往
				self.CommBtn:SetText(LSTR(920002))
				self.CommBtn:SetIsNormalState(true)
			else
				---未完成
				-- LSTR string:未完成
				self.CommBtn:SetIsDoneState(true, LSTR(920049))
				self.CommBtn:SetButtonTextOutlineEnable(false)
				self.CommBtn:SetButtonTextShadowEnable(false)
			end
		end

	elseif RewardStatus == ActivityRewardStatus.RewardStatusWaitGet then
		-- LSTR string:领取
		self.CommBtn:SetText(LSTR(920026))
		self.CommBtn:SetIsRecommendState(true)
		--设置奖励item / 按美术最新要求，有领取按钮的节点，不显示领奖动效
		--self.CommSlot:SetRewardShow(true)
	elseif RewardStatus == ActivityRewardStatus.RewardStatusDone then
		-- LSTR string:已领取
		self.CommBtn:SetIsDoneState(true, LSTR(920045))
		self.CommBtn:SetButtonTextOutlineEnable(false)
		self.CommBtn:SetButtonTextShadowEnable(false)
		--设置奖励item
		self.CommSlot:SetIsGet(true)
	end
end

function OpsNewBieStrategyListItemView:OnIsFinishedChanged(IsFinished)
	---无奖励item,按钮变化可能滞后，用IsFinished变化更新一次
	local Params = self.Params
	if Params == nil then
		return
	end
	local VM = Params.Data
	if VM == nil then
		return
	end
	local Rewards = VM:GetRewards()
	---无奖励item才更新
	if Rewards and #Rewards ~= 0 then
		local RewardStatus = VM:GetRewardStatus()
		if RewardStatus then
			self:OnRewardStatusChanged(RewardStatus)
		end
	end

end

---点击奖励item
function OpsNewBieStrategyListItemView:OnRewardItemClicked()
	local Params = self.Params
	if Params == nil then
		return
	end
	local VM = Params.Data
	if VM == nil then
		return
	end
	--local RewardStatus = VM:GetRewardStatus()
	--if RewardStatus ~= ActivityRewardStatus.RewardStatusDone then
		local Rewards = VM:GetRewards()
		if Rewards ~= nil and #Rewards > 0 then
			---设置图标和数量
			local ItemType = Rewards[1].ItemType
			local ItemID = Rewards[1].ItemID
			if ItemType == ActivityNodeRewardType.ActivityNodeRewardTypeLoot then
				--掉落
				local RewardItemList = ItemUtil.GetLootItems(ItemID)	
				if RewardItemList and #RewardItemList > 0 then
					ItemID = RewardItemList[1].ResID
				end
			end
			ItemTipsUtil.ShowTipsByResID(ItemID, self.CommSlot, {X = 0,Y = 0}, nil)
		end
	--end
end

function OpsNewBieStrategyListItemView:OnDestroy()

end

function OpsNewBieStrategyListItemView:OnShow()

end

function OpsNewBieStrategyListItemView:OnHide()

end

function OpsNewBieStrategyListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.CommBtn, self.OnBtnClicked)
	UIUtil.AddOnClickedEvent(self,  self.BtnStrategy, self.OnBtnStrategyClicked)
end

function OpsNewBieStrategyListItemView:OnRegisterGameEvent()

end

function OpsNewBieStrategyListItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local VM = Params.Data
	if VM == nil then
		return
	end
	self:RegisterBinders(VM, self.Binders)
end

function OpsNewBieStrategyListItemView:OnBtnClicked()
	local Params = self.Params
	if Params == nil then
		return
	end
	local VM = Params.Data
	if VM == nil then
		return
	end
	local RewardStatus = VM:GetRewardStatus()
	local NodeID = VM:GetNodeID()
	local NodeTitle = VM:GetNodeTitle()
	if RewardStatus == ActivityRewardStatus.RewardStatusNo then
		---未完成，跳转
		local IsAdvancedEthericActivityNode = false
		local IsJumpNode = false
		local Params = self.Params
		if Params and Params.Data then
			local VM = Params.Data
			IsAdvancedEthericActivityNode = VM:GetIsAdvancedEthericActivityNode()
		end
		local JumpData = VM:GetJumpData()
		if IsAdvancedEthericActivityNode then
			---以太之光的特殊逻辑 进度
			_G.OpsNewbieStrategyMgr:OpenEthericProgressPanel(NodeID, NodeTitle)
		else
			---跳转界面/跳转
			_G.OpsNewbieStrategyMgr:NodeJump(NodeID, JumpData)
		end
		if JumpData == nil then
			local ActivityID = VM:GetParentActivityID()
			local NodeID = VM:GetNodeID() 
			if ActivityID and NodeID then
				DataReportUtil.ReportActivityClickFlowData(ActivityID ,OpsNewbieStrategyDefine.OperationPageActionType.JumpToBtnCkicked, NodeID)
			end
		end
	elseif RewardStatus == ActivityRewardStatus.RewardStatusWaitGet then
		---未领奖，领奖
		_G.OpsNewbieStrategyMgr:GetRewardByNodeID(NodeID)
		--_G.OpsActivityMgr:SendActivityNodeGetReward(NodeID)
	elseif RewardStatus == ActivityRewardStatus.RewardStatusDone then
		---已领奖，不响应
	end
end

function OpsNewBieStrategyListItemView:OnBtnStrategyClicked()
	local Params = self.Params
	local VM
	local StrategyJumpData 
	if Params and Params.Data then
		VM = Params.Data
	else
		return false
	end
	if VM then
		StrategyJumpData = VM:GetStrategyJumpData()
	end
	if StrategyJumpData then
		--_G.OpsActivityMgr:Jump(StrategyJumpData[1], StrategyJumpData[2])
		JumpUtil.JumpTo(tonumber(StrategyJumpData[1]))
	end
end

function OpsNewBieStrategyListItemView:IsHaveJumpData()
	local Params = self.Params
	local VM
	local JumpData 
	if Params and Params.Data then
		VM = Params.Data
	else
		return false
	end
	if VM then
		JumpData = VM:GetJumpData()
	end
	if JumpData then
		return true
	else
		local NodeID = VM:GetNodeID() 
		local CfgData = ActivityNodeCfg:FindCfgByKey(NodeID)
		if CfgData and CfgData.JumpType and CfgData.JumpType ~= OPS_JUMP_TYPE.NONE_JUMP then
			return true
		end
		return false
	end
end

return OpsNewBieStrategyListItemView