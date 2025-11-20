local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EToggleButtonState = _G.UE.EToggleButtonState

local LSTR = _G.LSTR
---@class OpsGirlsDayStarTabItemVM : UIViewModel
local OpsGirlsDayStarTabItemVM = LuaClass(UIViewModel)

---Ctor
function OpsGirlsDayStarTabItemVM:Ctor()
	self.TaskTitle = nil
	self.LockVisible = nil
	self.bIsSelect = nil
	self.ReveivedVisible = nil
end

function OpsGirlsDayStarTabItemVM:UpdateVM(Value)
	self.TaskTitle = Value.TaskTitle
	self.LockVisible = Value.LockVisible
    self.ReveivedVisible = Value.ReveivedVisible
    self.bIsSelect = Value.bIsSelect
end

function OpsGirlsDayStarTabItemVM:SetSelect()
	self.bIsSelect = true
end

function OpsGirlsDayStarTabItemVM:SetNormal()
	self.bIsSelect = false
end

function OpsGirlsDayStarTabItemVM:IsEqualVM(Value)
    return true
end

--要返回当前类
return OpsGirlsDayStarTabItemVM