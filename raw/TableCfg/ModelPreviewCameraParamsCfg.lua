-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ModelPreviewCameraParamsCfg : CfgBase
local ModelPreviewCameraParamsCfg = {
	TableName = "c_model_preview_camera_params_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ModelPreviewCameraParamsCfg, { __index = CfgBase })

ModelPreviewCameraParamsCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function ModelPreviewCameraParamsCfg:FindCfgByKeys(SkeletonID, ViewGroupID)
	if nil == SkeletonID or nil == ViewGroupID then
		return nil
	end
	return self:FindCfgByKey(SkeletonID * 1000 + ViewGroupID)
end

return ModelPreviewCameraParamsCfg
