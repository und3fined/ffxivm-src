
local ProtoCommon = require("Protocol/ProtoCommon")
local MagicsparAttrName = {
	[ProtoCommon.attr_type.attr_critical] = _G.LSTR(1060032), -- 暴击
	[ProtoCommon.attr_type.attr_direct_atk] = _G.LSTR(1060033), -- 直击
	[ProtoCommon.attr_type.attr_belief] = _G.LSTR(1060034), -- 信念
	[ProtoCommon.attr_type.attr_quick] = _G.LSTR(1060035), -- 急速
	[ProtoCommon.attr_type.attr_gp_max] = _G.LSTR(1060036), -- 采集力
	[ProtoCommon.attr_type.attr_perception] = _G.LSTR(1060037), -- 鉴别力
	[ProtoCommon.attr_type.attr_gathering] = _G.LSTR(1060038), -- 获得力
	[ProtoCommon.attr_type.attr_mk_max] = _G.LSTR(1060039), -- 制作力
	[ProtoCommon.attr_type.attr_produce_precision] = _G.LSTR(1060040), -- 加工精度
	[ProtoCommon.attr_type.attr_work_precision] = _G.LSTR(1060041), -- 作业精度

}
local MagicsparEquipSlot =
{
	[1] = ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND,
	[2] = ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND,
	[3] = ProtoCommon.equip_part.EQUIP_PART_HEAD,
	[4] = ProtoCommon.equip_part.EQUIP_PART_EAR,
	[5] = ProtoCommon.equip_part.EQUIP_PART_BODY ,
	[6] = ProtoCommon.equip_part.EQUIP_PART_NECK,
	[7] = ProtoCommon.equip_part.EQUIP_PART_ARM,
	[8] = ProtoCommon.equip_part.EQUIP_PART_WRIST,
	[9] = ProtoCommon.equip_part.EQUIP_PART_LEG,
	[10] = ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER,
	[11] = ProtoCommon.equip_part.EQUIP_PART_FEET,
	[12] = ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER,
}
local MagicsparDefine = {
	RenderActorPath = "Blueprint'/Game/UMG/3DUI/MJS/BP/BP_MJS_MAIN.BP_MJS_MAIN_C'",
	BanBtnClickInterval = 500, -- 禁忌镶嵌按钮响应间隔ms
	MagicsparAttrName = MagicsparAttrName,
	MagicsparEquipSlot = MagicsparEquipSlot,
}

return MagicsparDefine