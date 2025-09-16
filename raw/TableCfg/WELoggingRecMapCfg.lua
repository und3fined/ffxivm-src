-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class WELoggingRecMapCfg : CfgBase
local WELoggingRecMapCfg = {
	TableName = "c_WE_Logging_RecMap_cfg",
    LruKeyType = nil,
	KeyName = "Level",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(WELoggingRecMapCfg, { __index = CfgBase })

WELoggingRecMapCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return WELoggingRecMapCfg
