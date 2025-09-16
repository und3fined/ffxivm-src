-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MonthcardGlobalCfg : CfgBase
local MonthcardGlobalCfg = {
	TableName = "c_monthcard_global_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MonthcardGlobalCfg, { __index = CfgBase })

MonthcardGlobalCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MonthcardGlobalCfg
