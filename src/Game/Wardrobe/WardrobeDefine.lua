local ProtoCommon = require("Protocol/ProtoCommon")
local EquipmentPartList = ProtoCommon.equip_part

local WardrobeDefine = {}

WardrobeDefine.RenderActorPath = "Class'/Game/UI/Render2D/Wardrobe/BP_Render2DLoginActor_%s.BP_Render2DLoginActor_%s_C'"
WardrobeDefine.LightConfig = {
	["e_c0101"] = 1,
}

WardrobeDefine.StainPanelOffsetY = 25
WardrobeDefine.UnlockPanelOffsetY = 65
WardrobeDefine.PresetPanelOffsetY = 55

-- 幻彩棱晶道具ID
WardrobeDefine.NormalItemID = 60700004
-- 特殊外观转换ID
WardrobeDefine.SpecialShiftID = 12190000

-- 
WardrobeDefine.UnStainedImg = "PaperSprite'/Game/UI/Atlas/Wardrobe/Frames/UI_Wardrobe_Img_BallColor1_png.UI_Wardrobe_Img_BallColor1_png'"
WardrobeDefine.StainedImg = "PaperSprite'/Game/UI/Atlas/Wardrobe/Frames/UI_Wardrobe_Img_BallColor1_png.UI_Wardrobe_Img_BallColor0_png'"

-- 红点
WardrobeDefine.RedDotList = {
	QuickUnlock = 19002,
}


WardrobeDefine.ProfClass = {
	ClassType = 1,			--protocommon.class_type
	AdvanceType = 2,		--进阶职业
	BasicType = 3,			--纯职业
}

WardrobeDefine.ClassType = {
	ProtoCommon.class_type.CLASS_TYPE_TANK,
	ProtoCommon.class_type.CLASS_TYPE_NEAR, --近战
	ProtoCommon.class_type.CLASS_TYPE_FAR, --远程
	ProtoCommon.class_type.CLASS_TYPE_MAGIC, --魔法
	ProtoCommon.class_type.CLASS_TYPE_HEALTH, --治疗
	ProtoCommon.class_type.CLASS_TYPE_CARPENTER, --能工巧匠
	ProtoCommon.class_type.CLASS_TYPE_EARTHMESSENGER , --大地使者
}

WardrobeDefine.ClassTypeData = {}

-- 衣橱染色模式，普通，预览，试染
WardrobeDefine.StainType = {
	Normal = 1,
	OnlyLook = 2,
	TryStain = 3,
}

--衣橱展示模型类型
WardrobeDefine.ShowModelType = {
	All = 1,
	Part = 2,
}

-- 对应职业外观解锁外观高亮值,
WardrobeDefine.ProfHighValue = 100

