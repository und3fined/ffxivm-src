--Author:Easy
--DateTime: 2023/5/28

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RichTextUtil = require("Utils/RichTextUtil")
local UIBindableList = require("UI/UIBindableList")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require ("Utils/MajorUtil")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")

local TreasureHuntTransferLIstItemVM = require("Game/TreasureHunt/VM/TreasureHuntTransferLIstItemVM")

local TreasureHuntTransferVM = LuaClass(UIViewModel)
function TreasureHuntTransferVM:Ctor()
    self.TeamMemberList = UIBindableList.New(TreasureHuntTransferLIstItemVM)
end

function TreasureHuntTransferVM:OnInit()   
end

function TreasureHuntTransferVM:OnBegin()
end

function TreasureHuntTransferVM:Clear()
end

function TreasureHuntTransferVM:OnEnd()
end

function TreasureHuntTransferVM:OnShutdown()
end

function TreasureHuntTransferVM:UpdateVM()
    local TeamMemberList = {}

    local MemberRoleIDList = _G.TeamMgr:GetMemberRoleIDList()
    for _, RoleID in pairs(MemberRoleIDList) do
        if not MajorUtil.IsMajorByRoleID(RoleID) then
            local function Callback(_, RoleVM)

                if RoleVM ~= nil then
                    TeamMember = {}
                    TeamMember.TeamMemberRoleID = RoleID
                    TeamMember.TeamMemberName = RoleVM.Name
                    TeamMember.Prof = RoleVM.Prof
                    TeamMember.Level = RoleVM.Level
                    table.insert(TeamMemberList,TeamMember)
                end
            end
            RoleInfoMgr:QueryRoleSimple(RoleID, Callback)
        end
    end

    self.TeamMemberList:UpdateByValues(TeamMemberList)
end

return TreasureHuntTransferVM