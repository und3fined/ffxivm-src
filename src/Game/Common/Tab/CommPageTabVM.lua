--
-- Author: anypkvcai
-- Date: 2022-05-07 16:20
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class CommPageTabVM : UIViewModel
local CommPageTabVM = LuaClass(UIViewModel)

---Ctor
function CommPageTabVM:Ctor()
	self.Type = nil
	self.Name = nil
	self.Icon = nil
	self.Num = 0
	self.NameVisible = true
	self.RedDotVisible = false
	self.TextVisible = true
	self.NumOpacity = true
end

function CommPageTabVM:IsEqualVM(Value)
	return true
end

---UpdateVM
---@param Value table
function CommPageTabVM:UpdateVM(Value)
	self.Type = Value.Type
	self.Name = Value.Name
	self.Icon = Value.Icon
	self.NumVisible = Value.NumVisible
end

function CommPageTabVM:UpdateNum(Num)
	self.Num = Num or 0
end

function CommPageTabVM:SetTextVisible(IsVisible)
	self.TextVisible = IsVisible
end

return CommPageTabVM