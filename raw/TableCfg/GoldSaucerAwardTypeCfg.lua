-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GoldSaucerAwardTypeCfg : CfgBase
local GoldSaucerAwardTypeCfg = {
	TableName = "c_gold_saucer_award_type_cfg",
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
        AwardIcon = 'Texture2D\'/Game/UI/Texture/GoldSauserMainPanel/UI_GoldSauserMainPanel_Icon_Award_ChamberofCommerce_Normal.UI_GoldSauserMainPanel_Icon_Award_ChamberofCommerce_Normal\'',
        AwardIconSelected = 'Texture2D\'/Game/UI/Texture/GoldSauserMainPanel/UI_GoldSauserMainPanel_Icon_Award_ChamberofCommerce_Select.UI_GoldSauserMainPanel_Icon_Award_ChamberofCommerce_Select\'',
        AwardType = 1,
    },
	LuaData = {
        {
        },
        {
            AwardIcon = 'Texture2D\'/Game/UI/Texture/GoldSauserMainPanel/UI_GoldSauserMainPanel_Icon_Award_Achievement_Normal.UI_GoldSauserMainPanel_Icon_Award_Achievement_Normal\'',
            AwardIconSelected = 'Texture2D\'/Game/UI/Texture/GoldSauserMainPanel/UI_GoldSauserMainPanel_Icon_Award_Achievement_Select.UI_GoldSauserMainPanel_Icon_Award_Achievement_Select\'',
            AwardType = 2,
        },
	},
}

setmetatable(GoldSaucerAwardTypeCfg, { __index = CfgBase })

GoldSaucerAwardTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GoldSaucerAwardTypeCfg
