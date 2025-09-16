-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SensitiveWordCfg : CfgBase
local SensitiveWordCfg = {
	TableName = "c_sensitive_word_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(SensitiveWordCfg, { __index = CfgBase })

SensitiveWordCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return SensitiveWordCfg
