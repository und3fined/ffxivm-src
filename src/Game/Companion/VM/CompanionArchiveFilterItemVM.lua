local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")

---@class CompanionArchiveFilterItemVM : UIViewModel
local CompanionArchiveFilterItemVM = LuaClass(UIViewModel)

---Ctor
function CompanionArchiveFilterItemVM:Ctor()
	self.IsSelect = false
    self.Title = nil
    self.Type = nil
    self.Value = nil
end

function CompanionArchiveFilterItemVM:GetSelect()
    return self.IsSelect
end

function CompanionArchiveFilterItemVM:SetSelect(IsSelect)
	self.IsSelect = IsSelect
end

--要返回当前类
return CompanionArchiveFilterItemVM