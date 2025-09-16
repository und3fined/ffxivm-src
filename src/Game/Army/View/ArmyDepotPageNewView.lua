---
--- Author: Administrator
--- DateTime: 2023-12-04 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ProtoRes = require("Protocol/ProtoRes")
local GroupPermissionType = ProtoRes.GroupGlobalConfigType
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")

local ArmyMgr = nil
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local ArmyDepotPanelVM = nil
local ArmyDepotPageVM = nil
---@class ArmyDepotPageNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagDepotListPage ArmyDepotListPageView
---@field BtnRename UFButton
---@field BtnTakeOut CommBtnSView
---@field ButtonName UFButton
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field CommonRedDot_UIBP CommonRedDotView
---@field ImgIcon UFImage
---@field PanelBagName UFCanvasPanel
---@field TableViewItem UTableView
---@field TextCurrency UFTextBlock
---@field TextName URichTextBox
---@field AnimBagDepotListIn UWidgetAnimation
---@field AnimBagDepotListOut UWidgetAnimation
---@field AnimDepositCoin UWidgetAnimation
---@field AnimDepositCoinTakeOut UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimSwitchDepot UWidgetAnimation
---@field ValueAnimDepositCoin float
---@field CurveAnimDepositCoin CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyDepotPageNewView = LuaClass(UIView, true)

function ArmyDepotPageNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagDepotListPage = nil
	--self.BtnRename = nil
	--self.BtnTakeOut = nil
	--self.ButtonName = nil
	--self.CommSidebarFrameS_UIBP = nil
	--self.CommonRedDot_UIBP = nil
	--self.ImgIcon = nil
	--self.PanelBagName = nil
	--self.TableViewItem = nil
	--self.TextCurrency = nil
	--self.TextName = nil
	--self.AnimBagDepotListIn = nil
	--self.AnimBagDepotListOut = nil
	--self.AnimDepositCoin = nil
	--self.AnimDepositCoinTakeOut = nil
	--self.AnimIn = nil
	--self.AnimSwitchDepot = nil
	--self.ValueAnimDepositCoin = nil
	--self.CurveAnimDepositCoin = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyDepotPageNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagDepotListPage)
	self:AddSubView(self.BtnTakeOut)
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	self:AddSubView(self.CommonRedDot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyDepotPageNewView:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	ArmyDepotPanelVM = ArmyMainVM:GetDepotPanelVM()
	ArmyDepotPageVM = ArmyDepotPanelVM:GetDepotPageVM()
	self.CommSidebarFrameS_UIBP:AddBackClick(self, self.OnClickedBtnBack)
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewItem)
	self.AnimNumList = {}
	self.AnimWaitPlayCount = 0 
	self.Binders = {
		{ "CapacityText", UIBinderSetText.New(self, self.TextCapacity) },
		{ "BindableListPage", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{ "PageName", UIBinderSetText.New(self, self.TextName) },
		{ "PageIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IconColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgIcon) },
		{ "DepotListVisible", UIBinderValueChangedCallback.New(self, nil, self.OnDepotListVisibleChanged) },
		{ "CurrentPage", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedPage) },
		{ "NumPercent", UIBinderSetPercent.New(self, self.ImgBagNotFull) },
		{ "TotalMoneyNumStr", UIBinderSetText.New(self, self.TextCurrency) },
		{ "IsGoldAnimPlay", UIBinderValueChangedCallback.New(self, nil, self.OnGoldAnimPlay) },
		{ "IsGoldDepotPerm", UIBinderValueChangedCallback.New(self, nil, self.OnBtnTakeOutStateChange) },
	}
end

function ArmyDepotPageNewView:OnDestroy()

end

function ArmyDepotPageNewView:OnShow()
	-- LSTR string:部队储物柜
	self.CommSidebarFrameS_UIBP:SetTitleText(LSTR(910249))
	ArmyDepotPageVM:DepotListInit()
	ArmyMgr:SendGroupStoreReqStoreInfo(ArmyDepotPageVM:GetCurDepotIndex())
	ArmyDepotPageVM:UpdateTotalMoneyNumStr()
	-- LSTR string:存取金币
	self.BtnTakeOut:SetText(LSTR(910097))
end

function ArmyDepotPageNewView:OnHide()
	--UIUtil.SetIsVisible(self.BagDepotListPage, false)
	ArmyDepotPageVM:SetDepotListVisible(false)
	self.AnimNumList = {}
	self.IsGoldAnimPlaying = false
	self.AnimWaitPlayCount = 0
	self:UnRegisterAllTimer()
end

function ArmyDepotPageNewView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonName, self.OnClickedExpand)
	UIUtil.AddOnClickedEvent(self, self.BtnRename, self.OnClickedRename)
	UIUtil.AddOnClickedEvent(self, self.BtnTakeOut, self.OnClickedTakeOut)

