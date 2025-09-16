-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SpecialUislotCfg : CfgBase
local SpecialUislotCfg = {
	TableName = "c_special_uislot_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'UIName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(SpecialUislotCfg, { __index = CfgBase })

SpecialUislotCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function SpecialUislotCfg:FindCfgByID(ID)
	return self:FindCfgByKey(ID)
end

return SpecialUislotCfg
