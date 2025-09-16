---
--- Author: kanohchen
--- DateTime: 2024-08-19 18:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local LSTR = _G.LSTR

---@class SystemUnlockSkillPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconJob UFImage
---@field ImgSkill UFImage
---@field TextSkillUnlock UFTextBlock
---@field TextTitle UFTextBlock
---@field FCanvasPanel_18 UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SystemUnlockSkillPanelView = LuaClass(UIView, true)

function SystemUnlockSkillPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconJob = nil
	--self.ImgSkill = nil
	--self.TextSkillUnlock = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SystemUnlockSkillPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SystemUnlockSkillPanelView:OnInit()
	self.StartPos = UIUtil.CanvasSlotGetPosition(self.FCanvasPanel_18)
	self.IconJobVisible = true
end

function SystemUnlockSkillPanelView:OnDestroy()

end

function SystemUnlockSkillPanelView:OnShow()
	if self.Params == nil then
		return
	end
	UIUtil.CanvasSlotSetPosition(self.FCanvasPanel_18, self.StartPos)
	local Params = self.Params
	if Params.IconSkill then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgSkill, Params.IconSkill)
	end
	if Params.IconJob then
		if not self.IconJobVisible then
			UIUtil.SetIsVisible(self.IconJob, true)
			self.IconJobVisible = true
		end
		UIUtil.ImageSetBrushFromAssetPath(self.IconJob, Params.IconJob)
	else
		UIUtil.SetIsVisible(self.IconJob, false)
		self.IconJobVisible = false
	end
	self.TextTitle:SetText(LSTR(Params.SkillName))
	self.TextSkillUnlock:SetText(string.format("%s", LSTR(140084))) --技能解锁

	--显示3s消失
	self:RegisterTimer(function()
		if Params == nil then
			return
		end
		_G.ModuleOpenMgr:OnAllMotionOver()
		_G.EventMgr:SendEvent(_G.EventID.ModuleOpenNotify, Params.ID)
		self:Hide()
	end, 3.0)
end

function SystemUnlockSkillPanelView:OnHide()

end

function SystemUnlockSkillPanelView:OnRegisterUIEvent()

end

function SystemUnlockSkillPanelView:OnRegisterGameEvent()

end

function SystemUnlockSkillPanelView:OnRegisterBinder()

end

return SystemUnlockSkillPanelView