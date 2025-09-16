-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FantasyTournamentCfg : CfgBase
local FantasyTournamentCfg = {
	TableName = "c_fantasy_tournament_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Title',
            },
            {
                Name = 'CupName',
            },
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FantasyTournamentCfg, { __index = CfgBase })

FantasyTournamentCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FantasyTournamentCfg
