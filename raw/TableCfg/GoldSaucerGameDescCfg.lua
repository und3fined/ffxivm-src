-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GoldSaucerGameDescCfg : CfgBase
local GoldSaucerGameDescCfg = {
	TableName = "c_gold_saucer_game_desc_cfg",
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

setmetatable(GoldSaucerGameDescCfg, { __index = CfgBase })

GoldSaucerGameDescCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GoldSaucerGameDescCfg
