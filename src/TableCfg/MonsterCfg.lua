-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MonsterCfg : CfgBase
local MonsterCfg = {
	TableName = "c_monster_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'Title',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MonsterCfg, { __index = CfgBase })

MonsterCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


return MonsterCfg
