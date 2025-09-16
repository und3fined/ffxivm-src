---
--- Author: Administrator
--- DateTime: 2024-12-09 10:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local UIViewID = require("Define/UIViewID")
local RechargeCfg = require("TableCfg/RechargeCfg")
local LootCfg = require("TableCfg/LootCfg")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local CommonUtil = require("Utils/CommonUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local OpsLimitedTimeSlotItemVM = require("Game/Ops/VM/OpsLimitedTimeSlotItemVM")

local LSTR = _G.LSTR
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsLimitedTimeOfferPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy OpsCommBtnLView
---@field Money CommMoneySlotView
---@field PreviewBtn OpsActivityPreviewBtnView
---@field ShareTips OpsActivityShareTipsItemView
---@field TableView_33 UTableView
---@field TextDiscount UFTextBlock
---@field TextInfo URichTextBox
---@field TextLimitedTimeOffer UFTextBlock
---@field TextPreview UFTextBlock
---@field TextPrice UFTextBlock
---@field TextUnit UFTextBlock
---@field Time OpsActivityTimeItemView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLimitedTimeOfferPanelView = LuaClass(UIView, true)

function OpsLimitedTimeOfferPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.Money = nil
	--self.PreviewBtn = nil
	--self.ShareTips = nil
	--self.TableView_33 = nil
	--self.TextDiscount = nil
	--self.TextInfo = nil
	--self.TextLimitedTimeOffer = nil
	--self.TextPreview = nil
	--self.TextPrice = nil
	--self.TextUnit = nil
	--self.Time = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLimitedTimeOfferPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.Money)
	self:AddSubView(self.PreviewBtn)
	self:AddSubView(self.ShareTips)
	self:AddSubView(self.Time)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsLimitedTimeOfferPanelView:InitBtnBuy()
	self.BtnBuy.NotUnlock = false
	self.BtnBuy.Price = false
	self.BtnBuy.Money = true 
	UIUtil.SetIsVisible(self.BtnBuy.PanelMoney, true) 
	UIUtil.SetIsVisible(self.BtnBuy.TextNotUnlock, false)
	UIUtil.SetIsVisible(self.BtnBuy.TextPrice, false)
	UIUtil.SetIsVisible(self.BtnBuy.PanelOriginalPrice, true)
	self.BtnBuy.TextOriginalPrice:SetText("")
	self.BtnBuy.BtnText = ""
	self.BtnBuy.CommBtnL:SetIsEnabled(false)
end

function OpsLimitedTimeOfferPanelView:OnInit()
	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_33, self.OnItemSelectedItemChanged, true)
	self.ItemVMList = UIBindableList.New(OpsLimitedTimeSlotItemVM)
	self:InitBtnBuy()
end

function OpsLimitedTimeOfferPanelView:OnDestroy()

end

function OpsLimitedTimeOfferPanelView:OnShow()
	self.ItemList = nil
	self.Buying = false
	self.BtnBuy.CommBtnL:SetIsEnabled(false)
	self.RechargeDisplayOrder = 0
	if self.Params == nil or self.Params.ActivityID == nil then
		return
	end
	self:InitViewByCfg()
	self:ShowBtnBuy()
	self.Money:UpdateView(SCORE_TYPE.SCORE_TYPE_STAMPS, true, UIViewID.RechargingMainPanel, true)
end

function OpsLimitedTimeOfferPanelView:OnHide()
	if self.Buying then 
		self.Buying = false
		_G.LootMgr:SetDealyState(self.Buying)
	end
end

function OpsLimitedTimeOfferPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.PreviewBtn.BtnView, self.OnClickPreviewBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy.CommBtnL, self.OnClickedBuy)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy.CommBtnL, self.OnClickedBuy)
	UIUtil.AddOnClickedEvent(self, self.ShareTips.Btn, self.OnClickShareBtn)
	UIUtil.AddOnClickedEvent(self, self.Money.BtnAdd, self.OnClickMoneyBtnAdd)
end

function OpsLimitedTimeOfferPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.RechargeActivitySuccess, self.UpdateByRechargeSuccess)
end

function OpsLimitedTimeOfferPanelView:UpdateByRechargeSuccess(RechargeActivityID)
	if (self.Params or {}).ActivityID ~= RechargeActivityID then
		return 
	end
	self.BtnBuy:SetBtnName(LSTR(1290003))   -- 已购买
    self.BtnBuy.CommBtnL:SetIsEnabled(false)
	local RechargeNode = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeRecharge)[1]
	if RechargeNode ~= nil then
		RechargeNode.Head.Finished = true
		if self.ItemList ~= nil then
			if #self.ItemList > 0 then
				_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, { Title = LSTR(790003), ItemList = self.ItemList } )   --"恭喜获得"
			else
				self.Buying = false
				_G.LootMgr:SetDealyState(self.Buying)
			end
		end
	end
end

function OpsLimitedTimeOfferPanelView:OnRegisterBinder()

