-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class DepartOfLightDescCfg : CfgBase
local DepartOfLightDescCfg = {
	TableName = "c_depart_of_light_desc_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ModuleID',
            },
            {
                Name = 'ModuleName',
            },
            {
                Name = 'HighLightDesc',
            },
            {
                Name = 'DescList',
                Children = {
                    {
                        Name = 'Title',
                    },
                    {
                        Name = 'Content',
                    },
				},
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(DepartOfLightDescCfg, { __index = CfgBase })

DepartOfLightDescCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return DepartOfLightDescCfg
