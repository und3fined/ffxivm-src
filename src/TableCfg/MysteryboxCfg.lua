-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MysteryboxCfg : CfgBase
local MysteryboxCfg = {
	TableName = "c_mysterybox_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'Desc',
            },
            {
                Name = 'Note',
            },
            {
                Name = 'BuyNote',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MysteryboxCfg, { __index = CfgBase })

MysteryboxCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MysteryboxCfg
