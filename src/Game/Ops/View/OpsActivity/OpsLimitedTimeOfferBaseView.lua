
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
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
local OpsActivityMgr = _G.OpsActivityMgr
local LootMgr = _G.LootMgr
local UIViewMgr = _G.UIViewMgr
local FLOG_ERROR = _G.FLOG_ERROR
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsLimitedTimeOfferBaseView : UIView
local OpsLimitedTimeOfferBaseView = LuaClass(UIView, true)

function OpsLimitedTimeOfferBaseView:OnInit()
	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_33, self.OnItemSelectedItemChanged, true)
	self.ItemVMList = UIBindableList.New(OpsLimitedTimeSlotItemVM)
end

function OpsLimitedTimeOfferBaseView:OnDestroy()

end

function OpsLimitedTimeOfferBaseView:InitBtnBuy()
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

function OpsLimitedTimeOfferBaseView:SetBtnBuy(IsBuy, BtnText, TextOriginalPrice)
	self.BtnBuy.BtnText = BtnText
	self.BtnBuy:SetBtnName(BtnText)
	self.BtnBuy.CommBtnL:SetIsEnabled(IsBuy)

	UIUtil.SetIsVisible(self.BtnBuy.IconMoney, IsBuy)
	UIUtil.SetIsVisible(self.BtnBuy.PanelOriginalPrice, IsBuy)
	self.BtnBuy.TextOriginalPrice:SetText(TextOriginalPrice)
	self.BtnBuy.CommBtnL:SetIsDoneState(not IsBuy, BtnText )
end

function OpsLimitedTimeOfferBaseView:MemberCheck(ActivityID)
    local ClassName = self.BtnBuy:GetClassName() 
    ClassName = self.PreviewBtn:GetClassName() 

    if self.BtnBuy == nil or self.BtnBuy:GetClassName() ~= "OpsCommBtnL_UIBP_C" then
        FLOG_ERROR("OpsLimitedTimeOfferBase: BtnBuy Error!!! ActivityID:".. tostring(ActivityID))
        return true 
    end
    if self.PreviewBtn == nil or self.PreviewBtn:GetClassName() ~= "OpsActivityPreviewBtn_UIBP_C" then
        FLOG_ERROR("OpsLimitedTimeOfferBase: TableView Error!!! ActivityID:".. tostring(ActivityID))
        return true 
    end
end

function OpsLimitedTimeOfferBaseView:OnShow()
	self.RewardListAdapter:CancelSelected()
    local Params = self.Params
    if Params == nil or Params.ActivityID == nil or self:MemberCheck(Params.ActivityID) then
		return
	end
	self:InitBtnBuy()
	self.ItemList = nil
	self.Buying = false
	self.RechargeDisplayOrder = 0
	self:InitViewByCfg()
	self:ShowBtnBuy()
	self.Money:UpdateView(SCORE_TYPE.SCORE_TYPE_STAMPS, true, UIViewID.RechargingMainPanel, true)
end

function OpsLimitedTimeOfferBaseView:OnHide()
	if self.Buying then 
		self.Buying = false
		LootMgr:SetDealyState(self.Buying)
	end
end

function OpsLimitedTimeOfferBaseView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.PreviewBtn.BtnView, self.OnClickPreviewBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy.CommBtnL, self.OnClickedBuy)
    if self.ShareTips then
        UIUtil.AddOnClickedEvent(self, self.ShareTips.Btn, self.OnClickShareBtn)
    end
    if self.Money then
        UIUtil.AddOnClickedEvent(self, self.Money.BtnAdd, self.OnClickMoneyBtnAdd)
    end
end

function OpsLimitedTimeOfferBaseView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RechargeActivitySuccess, self.UpdateByRechargeSuccess)
end

function OpsLimitedTimeOfferBaseView:UpdateByRechargeSuccess(RechargeActivityID)
	if (self.Params or {}).ActivityID ~= RechargeActivityID then
		return 
	end
	self:SetBtnBuy(false, LSTR(1290003))
	local RechargeNode = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeRecharge)[1]
	if RechargeNode ~= nil then
		RechargeNode.Head.Finished = true
		if self.ItemList ~= nil then
			if #self.ItemList > 0 then
				UIViewMgr:ShowView(UIViewID.CommonRewardPanel, { Title = LSTR(790003), ItemList = self.ItemList } )   --"恭喜获得"
			else
				self.Buying = false
				LootMgr:SetDealyState(self.Buying)
			end
		end
	end
end

function OpsLimitedTimeOfferBaseView:OnRegisterBinder()

end

function OpsLimitedTimeOfferBaseView:OnItemSelectedItemChanged(Index, ItemData, ItemView)
	if ItemData ~= nil then
		ItemData.IsSelect = true
		ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView, {X = 0,Y = 0}, function() ItemData.IsSelect = false end)
	end
end

function OpsLimitedTimeOfferBaseView:InitViewByCfg()
	local ActCfg = self.Params.Activity or {}
    if self.TextLimitedTimeOffer then
        self.TextLimitedTimeOffer:SetText(ActCfg.Title or "")
    end
    if self.TextInfo then
        self.TextInfo:SetText(ActCfg.SubTitle or "")
    end
    
	local ClientShowNodes = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
	local NodeID  = ClientShowNodes[1].Head.NodeID
	local ClientShowNodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)

	--文本填充
    if self.TextPrice then
        self.TextPrice:SetText(ClientShowNodeCfg.NodeTitle or "")
    end
    if self.TextUnit then
        self.TextUnit:SetText(ClientShowNodeCfg.NodeDesc or "")
    end
    if self.TextDiscount then
        self.TextDiscount:SetText(LSTR(790002))    	--"超值折扣！"
    end
	self.TextOriginalPrice = UIBinderSetTextFormatForMoney:GetText(ClientShowNodeCfg.Params[1] or 0)
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

function OpsLimitedTimeOfferBaseView:ShowBtnBuy()
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
		self:SetBtnBuy(false, LSTR(1290003))
    else
		local NodeID  = RechargeNode.Head.NodeID
		local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID) or {}
		local BtnText = ActivityNode.NodeTitle or ""
		self:SetBtnBuy(true, BtnText, self.TextOriginalPrice)
    end
end

function OpsLimitedTimeOfferBaseView:OnClickedBuy()
	local RechargeNode = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeRecharge)[1]
	if self.RechargeDisplayOrder == 0 or RechargeNode == nil or RechargeNode.Head.Finished then
		return
	end
	self.Buying = true
	LootMgr:SetDealyState(self.Buying)
	DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "4")
	OpsActivityMgr:Recharge(self.RechargeDisplayOrder, self.Params.ActivityID, self)
end

function OpsLimitedTimeOfferBaseView:OnClickPreviewBtn()
	if self.ShowNodeJumpType ~= nil and self.ShowNodeJumpParam ~= nil then
		OpsActivityMgr:Jump(self.ShowNodeJumpType, self.ShowNodeJumpParam)
		DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "3")
	end
end

function OpsLimitedTimeOfferBaseView:OnClickShareBtn()
	DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "1")
end

function OpsLimitedTimeOfferBaseView:OnClickMoneyBtnAdd()
	DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "2")
end

return OpsLimitedTimeOfferBaseView