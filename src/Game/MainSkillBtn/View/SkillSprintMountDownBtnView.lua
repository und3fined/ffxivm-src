---
--- Author: chunfengluo
--- DateTime: 2025-01-21 17:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MountVM = require("Game/Mount/VM/MountVM")
local MajorUtil = require("Utils/MajorUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local LSTR = _G.LSTR

---@class SkillSprintMountDownBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRun UFButton
---@field Icon_Skill UFImage
---@field ImgUpCDmask UFImage
---@field TextCD UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillSprintMountDownBtnView = LuaClass(UIView, true)

function SkillSprintMountDownBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRun = nil
	--self.Icon_Skill = nil
	--self.ImgUpCDmask = nil
	--self.TextCD = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillSprintMountDownBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillSprintMountDownBtnView:OnInit()

end

function SkillSprintMountDownBtnView:OnDestroy()

end

function SkillSprintMountDownBtnView:OnShow()

end

function SkillSprintMountDownBtnView:OnHide()

end

function SkillSprintMountDownBtnView:OnRegisterUIEvent()

end

function SkillSprintMountDownBtnView:OnRegisterGameEvent()

end

function SkillSprintMountDownBtnView:OnRegisterBinder()

end

return SkillSprintMountDownBtnView