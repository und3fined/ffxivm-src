-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TwelveGodCfg : CfgBase
local TwelveGodCfg = {
	TableName = "c_twelve_god_cfg",
    LruKeyType = nil,
	KeyName = "GodID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'Title',
            },
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(TwelveGodCfg, { __index = CfgBase })

TwelveGodCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return TwelveGodCfg
