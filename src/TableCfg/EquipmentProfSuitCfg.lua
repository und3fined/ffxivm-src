-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class EquipmentProfSuitCfg : CfgBase
local EquipmentProfSuitCfg = {
	TableName = "c_equipment_prof_suit_cfg",
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

setmetatable(EquipmentProfSuitCfg, { __index = CfgBase })

EquipmentProfSuitCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return EquipmentProfSuitCfg
