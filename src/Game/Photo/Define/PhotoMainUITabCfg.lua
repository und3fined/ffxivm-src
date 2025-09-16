
local PhotoDefine = require("Game/Photo/PhotoDefine")
local UITabMainDef = PhotoDefine.UITabMain

local Cfg = {
    [UITabMainDef.Camera] = 
    {
        IconPath    = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Photograph_Lens_Normal.UI_Icon_Tab_Photograph_Lens_Normal'",
        Name        = "",
        CB          = nil,
        Params      = nil,
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Photograph_Lens_Select.UI_Icon_Tab_Photograph_Lens_Select'",

    },

    [UITabMainDef.Role] = 
    {
        IconPath    = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Photograph_Role_Normal.UI_Icon_Tab_Photograph_Role_Normal'",
        Name        = "",
        CB          = nil,
        Params      = nil,
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Photograph_Role_Select.UI_Icon_Tab_Photograph_Role_Select'",

    },

    [UITabMainDef.Eff] = 
    {
        IconPath    = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Photograph_Filter_Normal.UI_Icon_Tab_Photograph_Filter_Normal'",
        Name        = "",
        CB          = nil,
        Params      = nil,
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Photograph_Filter_Select.UI_Icon_Tab_Photograph_Filter_Select'",

    },


    [UITabMainDef.Mod] = 
    {
        IconPath    = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Photograph_Template_Normal.UI_Icon_Tab_Photograph_Template_Normal'",
        Name        = "",
        CB          = nil,
        Params      = nil,
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Photograph_Template_Select.UI_Icon_Tab_Photograph_Template_Select'",
    },
}



return Cfg