local TemplateShutImageSize = _G.UE.FVector2D(308, 146)
local MsgTipsID = require("Define/MsgTipsID")

local UITabMain = {
    Camera      = 1,
    Role        = 2,
    Eff         = 3,
    Mod         = 4,
}

local UITabNameMain = {
    [UITabMain.Camera]  = LSTR(630013),
    [UITabMain.Role]    = LSTR(630028),
    [UITabMain.Eff]     = LSTR(630022),
    [UITabMain.Mod]     = LSTR(630020),
}

local UITabSub = {
    [UITabMain.Camera] = {
        DOF     = 1,
        FOV     = 2,
        Rot     = 3,
    },

    [UITabMain.Role] = {
        Act     = 1,
        Emo     = 2,
        Stat    = 3,
        Setting = 4,
    },

    [UITabMain.Eff] = {
        Filer     = 1,
        DarkFrame = 2,
        -- Frame     = 3,
        Scene     = 3,
    },

    [UITabMain.Mod] = {
        Mod     = 1,
    },
}

local UITabNameSub = {
    [UITabMain.Camera] = {
        [UITabSub[UITabMain.Camera].DOF]        = LSTR(630018),
        [UITabSub[UITabMain.Camera].FOV]        = LSTR(630034),
        [UITabSub[UITabMain.Camera].Rot]        = LSTR(630016),
    },

    [UITabMain.Role] = {
        [UITabSub[UITabMain.Role].Act]          = LSTR(630029),
        [UITabSub[UITabMain.Role].Emo]          = LSTR(630031),
        [UITabSub[UITabMain.Role].Stat]         = LSTR(630030),
        [UITabSub[UITabMain.Role].Setting]      = LSTR(630032),
    },

    [UITabMain.Eff] = {
        [UITabSub[UITabMain.Eff].Filer]         = LSTR(630021),
        [UITabSub[UITabMain.Eff].DarkFrame]     = LSTR(630019),
        -- [UITabSub[UITabMain.Role].Frame]        = LSTR(630033),
        [UITabSub[UITabMain.Eff].Scene]         = LSTR(630017),
           
    },

    [UITabMain.Mod] = {
        [UITabSub[UITabMain.Mod].Mod]           = LSTR(630020),
    },
}

local RoleCtrlSetting = {
    Ctrl = {
        Self = 1,
        MyPet = 2,
        Mate = 3, -- 好友|队员|部队
        Chocobo = 4, -- 陆行鸟
        Summon = 5, -- 召唤物
        MatePet = 6, -- 好友|队员|部队 的 宠物
        Entourate = 7, --亲信
    },

    UnCtrl = {
        Other = 1,
        OtherChocobo = 2, -- 陆行鸟
        OtherSummon = 3,
        OtherPet = 4,
        NPC = 5,
        Enemy = 6,
    },

    Camera = {
        LookForward = 1,
    },
}

local RoleCtrlSettingInfo = {
    Ctrl = {
        [RoleCtrlSetting.Ctrl.Self] = {
            Name = LSTR(630026),
        },

        [RoleCtrlSetting.Ctrl.MyPet] = {
            Name = LSTR(630027),
        },

        [RoleCtrlSetting.Ctrl.Mate] = {
            Name = LSTR(630005),
        },

        [RoleCtrlSetting.Ctrl.Chocobo] = {
            Name = LSTR(630014),
        },

        [RoleCtrlSetting.Ctrl.Summon] = {
            Name = LSTR(630009),
        },

        [RoleCtrlSetting.Ctrl.MatePet] = {
            Name = LSTR(630011),
        },

        [RoleCtrlSetting.Ctrl.Entourate] = {
            Name = LSTR(630035),
        },
    },

    UnCtrl = {
        [RoleCtrlSetting.UnCtrl.Other] = {
            Name = LSTR(630005),
        },

        [RoleCtrlSetting.UnCtrl.OtherChocobo] = {
            Name = LSTR(630014),
        },

        [RoleCtrlSetting.UnCtrl.OtherSummon] = {
            Name = LSTR(630009),
        },

        [RoleCtrlSetting.UnCtrl.OtherPet] = {
            Name = LSTR(630011),
        },

        [RoleCtrlSetting.UnCtrl.NPC] = {
            Name = LSTR(630035),
        },

        [RoleCtrlSetting.UnCtrl.Enemy] = {
            Name = LSTR(630015),
        },
    },

    Camera = {
        [RoleCtrlSetting.Camera.LookForward] = {
            Name = LSTR(630041),
        },
    },
}

local RoleSettingType = 
{
    Ctrl    = 1,
    UnCtrl  = 2,
    Camera  = 3,
}

