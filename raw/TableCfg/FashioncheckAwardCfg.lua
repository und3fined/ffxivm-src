-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FashioncheckAwardCfg : CfgBase
local FashioncheckAwardCfg = {
	TableName = "c_fashioncheck_award_cfg",
    LruKeyType = nil,
	KeyName = "AwardLevel",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        AwardLevel = 1,
        CelebrationCoins = 2,
        Coins = 20000,
        CommentInternal = 0.5,
        Content = '达到%s分',
        Score = 0,
        ScoreDurationStageOne = 2.0,
        ScoreDurationStageTwo = 1.5,
        ScoreEffectSpeedScale = 1.0,
    },
	LuaData = {
        {
            Coins = 5000,
            CommentInternal = 3.0,
            Content = '参与挑战',
        },
        {
            AwardLevel = 2,
            CelebrationCoins = 4,
            Coins = 15000,
            CommentInternal = 1.0,
            Score = 75,
        },
        {
            AwardLevel = 3,
            CelebrationCoins = 6,
            Score = 90,
        },
        {
            AwardLevel = 4,
            CelebrationCoins = 8,
            Score = 95,
        },
	},
}

setmetatable(FashioncheckAwardCfg, { __index = CfgBase })

FashioncheckAwardCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FashioncheckAwardCfg
