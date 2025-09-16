---
--- Author: lydianwang
--- DateTime: 2022-7-13
--- Description:
---
--local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ChatDefine = require("Game/Chat/ChatDefine")

--local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local QUEST_TYPE = ProtoRes.QUEST_TYPE
local TARGET_TYPE = ProtoRes.QUEST_TARGET_TYPE
local BEHAVIOR_TYPE = ProtoRes.QUEST_CLIENT_ACTION_TYPE
local RESTRICTION_TYPE = ProtoRes.QUEST_RESTRICTION_TYPE
local QUEST_FAULT_TOLERANT_TYPE = ProtoRes.QUEST_FAULT_TOLERANT_TYPE

local LSTR = _G.LSTR

local QuestDefine = {}

-- ==================================================
-- 全局变量
-- ==================================================

-- 静态系统变量
QuestDefine.QuestMaxDistance = 2000

---后台没有Chapter概念，由前台单独定义状态。
---此状态和QUEST_STATUS严格对应，改动会在QuestHelper.MakeChapterStatus()造成bug
QuestDefine.CHAPTER_STATUS = {
    NOT_STARTED = 1,
    IN_PROGRESS = 2,
    CAN_SUBMIT = 3,
    FINISHED = 4,
    FAILED = 5,
}
local CHAPTER_STATUS = QuestDefine.CHAPTER_STATUS

-- ==================================================
-- 逻辑数据
-- ==================================================

---任务目标类映射
--- --- Class: lua类路径
--- --- Desc: 默认目标描述
--- --- bCanAutoDoTarget: 允许目标自动完成
--- --- bShowQuestFunction: 目标注册在actor身上时，显式指定是否显示交互项，未赋值表示按代码逻辑来
--- --- bDirectInteract: 策划认为需要优先交互的任务，由交互系统放到一级交互
QuestDefine.TargetClassParams = {
    [TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_DIALOG] = {
        Class = "Game/Quest/QuestTarget/TargetFinishDialog",
        Desc = LSTR(590001), --590001("完成对话")
        bCanAutoDoTarget = true,
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_KILL_APPOINT_TYPE_ENEMY] = {
        Class = "Game/Quest/QuestTarget/TargetKillAppointTypeEnemy",
        Desc = LSTR(590002), --590002("击杀怪物")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_SEQUENCE] = {
        Class = "Game/Quest/QuestTarget/TargetFinishSequence",
        Desc = LSTR(590003), --590003("观看过场动画")
        bCanAutoDoTarget = true,
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_TRIGGER] = {
        Class = "Game/Quest/QuestTarget/TargetTrigger",
        Desc = LSTR(590004),  --590004("到达触发器")
        bShowQuestFunction = false, -- 触发器目标有特殊逻辑
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_INTERACT] = {
        Class = "Game/Quest/QuestTarget/TargetInteract",
        Desc = LSTR(590005), --590005("进行交互")
        bDirectInteract = true,
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_CHAT] = {
        Class = "Game/Quest/QuestTarget/TargetChat",
        Desc = LSTR(590006),    --590006("发送聊天")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_GET_ITEM] = {
        Class = "Game/Quest/QuestTarget/TargetGetItem",
        Desc = LSTR(590007), --590007("提交物品")
        bShowQuestFunction = true,
        bDirectInteract = true,
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_WAIT] = {
        Class = "Game/Quest/QuestTarget/TargetWait",
        Desc = LSTR(590008), --590008("等待指定时间")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_EMOTION] = {
        Class = "Game/Quest/QuestTarget/TargetEmotion",
        Desc = LSTR(590009), --590009("使用情感动作")
        bShowQuestFunction = true,
        bDirectInteract = true,
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_ACTIVATE_CRYSTAL] = {
        Class = "Game/Quest/QuestTarget/TargetActivateCrystal",
        Desc = LSTR(590010), --590010("解锁以太之光")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_EQUIP] = {
        Class = "Game/Quest/QuestTarget/TargetEquip",
        Desc = LSTR(590011), --590011("穿戴指定装备")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_USE_QUEST_ITEM] = {
        Class = "Game/Quest/QuestTarget/TargetUseQuestItem",
        Desc = LSTR(590012), --590012("使用任务物品")
        bDirectInteract = true,
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_CAST_SKILL] = {
        Class = "Game/Quest/QuestTarget/TargetCastSkill",
        Desc = LSTR(590013), --590013("使用指定技能")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_COLLECT_ITEM] = {
        Class = "Game/Quest/QuestTarget/TargetCollectItem",
        Desc = LSTR(590014), --590014("收集物品")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_SPACE] = {
        Class = "Game/Quest/QuestTarget/TargetFinishPWorld",
        Desc = LSTR(590015), --590015("完成副本")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_CREATE_KILL_ENEMY] = {
        Class = "Game/Quest/QuestTarget/TargetCreateKillEnemy",
        Desc = LSTR(590016), --590016("创怪杀怪")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_NAME_CHOCOBO] = {
        Class = "Game/Quest/QuestTarget/TargetNameChocobo",
        Desc = LSTR(590017), --590017("给陆行鸟取名")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_OWN_ITEM] = {
        Class = "Game/Quest/QuestTarget/TargetOwnItem",
        Desc = LSTR(590018), --590018("拥有购买物")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_PHASE_SPACE] = {
        Class = "Game/Quest/QuestTarget/TargetFinishPhaseSpace",
        Desc = LSTR(590019), --590019("完成相位副本")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_CUTOUT] = {
        Class = "Game/Quest/QuestTarget/TargetCutout",
        Desc = LSTR(590020), --590020("完成拼装剪影")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_CHOCOBO_QTE] = {
        Class = "Game/Quest/QuestTarget/TargetChocoboFeedingQte",
        Desc = LSTR(590021), --590021("完成陆行鸟喂食QTE")
    },
    [TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_FATE] = {
        Class = "Game/Quest/QuestTarget/TargetFinishFate",
        Desc = LSTR(590022), --590022("完成Fate")
    }
}

