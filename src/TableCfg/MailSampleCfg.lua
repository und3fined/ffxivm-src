-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MailSampleCfg : CfgBase
local MailSampleCfg = {
	TableName = "c_MailSample_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Text',
            },
            {
                Name = 'SenderID',
            },
            {
                Name = 'Title',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MailSampleCfg, { __index = CfgBase })

MailSampleCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MailSampleCfg
