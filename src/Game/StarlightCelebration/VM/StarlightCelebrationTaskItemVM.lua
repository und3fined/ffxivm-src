local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EToggleButtonState = _G.UE.EToggleButtonState

local LSTR = _G.LSTR
---@class StarlightCelebrationTaskItemVM : UIViewModel
local StarlightCelebrationTaskItemVM = LuaClass(UIViewModel)

---Ctor
function StarlightCelebrationTaskItemVM:Ctor()
	self.TaskNumber = nil
	self.LockVisible = nil
	self.TaskColor = nil
	self.bIsSelect = EToggleButtonState.UnChecked
end

function StarlightCelebrationTaskItemVM:UpdateVM(Value)
	self.TaskNumber = Value.Index
	self.LockVisible = Value.Lock
end

function StarlightCelebrationTaskItemVM:SetSelect()
	self.bIsSelect = EToggleButtonState.Checked
	self.TaskColor = "#fff5cb"
end

function StarlightCelebrationTaskItemVM:SetNormal()
	self.bIsSelect = EToggleButtonState.UnChecked
	self.TaskColor = "#313131"
end

function StarlightCelebrationTaskItemVM:IsSelect()
	return self.bIsSelect == EToggleButtonState.Checked
end

function StarlightCelebrationTaskItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Index == self.TaskNumber
end

--要返回当前类
return StarlightCelebrationTaskItemVM