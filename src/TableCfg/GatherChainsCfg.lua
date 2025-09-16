-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GatherChainsCfg : CfgBase
local GatherChainsCfg = {
	TableName = "c_gather_chains_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GatherChainsCfg, { __index = CfgBase })

GatherChainsCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GatherChainsCfg
