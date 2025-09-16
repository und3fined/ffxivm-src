local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")

---@class CompanionCallingSettingItemVM : UIViewModel
local CompanionCallingSettingItemVM = LuaClass(UIViewModel)

---Ctor
function CompanionCallingSettingItemVM:Ctor()
	self.IsSelect = false
    self.Title = nil
    self.Index = nil
    self.Clickable = nil
end

function CompanionCallingSettingItemVM:GetSelect()
    return self.IsSelect
end

function CompanionCallingSettingItemVM:SetSelect(IsSelect)
	self.IsSelect = IsSelect
    self.Clickable = not IsSelect
end

function CompanionCallingSettingItemVM:GetClickable()
    return self.Clickable
end

function CompanionCallingSettingItemVM:SetClickable(Clickable)
    self.Clickable = Clickable
end

--要返回当前类
return CompanionCallingSettingItemVM