-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class RandomEventCfg : CfgBase
local RandomEventCfg = {
	TableName = "c_random_event_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(RandomEventCfg, { __index = CfgBase })

RandomEventCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return RandomEventCfg
