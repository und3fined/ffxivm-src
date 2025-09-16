---
--- Author: enqingchen
--- DateTime: 2021-12-27 15:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIAdapterToggleGroup = require("UI/Adapter/UIAdapterToggleGroup")
local ItemGetaccesstypeCfg = require("TableCfg/ItemGetaccesstypeCfg")

local TipsUtil = require("Utils/TipsUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local EquipmentListPageVM = require("Game/Equipment/VM/EquipmentListPageVM")

---@class EquipmentListPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Filter CommDropDownListView
---@field Icon_PartPic UFImage
---@field NoReplace UFCanvasPanel
---@field TableView UTableView
---@field Text_Amount UFTextBlock
---@field Text_PartName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentListPageView = LuaClass(UIView, true)

function EquipmentListPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Filter = nil
	--self.Icon_PartPic = nil
	--self.NoReplace = nil
	--self.TableView = nil
	--self.Text_Amount = nil
	--self.Text_PartName = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentListPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Filter)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentListPageView:OnInit()
	self.ViewModel = EquipmentListPageVM.New()
	self.EquipmentsTableView = UIAdapterTableView.CreateAdapter(self, self.TableView, self.OnEquipmentSelectChange, false)
	self.EquipmentsTableView:SetScrollbarIsVisible(false)

	self.bFilterShow = false
end

function EquipmentListPageView:OnDestroy()

end

function EquipmentListPageView:OnShow()
	self.Text_None:SetText(LSTR(1050166))
	self.RichTextGo:SetText(LSTR(1050167))
end

function EquipmentListPageView:OnHide()

end

function EquipmentListPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.GoBtn, self.OnHyperlinkClicked)
	UIUtil.AddOnSelectionChangedEvent(self, self.Filter, self.OnSelectionChangedFilter, nil)
end

function EquipmentListPageView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.EquipRepairSucc, self.OnEquipRepairSucc)
end

function EquipmentListPageView:OnRegisterBinder()
	local Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.Icon_PartPic) },
		{ "PartName", UIBinderSetText.New(self, self.Text_PartName) },
		{ "PartCount", UIBinderSetTextFormat.New(self, self.Text_Amount, "(%d)") },
		{ "bEmpty", UIBinderSetIsVisible.New(self, self.NoReplace) },
		{ "bEmpty", UIBinderSetIsVisible.New(self, self.TableView, true) },
		{ "ItemBindableList", UIBinderUpdateBindableList.New(self, self.EquipmentsTableView) },
		{ "SelectIndex", UIBinderSetSelectedIndex.New(self, self.EquipmentsTableView) },
		{ "FilterType", UIBinderValueChangedCallback.New(self, nil, self.OnFilterTypeChange) },
		{ "FilterTypeList", UIBinderValueChangedCallback.New(self, nil, self.OnFilterTypeListChanged) }
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function EquipmentListPageView:OnEquipmentSelectChange(Index, ItemData, ItemView)
	local EquipmentDetailItemVM = ItemData
	if (EquipmentDetailItemVM) then
		---显示装备详情
		if self.SuperView ~= nil then
			-- UIUtil.SetIsVisible(self.SuperView.EquipmentDetail, true)
			-- self.SuperView.EquipmentDetail.ViewModel:SetMajorEquipment(EquipmentDetailItemVM.ResID, EquipmentDetailItemVM.GID, 
			-- EquipmentDetailItemVM.bEquiped, EquipmentDetailItemVM.IsBind, self.ViewModel.Part)
			-- self.SuperView.EquipmentDetail:ToOriginState()
			local IsVisible = UIUtil.IsVisible(self.SuperView.EquipmentDetail)
			if not IsVisible then
				self.SuperView:StopAnimation(self.SuperView.AnimEquipmentDetailHide)
				self.SuperView:PlayAnimation(self.SuperView.AnimEquipmentDetailShow)
				local DelayTime = self.SuperView.AnimListPanelIn:GetEndTime() or 0
				self:RegisterTimer(function()
					self.SuperView:PlayAnimation(self.SuperView.AnimListPanelIn, DelayTime, 1, 0, 1.0, false)
				end, DelayTime, 0, 1)
			end
			UIUtil.SetIsVisible(self.SuperView.EquipmentDetail, true)
			self.SuperView.EquipmentDetail:UpdateEquipment(ItemData.Item, self.ViewModel.Part)
			self.SuperView.EquipmentDetail:ToOriginState()
            if self.OnEquipmentListSelect ~= nil then
				self.OnEquipmentListSelect(self.SuperView, Index, ItemData, ItemView)
			end
		end
	end
