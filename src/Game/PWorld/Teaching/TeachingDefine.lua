local ProtoCommon = require("Protocol/ProtoCommon")

local MainTabs = {
    {
        Index = 1,
        Name = LSTR(890011),
    },
    {
        Index = 2,
        Name = LSTR(890012),
    },
}

local JobTypeInfos = {
    {
        Name = LSTR(30056),--防护职业
        Icon = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900142.UI_Icon_900142'",
    },
    {
        Name = LSTR(30057),--治疗职业
        Icon = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900146.UI_Icon_900146'",
    },
    {
        Name = LSTR(30058),--进攻职业
        Icon = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900180.UI_Icon_900180'",
    }
}

local EmptyImagePath = "Texture2D'/Game/UI/Texture/PWorld/UI_PWorld_Teaching_Img_Level_EmptyState.UI_PWorld_Teaching_Img_Level_EmptyState'"

local EnterInteractiveID = 186

local GuideSkillExBaseID = 100

local GuideSkillDetailInfo = {
    --对应101
    {
        {SkillID = 2011, ClassType = ProtoCommon.class_type.CLASS_TYPE_TANK, ProfType = 0},                                             --防护
        {SkillID = 2021, ClassType = ProtoCommon.class_type.CLASS_TYPE_HEALTH, ProfType = ProtoCommon.prof_type.PROF_TYPE_WHITEMAGE},   --治疗 白魔
        {SkillID = 2024, ClassType = ProtoCommon.class_type.CLASS_TYPE_HEALTH, ProfType = ProtoCommon.prof_type.PROF_TYPE_SCHOLAR},     --治疗 学者
        {SkillID = 2031, ClassType = ProtoCommon.class_type.CLASS_TYPE_NEAR, ProfType = 0},                                             --近战
        {SkillID = 2041, ClassType = ProtoCommon.class_type.CLASS_TYPE_FAR, ProfType = 0},                                              --远程
        {SkillID = 2051, ClassType = ProtoCommon.class_type.CLASS_TYPE_MAGIC, ProfType = ProtoCommon.prof_type.PROF_TYPE_BLACKMAGE},    --魔法 黑魔
        {SkillID = 2054, ClassType = ProtoCommon.class_type.CLASS_TYPE_MAGIC, ProfType = ProtoCommon.prof_type.PROF_TYPE_SUMMONER},     --魔法 召唤
    },
    --对应102
    --{
    --},
}

local TeachingDefine = {
    MainTabs = MainTabs,
    JobTypeInfos = JobTypeInfos,
    EmptyImagePath = EmptyImagePath,
    EnterInteractiveID = EnterInteractiveID,
    GuideSkillExBaseID = GuideSkillExBaseID,
    GuideSkillDetailInfo = GuideSkillDetailInfo,
}

return TeachingDefine