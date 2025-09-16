---
--- Author: star_lightpaw
--- DateTime: 2025-03-05 16:08
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local InviteSignSideDefine = require("Game/Common/InviteSignSideWin/InviteSignSideDefine")
local MenuValues = InviteSignSideDefine.MenuValues

---@class InviteMenuListItemVM : UIViewModel
local InviteMenuListItemVM = LuaClass(UIViewModel)

---Ctor
function InviteMenuListItemVM:Ctor( )
    self.ID = nil
    self.Icon = ""
    self.IsSelected = false
end

function InviteMenuListItemVM:IsEqualVM( Value )
    return Value ~= nil and self.ID ~= nil and self.ID == Value.ID
end

function InviteMenuListItemVM:UpdateVM( Value )
	self.ID = Value.ID
end

function InviteMenuListItemVM:SetIsSelected( IsSelected )
	self.IsSelected = IsSelected
    self.Icon = IsSelected and MenuValues[self.ID].IconSelect or MenuValues[self.ID].Icon
end

function InviteMenuListItemVM:GetID()
	return self.ID
end

return InviteMenuListItemVM