-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ChocoboNamecatCfg : CfgBase
local ChocoboNamecatCfg = {
	TableName = "c_chocobo_namecat_cfg",
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

setmetatable(ChocoboNamecatCfg, { __index = CfgBase })

ChocoboNamecatCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ChocoboNamecatCfg
