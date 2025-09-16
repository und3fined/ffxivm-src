-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class HelpCfg : CfgBase
local HelpCfg = {
	TableName = "c_help_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'HelpName',
            },
            {
                Name = 'TitleName',
            },
            {
                Name = 'SecContent',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(HelpCfg, { __index = CfgBase })

HelpCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function HelpCfg:FindCfgByID(ID)
	return self:FindCfgByKey(ID)
end

function HelpCfg:FindAllHelpIDCfg(ID)
	local AllCfgs = self:FindAllCfg(string.format("HID = %d", ID))
    return AllCfgs
end

return HelpCfg
