---
--- Author: Administrator
--- DateTime: 2025-07-30 16:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local JumpUtil = require("Utils/JumpUtil")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local StoreCfg = require("TableCfg/StoreCfg")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoCS = require("Protocol/ProtoCS")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local OpsActivityWhaleMonutVM = require("Game/Ops/VM/OpsActivityWhaleMonutVM")
local UIBindableList = require("UI/UIBindableList")
local OpsLimitedTimeSlotItemVM = require("Game/Ops/VM/OpsLimitedTimeSlotItemVM")

local LSTR = _G.LSTR
local UIViewMgr = _G.UIViewMgr
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local JumpStateCheckNodeID = 2507020204

---@class OpsFF7MainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy OpsCommBtnLView
---@field BtnCheck UFButton
---@field BtnGet CommBtnLView
---@field CommMoney CommMoneySlotView
---@field ImgBGDeco1 UFImage
---@field ImgBGDeco2 UFImage
---@field ImgBGDeco3 UFImage
---@field OpsActivityTime OpsActivityTimeItemView
---@field PanelBGDeco3 UFCanvasPanel
---@field PanelBtn UFCanvasPanel
---@field PanelGift UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field PanelTitle UFCanvasPanel
---@field ShareTips OpsActivityShareTipsItemView
---@field TableViewList UTableView
---@field TableView_64 UTableView
---@field TextCheck UFTextBlock
---@field TextGift UFTextBlock
---@field TextListTitle UFTextBlock
---@field TextSubTItle UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsFF7MainPanelView = LuaClass(UIView, true)

function OpsFF7MainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnCheck = nil
	--self.BtnGet = nil
	--self.CommMoney = nil
	--self.ImgBGDeco1 = nil
	--self.ImgBGDeco2 = nil
	--self.ImgBGDeco3 = nil
	--self.OpsActivityTime = nil
	--self.PanelBGDeco3 = nil
	--self.PanelBtn = nil
	--self.PanelGift = nil
	--self.PanelList = nil
	--self.PanelTitle = nil
	--self.ShareTips = nil
	--self.TableViewList = nil
	--self.TableView_64 = nil
	--self.TextCheck = nil
	--self.TextGift = nil
	--self.TextListTitle = nil
	--self.TextSubTItle = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsFF7MainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.BtnGet)
	self:AddSubView(self.CommMoney)
	self:AddSubView(self.OpsActivityTime)
	self:AddSubView(self.ShareTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsFF7MainPanelView:OnInit()
	self.ViewModel = OpsActivityWhaleMonutVM.New()
	self.TaskTableViewAdapter =  UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.GiftTableViewAdapter =  UIAdapterTableView.CreateAdapter(self, self.TableView_64, self.OnItemSelectedChanged, true)
	self.GiftVMList = UIBindableList.New(OpsLimitedTimeSlotItemVM)

	self.Binders = {
		{"TaskVMList", UIBinderUpdateBindableList.New(self, self.TaskTableViewAdapter)},
		{"StrParamText1", UIBinderSetText.New(self, self.TextCheck)},
    }
end

function OpsFF7MainPanelView:OnItemSelectedChanged(Index, ItemData, ItemView)
	if ItemData ~= nil then
		ItemData.IsSelect = true
		ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView, {X = 0,Y = 0}, function() ItemData.IsSelect = false end)
	end
end

function OpsFF7MainPanelView:OnDestroy()

end

function OpsFF7MainPanelView:OnShow()
	self.BtnBuy:SetBtnName(LSTR(1730002))
	self.BtnGet:SetBtnName(LSTR(1730001))
	self.TextGift:SetText(LSTR(1730004))
	if not self.Params then return end
	if not self.Params.ActivityID then return end
	self:UpdateAll()
	self.CommMoney:UpdateView(SCORE_TYPE.SCORE_TYPE_STAMPS, true, UIViewID.RechargingMainPanel, true)
end

