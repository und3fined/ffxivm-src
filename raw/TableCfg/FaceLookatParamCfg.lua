-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FaceLookatParamCfg : CfgBase
local FaceLookatParamCfg = {
	TableName = "c_face_lookat_param_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FaceLookatParamCfg, { __index = CfgBase })

FaceLookatParamCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY
---FindCfgByRaceIDTribeGender
---@param AttachType string
function FaceLookatParamCfg:FindCfgByAttachType(AttachType)
	local SearchConditions = string.format('SkeletonName = "%s"', AttachType)
	return self:FindCfg(SearchConditions)
end

return FaceLookatParamCfg
