-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

local CS = {
    _1_1 = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_20_png.UI_Adventure_Icon_Recommend_20_png\'',
    _1_2 = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_06_png.UI_Adventure_Icon_Recommend_06_png\'',
}

---@class RecommendQuestCfg : CfgBase
local RecommendQuestCfg = {
	TableName = "c_recommend_quest_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'UnlockTip',
            },
		}
    },
    DefaultValues = {
        ChapterID = 0,
        GrandCompanyLimit = 0,
        ID = 1,
        LevelLimit = 50,
        Priority = 1,
        ProfLimit = 11,
        QuestIconPath = '',
        Top = 0,
        Type = 1,
        UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_16_png.UI_Adventure_Icon_Recommend_16_png\'',
    },
	LuaData = {
        {
            ChapterID = 17280,
            LevelLimit = 1,
            ProfLimit = 0,
            UnlockIconPath = '',
        },
        {
            ChapterID = 15117,
            ID = 2,
            LevelLimit = 10,
            Priority = 3,
            ProfLimit = 0,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_01_png.UI_Adventure_Icon_Recommend_01_png\'',
        },
        {
            ChapterID = 17281,
            ID = 3,
            LevelLimit = 10,
            Priority = 4,
            ProfLimit = 0,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_02_png.UI_Adventure_Icon_Recommend_02_png\'',
        },
        {
            ChapterID = 17286,
            ID = 4,
            LevelLimit = 10,
            Priority = 11,
            ProfLimit = 0,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_03_png.UI_Adventure_Icon_Recommend_03_png\'',
        },
        {
            ChapterID = 17284,
            ID = 5,
            LevelLimit = 1,
            Priority = 2,
            ProfLimit = 9,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_04_png.UI_Adventure_Icon_Recommend_04_png\'',
        },
        {
            ChapterID = 17107,
            ID = 6,
            LevelLimit = 15,
            Priority = 13,
            Top = 1,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_05_png.UI_Adventure_Icon_Recommend_05_png\'',
        },
        {
            ChapterID = 17282,
            ID = 7,
            LevelLimit = 21,
            Priority = 17,
            ProfLimit = 0,
            UnlockIconPath = CS._1_2,
        },
        {
            ChapterID = 20053,
            ID = 8,
            LevelLimit = 40,
            Priority = 19,
            ProfLimit = 9,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_07_png.UI_Adventure_Icon_Recommend_07_png\'',
        },
        {
            ChapterID = 21019,
            ID = 9,
            Priority = 20,
            ProfLimit = 8,
            Top = 1,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_08_png.UI_Adventure_Icon_Recommend_08_png\'',
        },
        {
            ChapterID = 17074,
            ID = 10,
            LevelLimit = 10,
            Priority = 5,
            ProfLimit = 0,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_09_png.UI_Adventure_Icon_Recommend_09_png\'',
        },
        {
            ChapterID = 17273,
            ID = 11,
            LevelLimit = 10,
            Priority = 6,
            ProfLimit = 0,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_10_png.UI_Adventure_Icon_Recommend_10_png\'',
        },
        {
            ChapterID = 17276,
            ID = 12,
            LevelLimit = 10,
            Priority = 7,
            ProfLimit = 0,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_11_png.UI_Adventure_Icon_Recommend_11_png\'',
        },
        {
            ChapterID = 17275,
            ID = 13,
            LevelLimit = 10,
            Priority = 8,
            ProfLimit = 0,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_12_png.UI_Adventure_Icon_Recommend_12_png\'',
        },
        {
            ChapterID = 17274,
            ID = 14,
            LevelLimit = 10,
            Priority = 9,
            ProfLimit = 0,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_13_png.UI_Adventure_Icon_Recommend_13_png\'',
        },
        {
            ChapterID = 17287,
            ID = 15,
            LevelLimit = 17,
            Priority = 12,
            ProfLimit = 0,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_14_png.UI_Adventure_Icon_Recommend_14_png\'',
        },
        {
            ChapterID = 17197,
            ID = 16,
            LevelLimit = 30,
            Priority = 18,
            ProfLimit = 0,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_15_png.UI_Adventure_Icon_Recommend_15_png\'',
        },
        {
            ChapterID = 22003,
            ID = 17,
            Type = 2,
        },
        {
            ChapterID = 15212,
            ID = 18,
            Type = 3,
        },
        {
            ChapterID = 15213,
            ID = 19,
            Priority = 2,
            Type = 3,
        },
        {
            ChapterID = 15214,
            ID = 20,
            Priority = 3,
            Type = 3,
        },
        {
            ChapterID = 15215,
            ID = 21,
            Priority = 4,
            Type = 3,
        },
        {
            ChapterID = 17309,
            ID = 22,
            LevelLimit = 15,
            Type = 4,
        },
        {
            ChapterID = 17308,
            ID = 23,
            LevelLimit = 32,
            Priority = 2,
            Type = 4,
        },
        {
            ChapterID = 17310,
            ID = 24,
            LevelLimit = 45,
            Priority = 3,
            Type = 4,
        },
        {
            ChapterID = 21033,
            ID = 25,
            Priority = 4,
            Type = 2,
        },
        {
            ChapterID = 15216,
            ID = 26,
            Priority = 5,
            Type = 3,
        },
        {
            ChapterID = 15217,
            ID = 27,
            Priority = 6,
            Type = 3,
        },
        {
            ChapterID = 15218,
            ID = 28,
            Priority = 7,
            Type = 3,
        },
        {
            ChapterID = 21013,
            ID = 29,
            Priority = 8,
            Type = 3,
        },
        {
            ChapterID = 21015,
            ID = 30,
            Priority = 9,
            Type = 3,
        },
        {
            ChapterID = 21034,
            ID = 31,
            Priority = 11,
            Type = 3,
        },
        {
            ChapterID = 21035,
            ID = 32,
            Priority = 12,
            Type = 3,
        },
        {
            ChapterID = 24010,
            GrandCompanyLimit = 2,
            ID = 33,
            LevelLimit = 25,
            Priority = 14,
            UnlockIconPath = CS._1_1,
        },
        {
            ChapterID = 24011,
            GrandCompanyLimit = 1,
            ID = 34,
            LevelLimit = 25,
            Priority = 15,
            UnlockIconPath = CS._1_1,
        },
        {
            ChapterID = 24012,
            GrandCompanyLimit = 3,
            ID = 35,
            LevelLimit = 25,
            Priority = 16,
            UnlockIconPath = CS._1_1,
        },
        {
            ChapterID = 16101,
            ID = 36,
            Priority = 2,
            Type = 2,
        },
        {
            ChapterID = 16102,
            ID = 37,
            Priority = 3,
            Type = 2,
        },
        {
            ChapterID = 15014,
            ID = 38,
            LevelLimit = 10,
            Priority = 10,
            ProfLimit = 0,
            UnlockIconPath = CS._1_2,
        },
        {
            ChapterID = 17288,
            ID = 39,
            Priority = 21,
            UnlockIconPath = 'PaperSprite\'/Game/UI/Atlas/Adventure/Frames/UI_Adventure_Icon_Recommend_17_png.UI_Adventure_Icon_Recommend_17_png\'',
        },
        {
            ChapterID = 21014,
            ID = 40,
            Priority = 10,
            Type = 3,
        },
        {
            ID = 41,
            Priority = 10,
            Type = 3,
        },
        {
            ID = 42,
            Priority = 10,
            Type = 3,
        },
	},
}

setmetatable(RecommendQuestCfg, { __index = CfgBase })

RecommendQuestCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return RecommendQuestCfg
