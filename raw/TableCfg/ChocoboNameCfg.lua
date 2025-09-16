-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ChocoboNameCfg : CfgBase
local ChocoboNameCfg = {
	TableName = "c_chocobo_name_cfg",
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

setmetatable(ChocoboNameCfg, { __index = CfgBase })

ChocoboNameCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ChocoboNameCfg
