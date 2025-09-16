local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

---@class LoginCreatePrefixItemVM : UIViewModel
local LoginCreatePrefixItemVM = LuaClass(UIViewModel)


function LoginCreatePrefixItemVM:Ctor()
    self.TextTitle = ""
    self.bItemSelect = false

    self.SubType = nil
    self.MaxValue = nil
end

function LoginCreatePrefixItemVM:SetItemData(PrefixItem)
    self.TextTitle = PrefixItem.Name
    self.SubType = PrefixItem.Index
    self.MaxValue = PrefixItem.MaxValue
end

function LoginCreatePrefixItemVM:SetItemSelected(IsSelected)
    self.bItemSelect = IsSelected
end
return LoginCreatePrefixItemVM