---
--- Author: yutingzhan
--- DateTime: 2025-07-28 10:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ProtoCS = require("Protocol/ProtoCS")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local TimeUtil = require("Utils/TimeUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local OpsLoverFestivalMainVM = require("Game/Ops/VM/OpsLoverFestival/OpsLoverFestivalMainVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemCfg = require("TableCfg/ItemCfg")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

local SweetChocoItemID = 60110149
local BitterChocoItemID = 60110150

---@class OpsLoverFestivalMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityTime OpsActivityTimeItemView
---@field BtnGuide UFButton
---@field FProgressBar_61 UFProgressBar
---@field FinalReward CommBackpack126SlotView
---@field ImgLock UFImage
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field PanelTimeTips UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field Reward01 CommBackpack74SlotView
---@field Reward02 CommBackpack74SlotView
---@field RichTask URichTextBox
---@field RichTask_1 URichTextBox
---@field RichTask_2 URichTextBox
---@field State01 OpsLoverFestivalStateItemView
---@field State02 OpsLoverFestivalStateItemView
---@field State03 OpsLoverFestivalStateItemView
---@field TextBtnGuide UFTextBlock
---@field TextLimit UFTextBlock
---@field TextLimitTips UFTextBlock
---@field TextLimit_1 UFTextBlock
---@field TextLimit_2 UFTextBlock
---@field TextLoveValue UFTextBlock
---@field TextNumber UFTextBlock
---@field TextNumber_1 UFTextBlock
---@field TextNumber_2 UFTextBlock
---@field TextTimes UFTextBlock
---@field TextTimes_1 UFTextBlock
---@field TextTimes_2 UFTextBlock
---@field TextTipsTime UFTextBlock
---@field TextTitle UFTextBlock
---@field TextValue UFTextBlock
---@field Textnumber_3 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLoverFestivalMainView = LuaClass(UIView, true)

function OpsLoverFestivalMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityTime = nil
	--self.BtnGuide = nil
	--self.FProgressBar_61 = nil
	--self.FinalReward = nil
	--self.ImgLock = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.PanelTimeTips = nil
	--self.PanelTips = nil
	--self.Reward01 = nil
	--self.Reward02 = nil
	--self.RichTask = nil
	--self.RichTask_1 = nil
	--self.RichTask_2 = nil
	--self.State01 = nil
	--self.State02 = nil
	--self.State03 = nil
	--self.TextBtnGuide = nil
	--self.TextLimit = nil
	--self.TextLimitTips = nil
	--self.TextLimit_1 = nil
	--self.TextLimit_2 = nil
	--self.TextLoveValue = nil
	--self.TextNumber = nil
	--self.TextNumber_1 = nil
	--self.TextNumber_2 = nil
	--self.TextTimes = nil
	--self.TextTimes_1 = nil
	--self.TextTimes_2 = nil
	--self.TextTipsTime = nil
	--self.TextTitle = nil
	--self.TextValue = nil
	--self.Textnumber_3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLoverFestivalMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityTime)
	self:AddSubView(self.FinalReward)
	self:AddSubView(self.Reward01)
	self:AddSubView(self.Reward02)
	self:AddSubView(self.State01)
	self:AddSubView(self.State02)
	self:AddSubView(self.State03)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsLoverFestivalMainView:OnInit()
	self.TextBtnGuide:SetText(LSTR(100151))
	self.TextLoveValue:SetText(LSTR(100152))
	self.TextTimes:SetText(LSTR(100153))
	self.TextTimes_1:SetText(LSTR(100153))
	self.TextTimes_2:SetText(LSTR(100153))
	self.Reward01.Btn:SetIsAllowDoubleClick(false)
	self.Reward02.Btn:SetIsAllowDoubleClick(false)

	self.ViewModel = OpsLoverFestivalMainVM.New()
	self.Binders = {
        {"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TaskTitle1", UIBinderSetText.New(self, self.RichTask)},
		{"TaskNumText1", UIBinderSetText.New(self, self.TextNumber)},
		{"TaskLimit1", UIBinderSetText.New(self, self.TextLimit)},

		{"TaskTitle2", UIBinderSetText.New(self, self.RichTask_1)},
		{"TaskNumText2", UIBinderSetText.New(self, self.TextNumber_1)},
		{"TaskLimit2", UIBinderSetText.New(self, self.TextLimit_1)},

		{"TaskTitle3", UIBinderSetText.New(self, self.RichTask_2)},
		{"TaskNumText3", UIBinderSetText.New(self, self.TextNumber_2)},
		{"TaskLimit3", UIBinderSetText.New(self, self.TextLimit_2)},

		{"LoveValue", UIBinderSetText.New(self, self.TextValue)},
		{"WaitGetPanelVisible", UIBinderSetIsVisible.New(self, self.PanelTips)},
		{"WaitGetTips", UIBinderSetText.New(self, self.TextLimitTips)},
	}
