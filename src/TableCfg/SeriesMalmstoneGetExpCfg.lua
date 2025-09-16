-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SeriesMalmstoneGetExpCfg : CfgBase
local SeriesMalmstoneGetExpCfg = {
	TableName = "c_SeriesMalmstoneGetExp_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Title',
            },
            {
                Name = 'Description',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(SeriesMalmstoneGetExpCfg, { __index = CfgBase })

SeriesMalmstoneGetExpCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return SeriesMalmstoneGetExpCfg
