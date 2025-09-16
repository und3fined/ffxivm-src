---
--- Author: enqingchen
--- DateTime: 2021-12-31 16:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local TipsUtil = require("Utils/TipsUtil")
local HelpInfoUtil = require("Utils/HelpInfoUtil")

--@ViewModel
local AttributeMainPageVM = require("Game/Attribute/VM/AttributeMainPageVM")
-- local EquipmentJobBtnItemVM = require("Game/Equipment/VM/EquipmentJobBtnItemVM")
-- local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")

--@Binder
-- local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetProfIconSimple5nd = require("Binder/UIBinderSetProfIconSimple5nd")
-- local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
-- local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

---@class AttributeMainPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDetail CommBtnLView
---@field BtnInfo2 CommInforBtnView
---@field Btn_Infor UFButton
---@field ExpProgBar UProgressBar
---@field HorizontalInfo UFHorizontalBox
---@field ImgArrow1 UFImage
---@field ImgJobIcon UFImage
---@field ImgSync1 UFImage
---@field ImgSync2 UFImage
---@field ImgSync3 UFImage
---@field RichText_Exp URichTextBox
---@field SummaryItem01 AttributeSummaryItemView
---@field SummaryItem02 AttributeSummaryItemView
---@field SummaryItem03 AttributeSummaryItemView
---@field SummaryItem04 AttributeSummaryItemView
---@field SummaryItem05 AttributeSummaryItemView
---@field SummaryItem06 AttributeSummaryItemView
---@field SummaryItem07 AttributeSummaryItemView
---@field SummaryItem08 AttributeSummaryItemView
---@field TextJob UFTextBlock
---@field Text_BaseAttri UFTextBlock
---@field Text_DetailInfor UFTextBlock
---@field Text_Exp UFTextBlock
---@field Text_RoleLevel UFTextBlock
---@field Text_SecondAttri UFTextBlock
---@field AnimExpLight UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AttributeMainPageView = LuaClass(UIView, true)

local SummaryCount = 8

function AttributeMainPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDetail = nil
	--self.BtnInfo2 = nil
	--self.Btn_Infor = nil
	--self.ExpProgBar = nil
	--self.HorizontalInfo = nil
	--self.ImgArrow1 = nil
	--self.ImgJobIcon = nil
	--self.ImgSync1 = nil
	--self.ImgSync2 = nil
	--self.ImgSync3 = nil
	--self.RichText_Exp = nil
	--self.SummaryItem01 = nil
	--self.SummaryItem02 = nil
	--self.SummaryItem03 = nil
	--self.SummaryItem04 = nil
	--self.SummaryItem05 = nil
	--self.SummaryItem06 = nil
	--self.SummaryItem07 = nil
	--self.SummaryItem08 = nil
	--self.TextJob = nil
	--self.Text_BaseAttri = nil
	--self.Text_DetailInfor = nil
	--self.Text_Exp = nil
	--self.Text_RoleLevel = nil
	--self.Text_SecondAttri = nil
	--self.AnimExpLight = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AttributeMainPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnDetail)
	self:AddSubView(self.BtnInfo2)
	self:AddSubView(self.SummaryItem01)
	self:AddSubView(self.SummaryItem02)
	self:AddSubView(self.SummaryItem03)
	self:AddSubView(self.SummaryItem04)
	self:AddSubView(self.SummaryItem05)
	self:AddSubView(self.SummaryItem06)
	self:AddSubView(self.SummaryItem07)
	self:AddSubView(self.SummaryItem08)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AttributeMainPageView:OnInit()
	self.ViewModel = AttributeMainPageVM.New()
end

function AttributeMainPageView:OnDestroy()

end

function AttributeMainPageView:OnShow()
	--self:PlayAnimation(self.AnimIn)
	local DelayTime = self.AnimIn:GetEndTime() or 0
	self:RegisterTimer(function()
		self:PlayAnimation(self.AnimIn, DelayTime, 1, 0, 1.0, false)
	end, DelayTime, 0, 1)
	self.ViewModel:InitAttr()
	self:UpdateSummaries()
	self.BtnInfo2:SetButtonStyle(HelpInfoUtil.HelpInfoType.NewTipsBright)
	self.Text_BaseAttri:SetText(LSTR(1050179))
	self.Text_SecondAttri:SetText(LSTR(1050180))
	self.BtnDetail.TextContent:SetText(LSTR(1050181))
end

function AttributeMainPageView:OnHide()
	--self:PlayAnimation(self.AnimOut)
