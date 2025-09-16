-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SkillSeriesCfg : CfgBase
local SkillSeriesCfg = {
	TableName = "c_skill_series_cfg",
    LruKeyType = nil,
	KeyName = "BaseSkillID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        BaseSkillID = 10300,
        BeginTime = 0,
        EndTime = 5000,
        ID = 1,
        IsCanBeBreak = 0,
        Prof = 21,
        _SkillQueue = '[10300,10301,10302]',
        bReplaceAnim = 1,
    },
	LuaData = {
        {
            Prof = 18,
        },
        {
            BaseSkillID = 20300,
            ID = 2,
            Prof = 18,
            _SkillQueue = '[20300,20301,20302]',
        },
        {
            BaseSkillID = 10101,
            ID = 3,
            IsCanBeBreak = 1,
            Prof = 10,
            _SkillQueue = '[10101,10102,10103]',
        },
        {
            BaseSkillID = 10200,
            EndTime = 3000,
            ID = 4,
            IsCanBeBreak = 1,
            Prof = 25,
            _SkillQueue = '[10200,10210,10211]',
        },
        {
            BaseSkillID = 20200,
            EndTime = 3000,
            ID = 5,
            IsCanBeBreak = 1,
            Prof = 25,
            _SkillQueue = '[20200,20210,20211]',
        },
        {
            BaseSkillID = 20101,
            ID = 7,
            IsCanBeBreak = 1,
            Prof = 10,
            _SkillQueue = '[20101,20102,20103]',
        },
        {
            BaseSkillID = 10526,
            ID = 8,
            _SkillQueue = '[10526,10527,10528]',
        },
        {
            BaseSkillID = 10601,
            ID = 9,
            IsCanBeBreak = 1,
            Prof = 16,
            _SkillQueue = '[10601,10602,10603]',
        },
        {
            BaseSkillID = 10701,
            ID = 10,
            IsCanBeBreak = 1,
            Prof = 26,
            _SkillQueue = '[10701,10702,10703]',
        },
        {
            BaseSkillID = 10801,
            ID = 11,
            Prof = 17,
            _SkillQueue = '[10801,10802,10803,10804,10805,10806,10807,10808]',
        },
        {
            BaseSkillID = 10818,
            EndTime = 6000,
            ID = 12,
            Prof = 17,
            _SkillQueue = '[10818,10819]',
            bReplaceAnim = 0,
        },
        {
            BaseSkillID = 11101,
            ID = 13,
            IsCanBeBreak = 1,
            Prof = 22,
            _SkillQueue = '[11101,11102,11103]',
            bReplaceAnim = 0,
        },
        {
            BaseSkillID = 10901,
            ID = 14,
            IsCanBeBreak = 1,
            Prof = 12,
            _SkillQueue = '[10901,10902,10903]',
        },
        {
            BaseSkillID = 10926,
            EndTime = 1000,
            ID = 16,
            IsCanBeBreak = 1,
            Prof = 12,
            _SkillQueue = '[10926,10926,10926,10926,10926,10926]',
        },
        {
            BaseSkillID = 10905,
            ID = 17,
            IsCanBeBreak = 1,
            Prof = 12,
            _SkillQueue = '[10905,10927,10928]',
        },
        {
            BaseSkillID = 10620,
            EndTime = 1000,
            ID = 18,
            IsCanBeBreak = 1,
            Prof = 16,
            _SkillQueue = '[10620,10618]',
            bReplaceAnim = 0,
        },
        {
            BaseSkillID = 11001,
            ID = 19,
            IsCanBeBreak = 1,
            Prof = 15,
            _SkillQueue = '[11001,11002,11003]',
        },
        {
            BaseSkillID = 10635,
            ID = 20,
            IsCanBeBreak = 1,
            Prof = 16,
            _SkillQueue = '[10635,10636,10637]',
        },
        {
            BaseSkillID = 10222,
            EndTime = 3000,
            ID = 21,
            IsCanBeBreak = 1,
            Prof = 25,
            _SkillQueue = '[10222,10223,10224]',
        },
        {
            BaseSkillID = 20426,
            ID = 22,
            _SkillQueue = '[20426,20427,20428]',
        },
        {
            BaseSkillID = 20400,
            EndTime = 8000,
            ID = 23,
            _SkillQueue = '[20400,20401,20402]',
        },
        {
            BaseSkillID = 20401,
            EndTime = 8000,
            ID = 24,
            _SkillQueue = '[20401,20402,20403]',
        },
        {
            BaseSkillID = 20801,
            EndTime = 8000,
            ID = 25,
            Prof = 17,
            _SkillQueue = '[20801,20802,20806,20803,20801,20802,20806,20804,20801,20802,20806,20805]',
        },
        {
            BaseSkillID = 20380,
            ID = 26,
            Prof = 18,
            _SkillQueue = '[20380,20381,20382]',
        },
        {
            BaseSkillID = 20901,
            EndTime = 6000,
            ID = 27,
            Prof = 12,
            _SkillQueue = '[20901,20902,20903]',
        },
        {
            BaseSkillID = 20601,
            EndTime = 8000,
            ID = 28,
            Prof = 16,
            _SkillQueue = '[20601,20602,20603,20640]',
        },
        {
            BaseSkillID = 20701,
            ID = 29,
            Prof = 26,
            _SkillQueue = '[20701,20702,20703]',
        },
        {
            BaseSkillID = 21101,
            EndTime = 8000,
            ID = 31,
            Prof = 22,
            _SkillQueue = '[21101,21102,21103]',
            bReplaceAnim = 0,
        },
        {
            BaseSkillID = 21119,
            EndTime = 3600000,
            ID = 32,
            Prof = 22,
            _SkillQueue = '[21119,21120,21121]',
            bReplaceAnim = 0,
        },
        {
            BaseSkillID = 21126,
            EndTime = 3600000,
            ID = 33,
            Prof = 22,
            _SkillQueue = '[21126,21127,21128]',
            bReplaceAnim = 0,
        },
        {
            BaseSkillID = 10401,
            ID = 34,
            Prof = 11,
            _SkillQueue = '[10401,10402,10403]',
            bReplaceAnim = 0,
        },
        {
            BaseSkillID = 11200,
            ID = 35,
            Prof = 19,
            _SkillQueue = '[11200,11201,11202,11203]',
            bReplaceAnim = 0,
        },
        {
            BaseSkillID = 10415,
            ID = 36,
            Prof = 11,
            _SkillQueue = '[10415,10416,10417]',
            bReplaceAnim = 0,
        },
	},
}

setmetatable(SkillSeriesCfg, { __index = CfgBase })

SkillSeriesCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


function SkillSeriesCfg:FindCfgByBaseSkillID(BaseSkillID)
	local SearchConditions = string.format("BaseSkillID = %d", BaseSkillID)
	return self:FindCfg(SearchConditions)
end

return SkillSeriesCfg
