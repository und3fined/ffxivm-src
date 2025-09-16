-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class InstrumentCfg : CfgBase
local InstrumentCfg = {
	TableName = "c_instrument_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(InstrumentCfg, { __index = CfgBase })

InstrumentCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return InstrumentCfg
