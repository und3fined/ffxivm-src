-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FateMyEventCfg : CfgBase
local FateMyEventCfg = {
	TableName = "c_fate_my_event_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Describe',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FateMyEventCfg, { __index = CfgBase })

FateMyEventCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FateMyEventCfg
