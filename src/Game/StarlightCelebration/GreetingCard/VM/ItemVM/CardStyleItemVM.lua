
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local FLOG_WARNING = _G.FLOG_WARNING

---@class CardStyleItemVM: UIViewModel
local CardStyleItemVM = LuaClass(UIViewModel)

function CardStyleItemVM:Ctor()
	self.UnSelectIconPath = ""
    self.Islock = false
	self.IsSelected = false
	self.SelectIconPath = ""
end

function CardStyleItemVM:IsEqualVM(Value)
	return nil ~= Value
end

function CardStyleItemVM:UpdateVM(Value)
    if Value == nil then
        FLOG_WARNING("CardStyleItemVM:UpdateVM Value is nil")
        return
    end

	self.Islock = Value.Islock
	self.SelectIconPath = Value.SelectedIcon
	self.UnSelectIconPath = Value.UnSelectedIcon
end

function CardStyleItemVM:SetIsSelected(Value)
	self.IsSelected = Value == true

end

return CardStyleItemVM