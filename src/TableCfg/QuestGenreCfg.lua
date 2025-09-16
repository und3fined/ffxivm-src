-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class QuestGenreCfg : CfgBase
local QuestGenreCfg = {
	TableName = "c_quest_genre_cfg",
    LruKeyType = nil,
	KeyName = "QuestGenreID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'MainGenre',
            },
            {
                Name = 'SubGenre',
            },
            {
                Name = 'DetailedGenre',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(QuestGenreCfg, { __index = CfgBase })

QuestGenreCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return QuestGenreCfg
