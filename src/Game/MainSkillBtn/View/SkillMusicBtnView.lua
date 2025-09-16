---
--- Author: chunfengluo
--- DateTime: 2025-01-21 17:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SkillMusicBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRun UFButton
---@field FImg_CDNormal UFImage
---@field Icon_Skill UFImage
---@field Img_CD URadialImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillMusicBtnView = LuaClass(UIView, true)

function SkillMusicBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRun = nil
	--self.FImg_CDNormal = nil
	--self.Icon_Skill = nil
	--self.Img_CD = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillMusicBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillMusicBtnView:OnInit()

end

function SkillMusicBtnView:OnDestroy()

end

function SkillMusicBtnView:OnShow()
	self:SetSelfButtonIcon()
end

function SkillMusicBtnView:OnHide()

end

function SkillMusicBtnView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRun, self.OnClick)
end

function SkillMusicBtnView:OnRegisterGameEvent()

end

function SkillMusicBtnView:OnRegisterBinder()
end

function SkillMusicBtnView:SetSelfButtonIcon()
	if _G.MountMgr:CheckBgmIsPlay() then
		UIUtil.ImageSetBrushFromAssetPath(self.Icon_Skill, "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Mount_Btn_OpenMusic_png.UI_Skill_Mount_Btn_OpenMusic_png'")
	else
		UIUtil.ImageSetBrushFromAssetPath(self.Icon_Skill, "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Mount_Btn_CloseMusic_png.UI_Skill_Mount_Btn_CloseMusic_png'")
	end
end

function SkillMusicBtnView:SetButtonState(IsPlay)
	if IsPlay then
		UIUtil.ImageSetBrushFromAssetPath(self.Icon_Skill, "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Mount_Btn_OpenMusic_png.UI_Skill_Mount_Btn_OpenMusic_png'")
	else
		UIUtil.ImageSetBrushFromAssetPath(self.Icon_Skill, "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Mount_Btn_CloseMusic_png.UI_Skill_Mount_Btn_CloseMusic_png'")
	end
end

function SkillMusicBtnView:OnClick()
	local IsPlay = _G.MountMgr:CheckBgmIsPlay()
	_G.MountMgr:QuickPlayOrStopMountBGM(not IsPlay)
	self:SetSelfButtonIcon()
end

return SkillMusicBtnView