end

function ArmyDepotPageNewView:OnRegisterGameEvent()

end

function ArmyDepotPageNewView:OnRegisterBinder()
	self:RegisterBinders(ArmyDepotPageVM, self.Binders)
end

function ArmyDepotPageNewView:OnClickedBtnBack()
    UIViewMgr:HideView(UIViewID.ArmyDepotPanel)
	if not self.IsOuterOpen then
		ArmyMgr:OpenArmyMainPanel()
	end
end

function ArmyDepotPageNewView:OnClickedExpand()
	ArmyDepotPageVM:SetDepotListVisible(not ArmyDepotPageVM:GetDepotListVisible())
end

function ArmyDepotPageNewView:OnClickedRename()
	if ArmyDepotPanelVM:GetIsAllowedRename() then
		UIViewMgr:ShowView(UIViewID.ArmyDepotRename)
		ArmyDepotPageVM:SetDepotListVisible(false)
	else
		-- LSTR string:没有仓库命名权限
		MsgTipsUtil.ShowTips(LSTR(910170))
	end
end

function ArmyDepotPageNewView:OnValueChangedPage(Value)
	self.TableViewItem:SetScrollOffset(Value - 1)
	self:PlayAnimation(self.AnimSwitchDepot)
end

function ArmyDepotPageNewView:OnDepotListVisibleChanged(DepotListVisible)
	if DepotListVisible then
		UIUtil.SetIsVisible(self.BagDepotListPage, true)
		if self.AnimHideTimer then
			self:UnRegisterTimer(self.AnimHideTimer)
		end
		self:PlayAnimation(self.AnimBagDepotListIn)
	else
		if nil == self.AnimBagDepotListOut then
			UIUtil.SetIsVisible(self.BagDepotListPage, false)
			return
		end
		self:PlayAnimation(self.AnimBagDepotListOut)
		-- 计时器回调方式执行隐藏
		local function AnimCallback()
			UIUtil.SetIsVisible(self.BagDepotListPage, false)
		end
		self.AnimHideTimer = self:RegisterTimer(AnimCallback, self.AnimBagDepotListOut:GetEndTime() + 0.01)
		if ArmyMgr:IsExistCancelStoreRedDot() then
			ArmyMgr:SendDelStoreRedDot()
		end
	end
end

function ArmyDepotPageNewView:OnClickedExpansion()
	local EnlargeCfg = GroupGlobalCfg:FindCfgByKey(GroupPermissionType.GGCT_GROUP_STORE_EXTRA_GRID_NUM)
	local StoreID = ArmyDepotPageVM:GetCurDepotIndex()
	local ExpansionNum = ArmyMgr:GetStoreExpansionNum(StoreID) or 0
	-- 背包扩容已达到上限
	if ExpansionNum and ExpansionNum >= EnlargeCfg.Value[1] then
		-- LSTR string:部队仓库扩容次数已达到上限
		MsgTipsUtil.ShowErrorTips(LSTR(910247), 1)
		return
	end

	UIViewMgr:ShowView(UIViewID.ArmyExpandWin, {EnlargeID = ExpansionNum + 1, StoreID = StoreID})
