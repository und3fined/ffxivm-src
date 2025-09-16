---用于定义集合面板中活动节点的ID
local NodeIDDefine={
    -- 异界访客阶段1
	MysteriousVisitor = 2501210101,
    -- 异界访客阶段2
    MysteriousVisitor2 = 2501210102,
    -- 迷失企鹅大乱斗阶段1
	PenguinWars = 2501210103,
    -- 迷失企鹅大乱斗阶段2
    PenguinWars2 = 2501210104,
    -- -- 迷失企鹅大乱斗阶段3
    PenguinWars3 = 2501210105,
    -- 节日庆典阶段1
	Celebration = 2501210106,
    -- -- 节日庆典阶段2
    Celebration2 = 2501210107,
    SeasonShop = 2501210109,
    FatPenguin = 2501210110,
    ---视频配置节点
    VideoShow = 2501210112,
}

local TaskIDDefine = {
    ---异界访客叙事任务章节ID
    MysteriousVisitorTask = 22019,
    -- 迷失企鹅大乱斗叙事任务章节ID
    PenguinWarsTask = 22020,
    -- 节日庆典叙事任务章节ID
    CelebrationTask = 22021,
}
local OpsCeremonyDefine =
{
    NodeIDDefine = NodeIDDefine,
    TaskIDDefine = TaskIDDefine,
    ActivityID = 25012101,
    CelebrationActivityID = 25012102,
    PenguinWarsActivityID = 25012103,
    FatPenguinBlessActivityID = 25032605,
    PenguinWarsFateID = 2001,
    CelebrationStartPos = {x = 1156.8, y = 770.2},
    CelebrationMapID = 12001,
    PenguinPos = {x = 1007.7, y = 878.5},
    PenguinPosMapID = 12004,
}

return OpsCeremonyDefine