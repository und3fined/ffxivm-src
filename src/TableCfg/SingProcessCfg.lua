-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SingProcessCfg : CfgBase
local SingProcessCfg = {
	TableName = "c_sing_process_cfg",
    LruKeyType = nil,
	KeyName = "SingID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        ShowWeaponOnBreak = 1,
        SingID = 0,
    },
	LuaData = {
        {
            ShowWeaponOnBreak = 0,
        },
        {
            SingID = 102102,
        },
        {
            SingID = 103102,
        },
        {
            SingID = 103302,
        },
        {
            SingID = 104102,
        },
        {
            SingID = 105102,
        },
        {
            SingID = 107102,
        },
        {
            SingID = 107302,
        },
        {
            SingID = 108102,
        },
        {
            SingID = 108302,
        },
	},
}

setmetatable(SingProcessCfg, { __index = CfgBase })

SingProcessCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return SingProcessCfg
