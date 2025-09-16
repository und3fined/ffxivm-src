-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SkillMainCfg : CfgBase
local SkillMainCfg = {
	TableName = "c_skill_main_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Desc',
            },
            {
                Name = 'SkillName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(SkillMainCfg, { __index = CfgBase })

SkillMainCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


---GetSkillName
---@param ID number
---@return string
function SkillMainCfg:GetSkillName(ID)
	return self:FindValue(ID, "SkillName")
end

---GetSkillType
---@param ID number
---@return number
function SkillMainCfg:GetSkillType(ID)
	return self:FindValue(ID, "Type")
end

---GetSkillCD
---@param ID number
---@return number
function SkillMainCfg:GetSkillCD(ID)
	return self:FindValue(ID, "CD")
end

---GetSkillIdList
---@param ID number
---@return table
function SkillMainCfg:GetSkillIdList(ID)
	return self:FindValue(ID, "IdList")
end

---GetSkillClass
---@param ID number
---@return number
function SkillMainCfg:GetSkillClass(ID)
	return self:FindValue(ID, "Class")
end

---GetSkillClass
---@param ID number
---@return table
function SkillMainCfg:GetSkillCostList(ID)
	return self:FindValue(ID, "CostList")
end

---GetSkillLimitBuffs
---@param ID number
---@return table
function SkillMainCfg:GetSkillLimitBuffs(ID)
	return self:FindValue(ID, "LimitBuffs")
end


return SkillMainCfg
