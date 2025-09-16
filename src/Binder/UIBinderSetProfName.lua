---
--- Author: anypkvcai
--- DateTime: 2021-02-07 20:35
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

---@class UIBinderSetProfName : UIBinder
local UIBinderSetProfName = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetProfName:Ctor(View, Widget, NeedCheckUnlock)
	self.NeedCheckUnlock = NeedCheckUnlock
end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetProfName:OnValueChanged(NewValue, OldValue)
	local ProfID = NewValue

	local Name = RoleInitCfg:FindRoleInitProfName(ProfID)
	if self.NeedCheckUnlock then
		local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
		if (nil == RoleDetail or nil == RoleDetail.Prof.ProfList[ProfID]) and Name then
			Name = string.format(LSTR(1050172), Name)
		end
	end
	self.Widget:SetText(Name)
end

return UIBinderSetProfName