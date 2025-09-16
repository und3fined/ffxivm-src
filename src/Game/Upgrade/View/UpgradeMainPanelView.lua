---
--- Author: yutingzhan
--- DateTime: 2025-03-10 15:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UpgradeMainVM = require("Game/Upgrade/VM/UpgradeMainVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemUtil = require("Utils/ItemUtil")
local SaveKey = require("Define/SaveKey")
local DirectUpgradeCfg = require("TableCfg/DirectUpgradeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local LocalizationUtil = require("Utils/LocalizationUtil")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")

local LSTR = _G.LSTR
local USaveMgr = _G.UE.USaveMgr
local UpgradeMgr = _G.UpgradeMgr

---@class UpgradeMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnUpgrade CommBtnXLView
---@field CloseBtn CommonCloseBtnView
---@field CommInforBtn_UIBP CommInforBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field IconTime UFImage
---@field ImgJob UFImage
---@field ImgSpent UFImage
---@field Job1 UpgradeJobItemView
---@field Job2 UpgradeJobItemView
---@field PanelConsumption UFHorizontalBox
---@field PanelTime1 UFCanvasPanel
---@field TableViewList UTableView
---@field TableViewTab UTableView
---@field TextConsumption UFTextBlock
---@field TextJobLock UFTextBlock
---@field TextListTitle UFTextBlock
---@field TextPoper UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local UpgradeMainPanelView = LuaClass(UIView, true)
function UpgradeMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnUpgrade = nil
	--self.CloseBtn = nil
	--self.CommInforBtn_UIBP = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.IconTime = nil
	--self.ImgJob = nil
	--self.ImgSpent = nil
	--self.Job1 = nil
	--self.Job2 = nil
	--self.PanelConsumption = nil
	--self.PanelTime1 = nil
	--self.TableViewList = nil
	--self.TableViewTab = nil
	--self.TextConsumption = nil
	--self.TextJobLock = nil
	--self.TextListTitle = nil
	--self.TextPoper = nil
	--self.TextQuantity = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function UpgradeMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnUpgrade)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommInforBtn_UIBP)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.Job1)
	self:AddSubView(self.Job2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function UpgradeMainPanelView:OnInit()
	self.TextJobLock:SetText(LSTR(990114))
	self.TextTitle:SetText(LSTR(990115))	
	self.BtnUpgrade:SetText(LSTR(990115))
	self.TextListTitle:SetText(LSTR(990116))
	self.TextPoper:SetText(LSTR(990117))
	self.ViewModel = UpgradeMainVM.New()
	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.TextTime, nil, nil, self.TimeOutCallback, self.TimeUpdateCallback)
	self.TableViewTabAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnClickTabMember)
	self.TableViewListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.Binders = {
		{"TextJob1", UIBinderSetText.New(self, self.Job1.TextJob)},
		{"IconJob1", UIBinderSetImageBrush.New(self, self.Job1.IconJob)},
		{"TextLevel1", UIBinderSetText.New(self, self.Job1.TextLevel)},
		{"TextJob2", UIBinderSetText.New(self, self.Job2.TextJob)},
		{"IconJob2", UIBinderSetImageBrush.New(self, self.Job2.IconJob)},
		{"TextLevel2", UIBinderSetText.New(self, self.Job2.TextLevel)},
		{"ImgJob", UIBinderSetImageBrush.New(self, self.ImgJob)},
		{"IsTextLockVisiable", UIBinderSetIsVisible.New(self, self.TextJobLock)},
        {"TabVMList", UIBinderUpdateBindableList.New(self, self.TableViewTabAdapter)},
		{"TaskVMList", UIBinderUpdateBindableList.New(self, self.TableViewListAdapter)},
	}
end

function UpgradeMainPanelView:OnDestroy()

end

function UpgradeMainPanelView:OnShow()
	if self.Params == nil then
		return
	end
	self.CommInforBtn_UIBP.HelpInfoID = 11127
	self.ViewModel:Update(self.Params)
	self.AdapterCountDownTime:Start(self.ViewModel.EndTimeStamp, 1, true, false)
	self.TableViewTabAdapter:SetSelectedIndex(self.ViewModel.CurrentSelectDay)
end

function UpgradeMainPanelView:OnHide()

end

function UpgradeMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnUpgrade, self.OnClickBtnUpgrade)
end

function UpgradeMainPanelView:OnRegisterGameEvent()

end

