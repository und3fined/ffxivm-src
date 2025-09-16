---
--- Author: anypkvcai
--- DateTime: 2021-02-07 20:35
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local LSTR = _G.LSTR

local ProtoCommon = require("Protocol/ProtoCommon")
local RoleGender = ProtoCommon.role_gender

---@class UIBinderSetGenderName : UIBinder
local UIBinderSetGenderName = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetGenderName:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetGenderName:OnValueChanged(NewValue, OldValue)
	local Gender = NewValue
	local Name = self:GetGenderName(Gender)

	self.Widget:SetText(Name)
end

---GetGenderName
---@param Gender number
---@return string
function UIBinderSetGenderName:GetGenderName(Gender)
	if RoleGender.GENDER_MALE == Gender then
		return LSTR(10059) -- 男
	elseif RoleGender.GENDER_FEMALE == Gender then
		return LSTR(10060) -- 女
	else
		return LSTR(10061) -- 通用
	end
end

return UIBinderSetGenderName