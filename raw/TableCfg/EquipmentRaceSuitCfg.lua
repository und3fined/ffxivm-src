-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class EquipmentRaceSuitCfg : CfgBase
local EquipmentRaceSuitCfg = {
	TableName = "c_equipment_race_suit_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'SuitName',
            },
            {
                Name = 'SuitDesc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(EquipmentRaceSuitCfg, { __index = CfgBase })

EquipmentRaceSuitCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function EquipmentRaceSuitCfg:FindBlankCfg()
	local SearchConditions = "ID < 10000"
	return self:FindAllCfg(SearchConditions)
end

function EquipmentRaceSuitCfg:FindAllNormalCfg()
	local SearchConditions = "ID > 10000"
	return self:FindAllCfg(SearchConditions)
end
return EquipmentRaceSuitCfg
