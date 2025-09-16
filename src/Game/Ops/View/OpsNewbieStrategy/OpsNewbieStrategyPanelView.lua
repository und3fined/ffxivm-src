---
--- Author: Administrator
--- DateTime: 2024-11-18 14:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local OpsNewbieStrategyDefine = require("Game/Ops/OpsNewbieStrategy/OpsNewbieStrategyDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local OpsNewbieStrategyPanelVM = require("Game/Ops/VM/OpsNewbieStrategy/OpsNewbieStrategyPanelVM")
local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local DataReportUtil = require("Utils/DataReportUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local OpsNewbieStrategyMgr
local RedDotMgr

local MenuActivityIDMap = {
	[OpsNewbieStrategyDefine.PanelKey.FirstChoicePanel] = OpsNewbieStrategyDefine.ActivityID.FirstChoiceActivityID,
	[OpsNewbieStrategyDefine.PanelKey.RecommendPanel] = OpsNewbieStrategyDefine.ActivityID.RecommendActivityID,
	[OpsNewbieStrategyDefine.PanelKey.AdvancedPanel] = OpsNewbieStrategyDefine.ActivityID.AdvancedActivityID,
}

---@class OpsNewbieStrategyPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AdvancedPanel OpsNewbieStrategyAdvancedPanelView
---@field BtnAwards UFButton
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field FirstChoicePanel OpsNewbieStrategyFirstChoicePanelView
---@field InforBtn CommInforBtnView
---@field PanelAwardsAvailable UFCanvasPanel
---@field PanelReceive UFCanvasPanel
---@field ProBar UFProgressBar
---@field RecommendPanel OpsNewbieStrategyRecommendPanelView
---@field RedDot CommonRedDotView
---@field TableViewTab UTableView
---@field TextAwards UFTextBlock
---@field TextQuantity2 UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimAwardsAvailableLoop UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimProBar UWidgetAnimation
---@field AnimTableViewTabSelectionChanged UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewbieStrategyPanelView = LuaClass(UIView, true)

function OpsNewbieStrategyPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AdvancedPanel = nil
	--self.BtnAwards = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.FirstChoicePanel = nil
	--self.InforBtn = nil
	--self.PanelAwardsAvailable = nil
	--self.PanelReceive = nil
	--self.ProBar = nil
	--self.RecommendPanel = nil
	--self.RedDot = nil
	--self.TableViewTab = nil
	--self.TextAwards = nil
	--self.TextQuantity2 = nil
	--self.TextTitle = nil
	--self.AnimAwardsAvailableLoop = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimProBar = nil
	--self.AnimTableViewTabSelectionChanged = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AdvancedPanel)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.FirstChoicePanel)
	self:AddSubView(self.InforBtn)
	self:AddSubView(self.RecommendPanel)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyPanelView:OnInit()
	OpsNewbieStrategyMgr = _G.OpsNewbieStrategyMgr
	RedDotMgr = _G.RedDotMgr
	self.TableViewMenuAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnMenuSelectChanged)
	self.Binders = {
		{ "MenuList", UIBinderUpdateBindableList.New(self, self.TableViewMenuAdapter) },
		--{ "CurSelectedMenuItem",UIBinderSetSelectedItem.New(self, self.TableViewMenuAdapter) },
		{ "bFirstChoicePanel", UIBinderSetIsVisible.New(self, self.FirstChoicePanel) },
		{ "bRecommendPanel", UIBinderSetIsVisible.New(self, self.RecommendPanel) },
		{ "bAdvancedPanel", UIBinderSetIsVisible.New(self, self.AdvancedPanel) },
		{ "Name", UIBinderSetText.New(self, self.TextTitle)},
		{ "BraveryAwardProBar", UIBinderSetPercent.New(self, self.ProBar) },
		{ "BraveryAwardNumText", UIBinderSetText.New(self, self.TextQuantity2)},
		{ "IsHaveGiveBraveryReward", UIBinderValueChangedCallback.New(self, nil, self.OnIsHaveGiveBraveryRewardChange)},
		{ "IsBraveryRewardFinished", UIBinderSetIsVisible.New(self, self.PanelReceive)},
	}
	---领奖界面/新人攻略本身的弹窗/通用tips，减少无效刷新/虽然添加了节点变化推送，但是是用于处理红点的，只有完成状态变化才下发，依然保留此逻辑
	self.ShieldUIList = 
	{
		_G.UIViewID.OpsNewbieStrategyLightofEtherWinView,
	 	_G.UIViewID.OpsNewBieStrategyCommListWinView,
		_G.UIViewID.OpsNewbieStrategyBraveryAwardWinView,
		_G.UIViewID.OpsNewbieStrategyHintWinView,
	 	_G.UIViewID.CommonRewardPanel,
		_G.UIViewID.ItemTips,
		_G.UIViewID.CurrencyTips,
		_G.UIViewID.CommHelpInfoTitleTipsView,
		_G.UIViewID.SidePopUpEasyUse,
	}
	self.InforBtn:SetCheckClickedCallback(self, self.OnInforBtnClicked)
end

function OpsNewbieStrategyPanelView:OnDestroy()

end

