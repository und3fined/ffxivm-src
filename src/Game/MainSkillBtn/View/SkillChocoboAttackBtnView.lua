---
--- Author: sammrli
--- DateTime: 2025-03-20 19:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SkillChocoboAttackBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn_Attack UFButton
---@field ImgBtnBase UImage
---@field Img_CD URadialImage
---@field Img_ProfSign UImage
---@field PanelCD UFCanvasPanel
---@field Text_SkillCD UFTextBlock
---@field AnimClick UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillChocoboAttackBtnView = LuaClass(UIView, true)

function SkillChocoboAttackBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn_Attack = nil
	--self.ImgBtnBase = nil
	--self.Img_CD = nil
	--self.Img_ProfSign = nil
	--self.PanelCD = nil
	--self.Text_SkillCD = nil
	--self.AnimClick = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillChocoboAttackBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillChocoboAttackBtnView:OnInit()

end

function SkillChocoboAttackBtnView:OnDestroy()

end

function SkillChocoboAttackBtnView:OnShow()

end

function SkillChocoboAttackBtnView:OnHide()

end

function SkillChocoboAttackBtnView:OnRegisterUIEvent()

end

function SkillChocoboAttackBtnView:OnRegisterGameEvent()

end

function SkillChocoboAttackBtnView:OnRegisterBinder()

end

function SkillChocoboAttackBtnView:SetDisabled(Enabled)
	if Enabled then
		UIUtil.SetOpacity(self.ImgBtnBase, 0.5)
		UIUtil.SetOpacity(self.Img_ProfSign, 0.5)
	else
		UIUtil.SetOpacity(self.ImgBtnBase, 1)
		UIUtil.SetOpacity(self.Img_ProfSign, 1)
	end
end

return SkillChocoboAttackBtnView