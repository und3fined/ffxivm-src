-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CounterCfg : CfgBase
local CounterCfg = {
	TableName = "c_counter_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CounterCfg, { __index = CfgBase })

CounterCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return CounterCfg
