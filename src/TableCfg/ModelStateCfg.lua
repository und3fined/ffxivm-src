-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ModelStateCfg : CfgBase
local ModelStateCfg = {
	TableName = "c_model_state_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ModelStateCfg, { __index = CfgBase })

ModelStateCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ModelStateCfg
