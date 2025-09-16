local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LevelExpCfg = require("TableCfg/LevelExpCfg")

local ColorActive = "#d5d5d5"
local ColorInactive = "#828282"
local ColorMaxLevel = "#d1ba8e"
local ColorFinal = "d1906d"

---@class ProfessionLevelItemVM : UIViewModel
local ProfessionLevelItemVM = LuaClass(UIViewModel)

---Ctor
function ProfessionLevelItemVM:Ctor()
	self.ProfID = 0
	self.Level = 0
	self.ExpProgress = 0
	self.bIsActive = false
	self.bIsCurProf = false
	self.LevelColor = ColorInactive
	self.NameColor = ColorInactive
	self.ProfIcon = ""
end

function ProfessionLevelItemVM:SetActive(bIsActive)
	self.bIsActive = bIsActive
	if self.bIsActive then
		if self:IsMaxLevel() then
			local IsClear = _G.EquipmentMgr:IsClearFinalScene(self.ProfID)
			self.LevelColor = IsClear and ColorFinal or ColorMaxLevel
		else
			self.LevelColor = ColorActive
		end
		
		self.NameColor = ColorActive
	else
		self.LevelColor = ColorInactive
		self.NameColor = ColorInactive
	end
end

function ProfessionLevelItemVM:SetLevel(Level)
	self.Level = Level
	if self:IsMaxLevel() then
		local IsClear = _G.EquipmentMgr:IsClearFinalScene(self.ProfID)
			self.LevelColor = IsClear and ColorFinal or ColorMaxLevel
	end
end

function ProfessionLevelItemVM:IsMaxLevel()
	if nil == self.Level then
		return false
	end
	return self.Level >= LevelExpCfg:GetMaxLevel()
end

function ProfessionLevelItemVM:SetSelected(IsSelect)
	self.bIsCurProf = IsSelect
	if self.bIsActive then
		if self:IsMaxLevel() then
			local IsClear = _G.EquipmentMgr:IsClearFinalScene(self.ProfID)
			self.LevelColor = IsClear and ColorFinal or ColorMaxLevel
		else
			self.LevelColor = ColorActive
		end
		self.NameColor = ColorActive
	else
		self.LevelColor = IsSelect and ColorActive or ColorInactive
		self.NameColor = IsSelect and ColorActive or ColorInactive
	end
end

return ProfessionLevelItemVM