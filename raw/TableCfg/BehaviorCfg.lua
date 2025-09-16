-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BehaviorCfg : CfgBase
local BehaviorCfg = {
	TableName = "c_behavior_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BehaviorCfg, { __index = CfgBase })

BehaviorCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return BehaviorCfg
