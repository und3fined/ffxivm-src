--[[
Author: v_hggzhang
DateTime: 2023-04-07 12:56:49
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-05-23 11:57:32
FilePath: \Script\Game\Team\VM\InviteParentListItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AEollf.
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SimpleProfInfoVM = require("Game/Profession/VM/SimpleProfInfoVM")
local ActorUtil = require("Utils/ActorUtil")
local TeamDefine = require("Game/Team/TeamDefine")

---@class InviteParentListItemVM: UIViewModel
local InviteParentListItemVM = LuaClass(UIViewModel)

-- 0 not inivted
-- 1 invited by self, UI Status
-- 2 invited
-- 3 has team, can not be invited
local INVITE_DISPLAY_STATUS = {
	NO_INVITE = 0,
	INVITE_SELF = 1,
	INVITED = 2,
	HAS_TEAM = 3,
	NOT_DISPLAY = 4,
	SHARED = 5,
}

InviteParentListItemVM.DEF_INVITE_DISPLAY_STATUS = INVITE_DISPLAY_STATUS

---Ctor
function InviteParentListItemVM:Ctor()
	self.RoleID     = nil
    self.Name       = "" 
    self.ProfID     = nil
	self.Level 		= 0							--TODO DELETE IT
    self.ProfInfoVM = SimpleProfInfoVM.New()	--#TODO DELETE IT 
	self.InviteDisplayStatus = INVITE_DISPLAY_STATUS.NO_INVITE
	self.ReuseType = TeamDefine.InviteReuseType.INVITE
end

function InviteParentListItemVM:IsEqualVM(V)
	return V and self.RoleID == V.RoleID
end

---UpdateVM
---@param Value table @RoleVM
function InviteParentListItemVM:UpdateVM(Value)
    self.RoleID 	= Value.RoleID
	local RVM = _G.RoleInfoMgr:FindRoleVM(self.RoleID, true)
	self.Name       = RVM.Name or ""
    self.ProfID     = RVM.Prof
	self.Level 		= RVM.Level
    self.ProfInfoVM:UpdateVM(self)
	self.ReuseType  = Value.ReuseType or TeamDefine.InviteReuseType.INVITE
	self:UpadateInviteStatus(nil, true)
end

function InviteParentListItemVM:AdapterOnGetCanBeSelected()
	return false
end

function InviteParentListItemVM:AdapterOnGetWidgetIndex()
	return 1
end

function InviteParentListItemVM:UpadateInviteStatus(Status, bInit)
	if self.ReuseType == TeamDefine.InviteReuseType.SHARE then
		if _G.TeamRecruitMgr:InChatShareThresould(self.RoleID) then
			self.InviteDisplayStatus = INVITE_DISPLAY_STATUS.SHARED
		else
			self.InviteDisplayStatus = INVITE_DISPLAY_STATUS.NOT_DISPLAY
		end
		return
	end

	if not self.RoleID or not (self.ReuseType == TeamDefine.InviteReuseType.INVITE or self.ReuseType == nil) then
		self.InviteDisplayStatus = INVITE_DISPLAY_STATUS.NOT_DISPLAY
		return
	end

	if _G.TeamMgr:IsInInviate(self.RoleID) then
		if self.InviteDisplayStatus ~= INVITE_DISPLAY_STATUS.INVITE_SELF or bInit then
			self.InviteDisplayStatus = INVITE_DISPLAY_STATUS.INVITED
		end
	else
		self.InviteDisplayStatus = INVITE_DISPLAY_STATUS.NO_INVITE
	end

	if Status == INVITE_DISPLAY_STATUS.INVITE_SELF then
		self.InviteDisplayStatus = Status
	end

	if ActorUtil.HasTeam(ActorUtil.GetEntityIDByRoleID(self.RoleID)) or _G.TeamMgr:IsTeamMemberByRoleID(self.RoleID) then
		self.InviteDisplayStatus = INVITE_DISPLAY_STATUS.HAS_TEAM
	end
end

return InviteParentListItemVM