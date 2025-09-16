---
--- Author: Administrator
--- DateTime: 2024-07-08 14:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local PhotoDefine = require("Game/Photo/PhotoDefine")
local PhotoMgr
local FVector2D = _G.UE.FVector2D
local PhotoVM
local PhotoCamVM
local PhotoFilterVM
local PhotoDarkEdgeVM
local PhotoRoleSettingVM
local PhotoSceneVM
local PhotoTemplateVM
local PhotoActionVM
local PhotoEmojiVM
local PhotoRoleStatVM

local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetRenderTransformAngle = require("Binder/UIBinderSetRenderTransformAngle")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")

---@class PhotoRolePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
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

	self.FTextBlock_112:SetText(_G.LSTR(630058))


	PhotoRoleSettingVM = _G.PhotoRoleSettingVM

	self.AdpRoleSettingTree     = UIAdapterTreeView.CreateAdapter(self, self.TreeViewRole)

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
		{ "SubUIIdx", 			UIBinderValueChangedCallback.New(self, nil, self.OnBindSubUIIdx) },
	}
end

function PhotoRolePanelView:OnDestroy()

end

function PhotoRolePanelView:OnShow()
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
	-- print('Andre.PhotoMainView.OnTogGroupRoleSet Idx = ' .. tostring(Idx))
	PhotoRoleSettingVM:SetSubUIIdx(Idx)
end

local LastShowTime = nil
local function ShowTips(Content)
    if LastShowTime then
        local Now = TimeUtil.GetLocalTime()
        if Now - LastShowTime <= 5 then
            return
        end
    end

    MsgTipsUtil.ShowTips(Content)
    LastShowTime = TimeUtil.GetLocalTime()
end

function PhotoRolePanelView:OnValueChangedSlider(_, Value)
	if not _G.PhotoMgr:IsCurSeltMajor() then
        ShowTips(_G.LSTR(630057))
    end

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