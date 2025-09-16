-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupStoreUitextCfg : CfgBase
local GroupStoreUitextCfg = {
	TableName = "c_group_store_uitext_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'TextStr',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupStoreUitextCfg, { __index = CfgBase })

GroupStoreUitextCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GroupStoreUitextCfg
