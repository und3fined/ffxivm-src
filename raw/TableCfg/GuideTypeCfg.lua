-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GuideTypeCfg : CfgBase
local GuideTypeCfg = {
	TableName = "c_guide_type_cfg",
    LruKeyType = nil,
	KeyName = "GuideTypeID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'GuideName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GuideTypeCfg, { __index = CfgBase })

GuideTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function GuideTypeCfg:FindCfgByID(ID)
	local CachedData = self:GetCachedData()
	for _, v in pairs(CachedData) do
		if v.GuideTypeID == ID then
			return v
		end
	end

	local SearchConditions = string.format("GuideTypeID = %d", ID)
	return self:FindCfg(SearchConditions)
end

return GuideTypeCfg
