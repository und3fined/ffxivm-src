-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LegendaryWeaponChapterCfg : CfgBase
local LegendaryWeaponChapterCfg = {
	TableName = "c_legendary_weapon_chapter_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        ChapterID = 1,
        ID = 1,
        MajorVersion = 2,
        MinorVersion = 0,
        PatchVersion = 0,
        SpecialItemsHelp = '',
        TopicID = 1,
        Version = '2.0.1',
    },
	LuaData = {
        {
            PatchVersion = 1,
        },
        {
            ChapterID = 2,
            ID = 2,
            PatchVersion = 5,
            SpecialItemsHelp = '使用第一章上古武器进行指定的危命战斗后获得',
            Version = '2.0.5',
        },
        {
            ChapterID = 3,
            ID = 3,
            MinorVersion = 1,
            Version = '2.1.0',
        },
        {
            ID = 4,
            MinorVersion = 2,
            TopicID = 2,
            Version = '2.2.0',
        },
        {
            ChapterID = 2,
            ID = 5,
            MinorVersion = 2,
            PatchVersion = 5,
            SpecialItemsHelp = '使用第一章黄道武器进行指定的副本战斗后获得',
            TopicID = 2,
            Version = '2.2.5',
        },
        {
            ChapterID = 3,
            ID = 6,
            MinorVersion = 3,
            TopicID = 2,
            Version = '2.3.0',
        },
	},
}

setmetatable(LegendaryWeaponChapterCfg, { __index = CfgBase })

LegendaryWeaponChapterCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return LegendaryWeaponChapterCfg
