---
--- Author: Administrator
--- DateTime: 2024-12-03 10:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeRewardType = ProtoRes.Game.ActivityNodeRewardType
local ItemUtil = require("Utils/ItemUtil")
local ActivityRewardStatus = ProtoCS.Game.Activity.RewardStatus
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local OpsNewbieStrategyDefine = require("Game/Ops/OpsNewbieStrategy/OpsNewbieStrategyDefine")
local ScoreMgr
local ItemDefine = require("Game/Item/ItemDefine")

---@class OpsNewBieStrategyRewardforCourageWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AwardTips1 OpsNewbieStrategyAwardTipsView
---@field AwardTips2 OpsNewbieStrategyAwardTipsView
---@field BtnCheck UFButton
---@field BtnClose UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommSlot CommBackpack96SlotView
---@field FButton_65 UFButton
---@field PopUpBG CommonPopUpBGView
---@field ProBar UFProgressBar
---@field RewardPhase1 OpsNewbieStrategyRewardPhaseItemView
---@field RewardPhase2 OpsNewbieStrategyRewardPhaseItemView
---@field RewardPhase3 OpsNewbieStrategyRewardPhaseItemView
---@field TextBird UFTextBlock
---@field TextHint URichTextBox
---@field TextQuantity2 UFTextBlock
---@field TextQuantity4 UFTextBlock
---@field TextQuantity6 UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---@field Texttotal UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProBar UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewBieStrategyRewardforCourageWinView = LuaClass(UIView, true)

function OpsNewBieStrategyRewardforCourageWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AwardTips1 = nil
	--self.AwardTips2 = nil
	--self.BtnCheck = nil
	--self.BtnClose = nil
	--self.CloseBtn = nil
	--self.CommSlot = nil
	--self.FButton_65 = nil
	--self.PopUpBG = nil
	--self.ProBar = nil
	--self.RewardPhase1 = nil
	--self.RewardPhase2 = nil
	--self.RewardPhase3 = nil
	--self.TextBird = nil
	--self.TextHint = nil
	--self.TextQuantity2 = nil
	--self.TextQuantity4 = nil
	--self.TextQuantity6 = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--self.Texttotal = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut = nil
	--self.AnimProBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewBieStrategyRewardforCourageWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AwardTips1)
	self:AddSubView(self.AwardTips2)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommSlot)
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.RewardPhase1)
	self:AddSubView(self.RewardPhase2)
	self:AddSubView(self.RewardPhase3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewBieStrategyRewardforCourageWinView:OnInit()
	ScoreMgr = _G.ScoreMgr

	self.BraveryAwardProBar = 0
	self.CurNum = nil
	self.MaxNum = nil
end

function OpsNewBieStrategyRewardforCourageWinView:OnDestroy()

end

function OpsNewBieStrategyRewardforCourageWinView:OnShow()
	-- LSTR string:粉色胖陆行鸟
	self.TextBird:SetText(LSTR(920034))
	-- LSTR string:咕……咕……快吃到了！
	self.TextTips:SetText(LSTR(920033))
	-- LSTR string:勇气嘉奖
	self.TextTitle:SetText(LSTR(920032))
	local Params = self.Params
	-- LSTR string:完成首选、推荐、进阶计划获取<img tex="Texture2D'/UI/Texture/Ops/OpsNewbieStrategy/UI_NewbieStrategy_Icon_Courage.UI_Army_Icon_SkillGrade_01.UI_Army_Icon_SkillGrade_01'" size="30;30" baseline="-8"></>勇气徽记，领取你的勇者嘉奖
	self.TextHint:SetText(LSTR(920004))
	if Params and Params.ActivityData then
		local ActivityData = Params.ActivityData
		self:SetUIData(ActivityData)
	end
end

function OpsNewBieStrategyRewardforCourageWinView:SetUIData(Data)
	local ActivityData = Data
	local Activity = {NodeList = ActivityData.Detail.NodeList }
	self.BraveryAwardProBar, self.CurNum, self.MaxNum = _G.OpsNewbieStrategyMgr:GetBraveryAwardProgress(Activity.NodeList)
	if self.BraveryAwardProBar then
		--self.ProBar:SetPercent(self.BraveryAwardProBar)
		UIUtil.PlayAnimationTimePointPct(self, self.AnimProBar, self.BraveryAwardProBar)
	end
	if self.CurNum and self.MaxNum then
		---数字不需要国际化
		local Text = string.format("(%s/%s)", self.CurNum, self.MaxNum)
		self.Texttotal:SetText(Text)
	end
	self.NodeSortlist = {}
	for _, NodeData in ipairs(ActivityData.Detail.NodeList) do

		if NodeData.Head then
			local NodeID = NodeData.Head.NodeID
			local Finished = NodeData.Head.Finished
			local Target = 0
			local CfgData = ActivityNodeCfg:FindCfgByKey(NodeID)
			if CfgData then
				if CfgData.Target then
					Target = CfgData.Target
				end
			end
			local Item = {NodeData = NodeData, Target = Target, Finished = Finished}
			table.insert(self.NodeSortlist, Item)
		end

	end
	table.sort(self.NodeSortlist, function(a, b) 
		return a.Target < b.Target
	end)
	for Index, Data in ipairs(self.NodeSortlist) do
		local NodeData = Data.NodeData
		local Finished = Data.Finished
		self:SetRewardIsShow(Index, NodeData, Finished)
		if Index == 1 then
			self.TextQuantity2:SetText(Data.Target)
		elseif Index == 2 then
			self.TextQuantity4:SetText(Data.Target)
		elseif Index == 3 then
			self.TextQuantity6:SetText(Data.Target)
		end
	end
end

function OpsNewBieStrategyRewardforCourageWinView:OnHide()
	self.BraveryAwardProBar = 0
	self.CurNum = nil
	self.MaxNum = nil
end

function OpsNewBieStrategyRewardforCourageWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnClickedCheck)
	UIUtil.AddOnClickedEvent(self, self.FButton_65, self.OnClickedCheck)
