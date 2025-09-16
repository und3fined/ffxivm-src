---
--- Author: Administrator
--- DateTime: 2024-12-06 10:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local StoreCfg = require("TableCfg/StoreCfg")
local ProtoRes = require("Protocol/ProtoRes")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local ProtoCS = require("Protocol/ProtoCS")

local DataReportUtil = require("Utils/DataReportUtil")
local OpsActivityWhaleMonutVM = require("Game/Ops/VM/OpsActivityWhaleMonutVM")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local UIViewMgr = require("UI/UIViewMgr")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LSTR = _G.LSTR

---@class OpsWhaleMonutPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnNormal CommBtnLView
---@field BtnRecommend OpsCommBtnLView
---@field CommMoney CommMoneySlotView
---@field PanelNotPurchased UFCanvasPanel
---@field PanelPurchased UFCanvasPanel
---@field PreviewBtn OpsActivityPreviewBtnView
---@field RichTextInfo URichTextBox
---@field RichTextInfo2 URichTextBox
---@field ShareTips OpsActivityShareTipsItemView
---@field TableViewList UTableView
---@field TextHint UFTextBlock
---@field TextTitle1 UFTextBlock
---@field TextTitle2 UFTextBlock
---@field TimeNotPurchased OpsActivityTimeItemView
---@field TimePurchased OpsActivityTimeItemView
---@field AnimIn UWidgetAnimation
---@field AnimToPurchased UWidgetAnimation
---@field AnimWhaleLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsWhaleMonutPanelView = LuaClass(UIView, true)

function OpsWhaleMonutPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnNormal = nil
	--self.BtnRecommend = nil
	--self.CommMoney = nil
	--self.PanelNotPurchased = nil
	--self.PanelPurchased = nil
	--self.PreviewBtn = nil
	--self.RichTextInfo = nil
	--self.RichTextInfo2 = nil
	--self.ShareTips = nil
	--self.TableViewList = nil
	--self.TextHint = nil
	--self.TextTitle1 = nil
	--self.TextTitle2 = nil
	--self.TimeNotPurchased = nil
	--self.TimePurchased = nil
	--self.AnimIn = nil
	--self.AnimToPurchased = nil
	--self.AnimWhaleLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsWhaleMonutPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnNormal)
	self:AddSubView(self.BtnRecommend)
	self:AddSubView(self.CommMoney)
	self:AddSubView(self.PreviewBtn)
	self:AddSubView(self.ShareTips)
	self:AddSubView(self.TimeNotPurchased)
	self:AddSubView(self.TimePurchased)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsWhaleMonutPanelView:OnInit()
	self.ViewModel = OpsActivityWhaleMonutVM.New()
	self.TaskTableViewAdapter =  UIAdapterTableView.CreateAdapter(self, self.TableViewList)

	self.Binders = {
		{"TaskVMList", UIBinderUpdateBindableList.New(self, self.TaskTableViewAdapter)},
		{"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextSubTitle", UIBinderSetText.New(self, self.TextSubTitle)},
		{"StrParamText1", UIBinderSetText.New(self, self.PreviewBtn.Text01)},
		{"StrParamText2", UIBinderSetText.New(self, self.PreviewBtn.Text02)},
		{"StrParamText3", UIBinderSetText.New(self, self.TextHint)},
		{"StrParamText3Visible", UIBinderSetIsVisible.New(self, self.TextHint)},
    }
end

function OpsWhaleMonutPanelView:OnDestroy()

end

function OpsWhaleMonutPanelView:OnShow()
	self.BtnNormal:SetButtonText(LSTR(100041))
	self.BtnRecommend:SetBtnName(LSTR(100040))
	if not self.Params then return end
	if not self.Params.ActivityID then return end
	self:UpdateAll()
	self.CommMoney:UpdateView(SCORE_TYPE.SCORE_TYPE_STAMPS, true, _G.UIViewID.RechargingMainPanel, true)
end

function OpsWhaleMonutPanelView:UpdateAll()
	self.ViewModel:Update(self.Params)
	self:UpdateUIShow()
end

