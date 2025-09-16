---
--- Author: chunfengluo
--- DateTime: 2023-08-03 09:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local DataReportUtil = require("Utils/DataReportUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local MountMgr = _G.MountMgr
local MountDefine = require("Game/Mount/MountDefine")
local MountVM = require("Game/Mount/VM/MountVM")
local MountPanelVM = require("Game/Mount/VM/MountPanelVM")
local MountDetailVM = require("Game/Mount/VM/MountDetailVM")
local MountCustomMadeVM = require("Game/Mount/VM/MountCustomMadeVM")
local ChocoboTransportMgr = _G.ChocoboTransportMgr
local LSTR = _G.LSTR
local ModuleType = ProtoRes.module_type

---@class MountMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnArchive UFButton
---@field BtnCall CommBtnMView
---@field BtnCancelCall CommBtnMView
---@field BtnCustomMade UFButton
---@field BtnSetting UFButton
---@field CommEmpty CommBackpackEmptyView
---@field PanelCustomMade UFCanvasPanel
---@field PanelSettingTips UFCanvasPanel
---@field PopupBGHideSettingTips CommonPopUpBGView
---@field RedDot CommonRedDotView
---@field SettingTips MountSettingSummonView
---@field TableViewItem UTableView
---@field TextMountName UFTextBlock
---@field ToggleButtonCollect UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountMainPanelView = LuaClass(UIView, true)

function MountMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnArchive = nil
	--self.BtnCall = nil
	--self.BtnCancelCall = nil
	--self.BtnCustomMade = nil
	--self.BtnSetting = nil
	--self.CommEmpty = nil
	--self.PanelCustomMade = nil
	--self.PanelSettingTips = nil
	--self.PopupBGHideSettingTips = nil
	--self.RedDot = nil
	--self.SettingTips = nil
	--self.TableViewItem = nil
	--self.TextMountName = nil
	--self.ToggleButtonCollect = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCall)
	self:AddSubView(self.BtnCancelCall)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.PopupBGHideSettingTips)
	self:AddSubView(self.RedDot)
	self:AddSubView(self.SettingTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountMainPanelView:OnInit()
	self.FilterSelect = 1
	self.ViewModel = MountPanelVM.New()
	self.ViewModel:Init()
	self.DetailViewModel = MountDetailVM.New()
	--self.ItemTipsContent:SetParams({ ViewModel = self.DetailViewModel })

	self.MountTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewItem, self.OnMountTableViewSelectChange, true)
	self.MountTableViewAdapter:SetScrollbarIsVisible(false)

	--self.FilterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewFilterList, self.OnFilterTableViewSelectChange, false)
	--self.FilterTableView:SetScrollbarIsVisible(false)

	--self.SearchBar:SetCallback(self, self.ChangeCallback, self.CommitedCallback);

	self.ToggleButtonCollect.ClickToUncheckedState = true
	UIUtil.SetIsVisible(self.SettingTips, false)
	UIUtil.SetIsVisible(self.PopupBGHideSettingTips, false)

	self.RedDot:SetIsCustomizeRedDot(true)
	self.bSetSelectedIndexOnShow = nil
end

function MountMainPanelView:OnDestroy()

end

function MountMainPanelView:OnShow()
	MountMgr:SendMountListQuery()
	UIViewMgr:HideView(_G.UIViewID.Main2ndPanel)
	-- 提审版本屏蔽
	self:OnSearch()
	--首测屏蔽坐骑图鉴
	local bShowBtn = _G.LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_MOUNT_PREVIEW)
	UIUtil.SetIsVisible(self.BtnArchive, bShowBtn, true)
	self.ViewModel.IsCustomMadeRedDotVisible = MountCustomMadeVM:MountIsNew(self.MountSelectResID)
	self.bSetSelectedIndexOnShow = true

	self.BtnCall:SetText(LSTR(1090018))
	self.BtnCancelCall:SetText(LSTR(1090019))
	self.CommEmpty:SetTipsContent(LSTR(1090025))

	if self.Params ~= nil and self.Params.SelectedResID ~= nil then
		self.MountSelectResIDOnShow = self.Params.SelectedResID
	end
end

