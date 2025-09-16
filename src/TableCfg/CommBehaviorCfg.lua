-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CommBehaviorCfg : CfgBase
local CommBehaviorCfg = {
	TableName = "c_comm_behavior_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CommBehaviorCfg, { __index = CfgBase })

CommBehaviorCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return CommBehaviorCfg
