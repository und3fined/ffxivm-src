--[[
Author: xingcaicao
Date: 2023-05-30 17:01
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-09-23 19:14:31
FilePath: \Script\Game\TeamRecruit\VM\TeamRecruitSimpleProfVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local TeamRecruitDefine = require("Game/TeamRecruit/TeamRecruitDefine")

---@class TeamRecruitSimpleProfVM : UIViewModel
local TeamRecruitSimpleProfVM = LuaClass(UIViewModel)

---Ctor
function TeamRecruitSimpleProfVM:Ctor()
    self.Loc    = 0    ---位置
    self.Profs  = {}   ---职业
    self.RoleID = nil  ---占据这个位置的角色

    self.HasRole = false
    self.Icon = "" ---类别Icon 或 职业Icon
end

function TeamRecruitSimpleProfVM:IsEqualVM()
    return false
end

function TeamRecruitSimpleProfVM:UpdateVM(Value)
    self.Loc    = Value.Loc or 0
    self.Profs  = Value.Prof or {}
    self.RoleID = Value.RoleID
    self.HasRole = self.RoleID and self.RoleID ~= 0

    -- profs
    local Profs = self.Profs
    if self.HasRole then
        local Prof = (_G.RoleInfoMgr:FindRoleVM(self.RoleID) or {}).Prof
        if Prof and Prof > 0 then
            Profs = {Prof}
        end
    end
    self:UpdateProfs(Profs)
end

function TeamRecruitSimpleProfVM:UpdateProfs(Profs)
    local RecruitFuncType = TeamRecruitUtil.GetRecruitFunctionType(Profs)
    if TeamRecruitDefine.FuncTypeSimpleIconConfig[RecruitFuncType] == nil then
        RecruitFuncType =  TeamRecruitDefine.RecruitFunctionType.All
        if self.HasRole then
            _G.FLOG_ERROR("cannot find recruite type for roleid: %s, profs: %s", self.RoleID, table.tostring(Profs))
        end
    end
    self.Icon = TeamRecruitDefine.FuncTypeSimpleIconConfig[RecruitFuncType]
end

return TeamRecruitSimpleProfVM