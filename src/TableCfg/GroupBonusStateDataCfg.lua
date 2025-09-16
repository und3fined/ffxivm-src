-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupBonusStateDataCfg : CfgBase
local GroupBonusStateDataCfg = {
	TableName = "c_GroupBonusStateData_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'EffectName',
            },
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupBonusStateDataCfg, { __index = CfgBase })

GroupBonusStateDataCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GroupBonusStateDataCfg
