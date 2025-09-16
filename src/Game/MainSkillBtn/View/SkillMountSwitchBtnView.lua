---
--- Author: chunfengluo
--- DateTime: 2025-02-06 14:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MountVM = require("Game/Mount/VM/MountVM")

---@class SkillMountSwitchBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn_Attack UFButton
---@field ImgBtnBase UImage
---@field Img_ProfSign UImage
---@field AnimClick UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillMountSwitchBtnView = LuaClass(UIView, true)

function SkillMountSwitchBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn_Attack = nil
	--self.ImgBtnBase = nil
	--self.Img_ProfSign = nil
	--self.AnimClick = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillMountSwitchBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillMountSwitchBtnView:OnInit()

end

function SkillMountSwitchBtnView:OnDestroy()

end

function SkillMountSwitchBtnView:OnShow()

end

function SkillMountSwitchBtnView:OnHide()

end

function SkillMountSwitchBtnView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.Btn_Attack, self.OnClick)
end

function SkillMountSwitchBtnView:OnRegisterGameEvent()

end

function SkillMountSwitchBtnView:OnRegisterBinder()
	local Binders = {
		{ "IsHostRideFull", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateHostRideFull) },
	}
	self:RegisterBinders(MountVM, Binders)
end

function SkillMountSwitchBtnView:OnClick()
	_G.MountMgr:SendMountNextSeat()
end

function SkillMountSwitchBtnView:OnUpdateHostRideFull()
	if MountVM.IsHostRideFull then
		UIUtil.SetOpacity(self.Img_ProfSign, 0.5)
	else
		UIUtil.SetOpacity(self.Img_ProfSign, 1)
	end
end

return SkillMountSwitchBtnView