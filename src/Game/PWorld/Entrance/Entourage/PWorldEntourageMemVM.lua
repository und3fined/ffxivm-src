--[[
Author: andre_light <andre@lightpaw.com>
Date: 2024-05-20 17:56:27
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-08-05 15:32:53
FilePath: \Script\Game\PWorld\Entrance\Entourage\PWorldEntourageMemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local PWorldEntourageUIUtil = require("Game/PWorld/Entrance/Entourage/PWorldEntourageUIUtil")
local SceneEncourageNpcCfg = require("TableCfg/SceneEncourageNpcCfg")

local PWorldEntourageMemVM = LuaClass(UIViewModel)

function PWorldEntourageMemVM:Ctor()
	self.ID = nil
	self.Prof = 1
	self.Name = ""
	self.Lv = 0
	self.EquipLv = 0

	self.ProfName = ""
	self.ProfIcon = ""
	self.Portrait = ""
	self.BGRes = ""

	self.IsCombatProf = false
end

function PWorldEntourageMemVM:UpdateVM(V)
	self.ID = V.ID
	local Cfg = SceneEncourageNpcCfg:FindCfgByKey(self.ID)
	self.Lv = _G.PWorldEntourageVM.PWorldRequireLv

	if Cfg then
		self.Name 		= Cfg.Name
		self.ProfName 	= tostring(self.Lv) .. " " .. Cfg.ProfName
		self.ProfIcon 	= Cfg.ProfIcon
		self.Prof 		= Cfg.ProfType
		self.Portrait  	= Cfg.Portrait and Cfg.Portrait[1] or ""
		self.Avatar  	= Cfg.Avatar
	end
	
	self.BGRes = PWorldEntourageUIUtil.GetProfFrame(self.Prof)
end

function PWorldEntourageMemVM:IsEqualVM(Value)
	return true
end

return PWorldEntourageMemVM