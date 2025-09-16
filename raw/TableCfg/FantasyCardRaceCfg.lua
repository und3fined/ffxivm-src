-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FantasyCardRaceCfg : CfgBase
local FantasyCardRaceCfg = {
	TableName = "c_fantasy_card_race_cfg",
    LruKeyType = nil,
	KeyName = "Race",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'RaceName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FantasyCardRaceCfg, { __index = CfgBase })

FantasyCardRaceCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FantasyCardRaceCfg
