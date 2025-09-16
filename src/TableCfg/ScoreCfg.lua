-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ScoreCfg : CfgBase
local ScoreCfg = {
	TableName = "c_score_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'NameText',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ScoreCfg, { __index = CfgBase })

ScoreCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ScoreCfg
