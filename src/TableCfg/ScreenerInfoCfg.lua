-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

local CS = {
    _1_1 = '["MapID == 0"]',
    _1_2 = '["Classify == 1"]',
    _1_3 = '["Classify == 2"]',
    _1_4 = '["Classify == 3"]',
    _1_5 = '["Classify == 4"]',
    _1_6 = '["Classify == 5"]',
    _1_7 = '["Classify == 6"]',
    _1_8 = '["Classify == 7"]',
    _1_9 = '["Classify == 9"]',
    _1_10 = '["Classify == 8"]',
    _1_11 = '["Classify == 10"]',
    _1_12 = '["Classify == 11"]',
    _1_13 = '["ItemLevel==30"]',
    _1_14 = '["IsHQ==1"]',
    _1_15 = '["Classify == 15"]',
    _1_16 = '["FilterType==203","Classify == 15"]',
    _1_17 = '["ItemLevel>=1","ItemLevel<=50"]',
    _1_18 = '["ItemLevel>=51","ItemLevel<=100"]',
    _1_19 = '["ItemLevel>=101","ItemLevel<=150"]',
    _1_20 = '["FilterType==2"]',
    _1_21 = '["FilterType==3"]',
    _1_22 = '["FilterType==4"]',
    _1_23 = '["FilterType==5"]',
    _1_24 = '["ItemLevel==10"]',
    _1_25 = '["ItemLevel==20"]',
    _1_26 = '["ItemLevel==40"]',
    _1_27 = '["ItemLevel==50"]',
    _1_28 = '["ItemLevel==60"]',
    _1_29 = '["ItemLevel==70"]',
    _1_30 = '["ItemLevel==80"]',
    _1_31 = '["ItemLevel==90"]',
    _1_32 = '["IsHQ==0"]',
    _1_33 = '["ItemType == 201"]',
    _1_34 = '["ItemType == 202"]',
    _1_35 = '["ItemType == 203"]',
    _1_36 = '["ItemType == 204"]',
    _1_37 = '["ItemType == 205"]',
    _1_38 = '["ItemType == 206"]',
    _1_39 = '["ItemType == 207"]',
    _1_40 = '["ItemType == 200"]',
    _1_41 = '["ItemType == 208"]',
    _1_42 = '["FilterType==201","Classify == 15"]',
    _1_43 = '["FilterType==202","Classify == 15"]',
    _1_44 = '["ItemLevel>=151","ItemLevel<=200"]',
    _1_45 = '["FilterType==101"]',
    _1_46 = '["FilterType==102"]',
    _1_47 = '["FilterType==103"]',
    _1_48 = '["QuestGenreID == 10100"]',
    _1_49 = '["QuestGenreID == 10200"]',
    _1_50 = '["QuestGenreID >= 20101","QuestGenreID <= 20103"]',
    _1_51 = '["QuestGenreID >= 20201","QuestGenreID <= 20210"]',
    _1_52 = '["QuestGenreID >= 20301","QuestGenreID <= 20308"]',
    _1_53 = '["QuestGenreID >= 20401","QuestGenreID <= 20403"]',
    _1_54 = '["QuestGenreID >= 20501","QuestGenreID <= 20509"]',
    _1_55 = '["QuestGenreID >= 20601","QuestGenreID <= 20603"]',
    _1_56 = '["QuestGenreID >= 20901","QuestGenreID <= 20904"]',
    _1_57 = '["QuestGenreID >= 30301","QuestGenreID <= 30309"]',
    _1_58 = '["QuestGenreID >= 30401","QuestGenreID <= 30402"]',
    _1_59 = '["FilterType==6"]',
    _1_60 = '["FilterType==7"]',
    _1_61 = '["FilterType==1"]',
}

