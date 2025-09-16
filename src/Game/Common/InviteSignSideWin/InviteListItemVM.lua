---
--- Author: star_lightpaw
--- DateTime: 2025-03-05 16:08
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SimpleProfInfoVM = require("Game/Profession/VM/SimpleProfInfoVM")
local ActorUtil = require("Utils/ActorUtil")

---@class InviteListItemVM: UIViewModel
local InviteListItemVM = LuaClass(UIViewModel)


---Ctor
function InviteListItemVM:Ctor()
	self.RoleID     = nil
    self.Name       = "" 
    self.ProfID     = nil
	self.Level 		= 0							--TODO DELETE IT
    self.ProfInfoVM = SimpleProfInfoVM.New()	--#TODO DELETE IT 
    self.ItemType   = nil
    self.FilterKeyword   = nil
    self.BtnIcon   = nil
end

---@param V InviteListItemVM
function InviteListItemVM:IsEqualVM(V)
	-- return V and V.RoleID == self.RoleID
	return false
end

---UpdateVM
---@param Value table @RoleVM
function InviteListItemVM:UpdateVM(Value)
    self.RoleID 	= Value.RoleID
	local RVM = _G.RoleInfoMgr:FindRoleVM(self.RoleID, true)
	self.Name       = RVM.Name or ""
    self.ProfID     = RVM.Prof
	self.Level 		= RVM.Level
    self.ProfInfoVM:UpdateVM(self)
    self.FilterKeyword = Value.FilterKeyword
    self.ItemType   = Value.ItemType
    self.BtnIcon   = Value.BtnIcon
end

function InviteListItemVM:AdapterOnGetCanBeSelected()
	return false
end

function InviteListItemVM:AdapterOnGetWidgetIndex()
	return 1
end

return InviteListItemVM