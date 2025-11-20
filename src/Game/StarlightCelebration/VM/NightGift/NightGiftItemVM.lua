local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local LSTR = _G.LSTR
---@class NightGiftItemVM : UIViewModel
local NightGiftItemVM = LuaClass(UIViewModel)

---Ctor
function NightGiftItemVM:Ctor()
	self.Icon = nil
	self.ScaleBoxIconVisibility = nil
	self.bSelect = nil
	self.IsLock = nil
end

function NightGiftItemVM:UpdateVM(Value)
    self.Icon = Value.IconPath
    self.NormalIcon = Value.IconPath
	self.SelectedIcon = Value.SelectIcon

	self.bSelect = _G.UE.ESlateVisibility.HitTestInvisible
	self.ScaleBoxIconVisibility = 0
end

function NightGiftItemVM:SetSelectIcon()
	self.Icon = self.SelectedIcon
end

function NightGiftItemVM:SetNormalIcon()
	self.Icon = self.NormalIcon
end

function NightGiftItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Icon == self.Icon
end

--要返回当前类
return NightGiftItemVM