---客户端行为类映射
--- --- Class: lua类路径
--- --- bIgnoreWhenDirectFinish: 系统初始化时不执行
QuestDefine.BehaviorClassParams = {
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_SHOW_NPC] = {
        Class = "Game/Quest/ClientBehavior/BehaviorShowNPC",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_HIDE_NPC] = {
        Class = "Game/Quest/ClientBehavior/BehaviorHideNPC",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_PLAY_SEQUENCE] = {
        Class = "Game/Quest/ClientBehavior/BehaviorPlaySequence",
        bIgnoreWhenDirectFinish = true,
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_CHANGE_CAMERA] = {
        Class = "Game/Quest/ClientBehavior/BehaviorChangeCamera",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_OPEN_CAMERA_TRIGGER] = {
        Class = "Game/Quest/ClientBehavior/BehaviorCreateCamTrig",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_CLOSE_CAMERA_TRIGGER] = {
        Class = "Game/Quest/ClientBehavior/BehaviorDestroyCamTrig",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_CHANGE_MAP_BGM] = {
        Class = "Game/Quest/ClientBehavior/BehaviorChangeMapBGM",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_RESTORE_MAP_BGM] = {
        Class = "Game/Quest/ClientBehavior/BehaviorRestoreMapBGM",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_PLAY_BUBBLE] = {
        Class = "Game/Quest/ClientBehavior/BehaviorPlayBubble",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_PLAY_SOUND] = {
        Class = "Game/Quest/ClientBehavior/BehaviorPlaySound",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_PLAY_DIALOG] = {
        Class = "Game/Quest/ClientBehavior/BehaviorPlayDialog",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_SHOW_EOBJ] = {
        Class = "Game/Quest/ClientBehavior/BehaviorShowEObj",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_HIDE_EOBJ] = {
        Class = "Game/Quest/ClientBehavior/BehaviorHideEObj",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_ENTER_SINGLE_SCENE] = {
        Class = "Game/Quest/ClientBehavior/BehaviorEnterSingleScene",
        bIgnoreWhenDirectFinish = true,
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_SHOW_DYNOBSTACLE] = {
        Class = "Game/Quest/ClientBehavior/BehaviorShowDynObstacle",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_HIDE_DYNOBSTACLE] = {
        Class = "Game/Quest/ClientBehavior/BehaviorHideDynObstacle",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_RIDE] = {
        Class = "Game/Quest/ClientBehavior/BehaviorRide",
        bIgnoreWhenDirectFinish = true,
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_SHOW_EASY_USE] = {
        Class = "Game/Quest/ClientBehavior/BehaviorShowEasyUse",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_HINT_TALK] = {
        Class = "Game/Quest/ClientBehavior/BehaviorHintTalk",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_HINT_TALK_BEFORE] = {
        Class = "Game/Quest/ClientBehavior/BehaviorHintTalkBefore",
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_SHOW_AREA_SCENE] = {
        Class = "Game/Quest/ClientBehavior/BehaviorShowAreaScene"
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_HIDE_AREA_SCENE] = {
        Class = "Game/Quest/ClientBehavior/BehaviorHideAreaScene"
    },
    [BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_SET_EOBJ_STATE] = {
        Class = "Game/Quest/ClientBehavior/BehaviorSetEObjState"
    },
}

