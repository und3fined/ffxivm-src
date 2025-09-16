-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class RideCfg : CfgBase
local RideCfg = {
	TableName = "c_ride_cfg",
    LruKeyType = "integer",
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

setmetatable(RideCfg, { __index = CfgBase })

RideCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

--- 获取所有配置了打包的坐骑数据
function RideCfg:GetPackageCfg()
	local SearchConditions = "PackageName is not null and trim(PackageName) != ''"
	return self:FindAllCfg(SearchConditions)
end

return RideCfg
