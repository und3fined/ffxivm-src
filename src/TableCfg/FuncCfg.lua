-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FuncCfg : CfgBase
local FuncCfg = {
	TableName = "c_func_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FuncCfg, { __index = CfgBase })

FuncCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FuncCfg