---任务条件BitMask
QuestDefine.CondBit = {
    -- GameEvent
    QuestUpdate =   0x0001,
    ProfActivate =  0x0002,
    ProfSwitch =    0x0004,
    RegisterProf =  0x0008, -- 首发职业限制，无需注册事件
    Counter =       0x0010,
    GrandCompany =  0x0020,
    Activity =      0x0040,
    Score =         0x0080,
    ChocoboLevel =  0x0100,
    -- QuestRestriction
    Buff =          0x00010000,
    Ride =          0x00020000,
    Equip =         0x00040000,
    Item =          0x00080000,
    BagSlot =       0x00100000,
    ProfType =      0x00200000,
    Buddy =         0x00400000,
}
QuestDefine.AllCondBitMask = 0x000001FF--0x007F001F -- QuestRestriction那一段还没完善，先不开mask

---客户端行为类映射
QuestDefine.StateRestriction = {
    [RESTRICTION_TYPE.QUEST_TARGET_RESTRICTION_TYPE_BUFF] = {
        Class = "Game/Quest/StateRestriction/RestrictionBuff",
        CondBit = QuestDefine.CondBit.Buff,
    },
    [RESTRICTION_TYPE.QUEST_TARGET_RESTRICTION_TYPE_RIDE] = {
        Class = "Game/Quest/StateRestriction/RestrictionRide",
        CondBit = QuestDefine.CondBit.Ride,
    },
    [RESTRICTION_TYPE.QUEST_TARGET_RESTRICTION_TYPE_EQUIP] = {
        Class = "Game/Quest/StateRestriction/RestrictionEquip",
        CondBit = QuestDefine.CondBit.Equip,
    },
    [RESTRICTION_TYPE.QUEST_TARGET_RESTRICTION_TYPE_ITEM] = {
        Class = "Game/Quest/StateRestriction/RestrictionItem",
        CondBit = QuestDefine.CondBit.Item,
    },
    [RESTRICTION_TYPE.QUEST_TARGET_RESTRICTION_TYPE_BAG] = {
        Class = "Game/Quest/StateRestriction/RestrictionBagSlot",
        CondBit = QuestDefine.CondBit.BagSlot,
    },
    [RESTRICTION_TYPE.QUEST_TARGET_RESTRICTION_TYPE_PROF_TYPE] = {
        Class = "Game/Quest/StateRestriction/RestrictionProfType",
        CondBit = QuestDefine.CondBit.ProfType,
    },
    [RESTRICTION_TYPE.QUEST_TARGET_RESTRICTION_TYPE_BUDDY] = {
        Class = "Game/Quest/StateRestriction/RestrictionBuddy",
        CondBit = QuestDefine.CondBit.Buddy,
    },
}

---任务容错类型映射
QuestDefine.FaultTolerant = {
    [QUEST_FAULT_TOLERANT_TYPE.QUEST_FAULT_TOLERANT_TYPE_ITEM] = {
        Class = "Game/Quest/FaultTolerant/FaultTolerantItem",
    },
    [QUEST_FAULT_TOLERANT_TYPE.QUEST_FAULT_TOLERANT_TYPE_MOUNT] = {
        Class = "Game/Quest/FaultTolerant/FaultTolerantMount",
    },
    [QUEST_FAULT_TOLERANT_TYPE.QUEST_FAULT_TOLERANT_TYPE_BUFF] = {
        Class = "Game/Quest/FaultTolerant/FaultTolerantBuff",
    },
    [QUEST_FAULT_TOLERANT_TYPE.QUEST_FAULT_TOLERANT_TYPE_TELEPORT] = {
        Class = "Game/Quest/FaultTolerant/FaultTolerantTransfer",
    },
    [QUEST_FAULT_TOLERANT_TYPE.QUEST_FAULT_TOLERANT_TYPE_FATE] = {
        Class = "Game/Quest/FaultTolerant/FaultTolerantFate",
    },
}

