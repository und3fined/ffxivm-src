local CameraSettingsDefine = require("Game/CameraSettings/CameraSettingsDefine")

local LSTR = _G.LSTR
local NumberType = CameraSettingsDefine.NumberType
local PropertyType = CameraSettingsDefine.PropertyType
local GroupType = CameraSettingsDefine.GroupType
local ViewDistancePropType = CameraSettingsDefine.ViewDistancePropType
local FOVPropType = CameraSettingsDefine.FOVPropType
local ReboundPropType = CameraSettingsDefine.ReboundPropType
local RotatePropType = CameraSettingsDefine.RotatePropType
local SurroundPropType = CameraSettingsDefine.SurroundPropType
local TargetOffsetPropType = CameraSettingsDefine.TargetOffsetPropType

local GroupConfigs =
{
	[GroupType.ViewDistance] =
	{
		GroupName = LSTR("视距"),
		Properties =
		{
			[ViewDistancePropType.MinValue] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("最小值"),
				MinValue = 0,
				MaxValue = 1000,
			},
			[ViewDistancePropType.MaxValue] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("最大值"),
				MinValue = 1000,
				MaxValue = 2000,
			},
			[ViewDistancePropType.ZoomSpeed] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("缩放速度"),
				MinValue = 0,
				MaxValue = 1000,
			},
		}
	},
	[GroupType.FOV] =
	{
		GroupName = "FOV",
		Properties =
		{
			[FOVPropType.DefaultValue] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("默认值"),
				MinValue = 10,
				MaxValue = 170,
			},
		}
	},
	[GroupType.Rebound] =
	{
		GroupName = LSTR("回弹"),
		Properties =
		{
			[ReboundPropType.DampValue] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("回弹速率"),
				MinValue = 0,
				MaxValue = 10,
			},
			[ReboundPropType.LagTime] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("延迟时长"),
				MinValue = 0,
				MaxValue = 2000,
				NumType = NumberType.Integer,
			}
		}
	},
	[GroupType.Rotate] =
	{
		GroupName = LSTR("旋转"),
		Properties =
		{
			[RotatePropType.RotateVelocity] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("旋转速率"),
				MinValue = 0,
				MaxValue = 10,
			},
		}
	},
	[GroupType.Surround] =
	{
		GroupName = LSTR("环绕"),
		Properties =
		{
			[SurroundPropType.Switch] =
			{
				PropType = PropertyType.Boolean,
				PropName = LSTR("开关"),
			},
			[SurroundPropType.MinDistAngle] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("最小距离下角度"),
				MinValue = 0,
				MaxValue = 180,
			},
			[SurroundPropType.MaxDistAngle] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("最大距离下角度"),
				MinValue = 0,
				MaxValue = 180,
			},
			[SurroundPropType.MaxDistance] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("距离阈值"),
				MinValue = 0,
				MaxValue = 100,
			},
			[SurroundPropType.RotateVelocity] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("旋转速率"),
				MinValue = 0,
				MaxValue = 10,
			},
			[SurroundPropType.FocusOffsetFactor] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("偏移系数"),
				MinValue = 0,
				MaxValue = 1,
			},
			[SurroundPropType.MinFocusRadius] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("偏移最小r"),
				MinValue = 0,
				MaxValue = 100,
			},
			[SurroundPropType.MaxFocusRadius] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("偏移最大r"),
				MinValue = 0,
				MaxValue = 100,
			},
			[SurroundPropType.MinFocusDistance] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("偏移最小d"),
				MinValue = 0,
				MaxValue = 100,
			},
			[SurroundPropType.MaxFocusDistance] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("偏移最大d"),
				MinValue = 0,
				MaxValue = 100,
			},
		}
	},
	[GroupType.TargetOffset] =
	{
		GroupName = LSTR("注视点偏移"),
		Properties =
		{
			[TargetOffsetPropType.InterpVelocity] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("插值速率"),
				MinValue = 0,
				MaxValue = 100,
			},
			[TargetOffsetPropType.DefaultOffsetZ] =
			{
				PropType = PropertyType.Scalar,
				PropName = LSTR("Z轴偏移(cm)"),
				MinValue = -200,
				MaxValue = 200,
			},
		}
	},
}

local CameraSettingsConfig =
{
	GroupConfigs = GroupConfigs
}

return CameraSettingsConfig