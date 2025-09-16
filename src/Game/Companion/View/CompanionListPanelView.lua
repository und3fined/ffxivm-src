---
--- Author: HugoWong
--- DateTime: 2023-11-06 15:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local ProtoCommon = require("Protocol/ProtoCommon")
local DataReportUtil = require("Utils/DataReportUtil")
local MajorUtil = require("Utils/MajorUtil")

local CompanionListVM = require ("Game/Companion/VM/CompanionListVM")
local CompanionVM = require ("Game/Companion/VM/CompanionVM")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

local LSTR = _G.LSTR
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local MsgTipsUtil = _G.MsgTipsUtil
local CompanionMgr = _G.CompanionMgr
local CompanySealMgr = _G.CompanySealMgr
local ModuleOpenMgr = _G.ModuleOpenMgr

---@class CompanionListPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnArchive UFButton
---@field BtnCall CommBtnMView
---@field BtnCallingSetting UFButton
---@field BtnCancelCall CommBtnMView
---@field CommEmpty CommBackpackEmptyView
---@field PanelCallingSetting CompanionCallingSettingPanelView
---@field PopUpBGHidePanelSetting CommonPopUpBGView
---@field TableViewCompanion UTableView
---@field TextCompanionName UFTextBlock
---@field ToggleButtonFavourite UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanionListPanelView = LuaClass(UIView, true)

function CompanionListPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnArchive = nil
	--self.BtnCall = nil
	--self.BtnCallingSetting = nil
	--self.BtnCancelCall = nil
	--self.CommEmpty = nil
	--self.PanelCallingSetting = nil
	--self.PopUpBGHidePanelSetting = nil
	--self.TableViewCompanion = nil
	--self.TextCompanionName = nil
	--self.ToggleButtonFavourite = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanionListPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCall)
	self:AddSubView(self.BtnCancelCall)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.PanelCallingSetting)
	self:AddSubView(self.PopUpBGHidePanelSetting)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanionListPanelView:OnInit()
	self.ViewModel = CompanionListVM.New()
	self.CompanionAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewCompanion, self.OnCompanionTableViewSelectChange)

	-- 初始化Binders
	self.Binders = {
		{
			ViewModel = CompanionVM,
			Binders = {
				{ "CompanionList", UIBinderValueChangedCallback.New(self, nil, self.OnCompanionListChanged) },
				{ "CallingOutCompanion", UIBinderValueChangedCallback.New(self, nil, self.OnCallingOutCompanionChanged) },
			}
		},
		{
			ViewModel = self.ViewModel,
			Binders = {
				{ "CompanionVMList", UIBinderValueChangedCallback.New(self, nil, self.OnCompanionVMListChanged) },
				{ "CompanionName", UIBinderSetText.New(self, self.TextCompanionName) },
				{ "ToggleFavourite", UIBinderSetIsChecked.New(self, self.ToggleButtonFavourite) },
				{ "CanCallCompanion", UIBinderValueChangedCallback.New(self, nil, self.OnCanCallCompanionChanged) },
				{ "IsShowCallBtn", UIBinderValueChangedCallback.New(self, nil, self.OnIsShowCallBtnChanged) },
			}
		},
	}
end

function CompanionListPanelView:OnDestroy()

end

function CompanionListPanelView:OnShow()
	self:HandlePageSourceTLOG()
	self:SetFixText()

	ModuleOpenMgr:HideRedDotByModuleID(ProtoCommon.ModuleID.ModuleIDCompanion)

	if self:GetSelectedCompanionID() == 0 then
		self.ViewModel.CanCallCompanion = false
		self.ViewModel.IsShowCallBtn = true
	end

	-- 防止弱网环境造成模型和数据不对应，打开界面时判断是否要修正显示
	self:CheckCompanionSync()
end

function CompanionListPanelView:OnHide()
	self.CompanionAdapterTableView:ClearSelectedItem()
	self:SetCallingSettingPanelVisible(false)
end

function CompanionListPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnArchive, self.OnBtnArchiveClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnCall.Button, self.OnBtnCallClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnCancelCall.Button, self.OnBtnCancelCallClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnCallingSetting, self.OnBtnCallingSettingClicked)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonFavourite, self.OnToggleFavoriteClicked)
	self.PopUpBGHidePanelSetting:SetCallback(self, self.OnPopUpBGHidePanelSettingClicked)
end

function CompanionListPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnCanCallCompanionUpdate)
	self:RegisterGameEvent(EventID.PWorldMapExit, self.OnCanCallCompanionUpdate)
	self:RegisterGameEvent(EventID.MountCall, self.OnCanCallCompanionUpdate)
	self:RegisterGameEvent(EventID.MountBack, self.OnCanCallCompanionUpdate)
	self:RegisterGameEvent(EventID.NetStateUpdate, self.OnCanCallCompanionUpdate)
	self:RegisterGameEvent(EventID.CompanionNewListUpdate, self.OnCompanionNewListUpdate)
	self:RegisterGameEvent(EventID.CompanionFavouriteListUpdate, self.OnCompanionFavouriteListUpdate)
	self:RegisterGameEvent(EventID.CompanionCallingOutUpdate, self.OnCompanionCallingOutUpdate)
