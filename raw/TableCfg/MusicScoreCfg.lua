-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MusicScoreCfg : CfgBase
local MusicScoreCfg = {
	TableName = "c_music_score_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Determination',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MusicScoreCfg, { __index = CfgBase })

MusicScoreCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MusicScoreCfg
