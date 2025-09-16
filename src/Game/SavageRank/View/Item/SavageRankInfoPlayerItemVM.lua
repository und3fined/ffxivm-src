local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SavageRankHeadSlotVM = require("Game/SavageRank/View/Item/SavageRankHeadSlotVM")


---@class SavageRankInfoPlayerItemVM : UIViewModel
local SavageRankInfoPlayerItemVM = LuaClass(UIViewModel)

---Ctor
function SavageRankInfoPlayerItemVM:Ctor()
    self.SavageRankHeadSlotVM = SavageRankHeadSlotVM.New()
    self.RoleID = nil
    self.RoleName = nil
    self.ServerName = nil
    self.EquipLvText = nil
    self.Lv = nil
    self.Prof = nil
end

function SavageRankInfoPlayerItemVM:OnInit()

end
 
---UpdateVM
---@param List table
function SavageRankInfoPlayerItemVM:UpdateVM(List)
    self.RoleID = List.RoleID
    self.Lv = List.Lv
    self.SavageRankHeadSlotVM:UpdateVM(List)
    self:UpdateRoleInfo(List)
end

function SavageRankInfoPlayerItemVM:UpdateRoleInfo(List)
	local RoleVM = _G.RoleInfoMgr:FindRoleVM(self.RoleID)
	self.Prof = List.Prof
    self.EquipLvText = List.EquipLevel
    self.RoleName = RoleVM.Name
    local ServerName = _G.LoginMgr:GetMapleNodeName(RoleVM.WorldID)
    self.ServerName = ServerName
end

function SavageRankInfoPlayerItemVM:IsEqualVM(Value)
end

return SavageRankInfoPlayerItemVM