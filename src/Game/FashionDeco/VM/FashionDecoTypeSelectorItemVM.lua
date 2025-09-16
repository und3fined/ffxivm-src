---
--- Author: ccppeng
--- DateTime: 2024-11-1 19:53
--- Description:
---

local LuaClass = require("Core/LuaClass")
local FashionDecoUtil = require("Game/FashionDeco/VM/FashionDecoUtil")
local UIViewModel = require("UI/UIViewModel")

---@class FashionDecoTypeSelectorItemVM : UIViewModel
local FashionDecoTypeSelectorItemVM = LuaClass(UIViewModel)

---Ctor
function FashionDecoTypeSelectorItemVM:Ctor( )
	self.TypeID = nil
	self.Name = nil
	self.Icon = nil
	self.NormalIcon = nil
	self.SelectedIcon = nil
end

function FashionDecoTypeSelectorItemVM:IsEqualVM(Value)
	return false
end

function FashionDecoTypeSelectorItemVM:UpdateVM(Value,param)

	self.TypeID = Value

	local Config = FashionDecoUtil.FindFashionDecoTypeConfigByType(Value)
	if nil == Config then
		return
	end
	self.NormalIcon = Config.NormalIcon
	self.SelectedIcon = Config.SelectedIcon
	self.Icon = self.NormalIcon
	self.Name = Config.Name
	self.bSelect = _G.UE.ESlateVisibility.HitTestInvisible

	self.ScaleBoxIconVisibility = 0
end
function FashionDecoTypeSelectorItemVM:SetSelectIcon()
	self.Icon = self.SelectedIcon
end
function FashionDecoTypeSelectorItemVM:SetNormalIcon()
	self.Icon = self.NormalIcon
end

function FashionDecoTypeSelectorItemVM:SetName(Name)
	self.Name = Name or ""
end

function FashionDecoTypeSelectorItemVM:GetRawName()
	return self.Name or ""
end

function FashionDecoTypeSelectorItemVM:AdapterOnGetIsVisible()

	return true
end

return FashionDecoTypeSelectorItemVM