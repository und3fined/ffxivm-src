---
--- Author: Administrator
--- DateTime: 2025-03-12 14:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SkillUtil = require("Utils/SkillUtil")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")

---@class SkillSitBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSit UFButton
---@field Icon_Skill UFImage
---@field ImgUpCDmask2 UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillSitBtnView = LuaClass(UIView, true)

function SkillSitBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSit = nil
	--self.Icon_Skill = nil
	--self.ImgUpCDmask2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillSitBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillSitBtnView:OnInit()

end

function SkillSitBtnView:OnDestroy()

end

function SkillSitBtnView:OnShow()
	UIUtil.SetIsVisible(self.BtnSit,true,true)
end

function SkillSitBtnView:OnHide()

end

function SkillSitBtnView:OnRegisterUIEvent()
	SkillUtil.RegisterPressScaleEvent(self, self.BtnSit, SkillCommonDefine.SkillBtnClickFeedback)
end

function SkillSitBtnView:OnRegisterGameEvent()

end

function SkillSitBtnView:OnRegisterBinder()

end

return SkillSitBtnView