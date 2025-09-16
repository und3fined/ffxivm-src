-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GuideCfg : CfgBase
local GuideCfg = {
	TableName = "c_guide_cfg",
    LruKeyType = nil,
	KeyName = "GuideID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Title',
            },
            {
                Name = 'Content',
            },
            {
                Name = 'WindowContent',
            },
            {
                Name = 'SubTitle',
            },
            {
                Name = 'WindowContent[4]',
            },
            {
                Name = 'Content[4]',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GuideCfg, { __index = CfgBase })

GuideCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function GuideCfg:FindCfgByID(ID)
	local CachedData = self:GetCachedData()
	for _, v in pairs(CachedData) do
		if v.GuideID == ID then
			return v
		end
	end

	local SearchConditions = string.format("GuideID = %d", ID)
	return self:FindCfg(SearchConditions)
end

function GuideCfg:FindCfgByGuideID(GuideID)
	return self:FindCfgByKey(GuideID)
end

function GuideCfg:FindAllGroupID(GroupID)
	local AllCfgs = self:FindAllCfg(string.format("GuideTypeID = %d", GroupID))
    return AllCfgs
end


return GuideCfg
