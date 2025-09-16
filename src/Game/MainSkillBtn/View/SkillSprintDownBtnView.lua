---
--- Author: chunfengluo
--- DateTime: 2025-01-21 17:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local SkillUtil = require("Utils/SkillUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local SkillSprintDownBtnVM = require("Game/MainSkillBtn/VM/SkillSprintDownBtnVM")

local ProtoCommon = require("Protocol/ProtoCommon")


local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")

---@class SkillSprintDownBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRun UFButton
---@field Icon_Skill UFImage
---@field ImgUpCDmask UFImage
---@field TextCD UFTextBlock
---@field AnimPrompt UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillSprintDownBtnView = LuaClass(UIView, true)

function SkillSprintDownBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRun = nil
	--self.Icon_Skill = nil
	--self.ImgUpCDmask = nil
	--self.TextCD = nil
	--self.AnimPrompt = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillSprintDownBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillSprintDownBtnView:OnInit()
	self.SkillIndex = 10	--技能组表加速技能
	self.SkillID = 0
end

function SkillSprintDownBtnView:OnDestroy()

end

function SkillSprintDownBtnView:OnShow()

	local ParentView = rawget(self, "ParentView")
	local EntityID = ParentView.EntityID
	if EntityID == nil or EntityID == 0 then
		EntityID = MajorUtil.GetMajorEntityID()
	end
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(EntityID)
	if LogicData then
		self.SkillID = LogicData:GetBtnSkillID(self.SkillIndex)
	else
		self.SkillID = 0
	end
end

function SkillSprintDownBtnView:OnHide()

end

function SkillSprintDownBtnView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRun, self.OnBtnClick)
	SkillUtil.RegisterPressScaleEvent(self, self.BtnRun, SkillCommonDefine.SkillBtnClickFeedback)
end

function SkillSprintDownBtnView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SkillCDUpdateLua, self.OnSkillCDUpdate)
	self:RegisterGameEvent(EventID.SkillReplace, self.OnSkillReplace)
	self:RegisterGameEvent(EventID.InputActionSkillPressed, self.OnInputActionSkillPressed)
end

function SkillSprintDownBtnView:OnRegisterBinder()

	local Binders = {
		{"SkillCD", UIBinderSetText.New(self, self.TextCD)},
		{"bSkillValid", UIBinderSetIsVisible.New(self, self.ImgUpCDmask, true)},
	}
	self.SkillSprintDownBtnVM = SkillSprintDownBtnVM.New()
	self:RegisterBinders(self.SkillSprintDownBtnVM, Binders)
end

function SkillSprintDownBtnView:OnBtnClick()
	if self.SkillSprintDownBtnVM:IsSkillValid() then
		if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_USE_SKILL, true) then
			return
		end
		local BtnIndex = self.SkillIndex
		local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
		if LogicData and LogicData:CanCastSkill(BtnIndex, true) then
			if self.SkillID == 0 then
				self.SkillID = LogicData:GetBtnSkillID(self.SkillIndex)
			end
			SkillUtil.CastNormalSkillDirect(self.SkillID, BtnIndex)
		end
	end
end


function SkillSprintDownBtnView:OnSkillCDUpdate(Params)
	if Params.SkillID == self.SkillID then
		self.SkillSprintDownBtnVM:SetSkillCD(Params.SkillCD)
		if Params.SkillCD <= 0 then
			self:PlayAnimation(self.AnimPrompt)
		end
	end
end

function SkillSprintDownBtnView:OnSkillReplace(Params)
	if Params.SkillIndex == self.SkillIndex then
		self.SkillID = Params.SkillID
		local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
		if LogicData then
			LogicData:UpdateAllStateList(Params.SkillIndex, Params.SkillID)
			LogicData:RefreshAllAffectedFlag(Params.SkillIndex, Params.SkillID)
		end
		self.SkillSprintDownBtnVM:SetSkillCD(_G.SkillCDMgr:GetSkillRealCDValue(Params.SkillID))
	end
end

function SkillSprintDownBtnView:OnInputActionSkillPressed(Params)
	if Params ~= self.SkillIndex then return end

	self:OnBtnClick()
end

return SkillSprintDownBtnView