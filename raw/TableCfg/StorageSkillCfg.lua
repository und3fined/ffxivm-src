-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class StorageSkillCfg : CfgBase
local StorageSkillCfg = {
	TableName = "c_storage_skill_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        ID = 0,
        IsCancel = 0,
        IsTurn = 0,
        IsVisible = 1,
        LevelCount = 3,
        _LevelList = '[{"MaxTime":500,"ActionID":"","SkillID":20913},{"MaxTime":2500,"ActionID":"","SkillID":20913},{"MaxTime":5000,"ActionID":"","SkillID":20913},{"MaxTime":0,"ActionID":"","SkillID":0}]',
        LimitTime = 1500,
        MaxTime = 1500,
        MinTime = 0,
        MoveMultiply = 0.0,
        ReturnCD = 0.0,
        SingID = 0,
        Weight = 3,
    },
	LuaData = {
        {
            IsVisible = 0,
            LevelCount = 0,
            _LevelList = '[{"MaxTime":0,"ActionID":"","SkillID":0},{"MaxTime":0,"ActionID":"","SkillID":0},{"MaxTime":0,"ActionID":"","SkillID":0},{"MaxTime":0,"ActionID":"","SkillID":0}]',
            LimitTime = 0,
            MaxTime = 0,
            Weight = 0,
        },
        {
            ID = 2073,
            _LevelList = '[{"MaxTime":500,"ActionID":"","SkillID":10509},{"MaxTime":1000,"ActionID":"","SkillID":10510},{"MaxTime":1500,"ActionID":"","SkillID":10511},{"MaxTime":0,"ActionID":"","SkillID":0}]',
            ReturnCD = 8000.0,
            SingID = 10508,
            Weight = 2,
        },
        {
            ID = 10508,
            _LevelList = '[{"MaxTime":100,"ActionID":"","SkillID":10509},{"MaxTime":1000,"ActionID":"","SkillID":10510},{"MaxTime":1500,"ActionID":"","SkillID":10511},{"MaxTime":0,"ActionID":"","SkillID":0}]',
            ReturnCD = 8000.0,
            SingID = 10508,
            Weight = 2,
        },
        {
            ID = 10820,
            LevelCount = 2,
            _LevelList = '[{"MaxTime":500,"ActionID":"","SkillID":10820},{"MaxTime":1000,"ActionID":"","SkillID":10827},{"MaxTime":0,"ActionID":"","SkillID":0},{"MaxTime":0,"ActionID":"","SkillID":0}]',
            LimitTime = 1000,
            MaxTime = 1000,
            ReturnCD = 60000.0,
            SingID = 10820,
        },
        {
            ID = 10920,
            _LevelList = '[{"MaxTime":200,"ActionID":"","SkillID":10921},{"MaxTime":1120,"ActionID":"","SkillID":10923},{"MaxTime":1700,"ActionID":"","SkillID":10925},{"MaxTime":0,"ActionID":"","SkillID":0}]',
            LimitTime = 1700,
            MaxTime = 1700,
            SingID = 1092001,
            Weight = 2,
        },
        {
            ID = 10929,
            IsVisible = 0,
            LevelCount = 2,
            _LevelList = '[{"MaxTime":300,"ActionID":"","SkillID":10904},{"MaxTime":600,"ActionID":"","SkillID":10913},{"MaxTime":0,"ActionID":"","SkillID":0},{"MaxTime":0,"ActionID":"","SkillID":0}]',
            LimitTime = 1000,
            MaxTime = 1000,
        },
        {
            ID = 20831,
            _LevelList = '[{"MaxTime":2500,"ActionID":"","SkillID":20815},{"MaxTime":0,"ActionID":"","SkillID":0},{"MaxTime":0,"ActionID":"","SkillID":0},{"MaxTime":0,"ActionID":"","SkillID":0}]',
            LimitTime = 2500,
            MaxTime = 2500,
            SingID = 2083101,
        },
        {
            ID = 20912,
            LimitTime = 6500,
            MaxTime = 6500,
            SingID = 20912,
        },
        {
            ID = 20921,
            LimitTime = 4500,
            MaxTime = 4500,
            SingID = 2092101,
        },
	},
}

setmetatable(StorageSkillCfg, { __index = CfgBase })

StorageSkillCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


return StorageSkillCfg
