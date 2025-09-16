---
--- Author: henghaoli
--- DateTime: 2025-03-15 16:54
--- Description:
---

local LuaClass = require("Core/LuaClass")
local SkillCustomBtnBaseView = require("Game/Skill/View/Item/SkillCustomBtnBaseView")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIUtil = require("Utils/UIUtil")

---@class SkillCustomGenAttackBtnView : SkillCustomBtnBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAttack UFButton
---@field ImgBtnBase UImage
---@field ImgProfSign UImage
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillCustomGenAttackBtnView = LuaClass(SkillCustomBtnBaseView, true)

function SkillCustomGenAttackBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAttack = nil
	--self.ImgBtnBase = nil
	--self.ImgProfSign = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillCustomGenAttackBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillCustomGenAttackBtnView:OnInit()
	self.Super:OnInit()
	self.Binders = {
		{ "SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgProfSign) },
		{ "Scale", UIBinderValueChangedCallback.New(self, nil, self.OnScaleChanged) },
	}
end

function SkillCustomGenAttackBtnView:OnDestroy()

end

function SkillCustomGenAttackBtnView:OnShow()
	-- self.Super:OnShow()
	UIUtil.SetIsVisible(self.BtnAttack, true, false)
end

function SkillCustomGenAttackBtnView:OnHide()

end

function SkillCustomGenAttackBtnView:OnRegisterUIEvent()

end

function SkillCustomGenAttackBtnView:OnRegisterGameEvent()

end

function SkillCustomGenAttackBtnView:OnRegisterBinder()
	self:RegisterBinders(self.VM, self.Binders)
end

return SkillCustomGenAttackBtnView