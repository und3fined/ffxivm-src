---
--- Author: xingcaicao
--- DateTime: 2023-05-09 10:24
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MajorUtil = require("Utils/MajorUtil")
local SimpleProfInfoVM = require("Game/Profession/VM/SimpleProfInfoVM")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local TeamDefine = require("Game/Team/TeamDefine")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local ProtoRes = require("Protocol/ProtoRes")

local LSTR = _G.LSTR

---@class TeamMemberSimpleVM : UIViewModel
local TeamMemberSimpleVM = LuaClass(UIViewModel)

---Ctor
function TeamMemberSimpleVM:Ctor( )
	self.RoleID     = nil
    self.JoinTime   = 0
	self.IsCaptain  = false
	self.IsMajor    = false 
    self.IsEmpty    = true
	self.SortID = 0

    self.ProfID     = nil
    self.Level      = 0 
	self.ArmyName 	= LSTR(1300045)

	self.MemberItemBg 		= TeamDefine.TeamMemberEmptyItemBg
	self.VoiceMemberID 		= 0
	self.IsSaying 			= false
	self.StatusIcon			= ""
	self.bShowStatus		= true

    self.ProfInfoVM = SimpleProfInfoVM.New()
end

function TeamMemberSimpleVM:IsEqualVM( Value )
	return Value and Value.RoleID == self.RoleID and self.RoleID ~= 0 and self.RoleID ~= nil
end

function TeamMemberSimpleVM:UpdateVM( Value )
    self.RoleID     = Value.RoleID
	self.JoinTime   = Value.JoinTime or 0
	self.SortID 	= Value.SortID or 0
	self.IsMajor    = MajorUtil.IsMajorByRoleID(self.RoleID)
    self.IsEmpty    = (nil == self.RoleID or self.RoleID == 0)

	self:SetVoiceMemberID(Value.VoiceMemberID or 0)
	self.IsSaying 	   = false

    self:UpdateCaptain()

	if self.IsEmpty then
		self:ClearRoleInfo()
	else
		self:UpdateProfInfo(Value.TeamMgr)
	end
end

local _CaptainIcon
local _TeamMemberIcon
function TeamMemberSimpleVM.GetTeamCaptainIcon()
	if _CaptainIcon == nil then
		_CaptainIcon = OnlineStatusUtil.GetStatusRes(ProtoRes.OnlineStatus.OnlineStatusCaptain)
	end

	return _CaptainIcon
end

function TeamMemberSimpleVM.GetTeamMemberIcon()
	if _TeamMemberIcon == nil then
		_TeamMemberIcon =  OnlineStatusUtil.GetStatusRes(ProtoRes.OnlineStatus.OnlineStatusTeamMem)
	end

	return _TeamMemberIcon
end

function TeamMemberSimpleVM:UpdateCaptain()
	local teamhelper = require("Game/Team/TeamHelper").GetTeamMgr()
	if teamhelper:IsCaptainByRoleID(self.RoleID) then
		self.StatusIcon = self.GetTeamCaptainIcon()
	elseif teamhelper:IsTeamMemberByRoleID(self.RoleID) then
		self.StatusIcon = self.GetTeamMemberIcon()
	else
		local RoleVM = _G.RoleInfoMgr:FindRoleVM(self.RoleID, true)
		self.StatusIcon = (RoleVM and RoleVM.OnlineStatusIcon ~= self.GetTeamCaptainIcon() and RoleVM.OnlineStatusIcon ~= self.GetTeamMemberIcon()) and RoleVM.OnlineStatusIcon or ""
	end

	self.bShowStatus = self.StatusIcon and self.StatusIcon ~= ""
end

function TeamMemberSimpleVM:ClearRoleInfo(  )
	self.IsEmpty 	= true
    self.ProfID     = nil
    self.Level      = 0 
	self.ArmyName 	= LSTR(1300045)
	self.MemberItemBg = TeamDefine.TeamMemberEmptyItemBg

    self.ProfInfoVM:UpdateVM({})
end

function TeamMemberSimpleVM:SetVoiceMemberID( MemberID )
	self.VoiceMemberID = MemberID or 0
end

function TeamMemberSimpleVM:SetIsSaying( b )
	self.IsSaying = b
end

function TeamMemberSimpleVM:UpdateProfInfo(Mgr)
	if self.RoleID == nil or self.RoleID == 0 then
		self:ClearRoleInfo()
		return
	end

	if Mgr then
		self.ProfID     = Mgr:GetTeamMemberProf(self.RoleID)
		self.Level      = Mgr:GetTeamMemberLevel(self.RoleID)
	end
	self.IsEmpty	= false

	local Bg = nil 
	if self.ProfID then
		local ProfFunc = RoleInitCfg:FindFunction(self.ProfID)
		if ProfFunc then
			Bg = TeamDefine.TeamMemberItemBgEnum[ProfFunc]
		end
	end

	self.MemberItemBg = string.isnilorempty(Bg) and TeamDefine.TeamMemberEmptyItemBg or Bg
	self.ProfInfoVM:UpdateVM(self)
end

return TeamMemberSimpleVM