---不满足任务限制时，和任务状态有关的对话部分
QuestDefine.RestrictedDialogForStatus = {
    [CHAPTER_STATUS.NOT_STARTED] = LSTR(591001),    --591001("无法接受任务，没有满足以下条件。")
    [CHAPTER_STATUS.IN_PROGRESS] = LSTR(591002),    --591002("没有满足下列条件，无法继续进行任务。")
    [CHAPTER_STATUS.CAN_SUBMIT] = LSTR(591003), --591003("没有满足下列条件，无法完成任务。")
}
QuestDefine.RestrictedDialogType = {
    START       = 0,
    LowLevel    = 1,
    Prof        = 2,
    OwnProf     = 3,
    FixedProf   = 4,
    BagSlot     = 5,
    LootCount   = 6,
    GrandCompany = 7,
    TimeLimit   = 8,
    MAX         = 9,
}
QuestDefine.RestrictedDialogID = {
    Prof        = 510003,
    LowLevel    = 510004,
    FixedProf   = 510005,
    LootCount   = 510006,
    JoinGrandCompany = 624997,
    UpGrandCompanyLevel = 624998,
    ChangeGrandCompany = 624999,
}

QuestDefine.DialogueType = {
    None = 1,
    NpcDialog = 2,
    DialogueSequence = 3,
    CutSceneSequence = 4,
}
local DType = QuestDefine.DialogueType

-- 【【叙事】【对白ID段】对于七位数的对白ID增加首数字的判断】
-- https://tapd.woa.com/FinalFantasy/prong/stories/view/1020420083115851402
function QuestDefine.GetDialogueType(DialogOrSequenceID)
    local Digit = 0
    local BigDigit = (DialogOrSequenceID or 0) // 10000
    if BigDigit == 0 then return DType.None end

    for i = 5, 8 do
        if BigDigit < 10 then
            Digit = i
            break
        else
            BigDigit = BigDigit // 10
        end
    end

    if Digit == 5 or Digit == 6 then
        return DType.NpcDialog

    elseif Digit == 7 then
        return (BigDigit == 2) and DType.NpcDialog or DType.CutSceneSequence

    elseif Digit == 8 then
        return DType.DialogueSequence
    end

    return DType.None
end

-- 和ENaviType蓝图对应
QuestDefine.NaviType = {
    MIN = 0,
    NpcResID = 1,
	EObjResID = 2,
    None = 3,
    CrystalID = 4,
    AreaListID = 5,
	PointListID = 6,
    MonsterListID = 7,
    MAX = 8,
}

QuestDefine.TRACK_STATUS = {
	ACCEPT = 1,
	UPDATE = 2,
	FINISH = 3,
}

-- ==================================================
-- 特效音效
-- ==================================================

QuestDefine.Sound = {
    NormalAccept = {
        [1] = "",
        [2] = "/Game/WwiseAudio/Events/UI/UI_SYS/mission_music/Play_QuestStart.Play_QuestStart",
        [3] = "/Game/WwiseAudio/Events/UI/UI_SYS/mission_music/Play_Zingle_HW_Q_Accept.Play_Zingle_HW_Q_Accept",
        [4] = "/Game/WwiseAudio/Events/UI/UI_SYS/mission_music/Play_ST_Que_Accept.Play_ST_Que_Accept",
        [5] = "/Game/WwiseAudio/Events/UI/UI_SYS/mission_music/Play_EX3_QuestAccept_v7_44kHz16bit.Play_EX3_QuestAccept_v7_44kHz16bit",
        [6] = "",
    },
    NormalFinish = {
        [1] = "",
        [2] = "/Game/WwiseAudio/Events/UI/UI_SYS/mission_music/Play_QuestClear3.Play_QuestClear3",
        [3] = "/Game/WwiseAudio/Events/UI/UI_SYS/mission_music/Play_Zingle_HW_Q_Clear.Play_Zingle_HW_Q_Clear",
        [4] = "/Game/WwiseAudio/Events/UI/UI_SYS/mission_music/Play_ST_Que_Clear.Play_ST_Que_Clear",
        [5] = "/Game/WwiseAudio/Events/UI/UI_SYS/mission_music/Play_EX3_QuestComp_v3.Play_EX3_QuestComp_v3",
        [6] = "",
    },
}

