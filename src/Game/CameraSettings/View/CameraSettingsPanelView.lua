---
--- Author: zimuyi
--- DateTime: 2023-08-21 19:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CameraSettingsPanelVM = require("Game/CameraSettings/VM/CameraSettingsPanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class CameraSettingsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnFold UToggleButton
---@field TableViewGroups UTableView
---@field AnimFold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CameraSettingsPanelView = LuaClass(UIView, true)

function CameraSettingsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnFold = nil
	--self.TableViewGroups = nil
	--self.AnimFold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CameraSettingsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CameraSettingsPanelView:OnInit()
	self.ViewModel = CameraSettingsPanelVM.New()
	self.AdapterTableViewGroups = UIAdapterTableView.CreateAdapter(self, self.TableViewGroups)
	self.Binders =
	{
		{ "SettingsGroupVMList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewGroups) },
	}
end

function CameraSettingsPanelView:OnDestroy()

end

function CameraSettingsPanelView:OnShow()
	self.ViewModel:GenerateSettingsGroups()
end

function CameraSettingsPanelView:OnHide()

end

function CameraSettingsPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.BtnFold, self.OnFoldClicked)
end

function CameraSettingsPanelView:OnRegisterGameEvent()

end

function CameraSettingsPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CameraSettingsPanelView:OnFoldClicked(ToggleButton, ButtonState)
	local bHidePanel = ButtonState == _G.UE.EToggleButtonState.Checked
	if bHidePanel then
		self:PlayAnimation(self.AnimFold)
	else
		self:PlayAnimationReverse(self.AnimFold)
	end
end

return CameraSettingsPanelView