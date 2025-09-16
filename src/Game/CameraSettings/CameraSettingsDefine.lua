local PropertyType =
{
	Scalar = 1,
	Boolean = 2,
}

local GroupType =
{
	ViewDistance = 1,
	FOV = 2,
	Rebound = 3,
	Rotate = 4,
	Surround = 5,
	TargetOffset = 6,
}

local ViewDistancePropType =
{
	MinValue = 1,
	MaxValue = 2,
	ZoomSpeed = 3,
	CurrentValue = 4,
}

local FOVPropType =
{
	DefaultValue = 1,
}

local ReboundPropType =
{
	DampValue = 1,
	LagTime = 2,
}

local RotatePropType =
{
	RotateVelocity = 1,
}

local SurroundPropType =
{
	Switch = 1,
	MinDistAngle = 2,
	MaxDistAngle = 3,
	MaxDistance = 4,
	Delay = 5,
	RotateVelocity = 6,
	MinFocusDistance = 7,
	MaxFocusDistance = 8,
	MinFocusRadius = 9,
	MaxFocusRadius = 10,
	FocusOffsetFactor = 11,
}

local TargetOffsetPropType =
{
	InterpVelocity = 1,
	DefaultOffsetZ = 2,
}

local NumberType =
{
	Integer = 1,
	Float = 2,
}

local CameraSettingsDefine =
{
	PropertyType = PropertyType,
	GroupType = GroupType,
	ViewDistancePropType = ViewDistancePropType,
	FOVPropType = FOVPropType,
	ReboundPropType = ReboundPropType,
	RotatePropType = RotatePropType,
	SurroundPropType = SurroundPropType,
	TargetOffsetPropType = TargetOffsetPropType,
	NumberType = NumberType,
}

return CameraSettingsDefine