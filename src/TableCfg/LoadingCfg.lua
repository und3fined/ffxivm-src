-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LoadingCfg : CfgBase
local LoadingCfg = {
	TableName = "c_loading_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(LoadingCfg, { __index = CfgBase })

LoadingCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return LoadingCfg
