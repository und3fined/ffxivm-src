
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RideSkillCfg = require("TableCfg/RideSkillCfg")
local FashionDecorateSkillCfg = require("TableCfg/FashionDecorateSkillCfg")

local FLOG_WARNING = _G.FLOG_WARNING

---@class StoreMountActionItemVM: UIViewModel
---@field TabName string 标签名 
local StoreMountActionItemVM = LuaClass(UIViewModel)

local ActionType = {
	Mount = 1,
	Fashion =2
}
function StoreMountActionItemVM:Ctor()
	self.ID = nil
	self.MountID = nil
	self.SkillID = nil
	self.Icon = nil

	self.SkillName = nil
	self.SkillTag = nil
	self.Distance = nil
	self.Range = nil
	self.SingTimeDescribe = nil
	self.SingTime2 = nil
	self.SkillDescribe = nil
	self.Type = nil
end

function StoreMountActionItemVM:UpdateVM(Value)
    if Value == nil then
        FLOG_WARNING("StoreMountActionItemVM:UpdateVM Value is nil")
        return
    end
	self.Type = Value.Type
	if Value.Type == ActionType.Mount then
		self.SkillID = Value.SkillID
		self.MountID = Value.MountID
		local TempSkillCfg = RideSkillCfg:FindCfgByKey(self.SkillID)
		if TempSkillCfg == nil then
			return
		end
		self.Icon = TempSkillCfg.Icon
		self.SkillName = TempSkillCfg.SkillName
		self.SkillTag = TempSkillCfg.SkillTag
		self.Distance = TempSkillCfg.Distance
		self.Range = TempSkillCfg.Range
		self.SingTimeDescribe = TempSkillCfg.SingTimeDescribe
		self.SingTime2 = TempSkillCfg.SingTime2
		self.SkillDescribe = TempSkillCfg.SkillDescribe
	else
		self.SkillID = Value.SkillID
		self.ID = Value.ID
		local TempSkillCfg = FashionDecorateSkillCfg:FindCfgByKey(Value.SkillID)
		if TempSkillCfg == nil then
			return
		end
		self.Icon = TempSkillCfg.Icon
	end
end

return StoreMountActionItemVM
