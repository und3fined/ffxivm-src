-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupActivityTimeCfg : CfgBase
local GroupActivityTimeCfg = {
	TableName = "c_GroupActivityTime_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Text',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupActivityTimeCfg, { __index = CfgBase })

GroupActivityTimeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GroupActivityTimeCfg
