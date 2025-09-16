-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SceneEncourageNpcCfg : CfgBase
local SceneEncourageNpcCfg = {
	TableName = "c_scene_encourage_npc_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'ProfName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(SceneEncourageNpcCfg, { __index = CfgBase })

SceneEncourageNpcCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return SceneEncourageNpcCfg
