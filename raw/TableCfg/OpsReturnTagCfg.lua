-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class OpsReturnTagCfg : CfgBase
local OpsReturnTagCfg = {
	TableName = "c_ops_return_tag_cfg",
    LruKeyType = nil,
	KeyName = "TagID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(OpsReturnTagCfg, { __index = CfgBase })

OpsReturnTagCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return OpsReturnTagCfg
