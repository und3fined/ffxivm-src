-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

local CS = {
    _5_1 = '[{"RewardID":84220007,"ProofID":66200029},{"RewardID":84220008,"ProofID":66200030},{"RewardID":84220009,"ProofID":66200031}]',
    _6_1 = '[84220006,84220005,84220004,84220003,84220002,84220001]',
}

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
        BeginVersion = '2.1.0',
        EndTime = '2025-11-19 23:59:59',
        EndVersion = '2.2.0',
        LevelGroup = 3,
        LevelMax = 100,
        _RankProof = '[{"RewardID":0,"ProofID":0},{"RewardID":0,"ProofID":0},{"RewardID":0,"ProofID":0}]',
        _RankReward = '[]',
        Season = 0,
        SeasonID = 1,
        StarRoadBeginTime = '2025-08-11 06:00:00',
        StarRoadEndTime = '2025-11-19 23:59:59',
    },
	LuaData = {
        {
            LevelGroup = 1,
        },
        {
            BeginTime = '2025-11-20 12:00:00',
            BeginVersion = '2.2.0',
            EndTime = '2026-03-11 23:59:59',
            EndVersion = '2.3.0',
            LevelGroup = 2,
            SeasonID = 2,
            StarRoadBeginTime = '2025-11-20 12:00:00',
            StarRoadEndTime = '2026-03-11 23:59:59',
        },
        {
            BeginTime = '2026-03-12 12:00:00',
            BeginVersion = '2.3.0',
            EndTime = '2026-08-26 23:59:59',
            EndVersion = '3.0.0',
            _RankProof = CS._5_1,
            _RankReward = CS._6_1,
            Season = 1,
            SeasonID = 3,
            StarRoadBeginTime = '2026-03-12 12:00:00',
            StarRoadEndTime = '2026-08-26 23:59:59',
        },
        {
            BeginTime = '2026-08-27 10:00:00',
            BeginVersion = '3.0.0',
            EndTime = '2027-01-13 23:59:59',
            EndVersion = '3.1.0',
            _RankProof = CS._5_1,
            _RankReward = CS._6_1,
            Season = 2,
            SeasonID = 4,
            StarRoadBeginTime = '2026-08-27 10:00:00',
            StarRoadEndTime = '2027-01-13 23:59:59',
        },
	},
}

setmetatable(SeriesMalmstoneSeasonCfg, { __index = CfgBase })

SeriesMalmstoneSeasonCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return SeriesMalmstoneSeasonCfg
