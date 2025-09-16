-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ChocoboTitleCfg : CfgBase
local ChocoboTitleCfg = {
	TableName = "c_chocobo_title_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'Mission',
                Children = {
                    {
                        Name = 'Desc',
                    },
				},
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ChocoboTitleCfg, { __index = CfgBase })

ChocoboTitleCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ChocoboTitleCfg
