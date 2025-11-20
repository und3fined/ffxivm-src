-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class WilderExploreAwardTypeCfg : CfgBase
local WilderExploreAwardTypeCfg = {
	TableName = "c_wilder_explore_award_type_cfg",
    LruKeyType = nil,
	KeyName = "AwardType",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'TypeTitle',
            },
		}
    },
    DefaultValues = {
        AwardIcon = 'PaperSprite\'/Game/UI/Atlas/WorldExplora/Frames/UI_WorldExplora_Icon_Award_Tab01_png.UI_WorldExplora_Icon_Award_Tab01_png\'',
        AwardIconSelected = 'PaperSprite\'/Game/UI/Atlas/WorldExplora/Frames/UI_WorldExplora_Icon_Award_Tab01_Select_png.UI_WorldExplora_Icon_Award_Tab01_Select_png\'',
        AwardType = 1,
    },
	LuaData = {
        {
        },
        {
            AwardIcon = 'PaperSprite\'/Game/UI/Atlas/WorldExplora/Frames/UI_WorldExplora_Icon_Award_Tab02_png.UI_WorldExplora_Icon_Award_Tab02_png\'',
            AwardIconSelected = 'PaperSprite\'/Game/UI/Atlas/WorldExplora/Frames/UI_WorldExplora_Icon_Award_Tab02_Select_png.UI_WorldExplora_Icon_Award_Tab02_Select_png\'',
            AwardType = 2,
        },
        {
            AwardIcon = 'PaperSprite\'/Game/UI/Atlas/WorldExplora/Frames/UI_WorldExplora_Icon_Award_Tab03_png.UI_WorldExplora_Icon_Award_Tab03_png\'',
            AwardIconSelected = 'PaperSprite\'/Game/UI/Atlas/WorldExplora/Frames/UI_WorldExplora_Icon_Award_Tab03_Select_png.UI_WorldExplora_Icon_Award_Tab03_Select_png\'',
            AwardType = 3,
        },
	},
}

setmetatable(WilderExploreAwardTypeCfg, { __index = CfgBase })

WilderExploreAwardTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return WilderExploreAwardTypeCfg