end

function OpsLimitedTimeOfferPanelView:OnItemSelectedItemChanged(Index, ItemData, ItemView)
	if ItemData ~= nil then
		ItemData.IsSelect = true
		ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView, {X = 0,Y = 0}, function() ItemData.IsSelect = false end)
	end
end

function OpsLimitedTimeOfferPanelView:InitViewByCfg()
	local ActCfg = self.Params.Activity or {}
    self.TextLimitedTimeOffer:SetText(ActCfg.Title or "")
    self.TextInfo:SetText(ActCfg.SubTitle or "")
	local ClientShowNodes = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)

	local NodeID  = ClientShowNodes[1].Head.NodeID
	local ClientShowNodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)

	--文本填充
	self.TextPrice:SetText(ClientShowNodeCfg.NodeTitle or "")
	self.TextUnit:SetText(ClientShowNodeCfg.NodeDesc or "")
	self.TextDiscount:SetText(LSTR(790002))    	--"超值折扣！"
	self.BtnBuy.TextOriginalPrice:SetText(UIBinderSetTextFormatForMoney:GetText(ClientShowNodeCfg.Params[1] or 0))
	local TarLootCfg = LootCfg:FindCfgByKey(ClientShowNodeCfg.Params[2] or 0)
	self.ItemList = {}
	if TarLootCfg ~= nil then
		local Produce = TarLootCfg.Produce or {}
		for  i = 1, #Produce do 
			if (Produce[i].ID or 0) ~= 0 then
				table.insert(self.ItemList, {ResID = Produce[i].ID }) 
			end
		end
	end
	
	-- 商品预览跳转
	self.ShowNodeJumpParam = ClientShowNodeCfg.JumpParam
	self.ShowNodeJumpType = ClientShowNodeCfg.JumpType 
	self.PreviewBtn:SetTitleText(ClientShowNodeCfg.JumpButton or "")
	self.PreviewBtn:SetSubTitleText(nil)

	-- 奖励预览
	self.TextPreview:SetText(LSTR(790001))		--"奖励预览"
	self.RewardListAdapter:ScrollToTop()
	self.RewardListAdapter:SetScrollEnabled(not (#self.ItemList < 6))
	self.ItemVMList:UpdateByValues(self.ItemList)
	self.RewardListAdapter:UpdateAll(self.ItemVMList)
end

function OpsLimitedTimeOfferPanelView:ShowBtnBuy()
	local TarRechargeCfg
	local RechargeNode = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeRecharge)[1]
	if RechargeNode == nil then
        return
    end

	local RechargeNodeCfg = ActivityNodeCfg:FindCfgByKey(RechargeNode.Head.NodeID) or {}
	for i = 1, RechargeNodeCfg.ParamNum or 0 do
		TarRechargeCfg = RechargeCfg:FindCfgByKey(RechargeNodeCfg.Params[i])
		local Platform
		if CommonUtil.GetPlatformName() == "Android" then
			Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID
		elseif CommonUtil.GetPlatformName() == "IOS" then
			Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_IOS
		end
		if TarRechargeCfg.Platform == Platform then
			break
		end
	end

    if TarRechargeCfg == nil then
        return
    end
	self.RechargeDisplayOrder = TarRechargeCfg.DisplayOrder
    if RechargeNode.Head.Finished == true then
		self.BtnBuy:SetBtnName(LSTR(1290003))
		self.BtnBuy.BtnText = LSTR(1290003)
		self.BtnBuy.CommBtnL:SetIsEnabled(false)
    else
		local NodeID  = RechargeNode.Head.NodeID
		local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID) or {}
		self.BtnBuy:SetBtnName(ActivityNode.NodeTitle or "")
		self.BtnBuy.BtnText = ActivityNode.NodeTitle or ""
        self.BtnBuy.CommBtnL:SetIsEnabled(true)
    end
end

function OpsLimitedTimeOfferPanelView:OnClickedBuy()
	local RechargeNode = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeRecharge)[1]
	if self.RechargeDisplayOrder == 0 or RechargeNode == nil or RechargeNode.Head.Finished then
		return
	end
	self.Buying = true
	_G.LootMgr:SetDealyState(self.Buying)
	DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "4")
	_G.OpsActivityMgr:Recharge(self.RechargeDisplayOrder, self.Params.ActivityID, self)
end

function OpsLimitedTimeOfferPanelView:OnClickPreviewBtn()
	if self.ShowNodeJumpType ~= nil and self.ShowNodeJumpParam ~= nil then
		_G.OpsActivityMgr:Jump(self.ShowNodeJumpType, self.ShowNodeJumpParam)
		DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "3")
	end
end

function OpsLimitedTimeOfferPanelView:OnClickShareBtn()
	DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "1")
end

function OpsLimitedTimeOfferPanelView:OnClickMoneyBtnAdd()
	DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "2")
end

return OpsLimitedTimeOfferPanelView