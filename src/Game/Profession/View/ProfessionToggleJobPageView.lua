---
--- Author: zimuyi
--- DateTime: 2023-06-25 19:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local ProfessionToggleJobVM = require("Game/Profession/VM/ProfessionToggleJobVM")

local TextColorSelected = "FFF4D0FF"
local TextColorUnselected = "828282FF"

local TabIndex = {
	Fight = 1,
	Production = 2
}
---@class ProfessionToggleJobPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFold UFButton
---@field CommHorTabsSwitchNew CommHorTabsView
---@field HorizontalJobList UFHorizontalBox
---@field HorizontalSwitch UFHorizontalBox
---@field PanelJobs UFCanvasPanel
---@field TableViewJobList1 UTableView
---@field TableViewJobList2 UTableView
---@field TextFight UFTextBlock
---@field TextGather UFTextBlock
---@field ToggleBtnFight UToggleButton
---@field ToggleBtnGather UToggleButton
---@field AnimSwitch UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ProfessionToggleJobPageView = LuaClass(UIView, true)

function ProfessionToggleJobPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFold = nil
	--self.CommHorTabsSwitchNew = nil
	--self.HorizontalJobList = nil
	--self.HorizontalSwitch = nil
	--self.PanelJobs = nil
	--self.TableViewJobList1 = nil
	--self.TableViewJobList2 = nil
	--self.TextFight = nil
	--self.TextGather = nil
	--self.ToggleBtnFight = nil
	--self.ToggleBtnGather = nil
	--self.AnimSwitch = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ProfessionToggleJobPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommHorTabsSwitchNew)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ProfessionToggleJobPageView:OnInit()
	self.ViewModel = ProfessionToggleJobVM
	self.AdapterTableViewLeft = UIAdapterTableView.CreateAdapter(self, self.TableViewJobList1, nil, false, false, false, true, true)
	self.AdapterTableViewRight = UIAdapterTableView.CreateAdapter(self, self.TableViewJobList2, nil, false, false, false, true, true)
	self.AdapterTableViewLeft:SetScrollbarIsVisible(false)
	self.AdapterTableViewRight:SetScrollbarIsVisible(false)
	self.Binders =
	{
		{ "ProfSpecialization", UIBinderValueChangedCallback.New(self, nil, self.OnProfSpecializationChanged) },
		{ "LeftRangeItemVMList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewLeft) },
		{ "RightRangeItemVMList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewRight) },
	}
	self.BindersEquipment =
	{
		{ "lstProfDetail", UIBinderValueChangedCallback.New(self, nil, self.OnProfDetailListChanged) },
	}
	self.SeleceIndex = nil
end

function ProfessionToggleJobPageView:OnDestroy()

end

function ProfessionToggleJobPageView:OnShow()
	local DelayTime = self.AnimSwitch:GetEndTime() or 0
	self:RegisterTimer(function()
		self:PlayAnimation(self.AnimSwitch, DelayTime, 1, 0, 1.0, false)
	end, DelayTime, 0, 1)

	-- 折叠按钮是否显示
	if nil ~= self.Params and self.Params.bShowBtnFold then
		UIUtil.SetIsVisible(self.BtnFold, true, true)
	else
		UIUtil.SetIsVisible(self.BtnFold, false)
	end

	-- 当前选中职业类型
	local EquipmentProfSpecialization = _G.EquipmentMgr:GetEquipmentProfSpecialization()
	local IsCombatProf = true
	if EquipmentProfSpecialization ~= ProtoCommon.specialization_type.SPECIALIZATION_TYPE_NULL then
		IsCombatProf = _G.EquipmentMgr:GetEquipmentProfSpecialization() == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT
	else
		IsCombatProf = MajorUtil.GetMajorProfSpecialization() == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT
	end
	self.ViewModel.ProfSpecialization = IsCombatProf and ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT
		or ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION

	local MajorRoleDetail = _G.ActorMgr:GetMajorRoleDetail()
	if nil ~= MajorRoleDetail then
		EquipmentVM.lstProfDetail = MajorRoleDetail.Prof.ProfList
	end
end

function ProfessionToggleJobPageView:PostShowView()
	local Data = {{Name = LSTR(1050182)},{Name = LSTR(1050183)}}
	self.CommHorTabsSwitchNew:UpdateItems(Data)
	local MajorProfID = ProfID or MajorUtil.GetMajorProfID()
	local EquipmentProfSpecialization = _G.EquipmentMgr:GetEquipmentProfSpecialization()
	local IsCombatProf = true
	if EquipmentProfSpecialization ~= ProtoCommon.specialization_type.SPECIALIZATION_TYPE_NULL then
		IsCombatProf = _G.EquipmentMgr:GetEquipmentProfSpecialization() == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT
	else
		IsCombatProf = MajorUtil.GetMajorProfSpecialization() == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT
	end
	self.CommHorTabsSwitchNew:UpdateSelect(IsCombatProf and 1 or 2, true)
	self.CommHorTabsSwitchNew:SetSelectedIndex(IsCombatProf and 1 or 2)
end

function ProfessionToggleJobPageView:OnHide()
	_G.EquipmentMgr:SetEquipmentProfSpecialization(ProtoCommon.specialization_type.SPECIALIZATION_TYPE_NULL)
end

function ProfessionToggleJobPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFold, self.OnFoldClicked)
	UIUtil.AddOnSelectionChangedEvent(self, self.CommHorTabsSwitchNew, self.OnGroupTabsSelectionChanged)
end

function ProfessionToggleJobPageView:OnRegisterGameEvent()

end

function ProfessionToggleJobPageView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
	self:RegisterBinders(EquipmentVM, self.BindersEquipment)
end

---------- UI事件 ----------
function ProfessionToggleJobPageView:OnGroupTabsSelectionChanged(Index)
	self.ViewModel.ProfSpecialization = Index == TabIndex.Production and ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
		or ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT
end

function ProfessionToggleJobPageView:OnFoldClicked()
	self:Hide()
end

---------- 游戏事件 ----------


---------- VM事件 ----------

function ProfessionToggleJobPageView:OnProfDetailListChanged()
	self.ViewModel:UpdateProfList(EquipmentVM.lstProfDetail)
end

function ProfessionToggleJobPageView:OnProfSpecializationChanged(NewProfSpecialization)
	if self.SeleceIndex == NewProfSpecialization then 
		return
	end
	local bIsCombatProf = NewProfSpecialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT
	local TextColorCombat = bIsCombatProf and TextColorSelected or TextColorUnselected
	local TextColorProduct = bIsCombatProf and TextColorUnselected or TextColorSelected
	UIUtil.TextBlockSetColorAndOpacityHex(self.TextFight, TextColorCombat)
	UIUtil.TextBlockSetColorAndOpacityHex(self.TextGather, TextColorProduct)
	if nil == EquipmentVM.lstProfDetail then
		local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
		if nil ~= RoleDetail then
			EquipmentVM.lstProfDetail = RoleDetail.Prof.ProfList
		end
	end
	if nil ~= EquipmentVM.lstProfDetail then
		self.ViewModel:GenerateNewProfList(EquipmentVM.lstProfDetail)
	end
	self:PlayAnimation(self.AnimSwitch)
	self.SeleceIndex = NewProfSpecialization
end

return ProfessionToggleJobPageView