end

function OpsLoverFestivalMainView:OnDestroy()

end

function OpsLoverFestivalMainView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	self.GuideActivityID = tonumber(self.Params.ActivityID) + 1
	self.ViewModel:Update(self.Params)
	self:UpdateProgressBar()
	self:SetPanelState()
end

function OpsLoverFestivalMainView:OnHide()

end

function OpsLoverFestivalMainView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGuide, self.OnClickBtnGuide)
	UIUtil.AddOnClickedEvent(self, self.FinalReward.Btn, self.OnClickFinalReward)
	UIUtil.AddOnClickedEvent(self, self.Reward01.Btn, self.OnClickReward)
	UIUtil.AddOnClickedEvent(self, self.Reward02.Btn, self.OnClickReward)
end

function OpsLoverFestivalMainView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.OnOpsActivityUpdate)
	self:RegisterGameEvent(_G.EventID.LootItemUpdateRes, self.OnLootItemUpdateRes)
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeChanged, self.OnOpsActivityUpdate)

end

function OpsLoverFestivalMainView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsLoverFestivalMainView:OnOpsActivityUpdate()
	if self.Params == nil then
		return
	end

	if self.Params.ActivityID == nil then
		return
	end

	local Activity = self.Params.Activity
    local Detail = OpsActivityMgr.ActivityNodeMap[self.Params.ActivityID] or {}
    self.Params:UpdateVM({Activity = Activity, Detail = Detail})

	self.ViewModel:Update(self.Params)
	self:UpdateProgressBar()
end

function OpsLoverFestivalMainView:OnClickBtnGuide()
	_G.UIViewMgr:ShowView(_G.UIViewID.OpsLoverFestivalGuideWinView, {NodeList = self.ViewModel.GetChocoTaskList, ActivityID = self.GuideActivityID})
end

