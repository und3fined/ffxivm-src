
local ProtoCommon = require("Protocol/ProtoCommon")
local LuaClass = require("Core/LuaClass")

--人男-中原之民
local CameraFocusCfgMap_c0101 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -30, Distance = 120, Pitch = 0, UIX = -700.0, UIY = -70.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -35, Distance = 380, Pitch = 0, UIX = -700.0, UIY = -190.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -60, Distance = 120, Pitch = 0, UIX = -750.0, UIY = 120.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = -30, Distance = 270, Pitch = 0, UIX = -820.0, UIY = 0.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = -30, Distance = 250, Pitch = 0, UIX = -860.0, UIY = 480.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

--人女-中原之民
local CameraFocusCfgMap_c0201 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -30, Distance = 120, Pitch = 0.0, UIX = -700.0, UIY = -50.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -35, Distance = 350, Pitch = 0, UIX = -700.0, UIY = -190.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -60, Distance = 100, Pitch = 0, UIX = -750.0, UIY = 120.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = -30, Distance = 270, Pitch = 0, UIX = -820.0, UIY = 20.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = -30, Distance = 260, Pitch = 0, UIX = -820.0, UIY = 450.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

--人男-高地之民
local CameraFocusCfgMap_c0301 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -30, Distance = 130, Pitch = 0, UIX = -700.0, UIY = -70.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -35, Distance = 420, Pitch = 0, UIX = -700.0, UIY = -190.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -60, Distance = 130, Pitch = 0, UIX = -750.0, UIY = 120.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = -30, Distance = 300, Pitch = 0, UIX = -820.0, UIY = 0.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = -30, Distance = 280, Pitch = 0, UIX = -860.0, UIY = 480.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

--人女-高地之民
local CameraFocusCfgMap_c0401 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -30, Distance = 120, Pitch = 0.0, UIX = -700.0, UIY = -50.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -35, Distance = 390, Pitch = 0, UIX = -700.0, UIY = -190.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -60, Distance = 120, Pitch = 0, UIX = -730.0, UIY = 120.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = -30, Distance = 300, Pitch = 0, UIX = -830.0, UIY = 20.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = -40, Distance = 270, Pitch = 0, UIX = -820.0, UIY = 460.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

--猫男-逐日之民
local CameraFocusCfgMap_c0701 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -30, Distance = 120, Pitch = 0.0, UIX = -700.0, UIY = -50.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -15, Distance = 360, Pitch = 0, UIX = -720.0, UIY = -190.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -40, Distance = 110, Pitch = 0, UIX = -740.0, UIY = 120.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = -15, Distance = 270, Pitch = 0, UIX = -840.0, UIY = 20.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = -30, Distance = 230, Pitch = 0, UIX = -870.0, UIY = 460.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

--猫女-逐日之民
local CameraFocusCfgMap_c0801 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -35, Distance = 120, Pitch = 0.0, UIX = -720.0, UIY = -70.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -20, Distance = 330, Pitch = 0, UIX = -720.0, UIY = -190.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -60, Distance = 100, Pitch = 0, UIX = -740.0, UIY = 90.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = -10, Distance = 270, Pitch = 0, UIX = -840.0, UIY = 10.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = -50, Distance = 235, Pitch = 0, UIX = -870.0, UIY = 460.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

--鲁加男-北洋之民
local CameraFocusCfgMap_c0901 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -30, Distance = 160, Pitch = 0.0, UIX = -710.0, UIY = -90.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -30, Distance = 510, Pitch = 0, UIX = -710.0, UIY = -200.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -40, Distance = 180, Pitch = 0, UIX = -730.0, UIY = 90.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = 20, Distance = 320, Pitch = 0, UIX = -920.0, UIY = 50.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = -50, Distance = 300, Pitch = 0, UIX = -900.0, UIY = 430.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

