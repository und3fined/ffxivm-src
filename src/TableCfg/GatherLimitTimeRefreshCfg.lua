-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GatherLimitTimeRefreshCfg : CfgBase
local GatherLimitTimeRefreshCfg = {
	TableName = "c_gather_limit_time_refresh_cfg",
    LruKeyType = nil,
	KeyName = "RarePopTimeID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GatherLimitTimeRefreshCfg, { __index = CfgBase })

GatherLimitTimeRefreshCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GatherLimitTimeRefreshCfg
