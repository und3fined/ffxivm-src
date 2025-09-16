-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class RecipetoolAnimatiomCfg : CfgBase
local RecipetoolAnimatiomCfg = {
	TableName = "c_recipetool_animatiom_cfg",
    LruKeyType = nil,
	KeyName = "Tool",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ToolName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(RecipetoolAnimatiomCfg, { __index = CfgBase })

RecipetoolAnimatiomCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function RecipetoolAnimatiomCfg:FindCrafterTool(Job, MainSubTool)
	local CachedData = self:GetCachedData()
	for _, v in pairs(CachedData) do
		if v.Job == Job and v.MainSubTool == MainSubTool then
			return v
		end
	end

	local SearchConditions = string.format("Job = %d AND MainSubTool = %d", Job, MainSubTool)
	return self:FindCfg(SearchConditions)
end

return RecipetoolAnimatiomCfg