--鲁加女-北洋之民
local CameraFocusCfgMap_c1001 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -35, Distance = 130, Pitch = 0.0, UIX = -700.0, UIY = -50.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -30, Distance = 440, Pitch = 0, UIX = -720.0, UIY = -170.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -80, Distance = 140, Pitch = 0, UIX = -750.0, UIY = 100.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = -40, Distance = 360, Pitch = 0, UIX = -840.0, UIY = 20.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = -60, Distance = 310, Pitch = 0, UIX = -860.0, UIY = 460.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

--拉拉肥男-平原之民
local CameraFocusCfgMap_c1101 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -30, Distance = 120, Pitch = 0.0, UIX = -700.0, UIY = -20.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -30, Distance = 240, Pitch = 0, UIX = -720.0, UIY = -100.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -50, Distance = 50, Pitch = 0, UIX = -760.0, UIY = 30.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = 0, Distance = 120, Pitch = 0, UIX = -820.0, UIY = 100.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = 0, Distance = 110, Pitch = 0, UIX = -960.0, UIY = 390.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

--精灵男-森林之民
local CameraFocusCfgMap_c0501 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -25, Distance = 130, Pitch = 0.0, UIX = -700.0, UIY = -70.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -10, Distance = 440, Pitch = 0, UIX = -700.0, UIY = -180.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -40, Distance = 130, Pitch = 0, UIX = -750.0, UIY = 140.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = 0, Distance = 330, Pitch = 0, UIX = -800.0, UIY = 30.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = 0, Distance = 290, Pitch = 0, UIX = -850.0, UIY = 480.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

--精灵女-森林之民
local CameraFocusCfgMap_c0601 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -25, Distance = 120, Pitch = 0.0, UIX = -700.0, UIY = -45.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -15, Distance = 400, Pitch = 0, UIX = -700.0, UIY = -180.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -80, Distance = 130, Pitch = 0, UIX = -750.0, UIY = 100.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = -20, Distance = 350, Pitch = 0, UIX = -800.0, UIY = 30.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = -20, Distance = 310, Pitch = 0, UIX = -850.0, UIY = 420.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

--硌狮男-掠日之民
local CameraFocusCfgMap_c1501 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -30, Distance = 200, Pitch = 0.0, UIX = -710.0, UIY = -130.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -10, Distance = 460, Pitch = 0, UIX = -710.0, UIY = -180.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -30, Distance = 160, Pitch = 0, UIX = -760.0, UIY = 90.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = -30, Distance = 260, Pitch = 0, UIX = -900.0, UIY = 10.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = -40, Distance = 270, Pitch = 0, UIX = -940.0, UIY = 430.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

--敖龙女-晨曦之民
local CameraFocusCfgMap_c1401 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -35, Distance = 110, Pitch = 0.0, UIX = -700.0, UIY = -50.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -40, Distance = 335, Pitch = 0, UIX = -730.0, UIY = -200.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -90, Distance = 95, Pitch = 0, UIX = -730.0, UIY = 80.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = -5, Distance = 260, Pitch = 0, UIX = -830.0, UIY = 10.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = -35, Distance = 230, Pitch = 0, UIX = -880.0, UIY = 450.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

