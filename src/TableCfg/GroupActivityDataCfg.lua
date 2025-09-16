-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupActivityDataCfg : CfgBase
local GroupActivityDataCfg = {
	TableName = "c_GroupActivityData_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'TipsText',
            },
            {
                Name = 'EditText',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupActivityDataCfg, { __index = CfgBase })

GroupActivityDataCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GroupActivityDataCfg
