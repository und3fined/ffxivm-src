-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ScenarioTextCfg : CfgBase
local ScenarioTextCfg = {
	TableName = "c_scenario_text",
    LruKeyType = "string",
	KeyName = "TextID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Content',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ScenarioTextCfg, { __index = CfgBase })

ScenarioTextCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function ScenarioTextCfg:FindCfgByTextKey(TextKey)
	local SearchConditions = string.format("TextID = '%s'", TextKey)
	return self:FindCfg(SearchConditions)
end

return ScenarioTextCfg
