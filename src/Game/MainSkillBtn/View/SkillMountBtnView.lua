---
--- Author: chunfengluo
--- DateTime: 2025-01-21 17:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MountVM = require("Game/Mount/VM/MountVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetOpacity = require("Binder/UIBinderSetOpacity")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")

---@class SkillMountBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRun UFButton
---@field Icon_Skill UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillMountBtnView = LuaClass(UIView, true)

function SkillMountBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRun = nil
	--self.Icon_Skill = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillMountBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillMountBtnView:OnInit()

end

function SkillMountBtnView:OnDestroy()

end

function SkillMountBtnView:OnShow()

end

function SkillMountBtnView:OnHide()

end

function SkillMountBtnView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRun, self.OnClick)
end

function SkillMountBtnView:OnRegisterGameEvent()

end

function SkillMountBtnView:OnRegisterBinder()
	local Binders = {
		{ "SkillMountIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_Skill)},
		{ "FlyHigh", UIBinderValueChangedCallback.New(self, nil, self.OnFlyHighStateChange) },
		{ "IsInOtherRide", UIBinderValueChangedCallback.New(self, nil, self.OnIsInOtherRideChange) },
		{ "AllowRide", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateAllowRide)},
		{ "IsInRide", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateIsInRide)},
		{ "AllowGetDownMount", UIBinderValueChangedCallback.New(self, nil, self.UpdateAllowGetDownMount) },
		{ "SkillMountBtnIconOpacity", UIBinderSetOpacity.New(self, self.Icon_Skill)}
	}
	self:RegisterBinders(MountVM, Binders)
end

function SkillMountBtnView:OnClick()
	if MountVM.IsInRide and MountVM.IsMountFall then
		local MajorController = MajorUtil.GetMajorController()
		if MajorController ~= nil then
			MajorController:JumpEnd()
		end
    else
		if MajorUtil.IsMajorInsideWall() then return end

		-- 死亡状态下不支持交互操作
		if MajorUtil.IsMajorDead() == true then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.DeadStateCantControls)
			return
		end

		if MountVM.IsInRide then
			if MountVM.AllowGetDownMount then
				_G.MountMgr:GetDownMount(true)
			else
				MsgTipsUtil.ShowTips(LSTR(1090052))
			end
		else
			_G.MountMgr:SendMountCall()
		end

		if _G.SignsMgr.SceneMarkersMainPanelIsShowing then
			_G.UIViewMgr:HideView(_G.UIViewID.SceneMarkersMainPanel)
		end
		if _G.SignsMgr.TargetSignsMainPanelIsShowing then
			_G.UIViewMgr:HideView(_G.UIViewID.TeamSignsMainPanel)
		end
		if _G.UIViewMgr:IsViewVisible(_G.UIViewID.TeamRollPanel) then
			_G.UIViewMgr:HideView(_G.UIViewID.TeamRollPanel)
		end
		if _G.UIViewMgr:IsViewVisible(_G.UIViewID.BuddyMainPanel) then
			_G.UIViewMgr:HideView(_G.UIViewID.BuddyMainPanel)
		end
    end
end

function SkillMountBtnView:OnFlyHighStateChange(Params)
	MountVM.AllowGetDownMount = not (MountVM.IsInOtherRide and MountVM.FlyHigh)
end

function SkillMountBtnView:OnIsInOtherRideChange(Params)
	MountVM.AllowGetDownMount = not (MountVM.IsInOtherRide and MountVM.FlyHigh)
end

function SkillMountBtnView:OnUpdateIsInRide(Params)
	self:SetIconOpacity()
end

function SkillMountBtnView:OnUpdateAllowRide(Params)
	self:SetIconOpacity()
end

function SkillMountBtnView:UpdateAllowGetDownMount()
	self:SetIconOpacity()
end

function SkillMountBtnView:SetIconOpacity()
	if not MountVM.IsInRide and MountVM.AllowRide or MountVM.IsInRide and MountVM.AllowGetDownMount then
		MountVM.SkillMountBtnIconOpacity = 1
	else
		MountVM.SkillMountBtnIconOpacity = 0.5
	end
end

return SkillMountBtnView