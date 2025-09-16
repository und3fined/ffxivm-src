-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MusicPlayerCfg : CfgBase
local MusicPlayerCfg = {
	TableName = "c_MusicPlayer_cfg",
    LruKeyType = nil,
	KeyName = "MusicID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'MusicName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MusicPlayerCfg, { __index = CfgBase })

MusicPlayerCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MusicPlayerCfg
