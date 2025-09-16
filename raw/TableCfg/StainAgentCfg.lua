-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class StainAgentCfg : CfgBase
local StainAgentCfg = {
	TableName = "StainAgent",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(StainAgentCfg, { __index = CfgBase })

StainAgentCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return StainAgentCfg
