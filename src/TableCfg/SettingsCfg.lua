-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SettingsCfg : CfgBase
local SettingsCfg = {
	TableName = "c_settings_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Desc',
            },
            {
                Name = 'Value',
            },
            {
                Name = 'SwitchTips',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(SettingsCfg, { __index = CfgBase })

SettingsCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---获取设置信息列表
---@param Category number，类别
---@param SubCategory number，子类别
---@return table
function SettingsCfg:GetSettingsList( Category, SubCategory )
	if nil == Category then
		return {}
	end

	local IsWithEmulatorMode = _G.SettingsMgr.IsWithEmulatorMode
	local Condition = nil
	if nil == SubCategory then
		Condition = string.format("Category = %d", Category)
	else
		--IsHide: 0 都显示  1：真机/编辑器下隐藏  2：模拟器下隐藏   3：完全隐藏（真机、模拟器都隐藏）
		if IsWithEmulatorMode then
			Condition = string.format("Category = %d AND SubCategory = %d AND (IsHide = 0 OR IsHide = 1)", Category, SubCategory)
		else
			Condition = string.format("Category = %d AND SubCategory = %d AND (IsHide = 0 OR IsHide = 2)", Category, SubCategory)
		end
	end

	local ret = self:FindAllCfg(Condition)
	return ret or {}
end

return SettingsCfg
