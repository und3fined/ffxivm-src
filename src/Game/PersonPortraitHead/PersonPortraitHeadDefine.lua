local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

local LSTR = _G.LSTR
local DesignerType = ProtoCommon.DesignerType
local EnumAlias = ProtoEnumAlias.GetAlias
local PortraitSize = _G.UE.FVector2D(432, 432)
local MinDistance = 65 
local MaxDistance = 300 
local MinFOV = 40 
local MaxFOV = 70 
local SliderMaxFOV = 200
local MaxSavedPortraitImageNum = 200
local IntensityMaxValue = 255
local ColorChannelMaxValue = 255

local MontageZero = 0.00001 -- 由于界面那边在判断位置为0时，会当做刚播放完成，从而循环播放动作

local THead = 1 << 8
local TFrame = 1 << 7

local FrameType = {
    All      =   1,
    Sys      =   2,
    Act      =   3,
    Sea      =   4,
}

local HeadType = {
    Default = 0,
    Custom = 1
}

local EditTabMainKey = {
    Head = THead,
    Frame = TFrame,

    FrameAll      = TFrame + FrameType.All,
    FrameSys      = TFrame + FrameType.Sys,
    FrameAct      = TFrame + FrameType.Act,
    FrameSea      = TFrame + FrameType.Sea,
}

local EditTabs = {
    {
        Key = EditTabMainKey.Head,
        Name = LSTR(960008),
    },
    {
        Key = EditTabMainKey.Frame,
        Name = LSTR(960009),
        Children = {
            {
                Key = EditTabMainKey.FrameAll,
                Name = LSTR(960005),
            },
            {
                Key = EditTabMainKey.FrameSys,
                Name = LSTR(960027),
            },
            -- {
            --     Key = EditTabMainKey.FrameAct,
            --     Name = LSTR(960025),
            -- },
            -- {
            --     Key = EditTabMainKey.FrameSea,
            --     Name = LSTR(960031),
            -- },
        }
    },
}

local ScaleIconPath = "PaperSprite'/Game/UI/Atlas/PersonPortrait/Frames/UI_PersonPortrait_Icon_Scale_png.UI_PersonPortrait_Icon_Scale_png'"
local RotateIconPath = "PaperSprite'/Game/UI/Atlas/PersonPortrait/Frames/UI_PersonPortrait_Icon_Rotate_png.UI_PersonPortrait_Icon_Rotate_png'"

local PersonPortraitHeadDefine = {
    PortraitSize                = PortraitSize,
    MinDistance                 = MinDistance, 
    MaxDistance                 = MaxDistance,
    MinFOV                      = MinFOV, 
    MaxFOV                      = MaxFOV, 
    SliderMaxFOV                = SliderMaxFOV,
    MaxSavedPortraitImageNum    = MaxSavedPortraitImageNum,
    IntensityMaxValue           = IntensityMaxValue,
    ColorChannelMaxValue        = ColorChannelMaxValue,
    MontageZero                 = MontageZero,

    
    EditTabs = EditTabs,
    EditTabMainKey = EditTabMainKey,
    FrameType = FrameType,
    HeadType = HeadType,

    ScaleIconPath = ScaleIconPath,
    RotateIconPath = RotateIconPath,

    TFrame = TFrame,
    THead = THead,
}

return PersonPortraitHeadDefine