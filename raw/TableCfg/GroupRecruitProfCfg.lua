-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupRecruitProfCfg : CfgBase
local GroupRecruitProfCfg = {
	TableName = "c_GroupRecruitProf_cfg",
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

setmetatable(GroupRecruitProfCfg, { __index = CfgBase })

GroupRecruitProfCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GroupRecruitProfCfg
