-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ReddotCfg : CfgBase
local ReddotCfg = {
	TableName = "c_reddot_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ReddotCfg, { __index = CfgBase })

ReddotCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ReddotCfg
