---
--- Author: Administrator
--- DateTime: 2024-12-16 14:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local OpsShoppingPanelVM = require("Game/Ops/VM/OpsShoppingPanelVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local RechargeCfg = require("TableCfg/RechargeCfg")
local CommonUtil = require("Utils/CommonUtil")
local OPS_JUMP_TYPE = ProtoRes.Game.OPS_JUMP_TYPE
local LSTR = _G.LSTR
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

local UIViewMgr
local UIViewID
---@class OpsShoppingPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy CommBtnLView
---@field BtnExchange UFButton
---@field BtnGoto1 UFButton
---@field BtnGoto2 UFButton
---@field BtnGoto3 UFButton
---@field BtnGoto4 UFButton
---@field BtnGoto5 UFButton
---@field BtnGoto6 UFButton
---@field BtnStore UFButton
---@field RichTextHint URichTextBox
---@field ShareTips OpsActivityShareTipsItemView
---@field TextExchange UFTextBlock
---@field TextStore UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field Time OpsActivityTimeItemView
---@field AnimaIn UWidgetAnimation
---@field AnimaIn_0 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsShoppingPanelView = LuaClass(UIView, true)

function OpsShoppingPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnExchange = nil
	--self.BtnGoto1 = nil
	--self.BtnGoto2 = nil
	--self.BtnGoto3 = nil
	--self.BtnGoto4 = nil
	--self.BtnGoto5 = nil
	--self.BtnGoto6 = nil
	--self.BtnStore = nil
	--self.RichTextHint = nil
	--self.ShareTips = nil
	--self.TextExchange = nil
	--self.TextStore = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.Time = nil
	--self.AnimaIn = nil
	--self.AnimaIn_0 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsShoppingPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.ShareTips)
	self:AddSubView(self.Time)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsShoppingPanelView:OnInit()
	UIViewMgr = _G.UIViewMgr
	UIViewID = _G.UIViewID
	self.ViewModel = OpsShoppingPanelVM.New()
	self.Binders = {
        {"TitleText", UIBinderSetText.New(self, self.TextTitle)},
		{"SubTitleText", UIBinderSetText.New(self, self.TextSubTitle)},
       	{"RichHintText", UIBinderSetText.New(self, self.RichTextHint)},
		{"ImgPoster", UIBinderSetImageBrush.New(self, self.ImgPoster)},
		--{"BuyBtnEnabled", UIBinderSetIsEnabled.New(self, self.BtnBuy)},
    }
end

function OpsShoppingPanelView:OnDestroy()

end

function OpsShoppingPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end

	self.ViewModel:Update(self.Params)
	self:SetRechargeInfo()
end

function OpsShoppingPanelView:GetCurRechargeInfo()
    local NodeList = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeRecharge)
	for _, Node in ipairs(NodeList) do
		local NodeID  = Node.Head.NodeID
		local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
		FLOG_INFO("OpsShoppingPanelView...GetCurRechargeInfo: "..tostring(Node.Head.NodeID))
		for i = 1, ActivityNode.ParamNum do
            local RechargeCfg = RechargeCfg:FindCfgByKey(ActivityNode.Params[i])
			if RechargeCfg then
				FLOG_INFO("OpsShoppingPanelView...GetCurRechargeInfo,RechargeCfg: "..tostring(RechargeCfg.ID))
            	local Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID
            	if CommonUtil.GetPlatformName() == "Android" then
					Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID
             	elseif CommonUtil.GetPlatformName() == "IOS" then
                 	Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_IOS
				end
		
             	if RechargeCfg.Platform == Platform then
                	return Node, RechargeCfg
            	end
			end
         end
	end

    return nil
end

function OpsShoppingPanelView:SetRechargeInfo()
    local RechargeNode, RechargeCfg = self:GetCurRechargeInfo()
    if RechargeNode == nil or RechargeCfg == nil then
        return
    end
 
    if RechargeNode.Head.Finished == true then
		self.BtnBuy:SetButtonText(LSTR(1290003))
       -- self.ViewModel.BuyBtnEnabled = false
		self.BtnBuy:SetIsEnabled(false)
    else
		local NodeID  = RechargeNode.Head.NodeID
		local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
		if ActivityNode then
			self.BtnBuy:SetButtonText(ActivityNode.NodeTitle)
		end
        --self.ViewModel.BuyBtnEnabled = true
		self.BtnBuy:SetIsEnabled(true)
    end