function MountMainPanelView:OnHide()
	UIUtil.SetIsVisible(self.SettingTips, false)
	self.ViewModel:Clear()
	self.MountSelectResID = nil
	--self.SearchBar:SetText("")
	MountVM:RefreshFilterValue()
	--MountVM:ClearNew()
	self.bSetSelectedIndexOnShow = nil
	UIUtil.SetIsVisible(self.BtnCall, false)
	UIUtil.SetIsVisible(self.BtnCancelCall, false)
end

function MountMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCall.Button, self.OnCall)
	UIUtil.AddOnClickedEvent(self, self.BtnCancelCall.Button, self.OnCancelCall)
	UIUtil.AddOnClickedEvent(self, self.BtnSetting, self.OnBtnSetting)
	--UIUtil.AddOnClickedEvent(self, self.SearchBtn, self.OnSearch)
	UIUtil.AddOnClickedEvent(self, self.BtnArchive, self.OnLoadArchive)
	--UIUtil.AddOnStateChangedEvent(self, self.BtnFilter, self.OnBtnFilterClick)
	self.PopupBGHideSettingTips:SetCallback(self, self.OnHideSettingTips)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonCollect, self.OnBtnFavoriteClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCustomMade, self.OnClickBtnCustomMade)
end

function MountMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MountRefreshList, self.OnMountListChange)
	self:RegisterGameEvent(_G.EventID.MountFilterUpdate, self.OnMountFilterUpdate)
	self:RegisterGameEvent(_G.EventID.MountRefreshLike, self.OnMountLikeChange)
end

function MountMainPanelView:OnRegisterBinder()
	local Binders = {
		{ "ListSlotVM", UIBinderUpdateBindableList.New(self, self.MountTableViewAdapter) },
		{ "ListSlotVM", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateListSlotVM) },
		--{ "IsShowFilter", UIBinderSetIsChecked.New(self, self.BtnFilter, true) },
		--{ "IsShowFilter", UIBinderSetIsVisible.New(self, self.TableViewFilterList) },
		--{ "FilterItemList", UIBinderUpdateBindableList.New(self, self.FilterTableView) },
		--{ "IsSearch", UIBinderSetIsVisible.New(self, self.PanelFilterBar, true) },
		--{ "IsSearch", UIBinderSetIsVisible.New(self, self.SearchBtn, true, true) },
		--{ "IsSearch", UIBinderSetIsVisible.New(self, self.SearchBar) },
		--{ "IsShowDetail", UIBinderSetIsVisible.New(self, self.PanelItemTips) },
		--{ "IsShowDetail", UIBinderSetIsVisible.New(self, self.PopupBGHideItemTips) },

		-- { "IsInRide", UIBinderSetIsVisible.New(self, self.BtnCancelCall, false, true) },
		-- { "IsInRide", UIBinderSetIsVisible.New(self, self.BtnCall, true, true) },
		{ "IsPanelCustomMadeVisible", UIBinderSetIsVisible.New(self, self.PanelCustomMade) },
		{ "IsCustomMadeRedDotVisible", UIBinderValueChangedCallback.New(self, nil, self.OnSetCustomMadeRedDot) },
		{ "IsInRide", UIBinderValueChangedCallback.New(self, nil, self.OnIsInRideChange) },
	}
	self:RegisterBinders(self.ViewModel, Binders)

	local Binders1 = {
		{ "MountList", UIBinderValueChangedCallback.New(self, nil, self.OnMountListChange) },
		{ "CallSetting", UIBinderValueChangedCallback.New(self, nil, self.OnCallSettingChange) },
		{ "CurRideResID", UIBinderValueChangedCallback.New(self, nil, self.OnCurRideChange) },
	}
	self:RegisterBinders(MountVM, Binders1)

	local Binders2 = {
		{ "Name", UIBinderSetText.New(self, self.TextMountName) },
		{ "FavoriteToggle", UIBinderSetIsChecked.New(self, self.ToggleButtonCollect) },
	}
	self:RegisterBinders(self.DetailViewModel, Binders2)

	local Binders3 = {
		{ "NewMap", UIBinderValueChangedCallback.New(self, nil, self.OnCustomMadeNewMapChanged) },
	}
	self:RegisterBinders(MountCustomMadeVM, Binders3)
end

