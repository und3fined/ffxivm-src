-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class QuestTargetCfg : CfgBase
local QuestTargetCfg = {
	TableName = "c_quest_target_cfg",
    LruKeyType = "integer",
	KeyName = "id",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'm_szTargetDesc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(QuestTargetCfg, { __index = CfgBase })

QuestTargetCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return QuestTargetCfg
