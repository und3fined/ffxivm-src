local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

local LSTR = _G.LSTR
local DesignerType = ProtoCommon.DesignerType
local EnumAlias = ProtoEnumAlias.GetAlias
local MinDistance = 65 
local MaxDistance = 300 
local MinFOV = 20 
local MaxFOV = 90 
local MinRotate = -90
local MaxRotate = 90
local MinPitch = -70
local MaxPitch = 6
local SliderMaxFOV = 200
local MaxSavedPortraitImageNum = 200
local IntensityMaxValue = 255
local ColorChannelMaxValue = 255
local MontageZero = 0.00001 -- 由于界面那边在判断位置为0时，会当做刚播放完成，从而循环播放动作

local TabTypes = {
   Design    = (1 << DesignerType.DesignerType_Predict) + (1 << DesignerType.DesignerType_BackGround) + (1 << DesignerType.DesignerType_Decoration) + (1 << DesignerType.DesignerType_Decoration_Frame),
   Character = (1 << DesignerType.DesignerType_ModelEdit) + (1 << DesignerType.DesignerType_Action) + (1 << DesignerType.DesignerType_Emotion) + (1 << DesignerType.DesignerType_Light),

   PreDesign     = DesignerType.DesignerType_Predict,
   Bg            = DesignerType.DesignerType_BackGround,
   Decorate      = DesignerType.DesignerType_Decoration,
   DecorateFrame = DesignerType.DesignerType_Decoration_Frame,
   ModelEdit     = DesignerType.DesignerType_ModelEdit,
   Action        = DesignerType.DesignerType_Action,
   Emotion       = DesignerType.DesignerType_Emotion,
   Lighting      = DesignerType.DesignerType_Light,
}

-- ID值取自于 "H红点表.xlsx|红点名字表"
local RedDotIDs = {
    Bg = 100,
    Decorate = 101,
    DecorateFrame = 102,
}

local MainTabs = {
    {
        Key = TabTypes.Design,
        Name = LSTR(60001), --"装饰设计"
        Children = {
            {
                Key = TabTypes.PreDesign,
                Name = EnumAlias(DesignerType, TabTypes.PreDesign) or ""
            },
            {
                Key = TabTypes.Bg,
                Name = EnumAlias(DesignerType, TabTypes.Bg) or "",
                RedDot2ID = RedDotIDs.Bg,
            },
            {
                Key = TabTypes.Decorate,
                Name = EnumAlias(DesignerType, TabTypes.Decorate) or "",
                RedDot2ID = RedDotIDs.Decorate,
            },
            {
                Key = TabTypes.DecorateFrame,
                Name = EnumAlias(DesignerType, TabTypes.DecorateFrame) or "",
                RedDot2ID = RedDotIDs.DecorateFrame,
            },
        }
    },
    {
        Key = TabTypes.Character,
        Name = LSTR(60002), -- "人物设计"
        Children = {
            {
                Key = TabTypes.ModelEdit,
                Name = EnumAlias(DesignerType, TabTypes.ModelEdit) or ""
            },
            {
                Key = TabTypes.Action,
                Name = EnumAlias(DesignerType, TabTypes.Action) or ""
            },
            {
                Key = TabTypes.Emotion,
                Name = EnumAlias(DesignerType, TabTypes.Emotion) or ""
            },
            {
                Key = TabTypes.Lighting,
                Name = EnumAlias(DesignerType, TabTypes.Lighting) or ""
            },
        }
    }
}

local FilterType = {
    All      = 1,
    Owned    = 2,
    NotOwned = 3,
}

local DesignFilterList = {
    {
        Type = FilterType.All,
		Name = LSTR(60003), -- "全部"
    },
    {
        Type = FilterType.Owned,
		Name = LSTR(60004), -- "已拥有"
    },
    {
        Type = FilterType.NotOwned,
		Name = LSTR(60005), -- "未拥有"
    },
}

local EmotionFilterList = {
    {
        Type = FilterType.All,
		Name = LSTR(60003), -- "全部"
    },
    {
        Type = FilterType.Owned,
		Name = LSTR(60006), -- "已学会"
    },
    {
        Type = FilterType.NotOwned,
		Name = LSTR(60007), -- "未学会"
    },
}

-- 图片保存策略
local ImgSaveStrategy = {
    CurProf = 0, -- 当前职业
    AllProf = 1, -- 全部职业
}

local DefaultCancelActionID = 7014

local PersonPortraitDefine = {
    MinDistance                 = MinDistance, 
    MaxDistance                 = MaxDistance,
    MinFOV                      = MinFOV, 
    MaxFOV                      = MaxFOV, 
    MinRotate                   = MinRotate, 
    MaxRotate                   = MaxRotate, 
    MinPitch                    = MinPitch,
    MaxPitch                    = MaxPitch,
    SliderMaxFOV                = SliderMaxFOV,
    MaxSavedPortraitImageNum    = MaxSavedPortraitImageNum,
    IntensityMaxValue           = IntensityMaxValue,
    ColorChannelMaxValue        = ColorChannelMaxValue,
    MontageZero                 = MontageZero,

    TabTypes            = TabTypes,
    RedDotIDs           = RedDotIDs,
    MainTabs            = MainTabs,
    FilterType          = FilterType,
    DesignFilterList    = DesignFilterList,
    EmotionFilterList   = EmotionFilterList,

    ImgSaveStrategy = ImgSaveStrategy,
    DefaultCancelActionID = DefaultCancelActionID,
}

return PersonPortraitDefine