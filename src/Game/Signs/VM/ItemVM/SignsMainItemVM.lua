---
--- Author: ds_tianjiateng
--- DateTime: 2024-03-12 19:21
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local SignsSlotItemVM = require("Game/Signs/VM/ItemVM/SignsSlotItemVM")

---@class SignsMainItemVM : UIViewModel
local SignsMainItemVM = LuaClass(UIViewModel)


function SignsMainItemVM:Ctor()
	self.TittleText = nil
	self.Index = nil
	self.ID = 0
	self.TittleTextVisible = false
	self.PanelItemVisible = false
	self.SignsSlots = UIBindableList.New(SignsSlotItemVM)
end

function SignsMainItemVM:UpdateVM(Value)
	local Children = Value.Children
	if Children == nil then
		self.TittleText = Value.Tittle
	end
	self.Index = Value.Index
	self.ID = Value.Index
	self.TittleTextVisible = Children == nil
	self.PanelItemVisible = Children ~= nil
	self.SignsSlots:UpdateByValues(Children)
end

function SignsMainItemVM:OnShutdown()
	
end

return SignsMainItemVM