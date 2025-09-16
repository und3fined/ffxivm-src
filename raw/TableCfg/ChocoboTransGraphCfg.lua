-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ChocoboTransGraphCfg : CfgBase
local ChocoboTransGraphCfg = {
	TableName = "c_chocobo_trans_graph_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'MapName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ChocoboTransGraphCfg, { __index = CfgBase })

ChocoboTransGraphCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ChocoboTransGraphCfg
