---
--- Author: henghaoli
--- DateTime: 2025-03-13 20:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SkillHandleState4View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field SkillHandleState1 SkillHandleState1View
---@field SkillHandleState2 SkillHandleState1View
---@field SkillHandleState3 SkillHandleState1View
---@field SkillHandleState4 SkillHandleState1View
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillHandleState4View = LuaClass(UIView, true)

function SkillHandleState4View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.SkillHandleState1 = nil
	--self.SkillHandleState2 = nil
	--self.SkillHandleState3 = nil
	--self.SkillHandleState4 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillHandleState4View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SkillHandleState1)
	self:AddSubView(self.SkillHandleState2)
	self:AddSubView(self.SkillHandleState3)
	self:AddSubView(self.SkillHandleState4)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillHandleState4View:OnInit()

end

function SkillHandleState4View:OnDestroy()

end

function SkillHandleState4View:OnShow()

end

function SkillHandleState4View:OnHide()

end

function SkillHandleState4View:OnRegisterUIEvent()

end

function SkillHandleState4View:OnRegisterGameEvent()

end

function SkillHandleState4View:OnRegisterBinder()

end

return SkillHandleState4View