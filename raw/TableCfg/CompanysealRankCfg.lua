-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CompanysealRankCfg : CfgBase
local CompanysealRankCfg = {
	TableName = "c_companyseal_rank_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'RankName',
            },
            {
                Name = 'Desc',
            },
            {
                Name = 'ShowDesc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CompanysealRankCfg, { __index = CfgBase })

CompanysealRankCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return CompanysealRankCfg