end

function OpsShoppingPanelView:OnHide()

end

function OpsShoppingPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnExchange, self.OnClickExchange)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy.Button, self.OnClickedBuy)
	UIUtil.AddOnClickedEvent(self, self.BtnStore, self.OnClickedShopInlet)

	UIUtil.AddOnClickedEvent(self, self.BtnGoto1, self.OnClickedGoto1)
	UIUtil.AddOnClickedEvent(self, self.BtnGoto2, self.OnClickedGoto2)
	UIUtil.AddOnClickedEvent(self, self.BtnGoto3, self.OnClickedGoto3)
	UIUtil.AddOnClickedEvent(self, self.BtnGoto4, self.OnClickedGoto4)
	UIUtil.AddOnClickedEvent(self, self.BtnGoto5, self.OnClickedGoto5)
	UIUtil.AddOnClickedEvent(self, self.BtnGoto6, self.OnClickedGoto6)
end

function OpsShoppingPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.RechargeActivitySuccess, self.UpdateByRechargeSuccess)
end

function OpsShoppingPanelView:UpdateByRechargeSuccess(RechargeActivityID)
	if (self.Params or {}).ActivityID ~= RechargeActivityID then
		return
	end
	local RechargeNode, RechargeCfg = self:GetCurRechargeInfo()
	if RechargeNode == nil or RechargeCfg == nil then
		return
	end
	FLOG_INFO("UpdateByRechargeSuccess...ActivityID: "..tostring(RechargeActivityID))
	RechargeNode.Head.Finished = true
	self.BtnBuy:SetButtonText(LSTR(1290003))
    --self.ViewModel.BuyBtnEnabled = false
	self.BtnBuy:SetIsEnabled(false)

	local NodeID  = RechargeNode.Head.NodeID
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

end

function OpsShoppingPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.TextExchange:SetText(_G.LSTR(1290001))
	self.TextStore:SetText(_G.LSTR(1290002))
end

function OpsShoppingPanelView:OnClickExchange()
	local Nodes = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
	if Nodes == nil and #Nodes < 1 then
		return
	end
	UIViewMgr:ShowView(UIViewID.OpsActivityExchangeListWin, {Node = Nodes[1]})

end

function OpsShoppingPanelView:OnClickedBuy()
	local RechargeNode, RechargeCfg = self:GetCurRechargeInfo()
	if RechargeNode == nil or RechargeCfg == nil then
		FLOG_INFO("OpsShoppingPanelView RechargeCfg = nil or RechargeNode = nil")
		return
	end
	if RechargeNode.Head.Finished == true then
		return
    end
	_G.OpsActivityMgr:Recharge(RechargeCfg.DisplayOrder, self.Params.ActivityID, self)
end

function OpsShoppingPanelView:OnClickedShopInlet()
	UIViewMgr:ShowView(UIViewID.StoreNewMainPanel)
end

function OpsShoppingPanelView:OnClickedGoto1()
	self:JumpTo(1)
end

function OpsShoppingPanelView:OnClickedGoto2()
	self:JumpTo(2)
end

function OpsShoppingPanelView:OnClickedGoto3()
	self:JumpTo(3)
end

function OpsShoppingPanelView:OnClickedGoto4()
	self:JumpTo(4)
end

function OpsShoppingPanelView:OnClickedGoto5()
	self:JumpTo(5)
end

function OpsShoppingPanelView:OnClickedGoto6()
	self:JumpTo(6)
end

function OpsShoppingPanelView:JumpTo(Index)
	if Index == nil then
		return
	end
	local Nodes = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
	if Nodes == nil and #Nodes < 1 then
		return
	end
	local NodeID  = Nodes[1].Head.NodeID
	local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
	if ActivityNode then
		local UseNum = 2
		if ActivityNode.ParamNum < (UseNum + Index)  then
			return
		end
		_G.OpsActivityMgr:Jump(OPS_JUMP_TYPE.TABLE_JUMP, ActivityNode.Params[UseNum + Index])
	end
end

return OpsShoppingPanelView