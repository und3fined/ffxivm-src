-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupBonusStateGroupShowDataCfg : CfgBase
local GroupBonusStateGroupShowDataCfg = {
	TableName = "c_GroupBonusStateGroupShowData_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Desc',
            },
            {
                Name = 'Name',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupBonusStateGroupShowDataCfg, { __index = CfgBase })

GroupBonusStateGroupShowDataCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GroupBonusStateGroupShowDataCfg
