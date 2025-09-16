-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class InstrumentGroupCfg : CfgBase
local InstrumentGroupCfg = {
	TableName = "c_instrument_group_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(InstrumentGroupCfg, { __index = CfgBase })

InstrumentGroupCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return InstrumentGroupCfg
