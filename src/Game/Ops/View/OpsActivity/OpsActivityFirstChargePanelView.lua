---
--- Author: Administrator
--- DateTime: 2024-12-03 19:09
--- Description:首充活动界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ProtoCS = require("Protocol/ProtoCS")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local JumpUtil = require("Utils/JumpUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local DataReportUtil = require("Utils/DataReportUtil")

local ProtoCommon = require("Protocol/ProtoCommon")

local OpsActivityFirstChargePanelVM = require("Game/Ops/VM/OpsActivityFirstChargePanelVM")
local OpsActivityFirstChargeMgr = require("Game/Ops/OpsActivityFirstChargeMgr")
local ModuleOpenMgr = require("Game/ModuleOpen/ModuleOpenMgr")

local OpType ={
	Button = 1,
	MonthCard = 2,
	BattlePass = 3,
	PreviewReward = 4,
}

---@class OpsActivityFirstChargePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityTime OpsActivityTimeItemView
---@field BkgMask CommonBkgMaskView
---@field Btn CommBtnLView
---@field CommonBkg CommonBkg02View
---@field PreviewBtn OpsActivityPreviewBtnView
---@field TableViewSlot UTableView
---@field TextAward UFTextBlock
---@field TextDebut UFTextBlock
---@field TextInfo URichTextBox
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimInLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityFirstChargePanelView = LuaClass(UIView, true)

function OpsActivityFirstChargePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityTime = nil
	--self.BkgMask = nil
	--self.Btn = nil
	--self.CommonBkg = nil
	--self.PreviewBtn = nil
	--self.TableViewSlot = nil
	--self.TextAward = nil
	--self.TextDebut = nil
	--self.TextInfo = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimInLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityFirstChargePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityTime)
	self:AddSubView(self.BkgMask)
	self:AddSubView(self.Btn)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.PreviewBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityFirstChargePanelView:OnInit()
	self.ViewModel = OpsActivityFirstChargePanelVM.New()

	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnItemSelectedItemChanged, true)
	self.Binders = {
		{"RewardList", UIBinderUpdateBindableList.New(self, self.RewardListAdapter)},
		{"Title", UIBinderSetText.New(self, self.TextTitle)},
		{"SubTitle", UIBinderSetText.New(self, self.TextDebut)},
		{"Content", UIBinderSetText.New(self, self.TextInfo)},
		{"RewardName", UIBinderSetText.New(self, self.PreviewBtn.Text01)},
		{"RewardDescVisible", UIBinderSetIsVisible.New(self, self.PreviewBtn.Text02)},
		{"HelpID", UIBinderValueChangedCallback.New(self, nil, self.OnHelpIDChanged)},
		{"RewardBtnText", UIBinderSetText.New(self, self.Btn.TextContent)},
		{"RewardBtnText", UIBinderValueChangedCallback.New(self, nil, self.OnRewardStatusChanged)},

	}
end

function OpsActivityFirstChargePanelView:OnDestroy()
end

function OpsActivityFirstChargePanelView:OnShow()
	local Params = self.Params
	local NodeList = Params.NodeList
	OpsActivityFirstChargeMgr:SetActivityID(Params.ActivityID)
	if table.is_nil_empty(NodeList) then return end
	if not(NodeList[1] and NodeList[1].Head) then return  end
	OpsActivityFirstChargeMgr:SetNodeID(NodeList[1].Head.NodeID)
	local Head = NodeList[1].Head
	if not(Head.RewardStatus) then return end
	local Status = Head.RewardStatus
	OpsActivityFirstChargeMgr:SetFirstChargerStatus(Status)

	self.ViewModel:UpdateBaseInfo()
	self.ViewModel:UpdateRewardList()
	self.ViewModel:UpdateRewardBtn()

	self:InitText()
    self:RegisterTimer(function ()
		self:PlayAnimation(self.AnimInLoop, 0, 0)
	end, self.AnimIn:GetEndTime())
end

