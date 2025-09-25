-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

local CS = {
    _1_1 = '[5,5,5,5,5,5,5,5]',
    _1_2 = '[1,3,2,2]',
    _2_1 = '[1]',
    _2_2 = '[1,2]',
}

---@class TeamRecruitCfg : CfgBase
local TeamRecruitCfg = {
	TableName = "c_team_recruit_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'TaskName',
            },
		}
    },
    DefaultValues = {
        CompleteTask = 1,
        CrossWorldConfirm = 0,
        DailyRandomID = 0,
        _DefaultProf = '[1,1,3,3,2,2,2,2]',
        EquipLv = 1,
        ID = 1,
        IsWeeklyRewards = 0,
        _RecruitModel = '[]',
        Task = 1211008,
        TypeID = 9,
        bFilterDifficulty = 1,
    },
	LuaData = {
        {
            CompleteTask = 0,
            _DefaultProf = CS._1_1,
            EquipLv = 0,
            TypeID = 1,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            DailyRandomID = 3,
            _DefaultProf = CS._1_2,
            EquipLv = 90,
            ID = 2,
            Task = 1211004,
            TypeID = 2,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            DailyRandomID = 1,
            _DefaultProf = CS._1_2,
            EquipLv = 10,
            ID = 3,
            Task = 1211009,
            TypeID = 2,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            DailyRandomID = 2,
            EquipLv = 50,
            ID = 4,
            Task = 1202015,
            TypeID = 2,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            DailyRandomID = 5,
            EquipLv = 140,
            ID = 5,
            Task = 1206004,
            TypeID = 2,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            DailyRandomID = 6,
            EquipLv = 120,
            ID = 6,
            Task = 1206003,
            TypeID = 2,
            bFilterDifficulty = 0,
        },
        {
            _DefaultProf = CS._1_2,
            EquipLv = 10,
            ID = 7,
            _RecruitModel = CS._2_2,
            TypeID = 3,
        },
        {
            _DefaultProf = CS._1_2,
            EquipLv = 10,
            ID = 8,
            _RecruitModel = CS._2_2,
            Task = 1211009,
            TypeID = 3,
        },
        {
            _DefaultProf = CS._1_2,
            EquipLv = 10,
            ID = 9,
            _RecruitModel = CS._2_2,
            Task = 1211010,
            TypeID = 3,
        },
        {
            _DefaultProf = CS._1_2,
            EquipLv = 20,
            ID = 10,
            _RecruitModel = CS._2_2,
            Task = 1211012,
            TypeID = 3,
        },
        {
            _DefaultProf = CS._1_2,
            EquipLv = 30,
            ID = 11,
            _RecruitModel = CS._2_2,
            Task = 1211005,
            TypeID = 3,
        },
        {
            _DefaultProf = CS._1_2,
            EquipLv = 40,
            ID = 12,
            _RecruitModel = CS._2_2,
            Task = 1211006,
            TypeID = 3,
        },
        {
            _DefaultProf = CS._1_2,
            EquipLv = 50,
            ID = 13,
            _RecruitModel = CS._2_2,
            Task = 1211002,
            TypeID = 3,
        },
        {
            _DefaultProf = CS._1_2,
            EquipLv = 60,
            ID = 14,
            _RecruitModel = CS._2_2,
            Task = 1211013,
            TypeID = 3,
        },
        {
            _DefaultProf = CS._1_2,
            EquipLv = 70,
            ID = 15,
            _RecruitModel = CS._2_2,
            Task = 1211003,
            TypeID = 3,
        },
        {
            _DefaultProf = CS._1_2,
            EquipLv = 80,
            ID = 16,
            _RecruitModel = CS._2_2,
            Task = 1211014,
            TypeID = 3,
        },
        {
            _DefaultProf = CS._1_2,
            EquipLv = 90,
            ID = 17,
            _RecruitModel = CS._2_1,
            Task = 1211007,
            TypeID = 3,
        },
        {
            _DefaultProf = CS._1_2,
            EquipLv = 90,
            ID = 18,
            _RecruitModel = CS._2_1,
            Task = 1211004,
            TypeID = 3,
        },
        {
            EquipLv = 20,
            ID = 19,
            _RecruitModel = CS._2_2,
            Task = 1202021,
            TypeID = 5,
        },
        {
            EquipLv = 60,
            ID = 20,
            _RecruitModel = CS._2_2,
            Task = 1202015,
            TypeID = 5,
        },
        {
            EquipLv = 80,
            ID = 21,
            _RecruitModel = CS._2_2,
            Task = 1202020,
            TypeID = 5,
        },
        {
            _DefaultProf = CS._1_2,
            EquipLv = 90,
            ID = 22,
            _RecruitModel = CS._2_1,
            Task = 1211011,
            TypeID = 3,
        },
        {
            EquipLv = 125,
            ID = 23,
            _RecruitModel = CS._2_1,
            Task = 1202024,
            TypeID = 5,
        },
        {
            EquipLv = 125,
            ID = 24,
            _RecruitModel = CS._2_1,
            Task = 1202025,
            TypeID = 5,
        },
        {
            EquipLv = 125,
            ID = 25,
            _RecruitModel = CS._2_1,
            Task = 1202023,
            TypeID = 5,
        },
        {
            EquipLv = 105,
            ID = 26,
            _RecruitModel = CS._2_1,
            Task = 1203016,
            TypeID = 5,
        },
        {
            EquipLv = 135,
            ID = 27,
            _RecruitModel = CS._2_1,
            Task = 1202022,
            TypeID = 5,
        },
        {
            EquipLv = 145,
            ID = 28,
            _RecruitModel = CS._2_1,
            Task = 1203277,
            TypeID = 5,
        },
        {
            EquipLv = 165,
            ID = 29,
            _RecruitModel = CS._2_1,
            Task = 1203024,
            TypeID = 5,
        },
        {
            EquipLv = 100,
            ID = 30,
            _RecruitModel = CS._2_1,
            Task = 1206001,
            TypeID = 6,
        },
        {
            EquipLv = 140,
            ID = 31,
            _RecruitModel = CS._2_1,
            Task = 1206004,
            TypeID = 6,
        },
        {
            EquipLv = 120,
            ID = 32,
            _RecruitModel = CS._2_1,
            Task = 1205015,
            TypeID = 6,
        },
        {
            EquipLv = 120,
            ID = 33,
            _RecruitModel = CS._2_1,
            Task = 1206003,
            TypeID = 6,
        },
        {
            EquipLv = 120,
            ID = 34,
            _RecruitModel = CS._2_1,
            Task = 1205012,
            TypeID = 6,
        },
        {
            EquipLv = 120,
            ID = 35,
            _RecruitModel = CS._2_1,
            Task = 1205014,
            TypeID = 6,
        },
        {
            EquipLv = 135,
            ID = 36,
            IsWeeklyRewards = 1,
            _RecruitModel = CS._2_1,
            Task = 1205011,
            TypeID = 6,
        },
        {
            EquipLv = 135,
            ID = 37,
            IsWeeklyRewards = 1,
            _RecruitModel = CS._2_1,
            Task = 1206002,
            TypeID = 6,
        },
        {
            EquipLv = 135,
            ID = 38,
            IsWeeklyRewards = 1,
            _RecruitModel = CS._2_1,
            Task = 1205010,
            TypeID = 6,
        },
        {
            EquipLv = 135,
            ID = 39,
            IsWeeklyRewards = 1,
            _RecruitModel = CS._2_1,
            Task = 1205013,
            TypeID = 6,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 40,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 41,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 42,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 43,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 44,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 45,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 46,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 47,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 48,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 49,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 50,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 51,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 52,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 53,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 54,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 55,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 56,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 57,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            _DefaultProf = CS._1_1,
            ID = 58,
            TypeID = 10,
            bFilterDifficulty = 0,
        },
        {
            CompleteTask = 0,
            CrossWorldConfirm = 1,
            _DefaultProf = CS._1_1,
            ID = 59,
            TypeID = 11,
            bFilterDifficulty = 0,
        },
        {
            EquipLv = 155,
            ID = 612,
            Task = 1205024,
            TypeID = 6,
            bFilterDifficulty = 0,
        },
	},
}

setmetatable(TeamRecruitCfg, { __index = CfgBase })

TeamRecruitCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---获取去重招募类型列表
---@return table
function TeamRecruitCfg:GetDistinctTypeIDList()
	local Ret = {}
	local Cfg = self:FindAllCfg()

	for _, v in ipairs(Cfg or {}) do
		if v.TypeID then
			Ret[v.TypeID] = true
		end
	end

	return table.indices(Ret)
end

---获取指定类型的所有招募内容
---@param TypeID number @招募类型ID
---@return table
function TeamRecruitCfg:GetContentListByType( TypeID )
	if nil == TypeID then
		return
	end

    local CfgList =  self:FindAllCfg(string.format("TypeID = %d", TypeID))
	return CfgList
end

---获取指定内容的招募类型
---@param ID number @内容ID
---@return number
function TeamRecruitCfg:GetTypeID( ID )
	local Cfg = self:FindCfgByKey(ID)
	if nil == Cfg then
		return
	end

	return Cfg.TypeID
end

return TeamRecruitCfg
