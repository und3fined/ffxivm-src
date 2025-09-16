-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ChallengeLogRewardCfg : CfgBase
local ChallengeLogRewardCfg = {
	TableName = "c_challenge_log_reward_cfg",
    LruKeyType = nil,
	KeyName = "Num",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = {
        Count = 5,
        Icon = 'Texture2D\'/Game/Assets/Icon/061000/UI_Icon_061811.UI_Icon_061811\'',
        LootID = 85000044,
        Num = 20,
        _Produce = '[{"Num":0,"ID":0},{"Num":0,"ID":0},{"Num":0,"ID":0},{"Num":0,"ID":0}]',
    },
	LuaData = {
        {
        },
        {
            Count = 10,
            LootID = 85000045,
            Num = 40,
        },
        {
            Count = 15,
            LootID = 85000048,
            Num = 60,
        },
        {
            Count = 20,
            LootID = 85000049,
            Num = 80,
        },
        {
            Count = 25,
            LootID = 85000050,
            Num = 100,
        },
	},
}

setmetatable(ChallengeLogRewardCfg, { __index = CfgBase })

ChallengeLogRewardCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ChallengeLogRewardCfg