function OpsNewbieStrategyPanelView:OnShow()
	-- LSTR string:勇气嘉奖
	self.TextAwards:SetText(LSTR(920032))
	OpsNewbieStrategyPanelVM:MenuUpdata()
	if self.Params and OpsNewbieStrategyPanelVM then
		OpsNewbieStrategyPanelVM:UpdateOpsNewbieStrategyInfoByOpen(self.Params)
		local Index = OpsNewbieStrategyPanelVM:GetOpenMenuIndex()
		---点击同一个活动中心页签时，会先触发onshow,再触发onhide,在这里清理数据，不在hide清理
		self.TableViewMenuAdapter:CancelSelected()
		self:ClearData()
		OpsNewbieStrategyPanelVM:SetAdvancedIsUnLock()
		self.TableViewMenuAdapter:SetSelectedIndex(Index)
	end
	---勇气嘉奖红点设置
	local BraveryRewardRedName = OpsNewbieStrategyMgr:GetRedDotNameByActivityID(OpsNewbieStrategyDefine.ActivityID.BraveryAwardActivityID)
	self.RedDot:SetRedDotNameByString(BraveryRewardRedName)
end

function OpsNewbieStrategyPanelView:OnHide()
	---清理页签选中
	-- self.TableViewMenuAdapter:CancelSelected()
	-- self:ClearData()
	---界面隐藏时，防止报错导致领奖未打开，没有解除物品飘字屏蔽
	_G.LootMgr:SetDealyState(false)
	---界面隐藏时，把二级跳转也隐藏，防止显示bug
	_G.UIViewMgr:HideView(_G.UIViewID.OpsNewBieStrategyCommListWinView)
end

function OpsNewbieStrategyPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnAwards, self.OnBtnAwardsClicked)
end

function OpsNewbieStrategyPanelView:OnRegisterGameEvent()
    -- 活动中心数据更新
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdate, self.OnOpsActivityUpdate)
	-- 从其他界面退回需要更新数据
	self:RegisterGameEvent(_G.EventID.HideUI, self.OnOtherUIHideUI)
	--self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.OnOpsActivityUpdate)
end

function OpsNewbieStrategyPanelView:OnOpsActivityUpdate()
	if self.Params and OpsNewbieStrategyPanelVM then
		OpsNewbieStrategyPanelVM:UpdateOpsNewbieStrategyInfo(self.Params)
	end
end

function OpsNewbieStrategyPanelView:OnRegisterBinder()
	self:RegisterBinders(OpsNewbieStrategyPanelVM, self.Binders)
end

---页签点击处理
function OpsNewbieStrategyPanelView:OnMenuSelectChanged(Index, ItemData, ItemView)
	if ItemData then
		self:SwitchMenu(ItemData.Key)
		local ActivityID = MenuActivityIDMap[ItemData.Key]
		if ActivityID then
			DataReportUtil.ReportActivityClickFlowData(ActivityID ,ItemData.Key)
		end
	end
end

function OpsNewbieStrategyPanelView:SwitchMenu(Index)
	if OpsNewbieStrategyPanelVM then
		OpsNewbieStrategyPanelVM:SetSelectedMenuItem(Index)
	end
end

---隐藏时清理UI数据
function OpsNewbieStrategyPanelView:ClearData()
	if OpsNewbieStrategyPanelVM then
		OpsNewbieStrategyPanelVM:ClearUIData()
	end
end

function OpsNewbieStrategyPanelView:OnBtnAwardsClicked()
	OpsNewbieStrategyMgr:OpenBraveryAwardPanel()
	DataReportUtil.ReportActivityClickFlowData(OpsNewbieStrategyDefine.ActivityID.BraveryAwardActivityID ,OpsNewbieStrategyDefine.OperationPageActionType.BraveryAwardActivity)
end

function OpsNewbieStrategyPanelView:OnOtherUIHideUI(UIViewID)
	---从其他界面回来需要刷新一遍数据
	---屏蔽一下领奖界面/新人攻略本身的弹窗/通用tips，减少无效刷新
	if self.ShieldUIList then
		for _, ShieldUIViewID in ipairs(self.ShieldUIList) do
			if UIViewID == ShieldUIViewID then
				return
			end
		end
	end
	_G.OpsActivityMgr:SendQueryActivityList()
end

---信息按钮点击，数据埋点上传
function OpsNewbieStrategyPanelView:OnInforBtnClicked()
	local ActivityID
	local PanelKey = OpsNewbieStrategyPanelVM:GetSelectedMenuKey()
	if PanelKey and PanelKey ~= 0 then
		ActivityID = MenuActivityIDMap[PanelKey]
	end
	if ActivityID then
		DataReportUtil.ReportActivityClickFlowData(ActivityID ,OpsNewbieStrategyDefine.OperationPageActionType.InfoBtnCkicked)
	end
end

---可领取动画处理
function OpsNewbieStrategyPanelView:OnIsHaveGiveBraveryRewardChange(IsHaveGiveBraveryReward)
	UIUtil.SetIsVisible(self.PanelAwardsAvailable, IsHaveGiveBraveryReward)
	if IsHaveGiveBraveryReward then
		self:PlayAnimation(self.AnimAwardsAvailableLoop, 0, 0)
	else
		local EndTime = self.AnimAwardsAvailableLoop:GetEndTime()
		--重新设置播放模式
		self:PlayAnimation(self.AnimAwardsAvailableLoop, 0, 1)
		--重新设置播放起始时间
		self:PlayAnimationTimeRangeToEndTime(self.AnimAwardsAvailableLoop, EndTime)
	end
end


return OpsNewbieStrategyPanelView