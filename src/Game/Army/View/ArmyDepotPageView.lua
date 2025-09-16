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
---@class ArmyDepotPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagDepotListPage ArmyDepotListPageView
---@field BtnBack CommBackBtnView
---@field BtnRename UFButton
---@field BtnTakeOut CommBtnSView
---@field ButtonName UFButton
---@field CommonRedDot_UIBP CommonRedDotView
---@field ImgDepotBg UFImage
---@field ImgIcon UFImage
---@field PanelBagName UFCanvasPanel
---@field TableViewItem UTableView
---@field TextCurrency UFTextBlock
---@field TextDepotName UFTextBlock
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
local ArmyDepotPageView = LuaClass(UIView, true)

function ArmyDepotPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagDepotListPage = nil
	--self.BtnBack = nil
	--self.BtnRename = nil
	--self.BtnTakeOut = nil
	--self.ButtonName = nil
	--self.CommonRedDot_UIBP = nil
	--self.ImgDepotBg = nil
	--self.ImgIcon = nil
	--self.PanelBagName = nil
	--self.TableViewItem = nil
	--self.TextCurrency = nil
	--self.TextDepotName = nil
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

function ArmyDepotPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagDepotListPage)
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnTakeOut)
	self:AddSubView(self.CommonRedDot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyDepotPageView:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	ArmyDepotPanelVM = ArmyMainVM:GetDepotPanelVM()
	ArmyDepotPageVM = ArmyDepotPanelVM:GetDepotPageVM()
	self.BtnBack:AddBackClick(self, self.OnClickedBtnBack)
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewItem)
	self.AnimNumList = {}
	self.AnimWaitPlayCount = 0 
	self.Binders = {
		{ "CapacityText", UIBinderSetText.New(self, self.TextCapacity) },
		{ "BindableListPage", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{ "PageName", UIBinderSetText.New(self, self.TextName) },
		{ "PageIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IconColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgIcon) },
		--{ "DepotListVisible", UIBinderSetIsVisible.New(self, self.BagDepotListPage) },
		{ "DepotListVisible", UIBinderValueChangedCallback.New(self, nil, self.OnDepotListVisibleChanged) },
		{ "CurrentPage", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedPage) },
		--{ "NumState", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedNumState) },
		{ "NumPercent", UIBinderSetPercent.New(self, self.ImgBagNotFull) },
		{ "TotalMoneyNumStr", UIBinderSetText.New(self, self.TextCurrency) },
		{ "IsGoldAnimPlay", UIBinderValueChangedCallback.New(self, nil, self.OnGoldAnimPlay) },
		{ "IsGoldDepotPerm", UIBinderValueChangedCallback.New(self, nil, self.OnBtnTakeOutStateChange) },
	}
end

function ArmyDepotPageView:OnDestroy()

end

function ArmyDepotPageView:OnShow()
	-- LSTR string:储物柜
	self.TextDepotName:SetText(LSTR(910051))
	ArmyDepotPageVM:DepotListInit()
	ArmyMgr:SendGroupStoreReqStoreInfo(ArmyDepotPageVM:GetCurDepotIndex())
	ArmyDepotPageVM:UpdateTotalMoneyNumStr()
	-- LSTR string:存取金币
	self.BtnTakeOut:SetText(LSTR(910097))
end

function ArmyDepotPageView:OnHide()
	--UIUtil.SetIsVisible(self.BagDepotListPage, false)
	ArmyDepotPageVM:SetDepotListVisible(false)
	self.AnimNumList = {}
	self.IsGoldAnimPlaying = false
	self.AnimWaitPlayCount = 0
	self:UnRegisterAllTimer()
end

function ArmyDepotPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonName, self.OnClickedExpand)
	UIUtil.AddOnClickedEvent(self, self.BtnRename, self.OnClickedRename)
	UIUtil.AddOnClickedEvent(self, self.BtnTakeOut, self.OnClickedTakeOut)

end

function ArmyDepotPageView:OnRegisterGameEvent()

end

function ArmyDepotPageView:OnRegisterBinder()
	self:RegisterBinders(ArmyDepotPageVM, self.Binders)
end