function OpsLoverFestivalMainView:UpdateProgressBar()
	local NodeProgressList = self.ViewModel.NodeProgressList

	local function SetRewardUI(State, RewardIndex, RewardData)
		local RewardWidget = self.FinalReward
		local ItemQualityIcon = ItemUtil.GetSlotColorIcon(RewardData.ItemID, ItemDefine.ItemSlotType.Item126Slot)

		if State ~= nil then
			local RewardKey = "Reward" .. RewardIndex
			RewardWidget = State[RewardKey]
			ItemQualityIcon = ItemUtil.GetSlotColorIcon(RewardData.ItemID, ItemDefine.ItemSlotType.Item96Slot)
		end
		local IconPath = UIUtil.GetIconPath(ItemUtil.GetItemIcon(RewardData.ItemID))
		local CanPreview = ItemUtil.IsCanPreviewByResID(RewardData.ItemID)
		local Cfg = ItemCfg:FindCfgByKey(RewardData.ItemID)
		RewardWidget.RichTextQuantity:SetText(RewardData.Num)
		UIUtil.SetIsVisible(RewardWidget.RichTextQuantity, Cfg.MaxPile > 1 or RewardData.Num > 1)
		UIUtil.ImageSetBrushFromAssetPath(RewardWidget.Icon, IconPath)
		UIUtil.ImageSetBrushFromAssetPath(RewardWidget.ImgQuanlity, ItemQualityIcon)
		UIUtil.SetIsVisible(RewardWidget.BtnCheck, CanPreview, true)
	end

	local function SetRewardVisibility(State, IsAvailable, IsReceived)
		if State ~= nil then
			local RewardWidget1 = State.Reward1
			local RewardWidget2 = State.Reward2
			UIUtil.SetIsVisible(RewardWidget1.PanelAvailable, IsAvailable)
			UIUtil.SetIsVisible(RewardWidget1.IconReceived, IsReceived)
			UIUtil.SetIsVisible(RewardWidget2.PanelAvailable, IsAvailable)
			UIUtil.SetIsVisible(RewardWidget2.IconReceived, IsReceived)
		else
			local RewardWidget = self.FinalReward
			UIUtil.SetIsVisible(RewardWidget.PanelAvailable, IsAvailable)
			UIUtil.SetIsVisible(RewardWidget.IconReceived, IsReceived)
		end
	end

	local function SetImgVisibility(State, IsNormal, IsSelect)
		UIUtil.SetIsVisible(State.ImgNormal, IsNormal)
		UIUtil.SetIsVisible(State.ImgSelect, IsSelect)
	end

	for i = 1, 4 do
		local NodeData = NodeProgressList[i]
		local State = nil
		if NodeData ~= nil then
			if i == 4 then
				SetRewardUI(State, 1, NodeData.Rewards[1])
				self.Textnumber_3:SetText(NodeData.Target)
			else
				State = self["State0" .. i]
				State.TextNumber:SetText(NodeData.Target)
				SetRewardUI(State, 1, NodeData.Rewards[1])
				SetRewardUI(State, 2, NodeData.Rewards[2])
			end
			if NodeData.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
				if i == 4 then
					SetRewardVisibility(nil, true, false)
					SetImgVisibility(self, true, true)
					self.FinalReward:SetClickButtonCallback(self, self.FinalRewardItemClicked)
				else
					SetRewardVisibility(State, true, false)
					SetImgVisibility(State, true, true)
				end
			elseif NodeData.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
				if i == 4 then
					SetRewardVisibility(nil, false, true)
					SetImgVisibility(self, true, false)
				else
					SetRewardVisibility(State, false, true)
					SetImgVisibility(State, true, false)
				end
			else
				if i == 4 then
					SetRewardVisibility(nil, false, false)
					SetImgVisibility(self, false, false)
				else
					SetRewardVisibility(State, false, false)
					SetImgVisibility(State, false, false)
				end
			end
		end
	end
	if NodeProgressList[4] and NodeProgressList[4].RewardStartTime then
		local RewardStartTimeStamp = TimeUtil.GetTimeFromString(NodeProgressList[4].RewardStartTime)
		if RewardStartTimeStamp > TimeUtil.GetServerLogicTime() then
			UIUtil.SetIsVisible(self.PanelTimeTips, true)
			UIUtil.SetIsVisible(self.ImgLock, true)
			self.TextTipsTime:SetText(NodeProgressList[4].RewardStartTime)
		else
			UIUtil.SetIsVisible(self.PanelTimeTips, false)
			UIUtil.SetIsVisible(self.ImgLock, false)
		end
	end

	for i = 1, 3 do
	    self["State0" .. i].NodeData = self.ViewModel.NodeProgressList[i]
	end
	local LoveValue = self.ViewModel.LoveValue
	local PercentValues = {0.14, 0.42, 0.7, 1}
	for i = 4, 1, -1 do
		if NodeProgressList[i] then
			if NodeProgressList[i].Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet or NodeProgressList[i].Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
				if i == 4 then
					self.FProgressBar_61:SetPercent(1)
				else
					local SubPercentValue = (LoveValue - NodeProgressList[i].Target)/(NodeProgressList[i+1].Target - NodeProgressList[i].Target)
					local PercentValue = PercentValues[i] + SubPercentValue*(PercentValues[i+1] - PercentValues[i])
					self.FProgressBar_61:SetPercent(PercentValue)
				end
				break
			else
				if i == 1 then
					local PercentValue = (LoveValue)/(NodeProgressList[i].Target)*PercentValues[i]
					self.FProgressBar_61:SetPercent(PercentValue)
				end
			end
		end
	end