end

function OpsNewBieStrategyRewardforCourageWinView:OnClickedCheck()
	if self.CheckID then
		_G.PreviewMgr:OpenPreviewView(self.CheckID)
	end
end

function OpsNewBieStrategyRewardforCourageWinView:OnRegisterGameEvent()
	-- 活动中心领奖更新
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.OnOpsActivityGetRewardUpdate)
end

function OpsNewBieStrategyRewardforCourageWinView:OnRegisterBinder()

end

---GetRewardMsg = {
---    Detail = {
---        Head = {ActivityID, EmergencyShutDown, Effected, Hiden}
---        Nodes = repeated ActivityNode Nodes
---    }
---}
function OpsNewBieStrategyRewardforCourageWinView:OnOpsActivityGetRewardUpdate(GetRewardMsg)
	local Reward = GetRewardMsg.Reward
	local RewardActivityID = Reward.Detail.Head.ActivityID
	local ActivityList = _G.OpsActivityMgr:GetActivityListByClassify(OpsNewbieStrategyDefine.OpsNewbieStrategyMenuIndex)
	local RewardActivity = table.find_by_predicate(ActivityList, function(A)
		return A.Activity.ActivityID == RewardActivityID
	end)
	if RewardActivity == nil then
		return
	end
	self:SetUIData(RewardActivity)
end

function OpsNewBieStrategyRewardforCourageWinView:SetRewardIsShow(Index, Data, Finished)
	---todo 奖励数量蓝图摆死了，后续看看怎么改
	if Index == 1 then
		self:SetFirstRewardShow(Data, Finished)
	elseif Index == 2 then
		self:SetSecondRewardShow(Data, Finished)
	elseif Index == 3 then
		self:SetFinalRewardShow(Data, Finished)
	end
end

---设置第一级奖励
function OpsNewBieStrategyRewardforCourageWinView:SetFirstRewardShow(Data, Finished)
	if Data.Head == nil or Data.Head.NodeID == nil then
		return
	end
	local CfgData = ActivityNodeCfg:FindCfgByKey(Data.Head.NodeID)
	local RewardList = self:GetRewardList(CfgData)
	self.AwardTips1:SetData(RewardList)
	self.AwardTips1:SetNodeID(Data.Head.NodeID)
	local RewardStatus = Data.Head.RewardStatus
	self.AwardTips1:SetRewardStatus(RewardStatus)
	if Finished then
		UIUtil.SetIsVisible(self.RewardPhase1, true)
		local IsGet = RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone
		self.RewardPhase1:SetIsGet(IsGet)
	else
		UIUtil.SetIsVisible(self.RewardPhase1, false)
	end
end