end

function CompanionListPanelView:OnRegisterBinder()
	self:RegisterMultiBinders(self.Binders)
end

function CompanionListPanelView:OnCompanionTableViewSelectChange(Index, ItemData, ItemView)
	local CompanionID = self:GetSelectedCompanionID()
	
	CompanionMgr:SendReadNewCompanionMsg(CompanionID)
	local Cfg = ItemData.Cfg
	self.ViewModel.CompanionName = Cfg and Cfg.Name or ""
	self.ViewModel.ToggleFavourite = CompanionVM:IsCompanionFavourite(CompanionID)
	self.ViewModel.CanCallCompanion = CompanionMgr:CanCallCompanion()

	local CallingOutCompanion = CompanionVM:GetCallingOutCompanion()
	self.ViewModel.IsShowCallBtn = true
	if not self:IsSelectedMergeCompanion() then
		self.ViewModel.IsShowCallBtn = CallingOutCompanion == 0 or CallingOutCompanion ~= CompanionID
	else
		for _, ID in ipairs(Cfg.CompanionID or {}) do
			if CallingOutCompanion == ID then
				self.ViewModel.IsShowCallBtn = false
				break
			end
		end
	end

	DataReportUtil.ReportData("PetClickFlow", true, false, true,
	"EntertainID", "116",
	"Type", "5",
	"PetID", tostring(CompanionID))
end

function CompanionListPanelView:OnCompanionListChanged(Params)
	self.ViewModel:UpdateVMList()
end

function CompanionListPanelView:OnCallingOutCompanionChanged(NewValue, OldValue)
	if self:GetSelectedCompanionID() == 0 then return end

	local CurSelectCompanionCalled = false
	if not self:IsSelectedMergeCompanion() then
		CurSelectCompanionCalled = CompanionVM:GetCallingOutCompanion() == self:GetSelectedCompanionID()
	else
		local CompanionList = self:GetSelectedCompanionVM().Cfg.CompanionID
		for _, CompanionID in ipairs(CompanionList) do
			if CompanionVM:GetCallingOutCompanion() == CompanionID then
				CurSelectCompanionCalled = true
				break
			end
		end
	end
	self.ViewModel.IsShowCallBtn = not CurSelectCompanionCalled
end

