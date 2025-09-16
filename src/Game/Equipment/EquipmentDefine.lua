local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local AvatarPersonal = ProtoCommon.avatar_personal
local EquipPart = ProtoCommon.equip_part
local EquipmentType = ProtoRes.EquipmentType

local SuitIntegrityState =
{
	Integrated = 1,
	LackArmor = 2,
	LackWeapon = 3
}

local EndureState =
{
	Unavailable = 1,
	Normal = 2,
	Full = 3,
}

local WearableState =
{
	Unwearable = 1,
	OtherProfWearable = 2,
	Wearable = 3,
}

-- ProtoCommon.equip_part到显示顺序编号的映射
local EquipPartOrderMap =
{
	[EquipPart.EQUIP_PART_NONE] = 0,
	[EquipPart.EQUIP_PART_MASTER_HAND] = 1,
	[EquipPart.EQUIP_PART_SLAVE_HAND] = 2,
	[EquipPart.EQUIP_PART_HEAD] = 3,
	[EquipPart.EQUIP_PART_BODY] = 4,
	[EquipPart.EQUIP_PART_ARM] = 5,
	[EquipPart.EQUIP_PART_LEG] = 6,
	[EquipPart.EQUIP_PART_FEET] = 7,
	[EquipPart.EQUIP_PART_EAR] = 8,
	[EquipPart.EQUIP_PART_NECK] = 9,
	[EquipPart.EQUIP_PART_WRIST] = 10,
	[EquipPart.EQUIP_PART_LEFT_FINGER] = 11,
	[EquipPart.EQUIP_PART_RIGHT_FINGER] = 12,
}

-- ProtoCommon.equip_part 到 ProtoRes.EquipmentType 的映射
local EquipmentTypeMap =
{
	[EquipPart.EQUIP_PART_NONE] = EquipmentType.OTHER,
	[EquipPart.EQUIP_PART_MASTER_HAND] = EquipmentType.WEAPON_MASTER_HAND,
	[EquipPart.EQUIP_PART_SLAVE_HAND] = EquipmentType.WEAPON_SLAVE_HAND,
	[EquipPart.EQUIP_PART_HEAD] = EquipmentType.HEAD_ARMOUR,
	[EquipPart.EQUIP_PART_BODY] = EquipmentType.BODY_ARMOUR,
	[EquipPart.EQUIP_PART_ARM] = EquipmentType.ARM_ARMOUR,
	[EquipPart.EQUIP_PART_LEG] = EquipmentType.LEG_ARMOUR,
	[EquipPart.EQUIP_PART_FEET] = EquipmentType.FOOT_ARMOUR,
	[EquipPart.EQUIP_PART_EAR] = EquipmentType.EARRING,
	[EquipPart.EQUIP_PART_NECK] = EquipmentType.NECKLACE,
	[EquipPart.EQUIP_PART_LEFT_FINGER] = EquipmentType.RING_LEFT,
	[EquipPart.EQUIP_PART_RIGHT_FINGER] = EquipmentType.RING_RIGHT,
	[EquipPart.EQUIP_PART_WRIST] = EquipmentType.BRACELET,
	--[EquipPart.EQUIP_PART_FINGER] = EquipmentType.BRACELET,
	[EquipPart.EQUIP_PART_BODY_HAIR] = EquipmentType.NAKED_BODY_HAIR,
	[EquipPart.EQUIP_PART_BODY_HEAD] = EquipmentType.NAKED_BODY_HEAD,
	[EquipPart.EQUIP_PART_BODY_EAR] = EquipmentType.NAKED_BODY_EAR,
	[EquipPart.EQUIP_PART_BODY_TAIL] = EquipmentType.NAKED_BODY_TAIL,
}

-- ProtoCommon.equip_part 到 ProtoRes.avatar_personal 的映射
local AvatarPersonalMap =
{
	[EquipPart.EQUIP_PART_BODY_HAIR] = AvatarPersonal.AvatarPersonalHair,
	[EquipPart.EQUIP_PART_BODY_HEAD] = AvatarPersonal.AvatarFaceBase,
}

-- 装备模型ID的标准后缀长度
local EquipModelIDStandardLength = 4

local EquipmentDefine =
{
	SuitIntegrityState = SuitIntegrityState,
	EndureState = EndureState,
	WearableState = WearableState,
	EquipPartOrderMap = EquipPartOrderMap,
	ModelIDStandardLength = EquipModelIDStandardLength,
	EquipmentTypeMap = EquipmentTypeMap,
	AvatarPersonalMap = AvatarPersonalMap,
}

return EquipmentDefine