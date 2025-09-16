---
--- Author: zimuyi
--- DateTime: 2023-06-26 15:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local ProfessionToggleJobVM = require("Game/Profession/VM/ProfessionToggleJobVM")

local FLOG_INFO = _G.FLOG_INFO

---@class ProfessionLevelItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FButton UFButton
---@field IconProf UFImage
---@field ImgSelect UFImage
---@field LevelProbar UProgressBar
---@field TextProfLevel UFTextBlock
---@field TextProfName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ProfessionLevelItemView = LuaClass(UIView, true)

function ProfessionLevelItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FButton = nil
	--self.IconProf = nil
	--self.ImgSelect = nil
	--self.LevelProbar = nil
	--self.TextProfLevel = nil
	--self.TextProfName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ProfessionLevelItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ProfessionLevelItemView:OnInit()
	self.Binders =
	{
		{ "ProfIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconProf) },
		{ "ProfID", UIBinderSetProfName.New(self, self.TextProfName) },
		{ "ExpProgress", UIBinderSetPercent.New(self, self.LevelProbar) },
		{ "Level", UIBinderSetTextFormat.New(self, self.TextProfLevel, "%d") },
		{ "bIsCurProf", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "LevelColor", UIBinderSetColorAndOpacityHex.New(self, self.TextProfLevel) },
		{ "NameColor", UIBinderSetColorAndOpacityHex.New(self, self.TextProfName) },
	}
end

function ProfessionLevelItemView:OnDestroy()

end

function ProfessionLevelItemView:OnShow()

end

function ProfessionLevelItemView:OnHide()

end

function ProfessionLevelItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButton, self.OnBtnClicked)
end

function ProfessionLevelItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MajorProfSwitch, self.OnMajorProfSwitch)
	self:RegisterGameEvent(_G.EventID.SwitchLockProf, self.OnMajorProfSwitch)
end

function ProfessionLevelItemView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end
	self.ViewModel = self.Params.Data
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ProfessionLevelItemView:OnBtnClicked()
	if not self.ViewModel.bIsCurProf then

		local View = _G.UIViewMgr:FindView(_G.UIViewID.EquipmentMainPanel)
		local CanPreview = View and true or false
		if not _G.ProfMgr:CanChangeProf(self.ViewModel.ProfID, CanPreview) then
			return
		end

		FLOG_INFO("Request change prof: %d", self.ViewModel.ProfID)
		_G.EquipmentMgr:SwitchProfByID(self.ViewModel.ProfID)
	end
end

function ProfessionLevelItemView:OnMajorProfSwitch(Params)
	if nil == Params or self.ViewModel.ProfID ~= Params.ProfID then
		return
	end

	if nil ~= ProfessionToggleJobVM.SelectedLevelItemVM then
		ProfessionToggleJobVM.SelectedLevelItemVM:SetSelected(false)
	end
	ProfessionToggleJobVM.SelectedLevelItemVM = self.ViewModel
	ProfessionToggleJobVM.SelectedLevelItemVM:SetSelected(true)
end

return ProfessionLevelItemView