WardrobeDefine.FilterProfList = {
	{ ClassType = WardrobeDefine.ProfClass.ClassType, ProfID = -1},
	{ ClassType = WardrobeDefine.ProfClass.ClassType, ProfID = ProtoCommon.class_type.CLASS_TYPE_NULL},
	{ ClassType = WardrobeDefine.ProfClass.ClassType, ProfID = ProtoCommon.class_type.CLASS_TYPE_TANK},
	{ ClassType = WardrobeDefine.ProfClass.ClassType, ProfID = ProtoCommon.class_type.CLASS_TYPE_NEAR},
	{ ClassType = WardrobeDefine.ProfClass.ClassType, ProfID = ProtoCommon.class_type.CLASS_TYPE_FAR},
	{ ClassType = WardrobeDefine.ProfClass.ClassType, ProfID = ProtoCommon.class_type.CLASS_TYPE_MAGIC},
	{ ClassType = WardrobeDefine.ProfClass.ClassType, ProfID = ProtoCommon.class_type.CLASS_TYPE_HEALTH},
	{ ClassType = WardrobeDefine.ProfClass.ClassType, ProfID = ProtoCommon.class_type.CLASS_TYPE_CARPENTER},
	{ ClassType = WardrobeDefine.ProfClass.ClassType, ProfID = ProtoCommon.class_type.CLASS_TYPE_EARTHMESSENGER},
	{ ClassType = WardrobeDefine.ProfClass.AdvanceType, ProfID = ProtoCommon.prof_type.PROF_TYPE_GLADIATOR},
	{ ClassType = WardrobeDefine.ProfClass.AdvanceType, ProfID = ProtoCommon.prof_type.PROF_TYPE_MARAUDER},
	{ ClassType = WardrobeDefine.ProfClass.AdvanceType, ProfID = ProtoCommon.prof_type.PROF_TYPE_PUGILIST},
	{ ClassType = WardrobeDefine.ProfClass.AdvanceType, ProfID = ProtoCommon.prof_type.PROF_TYPE_LANCER},
	{ ClassType = WardrobeDefine.ProfClass.AdvanceType, ProfID = ProtoCommon.prof_type.PROF_TYPE_ROGUE},
	{ ClassType = WardrobeDefine.ProfClass.AdvanceType, ProfID = ProtoCommon.prof_type.PROF_TYPE_ARCHER},
	{ ClassType = WardrobeDefine.ProfClass.AdvanceType, ProfID = ProtoCommon.prof_type.PROF_TYPE_THAUMATURGE},
	{ ClassType = WardrobeDefine.ProfClass.AdvanceType, ProfID = ProtoCommon.prof_type.PROF_TYPE_ARCANIST},
	{ ClassType = WardrobeDefine.ProfClass.AdvanceType, ProfID = ProtoCommon.prof_type.PROF_TYPE_CONJURER},
	{ ClassType = WardrobeDefine.ProfClass.BasicType, ProfID = ProtoCommon.prof_type.PROF_TYPE_SCHOLAR},
	{ ClassType = WardrobeDefine.ProfClass.BasicType, ProfID = ProtoCommon.prof_type.PROF_TYPE_BLACKSMITH},
	{ ClassType = WardrobeDefine.ProfClass.BasicType, ProfID = ProtoCommon.prof_type.PROF_TYPE_ARMOR},
	{ ClassType = WardrobeDefine.ProfClass.BasicType, ProfID = ProtoCommon.prof_type.PROF_TYPE_CARPENTER},
	{ ClassType = WardrobeDefine.ProfClass.BasicType, ProfID = ProtoCommon.prof_type.PROF_TYPE_GOLDSMITH},
	{ ClassType = WardrobeDefine.ProfClass.BasicType, ProfID = ProtoCommon.prof_type.PROF_TYPE_WEAVER},
	{ ClassType = WardrobeDefine.ProfClass.BasicType, ProfID = ProtoCommon.prof_type.PROF_TYPE_LEATHER_WORK},
	{ ClassType = WardrobeDefine.ProfClass.BasicType, ProfID = ProtoCommon.prof_type.PROF_TYPE_ALCHEMIST},
	{ ClassType = WardrobeDefine.ProfClass.BasicType, ProfID = ProtoCommon.prof_type.PROF_TYPE_CULINARIAN},
	{ ClassType = WardrobeDefine.ProfClass.BasicType, ProfID = ProtoCommon.prof_type.PROF_TYPE_MINER},
	{ ClassType = WardrobeDefine.ProfClass.BasicType, ProfID = ProtoCommon.prof_type.PROF_TYPE_BOTANIST},
	{ ClassType = WardrobeDefine.ProfClass.BasicType, ProfID = ProtoCommon.prof_type.PROF_TYPE_FISHER},
}

WardrobeDefine.EquipmentTab = {
    EquipmentPartList.EQUIP_PART_MASTER_HAND,   -- 主手
    EquipmentPartList.EQUIP_PART_SLAVE_HAND,	-- 副手
    EquipmentPartList.EQUIP_PART_HEAD,	-- 头部
    EquipmentPartList.EQUIP_PART_BODY,	-- 身体
    EquipmentPartList.EQUIP_PART_ARM,	-- 手部
    EquipmentPartList.EQUIP_PART_LEG,	-- 腿部
    EquipmentPartList.EQUIP_PART_FEET,	-- 脚部
    EquipmentPartList.EQUIP_PART_EAR,	-- 耳部
    EquipmentPartList.EQUIP_PART_NECK,	-- 颈部
	EquipmentPartList.EQUIP_PART_WRIST, -- 腕部
    EquipmentPartList.EQUIP_PART_LEFT_FINGER,	-- 左指
    EquipmentPartList.EQUIP_PART_RIGHT_FINGER ,	-- 右指
}