local DailyRandomJumpCheck = function(NodeID, IsHint)
	local JumpState = false
	local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
	if ActivityNode ~= nil then 
		local JumpID = tonumber(ActivityNode.JumpParam) or 0
		JumpState = JumpUtil.IsCurJumpIDCanJump(JumpID)
		if not JumpState and IsHint then
			MsgTipsUtil.ShowTips(LSTR(1730007))
		end
		return JumpState
	end
	return JumpState
end

function OpsFF7MainPanelView:UpdateAll()
	local Activity = self.Params.Activity
	_G.RedDotMgr:DelRedDotByName(OpsActivityMgr:GetRedDotName(Activity.ClassifyID, Activity.ActivityID, "Reward"))
	self.ViewModel:Update(self.Params)

	local TaskVMList = self.ViewModel.TaskVMList:GetItems() or {}
	for i = 1, #TaskVMList do
		local RewardVMList = TaskVMList[i].RewardList:GetItems() or {}
		if TaskVMList[i].NodeID == JumpStateCheckNodeID then
			TaskVMList[i].JumpStateCheckCB = DailyRandomJumpCheck
			TaskVMList[i]:RefreshBtnGoText()
		end

		for j = 1, #RewardVMList do
			RewardVMList[j].NumVisible = false
		end
	end
	local Tasks = self.ViewModel.Tasks or {}
	for i = 1, #Tasks do
		local Rewards = Tasks[i].Rewards or {}
		if Tasks[i].NodeID == JumpStateCheckNodeID then
			Tasks[i].JumpStateCheckCB = DailyRandomJumpCheck
		end
		for j = 1, #Rewards do
			Rewards[j].NumVisible = false
		end
	end

	self:UpdateUIShow()
end

function OpsFF7MainPanelView:UpdateUIShow()
	local Activity = self.Params and self.Params.Activity or {}
	local HasBought = self.ViewModel:GetActGoodsHasBought()
	if HasBought then
		UIUtil.CanvasSlotSetPosition(self.PanelTitle, _G.UE.FVector2D(0, -320))
	else
		UIUtil.CanvasSlotSetPosition(self.PanelTitle, _G.UE.FVector2D(0, -40.5))
	end

	UIUtil.SetIsVisible(self.PanelList, HasBought)
	UIUtil.SetIsVisible(self.PanelBtn, not HasBought)
	UIUtil.SetIsVisible(self.PanelGift, not HasBought)
	UIUtil.SetIsVisible(self.ImgBGDeco1, not HasBought)
	UIUtil.SetIsVisible(self.ImgBGDeco2, HasBought)
	UIUtil.SetIsVisible(self.ImgBGDeco3, HasBought)
	UIUtil.SetIsVisible(self.TextSubTItle, not HasBought)

	self.TextTitle:SetText(Activity.Title or "")
	self.TextSubTItle:SetText(Activity.SubTitle or "")
	self.TextListTitle:SetText(Activity.SubTitle or "")

	local GoodsID = self.ViewModel:GetGoodsID()
	self.BtnBuy:SetBtnPriceByGoodsID(GoodsID)

	local GiftListData = {}
	local StatisticNodeList = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeStatistic) or {}

	for i = 1, #StatisticNodeList do
		local NodeID = (StatisticNodeList[i].Head or {}).NodeID or 0
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID) or {}
		local ResID = (NodeCfg.Rewards[1] or {}).ItemID
		if (ResID or 0) ~= 0 then
			table.insert(GiftListData,  { NodeID = NodeID, BtnCheckVisible = true, ResID = ResID })
		end
	end
	table.sort(GiftListData, function(Left, Right) return Left.NodeID < Right.NodeID end)
	self.GiftVMList:UpdateByValues(GiftListData)
	self.GiftTableViewAdapter:UpdateAll(self.GiftVMList)
end

function OpsFF7MainPanelView:OnHide()
	self:HideOtherView()
end

function OpsFF7MainPanelView:OnActive()
	if not self.ViewModel then return end

	OpsActivityMgr:SendQueryActivity(self.Params.ActivityID)
end

