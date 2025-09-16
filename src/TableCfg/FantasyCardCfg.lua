-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FantasyCardCfg : CfgBase
local FantasyCardCfg = {
	TableName = "c_fantasy_card_cfg",
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

setmetatable(FantasyCardCfg, { __index = CfgBase })

FantasyCardCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FantasyCardCfg
