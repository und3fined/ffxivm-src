-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PerformAssistantCfg : CfgBase
local PerformAssistantCfg = {
	TableName = "c_perform_assistant_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(PerformAssistantCfg, { __index = CfgBase })

PerformAssistantCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return PerformAssistantCfg
