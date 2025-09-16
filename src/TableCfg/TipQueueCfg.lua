-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TipQueueCfg : CfgBase
local TipQueueCfg = {
	TableName = "c_tip_queue_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(TipQueueCfg, { __index = CfgBase })

TipQueueCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return TipQueueCfg
