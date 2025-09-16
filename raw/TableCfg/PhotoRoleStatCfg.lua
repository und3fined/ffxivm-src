-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PhotoRoleStatCfg : CfgBase
local PhotoRoleStatCfg = {
	TableName = "c_PhotoRoleStat_cfg",
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

setmetatable(PhotoRoleStatCfg, { __index = CfgBase })

PhotoRoleStatCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return PhotoRoleStatCfg
