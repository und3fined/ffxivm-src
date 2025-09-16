--[[
Author: v_hggzhang <v_hggzhang@tencent.com>
Date: 2024-05-20 17:56:27
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-07-11 15:26:54
FilePath: \Script\Game\PWorld\Team\PWorldTeamMemberVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local PWorldTeamMemberVM = LuaClass(UIViewModel)
local MajorUtil = require("Utils/MajorUtil")

function PWorldTeamMemberVM:Ctor()
    self.MemRoleID = 0
    self.RoleVM = nil

    self.MVPVoteEnable = true
    self.Selected = false
    self.Opacity = 1
end

function PWorldTeamMemberVM:UpdateVM(Value)
    if not Value then
        return
    end

    self.MemRoleID = Value
    self.RoleVM = _G.RoleInfoMgr:FindRoleVM(self.MemRoleID)

    self.Selected = false
    self:UpdMVPVoteEnable()
end

function PWorldTeamMemberVM:IsEqualVM(_)
    -- for other views may use this kind of view model, so always return false
    return false
end

function PWorldTeamMemberVM:SetSelected(V)
    self.Selected = V
end

function PWorldTeamMemberVM:SetMVPVoteEnable(V)
    self.MVPVoteEnable = V
    self.Opacity = V and 1 or 0.3
end

function PWorldTeamMemberVM:UpdMVPVoteEnable()
    local IsMajor = MajorUtil.GetMajorRoleID() == self.MemRoleID and self.MemRoleID ~= nil
    local Enable = (not _G.PWorldTeamMgr:HasVoteMvpMemGone(self.MemRoleID)) and (not IsMajor)
    self:SetMVPVoteEnable(Enable)
end

return PWorldTeamMemberVM
