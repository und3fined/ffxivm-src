local LuaClass = require("Core/LuaClass")

local CameraControlParams = require("Game/Common/Render2d/CameraControlParams")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")
local CharacreateCameraTypeCfg = require("TableCfg/CharacreateCameraTypeCfg")
local CharacreateCameraParamsCfg = require("TableCfg/CharacreateCameraParamsCfg")

local FocusType = CameraControlDefine.FocusType

---@class CameraControlDataLoader
local CameraControlDataLoader = LuaClass()

function CameraControlDataLoader:Ctor()
	self.UserData = nil
	self.CachedParams = {}
end

function CameraControlDataLoader:SetUserData(UserData)
	self.UserData = UserData
end

function CameraControlDataLoader:GetCameraControlParams(SkeletonName, InFocusType)
	if nil == InFocusType or InFocusType >= FocusType.Max then
		_G.FLOG_ERROR("Invalid camera control focus type")
		return nil
	end

	local CameraControlParams = CameraControlParams.New()
	local RawFocusData = nil
	-- UserData数据->表格数据
	if nil ~= self.UserData then
		RawFocusData = self.UserData.CameraControlParamsMap:FindRef(InFocusType)
		CameraControlParams.FocusEID = RawFocusData and RawFocusData.FocusEID or ""
	end
	if nil == RawFocusData then
		local CfgData = CharacreateCameraParamsCfg:FindCfg(string.format("SkeletonName = \"%s\"", SkeletonName))
		if nil == CfgData or nil == CfgData.CameraParamsList then
			return nil
		end
		RawFocusData = CfgData.CameraParamsList[InFocusType]
		CameraControlParams.FocusEID = CharacreateCameraTypeCfg:FindValue(InFocusType, "EID")
	end

	self:TransformParamsData(RawFocusData, CameraControlParams)

	return CameraControlParams
end

function CameraControlDataLoader:GetFocusEID(InFocusType)
	return CharacreateCameraTypeCfg:FindValue(InFocusType, "EID")
end

-- 将表格或者UserData数据转换为CameraControlParams
function CameraControlDataLoader:TransformParamsData(RawFocusData, OutCameraControlParams)
	if nil == RawFocusData or nil == OutCameraControlParams then
		return
	end
	OutCameraControlParams.DefaultViewDistance = RawFocusData.DefaultViewDistance
	OutCameraControlParams.MinPitch = RawFocusData.MinPitch or OutCameraControlParams.MinPitch
	OutCameraControlParams.MaxPitch = RawFocusData.MaxPitch or OutCameraControlParams.MaxPitch
	local RawParamsNames = {"NearCameraParams", "FarCameraParams"}
	local ControlParamsNames = {"MinViewDistParams", "MaxViewDistParams"}

	for Index = 1, 2 do
		local RawParams = RawFocusData[RawParamsNames[Index]]
		local ControlParams = OutCameraControlParams[ControlParamsNames[Index]]
		ControlParams.ViewDistance = RawParams.ViewDistance
		ControlParams.FOV = RawParams.FOV
		ControlParams.ZOffset = RawParams.ZOffset
		ControlParams.PitchOffset = RawParams.PitchOffset
	end
end

return CameraControlDataLoader
