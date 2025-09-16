-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

local CS = {
    _1_1 = '10315,10316',
    _1_2 = '10314,10316',
    _1_3 = '10312',
    _2_1 = '[[84,86]]',
    _2_2 = '[[50,52],[64,66],[78,80]]',
    _2_3 = '[[1071,1072,1073],[1074,1075,1076]]',
}

---@class SpectrumCfg : CfgBase
local SpectrumCfg = {
	TableName = "c_spectrum_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        DeadKeep = 0,
        ID = 1,
        Job = 18,
        ResourceInc = 0,
        ResourceInit = 0,
        SpectrumMax = 10000,
        Type = 0,
        TypeParam1 = '',
        _TypeParam2 = '',
    },
	LuaData = {
        {
            ResourceInc = 250,
            Type = 1,
            TypeParam1 = '1000,1001,1002',
        },
        {
            ID = 2,
            Job = 10,
            Type = 2,
            TypeParam1 = '7013',
            _TypeParam2 = '[{"Resource":2500,"SkillID":10110}]',
        },
        {
            ID = 3,
            Job = 25,
            ResourceInc = 125,
            SpectrumMax = 5000,
            Type = 3,
            TypeParam1 = '5000,10000',
        },
        {
            ID = 4,
            Job = 25,
            ResourceInc = 200,
            Type = 4,
            TypeParam1 = '10000',
        },
        {
            ID = 5,
            Job = 21,
            SpectrumMax = 1,
            Type = 5,
        },
        {
            ID = 6,
            Job = 21,
            Type = 6,
            TypeParam1 = '1032',
        },
        {
            ID = 7,
            Job = 21,
            Type = 7,
            TypeParam1 = '1033',
        },
        {
            ID = 8,
            ResourceInc = 250,
            Type = 8,
            TypeParam1 = CS._1_1,
            _TypeParam2 = CS._2_1,
        },
        {
            ID = 9,
            ResourceInc = 250,
            Type = 9,
            TypeParam1 = CS._1_2,
            _TypeParam2 = CS._2_1,
        },
        {
            ID = 10,
            ResourceInc = 500,
            Type = 10,
            TypeParam1 = CS._1_3,
            _TypeParam2 = CS._2_2,
        },
        {
            ID = 11,
            Job = 0,
        },
        {
            ID = 12,
            Job = 16,
            SpectrumMax = 0,
            TypeParam1 = '1034',
        },
        {
            ID = 13,
            Job = 16,
            SpectrumMax = 0,
            TypeParam1 = '1035',
        },
        {
            ID = 14,
            Job = 16,
            SpectrumMax = 0,
            TypeParam1 = '1036',
        },
        {
            ID = 15,
            Job = 26,
            SpectrumMax = 0,
            TypeParam1 = '1059',
        },
        {
            ID = 16,
            Job = 26,
        },
        {
            ID = 17,
            Job = 17,
            TypeParam1 = '1101',
        },
        {
            ID = 18,
            Job = 17,
            TypeParam1 = '1100',
        },
        {
            ID = 19,
            ResourceInc = 250,
            Type = 8,
            TypeParam1 = CS._1_1,
            _TypeParam2 = CS._2_1,
        },
        {
            ID = 20,
            ResourceInc = 250,
            Type = 9,
            TypeParam1 = CS._1_2,
            _TypeParam2 = CS._2_1,
        },
        {
            ID = 21,
            ResourceInc = 500,
            Type = 10,
            TypeParam1 = CS._1_3,
            _TypeParam2 = CS._2_2,
        },
        {
            ID = 22,
            Job = 21,
            ResourceInc = 250,
            SpectrumMax = 19439,
            Type = 5,
        },
        {
            ID = 23,
            Job = 26,
            SpectrumMax = 0,
            TypeParam1 = '1061',
        },
        {
            ID = 24,
            Job = 15,
            SpectrumMax = 0,
        },
        {
            ID = 25,
            Job = 15,
            SpectrumMax = 0,
        },
        {
            ID = 26,
            Job = 15,
            SpectrumMax = 0,
        },
        {
            ID = 27,
            Job = 15,
        },
        {
            ID = 28,
            Job = 22,
            SpectrumMax = 0,
            TypeParam1 = '1070',
        },
        {
            ID = 29,
            Job = 22,
            SpectrumMax = 0,
            Type = 11,
            TypeParam1 = '1085|{4,20,25}',
            _TypeParam2 = CS._2_3,
        },
        {
            ID = 30,
            Job = 22,
            SpectrumMax = 0,
            Type = 11,
            TypeParam1 = '1077',
            _TypeParam2 = CS._2_3,
        },
        {
            ID = 31,
            Job = 12,
            TypeParam1 = '2000,5000',
        },
        {
            DeadKeep = 1,
            ID = 32,
            Job = 0,
            ResourceInc = 12,
            SpectrumMax = 3000,
        },
        {
            DeadKeep = 1,
            ID = 33,
            Job = 0,
            ResourceInc = 16,
            SpectrumMax = 3000,
        },
        {
            DeadKeep = 1,
            ID = 34,
            Job = 0,
            ResourceInc = 5,
            SpectrumMax = 3000,
        },
        {
            ID = 35,
            Job = 19,
        },
        {
            ID = 36,
            Job = 19,
        },
        {
            ID = 37,
            Job = 11,
            TypeParam1 = '50',
        },
        {
            ID = 38,
            Job = 11,
            SpectrumMax = 1,
            TypeParam1 = '1400',
        },
        {
            ID = 39,
            Job = 11,
            SpectrumMax = 1,
        },
        {
            ID = 40,
            Job = 27,
            SpectrumMax = 1,
        },
	},
}

setmetatable(SpectrumCfg, { __index = CfgBase })

SpectrumCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


return SpectrumCfg
