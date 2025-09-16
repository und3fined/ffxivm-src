---
--- Author: chriswang
--- DateTime: 2023-08-31 17:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillTipsMgr = _G.SkillTipsMgr
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")

---@class CrafterAdjustItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdjust UFButton
---@field IconAdjust UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterAdjustItemView = LuaClass(UIView, true)

function CrafterAdjustItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdjust = nil
	--self.IconAdjust = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterAdjustItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterAdjustItemView:OnInit()

end

function CrafterAdjustItemView:OnDestroy()

end

function CrafterAdjustItemView:OnShow()
	self:PlayAnimation(self.AnimShow)
end

function CrafterAdjustItemView:OnHide()
end

function CrafterAdjustItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAdjust, self.OnClickBtnSkill)
	UIUtil.AddOnLongClickedEvent(self, self.BtnAdjust, self.OnLongClicked)
	UIUtil.AddOnLongClickReleasedEvent(self, self.BtnAdjust, self.OnLongClickReleased)

	UIUtil.AddOnPressedEvent(self, self.BtnAdjust, self.OnBtnAdjustPressed)
	UIUtil.AddOnReleasedEvent(self, self.BtnAdjust, self.OnBtnAdjustReleased)
end

function CrafterAdjustItemView:OnRegisterGameEvent()

end

function CrafterAdjustItemView:OnRegisterBinder()

end

function CrafterAdjustItemView:OnSkillReplace(ButtonIndex, SkillID)
	self.ButtonIndex = ButtonIndex	
	self.BtnSkillID = SkillID
	
	local IconPath = SkillMainCfg:FindValue(SkillID, "Icon")
	if IconPath == nil or IconPath == "None" then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.IconAdjust, IconPath)
end

function CrafterAdjustItemView:OnBtnAdjustPressed()
	self.AdjustPanel:SetRenderScale(_G.UE.FVector2D(1, 1) * SkillCommonDefine.SkillBtnClickFeedback)
end

function CrafterAdjustItemView:OnBtnAdjustReleased()
	self.AdjustPanel:SetRenderScale(_G.UE.FVector2D(1, 1))
end

function CrafterAdjustItemView:OnClickBtnSkill()
	_G.CrafterMgr:CastLifeSkill(self.ButtonIndex, self.BtnSkillID)
	FLOG_INFO("==== Crafter RandonEventSkill, Idx:%d - %d", self.ButtonIndex, self.BtnSkillID)
end

function CrafterAdjustItemView:OnLongClicked()
	self.TipsHandleID = SkillTipsMgr:ShowMajorCrafterSkillTips(self.BtnSkillID, self)
end

function CrafterAdjustItemView:OnLongClickReleased()
	if self.TipsHandleID then
		SkillTipsMgr:HideTipsByHandleID(self.TipsHandleID)
		self.TipsHandleID = nil
	end
end

return CrafterAdjustItemView