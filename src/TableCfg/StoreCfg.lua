-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class StoreCfg : CfgBase
local StoreCfg = {
	TableName = "c_store_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = true,
	Localization = {
        Config = {
            {
                Name = 'LabelMain',
            },
            {
                Name = 'LabelSub',
            },
            {
                Name = 'Name',
            },
            {
                Name = 'Desc',
            },
            {
                Name = 'PurchaseConditions',
                Children = {
                    {
                        Name = 'Desc',
                    },
				},
            },
            {
                Name = 'TipsConditionDes',
            },
            {
                Name = 'SpecialTips',
                Children = {
                    {
                        Name = 'Des',
                    },
				},
            },
            {
                Name = 'AdditionalDesc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(StoreCfg, { __index = CfgBase })

StoreCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return StoreCfg
