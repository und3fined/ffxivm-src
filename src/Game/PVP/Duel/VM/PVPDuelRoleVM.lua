--
-- Author: HugoWong
-- Date:
-- Description: 
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MajorUtil = require("Utils/MajorUtil")

local PVPTeamMgr = _G.PVPTeamMgr

---@class PVPDuelRoleVM
local PVPDuelRoleVM = LuaClass(UIViewModel)

function PVPDuelRoleVM:Ctor()
	self.RoleID = 0
	self.Name = ""
	self.ProfID = 0
	self.CampID = 0
	self.PortraitUrl = nil
	self.PortraitUrlHashEx = nil
end

function PVPDuelRoleVM:UpdateVM(Value)
	local RoleID = Value.RoleID
	self.RoleID = RoleID
	_G.RoleInfoMgr:QueryRoleSimple(RoleID, function(Params, RoleVM)
		if RoleVM then
			self.Name = RoleVM.Name
			self.ProfID = RoleVM.Prof
			self.PortraitUrl = RoleVM.PortraitUrl
			self.PortraitUrlHashEx = RoleVM.PortraitUrlHashEx
		end
	end, nil, false)

	local IsMajor = MajorUtil.GetMajorRoleID() == RoleID
	if IsMajor then
		self.CampID = PVPTeamMgr:GetMajorCampID()
	else
		self.CampID = 1
	end
end

return PVPDuelRoleVM