end

function EquipmentListPageView:OnFilterTypeChange()
	if nil ~= self.ViewModel.FilterType then
		self:PlayAnimation(self.AnimFilterChange)
		self.Filter:SetSelectedIndex(self.ViewModel.FilterType)
	end
end

function EquipmentListPageView:ToOriginState()
	self.EquipmentsTableView:ScrollToTop()
	local IsVisible = UIUtil.IsVisible(self.SuperView.EquipmentDetail)
	if IsVisible then
		self.SuperView:PlayAnimation(self.SuperView.AnimEquipmentDetailHide)
	end
    UIUtil.SetIsVisible(self.SuperView.EquipmentDetail, false)
	self.ViewModel:SetFilter(FilterType.All)
end

function EquipmentListPageView:OnSelectionChangedFilter(Index)
	local IsVisible = UIUtil.IsVisible(self.SuperView.EquipmentDetail)
	if IsVisible then
		self.SuperView:PlayAnimation(self.SuperView.AnimEquipmentDetailHide)
	end
	UIUtil.SetIsVisible(self.SuperView.EquipmentDetail, false)
	self.ViewModel:SetFilter(Index)
end

function EquipmentListPageView:OnFilterTypeListChanged()
	if nil == self.ViewModel.FilterTypeList then
		return
	end
	self:PlayAnimation(self.AnimUpdate)
	self.Filter:UpdateItems(self.ViewModel.FilterTypeList, self.ViewModel.FilterType)
end

function EquipmentListPageView:OnEquipRepairSucc(Params)
	self.ViewModel:UpdateList()
end

function EquipmentListPageView:OnHyperlinkClicked()
	local MajorUtil = require("Utils/MajorUtil")
	local ItemUtil = require("Utils/ItemUtil")
	--写死获取途径
	local AccessList = {144, 145, 268}
	local Cfg
	local MajorLevel = MajorUtil.GetMajorLevel()
	local UnLockIndex = 1
	local CommGetWayItems = {}
	for _, value in ipairs(AccessList) do
		Cfg = ItemGetaccesstypeCfg:FindCfgByKey(value)
		if Cfg ~= nil then
			local ViewParams = {ID = Cfg.ID, FunDesc = Cfg.FunDesc, ItemID = 0, MajorLevel = MajorLevel, 
			FunIcon = Cfg.FunIcon, ItemAccessFunType = Cfg.FunType, UnLockLevel = Cfg.UnLockLevel, 
			IsRedirect = Cfg.IsRedirect, FunValue = Cfg.FunValue, RepeatJumpTipsID = Cfg.RepeatJumpTipsID, UnLockTipsID = Cfg.UnLockTipsID}
			if (ViewParams.UnLockLevel == nil or ViewParams.MajorLevel == nil or ViewParams.UnLockLevel <= ViewParams.MajorLevel) 
			and ItemUtil.QueryIsUnLock(ViewParams.ItemAccessFunType, ViewParams.FunValue, ViewParams.ItemID) then --等级限制
				ViewParams.IsUnLock = true
			else
				ViewParams.IsUnLock = false
			end
			if ViewParams.IsUnLock and Cfg.SpoilerCondition and Cfg.SpoilerCondition ~= 0 then
				ViewParams.CanRevealPlot = ItemUtil.QueryIsCanRevealPlot(ViewParams.ItemAccessFunType, Cfg.SpoilerCondition)
				ViewParams.SpoilerTipsDesc = Cfg.SpoilerTipsDesc
			else
				ViewParams.CanRevealPlot = true
			end
			if ViewParams.IsUnLock then
				table.insert(CommGetWayItems, UnLockIndex, ViewParams)
				UnLockIndex = UnLockIndex + 1
			else
				table.insert(CommGetWayItems,ViewParams)
			end
		end
	end

	local Params = {}
	Params.Data = CommGetWayItems
	local BtnSize = UIUtil.CanvasSlotGetSize(self.GoBtn)
	local View = TipsUtil.ShowGetWayTips(self.ViewModel, nil, self.GoBtn, UE.FVector2D(BtnSize.X, -15), UE.FVector2D(1, 1), false)
	View:UpdateView(Params.Data)
end

return EquipmentListPageView