QuestDefine.TargetSound = "/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_event_check.Play_SE_UI_SE_UI_event_check"

-- ==================================================
-- UI
-- ==================================================

QuestDefine.MainCityID2Name = {
	[1041] = LSTR(591006), --591006("格里达尼亚")
	[1042] = LSTR(591006), --591006("格里达尼亚")
}

QuestDefine.LogQuestTypeAll = -1

QuestDefine.LogTabIcon = {
    [QuestDefine.LogQuestTypeAll] = {
        Normal = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Noraml.UI_Icon_Tab_Bag_Equip_All_Noraml'",
        Select = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Select.UI_Icon_Tab_Bag_Equip_All_Select'",
    },
    [QUEST_TYPE.QUEST_TYPE_MAIN] = {
        Normal = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Hud_Main_Missed.UI_Icon_Tab_Hud_Main_Missed'",
        Select = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Hud_Main_Missed.UI_Icon_Tab_Hud_Main_Missed'",
    },
    [QUEST_TYPE.QUEST_TYPE_IMPORTANT] = {
        Normal = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Hud_Plus_Missed.UI_Icon_Tab_Hud_Plus_Missed'",
        Select = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Hud_Plus_Missed.UI_Icon_Tab_Hud_Plus_Missed'",
    },
    [QUEST_TYPE.QUEST_TYPE_BRANCH] = {
        Normal = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Hud_Normal_Missed.UI_Icon_Tab_Hud_Normal_Missed'",
        Select = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Hud_Normal_Missed.UI_Icon_Tab_Hud_Normal_Missed'",
    }
}

QuestDefine.QuestTypeNames = {
        [QuestDefine.LogQuestTypeAll] = LSTR(390019),
        [QUEST_TYPE.QUEST_TYPE_MAIN] = LSTR(390020),
        [QUEST_TYPE.QUEST_TYPE_IMPORTANT] = LSTR(390021),
        [QUEST_TYPE.QUEST_TYPE_BRANCH] = LSTR(390022),
    }

QuestDefine.QuestTypeInfo = {
	[QUEST_TYPE.QUEST_TYPE_MAIN] = {
        TypeIconStr = "_Main",
        AcceptSound = QuestDefine.Sound.NormalAccept,
        FinishSound = QuestDefine.Sound.NormalFinish,
	},
	[QUEST_TYPE.QUEST_TYPE_IMPORTANT] = {
        TypeIconStr = "_Plus",
        AcceptSound = QuestDefine.Sound.NormalAccept,
        FinishSound = QuestDefine.Sound.NormalFinish,
	},
	[QUEST_TYPE.QUEST_TYPE_BRANCH] = {
        TypeIconStr = "_Normal",
        AcceptSound = QuestDefine.Sound.NormalAccept,
        FinishSound = QuestDefine.Sound.NormalFinish,
	},
}

QuestDefine.QuestStatusInfo = {
    [CHAPTER_STATUS.NOT_STARTED] = {
        StatusIconStr = "_Missed",
    },
    [CHAPTER_STATUS.IN_PROGRESS] = {
        StatusIconStr = "_Go",
    },
    [CHAPTER_STATUS.CAN_SUBMIT] = {
        StatusIconStr = "_Remain",
    },
    [CHAPTER_STATUS.FINISHED] = {
        StatusIconStr = "_Remain",
    },
    [CHAPTER_STATUS.FAILED] = {
        StatusIconStr = "_Remain",
    },
}

QuestDefine.MainlineOverIcon =
    "PaperSprite'/Game/UI/Atlas/MapIcon/Frames/UI_Icon_900013_png.UI_Icon_900013_png'"
QuestDefine.MainlineOverText1 = LSTR(593001) --593001("请期待下一个版本来临!")
QuestDefine.MainlineOverText2 = LSTR(593002) --593002("已完成当前版本所有主线")

