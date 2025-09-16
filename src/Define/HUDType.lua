---
--- Author: anypkvcai
--- DateTime: 2021-03-08 12:38
--- Description:
---

---@class HUDType : uint8
local HUDType = {

	None = 0,

	MonsterInfo 	= 1, -- 怪物头顶信息
	NPCInfo 		= 2, -- NPC头顶信息
	InteractObjInfo = 3, -- 场景交互物
	PlayerInfo 		= 4, -- 玩家头顶信息
	CompanionInfo 	= 5, -- 宠物头顶信息
	GatherInfo 		= 6, -- 采集物头顶信息
	BuddyInfo 		= 7, -- 搭档头顶信息
	HouseObjInfo 	= 8, -- 房屋物件信息

	MajorHPDamage1 = 21, -- 自己受到伤害 普通(技能名在左侧，伤害显示在右侧)
	MajorHPDamage2 = 22, -- 自己受到伤害 直击(技能名在左侧，伤害显示在右侧)
	MajorHPDamage3 = 23, -- 自己受到伤害 暴击(技能名在左侧，伤害显示在右侧)
	MajorHPDamage4 = 24, -- 自己受到伤害 直击暴击(技能名在左侧，伤害显示在右侧)
	MajorHPDamage5 = 25, -- 自己受到伤害 普通(无技能名，伤害显示在左侧)
	MajorHPDamage6 = 26, -- 自己受到伤害 直击(无技能名，伤害显示在左侧)
	MajorHPDamage7 = 27, -- 自己受到伤害 暴击(无技能名，伤害显示在左侧)
	MajorHPDamage8 = 28, -- 自己受到伤害 直击暴击(无技能名，伤害显示在左侧)
	--MajorHPDamage9 = 29, -- 自己受到伤害 持续性伤害

	MajorHPHeal1 = 31, -- 自己受到治疗 普通
	MajorHPHeal2 = 32, -- 自己受到治疗 直击
	MajorHPHeal3 = 33, -- 自己受到治疗 暴击
	--MajorHPHeal4 = 34, -- 自己受到治疗 持续性治疗

	-- MajorMPDamage1 	= 35, -- 自己受到魔法扣除
	-- MajorMPHeal1 	= 36, -- 自己受到魔法增加

	ActorHPHeal1 = 41, -- 队友受到治疗 普通
	ActorHPHeal2 = 42, -- 队友受到治疗 直击
	ActorHPHeal3 = 43, -- 队友受到治疗 暴击
	ActorHPHeal4 = 44, -- 队友受到治疗 持续性治疗

	MonsterHPDamage1 = 51, -- 怪物受到伤害 普通(技能名在左侧，伤害显示在右侧)
	MonsterHPDamage2 = 52, -- 怪物受到伤害 直击(技能名在左侧，伤害显示在右侧)
	MonsterHPDamage3 = 53, -- 怪物受到伤害 暴击(技能名在左侧，伤害显示在右侧)
	MonsterHPDamage4 = 54, -- 怪物受到伤害 直击暴击(技能名在左侧，伤害显示在右侧)
	MonsterHPDamage5 = 55, -- 怪物受到伤害 普通(无技能名，伤害显示在左侧)
	MonsterHPDamage6 = 56, -- 怪物受到伤害 直击(无技能名，伤害显示在左侧)
	MonsterHPDamage7 = 57, -- 怪物受到伤害 暴击(无技能名，伤害显示在左侧)
	MonsterHPDamage8 = 58, -- 怪物受到伤害 直击暴击(无技能名，伤害显示在左侧)
	MonsterHPDamage9 = 59, -- 怪物受到伤害 持续性伤害

	MajorDodge 		= 61, -- 自己闪避
	MajorSuperman 	= 62, -- 自己无敌
	MajorInvalid 	= 63, -- 自己无效

	MonsterDodge 	= 66, --怪物闪避
	MonsterSuperman = 67, --怪物无敌
	MonsterInvalid  = 68, --怪物无效

	MajorBufferAdd 		= 71, -- 自己添加增益buffer
	MajorDBufferAdd 	= 72, -- 自己添加减益buffer
	MajorBufferRemove 	= 73, -- 自己删除buffer

	ActorBufferAdd 		= 74, -- 队友添加buffer
	ActorBufferRemove 	= 75, -- 队友删除buffer

	MonsterBufferAdd 	= 76, -- 怪物添加buffer
	MonsterBufferRemove = 77, -- 怪物删除buffer

	---------------- Life Skill ----------------

	LifeSkillFlyText1 = 91,  -- 生活技能飘字，绿色普通
	LifeSkillFlyText2 = 92,  -- 生活技能飘字，绿色暴击
	LifeSkillFlyText3 = 93,  -- 生活技能飘字，蓝色普通
	LifeSkillFlyText4 = 94,  -- 生活技能飘字，蓝色暴击

	----------------

	BuoyQuest 				= 120, -- 任务主界面浮标指引。现在只有1个样式，将来有多个的时候再说
	BuoyAetherCurrent 		= 121, -- 风脉泉浮标
	BuoyMapFollow 			= 122, -- 自主追踪点浮标
	BuoyUnActivatedCrystal 	= 123, -- 未解锁水晶追踪浮标
	BuoyGoldGameNPC 		= 124, -- 金蝶地图机遇任务开启时NPC追踪浮标

	-- uint8 max 256
}

return HUDType