--@author star
--@date 2024-12-30

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@Class ArmyEditInfoHeadSlotVM : UIViewModel

local ArmyEditInfoHeadSlotVM = LuaClass(UIViewModel)

function ArmyEditInfoHeadSlotVM:Ctor()
    self.RoleID = nil
    self.RoleName = nil
    self.IsRoleQueryFinish = nil
    self.IsEmpty = nil
end

function ArmyEditInfoHeadSlotVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function ArmyEditInfoHeadSlotVM:UpdateVM(Value)
    --self.RoleName = ""
    self.ID = Value.ID
    self.IsEmpty = Value.IsEmpty
    if self.IsEmpty then
        self.RoleName = LSTR(910353)
        return
    end
    self.RoleID = Value.RoleID
    self:SetIsRoleQueryFinish(false)
    -- LSTR string:查询中...
    --self.RoleName = LSTR(910168)
    local function Callback(_, RoleVM)
		self.RoleName = RoleVM.Name
        self:SetIsRoleQueryFinish(true)
	end
    _G.RoleInfoMgr:QueryRoleSimple(self.RoleID, Callback, self, false)
end

function ArmyEditInfoHeadSlotVM:SetIsRoleQueryFinish(IsRoleQueryFinish)
    self.IsRoleQueryFinish = IsRoleQueryFinish
end

function ArmyEditInfoHeadSlotVM:GetRoleID()
    return self.RoleID
end

return ArmyEditInfoHeadSlotVM