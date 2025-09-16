--[[
Author: andre_lightpaw <andre@lightpaw.com>
Date: 2024-07-15 19:50:27
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-08-05 20:01:04
FilePath: \Script\Game\PWorld\Team\PWorldEntourageTeamMgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%A
--]]

local LuaClass = require("Core/LuaClass")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local PWorldEntourageTeamVM

local PWorldMgr
local ATeamMgr = require("Game/Team/Abs/ATeamMgr")

local ProtoCommon = require("Protocol/ProtoCommon")
local SceneModeDef = ProtoCommon.SceneMode
local CS_CMD = ProtoCS.CS_CMD

local PWorldQuestDefine = require("Game/PWorld/Quest/PWorldQuestDefine")
local TeamHelper = require("Game/Team/TeamHelper")

---@class PWorldEntourageTeamMgr : ATeamMgr
local PWorldEntourageTeamMgr = LuaClass(ATeamMgr)

function PWorldEntourageTeamMgr:OnBegin()
    self:SetLogName("PWorldEntourageTeamMgr")

    self.Super.OnBegin(self)
    PWorldEntourageTeamVM = _G.PWorldEntourageTeamVM
    PWorldMgr = _G.PWorldMgr
    self:SetTeamVM(PWorldEntourageTeamVM)
end

function PWorldEntourageTeamMgr:OnRegisterGameEvent()
    self.Super.OnRegisterGameEvent(self)

    self:RegisterGameEvent(_G.EventID.TeamSceneTeamDataUpdate,self.OnSceneTeamDataUpdate)
end


function PWorldEntourageTeamMgr:OnGameEventVisionEnter(Params)
    self:InitAVisionEntity(Params.ULongParam1)
end

function PWorldEntourageTeamMgr:OnGameEventVisionLeave(Params)
    local EntityID = Params.ULongParam1
    for i, v in ipairs(self:GetRawMembersData()) do
        if v.EntityID == EntityID then
            v.bVision = false
            _G.PWorldEntourageTeamVM:UpdateVM()
            break 
        end
    end
end

function PWorldEntourageTeamMgr:IsInTeam()
	return TeamHelper.GetTeamMgr() == self
end

function PWorldEntourageTeamMgr:IsTeamMemberByEntityID(EntityID)
    return EntityID and EntityID ~= 0 and table.find_item(_G.PWorldTeamMgr.SceneTeamData or {}, EntityID, 'EntityID') ~= nil
end

function PWorldEntourageTeamMgr:IterTeamMembers()
    local IterFunc = function(t, i)
        i = i + 1
        local v = t[i]
        if v then
            return i, v.Type == ProtoCS.SceneTeamEntityType.SceneTeamEntityTypePlayer and v.RoleID or nil, v.EntityID
        end
    end

    return IterFunc, self:GetRawMembersData(), 0
end 

function PWorldEntourageTeamMgr:InitAVisionEntity(EntityID)
    local Mem = table.find_item(self:GetRawMembersData(), "EntityID")
    if Mem then
        Mem.bVision = true
    end
end

function PWorldEntourageTeamMgr:GetRawMembersData()
    return _G.PWorldTeamMgr.SceneTeamData or {}
end

function PWorldEntourageTeamMgr:GetTeamID()
    return self:IsInTeam() and _G.PWorldTeamMgr:GetTeamID() or nil
end

function PWorldEntourageTeamMgr:OnSceneTeamDataUpdate()
    if self:IsInTeam() then
        _G.PWorldEntourageTeamVM:UpdateVM() 
        self:SetCaptainByRoleID(MajorUtil.GetMajorRoleID(), true)
    end

    _G.PWorldEntourageTeamVM:SetIsTeam(self:IsInTeam())
end

return PWorldEntourageTeamMgr
