-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PVPHonorCfg : CfgBase
local PVPHonorCfg = {
	TableName = "c_PVPHonor_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Type',
            },
            {
                Name = 'Name',
            },
            {
                Name = 'Description',
            },
            {
                Name = 'ConditionNote',
            },
		}
    },
    DefaultValues = {
        AchievementID = 0,
        ConditionID = 0,
        ConditionParam = 1,
        ID = 1,
        Icon = '',
        IsOpen = 1,
        Level = 1,
        SortID = 0,
        Type = 2,
    },
	LuaData = {
        {
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal2.UI_Icon_PVP_BattleInfo_Medal2\'',
            Type = 1,
        },
        {
            ConditionParam = 3,
            ID = 2,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal15.UI_Icon_PVP_BattleInfo_Medal15\'',
        },
        {
            ConditionParam = 6,
            ID = 3,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal16.UI_Icon_PVP_BattleInfo_Medal16\'',
            Level = 2,
        },
        {
            ConditionParam = 10,
            ID = 4,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal17.UI_Icon_PVP_BattleInfo_Medal17\'',
            Level = 2,
        },
        {
            ConditionParam = 50,
            ID = 5,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal21.UI_Icon_PVP_BattleInfo_Medal21\'',
            Type = 3,
        },
        {
            ConditionParam = 500,
            ID = 6,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal22.UI_Icon_PVP_BattleInfo_Medal22\'',
            Level = 2,
            Type = 3,
        },
        {
            ConditionParam = 2000,
            ID = 7,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal23.UI_Icon_PVP_BattleInfo_Medal23\'',
            Level = 3,
            Type = 3,
        },
        {
            ConditionParam = 20,
            ID = 8,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal12.UI_Icon_PVP_BattleInfo_Medal12\'',
            Type = 4,
        },
        {
            ConditionParam = 200,
            ID = 9,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal13.UI_Icon_PVP_BattleInfo_Medal13\'',
            Level = 2,
            Type = 4,
        },
        {
            ConditionParam = 1000,
            ID = 10,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal14.UI_Icon_PVP_BattleInfo_Medal14\'',
            Level = 3,
            Type = 4,
        },
        {
            ID = 11,
            IsOpen = 0,
            Type = 5,
        },
        {
            ConditionParam = 3,
            ID = 12,
            IsOpen = 0,
            Level = 2,
            Type = 5,
        },
        {
            ConditionParam = 8,
            ID = 13,
            IsOpen = 0,
            Level = 3,
            Type = 5,
        },
        {
            AchievementID = 2020080,
            ID = 14,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal1.UI_Icon_PVP_BattleInfo_Medal1\'',
            Level = 3,
            Type = 6,
        },
        {
            ID = 15,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal9.UI_Icon_PVP_BattleInfo_Medal9\'',
            Type = 7,
        },
        {
            ConditionParam = 10,
            ID = 16,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal10.UI_Icon_PVP_BattleInfo_Medal10\'',
            Level = 2,
            Type = 7,
        },
        {
            ConditionParam = 100,
            ID = 17,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal11.UI_Icon_PVP_BattleInfo_Medal11\'',
            Level = 3,
            Type = 7,
        },
        {
            ConditionParam = 50,
            ID = 18,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal3.UI_Icon_PVP_BattleInfo_Medal3\'',
            Type = 8,
        },
        {
            ConditionParam = 500,
            ID = 19,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal4.UI_Icon_PVP_BattleInfo_Medal4\'',
            Level = 2,
            Type = 8,
        },
        {
            ConditionParam = 2000,
            ID = 20,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal5.UI_Icon_PVP_BattleInfo_Medal5\'',
            Level = 3,
            Type = 8,
        },
        {
            ID = 21,
            IsOpen = 0,
            Type = 9,
        },
        {
            ConditionParam = 10,
            ID = 22,
            IsOpen = 0,
            Level = 2,
            Type = 9,
        },
        {
            ConditionParam = 100,
            ID = 23,
            IsOpen = 0,
            Level = 3,
            Type = 9,
        },
        {
            ConditionParam = 20,
            ID = 24,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal18.UI_Icon_PVP_BattleInfo_Medal18\'',
            Type = 10,
        },
        {
            ConditionParam = 200,
            ID = 25,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal19.UI_Icon_PVP_BattleInfo_Medal19\'',
            Level = 2,
            Type = 10,
        },
        {
            ConditionParam = 1000,
            ID = 26,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal20.UI_Icon_PVP_BattleInfo_Medal20\'',
            Level = 3,
            Type = 10,
        },
        {
            ConditionParam = 100,
            ID = 27,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal6.UI_Icon_PVP_BattleInfo_Medal6\'',
            Type = 11,
        },
        {
            ConditionParam = 1000,
            ID = 28,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal7.UI_Icon_PVP_BattleInfo_Medal7\'',
            Level = 2,
            Type = 11,
        },
        {
            ConditionParam = 5000,
            ID = 29,
            Icon = 'Texture2D\'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_Medal8.UI_Icon_PVP_BattleInfo_Medal8\'',
            Level = 3,
            Type = 11,
        },
	},
}

setmetatable(PVPHonorCfg, { __index = CfgBase })

PVPHonorCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function PVPHonorCfg:FindCfgsByType(HonorType)
    local SearchCondition = string.format("Type == %d", HonorType)
 	return PVPHonorCfg:FindAllCfg(SearchCondition)
end

function PVPHonorCfg:FindMinLevelCfgByType(HonorType)
    local Cfgs = self:FindCfgsByType(HonorType)
    
    local Result = nil
    local MinLevel = 100
    for _, Cfg in pairs(Cfgs or {}) do
        if Cfg.Level < MinLevel then
            MinLevel = Cfg.Level
            Result = Cfg
        end
    end

    return Result
end

return PVPHonorCfg