function MountMainPanelView:OnUpdateListSlotVM(Params)
	self.MountTableViewAdapter:UpdateAll(Params)
	local bIsEmptyList = Params and #Params == 0
	UIUtil.SetIsVisible(self.CommEmpty, bIsEmptyList)
	--UIUtil.SetIsVisible(self.PanelContent, not bIsEmptyList)
	if bIsEmptyList then
		self.DetailViewModel:UpdateDetail()
	end
	self:UpdateSelectedIndex()

end

function MountMainPanelView:OnLoadArchive()
	DataReportUtil.ReportMountInterSystemFlowData(2, 1)
	UIViewMgr:ShowView(UIViewID.MountArchivePanel)
end

function MountMainPanelView:ChangeCallback(Text, Length)
	if Text == '' then
		self.ViewModel:UpdateMountList(Text, true)
	end
end

function MountMainPanelView:CommitedCallback(Text, CommitMethod)
	self.ViewModel:UpdateMountList(Text, true)
end

function MountMainPanelView:OnCallSettingChange(NewValue, OldValue)
	if OldValue == nil then
		return
	end
	self.SettingTips.ViewModel:GenItems(MountVM.CallSetting)
end

function MountMainPanelView:OnCurRideChange(NewValue, OldValue)
	self.ViewModel.IsInRide = NewValue > 0
end

function MountMainPanelView:OnIsInRideChange(NewValue, OldValue)
	self.ViewModel:UpdateMountList(nil, false)
	self:UpdateSelectedIndex()
end

function MountMainPanelView:OnMountTableViewSelectChange(Index, ItemData, ItemView)
	local Mount = ItemData.Mount
	if Mount == nil then
		return
	end
	local bChanged = true
	if self.MountSelectResID == Mount.ResID then bChanged = false end
	self.MountSelectResID = Mount.ResID
	DataReportUtil.ReportMountInterSystemFlowData(3, 1, Mount.ResID)
	self.ViewModel.IsShowDetail = true
	if self.bSetSelectedIndexOnShow == false then
		if ItemData.IsShowRedPoint and not MountCustomMadeVM:MountIsNew(ItemData.ResID) then
			local Param = {ResID = ItemData.ResID or 0, Handbook = ItemData.Handbook}
			_G.MountMgr:SendMountRead(Param)
			--本地取消一次红点，下次全量拉才会刷新数据
			ItemData.IsShowRedPoint = false
			-- _G.MountMgr:InsertLocalRedPointID(ViewModel.ResID or 0)
		end
        MountVM:ClearNewByResID(Mount.ResID)
	end
	ItemData:UpdateData()
	self.DetailViewModel:UpdateDetail(Mount)

	local IsInRide = self.ViewModel.IsInRide
	local IsInOtherRide = MountVM.IsInOtherRide
	local IsInChocoboTransport = ChocoboTransportMgr:GetIsTransporting() -- 运输陆行鸟使用的陆行鸟不是玩家的陆行鸟，额外判断处理
	local bIsRidingSelectedMount = IsInRide and not IsInOtherRide and MountVM.CurRideResID == Mount.ResID and not IsInChocoboTransport
	UIUtil.SetIsVisible(self.BtnCall, not bIsRidingSelectedMount)
	UIUtil.SetIsVisible(self.BtnCancelCall, bIsRidingSelectedMount)
	
    self.ViewModel.IsPanelCustomMadeVisible = _G.MountMgr:IsCustomMadeEnabled(Mount.ResID)
	self.ViewModel.IsCustomMadeRedDotVisible = MountCustomMadeVM:MountIsNew(Mount.ResID)
	if self.bSetSelectedIndexOnShow == true then
		self.bSetSelectedIndexOnShow = false
	end

	DataReportUtil.ReportMountInterfaceFlowData("MountInterfaceFlow", 2, Mount.ResID)
end

function MountMainPanelView:OnMountListChange(Params)
	self.ViewModel:UpdateMountList(nil, false)
end

function MountMainPanelView:OnMountLikeChange(Params)
	--self:UpdateListAndDetail()
	self.ViewModel:UpdateCurMountList()
	if Params.ResID == self.MountSelectResID then
		self.DetailViewModel:UpdateDetail(Params)
	end
end