function UpgradeMainPanelView:OnClickBtnUpgrade()
	local SelectedIndex = self.TableViewTabAdapter:GetSelectedIndex()
	if SelectedIndex < self.ViewModel.CurrentSelectDay then
		MsgTipsUtil.ShowTips(LSTR(990118))
	elseif self.ViewModel.IsUpgradeEnd then
		MsgTipsUtil.ShowTipsByID(352004)	--光之直升活动已结束
	elseif not self.ViewModel.IsCanUpgrade then
		MsgTipsUtil.ShowTipsByID(352003)	--不是直升使用的初始职业或对应转职后的特职
	elseif self.ViewModel.IsFinishAllTask then
		MsgTipsUtil.ShowTipsByID(352006)	--已完成所有当前可执行的主线任务和特职任务
	else
		if self.ViewModel.IsTextLockVisiable then
			self:SendUpgrade()
		else
			USaveMgr.SetInt(SaveKey.ShowDirectUpgradePopUp, 1, true)
			local Msg = string.format(LSTR(990119), self.ViewModel.TextJob1, self.ViewModel.TextJob1)
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(990120), Msg, self.SendUpgrade)
		end
	end
end

function UpgradeMainPanelView:SendUpgrade()
	_G.UpgradeMgr.UpgradeUseProf = self.Params.Prof
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.BagMain) then
		_G.UIViewMgr:HideView(_G.UIViewID.BagMain)
	end
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.UpgradeMainPanelView) then
		_G.UIViewMgr:HideView(_G.UIViewID.UpgradeMainPanelView)
	end
	local function CallBack()
		_G.UpgradeMgr.IsLevelUpgrade = false
		UpgradeMgr:SendUpgrade(_G.UpgradeMgr.UpgradeUseProf)
		_G.UpgradeMgr.UpgradeUseProf = nil
	end
	local CostItemIDCfg = DirectUpgradeCfg:FindCfgByKey(ProtoRes.DirectUpgradeCfgID.DirectUpgradeCfgIDDialogID)
	if CostItemIDCfg ~= nil then
		local DialogLibID = CostItemIDCfg.Value
		_G.NpcDialogMgr:PlayDialogLib(DialogLibID, nil, nil, CallBack)
	end
end

function UpgradeMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function UpgradeMainPanelView:OnClickTabMember(Index, ItemData, ItemView)
	if Index > self.ViewModel.CurrentSelectDay then
		MsgTipsUtil.ShowTips(string.format(LSTR(990121),ItemData.TextTime))
		self.TableViewTabAdapter:SetSelectedIndex(self.SelectedIndex)
		return
	end
	self.SelectedIndex = Index
	self.ViewModel:SetTaskInfo(Index)
	if Index < self.ViewModel.CurrentSelectDay then
		self.ViewModel.TextJob2 = self.ViewModel.BeforeDayTextJob2
		self.ViewModel.TextLevel2 = self.ViewModel.BeforeDayTextLevel2
		self.ViewModel.IconJob2 = self.ViewModel.BeforeDayIconJob2
		UIUtil.SetIsVisible(self.PanelConsumption, false)
		self.BtnUpgrade:SetIsDisabledState(true, true)
	else
		self.ViewModel.TextJob2 = self.ViewModel.CurDayTextJob2
		self.ViewModel.TextLevel2 = self.ViewModel.CurDayTextLevel2
		self.ViewModel.IconJob2 = self.ViewModel.CurDayIconJob2
		UIUtil.SetIsVisible(self.PanelConsumption, true)
		if self.ViewModel.IsUpgradeEnd or not self.ViewModel.IsCanUpgrade then
			self.BtnUpgrade:SetIsDisabledState(true, true)
		else
			if self.ViewModel.IsFinishAllTask then
				self.BtnUpgrade:SetIsDisabledState(true, true)
			else
				self.BtnUpgrade:SetIsRecommendState(true)
			end
		end
		if self.ViewModel.QuestCostData[Index].IsCostItem > 0 then
			UIUtil.SetIsVisible(self.ImgSpent, true)
			UIUtil.SetIsVisible(self.TextQuantity, true)
			self.TextConsumption:SetText(LSTR(990122))
			self.TextQuantity:SetText("1/1")
			local Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(self.ViewModel.ItemID))
			UIUtil.ImageSetBrushFromAssetPath(self.ImgSpent, Icon)
		else
			self.TextConsumption:SetText(LSTR(990123))
			UIUtil.SetIsVisible(self.ImgSpent, false)
			UIUtil.SetIsVisible(self.TextQuantity, false)
		end
	end
end

function UpgradeMainPanelView:TimeOutCallback()
	self.BtnUpgrade:SetIsDisabledState(true, true)
	self.ViewModel.IsUpgradeEnd = true
	self.TextTime:SetText(_G.LSTR(970002))
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.UpgradeMainPanelView) then
		_G.UIViewMgr:HideView(_G.UIViewID.UpgradeMainPanelView)
	end
end

function UpgradeMainPanelView:TimeUpdateCallback(LeftTime)
	return LocalizationUtil.GetCountdownTimeForLongTime(LeftTime, "")
end

return UpgradeMainPanelView