function ArmyDepotPageView:OnClickedBtnBack()
    UIViewMgr:HideView(UIViewID.ArmyDepotPanel)
	if not self.IsOuterOpen then
		ArmyMgr:OpenArmyMainPanel()
	end
end

function ArmyDepotPageView:OnClickedExpand()
	ArmyDepotPageVM:SetDepotListVisible(not ArmyDepotPageVM:GetDepotListVisible())
end

function ArmyDepotPageView:OnClickedRename()
	if ArmyDepotPanelVM:GetIsAllowedRename() then
		UIViewMgr:ShowView(UIViewID.ArmyDepotRename)
		ArmyDepotPageVM:SetDepotListVisible(false)
	else
		-- LSTR string:没有仓库命名权限
		MsgTipsUtil.ShowTips(LSTR(910170))
	end
end

function ArmyDepotPageView:OnValueChangedPage(Value)
	self.TableViewItem:SetScrollOffset(Value - 1)
	self:PlayAnimation(self.AnimSwitchDepot)
end

function ArmyDepotPageView:OnValueChangedNumState(Value)
	-- if Value == ArmyDefine.DepotNumState.Empty then
	-- 	UIUtil.SetIsVisible(self.ImgBagEmpty, true)
	-- 	UIUtil.SetIsVisible(self.ImgBagNotFull, false)
	-- 	UIUtil.SetIsVisible(self.ImgBagFull, false)
	-- elseif Value == ArmyDefine.DepotNumState.NotFull then
	-- 	UIUtil.SetIsVisible(self.ImgBagEmpty, true)
	-- 	UIUtil.SetIsVisible(self.ImgBagNotFull, true)
	-- 	UIUtil.SetIsVisible(self.ImgBagFull, false)
	-- elseif Value == ArmyDefine.DepotNumState.Full then
	-- 	UIUtil.SetIsVisible(self.ImgBagEmpty, false)
	-- 	UIUtil.SetIsVisible(self.ImgBagNotFull, false)
	-- 	UIUtil.SetIsVisible(self.ImgBagFull, true)
	-- end
end

function ArmyDepotPageView:OnDepotListVisibleChanged(DepotListVisible)
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

function ArmyDepotPageView:OnClickedExpansion()
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

function ArmyDepotPageView:OnClickedTakeOut()
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

function ArmyDepotPageView:OnGoldAnimPlay(IsGoldAnimPlay)
	if IsGoldAnimPlay then
		local AnimNum = {}
		AnimNum.OldNum =  ArmyDepotPageVM:GetOldTotalNum()
		AnimNum.Num = ArmyDepotPageVM:GetArmyMoneyStoreNum()
		table.insert(self.AnimNumList, AnimNum)
		self:RegisterTimer(self.GoldAnimPlay, 1.5, 0)
		ArmyDepotPageVM:SetIsGoldAnimPlay(false)
	end
end

function ArmyDepotPageView:GoldAnimPlay()
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

function ArmyDepotPageView:OnAnimationFinished(Animation)
	if Animation == self.AnimDepositCoin or Animation == self.AnimDepositCoinTakeOut then
		self.IsGoldAnimPlaying = false
		if self.AnimNumList and self.AnimNumList[1] then
			--- 浮点数有精度误差，动画结束时修正一下
			--ArmyDepotPageVM:SetTotalMoneyNumStrByNum(self.AnimNumList[1].Num)
			table.remove(self.AnimNumList, 1)
		end
		if self.AnimWaitPlayCount > 0 then
			self.AnimWaitPlayCount = self.AnimWaitPlayCount - 1
			self:GoldAnimPlay()
		end
	end
end

function ArmyDepotPageView:SequenceEvent_AnimDepositCoin()
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

function ArmyDepotPageView:OnBtnTakeOutStateChange(IsGoldDepotPerm)
	self.BtnTakeOut:SetIsDisabledState(not IsGoldDepotPerm, true)
	if not IsGoldDepotPerm then
		if UIViewMgr:FindView(UIViewID.ArmyDepotMoneyWin) then
			UIViewMgr:HideView(UIViewID.ArmyDepotMoneyWin)
			-- LSTR string:暂无权限，请联系管理者
			MsgTipsUtil.ShowTips(LSTR(910155))
		end
	end
end

return ArmyDepotPageView