function OpsFF7MainPanelView:OnRegisterBinder()
	if self.ViewModel then
		self:RegisterBinders(self.ViewModel, self.Binders)
	end
end

function OpsFF7MainPanelView:HideOtherView()
	if UIViewMgr:IsViewVisible(_G.UIViewID.StoreNewBuyWinPanel) then
		UIViewMgr:HideView(_G.UIViewID.StoreNewBuyWinPanel)
	end

	if UIViewMgr:IsViewVisible(_G.UIViewID.OpsSkateboardRebatesWin) then
		UIViewMgr:HideView(_G.UIViewID.OpsSkateboardRebatesWin)
	end
end

function OpsFF7MainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGet, self.OnClickRebateTask)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy.CommBtnL, self.OnClickBuy)
	UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnClickPreview)
end

function OpsFF7MainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.StoreBuyGoodsDisplay, self.OnShowReward)
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.UpdateOriginDataShow)
	self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.UpdateOriginDataShow)
	self:RegisterGameEvent(EventID.OpsActivityUpdate, self.UpdateOriginDataShow)
	self:RegisterGameEvent(EventID.BagUseItemSucc, self.OnEventUseItemSucc)
	self:RegisterGameEvent(EventID.LootItemUpdateRes, self.OnLootItemUpdateRes)
end

function OpsFF7MainPanelView:OnEventUseItemSucc(Params)
    if nil == Params then return end

	local GoodsID = self.ViewModel:GetGoodsID()
	local TempCfg = StoreCfg:FindCfgByKey(GoodsID)
	if not TempCfg then return end	
	local TempCfgItems = TempCfg.Items or {}
	local ResID = TempCfgItems[1] and TempCfgItems[1].ID or 0
	if Params.ResID == ResID then
		OpsActivityMgr:SendQueryActivity(self.Params.ActivityID)
		self:HideOtherView()
	end
end

function OpsFF7MainPanelView:UpdateOriginDataShow()
	local NodeData = OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID)
	if NodeData and NodeData.NodeList then
		self.Params.NodeList = NodeData.NodeList
		self:UpdateAll()
	end
end

function OpsFF7MainPanelView:OpsNodeRewardGet(MsgBody)
	local NodeData = OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID)
	if NodeData and NodeData.NodeList then
		self.Params.NodeList = NodeData.NodeList
		self:UpdateAll()
	end
end

function OpsFF7MainPanelView:OnLootItemUpdateRes(InLootList, InReason)
	if not InLootList or not next(InLootList) then return end
	if not string.find(InReason, "Activity") then return end

	local TaskData = self.ViewModel and self.ViewModel.Tasks or {}
	local ItemList = {}
	for i, v in ipairs(TaskData) do
		if string.find(InReason, tostring(v.NodeID)) then
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
        UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, {ItemList = ItemList})
    end
end

function OpsFF7MainPanelView:OnShowReward()
	self:RegisterTimer(function()
		if not UIViewMgr:IsViewVisible(_G.UIViewID.CommonRewardPanel) then
			self:PlayAnimation(self.AnimToPurchased)
			self:UpdateAll()
			self:UnRegisterAllTimer()
		end
	end, 0, 1, -1)

	self:HideOtherView()
end

function OpsFF7MainPanelView:OnClickRebateTask()
	DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "3")
	UIViewMgr:ShowView(UIViewID.OpsSkateboardRebatesWin, {ViewModel = self.ViewModel, TitleText = LSTR(1730001), BtnText = LSTR(1730006)})
end

function OpsFF7MainPanelView:OnClickBuy()
	local GoodsID = self.ViewModel:GetGoodsID()
	_G.StoreMgr:OpenExternalPurchaseInterfaceByNewUIBP(GoodsID)
	DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "4")
end

function OpsFF7MainPanelView:OnClickPreview()
	if self.ViewModel and self.ViewModel.PreviewMonutJumpID then
		OpsActivityMgr:Jump(self.ViewModel.PreviewMonutJumpType, self.ViewModel.PreviewMonutJumpID)
		DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "2")
	end
end

return OpsFF7MainPanelView