---设置第二级奖励
function OpsNewBieStrategyRewardforCourageWinView:SetSecondRewardShow(Data, Finished)
	if Data.Head == nil or Data.Head.NodeID == nil then
		return
	end
	local CfgData = ActivityNodeCfg:FindCfgByKey(Data.Head.NodeID)
	local RewardList = self:GetRewardList(CfgData)
	self.AwardTips2:SetData(RewardList)
	self.AwardTips2:SetNodeID(Data.Head.NodeID)
	local RewardStatus = Data.Head.RewardStatus
	self.AwardTips2:SetRewardStatus(RewardStatus)
	if Finished then
		UIUtil.SetIsVisible(self.RewardPhase2, true)
		local IsGet = RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone
		self.RewardPhase2:SetIsGet(IsGet)
	else
		UIUtil.SetIsVisible(self.RewardPhase2, false)
	end
end

---设置第三级奖励
function OpsNewBieStrategyRewardforCourageWinView:SetFinalRewardShow(Data, Finished)
	if Data.Head == nil or Data.Head.NodeID == nil then
		return
	end
	local CfgData = ActivityNodeCfg:FindCfgByKey(Data.Head.NodeID)
	self.FinalRewardNodeID = Data.Head.NodeID
	local RewardList = self:GetRewardList(CfgData)
	---蓝图只摆了一个，后续新增要改蓝图
	if RewardList and #RewardList > 0 then
		local RewardItem = RewardList[1]
		self.FinalRewardItem = RewardItem
		---隐藏无用UI --todo后续整合一下无Vm设置奖励Item
		self.CommSlot:SetLevelVisible(false)
		self.CommSlot:SetIconChooseVisible(false)
		---设置图标和数量
		local ItemType = RewardItem.Type
		local ItemID = RewardItem.ItemID
		local ItemNum = RewardItem.Num
		local Icon
		---坐骑预览使用第三级奖励的第一个奖励id
		self.CheckID = ItemID
		local ItemQualityIcon = ItemUtil.GetSlotColorIcon(ItemID, ItemDefine.ItemSlotType.Item96Slot)
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
			self.CommSlot:SetNum(ItemNum)
			self.CommSlot:SetIconImg(Icon)
			self.CommSlot:SetClickButtonCallback(self, self.FinalRewardItemClicked)
		else
			UIUtil.SetIsVisible(self.CommSlot, false)
		end

	end
	local RewardStatus = Data.Head.RewardStatus
	self.FinalRewardRewardStatus = RewardStatus
	if Finished then
		UIUtil.SetIsVisible(self.RewardPhase3, true)
		local IsGet = RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone
		self.RewardPhase3:SetIsGet(IsGet)
		self.CommSlot:CommSetIsGet(IsGet)
		self.CommSlot:SetRewardShow(not IsGet)
	else
		UIUtil.SetIsVisible(self.RewardPhase3, false)
	end
end

function OpsNewBieStrategyRewardforCourageWinView:GetRewardList(CfgData)
	local RewardList = {}
	if CfgData then
		for _, Reward in ipairs(CfgData.Rewards) do
			if Reward.ItemID ~= 0 and Reward.ItemID ~= nil then
				table.insert(RewardList, {ItemID = Reward.ItemID, Type = Reward.Type, Num = Reward.Num, NodeID = CfgData.NodeID})
			end
		end
	end
	return RewardList
end

---todo 后续将Item点击逻辑整合到一起
function OpsNewBieStrategyRewardforCourageWinView:FinalRewardItemClicked()
	if self.FinalRewardRewardStatus ==  ActivityRewardStatus.RewardStatusWaitGet then
		local Params = self.Params
		if Params == nil then
			return
		end
		local NodeID = self.FinalRewardNodeID
		if NodeID then
			_G.OpsNewbieStrategyMgr:GetRewardByNodeID(NodeID)
		end
	else
		local ItemType = self.FinalRewardItem.Type
		local ItemID = self.FinalRewardItem.ItemID
		if ItemType == ActivityNodeRewardType.ActivityNodeRewardTypeLoot then
			--掉落
			local RewardItemList = ItemUtil.GetLootItems(ItemID)	
			if RewardItemList and #RewardItemList > 0 then
				ItemID = RewardItemList[1].ResID
			end
		end
		ItemTipsUtil.ShowTipsByResID(ItemID, self.CommSlot, {X = 0,Y = 0}, nil)
	end
end

return OpsNewBieStrategyRewardforCourageWinView