local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local MajorUtil = require("Utils/MajorUtil")
local CameraSettingsDefine = require("Game/CameraSettings/CameraSettingsDefine")

local GroupType = CameraSettingsDefine.GroupType
local ViewDistancePropType = CameraSettingsDefine.ViewDistancePropType
local FOVPropType = CameraSettingsDefine.FOVPropType
local ReboundPropType = CameraSettingsDefine.ReboundPropType
local RotatePropType = CameraSettingsDefine.RotatePropType
local SurroundPropType = CameraSettingsDefine.SurroundPropType
local TargetOffsetPropType = CameraSettingsDefine.TargetOffsetPropType
local LSTR = _G.LSTR
---@class CameraSettingsMgr : MgrBase
local CameraSettingsMgr = LuaClass(MgrBase)

function CameraSettingsMgr:OnInit()
	self.PropSetterMap =
	{
		[GroupType.ViewDistance] =
		{
			[ViewDistancePropType.MinValue] = _G.UE.UCameraControllComponent.SetMinCameraDistance,
			[ViewDistancePropType.MaxValue] = _G.UE.UCameraControllComponent.SetMaxCameraDistance,
			[ViewDistancePropType.ZoomSpeed] = _G.UE.UCameraControllComponent.SetZoomSpeed,
			[ViewDistancePropType.CurrentValue] = _G.UE.UCameraControllComponent.SetTargetArmLength,
		},
		[GroupType.FOV] =
		{
			[FOVPropType.DefaultValue] = _G.UE.UCameraControllComponent.SetDefaultFOVY
		},
		[GroupType.Rebound] =
		{
			[ReboundPropType.DampValue] = _G.UE.UCameraControllComponent.SetReboundVelocity,
			[ReboundPropType.LagTime] = _G.UE.UCameraControllComponent.SetReboundLagTime,
		},
		[GroupType.Rotate] =
		{
			[RotatePropType.RotateVelocity] = _G.UE.UCameraControllComponent.SetTurnSpeed,
		},
		[GroupType.Surround] =
		{
			[SurroundPropType.Switch] = _G.UE.UCameraControllComponent.SetSurroundEnabled,
			[SurroundPropType.MinDistAngle] = _G.UE.UCameraControllComponent.SetSurroundMinDistAngle,
			[SurroundPropType.MaxDistAngle] = _G.UE.UCameraControllComponent.SetSurroundMaxDistAngle,
			[SurroundPropType.MaxDistance] = _G.UE.UCameraControllComponent.SetMaxSurroundDistance,
			[SurroundPropType.RotateVelocity] = _G.UE.UCameraControllComponent.SetSurroundInterpSpeed,
			[SurroundPropType.FocusOffsetFactor] = _G.UE.UCameraControllComponent.SetSurroundOffsetFactor,
			[SurroundPropType.MinFocusRadius] = _G.UE.UCameraControllComponent.SetMinTargetRadiusForOffset,
			[SurroundPropType.MaxFocusRadius] = _G.UE.UCameraControllComponent.SetMaxTargetRadiusForOffset,
			[SurroundPropType.MinFocusDistance] = _G.UE.UCameraControllComponent.SetMinTargetDistForOffset,
			[SurroundPropType.MaxFocusDistance] = _G.UE.UCameraControllComponent.SetMaxTargetDistForOffset,
		},
		[GroupType.TargetOffset] =
		{
			[TargetOffsetPropType.InterpVelocity] = _G.UE.UCameraControllComponent.SetTargetOffsetInterpVelocity,
			[TargetOffsetPropType.DefaultOffsetZ] = _G.UE.UCameraControllComponent.SetDefaultTargetOffsetZ,
		},
	}
	self.PropGetterMap =
	{
		[GroupType.ViewDistance] =
		{
			[ViewDistancePropType.MinValue] = _G.UE.UCameraControllComponent.GetMinCameraDistance,
			[ViewDistancePropType.MaxValue] = _G.UE.UCameraControllComponent.GetMaxCameraDistance,
			[ViewDistancePropType.ZoomSpeed] = _G.UE.UCameraControllComponent.GetZoomSpeed,
			[ViewDistancePropType.CurrentValue] = _G.UE.UCameraControllComponent.GetTargetArmLength,
			
		},
		[GroupType.FOV] =
		{
			[FOVPropType.DefaultValue] = _G.UE.UCameraControllComponent.GetDefaultFOVY
		},
		[GroupType.Rebound] =
		{
			[ReboundPropType.DampValue] = _G.UE.UCameraControllComponent.GetReboundVelocity,
			[ReboundPropType.LagTime] = _G.UE.UCameraControllComponent.GetReboundLagTime,
		},
		[GroupType.Rotate] =
		{
			[RotatePropType.RotateVelocity] = _G.UE.UCameraControllComponent.GetTurnSpeed,
		},
		[GroupType.Surround] =
		{
			[SurroundPropType.Switch] = _G.UE.UCameraControllComponent.GetSurroundEnabled,
			[SurroundPropType.MinDistAngle] = _G.UE.UCameraControllComponent.GetSurroundMinDistAngle,
			[SurroundPropType.MaxDistAngle] = _G.UE.UCameraControllComponent.GetSurroundMaxDistAngle,
			[SurroundPropType.MaxDistance] = _G.UE.UCameraControllComponent.GetMaxSurroundDistance,
			[SurroundPropType.RotateVelocity] = _G.UE.UCameraControllComponent.GetSurroundInterpSpeed,
			[SurroundPropType.FocusOffsetFactor] = _G.UE.UCameraControllComponent.GetSurroundOffsetFactor,
			[SurroundPropType.MinFocusRadius] = _G.UE.UCameraControllComponent.GetMinTargetRadiusForOffset,
			[SurroundPropType.MaxFocusRadius] = _G.UE.UCameraControllComponent.GetMaxTargetRadiusForOffset,
			[SurroundPropType.MinFocusDistance] = _G.UE.UCameraControllComponent.GetMinTargetDistForOffset,
			[SurroundPropType.MaxFocusDistance] = _G.UE.UCameraControllComponent.GetMaxTargetDistForOffset,
		},
		[GroupType.TargetOffset] =
		{
			[TargetOffsetPropType.InterpVelocity] = _G.UE.UCameraControllComponent.GetTargetOffsetInterpVelocity,
			[TargetOffsetPropType.DefaultOffsetZ] = _G.UE.UCameraControllComponent.GetDefaultTargetOffsetZ,
		},
	}
end

function CameraSettingsMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.CameraSettingsUpdate, self.OnCameraSettingsUpdate)
end

function CameraSettingsMgr:OnCameraSettingsUpdate(Params)
	if nil == Params then
		return
	end

	self:SetCameraProperty(Params.Group, Params.Property, Params.Value)
end

function CameraSettingsMgr:SetCameraProperty(GroupKey, PropKey, Value)
	local CameraControlComp = MajorUtil.GetMajorCameraControlComponent()
	if nil == CameraControlComp then
		return
	end
	if nil == self.PropSetterMap[GroupKey] or nil == self.PropSetterMap[GroupKey][PropKey] then
		return
	end
	self.PropSetterMap[GroupKey][PropKey](CameraControlComp, Value)
end

function CameraSettingsMgr:GetCameraProperty(GroupKey, PropKey)
	local CameraControlComp = MajorUtil.GetMajorCameraControlComponent()
	if nil == CameraControlComp then
		return
	end

	if nil == self.PropGetterMap[GroupKey] or nil == self.PropGetterMap[GroupKey][PropKey] then
		return
	end
	return self.PropGetterMap[GroupKey][PropKey](CameraControlComp)
end

return CameraSettingsMgr