end

function ArmyDepotPageNewView:OnClickedTakeOut()
	local IsGoldDepotPerm = ArmyDepotPageVM:GetIsGoldDepotPerm()
	if IsGoldDepotPerm then
		local Params = {
			TotalNum = ArmyDepotPageVM:GetArmyMoneyStoreNum(),
		}
		UIViewMgr:ShowView(UIViewID.ArmyDepotMoneyWin, Params)
	else
		-- LSTR string:暂无权限，请联系管理者
		MsgTipsUtil.ShowTips(LSTR(910155))
	end

end

function ArmyDepotPageNewView:OnGoldAnimPlay(IsGoldAnimPlay)
	if IsGoldAnimPlay then
		local AnimNum = {}
		AnimNum.OldNum =  ArmyDepotPageVM:GetOldTotalNum()
		AnimNum.Num = ArmyDepotPageVM:GetArmyMoneyStoreNum()
		table.insert(self.AnimNumList, AnimNum)
		self:RegisterTimer(self.GoldAnimPlay, 1.5, 0)
		ArmyDepotPageVM:SetIsGoldAnimPlay(false)
	end
end

function ArmyDepotPageNewView:GoldAnimPlay()
	if self.AnimNumList and self.AnimNumList[1] then
		local IsTakeOut = self.AnimNumList[1].Num < self.AnimNumList[1].OldNum
		if not self.IsGoldAnimPlaying then
			if IsTakeOut then
				self:PlayAnimation(self.AnimDepositCoinTakeOut)
			else
				self:PlayAnimation(self.AnimDepositCoin)
			end
			self.IsGoldAnimPlaying = true
		else
			self.AnimWaitPlayCount = self.AnimWaitPlayCount + 1
		end
	end
end

function ArmyDepotPageNewView:OnAnimationFinished(Animation)
	if Animation == self.AnimDepositCoin or Animation == self.AnimDepositCoinTakeOut then
		self.IsGoldAnimPlaying = false
		if self.AnimNumList and self.AnimNumList[1] then
			--- 浮点数有精度误差，动画结束时修正一下
			table.remove(self.AnimNumList, 1)
		end
		if self.AnimWaitPlayCount > 0 then
			self.AnimWaitPlayCount = self.AnimWaitPlayCount - 1
			self:GoldAnimPlay()
		end
	end
end

function ArmyDepotPageNewView:SequenceEvent_AnimDepositCoin()
	if self.AnimNumList and self.AnimNumList[1] then
		local IsTakeOut = self.AnimNumList[1].Num < self.AnimNumList[1].OldNum
		if IsTakeOut then
			self:GetValueAnimDepositCoinTakeOut()
		else
			self:GetValueAnimDepositCoin()
		end
		---在结束动画修正精度误差，表现延迟太明显，在动画中修正
		local AnimVlaue = 0
		if self.ValueAnimDepositCoin > 0.999 then
			AnimVlaue = 1
		else
			AnimVlaue = self.ValueAnimDepositCoin
		end
		ArmyDepotPageVM:SetTotalMoneyNumStrByAminVlaue(AnimVlaue, self.AnimNumList[1])
	end
end

function ArmyDepotPageNewView:OnBtnTakeOutStateChange(IsGoldDepotPerm)
	self.BtnTakeOut:SetIsDisabledState(not IsGoldDepotPerm, true)
	if not IsGoldDepotPerm then
		if UIViewMgr:FindView(UIViewID.ArmyDepotMoneyWin) then
			UIViewMgr:HideView(UIViewID.ArmyDepotMoneyWin)
			-- LSTR string:暂无权限，请联系管理者
			MsgTipsUtil.ShowTips(LSTR(910155))
		end
	end
end

return ArmyDepotPageNewView