local RoleSettingTypeInfo = 
{
    [RoleSettingType.Ctrl]    = {
        Name = LSTR(630010),
        ChildList = RoleCtrlSetting.Ctrl,
        SettingInfo = RoleCtrlSettingInfo.Ctrl,
    },

    [RoleSettingType.UnCtrl]    = {
        Name = LSTR(630002),
        ChildList = RoleCtrlSetting.UnCtrl,
        SettingInfo = RoleCtrlSettingInfo.UnCtrl,

    },

    [RoleSettingType.Camera]    = {
        Name = LSTR(630042),
        ChildList = RoleCtrlSetting.Camera,
        SettingInfo = RoleCtrlSettingInfo.Camera,
    },
}

local MoveMouthType = {
    ---移动: 1
        Movement = 1,
    ---口型
        Mouth = 2,
}

local GiveType = {
    ---状态 1
        Status = 1,
    ---动作
        Action = 2,
        --表情
        Emoji = 3,
        ---移动
        Movement = 4,
        --口型
        Mouth = 5,
}

local AnimType = {
    Motion = 1,
    Movement = 2,
    Face = 3,
    Mouth = 4,
}

local PhotoTipsID = {
    ChangesUndo         = MsgTipsID.PhotoChangesUndo,

    MoveUnlock          = MsgTipsID.PhotoMoveUnlock,
    MoveLock            = MsgTipsID.PhotoMoveLock,

    WeatherPause        = MsgTipsID.PhotoWeatherPause,
    WeatherResume       = MsgTipsID.PhotoWeatherResume,

    SelfPause           = MsgTipsID.PhotoSelfPause,
    SelfResume          = MsgTipsID.PhotoSelfResume,

    AllActorPause       = MsgTipsID.PhotoAllActorPause,
    AllActorResume      = MsgTipsID.PhotoAllActorResume,

    EnableGiveAll       = MsgTipsID.PhotoEnableGiveAll,
    DisableGiveAll      = MsgTipsID.PhotoDisableGiveAll,

    StartFaceLookAt     = MsgTipsID.PhotoStartFaceLookAt,
    StopFaceLookAt      = MsgTipsID.PhotoStopFaceLookAt,

    StartEyeLookAt      = MsgTipsID.PhotoStartEyeLookAt,
    StopEyeLookAt       = MsgTipsID.PhotoStopEyeLookAt,


    ShowAuxLine         = MsgTipsID.PhotoShowAuxLine,
    HideAuxLine         = MsgTipsID.PhotoHideAuxLine,

    ShowView            = MsgTipsID.PhotoShowView,
    HideView            = MsgTipsID.PhotoHideView,

    TemplateIsMaxNum    = MsgTipsID.PhotoTemplateIsMaxNum,
    TemplateDelete      = MsgTipsID.PhotoTemplateDelete,
}

local Define = {
    
    UITabMain = UITabMain,

    UITabSub = UITabSub,

    UITabNameMain = UITabNameMain,

    UITabNameSub = UITabNameSub,

    AnimType = AnimType,

    CastTy = {
        Drug = 1,
        Skill = 2
    },

    MoveMouthType = MoveMouthType,
    PhotoGiveType = GiveType,

    RoleCtrlSetting = RoleCtrlSetting,

    RoleCtrlSettingInfo = RoleCtrlSettingInfo,

    RoleSettingType = RoleSettingType,
    RoleSettingTypeInfo = RoleSettingTypeInfo,

    -- camera turnplate
    TouchY2Unit = 5,
    CameraTurnplateAngle = 84,
    
    CameraTurnplateUnitMin = 0,
    CameraTurnplateUnitMax = 100,
    Unit2TurnplateAngle = 84 / 100,

    CameraUnit2ValueDOFMin = 0,
    CameraUnit2ValueDOFMax = 16,

    CameraDOFMax = 4,

    CameraUnit2ValueFOVMin = 0,
    CameraUnit2ValueFOVMax = 200,

    CameraUnit2ValueRotMin = -180,
    CameraUnit2ValueRotMax = 180,

    -- camera move
    CameraMoveStep = 2,

    -- CameraSubReset
    CameraResetUnit = 50,

    MaxTemplateCnt = 5,

    TemplateShutImageSize = TemplateShutImageSize,

    TemplateImageDefault = "Texture2D'/Game/UI/Texture/Photo/UI_Photo_Img_Banner02.UI_Photo_Img_Banner02'",

    TemplateDownloadMax = 200,


    -- DOF distance (note: the meaing of A and B here is the opposite of the official meaning)
    DofDis = 50,

    PhotoTipsID = PhotoTipsID,
}

return Define