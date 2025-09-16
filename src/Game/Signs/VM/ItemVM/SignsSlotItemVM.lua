---
--- Author: ds_tianjiateng
--- DateTime: 2024-03-12 19:21
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class SignsSlotItemVM : UIViewModel
local SignsSlotItemVM = LuaClass(UIViewModel)

---Ctor
function SignsSlotItemVM:Ctor()
	self.ID = nil
	self.IconPath = nil
	self.IsSelected = false
	self.IsUsed = false
	self.ResPath = nil
end

function SignsSlotItemVM:UpdateVM(Value)
	self.IconPath = Value.IconPath
	self.ID = Value.Index
	if Value.Index == nil then
		self.ID = Value.ID
	end
	self.ResPath = Value.ResPath
	if _G.SignsMgr.TargetSignsMainPanelIsShowing then
		self:SetIsUsed(_G.SignsMgr:OnCheckIsUsedByID(self.ID))
	end
end

function SignsSlotItemVM:SetIsUsed(IsUsed)
	self.IsUsed = IsUsed
end

function SignsSlotItemVM:OnShutdown()
	
end

function SignsSlotItemVM:OnInit()
	self.ID = nil
	self.IconPath = nil
	self.IsSelected = false
	self.IsUsed = false
	self.ResPath = nil

end

return SignsSlotItemVM