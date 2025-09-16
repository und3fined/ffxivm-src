
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local FLOG_WARNING = _G.FLOG_WARNING

---@class StoreGiftMailStyleItemVM: UIViewModel
local StoreGiftMailStyleItemVM = LuaClass(UIViewModel)

function StoreGiftMailStyleItemVM:Ctor()
	self.IconPath = ""
    self.Islock = false
	self.IsSelected = false
end

function StoreGiftMailStyleItemVM:IsEqualVM(Value)
	return nil ~= Value
end

function StoreGiftMailStyleItemVM:UpdateVM(Value)
    if Value == nil then
        FLOG_WARNING("StoreGiftMailStyleItemVM:UpdateVM Value is nil")
        return
    end
	self.IconPath = Value.IconPath
	self.Islock = Value.Islock
end

function StoreGiftMailStyleItemVM:SetIsSelected(Value)
	self.IsSelected = Value == true and true or false
end

return StoreGiftMailStyleItemVM