function OpsActivityFirstChargePanelView:InitText()
	self.TextAward:SetText(_G.LSTR(900004))
end

function OpsActivityFirstChargePanelView:OnHide()
end

function OpsActivityFirstChargePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickedBtn)
	UIUtil.AddOnClickedEvent(self, self.PreviewBtn.BtnView, self.OnClickedPreviewBtn)
	UIUtil.AddOnHyperlinkClickedEvent(self, self.TextInfo, self.OnHyperlinkClicked)
end

function OpsActivityFirstChargePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.OpsNodeRewardGet)
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdateInfo, self.OpsNodeRewardGet)
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdate, self.OpsNodeRewardGet)
end

function OpsActivityFirstChargePanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsActivityFirstChargePanelView:OnHelpIDChanged()
	self.ActivityTime.InforBtn.HelpInfoID = self.ViewModel.HelpID
end

function OpsActivityFirstChargePanelView:OpsNodeRewardGet(MsgBody)
	local NodeData = _G.OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID)
	self.Params.NodeList = NodeData.NodeList
	local Head = self.Params.NodeList[1].Head
	if not(Head.RewardStatus) then return end
	local Status = Head.RewardStatus
	OpsActivityFirstChargeMgr:SetFirstChargerStatus(Status)
	self.ViewModel:UpdateRewardList()
	self.ViewModel:UpdateRewardBtn()
end


function OpsActivityFirstChargePanelView:OnRewardStatusChanged()
	local Status = OpsActivityFirstChargeMgr:GetFirstChargerStatus()
	self.Btn:SetIsDisabledState(Status == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone, true)
end

-- 点击预览按钮
function OpsActivityFirstChargePanelView:OnClickedPreviewBtn()
	if self.ViewModel == nil then return end
	if self.ViewModel.RewardID == nil then return end

	DataReportUtil.ReportFirstChargeData("ActivityClickFlow", OpsActivityFirstChargeMgr:GetActivityID(), OpType.PreviewReward)
	_G.PreviewMgr:OpenPreviewView(self.ViewModel.RewardID)
end

function OpsActivityFirstChargePanelView:OnItemSelectedItemChanged(Index, ItemData, ItemView)
	if ItemData.ResID ~= nil then
		if ItemUtil.ItemIsScore(ItemData.ResID) then
			ItemTipsUtil.CurrencyTips(ItemData.ResID, false, ItemView, _G.UE4.FVector2D(0, 0))
		else
			ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView, _G.UE4.FVector2D(0, 0))
		end
	end
end

-- 点击领取按钮
function OpsActivityFirstChargePanelView:OnClickedBtn()
	local Status = OpsActivityFirstChargeMgr:GetFirstChargerStatus()
	if Status == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
	end

	if Status == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
	OpsActivityFirstChargeMgr:SendGetFirstChargeReward()
	end

	if Status == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		DataReportUtil.ReportFirstChargeData("ActivityClickFlow", OpsActivityFirstChargeMgr:GetActivityID(), OpType.Button)
		_G.RechargingMgr:ShowMainPanel()
	end
end


function OpsActivityFirstChargePanelView:OnHyperlinkClicked(_, LinkID)
	if tonumber(LinkID) == 18 then
		DataReportUtil.ReportFirstChargeData("ActivityClickFlow", OpsActivityFirstChargeMgr:GetActivityID(), OpType.MonthCard)
		-- if not ModuleOpenMgr:ModuleState(ProtoCommon.ModuleID.ModuleIDMonthCard) then
		-- 	return
		-- end

	elseif tonumber(LinkID) == 32 then
		DataReportUtil.ReportFirstChargeData("ActivityClickFlow", OpsActivityFirstChargeMgr:GetActivityID(), OpType.BattlePass)
		-- if not ModuleOpenMgr:ModuleState(ProtoCommon.ModuleID.ModuleIDBattlePass) then
		-- 	return
		-- end
	end 
	JumpUtil.JumpTo(tonumber(LinkID), true)
end

return OpsActivityFirstChargePanelView