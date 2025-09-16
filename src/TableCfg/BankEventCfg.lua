-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BankEventCfg : CfgBase
local BankEventCfg = {
	TableName = "c_bank_event_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BankEventCfg, { __index = CfgBase })

BankEventCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return BankEventCfg
