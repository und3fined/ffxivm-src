-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SavageRankCfg : CfgBase
local SavageRankCfg = {
	TableName = "c_SavageRank_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'SceneName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(SavageRankCfg, { __index = CfgBase })

SavageRankCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return SavageRankCfg
