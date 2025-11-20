---
--- Author: Administrator
--- DateTime: 2024-07-08 14:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PhotoDefine = require("Game/Photo/PhotoDefine")

local PhotoMgr
local PhotoRoleSettingVM

---@class PhotoRolePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FTextBlock_112 UFTextBlock
---@field PanelAngle UFCanvasPanel
---@field PanelRole UFCanvasPanel
---@field ProbarAngle UFProgressBar
---@field Slider USlider
---@field TextAngleNumber UFTextBlock
---@field TreeViewRole UFTreeView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoRolePanelView = LuaClass(UIView, true)

function PhotoRolePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FTextBlock_112 = nil
	--self.PanelAngle = nil
	--self.PanelRole = nil
	--self.ProbarAngle = nil
	--self.Slider = nil
	--self.TextAngleNumber = nil
	--self.TreeViewRole = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoRolePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoRolePanelView:OnInit()
	PhotoRoleSettingVM = _G.PhotoRoleSettingVM
	PhotoMgr = _G.PhotoMgr

	self.FTextBlock_112:SetText(_G.LSTR(630058))
	self.AdpRoleSettingTree = UIAdapterTreeView.CreateAdapter(self, self.TreeViewRole)
	self.RoleSubPanelDict = {
		[0] = self.PanelRoleFace,
		[1] = self.TreeViewRole,
	}

	self.BinderRoleSetting =
	{
		{ "CtrlTypeTree", 		UIBinderUpdateBindableList.New(self, self.AdpRoleSettingTree) },
		{ "MajorAngleIdx", 		UIBinderSetSlider.New(self, self.Slider) },
		{ "MajorAngle", 		UIBinderSetText.New(self, self.TextAngleNumber) },
		-- { "IsRepeatLastCast", 	UIBinderSetIsChecked.New(self, self.TogRepeatCast) },
		-- { "IsCustomLookAt", 	UIBinderSetIsChecked.New(self, self.TogCustomLookAt) },
		-- { "SubUIIdx", 			UIBinderValueChangedCallback.New(self, nil, self.OnBindSubUIIdx) },
		{ "ProbarIsVisibility", UIBinderSetIsVisible.New(self, self.PanelAngle) },
	}
end

function PhotoRolePanelView:OnDestroy()

end

function PhotoRolePanelView:OnShow()
	PhotoRoleSettingVM.ProbarIsVisibility = PhotoMgr:IsCurSeltMajor()
end

function PhotoRolePanelView:OnHide()

end

function PhotoRolePanelView:OnRegisterUIEvent()
	-- UIUtil.AddOnStateChangedEvent(self, 		self.ToggleGroupRole, 		self.OnTogGroupRoleSet)

	UIUtil.AddOnValueChangedEvent(self, 		self.Slider, 				self.OnValueChangedSlider)
	-- UIUtil.AddOnClickedEvent(self,              self.TogRepeatCast,    		self.OnTogRepeatCast)
	-- UIUtil.AddOnClickedEvent(self,              self.TogCustomLookAt,    	self.OnTogCustomLookAt)
end

function PhotoRolePanelView:OnRegisterGameEvent()
end

function PhotoRolePanelView:OnRegisterBinder()
	self:RegisterBinders(PhotoRoleSettingVM, 	self.BinderRoleSetting)

end

function PhotoRolePanelView:OnTogGroupRoleSet(TogGroup, TogBtn, Idx, Stat)
	PhotoRoleSettingVM:SetSubUIIdx(Idx)
end

function PhotoRolePanelView:OnValueChangedSlider(_, Value)
	PhotoRoleSettingVM:SetMajorAngleIdx(Value)
end

function PhotoRolePanelView:OnTogRepeatCast(Tog, Stat)
	PhotoRoleSettingVM:SetIsRepeatLastCast(not PhotoRoleSettingVM.IsRepeatLastCast)
end

function PhotoRolePanelView:OnTogCustomLookAt(Tog, Stat)
	PhotoRoleSettingVM:SetIsCustomLookAt(not PhotoRoleSettingVM.IsCustomLookAt)
end

function PhotoRolePanelView:OnBindSubUIIdx()
	local Idx = PhotoRoleSettingVM.SubUIIdx

	-- for K, View in pairs(self.RoleSubPanelDict) do
	-- 	UIUtil.SetIsVisible(View, K == Idx)
	-- end
end

return PhotoRolePanelView