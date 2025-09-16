-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LegendaryWeaponTopicCfg : CfgBase
local LegendaryWeaponTopicCfg = {
	TableName = "c_legendary_weapon_topic_cfg",
    LruKeyType = nil,
	KeyName = "TopicID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'Chap1Text',
            },
            {
                Name = 'Chap2Text',
            },
            {
                Name = 'Chap3Text',
            },
		}
    },
    DefaultValues = {
        Chap1Anime = '',
        Chap2Anime = '',
        Chap3Anime = '',
        Class = '10_12_15_16_17_18_21_22_25_26',
        FinishMotion = '',
        FirstType = 400101,
        Logo = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_LightWeapon_Antiquity_Select.UI_Icon_Tab_LightWeapon_Antiquity_Select\'',
        OpenMotion = '',
        PreImg = '',
        PrePV = '',
        PreTime = '',
        QuestID = 0,
        Scd = '',
        ShopID = 4001,
        TopicID = 1,
        Version = '2.0.1',
    },
	LuaData = {
        {
        },
        {
            Logo = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_LightWeapon_Ecliptic_Select.UI_Icon_Tab_LightWeapon_Ecliptic_Select\'',
            TopicID = 2,
            Version = '2.2.0',
        },
	},
}

setmetatable(LegendaryWeaponTopicCfg, { __index = CfgBase })

LegendaryWeaponTopicCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return LegendaryWeaponTopicCfg
