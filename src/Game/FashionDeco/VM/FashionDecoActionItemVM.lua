---
--- Author: ccppeng
--- DateTime: 2024-11-1 19:53
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FashionDecoActionItemVM : UIViewModel
local FashionDecoActionItemVM = LuaClass(UIViewModel)

---Ctor
function FashionDecoActionItemVM:Ctor( )
	self.AppearanceIcon = nil
	self.HumanActionTimelinePath = nil
end

function FashionDecoActionItemVM:IsEqualVM(Value)
	return false
end

function FashionDecoActionItemVM:UpdateVM(Value,param)
	self.AppearanceIcon = Value.Icon
	self.HumanActionTimelinePath = Value.HumanActionTimelinePath
	self.ID = Value.ID
	self.cd = Value.cd
	self.ChangeState = Value.ChangeState
end

function FashionDecoActionItemVM:SetName(Name)
	self.Name = Name or ""
end

function FashionDecoActionItemVM:GetRawName()
	return self.Name or ""
end

function FashionDecoActionItemVM:AdapterOnGetIsVisible()

	return true
end
function FashionDecoActionItemVM:AdapterOnGetCanBeSelected()
	return true
end


return FashionDecoActionItemVM