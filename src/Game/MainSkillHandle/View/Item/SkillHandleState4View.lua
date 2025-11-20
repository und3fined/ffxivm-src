---
--- Author: henghaoli
--- DateTime: 2025-05-23 14:41
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
	self.HandleStateSelect = {
		Left = self.SkillHandleState1.ImgSelect,
		Up = self.SkillHandleState2.ImgSelect,
		Right = self.SkillHandleState3.ImgSelect,
		Down = self.SkillHandleState4.ImgSelect,
	}
	self.DirectionType = "Hide"
	self:ResetHandleDirectionState()
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

function SkillHandleState4View:GetHandleDirectionView(Key)
	if Key == "InteractiveRight" then
		return self.SkillHandleState3.ImgSelect
	elseif Key == "InteractiveUp" then
		return self.SkillHandleState2.ImgSelect
	elseif Key == "InteractiveDown" then
		return self.SkillHandleState4.ImgSelect
	else
		return self.SkillHandleState1.ImgSelect
	end
end

function SkillHandleState4View:SetHandleDirectionState(Key, Value)
	UIUtil.SetIsVisible(self:GetHandleDirectionView(Key), Value)
end

function SkillHandleState4View:ResetHandleDirectionState()
	UIUtil.SetIsVisible(self.SkillHandleState1.ImgSelect, false)
	UIUtil.SetIsVisible(self.SkillHandleState2.ImgSelect, false)
	UIUtil.SetIsVisible(self.SkillHandleState3.ImgSelect, false)
	UIUtil.SetIsVisible(self.SkillHandleState4.ImgSelect, false)
end

function SkillHandleState4View:SetHandleDirectionType(Type)
	if self.DirectionType == Type then
		return
	end
	self.DirectionType = Type
	if Type then
		self:ResetHandleDirectionState()
		if Type == "Hide" then
			UIUtil.SetIsVisible(self, false)
		elseif Type == "UpAndDown" then
			self:SetHandleDirectionState("InteractiveUp", true)
			self:SetHandleDirectionState("InteractiveDown", true)
			UIUtil.SetIsVisible(self, true)
		else
			self:SetHandleDirectionState(Type, true)
			UIUtil.SetIsVisible(self, true)
		end
	end
end

return SkillHandleState4View