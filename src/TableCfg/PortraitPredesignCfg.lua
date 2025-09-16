-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PortraitPredesignCfg : CfgBase
local PortraitPredesignCfg = {
	TableName = "c_portrait_predesign_cfg",
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

setmetatable(PortraitPredesignCfg, { __index = CfgBase })

PortraitPredesignCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---获取预设信息列表
function PortraitPredesignCfg:GetPredesignInfos()
	return self:FindAllCfg("Hide != TRUE")
end

return PortraitPredesignCfg
