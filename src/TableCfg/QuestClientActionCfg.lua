-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class QuestClientActionCfg : CfgBase
local QuestClientActionCfg = {
	TableName = "c_quest_client_action_cfg",
    LruKeyType = "integer",
	KeyName = "id",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(QuestClientActionCfg, { __index = CfgBase })

QuestClientActionCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return QuestClientActionCfg
