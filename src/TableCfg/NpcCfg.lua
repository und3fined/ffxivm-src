-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class NpcCfg : CfgBase
local NpcCfg = {
	TableName = "c_npc_cfg",
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

setmetatable(NpcCfg, { __index = CfgBase })

NpcCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return NpcCfg