QuestDefine.IconShowPlaceInfo = {
    ["HUD"] = {
        AssetPath = "/Game/UI/Atlas/HUDQuest/Frames",
        AssetNameInfo = "_Hud",
    },
    ["MAP"] = {
        AssetPath = "/Game/UI/Atlas/MapIcon/Frames",
        AssetNameInfo = "_Map",
    },
    ["LOG"] = {
        AssetPath = "/Game/UI/Atlas/HUDQuest/Frames",
        AssetNameInfo = "_Hud",
    },
}

QuestDefine.SOURCE_TYPE = {
    HUD = 1,
    MAP = 2,
    LOG = 3,
}

QuestDefine.FaultTolerantIcon = "PaperSprite'/Game/UI/Atlas/MapIcon/Frames/UI_Icon_Map_Snap_Missed_Blue_png.UI_Icon_Map_Snap_Missed_Blue_png'"
QuestDefine.FaultTolerantIconUnproceed = "PaperSprite'/Game/UI/Atlas/MapIcon/Frames/UI_Icon_Map_Snap_Missed_Red_png.UI_Icon_Map_Snap_Missed_Red_png'"
QuestDefine.TrackIcon = {
    [QuestDefine.SOURCE_TYPE.HUD] = {
        [true] = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Main_Go_Link_png.UI_Icon_Hud_Main_Go_Link_png'",
        [false] = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Main_Go_Link_Red_png.UI_Icon_Hud_Main_Go_Link_Red_png'",
    },
    [QuestDefine.SOURCE_TYPE.MAP] = {
        [true] = "PaperSprite'/Game/UI/Atlas/MapIcon/Frames/UI_Icon_Map_Main_Go_Link_png.UI_Icon_Map_Main_Go_Link_png'",
        [false] = "PaperSprite'/Game/UI/Atlas/MapIcon/Frames/UI_Icon_Map_Main_Go_Link_Red_png.UI_Icon_Map_Main_Go_Link_Red_png'",
    }
}

function QuestDefine.MakeIconPath(QuestType, ChapterStatus, bCanProceed, bMonster, bIsCycle, ShowPlace)
    local ShowPlaceStr, TypeStr, StatusStr, CanProceedStr
    if QuestDefine.IconShowPlaceInfo[ShowPlace] == nil then
        ShowPlace = "HUD"
    end

    ShowPlaceStr = QuestDefine.IconShowPlaceInfo[ShowPlace].AssetNameInfo

    TypeStr = QuestDefine.QuestTypeInfo[QuestType].TypeIconStr

    if bMonster then
        StatusStr = "_Target"
    elseif bIsCycle and (ChapterStatus == CHAPTER_STATUS.NOT_STARTED) then
        StatusStr = "_Cycle"
    else
        StatusStr = QuestDefine.QuestStatusInfo[ChapterStatus].StatusIconStr
    end

    local bChapterFinished = (ChapterStatus == CHAPTER_STATUS.FINISHED)
    CanProceedStr = (bCanProceed or bChapterFinished) and "" or "_Red"

    local AssetName = string.format("UI_Icon%s%s%s%s_png",
        ShowPlaceStr, TypeStr, StatusStr, CanProceedStr)
    local AssetPath = QuestDefine.IconShowPlaceInfo[ShowPlace].AssetPath
    return string.format("PaperSprite'%s/%s.%s'", AssetPath, AssetName, AssetName)
end

function QuestDefine.MakeTrackingIconPath(SourceType, bCanProceed)
    return QuestDefine.TrackIcon[SourceType][bCanProceed]
end

QuestDefine.ShareChannels = {
	{
		ChannelName = LSTR(594001), --594001("新人频道")
		ChannelType = ChatDefine.ChatChannel.Newbie,
	},
	{
		ChannelName = LSTR(594002), --594002("部队频道")
		ChannelType = ChatDefine.ChatChannel.Army,
	},
	{
		ChannelName = LSTR(594003), --594003("组队频道")
		ChannelType = ChatDefine.ChatChannel.Team,
	},
}

QuestDefine.NEW_ACCCEPT_DURATION = 1
QuestDefine.PRE_TRACK_DURATION = 5

QuestDefine.FilterType = {
    None = 0,
    Filter = 1,
    Search = 2,
}
-- ==================================================
-- debug
-- ==================================================

QuestDefine.bShowDebugLog = false

return QuestDefine