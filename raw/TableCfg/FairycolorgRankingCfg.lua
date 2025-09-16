-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FairycolorgRankingCfg : CfgBase
local FairycolorgRankingCfg = {
	TableName = "c_fairycolorgRanking_cfg",
    LruKeyType = nil,
	KeyName = "Level",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'RewardName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FairycolorgRankingCfg, { __index = CfgBase })

FairycolorgRankingCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FairycolorgRankingCfg
