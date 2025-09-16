--[[
Author: andre_lightpaw <andre@lightpaw.com>
Date: 2024-05-20 17:56:27
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-08-15 11:36:56
FilePath: \Script\Game\PWorld\Entrance\Entourage\PWorldEntourageConfirmMemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local PWorldEntourageUIUtil = require("Game/PWorld/Entrance/Entourage/PWorldEntourageUIUtil")

local SceneEncourageNpcCfg = require("TableCfg/SceneEncourageNpcCfg")

local ProfUtil = require("Game/Profession/ProfUtil")
local MajorUtil = require("Utils/MajorUtil")

local PWorldEntourageConfirmMemVM  = LuaClass(UIViewModel)

function PWorldEntourageConfirmMemVM :Ctor()
	self.ID = nil
	self.Prof = 1
	self.Name = ""
	self.Level = 0
	self.RoleVM = nil
	self.ProfName = ""
	self.ProfIcon = ""

    self.IsTeamMateOrMajor = true
    self.HasReady = true
	self.ShowCapIcon = false
	self.IsEntourageMem = true
end

function PWorldEntourageConfirmMemVM:UpdateVM(V)
	self.ID = V.ID
	local Cfg = SceneEncourageNpcCfg:FindCfgByKey(self.ID)
	self.IsMajor = V.IsMajor
	if  V.IsMajor then
		self.RoleVM = MajorUtil.GetMajorRoleVM()
    	self.HasReady = false
		self.IsTeamMateOrMajor = true
		self.ShowCapIcon = true
	else
		self.IsTeamMateOrMajor = false
		self.RoleVM = nil
    	self.HasReady = true
		self.ShowCapIcon = false
		if Cfg then
			self.Name 		= Cfg.Name
			self.ProfName 	= Cfg.ProfName
			self.ProfIcon 	= Cfg.ProfIcon
			self.Prof 		= Cfg.ProfType
		end
		self.Level = _G.PWorldEntourageVM.PWorldRequireLv
	end
end

function PWorldEntourageConfirmMemVM :IsEqualVM(Value)
    return nil ~= Value and Value == self.ID
end

return PWorldEntourageConfirmMemVM 