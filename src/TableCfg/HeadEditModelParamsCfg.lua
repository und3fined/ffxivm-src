-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class HeadEditModelParamsCfg : CfgBase
local HeadEditModelParamsCfg = {
	TableName = "c_head_edit_model_params_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(HeadEditModelParamsCfg, { __index = CfgBase })

HeadEditModelParamsCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

local RaceCfg = require("TableCfg/RaceCfg")
local MajorUtil = require("Utils/MajorUtil")

function HeadEditModelParamsCfg:GetMajorCfg() 
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
	return HeadEditModelParamsCfg:FindCfg(SearchConditions)
end

return HeadEditModelParamsCfg
