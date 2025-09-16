-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ScoreSummaryTypeCfg : CfgBase
local ScoreSummaryTypeCfg = {
	TableName = "c_score_summary_type_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ScoreSummaryTabShow',
            },
            {
                Name = 'SubTypeShow',
            },
		}
    },
    DefaultValues = {
        ID = 1,
        IconPath = 'Texture2D\'/Game/UI/Texture/Equipment/UI_CurrencyView_Icon_Way04.UI_CurrencyView_Icon_Way04\'',
        ScoreSumType = 1,
        SubType = 1,
    },
	LuaData = {
        {
        },
        {
            ID = 2,
            IconPath = 'Texture2D\'/Game/UI/Texture/Equipment/UI_CurrencyView_Icon_Way05.UI_CurrencyView_Icon_Way05\'',
            SubType = 2,
        },
        {
            ID = 3,
            IconPath = 'Texture2D\'/Game/UI/Texture/Equipment/UI_CurrencyView_Icon_Way06.UI_CurrencyView_Icon_Way06\'',
            SubType = 10,
        },
        {
            ID = 4,
            IconPath = 'Texture2D\'/Game/UI/Texture/Equipment/UI_CurrencyView_Icon_Way07.UI_CurrencyView_Icon_Way07\'',
            SubType = 11,
        },
        {
            ID = 5,
            IconPath = 'Texture2D\'/Game/UI/Texture/Equipment/UI_CurrencyView_Icon_Way01.UI_CurrencyView_Icon_Way01\'',
            ScoreSumType = 2,
            SubType = 3,
        },
        {
            ID = 6,
            IconPath = 'Texture2D\'/Game/UI/Texture/Equipment/UI_CurrencyView_Icon_Way03.UI_CurrencyView_Icon_Way03\'',
            ScoreSumType = 2,
            SubType = 4,
        },
        {
            ID = 7,
            IconPath = 'Texture2D\'/Game/UI/Texture/Equipment/UI_CurrencyView_Icon_Way02.UI_CurrencyView_Icon_Way02\'',
            ScoreSumType = 2,
            SubType = 5,
        },
        {
            ID = 8,
            IconPath = 'Texture2D\'/Game/UI/Texture/Equipment/UI_CurrencyView_Icon_Way08.UI_CurrencyView_Icon_Way08\'',
            ScoreSumType = 3,
            SubType = 6,
        },
        {
            ID = 9,
            IconPath = 'Texture2D\'/Game/UI/Texture/Equipment/UI_CurrencyView_Icon_Way09.UI_CurrencyView_Icon_Way09\'',
            ScoreSumType = 3,
            SubType = 7,
        },
        {
            ID = 10,
            IconPath = 'Texture2D\'/Game/UI/Texture/Equipment/UI_CurrencyView_Icon_Way10.UI_CurrencyView_Icon_Way10\'',
            ScoreSumType = 4,
            SubType = 9,
        },
	},
}

setmetatable(ScoreSummaryTypeCfg, { __index = CfgBase })

ScoreSummaryTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ScoreSummaryTypeCfg
