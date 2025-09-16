-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GuideDescribeCfg : CfgBase
local GuideDescribeCfg = {
	TableName = "c_GuideDescribe_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Describe',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GuideDescribeCfg, { __index = CfgBase })

GuideDescribeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GuideDescribeCfg
