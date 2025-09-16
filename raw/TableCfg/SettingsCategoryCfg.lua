-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SettingsCategoryCfg : CfgBase
local SettingsCategoryCfg = {
	TableName = "c_settings_category_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'CategoryName',
            },
            {
                Name = 'SubCategoryName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(SettingsCategoryCfg, { __index = CfgBase })

SettingsCategoryCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---获取指定类别的子类别列表
---@param Category number，类别
---@return table
function SettingsCategoryCfg:GetSubCategoryList( Category )
	if nil == Category then
		return {}
	end

	local Condition = string.format("Category = %d AND SubCategory != 0", Category)
	local ret = SettingsCategoryCfg:FindAllCfg(Condition)
	return ret or {}
end

return SettingsCategoryCfg