-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PortraitModelDefaultParamsCfg : CfgBase
local PortraitModelDefaultParamsCfg = {
	TableName = "c_portrait_model_default_params_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(PortraitModelDefaultParamsCfg, { __index = CfgBase })

PortraitModelDefaultParamsCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

local RaceCfg = require("TableCfg/RaceCfg")
local MajorUtil = require("Utils/MajorUtil")

function PortraitModelDefaultParamsCfg:GetMajorCfg() 
	local RoleVM = MajorUtil.GetMajorRoleVM()
	if nil == RoleVM then
		return
	end

	local Cfg = RaceCfg:FindCfgByRaceIDGenderAndTribe(RoleVM.Race, RoleVM.Gender, RoleVM.Tribe)
	if nil == Cfg then 
		return
	end

	local AttachType = Cfg.AttachType
	if string.isnilorempty(AttachType) then
		return
	end

	local SearchConditions = string.format("SkeletonName = \"%s\"", AttachType)
	return PortraitModelDefaultParamsCfg:FindCfg(SearchConditions)
end

return PortraitModelDefaultParamsCfg
