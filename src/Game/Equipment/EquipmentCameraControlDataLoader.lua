local LuaClass = require("Core/LuaClass")

local CameraControlDataLoader = require("Game/Common/Render2D/CameraControlDataLoader")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")
local CameraControlParams = require("Game/Common/Render2D/CameraControlParams")
local CharasysCameraParamsCfg = require("TableCfg/CharasysCameraParamsCfg")

local FocusType = CameraControlDefine.FocusType

---@class EquipmentCameraControlDataLoader : CameraControlDataLoader
local EquipmentCameraControlDataLoader = LuaClass(CameraControlDataLoader, true)

function CameraControlDataLoader:GetCameraControlParams(SkeletonName, InFocusType)
	if nil == InFocusType or InFocusType >= FocusType.Max then
		_G.FLOG_ERROR("Invalid camera control focus type")
		return nil
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
		RawFocusData.DefaultViewDistance = RawFocusData.DefaultViewDistance
		CameraControlParams.FocusEID = self:GetFocusEID(InFocusType)
	end

	CameraControlParams.DefaultViewDistance = RawFocusData.DefaultViewDistance
	CameraControlParams.MinPitch = RawFocusData.MinPitch or CameraControlParams.MinPitch
	CameraControlParams.MaxPitch = RawFocusData.MaxPitch or CameraControlParams.MaxPitch
	local RawParamsNames = {"NearCameraParams", "FarCameraParams"}
	local ControlParamsNames = {"MinViewDistParams", "MaxViewDistParams"}

	for Index = 1, 2 do
		local RawParams = RawFocusData[RawParamsNames[Index]]
		local ControlParams = CameraControlParams[ControlParamsNames[Index]]
		ControlParams.ViewDistance = RawParams.ViewDistance
		ControlParams.FOV = RawParams.FOV
		ControlParams.ZOffset = RawParams.ZOffset
		ControlParams.PitchOffset = RawParams.PitchOffset
	end
	return CameraControlParams
end

return EquipmentCameraControlDataLoader
