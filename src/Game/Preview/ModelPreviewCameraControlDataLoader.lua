local LuaClass = require("Core/LuaClass")

local CameraControlDataLoader = require("Game/Common/Render2D/CameraControlDataLoader")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")
local CameraControlParams = require("Game/Common/Render2D/CameraControlParams")
local ModelPreviewCameraParamsCfg = require("TableCfg/ModelPreviewCameraParamsCfg")

local FocusType = CameraControlDefine.FocusType

---@class ModelPreviewCameraControlDataLoader : CameraControlDataLoader
local ModelPreviewCameraControlDataLoader = LuaClass(CameraControlDataLoader, true)

function ModelPreviewCameraControlDataLoader:GetCameraControlParams(SkeletonName, ViewGroupID)
	if string.isnilorempty(SkeletonName) or nil == ViewGroupID then
		_G.FLOG_ERROR("[ModelPreviewCameraControlDataLoader:GetCameraControlParams] Invalid skeleton name or view group ID")
		return nil
	end

	if nil == self.CachedParams then
		-- 处理没通过New创建DataLoader的情况
		self.CachedParams = {}
	end

	if nil ~= self.CachedParams[SkeletonName] and nil ~= self.CachedParams[SkeletonName][ViewGroupID] then
		return self.CachedParams[SkeletonName][ViewGroupID]
	end

	local SkeletonID = SkeletonName:match("^[a-zA-Z]0*(%d+)$")
	SkeletonID = SkeletonID and tonumber(SkeletonID) or 0
	local CfgData = ModelPreviewCameraParamsCfg:FindCfgByKeys(SkeletonID, ViewGroupID)
	if nil == CfgData or nil == CfgData.CameraParams then
		return nil
	end
	local RawFocusData = CfgData.CameraParams
	local CameraControlParams = CameraControlParams.New()
	CameraControlParams.FocusEID = self:GetFocusEID(FocusType.WholeBody)
	self:TransformParamsData(RawFocusData, CameraControlParams)

	if nil == self.CachedParams[SkeletonName] then
		self.CachedParams[SkeletonName] = {}
	end
	self.CachedParams[SkeletonName][ViewGroupID] = CameraControlParams

	return CameraControlParams
end

return ModelPreviewCameraControlDataLoader
