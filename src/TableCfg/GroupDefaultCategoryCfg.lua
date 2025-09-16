-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupDefaultCategoryCfg : CfgBase
local GroupDefaultCategoryCfg = {
	TableName = "c_GroupDefaultCategory_cfg",
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

setmetatable(GroupDefaultCategoryCfg, { __index = CfgBase })

GroupDefaultCategoryCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GroupDefaultCategoryCfg
