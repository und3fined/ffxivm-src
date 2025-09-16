---
--- Author: chriswang
--- DateTime: 2025-03-17 11:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local SkillUtil = require("Utils/SkillUtil")
local MajorUtil = require("Utils/MajorUtil")

---@class SkillLimitBackGenAttackBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAttack UFButton
---@field ImgBtnBase UImage
---@field ImgProfSign UImage
---@field ImgSwitch UImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillLimitBackGenAttackBtnView = LuaClass(UIView, true)

function SkillLimitBackGenAttackBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAttack = nil
	--self.ImgBtnBase = nil
	--self.ImgProfSign = nil
	--self.ImgSwitch = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillLimitBackGenAttackBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillLimitBackGenAttackBtnView:OnInit()

end

function SkillLimitBackGenAttackBtnView:OnDestroy()

end

function SkillLimitBackGenAttackBtnView:OnShow()
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(MajorUtil.GetMajorEntityID())
	if LogicData == nil then
		return
	end
	local SkillID = LogicData:GetBtnSkillID(0)
	SkillUtil.ChangeSkillIcon(SkillID, self.ImgProfSign)
end

function SkillLimitBackGenAttackBtnView:OnHide()

end

function SkillLimitBackGenAttackBtnView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAttack, self.OnBtnAttackClick)
end

function SkillLimitBackGenAttackBtnView:OnRegisterGameEvent()

end

function SkillLimitBackGenAttackBtnView:OnRegisterBinder()

end

function SkillLimitBackGenAttackBtnView:OnBtnAttackClick()
	_G.EventMgr:SendEvent(EventID.SkillLimitCancelBtnClick)
end

return SkillLimitBackGenAttackBtnView