function OpsWhaleMonutPanelView:UpdateUIShow()
	local Activity = self.Params and self.Params.Activity or {}
	if self.ViewModel:GetActGoodsHasBought() then
		UIUtil.SetIsVisible(self.PanelPurchased, true)
		UIUtil.SetIsVisible(self.PanelNotPurchased, false)
	else
		UIUtil.SetIsVisible(self.PanelPurchased, false)
		UIUtil.SetIsVisible(self.PanelNotPurchased, true)
	end

	self.TextTitle1:SetText(Activity.Title or "")
	self.TextTitle2:SetText(Activity.Title or "")
	self.RichTextInfo:SetText(Activity.SubTitle or "")
	self.RichTextInfo2:SetText(Activity.SubTitle or "")

	local GoodsID = self.ViewModel:GetGoodsID()
	self.BtnRecommend:SetBtnPriceByGoodsID(GoodsID)
end

function OpsWhaleMonutPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnNormal, self.OnClickRebateTask)
	UIUtil.AddOnClickedEvent(self, self.BtnRecommend.CommBtnL, self.OnClickBuy)
	UIUtil.AddOnClickedEvent(self, self.PreviewBtn.BtnView, self.OnClickPreview)
end

function OpsWhaleMonutPanelView:OnClickRebateTask()
	DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "3")
	UIViewMgr:ShowView(_G.UIViewID.OpsWhaleMonutRebatesWin, {ViewModel = self.ViewModel})
end

function OpsWhaleMonutPanelView:OnClickBuy()
	local GoodsID = self.ViewModel:GetGoodsID()
	_G.StoreMgr:OpenExternalPurchaseInterfaceByNewUIBP(GoodsID)
	DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "4")
end

function OpsWhaleMonutPanelView:OnClickPreview()
	if self.ViewModel and self.ViewModel.PreviewMonutJumpID then
		OpsActivityMgr:Jump(self.ViewModel.PreviewMonutJumpType, self.ViewModel.PreviewMonutJumpID)
		DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "2")
	end
end

function OpsWhaleMonutPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.StoreBuyGoodsDisplay, self.OnShowReward)
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.UpdateOriginDataShow)
	self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.UpdateOriginDataShow)
	self:RegisterGameEvent(EventID.OpsActivityUpdate, self.UpdateOriginDataShow)
	self:RegisterGameEvent(EventID.BagUseItemSucc, self.OnEventUseItemSucc)
	self:RegisterGameEvent(EventID.LootItemUpdateRes, self.OnLootItemUpdateRes)
end

function OpsWhaleMonutPanelView:OnEventUseItemSucc(Params)
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

function OpsWhaleMonutPanelView:OnActive()
	if not self.ViewModel then return end
		
	OpsActivityMgr:SendQueryActivity(self.Params.ActivityID)
end

function OpsWhaleMonutPanelView:UpdateOriginDataShow()
	local NodeData = OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID)
	if NodeData and NodeData.NodeList then
		self.Params.NodeList = NodeData.NodeList
		self:UpdateAll()
	end
end

function OpsWhaleMonutPanelView:OpsNodeRewardGet(MsgBody)
	local NodeData = OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID)
	if NodeData and NodeData.NodeList then
		self.Params.NodeList = NodeData.NodeList
		self:UpdateAll()
	end
end

function OpsWhaleMonutPanelView:OnLootItemUpdateRes(InLootList, InReason)
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

function OpsWhaleMonutPanelView:OnShowReward()
	self:RegisterTimer(function()
		if not UIViewMgr:IsViewVisible(_G.UIViewID.CommonRewardPanel) then
			self:PlayAnimation(self.AnimToPurchased)
			self:UpdateAll()
			self:UnRegisterAllTimer()
		end
	end, 0, 1, -1)
	
	self:HideOtherView()
end

function OpsWhaleMonutPanelView:OnRegisterBinder()
	if self.ViewModel then
		self:RegisterBinders(self.ViewModel, self.Binders)
	end
end

function OpsWhaleMonutPanelView:OnHide()
	self:HideOtherView()
end

function OpsWhaleMonutPanelView:HideOtherView()
	if UIViewMgr:IsViewVisible(_G.UIViewID.StoreNewBuyWinPanel) then
		UIViewMgr:HideView(_G.UIViewID.StoreNewBuyWinPanel)
	end

	if UIViewMgr:IsViewVisible(_G.UIViewID.OpsWhaleMonutRebatesWin) then
		UIViewMgr:HideView(_G.UIViewID.OpsWhaleMonutRebatesWin)
	end
end

return OpsWhaleMonutPanelView