---
--- Author: ashyuan
--- DateTime: 2024-05-08 14:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PworldSkillGuideCfg = require("TableCfg/PworldSkillGuideCfg")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")

---@class PWorldTeachingSkillGuidanceItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GestureSelect TutorialGestureSelectItemView
---@field PanelTipsDown UFCanvasPanel
---@field PanelTipsLeft UFCanvasPanel
---@field PanelTipsRight UFCanvasPanel
---@field PanelTipsSuperior UFCanvasPanel
---@field TextTipsD TutorialGestureTips2ItemView
---@field TextTipsL TutorialGestureTips2ItemView
---@field TextTipsR TutorialGestureTips2ItemView
---@field TextTipsS TutorialGestureTips2ItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldTeachingSkillGuidanceItemView = LuaClass(UIView, true)

function PWorldTeachingSkillGuidanceItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GestureSelect = nil
	--self.PanelTipsDown = nil
	--self.PanelTipsLeft = nil
	--self.PanelTipsRight = nil
	--self.PanelTipsSuperior = nil
	--self.TextTipsD = nil
	--self.TextTipsL = nil
	--self.TextTipsR = nil
	--self.TextTipsS = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldTeachingSkillGuidanceItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GestureSelect)
	self:AddSubView(self.TextTipsD)
	self:AddSubView(self.TextTipsL)
	self:AddSubView(self.TextTipsR)
	self:AddSubView(self.TextTipsS)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldTeachingSkillGuidanceItemView:OnInit()

end

function PWorldTeachingSkillGuidanceItemView:OnDestroy()

end

function PWorldTeachingSkillGuidanceItemView:OnShow()
	-- 防止阻挡技能button
	UIUtil.SetIsVisible(self.GestureSelect.Btn, false)
end

function PWorldTeachingSkillGuidanceItemView:SetSkillInfo(SkillID)

	UIUtil.SetIsVisible(self.TextTipsD, false)
	UIUtil.SetIsVisible(self.TextTipsL, false)
	UIUtil.SetIsVisible(self.TextTipsR, false)
	UIUtil.SetIsVisible(self.TextTipsS, false)

	local SkillGuideCfg = PworldSkillGuideCfg:FindCfgByKey(SkillID)
	if not SkillGuideCfg then
		return
	end

	local Arrow = SkillGuideCfg.Dir
	if Arrow == 0 then
		UIUtil.SetIsVisible(self.TextTipsS, true)
		self.TextTipsS:SetText(SkillGuideCfg.Content)
		self.TextTipsS:NearBySkill(TutorialDefine.TutorialArrowDir.Bottom)
	elseif Arrow == 1 then
		UIUtil.SetIsVisible(self.TextTipsD, true)
		self.TextTipsD:SetText(SkillGuideCfg.Content)
		self.TextTipsD:NearBySkill(TutorialDefine.TutorialArrowDir.Top)
	elseif Arrow == 2 then
		UIUtil.SetIsVisible(self.TextTipsL, true)
		self.TextTipsL:SetText(SkillGuideCfg.Content)
		self.TextTipsL:NearBySkill(TutorialDefine.TutorialArrowDir.Right)
	elseif Arrow == 3 then
		UIUtil.SetIsVisible(self.TextTipsR, true)
		self.TextTipsR:SetText(SkillGuideCfg.Content)
		self.TextTipsR:NearBySkill(TutorialDefine.TutorialArrowDir.Left)
	end
end

function PWorldTeachingSkillGuidanceItemView:SetSelecetScale(Scale)
	self.GestureSelect:SetRenderScale(_G.UE.FVector2D(Scale, Scale))
end

function PWorldTeachingSkillGuidanceItemView:OnHide()

end

function PWorldTeachingSkillGuidanceItemView:OnRegisterUIEvent()

end

function PWorldTeachingSkillGuidanceItemView:OnRegisterGameEvent()
end

function PWorldTeachingSkillGuidanceItemView:OnRegisterBinder()

end

function PWorldTeachingSkillGuidanceItemView:OnRegisterBinder()

end

return PWorldTeachingSkillGuidanceItemView