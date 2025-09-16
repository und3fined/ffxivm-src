local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MajorUtil = require("Utils/MajorUtil")

---@class SavageRankHeadSlotVM : UIViewModel
local SavageRankHeadSlotVM = LuaClass(UIViewModel)

---Ctor
function SavageRankHeadSlotVM:Ctor()
	self.Name = ""
	self.OpenText = ""
	self.SelectVisible = false
	self.PanelOpeningVisible = false
	self.RoleID = nil
	self.Prof = nil
	self.IsSelect = false
end

function SavageRankHeadSlotVM:OnInit()

end
 
---UpdateVM
---@param List table
function SavageRankHeadSlotVM:UpdateVM(List)
	self.RoleID = List.RoleID
	self:UpdateProfIcon(List.Prof)
	self:SetIsSelect(List)
end

function SavageRankHeadSlotVM:UpdateProfIcon(Prof)
	self.Prof = Prof
end

function SavageRankHeadSlotVM:SetIsSelect(List)
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	if MajorRoleID == List.RoleID then
		self.IsSelect = true
	else
		self.IsSelect = false
	end
end

function SavageRankHeadSlotVM:OnValueChanged(Value)
	self.RoleID = Value.RoleID
end

function SavageRankHeadSlotVM:IsEqualVM(Value)
	return nil ~= Value and Value.RoleID == self.RoleID
end

return SavageRankHeadSlotVM