end

function AttributeMainPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDetail, self.OnAttrDetailInfoClick)
	UIUtil.AddOnClickedEvent(self, self.BtnInfo2.BtnInfor, self.OnButtonInfoClick)
end

function AttributeMainPageView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.Major_Attr_Change, self.OnMajorAttrChange)
	self:RegisterGameEvent(_G.EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
	self:RegisterGameEvent(_G.EventID.MajorExpUpdate, self.OnMajorExpUpdate)
	self:RegisterGameEvent(_G.EventID.MajorProfSwitch, self.OnMajorProfSwitch)
	self:RegisterGameEvent(_G.EventID.MajorLevelSyncSwitch, self.OnLevelSyncSwitch)
end

function AttributeMainPageView:OnRegisterBinder()
	local Binders = {
		{ "Level", UIBinderSetTextFormat.New(self, self.Text_RoleLevel, "%d") },
		{ "ExpText", UIBinderSetText.New(self, self.RichText_Exp) },
		{ "ExpProgress", UIBinderSetPercent.New(self, self.ExpProgBar) },
		{ "ExpProgress", UIBinderValueChangedCallback.New(self, nil, self.OnExpProgressChanged) },
		{ "ProfID", UIBinderSetProfIconSimple5nd.New(self, self.ImgJobIcon) },
		{ "ProfID", UIBinderSetProfName.New(self, self.TextJob) },
		{ "bInLevelSync", UIBinderSetIsVisible.New(self, self.ImgSync1) },
		{ "bInLevelSync", UIBinderSetIsVisible.New(self, self.ImgSync2) },
		{ "bInLevelSync", UIBinderSetIsVisible.New(self, self.ImgSync3) },
		{ "bHasMaxLevelProf", UIBinderSetIsVisible.New(self, self.HorizontalInfo) }
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function AttributeMainPageView:OnMajorAttrChange(Params)
	self.ViewModel:UpdateAttrValue(Params)
end

function AttributeMainPageView:OnMajorLevelUpdate(Params)
	self.ViewModel:UpdateLevelValue(Params)
end

function AttributeMainPageView:OnMajorExpUpdate(Params)
	self.ViewModel:UpdateExpValue(Params)
end

function AttributeMainPageView:OnMajorProfSwitch(Params)
	if nil == Params then
		return
	end
	self.ViewModel:InitAttr()
	self:UpdateSummaries()
	self:PlayAnimation(self.AnimUpdate)
end

function AttributeMainPageView:OnLevelSyncSwitch()
	self.ViewModel.bInLevelSync = MajorUtil.IsInLevelSync()
end

function AttributeMainPageView:OnAttrDetailInfoClick()
	if self.OnAttrDetailInfo ~= nil and self.SuperView ~= nil then
		self.OnAttrDetailInfo(self.SuperView)
	end
end

function AttributeMainPageView:UpdateSummaries()
	for Index = 1, SummaryCount do
		local ViewName = string.format("SummaryItem%02d", Index)
		local View = self[ViewName]
		local AttrKey = self.ViewModel.ListAttrKey[Index]
		if nil ~= AttrKey then
			if nil == View.ViewModel then
				View.ViewModel = self.ViewModel.Map_AttributeSummaryItemVM[AttrKey]
			else
				View.ViewModel:UpdateVM(self.ViewModel.Map_AttributeSummaryItemVM[AttrKey])
			end
			UIUtil.SetIsVisible(View, true)
		else
			UIUtil.SetIsVisible(View, false)
		end
	end
end

function AttributeMainPageView:OnExpProgressChanged(NewExpProgress)
	self:PlayAnimation(self.AnimExpLight, self.AnimExpLight:GetEndTime() * NewExpProgress, 1, nil, 0.0, false)
end

function AttributeMainPageView:OnButtonInfoClick()
	local ViewID = UIViewID.CommHelpInfoTipsView
	local Params = {}
	local Content = _G.LSTR(1050223)
	local BtnSize = UIUtil.GetLocalSize(self.BtnInfo2)
	Params.Data = table.is_nil_empty(Content) and {{Title = "", Content = {Content}}} or Content
	Params.Offset = _G.UE.FVector2D(-20, BtnSize.Y - 20)
	Params.Alignment = _G.UE.FVector2D(1, 0)
	Params.InTargetWidget = self.BtnInfo2
	Params.HidePopUpBG = false
    _G.UIViewMgr:ShowView(ViewID, Params)
end

return AttributeMainPageView