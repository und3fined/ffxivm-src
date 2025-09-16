-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SeriesMalmstoneSeasonCfg : CfgBase
local SeriesMalmstoneSeasonCfg = {
	TableName = "c_SeriesMalmstoneSeason_cfg",
    LruKeyType = nil,
	KeyName = "SeasonID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        BeginTime = '2025-08-11 06:00:00',
        EndTime = '2025-11-19 23:59:59',
        LevelGroup = 1,
        LevelMax = 100,
        SeasonID = 1,
    },
	LuaData = {
        {
        },
	},
}

setmetatable(SeriesMalmstoneSeasonCfg, { __index = CfgBase })

SeriesMalmstoneSeasonCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return SeriesMalmstoneSeasonCfg
