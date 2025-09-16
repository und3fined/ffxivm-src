-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CommStatCfg : CfgBase
local CommStatCfg = {
	TableName = "c_comm_stat_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CommStatCfg, { __index = CfgBase })

CommStatCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return CommStatCfg