function MountMainPanelView:UpdateSelectedIndex()
	if self.MountSelectResIDOnShow and self.ViewModel and self.ViewModel.ListSlotVM then
		for Index, MountSlotVM in ipairs(self.ViewModel.ListSlotVM) do
			if MountSlotVM.Mount.ResID == self.MountSelectResIDOnShow then
				self.MountTableViewAdapter:SetSelectedIndex(Index)
				self.MountTableViewAdapter:ScrollToIndex(Index)
				return
			end
		end
	end
	if MountVM.CurRideResID and self.ViewModel and self.ViewModel.ListSlotVM then
		for Index, MountSlotVM in ipairs(self.ViewModel.ListSlotVM) do
			if MountSlotVM.Mount.ResID == MountVM.CurRideResID then
				self.MountTableViewAdapter:SetSelectedIndex(Index)
				self.MountTableViewAdapter:ScrollToIndex(Index)
				return
			end
		end
	end
	self.MountTableViewAdapter:SetSelectedIndex(1)
	self.MountTableViewAdapter:ScrollToIndex(1)
end

function MountMainPanelView:OnMountFilterUpdate(Params)
	local Key = Params[1]
	local bSelect = Params[2]
	self.FilterSelect = bSelect and Key or 0
	self.ViewModel:GenFilterItemList(self.FilterSelect)
end

function MountMainPanelView:OnCall()
	-- 运输陆行鸟途中不允许玩家召唤自己的坐骑
	if ChocoboTransportMgr:GetIsTransporting() then
        MsgTipsUtil.ShowTips(LSTR(1090001))
		return
	end

	if MountVM.IsInRide then
		MountMgr:SendMountRecall(self.DetailViewModel.ResID)
	else
		MountMgr:SendMountCall(self.DetailViewModel.ResID)
	end
	DataReportUtil.ReportEasyUseFlowData(3, self.DetailViewModel.ResID, 5)
end

function MountMainPanelView:OnCancelCall()
	_G.MountMgr:GetDownMount(false)
end

function MountMainPanelView:OnBtnSetting()
	if UIUtil.IsVisible(self.SettingTips) == true then
		UIUtil.SetIsVisible(self.SettingTips, false)
		UIUtil.SetIsVisible(self.PopupBGHideSettingTips, false)
	else
		self.SettingTips.ViewModel:GenItems(MountVM.CallSetting)
		UIUtil.SetIsVisible(self.SettingTips, true)
		UIUtil.SetIsVisible(self.PopupBGHideSettingTips, true)
	end
end

function MountMainPanelView:OnSearch()
	self.ViewModel.IsSearch = true
end

function MountMainPanelView:OnBtnFilterClick(ToggleButton, ButtonState)
	self.ViewModel.IsShowFilter = ButtonState == _G.UE.EToggleButtonState.Checked
	if self.ViewModel.IsShowFilter then
		self.ViewModel:GenFilterItemList(self.FilterSelect)
	end
end

function MountMainPanelView:OnCloseBtnClick()
	UIViewMgr:HideView(self.ViewID)
	--策划要求
end

function MountMainPanelView:OnHideSettingTips()
	UIUtil.SetIsVisible(self.SettingTips, false)
	UIUtil.SetIsVisible(self.PopupBGHideSettingTips, false)
end

function MountMainPanelView:OnBtnFavoriteClick(ToggleButton, ButtonState)
	if self.DetailViewModel.OnBtnFavoriteClick then
		self.DetailViewModel:OnBtnFavoriteClick(ButtonState)
	end
end

function MountMainPanelView:OnClickBtnCustomMade()
	DataReportUtil.ReportCustomizeUIFlowData(1, self.MountSelectResID, self.TextMountName:GetText(),"","",1)
	_G.MountMgr:JumpToCustomMadePanel(self.MountSelectResID)
end

function MountMainPanelView:OnSetCustomMadeRedDot(bVisible)
	if self.RedDot.ItemVM == nil then
		self.RedDot:InitData()
	end
	self.RedDot:SetRedDotUIIsShow(bVisible)
end

function MountMainPanelView:OnCustomMadeNewMapChanged()
	self.ViewModel.IsCustomMadeRedDotVisible = MountCustomMadeVM:MountIsNew(self.MountSelectResID)
end

return MountMainPanelView