-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ShareAppCfg : CfgBase
local ShareAppCfg = {
	TableName = "c_share_app_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ShareAppCfg, { __index = CfgBase })

ShareAppCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ShareAppCfg
