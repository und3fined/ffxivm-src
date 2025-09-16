-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class DiscoverNoteCfg : CfgBase
local DiscoverNoteCfg = {
	TableName = "c_DiscoverNote_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'MapName',
            },
            {
                Name = 'ImpTitle',
            },
            {
                Name = 'ImpText',
            },
            {
                Name = 'RecordTitle',
            },
            {
                Name = 'RecordText',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(DiscoverNoteCfg, { __index = CfgBase })

DiscoverNoteCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return DiscoverNoteCfg
