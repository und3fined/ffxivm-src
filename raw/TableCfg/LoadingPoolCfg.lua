-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LoadingPoolCfg : CfgBase
local LoadingPoolCfg = {
	TableName = "c_loading_pool_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(LoadingPoolCfg, { __index = CfgBase })

LoadingPoolCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return LoadingPoolCfg
