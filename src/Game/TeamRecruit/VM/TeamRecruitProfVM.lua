---
--- Author: xingcaicao
--- DateTime: 2023-05-25 19:19
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local TeamRecruitDefine = require("Game/TeamRecruit/TeamRecruitDefine")

---@class TeamRecruitProfVM : UIViewModel
local TeamRecruitProfVM = LuaClass(UIViewModel)

---Ctor
function TeamRecruitProfVM:Ctor()
    self.Loc    = 0    ---位置
    self.Profs  = {}   ---职业
    self.RoleID = nil  ---占据这个位置的角色

    self.HasRole = false
    self.MemIconID = -1
    self.Icon = "" ---类别Icon 或 职业Icon
    self.RecruitFuncType = 0 ---招募职能类型
end

function TeamRecruitProfVM:IsEqualVM(Value)
    return nil ~= Value and self.Loc == Value.Loc
end

function TeamRecruitProfVM:UpdateVM(Value)
    self.Loc    = Value.Loc or 0
    self.Profs  = table.clone(Value.Prof or {})
    self.RoleID = Value.RoleID

    self.HasRole = self.RoleID ~= nil and self.RoleID ~= 0

    self:UpdateFunctionInfo()
end

function TeamRecruitProfVM:IsFullProf()
    return #self.Profs >= #(TeamRecruitUtil.GetAllOpenProf())
end

function TeamRecruitProfVM:IsCanJoinRole()
    return (self.HasRole == false) and (#self.Profs > 0)
end

function TeamRecruitProfVM:AddProf(Prof)
    if table.contain(self.Profs, Prof) then
        return
    end

    table.insert(self.Profs, Prof)

    -- if self:IsFullProf() then
    --     self:FullProfs()
    --     return
    -- end

    self:UpdateFunctionInfo()
end

function TeamRecruitProfVM:BatchAddProfs(Profs, bNotUpate)
    for _, v in ipairs(Profs) do
        if not table.contain(self.Profs, v) then
           table.insert(self.Profs, v) 
        end
    end

    if not bNotUpate then
        self:UpdateFunctionInfo()
    end
end

function TeamRecruitProfVM:RemoveProf(Prof)
    if not table.contain(self.Profs, Prof) then
        return
    end

    --清除掉不可编辑职业数据
    -- if self:IsFullProf() then
    --     self.Profs = table.clone(TeamRecruitUtil.GetAllOpenProf()) 
    -- end

    table.remove_item(self.Profs, Prof)
    self:UpdateFunctionInfo()
end

function TeamRecruitProfVM:BatchRemove(Profs)
    for _, v in ipairs(Profs or {}) do
        table.remove_item(self.Profs, v)
    end

    self:UpdateFunctionInfo()
end

function TeamRecruitProfVM:FullProfs()
    self.Profs = table.clone(TeamRecruitUtil.GetAllOpenProf())

    self:UpdateFunctionInfo()
end

function TeamRecruitProfVM:ClearProfs(bNotUpdate)
    self.Profs = {}

    if not bNotUpdate then
        self:UpdateFunctionInfo()
    end
end

function TeamRecruitProfVM:UpdateFunctionInfo()
    self.MemIconID = TeamRecruitUtil.EncodeRecruitMemIconID(self.HasRole, self.RoleID, self.Profs)
    self.Icon = TeamRecruitUtil.GetRecruitMemIcon(self.MemIconID)
    self.RecruitFuncType = TeamRecruitUtil.GetRecruitFunctionType(self.Profs)

    -- if self.HasRole then
    --     local RoleVM = _G.RoleInfoMgr:FindRoleVM(self.RoleID)
    --     if RoleVM then
    --         self.Icon = RoleInitCfg:FindRoleInitProfIcon(RoleVM.Prof)
    --     end

    -- else
    --     if table.length(self.Profs) == 1 then
    --         self.Icon = RoleInitCfg:FindRoleInitProfIcon(self.Profs[1])

    --     else
    --         self.Icon = TeamRecruitDefine.FuncTypeIconConfig[self.RecruitFuncType]
    --     end
    -- end
end

return TeamRecruitProfVM