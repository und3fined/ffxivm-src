---染色分类资源路径
local ColorTypeIconPath = {
    {
        Type = 2,
        --"White"
        IconPath = "PaperSprite'/Game/UI/Atlas/Glamours/Frames/UI_Glamours_Icon_White_png.UI_Glamours_Icon_White_png'"
    },
    {
        Type = 4,
        --"Red"
        IconPath = "PaperSprite'/Game/UI/Atlas/Glamours/Frames/UI_Glamours_Icon_Red_png.UI_Glamours_Icon_Red_png'"
    },
    {
        Type = 5,
        --"Brown"
        IconPath = "PaperSprite'/Game/UI/Atlas/Glamours/Frames/UI_Glamours_Icon_Brown_png.UI_Glamours_Icon_Brown_png'"
    },
    {
        Type = 6,
        --"Yellow"
        IconPath = "PaperSprite'/Game/UI/Atlas/Glamours/Frames/UI_Glamours_Icon_Yellow_png.UI_Glamours_Icon_Yellow_png'"
    },
    {
        Type = 7,
        --"Green"
        IconPath = "PaperSprite'/Game/UI/Atlas/Glamours/Frames/UI_Glamours_Icon_Green_png.UI_Glamours_Icon_Green_png'"
    },
    {
        Type = 8,
        --"Blue"
        IconPath = "PaperSprite'/Game/UI/Atlas/Glamours/Frames/UI_Glamours_Icon_Blue_png.UI_Glamours_Icon_Blue_png'"
    },
    {
        Type = 9,
        --"Purple"
        IconPath = "PaperSprite'/Game/UI/Atlas/Glamours/Frames/UI_Glamours_Icon_Purple_png.UI_Glamours_Icon_Purple_png'"
    },
    {
        Type = 10,
        --"Rainbow"
        IconPath = "PaperSprite'/Game/UI/Atlas/Buddy/Frames/UI_Buddy_Icon_Surface_Colour_png.UI_Buddy_Icon_Surface_Colour_png'"
    }
}

local ColorValue = {
    {
        Type = 4,
        Color = "913b30ff",
        IconPath = "PaperSprite'/Game/UI/Atlas/Buddy/Frames/UI_Buddy_Icon_Surface_Color_png.UI_Buddy_Icon_Surface_Color_png'"
    },
    {
        Type = 5,
        Color = "6e3d24ff",
        IconPath = "PaperSprite'/Game/UI/Atlas/Buddy/Frames/UI_Buddy_Icon_Surface_Color_png.UI_Buddy_Icon_Surface_Color_png'"
    },
    {
        Type = 6,
        Color = "dbb457ff",
        IconPath = "PaperSprite'/Game/UI/Atlas/Buddy/Frames/UI_Buddy_Icon_Surface_Color_png.UI_Buddy_Icon_Surface_Color_png'"
    },
    {
        Type = 7,
        Color = "406339ff",
        IconPath = "PaperSprite'/Game/UI/Atlas/Buddy/Frames/UI_Buddy_Icon_Surface_Color_png.UI_Buddy_Icon_Surface_Color_png'"
    },
    {
        Type = 8,
        Color = "437290ff",
        IconPath = "PaperSprite'/Game/UI/Atlas/Buddy/Frames/UI_Buddy_Icon_Surface_Color_png.UI_Buddy_Icon_Surface_Color_png'"
    },
    {
        Type = 9,
        Color = "877faeff",
        IconPath = "PaperSprite'/Game/UI/Atlas/Buddy/Frames/UI_Buddy_Icon_Surface_Color_png.UI_Buddy_Icon_Surface_Color_png'"
    },
    {
        Type = 2,
        Color = "afaca2ff",
        IconPath = "PaperSprite'/Game/UI/Atlas/Buddy/Frames/UI_Buddy_Icon_Surface_Color_png.UI_Buddy_Icon_Surface_Color_png'"
    },
    {
        Type = 10,
        Color = "ffffffff",
        IconPath = "PaperSprite'/Game/UI/Atlas/Buddy/Frames/UI_Buddy_Icon_Surface_Colour_png.UI_Buddy_Icon_Surface_Colour_png'"
    }
}

local SurfaceArmorMenu = {
    {
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Partner_Mate_Normal.UI_Icon_Tab_Partner_Mate_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Partner_Mate_Select.UI_Icon_Tab_Partner_Mate_Select'",
    },
   -- {
        --IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Partner_Stain_Normal.UI_Icon_Tab_Partner_Stain_Normal'",
        --SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Partner_Stain_Select.UI_Icon_Tab_Partner_Stain_Select'",
  -- },
}

local ErrorTipsId_NotCallBuddy = 308001

local BuddyDefine = {
    ColorTypePath = ColorTypeIconPath,
	MonsterID = 20350000,
    ColorValue = ColorValue,
    ErrorTipsId_NotCallBuddy = ErrorTipsId_NotCallBuddy,
    SurfaceArmorMenu = SurfaceArmorMenu
}

return BuddyDefine
