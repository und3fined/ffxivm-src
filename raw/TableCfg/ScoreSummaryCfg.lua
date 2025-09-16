-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

local CS = {
    _2_1 = '[200184]',
}

---@class ScoreSummaryCfg : CfgBase
local ScoreSummaryCfg = {
	TableName = "c_score_summary_cfg",
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
    DefaultValues = {
        CurrencyShowOrder = 1,
        ID = 19000001,
        IsUpperLimit = 1,
        JumpIconPath = 'Texture2D\'/Game/UI/Texture/Equipment/UI_CurrencyView_Btn_Get01.UI_CurrencyView_Btn_Get01\'',
        _PreTask = '[]',
        ScoreSummary = 1,
        ShopID = 0,
        SubHead = 3,
        SubHeadOrder = 1,
    },
	LuaData = {
        {
            IsUpperLimit = 0,
            JumpIconPath = 'Texture2D\'/Game/UI/Texture/Equipment/UI_CurrencyView_Btn_Get02.UI_CurrencyView_Btn_Get02\'',
            SubHead = 1,
        },
        {
            CurrencyShowOrder = 2,
            ID = 19000002,
            IsUpperLimit = 0,
            JumpIconPath = 'Texture2D\'/Game/UI/Texture/Equipment/UI_CurrencyView_Btn_Get03.UI_CurrencyView_Btn_Get03\'',
            SubHead = 1,
        },
        {
            ID = 19000004,
            _PreTask = '[170285]',
            ShopID = 2002,
            SubHead = 2,
            SubHeadOrder = 2,
        },
        {
            ID = 19000005,
            ShopID = 2001,
            SubHead = 10,
            SubHeadOrder = 3,
        },
        {
            ID = 19000100,
            ScoreSummary = 2,
            ShopID = 3005,
        },
        {
            CurrencyShowOrder = 2,
            ID = 19000101,
            ScoreSummary = 2,
            ShopID = 3006,
        },
        {
            CurrencyShowOrder = 3,
            ID = 19000102,
            ScoreSummary = 2,
            ShopID = 3007,
        },
        {
            ID = 19000103,
            ScoreSummary = 2,
            ShopID = 3010,
            SubHead = 5,
            SubHeadOrder = 2,
        },
        {
            ID = 19000105,
            IsUpperLimit = 0,
            ShopID = 2003,
            SubHead = 11,
            SubHeadOrder = 4,
        },
        {
            CurrencyShowOrder = 2,
            ID = 19000106,
            IsUpperLimit = 0,
            ShopID = 2004,
            SubHead = 11,
            SubHeadOrder = 4,
        },
        {
            CurrencyShowOrder = 3,
            ID = 19000107,
            IsUpperLimit = 0,
            ShopID = 2005,
            SubHead = 11,
            SubHeadOrder = 4,
        },
        {
            ID = 19000108,
            ScoreSummary = 2,
            ShopID = 3011,
            SubHead = 4,
            SubHeadOrder = 3,
        },
        {
            ID = 19000200,
            _PreTask = CS._2_1,
            ScoreSummary = 3,
            ShopID = 3001,
            SubHead = 6,
        },
        {
            CurrencyShowOrder = 2,
            ID = 19000201,
            _PreTask = CS._2_1,
            ScoreSummary = 3,
            ShopID = 3002,
            SubHead = 6,
        },
        {
            ID = 19000202,
            _PreTask = CS._2_1,
            ScoreSummary = 3,
            ShopID = 3003,
            SubHead = 7,
            SubHeadOrder = 2,
        },
        {
            CurrencyShowOrder = 2,
            ID = 19000203,
            _PreTask = CS._2_1,
            ScoreSummary = 3,
            ShopID = 3004,
            SubHead = 7,
            SubHeadOrder = 2,
        },
	},
}

setmetatable(ScoreSummaryCfg, { __index = CfgBase })

ScoreSummaryCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ScoreSummaryCfg
