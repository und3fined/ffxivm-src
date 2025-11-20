local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")

---@class OpsTeamUpTeamMembersItemVM : UIViewModel
local OpsTeamUpTeamMembersItemVM = LuaClass(UIViewModel)

---Ctor
function OpsTeamUpTeamMembersItemVM:Ctor()
    self.RedDotName = nil
    self.HeaderUrl = nil
    self.TextName = nil
end

function OpsTeamUpTeamMembersItemVM:UpdateVM(Params)
    if Params then
        self.RedDotName = Params.RedDotName
        self.HeaderUrl = Params.HeaderUrl
        self.TextName = Params.NickName

        -- if self.RoleID == 0 then
        --     ---LSTR 点击邀请
        --     self.TextName = LSTR(1650001)
        -- elseif self.RoleID then
        --     local function Callback(_, RoleVM)
        --         ---防止高延迟回包时，成员id变化
        --         if RoleVM.RoleID == self.RoleID then
        --             self.TextName = RoleVM.Name
        --         end
        --     end
        --     _G.RoleInfoMgr:QueryRoleSimple(self.RoleID, Callback, self, false)
        -- end

    end
end

function OpsTeamUpTeamMembersItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.HeaderUrl == self.HeaderUrl and Value.TextName == self.TextName
end

function OpsTeamUpTeamMembersItemVM:GetHeaderUrl()
	return self.HeaderUrl
end

return OpsTeamUpTeamMembersItemVM