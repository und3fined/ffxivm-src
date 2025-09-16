-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class EidCfg : CfgBase
local EidCfg = {
	TableName = "c_eid_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(EidCfg, { __index = CfgBase })

EidCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return EidCfg
