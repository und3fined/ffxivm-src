-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FantasyTournamentEffectCfg : CfgBase
local FantasyTournamentEffectCfg = {
	TableName = "c_fantasy_tournament_effect_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FantasyTournamentEffectCfg, { __index = CfgBase })

FantasyTournamentEffectCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FantasyTournamentEffectCfg