---@class ScreenerInfoCfg : CfgBase
local ScreenerInfoCfg = {
	TableName = "c_screener_info_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ScreenerName',
            },
		}
    },
    DefaultValues = {
        _FilterAnd = '[]',
        _FilterOR = '[]',
        ID = 1,
        ScreenerID = 26,
        ScreenerIcon = '',
    },
	LuaData = {
        {
            _FilterOR = '["ProfLimit == {10}","ClassLimit == 1","ClassLimit == 8","ProfLimit == {10,1}","ProfLimit == {1,10}"]',
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {12}","ClassLimit == 1","ClassLimit == 8","ProfLimit == {12,2}","ProfLimit == {2,12}"]',
            ID = 2,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {16}","ClassLimit == 2","ClassLimit == 8","ProfLimit == {16,4}","ProfLimit == {4,16}"]',
            ID = 3,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {17}","ClassLimit == 2","ClassLimit == 8","ProfLimit == {17,3}","ProfLimit == {3,17}"]',
            ID = 4,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {18}","ClassLimit == 3","ClassLimit == 8","ProfLimit == {18,6}","ProfLimit == {6,18}"]',
            ID = 5,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {21}","ClassLimit == 4","ClassLimit == 8","ProfLimit == {21,7}","ProfLimit == {7,21}"]',
            ID = 6,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {22}","ClassLimit == 4","ClassLimit == 8","ProfLimit == {22,8}","ProfLimit == {8,22}"]',
            ID = 7,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {25}","ClassLimit == 5","ClassLimit == 8","ProfLimit == {25,9}","ProfLimit == {9,25}"]',
            ID = 8,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {26}","ClassLimit == 5","ClassLimit == 8","ProfLimit == {26}","ProfLimit == {26}"]',
            ID = 9,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {34}","ClassLimit == 6","ClassLimit == 9"]',
            ID = 10,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {35}","ClassLimit == 6","ClassLimit == 9"]',
            ID = 11,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {30}","ClassLimit == 6","ClassLimit == 9"]',
            ID = 12,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {28}","ClassLimit == 6","ClassLimit == 9"]',
            ID = 13,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {29}","ClassLimit == 6","ClassLimit == 9"]',
            ID = 14,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {31}","ClassLimit == 6","ClassLimit == 9"]',
            ID = 15,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {33}","ClassLimit == 6","ClassLimit == 9"]',
            ID = 16,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {32}","ClassLimit == 6","ClassLimit == 9"]',
            ID = 17,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {36}","ClassLimit == 7","ClassLimit == 9"]',
            ID = 18,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {37}","ClassLimit == 7","ClassLimit == 9"]',
            ID = 19,
            ScreenerID = 1,
        },
        {
            _FilterOR = '["ProfLimit == {38}","ClassLimit == 7","ClassLimit == 9"]',
            ID = 20,
            ScreenerID = 1,
        },
        {
            _FilterAnd = CS._1_2,
            ID = 21,
            ScreenerID = 2,
        },
        {
            _FilterAnd = CS._1_3,
            ID = 22,
            ScreenerID = 2,
        },
        {
            _FilterAnd = CS._1_4,
            ID = 23,
            ScreenerID = 2,
        },
        {
            _FilterAnd = CS._1_5,
            ID = 24,
            ScreenerID = 2,
        },
        {
            _FilterAnd = CS._1_6,
            ID = 25,
            ScreenerID = 2,
        },
        {
            _FilterAnd = CS._1_7,
            ID = 26,
            ScreenerID = 2,
        },
        {
            _FilterAnd = CS._1_8,
            ID = 27,
            ScreenerID = 2,
        },
        {
            _FilterAnd = CS._1_9,
            ID = 28,
            ScreenerID = 2,
        },
        {
            _FilterAnd = CS._1_10,
            ID = 29,
            ScreenerID = 2,
        },
        {
            _FilterAnd = CS._1_11,
            ID = 30,
            ScreenerID = 2,
        },
        {
            _FilterAnd = CS._1_12,
            ID = 31,
            ScreenerID = 2,
        },
        {
            _FilterAnd = CS._1_24,
            ID = 32,
            ScreenerID = 3,
        },
        {
            _FilterAnd = CS._1_25,
            ID = 33,
            ScreenerID = 3,
        },
        {
            _FilterAnd = CS._1_13,
            ID = 34,
            ScreenerID = 3,
        },
        {
            _FilterAnd = CS._1_26,
            ID = 35,
            ScreenerID = 3,
        },
        {
            _FilterAnd = CS._1_27,
            ID = 36,
            ScreenerID = 3,
        },
        {
            _FilterAnd = CS._1_28,
            ID = 37,
            ScreenerID = 3,
        },
        {
            _FilterAnd = CS._1_29,
            ID = 38,
            ScreenerID = 3,
        },
        {
            _FilterAnd = CS._1_30,
            ID = 39,
            ScreenerID = 3,
        },
        {
            _FilterAnd = CS._1_31,
            ID = 40,
            ScreenerID = 3,
        },
        {
            _FilterAnd = '["ItemLevel==100"]',
            ID = 41,
            ScreenerID = 3,
        },
        {
            _FilterAnd = '["ItemLevel==110"]',
            ID = 42,
            ScreenerID = 3,
        },
        {
            _FilterAnd = CS._1_32,
            ID = 43,
            ScreenerID = 4,
        },
        {
            _FilterAnd = CS._1_14,
            ID = 44,
            ScreenerID = 4,
        },
        {
            ID = 45,
            ScreenerID = 5,
        },
        {
            ID = 46,
            ScreenerID = 5,
        },
        {
            ID = 47,
            ScreenerID = 5,
        },
        {
            ID = 48,
            ScreenerID = 5,
        },
        {
            ID = 49,
            ScreenerID = 5,
        },
        {
            ID = 50,
            ScreenerID = 5,
        },
        {
            ID = 51,
            ScreenerID = 5,
        },
        {
            ID = 52,
            ScreenerID = 5,
        },
        {
            ID = 53,
            ScreenerID = 5,
        },
        {
            ID = 54,
            ScreenerID = 5,
        },
        {
            _FilterAnd = '["ItemColor == 1"]',
            ID = 55,
            ScreenerID = 6,
        },
        {
            _FilterAnd = '["ItemColor == 2"]',
            ID = 56,
            ScreenerID = 6,
        },
        {
            _FilterAnd = CS._1_13,
            ID = 57,
            ScreenerID = 7,
        },
        {
            _FilterAnd = CS._1_33,
            ID = 58,
            ScreenerID = 8,
        },
        {
            _FilterAnd = CS._1_34,
            ID = 59,
            ScreenerID = 8,
        },
        {
            _FilterAnd = CS._1_35,
            ID = 60,
            ScreenerID = 8,
        },
        {
            _FilterAnd = CS._1_36,
            ID = 61,
            ScreenerID = 8,
        },
        {
            _FilterAnd = CS._1_37,
            ID = 62,
            ScreenerID = 8,
        },
        {
            _FilterAnd = CS._1_38,
            ID = 63,
            ScreenerID = 8,
        },
        {
            _FilterAnd = CS._1_39,
            ID = 64,
            ScreenerID = 8,
        },
        {
            _FilterAnd = CS._1_40,
            ID = 65,
            ScreenerID = 8,
        },
        {
            _FilterAnd = CS._1_41,
            ID = 66,
            ScreenerID = 8,
        },
        {
            _FilterAnd = CS._1_15,
            ID = 67,
            ScreenerID = 9,
        },
        {
            _FilterAnd = CS._1_42,
            ID = 68,
            ScreenerID = 9,
        },
        {
            _FilterAnd = CS._1_43,
            ID = 69,
            ScreenerID = 9,
        },
        {
            _FilterAnd = CS._1_16,
            ID = 70,
            ScreenerID = 9,
        },
        {
            _FilterAnd = CS._1_17,
            ID = 71,
            ScreenerID = 10,
        },
        {
            _FilterAnd = CS._1_18,
            ID = 72,
            ScreenerID = 10,
        },
        {
            _FilterAnd = CS._1_19,
            ID = 73,
            ScreenerID = 10,
        },
        {
            ID = 74,
            ScreenerID = 11,
        },
        {
            ID = 75,
            ScreenerID = 11,
        },
        {
            ID = 76,
            ScreenerID = 11,
        },
        {
            ID = 77,
            ScreenerID = 11,
        },
        {
            ID = 78,
            ScreenerID = 11,
        },
        {
            ID = 79,
            ScreenerID = 11,
        },
        {
            ID = 80,
            ScreenerID = 11,
        },
        {
            ID = 81,
            ScreenerID = 11,
        },
        {
            ID = 82,
            ScreenerID = 11,
        },
        {
            ID = 83,
            ScreenerID = 11,
        },
        {
            _FilterAnd = CS._1_17,
            ID = 84,
            ScreenerID = 12,
        },
        {
            _FilterAnd = CS._1_18,
            ID = 85,
            ScreenerID = 12,
        },
        {
            _FilterAnd = CS._1_19,
            ID = 86,
            ScreenerID = 12,
        },
        {
            _FilterAnd = CS._1_44,
            ID = 87,
            ScreenerID = 12,
        },
        {
            _FilterAnd = CS._1_45,
            ID = 88,
            ScreenerID = 13,
        },
        {
            _FilterAnd = CS._1_46,
            ID = 89,
            ScreenerID = 13,
        },
        {
            _FilterAnd = CS._1_47,
            ID = 90,
            ScreenerID = 13,
        },
        {
            _FilterAnd = '["FilterType==104"]',
            ID = 91,
            ScreenerID = 13,
        },
        {
            _FilterAnd = CS._1_17,
            ID = 92,
            ScreenerID = 14,
        },
        {
            _FilterAnd = CS._1_18,
            ID = 93,
            ScreenerID = 14,
        },
        {
            _FilterAnd = CS._1_19,
            ID = 94,
            ScreenerID = 14,
        },
        {
            _FilterAnd = CS._1_44,
            ID = 95,
            ScreenerID = 14,
        },
        {
            ID = 96,
            ScreenerID = 15,
        },
        {
            _FilterAnd = CS._1_24,
            ID = 97,
            ScreenerID = 15,
        },
        {
            _FilterAnd = CS._1_25,
            ID = 98,
            ScreenerID = 15,
        },
        {
            _FilterAnd = CS._1_13,
            ID = 99,
            ScreenerID = 15,
        },
        {
            _FilterAnd = CS._1_26,
            ID = 100,
            ScreenerID = 15,
        },
        {
            _FilterAnd = CS._1_27,
            ID = 101,
            ScreenerID = 15,
        },
        {
            _FilterAnd = CS._1_28,
            ID = 102,
            ScreenerID = 15,
        },
        {
            _FilterAnd = CS._1_29,
            ID = 103,
            ScreenerID = 15,
        },
        {
            _FilterAnd = CS._1_30,
            ID = 104,
            ScreenerID = 15,
        },
        {
            _FilterAnd = CS._1_31,
            ID = 105,
            ScreenerID = 15,
        },
        {
            _FilterAnd = CS._1_32,
            ID = 106,
            ScreenerID = 19,
        },
        {
            _FilterAnd = CS._1_14,
            ID = 107,
            ScreenerID = 19,
        },
        {
            _FilterAnd = CS._1_14,
            ID = 108,
            ScreenerID = 20,
        },
        {
            ID = 109,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 1","ClassLimit == 8","ProfLimit == {10,1}"]',
            ID = 110,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 1","ClassLimit == 8","ProfLimit == {12,2}"]',
            ID = 111,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 2","ClassLimit == 8","ProfLimit == {16,4}"]',
            ID = 112,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 2","ClassLimit == 8","ProfLimit == {17,3}"]',
            ID = 113,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 3","ClassLimit == 8","ProfLimit == {18,6}"]',
            ID = 114,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 4","ClassLimit == 8","ProfLimit == {21,7}"]',
            ID = 115,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 4","ClassLimit == 8","ProfLimit == {22,8}"]',
            ID = 116,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 5","ClassLimit == 8","ProfLimit == {25,9}"]',
            ID = 117,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 5","ClassLimit == 8","ProfLimit == {26}"]',
            ID = 118,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 6","ClassLimit == 9","ProfLimit == {34}"]',
            ID = 119,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 6","ClassLimit == 9","ProfLimit == {35}"]',
            ID = 120,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 6","ClassLimit == 9","ProfLimit == {30}"]',
            ID = 121,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 6","ClassLimit == 9","ProfLimit == {28}"]',
            ID = 122,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 6","ClassLimit == 9","ProfLimit == {29}"]',
            ID = 123,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 6","ClassLimit == 9","ProfLimit == {31}"]',
            ID = 124,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 6","ClassLimit == 9","ProfLimit == {33}"]',
            ID = 125,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 6","ClassLimit == 9","ProfLimit == {32}"]',
            ID = 126,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 7","ClassLimit == 9","ProfLimit == {36}"]',
            ID = 127,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 7","ClassLimit == 9","ProfLimit == {37}"]',
            ID = 128,
            ScreenerID = 23,
        },
        {
            _FilterOR = '["ClassLimit == 7","ClassLimit == 9","ProfLimit == {38}"]',
            ID = 129,
            ScreenerID = 23,
        },
        {
            ID = 130,
            ScreenerID = 24,
        },
        {
            _FilterAnd = '["Grade==1"]',
            ID = 131,
            ScreenerID = 24,
        },
        {
            _FilterAnd = '["Grade==5"]',
            ID = 132,
            ScreenerID = 24,
        },
        {
            _FilterAnd = '["Grade==10"]',
            ID = 133,
            ScreenerID = 24,
        },
        {
            _FilterAnd = '["Grade==15"]',
            ID = 134,
            ScreenerID = 24,
        },
        {
            _FilterAnd = '["Grade==20"]',
            ID = 135,
            ScreenerID = 24,
        },
        {
            _FilterAnd = '["Grade==25"]',
            ID = 136,
            ScreenerID = 24,
        },
        {
            _FilterAnd = '["Grade==30"]',
            ID = 137,
            ScreenerID = 24,
        },
        {
            _FilterAnd = '["Grade==35"]',
            ID = 138,
            ScreenerID = 24,
        },
        {
            _FilterAnd = '["Grade==40"]',
            ID = 139,
            ScreenerID = 24,
        },
        {
            _FilterAnd = '["Grade==45"]',
            ID = 140,
            ScreenerID = 24,
        },
        {
            _FilterAnd = '["Grade==50"]',
            ID = 141,
            ScreenerID = 24,
        },
        {
            ID = 142,
            ScreenerID = 25,
        },
        {
            _FilterAnd = CS._1_40,
            ID = 143,
            ScreenerID = 25,
        },
        {
            _FilterAnd = CS._1_33,
            ID = 144,
            ScreenerID = 25,
        },
        {
            _FilterAnd = CS._1_34,
            ID = 145,
            ScreenerID = 25,
        },
        {
            _FilterAnd = CS._1_35,
            ID = 146,
            ScreenerID = 25,
        },
        {
            _FilterAnd = CS._1_36,
            ID = 147,
            ScreenerID = 25,
        },
        {
            _FilterAnd = CS._1_37,
            ID = 148,
            ScreenerID = 25,
        },
        {
            _FilterAnd = CS._1_38,
            ID = 149,
            ScreenerID = 25,
        },
        {
            _FilterAnd = CS._1_39,
            ID = 150,
            ScreenerID = 25,
        },
        {
            _FilterAnd = CS._1_41,
            ID = 151,
            ScreenerID = 25,
        },
        {
            _FilterAnd = '["ItemType == 411"]',
            ID = 152,
            ScreenerID = 25,
        },
        {
            ID = 153,
        },
        {
            ID = 154,
        },
        {
            ID = 155,
        },
        {
            ID = 156,
        },
        {
            ID = 157,
        },
        {
            ID = 158,
        },
        {
            ID = 159,
        },
        {
            ID = 160,
        },
        {
            ID = 161,
        },
        {
            ID = 162,
        },
        {
            ID = 163,
        },
        {
            ID = 164,
        },
        {
            ID = 165,
        },
        {
            ID = 166,
        },
        {
            ID = 167,
        },
        {
            ID = 168,
        },
        {
            ID = 169,
        },
        {
            ID = 170,
        },
        {
            ID = 171,
        },
        {
            ID = 172,
        },
        {
            ID = 173,
        },
        {
            ID = 174,
        },
        {
            ID = 175,
        },
        {
            ID = 176,
        },
        {
            ID = 177,
        },
        {
            ID = 178,
        },
        {
            ID = 179,
        },
        {
            ID = 180,
        },
        {
            ID = 181,
            ScreenerID = 27,
        },
        {
            ID = 182,
            ScreenerID = 28,
        },
        {
            _FilterAnd = '["Race == 1"]',
            ID = 183,
            ScreenerID = 28,
        },
        {
            _FilterAnd = '["Race == 2"]',
            ID = 184,
            ScreenerID = 28,
        },
        {
            _FilterAnd = '["Race == 3"]',
            ID = 185,
            ScreenerID = 28,
        },
        {
            _FilterAnd = '["Race == 4"]',
            ID = 186,
            ScreenerID = 28,
        },
        {
            _FilterAnd = '["Race == 5"]',
            ID = 187,
            ScreenerID = 28,
        },
        {
            ID = 188,
            ScreenerID = 29,
        },
        {
            _FilterAnd = '["Gender == 1"]',
            ID = 189,
            ScreenerID = 29,
        },
        {
            _FilterAnd = '["Gender == 2"]',
            ID = 190,
            ScreenerID = 29,
        },
        {
            _FilterAnd = '["Grade >= 1","Grade<= 10"]',
            ID = 191,
            ScreenerID = 30,
        },
        {
            _FilterAnd = '["Grade >= 11","Grade<= 20"]',
            ID = 192,
            ScreenerID = 30,
        },
        {
            _FilterAnd = '["Grade >= 21","Grade<= 30"]',
            ID = 193,
            ScreenerID = 30,
        },
        {
            _FilterAnd = '["Grade >= 31","Grade<= 40"]',
            ID = 194,
            ScreenerID = 30,
        },
        {
            _FilterAnd = '["Grade >= 41","Grade<= 50"]',
            ID = 195,
            ScreenerID = 30,
        },
        {
            _FilterAnd = CS._1_48,
            ID = 196,
            ScreenerID = 31,
        },
        {
            _FilterAnd = CS._1_49,
            ID = 197,
            ScreenerID = 31,
        },
        {
            _FilterAnd = CS._1_50,
            ID = 198,
            ScreenerID = 31,
        },
        {
            _FilterAnd = CS._1_51,
            ID = 199,
            ScreenerID = 31,
        },
        {
            _FilterAnd = CS._1_52,
            ID = 200,
            ScreenerID = 31,
        },
        {
            _FilterAnd = CS._1_53,
            ID = 201,
            ScreenerID = 31,
        },
        {
            _FilterAnd = CS._1_54,
            ID = 202,
            ScreenerID = 31,
        },
        {
            _FilterAnd = CS._1_55,
            ID = 203,
            ScreenerID = 31,
        },
        {
            _FilterOR = '["QuestGenreID == 20701","QuestGenreID == 20702","QuestGenreID == 30101","QuestGenreID == 30102"]',
            ID = 204,
            ScreenerID = 31,
        },
        {
            _FilterOR = '["QuestGenreID >= 20801 AND QuestGenreID <= 20805","QuestGenreID >= 30201 AND QuestGenreID <= 30205"]',
            ID = 205,
            ScreenerID = 31,
        },
        {
            _FilterAnd = CS._1_56,
            ID = 206,
            ScreenerID = 31,
        },
        {
            _FilterAnd = CS._1_57,
            ID = 207,
            ScreenerID = 31,
        },
        {
            _FilterAnd = CS._1_58,
            ID = 208,
            ScreenerID = 31,
        },
        {
            _FilterAnd = '["MapID >= 13001","MapID <= 13007"]',
            ID = 209,
            ScreenerID = 32,
        },
        {
            _FilterAnd = '["MapID >= 11001","MapID <= 11006"]',
            ID = 210,
            ScreenerID = 32,
        },
        {
            _FilterAnd = '["MapID >= 12001","MapID <= 12007"]',
            ID = 211,
            ScreenerID = 32,
        },
        {
            _FilterAnd = '["MapID >= 15001","MapID <= 15004"]',
            ID = 212,
            ScreenerID = 32,
        },
        {
            _FilterAnd = '["MapID == 14001"]',
            ID = 213,
            ScreenerID = 32,
        },
        {
            _FilterAnd = '["MapID >= 4001","MapID <= 4006"]',
            ID = 214,
            ScreenerID = 32,
        },
        {
            _FilterAnd = CS._1_1,
            ID = 215,
            ScreenerID = 32,
        },
        {
            _FilterAnd = CS._1_1,
            ID = 216,
            ScreenerID = 32,
        },
        {
            _FilterAnd = CS._1_1,
            ID = 217,
            ScreenerID = 32,
        },
        {
            _FilterAnd = CS._1_1,
            ID = 218,
            ScreenerID = 32,
        },
        {
            _FilterAnd = '["MinLevel >= 1","MinLevel <= 20"]',
            ID = 219,
            ScreenerID = 33,
        },
        {
            _FilterAnd = '["MinLevel >= 21","MinLevel <= 40"]',
            ID = 220,
            ScreenerID = 33,
        },
        {
            _FilterAnd = '["MinLevel >= 41","MinLevel <= 50"]',
            ID = 221,
            ScreenerID = 33,
        },
        {
            _FilterAnd = '["MinLevel >= 51"]',
            ID = 222,
            ScreenerID = 33,
        },
        {
            _FilterAnd = CS._1_48,
            ID = 223,
            ScreenerID = 34,
        },
        {
            _FilterAnd = CS._1_49,
            ID = 224,
            ScreenerID = 34,
        },
        {
            _FilterAnd = CS._1_50,
            ID = 225,
            ScreenerID = 35,
        },
        {
            _FilterAnd = CS._1_51,
            ID = 226,
            ScreenerID = 35,
        },
        {
            _FilterAnd = CS._1_52,
            ID = 227,
            ScreenerID = 35,
        },
        {
            _FilterAnd = CS._1_53,
            ID = 228,
            ScreenerID = 35,
        },
        {
            _FilterAnd = CS._1_54,
            ID = 229,
            ScreenerID = 35,
        },
        {
            _FilterAnd = CS._1_55,
            ID = 230,
            ScreenerID = 35,
        },
        {
            _FilterAnd = '["QuestGenreID >= 20701","QuestGenreID <= 20702"]',
            ID = 231,
            ScreenerID = 35,
        },
        {
            _FilterAnd = '["QuestGenreID >= 20801","QuestGenreID <= 20805"]',
            ID = 232,
            ScreenerID = 35,
        },
        {
            _FilterAnd = CS._1_56,
            ID = 233,
            ScreenerID = 35,
        },
        {
            _FilterAnd = '["QuestGenreID >= 30101","QuestGenreID <= 30102"]',
            ID = 234,
            ScreenerID = 36,
        },
        {
            _FilterAnd = '["QuestGenreID >= 30201","QuestGenreID <= 30205"]',
            ID = 235,
            ScreenerID = 36,
        },
        {
            _FilterAnd = CS._1_57,
            ID = 236,
            ScreenerID = 36,
        },
        {
            _FilterAnd = CS._1_58,
            ID = 237,
            ScreenerID = 36,
        },
        {
            ID = 238,
            ScreenerID = 37,
        },
        {
            _FilterAnd = CS._1_2,
            ID = 239,
            ScreenerID = 37,
        },
        {
            _FilterAnd = CS._1_3,
            ID = 240,
            ScreenerID = 37,
        },
        {
            _FilterAnd = CS._1_4,
            ID = 241,
            ScreenerID = 37,
        },
        {
            _FilterAnd = CS._1_5,
            ID = 242,
            ScreenerID = 37,
        },
        {
            _FilterAnd = CS._1_6,
            ID = 243,
            ScreenerID = 37,
        },
        {
            _FilterAnd = CS._1_7,
            ID = 244,
            ScreenerID = 37,
        },
        {
            _FilterAnd = CS._1_8,
            ID = 245,
            ScreenerID = 37,
        },
        {
            _FilterAnd = CS._1_10,
            ID = 246,
            ScreenerID = 37,
        },
        {
            _FilterAnd = CS._1_9,
            ID = 247,
            ScreenerID = 37,
        },
        {
            _FilterAnd = CS._1_11,
            ID = 248,
            ScreenerID = 37,
        },
        {
            _FilterAnd = CS._1_12,
            ID = 249,
            ScreenerID = 37,
        },
        {
            _FilterAnd = CS._1_2,
            ID = 250,
            ScreenerID = 38,
        },
        {
            _FilterAnd = '["ItemLevel==10","Classify == 1"]',
            ID = 251,
            ScreenerID = 38,
        },
        {
            _FilterAnd = '["ItemLevel==20","Classify == 1"]',
            ID = 252,
            ScreenerID = 38,
        },
        {
            _FilterAnd = '["ItemLevel==30","Classify == 1"]',
            ID = 253,
            ScreenerID = 38,
        },
        {
            _FilterAnd = '["ItemLevel==40","Classify == 1"]',
            ID = 254,
            ScreenerID = 38,
        },
        {
            _FilterAnd = '["ItemLevel==50","Classify == 1"]',
            ID = 255,
            ScreenerID = 38,
        },
        {
            _FilterAnd = '["ItemLevel==60","Classify == 1"]',
            ID = 256,
            ScreenerID = 38,
        },
        {
            _FilterAnd = '["ItemLevel==70","Classify == 1"]',
            ID = 257,
            ScreenerID = 38,
        },
        {
            _FilterAnd = '["ItemLevel==80","Classify == 1"]',
            ID = 258,
            ScreenerID = 38,
        },
        {
            _FilterAnd = '["ItemLevel==90","Classify == 1"]',
            ID = 259,
            ScreenerID = 38,
        },
        {
            _FilterAnd = '["ItemLevel==100","Classify == 1"]',
            ID = 260,
            ScreenerID = 38,
        },
        {
            _FilterAnd = '["ItemLevel==110","Classify == 1"]',
            ID = 261,
            ScreenerID = 38,
        },
        {
            _FilterAnd = '["ItemLevel==125","Classify == 1"]',
            ID = 262,
            ScreenerID = 38,
        },
        {
            _FilterAnd = '["ItemLevel==135","Classify == 1"]',
            ID = 263,
            ScreenerID = 38,
        },
        {
            _FilterAnd = CS._1_3,
            ID = 264,
            ScreenerID = 39,
        },
        {
            _FilterAnd = '["ItemLevel==10","Classify == 2"]',
            ID = 265,
            ScreenerID = 39,
        },
        {
            _FilterAnd = '["ItemLevel==20","Classify == 2"]',
            ID = 266,
            ScreenerID = 39,
        },
        {
            _FilterAnd = '["ItemLevel==30","Classify == 2"]',
            ID = 267,
            ScreenerID = 39,
        },
        {
            _FilterAnd = '["ItemLevel==40","Classify == 2"]',
            ID = 268,
            ScreenerID = 39,
        },
        {
            _FilterAnd = '["ItemLevel==50","Classify == 2"]',
            ID = 269,
            ScreenerID = 39,
        },
        {
            _FilterAnd = '["ItemLevel==60","Classify == 2"]',
            ID = 270,
            ScreenerID = 39,
        },
        {
            _FilterAnd = '["ItemLevel==70","Classify == 2"]',
            ID = 271,
            ScreenerID = 39,
        },
        {
            _FilterAnd = '["ItemLevel==80","Classify == 2"]',
            ID = 272,
            ScreenerID = 39,
        },
        {
            _FilterAnd = '["ItemLevel==90","Classify == 2"]',
            ID = 273,
            ScreenerID = 39,
        },
        {
            _FilterAnd = '["ItemLevel==100","Classify == 2"]',
            ID = 274,
            ScreenerID = 39,
        },
        {
            _FilterAnd = '["ItemLevel==110","Classify == 2"]',
            ID = 275,
            ScreenerID = 39,
        },
        {
            _FilterAnd = '["ItemLevel==125","Classify == 2"]',
            ID = 276,
            ScreenerID = 39,
        },
        {
            _FilterAnd = '["ItemLevel==135","Classify == 2"]',
            ID = 277,
            ScreenerID = 39,
        },
        {
            _FilterAnd = CS._1_4,
            ID = 278,
            ScreenerID = 40,
        },
        {
            _FilterAnd = '["ItemLevel==10","Classify == 3"]',
            ID = 279,
            ScreenerID = 40,
        },
        {
            _FilterAnd = '["ItemLevel==20","Classify == 3"]',
            ID = 280,
            ScreenerID = 40,
        },
        {
            _FilterAnd = '["ItemLevel==30","Classify == 3"]',
            ID = 281,
            ScreenerID = 40,
        },
        {
            _FilterAnd = '["ItemLevel==40","Classify == 3"]',
            ID = 282,
            ScreenerID = 40,
        },
        {
            _FilterAnd = '["ItemLevel==50","Classify == 3"]',
            ID = 283,
            ScreenerID = 40,
        },
        {
            _FilterAnd = '["ItemLevel==60","Classify == 3"]',
            ID = 284,
            ScreenerID = 40,
        },
        {
            _FilterAnd = '["ItemLevel==70","Classify == 3"]',
            ID = 285,
            ScreenerID = 40,
        },
        {
            _FilterAnd = '["ItemLevel==80","Classify == 3"]',
            ID = 286,
            ScreenerID = 40,
        },
        {
            _FilterAnd = '["ItemLevel==90","Classify == 3"]',
            ID = 287,
            ScreenerID = 40,
        },
        {
            _FilterAnd = '["ItemLevel==100","Classify == 3"]',
            ID = 288,
            ScreenerID = 40,
        },
        {
            _FilterAnd = '["ItemLevel==110","Classify == 3"]',
            ID = 289,
            ScreenerID = 40,
        },
        {
            _FilterAnd = '["ItemLevel==125","Classify == 3"]',
            ID = 290,
            ScreenerID = 40,
        },
        {
            _FilterAnd = '["ItemLevel==135","Classify == 3"]',
            ID = 291,
            ScreenerID = 40,
        },
        {
            _FilterAnd = CS._1_5,
            ID = 292,
            ScreenerID = 41,
        },
        {
            _FilterAnd = '["ItemLevel==10","Classify == 4"]',
            ID = 293,
            ScreenerID = 41,
        },
        {
            _FilterAnd = '["ItemLevel==20","Classify == 4"]',
            ID = 294,
            ScreenerID = 41,
        },
        {
            _FilterAnd = '["ItemLevel==30","Classify == 4"]',
            ID = 295,
            ScreenerID = 41,
        },
        {
            _FilterAnd = '["ItemLevel==40","Classify == 4"]',
            ID = 296,
            ScreenerID = 41,
        },
        {
            _FilterAnd = '["ItemLevel==50","Classify == 4"]',
            ID = 297,
            ScreenerID = 41,
        },
        {
            _FilterAnd = '["ItemLevel==60","Classify == 4"]',
            ID = 298,
            ScreenerID = 41,
        },
        {
            _FilterAnd = '["ItemLevel==70","Classify == 4"]',
            ID = 299,
            ScreenerID = 41,
        },
        {
            _FilterAnd = '["ItemLevel==80","Classify == 4"]',
            ID = 300,
            ScreenerID = 41,
        },
        {
            _FilterAnd = '["ItemLevel==90","Classify == 4"]',
            ID = 301,
            ScreenerID = 41,
        },
        {
            _FilterAnd = '["ItemLevel==100","Classify == 4"]',
            ID = 302,
            ScreenerID = 41,
        },
        {
            _FilterAnd = '["ItemLevel==110","Classify == 4"]',
            ID = 303,
            ScreenerID = 41,
        },
        {
            _FilterAnd = '["ItemLevel==125","Classify == 4"]',
            ID = 304,
            ScreenerID = 41,
        },
        {
            _FilterAnd = '["ItemLevel==135","Classify == 4"]',
            ID = 305,
            ScreenerID = 41,
        },
        {
            _FilterAnd = CS._1_6,
            ID = 306,
            ScreenerID = 42,
        },
        {
            _FilterAnd = '["ItemLevel==10","Classify == 5"]',
            ID = 307,
            ScreenerID = 42,
        },
        {
            _FilterAnd = '["ItemLevel==20","Classify == 5"]',
            ID = 308,
            ScreenerID = 42,
        },
        {
            _FilterAnd = '["ItemLevel==30","Classify == 5"]',
            ID = 309,
            ScreenerID = 42,
        },
        {
            _FilterAnd = '["ItemLevel==40","Classify == 5"]',
            ID = 310,
            ScreenerID = 42,
        },
        {
            _FilterAnd = '["ItemLevel==50","Classify == 5"]',
            ID = 311,
            ScreenerID = 42,
        },
        {
            _FilterAnd = '["ItemLevel==60","Classify == 5"]',
            ID = 312,
            ScreenerID = 42,
        },
        {
            _FilterAnd = '["ItemLevel==70","Classify == 5"]',
            ID = 313,
            ScreenerID = 42,
        },
        {
            _FilterAnd = '["ItemLevel==80","Classify == 5"]',
            ID = 314,
            ScreenerID = 42,
        },
        {
            _FilterAnd = '["ItemLevel==90","Classify == 5"]',
            ID = 315,
            ScreenerID = 42,
        },
        {
            _FilterAnd = '["ItemLevel==100","Classify == 5"]',
            ID = 316,
            ScreenerID = 42,
        },
        {
            _FilterAnd = '["ItemLevel==110","Classify == 5"]',
            ID = 317,
            ScreenerID = 42,
        },
        {
            _FilterAnd = '["ItemLevel==125","Classify == 5"]',
            ID = 318,
            ScreenerID = 42,
        },
        {
            _FilterAnd = '["ItemLevel==135","Classify == 5"]',
            ID = 319,
            ScreenerID = 42,
        },
        {
            _FilterAnd = CS._1_7,
            ID = 320,
            ScreenerID = 43,
        },
        {
            _FilterAnd = '["ItemLevel==10","Classify == 6"]',
            ID = 321,
            ScreenerID = 43,
        },
        {
            _FilterAnd = '["ItemLevel==20","Classify == 6"]',
            ID = 322,
            ScreenerID = 43,
        },
        {
            _FilterAnd = '["ItemLevel==30","Classify == 6"]',
            ID = 323,
            ScreenerID = 43,
        },
        {
            _FilterAnd = '["ItemLevel==40","Classify == 6"]',
            ID = 324,
            ScreenerID = 43,
        },
        {
            _FilterAnd = '["ItemLevel==50","Classify == 6"]',
            ID = 325,
            ScreenerID = 43,
        },
        {
            _FilterAnd = '["ItemLevel==60","Classify == 6"]',
            ID = 326,
            ScreenerID = 43,
        },
        {
            _FilterAnd = '["ItemLevel==70","Classify == 6"]',
            ID = 327,
            ScreenerID = 43,
        },
        {
            _FilterAnd = '["ItemLevel==80","Classify == 6"]',
            ID = 328,
            ScreenerID = 43,
        },
        {
            _FilterAnd = '["ItemLevel==90","Classify == 6"]',
            ID = 329,
            ScreenerID = 43,
        },
        {
            _FilterAnd = '["ItemLevel==100","Classify == 6"]',
            ID = 330,
            ScreenerID = 43,
        },
        {
            _FilterAnd = '["ItemLevel==110","Classify == 6"]',
            ID = 331,
            ScreenerID = 43,
        },
        {
            _FilterAnd = '["ItemLevel==125","Classify == 6"]',
            ID = 332,
            ScreenerID = 43,
        },
        {
            _FilterAnd = '["ItemLevel==135","Classify == 6"]',
            ID = 333,
            ScreenerID = 43,
        },
        {
            _FilterAnd = CS._1_8,
            ID = 334,
            ScreenerID = 44,
        },
        {
            _FilterAnd = '["ItemLevel==10","Classify == 7"]',
            ID = 335,
            ScreenerID = 44,
        },
        {
            _FilterAnd = '["ItemLevel==20","Classify == 7"]',
            ID = 336,
            ScreenerID = 44,
        },
        {
            _FilterAnd = '["ItemLevel==30","Classify == 7"]',
            ID = 337,
            ScreenerID = 44,
        },
        {
            _FilterAnd = '["ItemLevel==40","Classify == 7"]',
            ID = 338,
            ScreenerID = 44,
        },
        {
            _FilterAnd = '["ItemLevel==50","Classify == 7"]',
            ID = 339,
            ScreenerID = 44,
        },
        {
            _FilterAnd = '["ItemLevel==60","Classify == 7"]',
            ID = 340,
            ScreenerID = 44,
        },
        {
            _FilterAnd = '["ItemLevel==70","Classify == 7"]',
            ID = 341,
            ScreenerID = 44,
        },
        {
            _FilterAnd = '["ItemLevel==80","Classify == 7"]',
            ID = 342,
            ScreenerID = 44,
        },
        {
            _FilterAnd = '["ItemLevel==90","Classify == 7"]',
            ID = 343,
            ScreenerID = 44,
        },
        {
            _FilterAnd = '["ItemLevel==100","Classify == 7"]',
            ID = 344,
            ScreenerID = 44,
        },
        {
            _FilterAnd = '["ItemLevel==110","Classify == 7"]',
            ID = 345,
            ScreenerID = 44,
        },
        {
            _FilterAnd = '["ItemLevel==125","Classify == 7"]',
            ID = 346,
            ScreenerID = 44,
        },
        {
            _FilterAnd = '["ItemLevel==135","Classify == 7"]',
            ID = 347,
            ScreenerID = 44,
        },
        {
            _FilterAnd = CS._1_10,
            ID = 348,
            ScreenerID = 45,
        },
        {
            _FilterAnd = '["ItemLevel==10","Classify == 8"]',
            ID = 349,
            ScreenerID = 45,
        },
        {
            _FilterAnd = '["ItemLevel==20","Classify == 8"]',
            ID = 350,
            ScreenerID = 45,
        },
        {
            _FilterAnd = '["ItemLevel==30","Classify == 8"]',
            ID = 351,
            ScreenerID = 45,
        },
        {
            _FilterAnd = '["ItemLevel==40","Classify == 8"]',
            ID = 352,
            ScreenerID = 45,
        },
        {
            _FilterAnd = '["ItemLevel==50","Classify == 8"]',
            ID = 353,
            ScreenerID = 45,
        },
        {
            _FilterAnd = '["ItemLevel==60","Classify == 8"]',
            ID = 354,
            ScreenerID = 45,
        },
        {
            _FilterAnd = '["ItemLevel==70","Classify == 8"]',
            ID = 355,
            ScreenerID = 45,
        },
        {
            _FilterAnd = '["ItemLevel==80","Classify == 8"]',
            ID = 356,
            ScreenerID = 45,
        },
        {
            _FilterAnd = '["ItemLevel==90","Classify == 8"]',
            ID = 357,
            ScreenerID = 45,
        },
        {
            _FilterAnd = '["ItemLevel==100","Classify == 8"]',
            ID = 358,
            ScreenerID = 45,
        },
        {
            _FilterAnd = '["ItemLevel==110","Classify == 8"]',
            ID = 359,
            ScreenerID = 45,
        },
        {
            _FilterAnd = '["ItemLevel==125","Classify == 8"]',
            ID = 360,
            ScreenerID = 45,
        },
        {
            _FilterAnd = '["ItemLevel==135","Classify == 8"]',
            ID = 361,
            ScreenerID = 45,
        },
        {
            _FilterAnd = CS._1_9,
            ID = 362,
            ScreenerID = 46,
        },
        {
            _FilterAnd = '["ItemLevel==10","Classify == 9"]',
            ID = 363,
            ScreenerID = 46,
        },
        {
            _FilterAnd = '["ItemLevel==20","Classify == 9"]',
            ID = 364,
            ScreenerID = 46,
        },
        {
            _FilterAnd = '["ItemLevel==30","Classify == 9"]',
            ID = 365,
            ScreenerID = 46,
        },
        {
            _FilterAnd = '["ItemLevel==40","Classify == 9"]',
            ID = 366,
            ScreenerID = 46,
        },
        {
            _FilterAnd = '["ItemLevel==50","Classify == 9"]',
            ID = 367,
            ScreenerID = 46,
        },
        {
            _FilterAnd = '["ItemLevel==60","Classify == 9"]',
            ID = 368,
            ScreenerID = 46,
        },
        {
            _FilterAnd = '["ItemLevel==70","Classify == 9"]',
            ID = 369,
            ScreenerID = 46,
        },
        {
            _FilterAnd = '["ItemLevel==80","Classify == 9"]',
            ID = 370,
            ScreenerID = 46,
        },
        {
            _FilterAnd = '["ItemLevel==90","Classify == 9"]',
            ID = 371,
            ScreenerID = 46,
        },
        {
            _FilterAnd = '["ItemLevel==100","Classify == 9"]',
            ID = 372,
            ScreenerID = 46,
        },
        {
            _FilterAnd = '["ItemLevel==110","Classify == 9"]',
            ID = 373,
            ScreenerID = 46,
        },
        {
            _FilterAnd = '["ItemLevel==125","Classify == 9"]',
            ID = 374,
            ScreenerID = 46,
        },
        {
            _FilterAnd = '["ItemLevel==135","Classify == 9"]',
            ID = 375,
            ScreenerID = 46,
        },
        {
            _FilterAnd = CS._1_11,
            ID = 376,
            ScreenerID = 47,
        },
        {
            _FilterAnd = '["ItemLevel==10","Classify == 10"]',
            ID = 377,
            ScreenerID = 47,
        },
        {
            _FilterAnd = '["ItemLevel==20","Classify == 10"]',
            ID = 378,
            ScreenerID = 47,
        },
        {
            _FilterAnd = '["ItemLevel==30","Classify == 10"]',
            ID = 379,
            ScreenerID = 47,
        },
        {
            _FilterAnd = '["ItemLevel==40","Classify == 10"]',
            ID = 380,
            ScreenerID = 47,
        },
        {
            _FilterAnd = '["ItemLevel==50","Classify == 10"]',
            ID = 381,
            ScreenerID = 47,
        },
        {
            _FilterAnd = '["ItemLevel==60","Classify == 10"]',
            ID = 382,
            ScreenerID = 47,
        },
        {
            _FilterAnd = '["ItemLevel==70","Classify == 10"]',
            ID = 383,
            ScreenerID = 47,
        },
        {
            _FilterAnd = '["ItemLevel==80","Classify == 10"]',
            ID = 384,
            ScreenerID = 47,
        },
        {
            _FilterAnd = '["ItemLevel==90","Classify == 10"]',
            ID = 385,
            ScreenerID = 47,
        },
        {
            _FilterAnd = '["ItemLevel==100","Classify == 10"]',
            ID = 386,
            ScreenerID = 47,
        },
        {
            _FilterAnd = '["ItemLevel==110","Classify == 10"]',
            ID = 387,
            ScreenerID = 47,
        },
        {
            _FilterAnd = '["ItemLevel==125","Classify == 10"]',
            ID = 388,
            ScreenerID = 47,
        },
        {
            _FilterAnd = '["ItemLevel==135","Classify == 10"]',
            ID = 389,
            ScreenerID = 47,
        },
        {
            _FilterAnd = CS._1_12,
            ID = 390,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["ItemLevel==10","Classify == 11"]',
            ID = 391,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["ItemLevel==20","Classify == 11"]',
            ID = 392,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["ItemLevel==30","Classify == 11"]',
            ID = 393,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["ItemLevel==40","Classify == 11"]',
            ID = 394,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["ItemLevel==50","Classify == 11"]',
            ID = 395,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["ItemLevel==60","Classify == 11"]',
            ID = 396,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["ItemLevel==70","Classify == 11"]',
            ID = 397,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["ItemLevel==80","Classify == 11"]',
            ID = 398,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["ItemLevel==90","Classify == 11"]',
            ID = 399,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["ItemLevel==100","Classify == 11"]',
            ID = 400,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["ItemLevel==110","Classify == 11"]',
            ID = 401,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["ItemLevel==125","Classify == 11"]',
            ID = 402,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["ItemLevel==135","Classify == 11"]',
            ID = 403,
            ScreenerID = 48,
        },
        {
            _FilterAnd = '["Star = 1"]',
            ID = 404,
            ScreenerID = 17,
            ScreenerIcon = 'PaperSprite\'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Star1_png.UI_Cards_Icon_Star1_png\'',
        },
        {
            _FilterAnd = '["Star = 2"]',
            ID = 405,
            ScreenerID = 17,
            ScreenerIcon = 'PaperSprite\'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Star2_png.UI_Cards_Icon_Star2_png\'',
        },
        {
            _FilterAnd = '["Star = 3"]',
            ID = 406,
            ScreenerID = 17,
            ScreenerIcon = 'PaperSprite\'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Star3_png.UI_Cards_Icon_Star3_png\'',
        },
        {
            _FilterAnd = '["Star = 4"]',
            ID = 407,
            ScreenerID = 17,
            ScreenerIcon = 'PaperSprite\'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Star4_png.UI_Cards_Icon_Star4_png\'',
        },
        {
            _FilterAnd = '["Star = 5"]',
            ID = 408,
            ScreenerID = 17,
            ScreenerIcon = 'PaperSprite\'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Star5_png.UI_Cards_Icon_Star5_png\'',
        },
        {
            _FilterAnd = '["Race = 0"]',
            ID = 409,
            ScreenerID = 18,
            ScreenerIcon = 'PaperSprite\'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_NoneType_png.UI_Cards_Icon_NoneType_png\'',
        },
        {
            _FilterAnd = '["Race = 3"]',
            ID = 410,
            ScreenerID = 18,
            ScreenerIcon = 'PaperSprite\'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Scion_png.UI_Cards_Icon_Scion_png\'',
        },
        {
            _FilterAnd = '["Race = 4"]',
            ID = 411,
            ScreenerID = 18,
            ScreenerIcon = 'PaperSprite\'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Primal_png.UI_Cards_Icon_Primal_png\'',
        },
        {
            _FilterAnd = '["Race = 2"]',
            ID = 412,
            ScreenerID = 18,
            ScreenerIcon = 'PaperSprite\'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Imperial_png.UI_Cards_Icon_Imperial_png\'',
        },
        {
            _FilterAnd = '["Race = 1"]',
            ID = 413,
            ScreenerID = 18,
            ScreenerIcon = 'PaperSprite\'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Beastman_png.UI_Cards_Icon_Beastman_png\'',
        },
        {
            _FilterAnd = CS._1_45,
            ID = 414,
            ScreenerID = 49,
        },
        {
            _FilterAnd = CS._1_46,
            ID = 415,
            ScreenerID = 49,
        },
        {
            _FilterAnd = CS._1_47,
            ID = 416,
            ScreenerID = 49,
        },
        {
            _FilterAnd = CS._1_20,
            ID = 417,
            ScreenerID = 50,
        },
        {
            _FilterAnd = CS._1_21,
            ID = 418,
            ScreenerID = 50,
        },
        {
            _FilterAnd = CS._1_22,
            ID = 419,
            ScreenerID = 50,
        },
        {
            _FilterAnd = CS._1_23,
            ID = 420,
            ScreenerID = 50,
        },
        {
            _FilterAnd = CS._1_59,
            ID = 421,
            ScreenerID = 50,
        },
        {
            _FilterAnd = CS._1_60,
            ID = 422,
            ScreenerID = 50,
        },
        {
            _FilterAnd = CS._1_61,
            ID = 423,
            ScreenerID = 51,
        },
        {
            _FilterAnd = CS._1_20,
            ID = 424,
            ScreenerID = 51,
        },
        {
            _FilterAnd = CS._1_21,
            ID = 425,
            ScreenerID = 51,
        },
        {
            _FilterAnd = CS._1_22,
            ID = 426,
            ScreenerID = 51,
        },
        {
            _FilterAnd = CS._1_23,
            ID = 427,
            ScreenerID = 51,
        },
        {
            _FilterAnd = CS._1_59,
            ID = 428,
            ScreenerID = 51,
        },
        {
            _FilterAnd = CS._1_60,
            ID = 429,
            ScreenerID = 51,
        },
        {
            _FilterAnd = '["FilterType==9"]',
            ID = 430,
            ScreenerID = 51,
        },
        {
            _FilterAnd = '["FilterType==8"]',
            ID = 431,
            ScreenerID = 51,
        },
        {
            _FilterAnd = '["FilterType==10"]',
            ID = 432,
            ScreenerID = 51,
        },
        {
            _FilterAnd = '["FilterType==11"]',
            ID = 433,
            ScreenerID = 51,
        },
        {
            _FilterAnd = '["ItemLevel>=1","ItemLevel<=10"]',
            ID = 434,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=11","ItemLevel<=20"]',
            ID = 435,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=21","ItemLevel<=30"]',
            ID = 436,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=31","ItemLevel<=40"]',
            ID = 437,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=41","ItemLevel<=50"]',
            ID = 438,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=51","ItemLevel<=60"]',
            ID = 439,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=61","ItemLevel<=70"]',
            ID = 440,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=71","ItemLevel<=80"]',
            ID = 441,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=81","ItemLevel<=90"]',
            ID = 442,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=91","ItemLevel<=100"]',
            ID = 443,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=101","ItemLevel<=110"]',
            ID = 444,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=111","ItemLevel<=120"]',
            ID = 445,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=121","ItemLevel<=130"]',
            ID = 446,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=131","ItemLevel<=140"]',
            ID = 447,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=141","ItemLevel<=150"]',
            ID = 448,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=151","ItemLevel<=160"]',
            ID = 449,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=161","ItemLevel<=170"]',
            ID = 450,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["ItemLevel>=171","ItemLevel<=180"]',
            ID = 451,
            ScreenerID = 52,
        },
        {
            _FilterAnd = '["Lock == 0"]',
            ID = 452,
            ScreenerID = 27,
        },
        {
            _FilterAnd = '["Lock == 1"]',
            ID = 453,
            ScreenerID = 27,
        },
        {
            ID = 454,
            ScreenerID = 53,
        },
        {
            _FilterAnd = '["Stain == 1"]',
            ID = 455,
            ScreenerID = 53,
        },
        {
            _FilterAnd = '["Stain == 0"]',
            ID = 456,
            ScreenerID = 53,
        },
        {
            _FilterAnd = CS._1_61,
            ID = 457,
            ScreenerID = 54,
        },
        {
            _FilterAnd = CS._1_20,
            ID = 458,
            ScreenerID = 54,
        },
        {
            _FilterAnd = CS._1_21,
            ID = 459,
            ScreenerID = 54,
        },
        {
            _FilterAnd = CS._1_22,
            ID = 460,
            ScreenerID = 54,
        },
        {
            _FilterAnd = CS._1_23,
            ID = 461,
            ScreenerID = 54,
        },
        {
            _FilterAnd = '["ItemLevel>=1","ItemLevel<=10","ItemType == 100"]',
            ID = 462,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=11","ItemLevel<=20","ItemType == 100"]',
            ID = 463,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=21","ItemLevel<=30","ItemType == 100"]',
            ID = 464,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=31","ItemLevel<=40","ItemType == 100"]',
            ID = 465,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=41","ItemLevel<=50","ItemType == 100"]',
            ID = 466,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=51","ItemLevel<=60","ItemType == 100"]',
            ID = 467,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=61","ItemLevel<=70","ItemType == 100"]',
            ID = 468,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=71","ItemLevel<=80","ItemType == 100"]',
            ID = 469,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=81","ItemLevel<=90","ItemType == 100"]',
            ID = 470,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=91","ItemLevel<=100","ItemType == 100"]',
            ID = 471,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=101","ItemLevel<=110","ItemType == 100"]',
            ID = 472,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=111","ItemLevel<=120","ItemType == 100"]',
            ID = 473,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=121","ItemLevel<=130","ItemType == 100"]',
            ID = 474,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=131","ItemLevel<=140","ItemType == 100"]',
            ID = 475,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=141","ItemLevel<=150","ItemType == 100"]',
            ID = 476,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=151","ItemLevel<=160","ItemType == 100"]',
            ID = 477,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=161","ItemLevel<=170","ItemType == 100"]',
            ID = 478,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["ItemLevel>=171","ItemLevel<=180","ItemType == 100"]',
            ID = 479,
            ScreenerID = 55,
        },
        {
            _FilterAnd = '["FilterType==2","ItemType == 102"]',
            ID = 480,
            ScreenerID = 56,
        },
        {
            _FilterAnd = '["FilterType==3","ItemType == 102"]',
            ID = 481,
            ScreenerID = 56,
        },
        {
            _FilterAnd = '["FilterType==4","ItemType == 102"]',
            ID = 482,
            ScreenerID = 56,
        },
        {
            _FilterAnd = '["FilterType==5","ItemType == 102"]',
            ID = 483,
            ScreenerID = 56,
        },
        {
            _FilterAnd = '["FilterType==6","ItemType == 102"]',
            ID = 484,
            ScreenerID = 56,
        },
        {
            _FilterAnd = '["FilterType==7","ItemType == 102"]',
            ID = 485,
            ScreenerID = 56,
        },
        {
            _FilterAnd = '["FilterType==2","ItemType == 105"]',
            ID = 486,
            ScreenerID = 57,
        },
        {
            _FilterAnd = '["FilterType==3","ItemType == 105"]',
            ID = 487,
            ScreenerID = 57,
        },
        {
            _FilterAnd = '["FilterType==4","ItemType == 105"]',
            ID = 488,
            ScreenerID = 57,
        },
        {
            _FilterAnd = '["FilterType==5","ItemType == 105"]',
            ID = 489,
            ScreenerID = 57,
        },
        {
            _FilterAnd = '["FilterType==6","ItemType == 105"]',
            ID = 490,
            ScreenerID = 57,
        },
        {
            _FilterAnd = '["FilterType==7","ItemType == 105"]',
            ID = 491,
            ScreenerID = 57,
        },
        {
            _FilterAnd = '["FilterType==3","ItemType == 109"]',
            ID = 492,
            ScreenerID = 58,
        },
        {
            _FilterAnd = '["FilterType==4","ItemType == 109"]',
            ID = 493,
            ScreenerID = 58,
        },
        {
            _FilterAnd = '["FilterType==5","ItemType == 109"]',
            ID = 494,
            ScreenerID = 58,
        },
        {
            _FilterAnd = '["FilterType==6","ItemType == 109"]',
            ID = 495,
            ScreenerID = 58,
        },
        {
            _FilterAnd = '["FilterType==7","ItemType == 109"]',
            ID = 496,
            ScreenerID = 58,
        },
        {
            _FilterAnd = '["FilterType==9","ItemType == 109"]',
            ID = 497,
            ScreenerID = 58,
        },
        {
            _FilterAnd = '["FilterType==8","ItemType == 109"]',
            ID = 498,
            ScreenerID = 58,
        },
        {
            _FilterAnd = '["FilterType==10","ItemType == 109"]',
            ID = 499,
            ScreenerID = 58,
        },
        {
            _FilterAnd = '["FilterType==11","ItemType == 109"]',
            ID = 500,
            ScreenerID = 58,
        },
        {
            _FilterAnd = '["FilterType==1","ItemType == 109"]',
            ID = 501,
            ScreenerID = 58,
        },
        {
            _FilterAnd = '["FilterType==2","ItemType == 109"]',
            ID = 502,
            ScreenerID = 58,
        },
        {
            _FilterAnd = '["ItemColor == 1","ItemType == 401"]',
            ID = 503,
            ScreenerID = 59,
        },
        {
            _FilterAnd = '["ItemColor == 2","ItemType == 401"]',
            ID = 504,
            ScreenerID = 59,
        },
        {
            _FilterAnd = CS._1_15,
            ID = 505,
            ScreenerID = 60,
        },
        {
            _FilterAnd = CS._1_43,
            ID = 506,
            ScreenerID = 60,
        },
        {
            _FilterAnd = CS._1_16,
            ID = 507,
            ScreenerID = 60,
        },
        {
            _FilterAnd = CS._1_15,
            ID = 508,
            ScreenerID = 61,
        },
        {
            _FilterAnd = CS._1_42,
            ID = 509,
            ScreenerID = 61,
        },
        {
            _FilterAnd = CS._1_16,
            ID = 510,
            ScreenerID = 61,
        },
	},
}

setmetatable(ScreenerInfoCfg, { __index = CfgBase })

ScreenerInfoCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ScreenerInfoCfg
