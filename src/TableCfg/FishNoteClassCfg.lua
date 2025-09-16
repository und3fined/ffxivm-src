-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FishNoteClassCfg : CfgBase
local FishNoteClassCfg = {
	TableName = "c_fish_note_class_cfg",
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

setmetatable(FishNoteClassCfg, { __index = CfgBase })

FishNoteClassCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FishNoteClassCfg