end

function OpsLoverFestivalMainView:SetPanelState()
	UIUtil.SetIsVisible(self.FinalReward.RichTextLevel, false)
	UIUtil.SetIsVisible(self.FinalReward.IconChoose, false)
	UIUtil.SetIsVisible(self.Reward01.RichTextLevel, false)
	UIUtil.SetIsVisible(self.Reward01.IconChoose, false)
	UIUtil.SetIsVisible(self.Reward02.RichTextLevel, false)
	UIUtil.SetIsVisible(self.Reward02.IconChoose, false)
	local IconPath1 = UIUtil.GetIconPath(ItemUtil.GetItemIcon(SweetChocoItemID))
	local ItemQualityIcon1 = ItemUtil.GetSlotColorIcon(SweetChocoItemID, ItemDefine.ItemSlotType.Item74Slot)
	UIUtil.ImageSetBrushFromAssetPath(self.Reward01.Icon, IconPath1)
	UIUtil.ImageSetBrushFromAssetPath(self.Reward01.ImgQuanlity, ItemQualityIcon1)

	local IconPath2 = UIUtil.GetIconPath(ItemUtil.GetItemIcon(BitterChocoItemID))
	local ItemQualityIcon2 = ItemUtil.GetSlotColorIcon(BitterChocoItemID, ItemDefine.ItemSlotType.Item74Slot)
	UIUtil.ImageSetBrushFromAssetPath(self.Reward02.Icon, IconPath2)
	UIUtil.ImageSetBrushFromAssetPath(self.Reward02.ImgQuanlity, ItemQualityIcon2)
	UIUtil.SetIsVisible(self.Reward01.PanelAvailable, true)
	UIUtil.SetIsVisible(self.Reward02.PanelAvailable, true)

	UIUtil.SetIsVisible(self.Reward01.RichTextQuantity, false)
	UIUtil.SetIsVisible(self.Reward02.RichTextQuantity, false)

end


function OpsLoverFestivalMainView:OnClickFinalReward()
	local FinalNode = self.ViewModel.NodeProgressList[4]
	if FinalNode ~= nil then
		if FinalNode.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
			OpsActivityMgr:SendActivityNodeGetReward(FinalNode.ActivityNodeID)
		else
			ItemTipsUtil.ShowTipsByResID(FinalNode.Rewards[1].ItemID, self.FinalReward, nil, nil, 30)
		end
	end
end

function OpsLoverFestivalMainView:OnClickReward()
	OpsActivityMgr:SendActivityGetReward(self.GuideActivityID)
end

function OpsLoverFestivalMainView:OnLootItemUpdateRes(InLootList, InReason)
	if not InLootList or not next(InLootList) then return end
	if not string.find(InReason, "Activity") then return end

	local TaskData = table.array_concat(self.ViewModel.GetChocoTaskList, self.ViewModel.NodeProgressList)
	local ItemList = {}
	for i, v in ipairs(TaskData) do
		if string.find(InReason, tostring(v.Head.NodeID)) then
			local LOOT_TYPE = ProtoCS.LOOT_TYPE
			for k, v in pairs(InLootList) do
				if v.Type == LOOT_TYPE.LOOT_TYPE_ITEM then 
					table.insert(ItemList, {ResID = v.Item.ResID, Num = v.Item.Value})
				elseif v.Type == LOOT_TYPE.LOOT_TYPE_SCORE then 
					table.insert(ItemList, {ResID = v.Score.ResID, Num = v.Score.Value})
				end
			end
			break
		end
	end

	if next(ItemList) then
		_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, {ItemList = ItemList})
	end
end

return OpsLoverFestivalMainView