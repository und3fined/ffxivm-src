-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupLogCfg : CfgBase
local GroupLogCfg = {
	TableName = "c_GroupLog_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Type',
            },
            {
                Name = 'Text',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupLogCfg, { __index = CfgBase })

GroupLogCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GroupLogCfg
