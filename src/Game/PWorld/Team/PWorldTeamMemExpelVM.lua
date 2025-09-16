--[[
Author: v_hggzhang <v_hggzhang@tencent.com>
Date: 2025-02-28 11:42:06
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-04-18 14:26:30
FilePath: \Script\Game\PWorld\Team\PWorldTeamMemExpelVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local PWorldTeamMemExpelVM = LuaClass(UIViewModel)
local MajorUtil = require("Utils/MajorUtil")

function PWorldTeamMemExpelVM:Ctor()
    self.MemRoleID = 0
    self.RoleVM = nil

    self.MVPVoteEnable = true
    self.Selected = false
    self.Opacity = 1
end

function PWorldTeamMemExpelVM:UpdateVM(Value)
    if not Value then
        return
    end
    self.MemRoleID = Value
    self.RoleVM = _G.RoleInfoMgr:FindRoleVM(self.MemRoleID)

    self.Selected = false
    self:UpdMVPVoteEnable()

    self.Prof = _G.PWorldTeamMgr:GetTeamMemberProf(Value)
end

function PWorldTeamMemExpelVM:IsEqualVM(Value)
    -- print("zhg PWorldTeamMemExpelVM:IsEqualVM " .. tostring(Value))
    -- print("zhg PWorldTeamMemExpelVM:IsEqualVM " .. table_to_string_block(Value))
    return self.MemRoleID == Value
end

function PWorldTeamMemExpelVM:SetSelected(V)
    if V and (V == self.Selected) then
        self.Selected = false
    end
    self.Selected = V
end

function PWorldTeamMemExpelVM:SetMVPVoteEnable(V)
    self.MVPVoteEnable = V
    self.Opacity = V and 1 or 0.5
end

function PWorldTeamMemExpelVM:UpdMVPVoteEnable()
    local IsMajor = MajorUtil.GetMajorRoleID() == self.MemRoleID
    local Enable = (not _G.PWorldTeamMgr:HasVoteMvpMemGone(self.MemRoleID)) and (not IsMajor) -- and (not InMyTeam)

    self:SetMVPVoteEnable(Enable)
end

return PWorldTeamMemExpelVM
