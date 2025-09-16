-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MountCustomCfg : CfgBase
local MountCustomCfg = {
	TableName = "c_mount_custom_cfg",
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

setmetatable(MountCustomCfg, { __index = CfgBase })

MountCustomCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MountCustomCfg