WardrobeDefine.StainPartType = {
	[EquipmentPartList.EQUIP_PART_HEAD] = _G.UE.EAvatarPartType.HEAD_ARMOUR,
	[EquipmentPartList.EQUIP_PART_BODY] = _G.UE.EAvatarPartType.BODY_ARMOUR ,
	[EquipmentPartList.EQUIP_PART_ARM] = _G.UE.EAvatarPartType.ARM_ARMOUR ,
	[EquipmentPartList.EQUIP_PART_LEG] = _G.UE.EAvatarPartType.LEG_ARMOUR ,
	[EquipmentPartList.EQUIP_PART_FEET] = _G.UE.EAvatarPartType.FOOT_ARMOUR ,
}

WardrobeDefine.ProfInfo = {
    [ProtoCommon.prof_type.PROF_TYPE_GLADIATOR] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_GLA.UI_Wardrobe_Icon_Job_GLA'"}, --剑术师
    [ProtoCommon.prof_type.PROF_TYPE_MARAUDER] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_MRD.UI_Wardrobe_Icon_Job_MRD'"},	-- 斧术师
	[ProtoCommon.prof_type.PROF_TYPE_PUGILIST] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_PGL.UI_Wardrobe_Icon_Job_PGL'"},	-- 格斗家
	[ProtoCommon.prof_type.PROF_TYPE_LANCER] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_LNC.UI_Wardrobe_Icon_Job_LNC'"},	-- 枪术师
	[ProtoCommon.prof_type.PROF_TYPE_ROGUE] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_ROG.UI_Wardrobe_Icon_Job_ROG'"},	-- 双剑师
	[ProtoCommon.prof_type.PROF_TYPE_ARCHER] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_ARC.UI_Wardrobe_Icon_Job_ARC'"},	-- 弓箭手
	[ProtoCommon.prof_type.PROF_TYPE_THAUMATURGE] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_THM.UI_Wardrobe_Icon_Job_THM'"},	-- 咒术师
	[ProtoCommon.prof_type.PROF_TYPE_ARCANIST] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_ACN.UI_Wardrobe_Icon_Job_ACN'"},	-- 秘术师
	[ProtoCommon.prof_type.PROF_TYPE_CONJURER] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_CNJ.UI_Wardrobe_Icon_Job_CNJ'"},	-- 幻术师
	[ProtoCommon.prof_type.PROF_TYPE_PALADIN] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_PLD.UI_Wardrobe_Icon_Job_PLD'"},	-- 骑士
	[ProtoCommon.prof_type.PROF_TYPE_WARRIOR] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_WAR.UI_Wardrobe_Icon_Job_WAR'"},	-- 战士
	[ProtoCommon.prof_type.PROF_TYPE_NINJA] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_NIN.UI_Wardrobe_Icon_Job_NIN'"},	-- 忍者
	[ProtoCommon.prof_type.PROF_TYPE_DRAGOON] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_DRG.UI_Wardrobe_Icon_Job_DRG'"},-- 龙骑士
	[ProtoCommon.prof_type.PROF_TYPE_MONK] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_MNK.UI_Wardrobe_Icon_Job_MNK'"},	-- 武僧
	[ProtoCommon.prof_type.PROF_TYPE_BARD] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_BRD.UI_Wardrobe_Icon_Job_BRD'"},	-- 吟游诗人
	[ProtoCommon.prof_type.PROF_TYPE_BLACKMAGE] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_BLM.UI_Wardrobe_Icon_Job_BLM'"},	-- 黑魔法师
	[ProtoCommon.prof_type.PROF_TYPE_SUMMONER] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_SMN.UI_Wardrobe_Icon_Job_SMN'"},	-- 召唤师
	[ProtoCommon.prof_type.PROF_TYPE_WHITEMAGE] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_WHM.UI_Wardrobe_Icon_Job_WHM'"},	-- 白魔法师
	[ProtoCommon.prof_type.PROF_TYPE_SCHOLAR] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_SCH.UI_Wardrobe_Icon_Job_SCH'"},		-- 学者
	[ProtoCommon.prof_type.PROF_TYPE_BLACKSMITH] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_BSM.UI_Wardrobe_Icon_Job_BSM'"},	-- 锻铁匠
	[ProtoCommon.prof_type.PROF_TYPE_ARMOR] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_ARM.UI_Wardrobe_Icon_Job_ARM'"},	-- 铸甲匠
	[ProtoCommon.prof_type.PROF_TYPE_CARPENTER] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_CRP.UI_Wardrobe_Icon_Job_CRP'"},	-- 刻木匠
	[ProtoCommon.prof_type.PROF_TYPE_GOLDSMITH] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_GSM.UI_Wardrobe_Icon_Job_GSM'"},	-- 雕金匠
	[ProtoCommon.prof_type.PROF_TYPE_WEAVER] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_WVR.UI_Wardrobe_Icon_Job_WVR'"},	-- 裁衣匠
	[ProtoCommon.prof_type.PROF_TYPE_LEATHER_WORK] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_LTW.UI_Wardrobe_Icon_Job_LTW'"},	-- 制革匠
	[ProtoCommon.prof_type.PROF_TYPE_ALCHEMIST] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_ALC.UI_Wardrobe_Icon_Job_ALC'"},	-- 炼金术士
	[ProtoCommon.prof_type.PROF_TYPE_CULINARIAN] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_CUL.UI_Wardrobe_Icon_Job_CUL'"},	-- 烹调师
	[ProtoCommon.prof_type.PROF_TYPE_MINER] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_MIN.UI_Wardrobe_Icon_Job_MIN'"},	-- 采矿工
	[ProtoCommon.prof_type.PROF_TYPE_BOTANIST] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_BTN.UI_Wardrobe_Icon_Job_BTN'"},	-- 园艺工
	[ProtoCommon.prof_type.PROF_TYPE_FISHER] = { CollectIcon = "Texture2D'/Game/UI/Texture/Wardrobe/UI_Wardrobe_Icon_Job_FSH.UI_Wardrobe_Icon_Job_FSH'"},	-- 捕鱼人
}