function CompanionListPanelView:OnCompanionVMListChanged(Params)
	-- 展示列表为空的UI
	UIUtil.SetIsVisible(self.CommEmpty, Params and #Params == 0)

	-- 刷新列表展示
	self.CompanionAdapterTableView:UpdateAll(Params)
	self:UpdateSelectedCompanion()
end

function CompanionListPanelView:UpdateSelectedCompanion()
	local CallingOutCompanionID = CompanionVM:GetCallingOutCompanion()

	-- 如果有召唤出的宠物则选择此宠物，如果没有则选第一个，最后如果列表为空则不选
	if CallingOutCompanionID ~= 0 and self.ViewModel.CompanionVMList ~= nil then
		local IsInGroup, MergeGroupID = CompanionMgr:IsCompanionInMergeGroup(CallingOutCompanionID)
		for Index, CompanionVM in ipairs(self.ViewModel.CompanionVMList) do
			if IsInGroup then
				if CompanionVM.IsMerge and CompanionVM.Cfg.ID == MergeGroupID then
					self.CompanionAdapterTableView:SetSelectedIndex(Index)
					break
				end
			else
				if CompanionVM.CompanionID == CallingOutCompanionID then
					self.CompanionAdapterTableView:SetSelectedIndex(Index)
					break
				end
			end
		end
	elseif self.ViewModel.CompanionVMList ~= nil and #self.ViewModel.CompanionVMList > 0 then
		self.CompanionAdapterTableView:SetSelectedIndex(1)
	else
		self.CompanionAdapterTableView:ClearSelectedItem()
	end
end

function CompanionListPanelView:OnCanCallCompanionChanged(NewValue, OldValue)
	if NewValue == nil then return end

	if NewValue then
		self.BtnCall:SetIsRecommendState(true)
	else
		self.BtnCall:SetIsNormalState(true)
	end
end

function CompanionListPanelView:OnIsShowCallBtnChanged(NewValue, OldValue)
	if NewValue == nil then return end

	UIUtil.SetIsVisible(self.BtnCall, NewValue)
	UIUtil.SetIsVisible(self.BtnCancelCall, not NewValue)
end

function CompanionListPanelView:OnBtnArchiveClicked()
	CompanionMgr:OpenCompanionArchive({ FromListPanel = true })
end

function CompanionListPanelView:OnBtnCallClicked()
	if self:GetSelectedCompanionID() == 0 then
		MsgTipsUtil.ShowTips(LSTR(120013))
		return
	end

	local CallOutID = self:GetSelectedCompanionID()
	local IsInGroup, GroupID = CompanionMgr:IsCompanionInMergeGroup(CallOutID)
	if IsInGroup then
		-- 袖珍领袖需要先加入联军才能召唤
		if GroupID == 2 then
			local CompanySealInfo = CompanySealMgr:GetCompanySealInfo()
			if not CompanySealInfo or CompanySealInfo.GrandCompanyID == 0 then
				MsgTipsUtil.ShowTips(LSTR(120005))
				return
			end
		end
		CallOutID = CompanionMgr:GetCompanionFromGroup(GroupID)
	end
	CompanionMgr:CallOutCompanion(CallOutID)
	DataReportUtil.ReportEasyUseFlowData(3, CallOutID, 3)
end

function CompanionListPanelView:OnBtnCancelCallClicked()
	CompanionMgr:CallBackCompanion()
end

function CompanionListPanelView:OnBtnCallingSettingClicked()
	local isNowVisible = UIUtil.IsVisible(self.PanelCallingSetting)
	if isNowVisible == true then return end
	
	self:SetCallingSettingPanelVisible(true)
end

function CompanionListPanelView:OnToggleFavoriteClicked(ToggleButton, ButtonState)
	local OldFavourite = self.ViewModel.ToggleFavourite
	local IsFavourite = UIUtil.IsToggleButtonChecked(ButtonState)

	self.ViewModel.ToggleFavourite = IsFavourite
	if self:GetSelectedCompanionID() ~= 0 then
		CompanionMgr:SetCompanionFavourite(self:GetSelectedCompanionID(), IsFavourite)
	else
		MsgTipsUtil.ShowTips(LSTR(120013))
	end

	self.ViewModel.ToggleFavourite = OldFavourite
end

function CompanionListPanelView:OnPopUpBGHidePanelSettingClicked()
	self:SetCallingSettingPanelVisible(false)
end

function CompanionListPanelView:SetCallingSettingPanelVisible(Visible)
	UIUtil.SetIsVisible(self.PanelCallingSetting, Visible)
	UIUtil.SetIsVisible(self.PopUpBGHidePanelSetting, Visible, true)
end

function CompanionListPanelView:OnCanCallCompanionUpdate(Param)
	self.ViewModel.CanCallCompanion = CompanionMgr:CanCallCompanion()
end

function CompanionListPanelView:OnCompanionNewListUpdate()
	self.ViewModel:UpdateVMData()
end

function CompanionListPanelView:OnCompanionFavouriteListUpdate()
	if self:GetSelectedCompanionID() ~= 0 then
    	self.ViewModel.ToggleFavourite = CompanionVM:IsCompanionFavourite(self:GetSelectedCompanionID())
	end

	self.ViewModel:UpdateVMData()
end

function CompanionListPanelView:OnCompanionCallingOutUpdate()
	self.ViewModel:UpdateVMData()
end

function CompanionListPanelView:IsSelectedMergeCompanion()
	local CompanionVM = self.CompanionAdapterTableView:GetSelectedItemData()
	return CompanionVM and CompanionVM.IsMerge
end

function CompanionListPanelView:GetSelectedCompanionID()
	local Index = self.CompanionAdapterTableView:GetSelectedIndex()
	if Index == nil then return 0 end

	local CompanionVM = self.CompanionAdapterTableView:GetSelectedItemData()
	return CompanionVM.IsMerge and CompanionVM.Cfg.CompanionID[1] or CompanionVM.CompanionID
end

function CompanionListPanelView:GetSelectedCompanionVM()
	return self.CompanionAdapterTableView:GetSelectedItemData()
end

function CompanionListPanelView:HandlePageSourceTLOG()
	local IsFromMain = self.Params and self.Params.bOpen
	local Arg1 = IsFromMain == true and 1 or 2
	DataReportUtil.ReportData("PetSystemFlow", true, false, true,
	"OpType", "1",
	"Arg1", tostring(Arg1))
end

function CompanionListPanelView:SetFixText()
	self.CommEmpty:SetTipsContent(LSTR(120024))
	self.BtnCall:SetText(LSTR(120021))
	self.BtnCancelCall:SetText(LSTR(120022))
end

function CompanionListPanelView:CheckCompanionSync()
	local Major = MajorUtil.GetMajor()
	if Major then
		local CompanionComponent = Major:GetCompanionComponent()
		local CompanionIDOnActor = CompanionComponent:GetCompanionResID()
		local CompanionIDOnServer = CompanionVM:GetCallingOutCompanion()
		if CompanionIDOnActor ~= CompanionIDOnServer then
			_G.FLOG_INFO(string.format("[CompanionListPanelView]Sync companion with true ID: %d", CompanionIDOnServer))
			if CompanionIDOnServer ~= 0 then
				CompanionMgr:CallOut(Major, CompanionIDOnServer)
			else
				CompanionMgr:CallBack(Major)
			end
		end
	end
end

return CompanionListPanelView