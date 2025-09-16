-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class DyeColorCfg : CfgBase
local DyeColorCfg = {
	TableName = "c_dye_color_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'DisplayName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(DyeColorCfg, { __index = CfgBase })

DyeColorCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function DyeColorCfg:FindCfgByTypeID(ColorTypeID)
	local Cfgs = self:FindAllCfg(string.format("Type = %d", ColorTypeID))
	return Cfgs
end

return DyeColorCfg