--敖龙男-晨曦之民
local CameraFocusCfgMap_c1301 = 
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = {BackAll = true, HoldWeapon = true, SocketName = "", Yaw = 0, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = {BackAll = false, HoldWeapon = false, SocketName = "head_M", Yaw = -30, Distance = 160, Pitch = 0.0, UIX = -700.0, UIY = -70.0},
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = {BackAll = false, HoldWeapon = false, SocketName = "spine3_M", Yaw = -30, Distance = 460, Pitch = 0, UIX = -720.0, UIY = -200.0},
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = {BackAll = false, HoldWeapon = false, SocketName = "wrist_R", Yaw = -50, Distance = 140, Pitch = 0, UIX = -750.0, UIY = 90.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = {BackAll = false, HoldWeapon = false, SocketName = "knee_R", Yaw = -15, Distance = 340, Pitch = 0, UIX = -800.0, UIY = 20.0},
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = {BackAll = false, HoldWeapon = false, SocketName = "toes_R", Yaw = 15, Distance = 310, Pitch = 0, UIX = -860.0, UIY = 460.0},
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = {BackAll = true, HoldWeapon = false, SocketName = "neck_M", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_L", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = {BackAll = true, HoldWeapon = false, SocketName = "wrist_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = {BackAll = true, HoldWeapon = false, SocketName = "elbow_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = {BackAll = false, HoldWeapon = false, SocketName = "ear_R", Yaw = -45, Distance = 500, Pitch = 0, UIX = -938.0, UIY = -92.0},
}

---@class CameraFocusCfgMap
local CameraFocusCfgMap = LuaClass()

function CameraFocusCfgMap:Ctor()
    
end

function CameraFocusCfgMap:SetAssetUserData(UserData)
	self.UserData = UserData
end

function CameraFocusCfgMap:GetCfgByRaceAndProf(InRaceID, InProfID, SlotType)
	local PartConfig = nil
	if self.UserData ~= nil and self.UserData.PartConfig ~= nil then
		-- 优先查找Configs
		local Params = _G.UE.FEquipCameraFocusParams()
		if self.UserData:FindParams(1 / _G.UE.UCameraMgr.Get():GetAspectRatio(), InProfID, SlotType, Params) then
			return Params
		end

		-- 其次查找ProfConfig
		if nil ~= InProfID and nil ~= self.UserData.ProfConfig then
			local ProfConfig = self.UserData.ProfConfig:FindRef(InProfID)
			if nil ~= ProfConfig and nil ~= ProfConfig.PartConfig then
				PartConfig = ProfConfig.PartConfig:FindRef(SlotType)
				if nil ~= PartConfig then
					return PartConfig
				end
			end
		end

		-- 最终查找PartConfig
		PartConfig = self.UserData.PartConfig:FindRef(SlotType)
		if nil ~= PartConfig then
			return PartConfig
		end
	end

    local Table = nil ~= InRaceID and _G["CameraFocusCfgMap_"..InRaceID] or nil
    if Table == nil then
        Table = CameraFocusCfgMap_c0101
    end
    return Table[SlotType]
end

function CameraFocusCfgMap:GetSpringArmDistance(InAttachType)
	local CameraMgr = _G.UE.UCameraMgr.Get()
	local Scale = 1
    if CameraMgr ~= nil then
        Scale = CameraMgr:GetRatioScale()
    end
	if self.UserData == nil or not _G.UE.UCommonUtil.IsObjectValid(self.UserData) then
		return 0
	end
    return self.UserData.OriginDistance * Scale
end

function CameraFocusCfgMap:GetSpringArmOriginX(InAttachType)
	if self.UserData == nil then
		return 0
	end
	return self.UserData.OriginX
end

function CameraFocusCfgMap:GetSpringArmOriginY(InAttachType)
	if self.UserData == nil then
		return 0
	end
    return self.UserData.OriginY
end

function CameraFocusCfgMap:GetSpringArmOriginZ(InAttachType)
	if self.UserData == nil then
		return 0
	end
    return self.UserData.OriginZ
end

function CameraFocusCfgMap:GetOriginFOV(InAttachType)
	if self.UserData == nil then
		return 0
	end
    return self.UserData.OriginFOV
end

function CameraFocusCfgMap:GetLeftDefaultFOV(InAttachType)
	if self.UserData == nil then
		return 0
	end
	if(self.UserData.LeftDefaultFOV == nil or self.UserData.LeftDefaultFOV == 0) then
		return self:GetOriginFOV(InAttachType)
	end
    return self.UserData.LeftDefaultFOV
end

function CameraFocusCfgMap:GetMainAttrFOV(InAttachType)
	if self.UserData == nil then
		return 0
	end
	if(self.UserData.MainAttrFOV == nil or self.UserData.MainAttrFOV == 0) then
		return self:GetOriginFOV(InAttachType)
	end
    return self.UserData.MainAttrFOV
end

return CameraFocusCfgMap