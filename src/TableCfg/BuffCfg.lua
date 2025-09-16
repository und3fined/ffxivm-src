-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BuffCfg : CfgBase
local BuffCfg = {
	TableName = "c_buff_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'BuffName',
            },
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BuffCfg, { __index = CfgBase })

BuffCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


return BuffCfg
