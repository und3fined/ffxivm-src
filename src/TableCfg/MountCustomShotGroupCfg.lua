-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MountCustomShotGroupCfg : CfgBase
local MountCustomShotGroupCfg = {
	TableName = "c_mount_custom_shot_group_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Shot',
                Children = {
                    {
                        Name = 'Description',
                    },
				},
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MountCustomShotGroupCfg, { __index = CfgBase })

MountCustomShotGroupCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MountCustomShotGroupCfg
