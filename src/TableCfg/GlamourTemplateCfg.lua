-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GlamourTemplateCfg : CfgBase
local GlamourTemplateCfg = {
	TableName = "c_Glamour_template_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'DefaultName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GlamourTemplateCfg, { __index = CfgBase })

GlamourTemplateCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GlamourTemplateCfg
