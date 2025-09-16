-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FootMarkRecordCfg : CfgBase
local FootMarkRecordCfg = {
	TableName = "c_foot_mark_record_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ShowText',
            },
            {
                Name = 'CompText',
            },
            {
                Name = 'CountName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FootMarkRecordCfg, { __index = CfgBase })

FootMarkRecordCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FootMarkRecordCfg
