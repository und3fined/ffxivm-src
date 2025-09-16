---
--- Author: Administrator
--- DateTime: 2024-12-02 10:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local ReportDefine = require("Game/Report/ReportDefine")
local UIViewID = require("Define/UIViewID")

---@class ReportItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommCheckBox_UIBP CommCheckBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ReportItemView = LuaClass(UIView, true)

function ReportItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommCheckBox_UIBP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ReportItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommCheckBox_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ReportItemView:OnInit()
	self.Binders = {
		{ "ReasonsID", UIBinderValueChangedCallback.New(self, nil, self.OnReasonsIDChanged) },
		{ "Selected", UIBinderSetIsChecked.New(self, self.CommCheckBox_UIBP) },
	}
end

function ReportItemView:OnDestroy()

end

function ReportItemView:OnShow()
	
end

function ReportItemView:OnHide()
end

function ReportItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CommCheckBox_UIBP, self.OnCheckBoxStateChanged )
end

function ReportItemView:OnRegisterGameEvent()

end

function ReportItemView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ReportItemView:OnReasonsIDChanged(NewValue)
	self.CommCheckBox_UIBP:SetText((ReportDefine.ReportReasons[NewValue] or {}).Text)
end

function ReportItemView:OnCheckBoxStateChanged(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	local ViewMode = self.ViewModel
	if ViewMode then
		ViewMode.Selected = IsChecked
		local ReportWinView = _G.UIViewMgr:FindView(UIViewID.ReportPanel)
		if ReportWinView ~= nil then
			ReportWinView:SetSelectItemVm(ViewMode)
		end
	end
end

return ReportItemView