WardrobeDefine.TxtColor = {
    WarningColor = "#F5514FFF",
    NormalColor = "#D5C6A8FF",
}

WardrobeDefine.SuitTabList = {
	{ID = 1, Name = 1080037, IconPathNormal = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Noraml.UI_Icon_Tab_Bag_Equip_All_Noraml'", IconPathSelect = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Select.UI_Icon_Tab_Bag_Equip_All_Select'"},
	{ID = 2, Name = 1080124, IconPathNormal = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Body_Noraml.UI_Icon_Tab_Bag_Equip_Body_Noraml'", IconPathSelect = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Body_Select.UI_Icon_Tab_Bag_Equip_Body_Select'"},
	{ID = 3, Name = 1080125, IconPathNormal = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Appearance_Noraml.UI_Icon_Tab_Bag_Equip_Appearance_Noraml'", IconPathSelect = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Appearance_Select.UI_Icon_Tab_Bag_Equip_Appearance_Select'"},
}

WardrobeDefine.InitPresetsUnlockNum = 5
WardrobeDefine.MaxPresetsNum = 20

WardrobeDefine.EquipOrCanPreviewErrorType = {
	None = 0,
	Race = 1,
	Gender = 2,
	Prof = 3,
	Level = 4,
}

--TODO[chaooren]4.20 tips后续换为tip id
WardrobeDefine.EquipOrCanPreviewErrorTips = {
	[WardrobeDefine.EquipOrCanPreviewErrorType.Race] = 1080116,
	[WardrobeDefine.EquipOrCanPreviewErrorType.Gender] = 1080117,
	[WardrobeDefine.EquipOrCanPreviewErrorType.Prof] = 1080118,
	[WardrobeDefine.EquipOrCanPreviewErrorType.Level] = 1080119,
}

WardrobeDefine.ColorTypeList = {2,3,4,5,6,7,1,8}

return WardrobeDefine