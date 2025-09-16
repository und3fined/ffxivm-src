-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CondCfg : CfgBase
local CondCfg = {
	TableName = "c_cond_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CondCfg, { __index = CfgBase })

CondCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return CondCfg
