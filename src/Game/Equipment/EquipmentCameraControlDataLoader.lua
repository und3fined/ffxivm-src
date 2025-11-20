local LuaClass = require("Core/LuaClass")

local CameraControlDataLoader = require("Game/Common/Render2D/CameraControlDataLoader")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")
local CameraControlParams = require("Game/Common/Render2D/CameraControlParams")
local CharasysCameraParamsCfg = require("TableCfg/CharasysCameraParamsCfg")

local FocusType = CameraControlDefine.FocusType

---@class EquipmentCameraControlDataLoader : CameraControlDataLoader
local EquipmentCameraControlDataLoader = LuaClass(CameraControlDataLoader, true)

function EquipmentCameraControlDataLoader:GetCameraControlParams(SkeletonName, InFocusType)
	if nil == self.CachedParams then
		-- 处理没通过New创建DataLoader的情况
		self.CachedParams = {}
	end

	if nil == InFocusType or InFocusType >= FocusType.Max then
		_G.FLOG_ERROR("Invalid camera control focus type")
		return nil
	end

	if nil ~= self.CachedParams[SkeletonName] and nil ~= self.CachedParams[SkeletonName][InFocusType] then
		return self.CachedParams[SkeletonName][InFocusType]
	end

	local CameraControlParams = CameraControlParams.New()
	local RawFocusData = nil
	-- UserData数据->表格数据
	if nil ~= self.UserData then
	end
	if nil == RawFocusData then
		local CfgData = CharasysCameraParamsCfg:FindCfg(string.format("SkeletonName = \"%s\"", SkeletonName))
		if nil == CfgData or nil == CfgData.CameraParams then
			return nil
		end
		RawFocusData = CfgData.CameraParams
		CameraControlParams.FocusEID = self:GetFocusEID(InFocusType)
	end

	self:TransformParamsData(RawFocusData, CameraControlParams)

	if nil == self.CachedParams[SkeletonName] then
		self.CachedParams[SkeletonName] = {}
	end
	self.CachedParams[SkeletonName][InFocusType] = CameraControlParams

	return CameraControlParams
end

return EquipmentCameraControlDataLoader
