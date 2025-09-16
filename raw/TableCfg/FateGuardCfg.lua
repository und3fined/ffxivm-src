-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FateGuardCfg : CfgBase
local FateGuardCfg = {
	TableName = "c_fate_guard_cfg",
    LruKeyType = nil,
	KeyName = "FateID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FateGuardCfg, { __index = CfgBase })

FateGuardCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FateGuardCfg
