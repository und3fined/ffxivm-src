local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BuddyMgr = require("Game/Buddy/BuddyMgr")

local EToggleButtonState = _G.UE.EToggleButtonState
---@class BuddySkillItemVM : UIViewModel
local BuddySkillItemVM = LuaClass(UIViewModel)

---Ctor
function BuddySkillItemVM:Ctor()
	self.UseImgVisible = nil
	self.IconImg = nil
	self.MaskImgVisible = nil
	self.ID = nil
	self.Value = nil
	self.EFFVisible = nil

	self.SelectImgVisible = nil
end

function BuddySkillItemVM:UpdateVM(Value)
	if  Value == nil then
		return
	end
	self.ID = Value.ID
	self.Value = Value
	self.IconImg = Value.Icon

	local Skills = BuddyMgr:GetAbilitySkills(Value.Type)
	local CurLevel = Skills and #Skills or 0
	self.MaskImgVisible = CurLevel <= Value.Index

	self.EFFVisible = CurLevel == Value.Index and self:BoolCanStudy()
end

function BuddySkillItemVM:UpdateIconState(ID)
	self.SelectImgVisible = ID  == self.ID 
end

function BuddySkillItemVM:BoolCanStudy()
	--[[if BuddyMgr:IsBuddyOuting() == false then
		return false
	end

	if BuddyMgr:CanBuddyActivity() == false then
		return false
	end]]--

	local Skills = BuddyMgr:GetAbilitySkills(self.Value.Type)
	local CurLevel = Skills and #Skills or 0
	
	return CurLevel == self.Value.Index and BuddyMgr:GetSkillUnassigned() >= self:GetCostSkillCost()
end

function BuddySkillItemVM:IsLearned()
	local Skills = BuddyMgr:GetAbilitySkills(self.Value.Type)
	local CurLevel = Skills and #Skills or 0

	return CurLevel > self.Value.Index
end

function BuddySkillItemVM:GetCostSkillCost()
	return self.Value.NeedPoints
end

function BuddySkillItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.ID == self.ID
end




--要返回当前类
return BuddySkillItemVM