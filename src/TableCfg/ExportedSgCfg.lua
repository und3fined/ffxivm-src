-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ExportedSgCfg : CfgBase
local ExportedSgCfg = {
	TableName = "c_exported_sg_cfg",
    LruKeyType = "integer",
	KeyName = "SharedGroupID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ExportedSgCfg, { __index = CfgBase })

ExportedSgCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ExportedSgCfg
