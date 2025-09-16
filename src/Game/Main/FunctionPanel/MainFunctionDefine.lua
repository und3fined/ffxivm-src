---
--- Author: loiafeng
--- DateTime: 2025-01-07 10:47
--- Description: 主界面右上角功能区按钮定义
---

---@class MainFunctionButtonType 主界面右上角功能按钮类型
local ButtonType = {
    NONE = 0,
    MENU = 1,               -- 菜单
    ROLE = 2,               -- 角色
    ADVENTURE = 3,          -- 冒险
    ACTIVITY = 4,           -- 活动
    STORE = 5,              -- 商城
    BATTLE_PASS = 6,        -- 战令

    SEASON_ACTIVITY = 7,    -- 季节活动
    NEW_VERSION = 8,        -- 新版本内容
    PRE_DOWNLOAD = 9,       -- 预下载
    MUR_SURVEY = 10,        -- 调查问卷
    DEPART_OF_LIGHT = 11,   -- 光之启程
}

---@class MainFunctionButtonConfig
---@field Icon string
---@field RedDotID number? 红点ID

---TODO(loiafeng): @field AllowCustom function 是否允许玩家自定义位置

local Configs = {
    [ButtonType.NONE] = {},

    [ButtonType.MENU] = {
        Icon = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Btn_More_png.UI_Main_Btn_More_png'",
        RedDotID = 1,
    },
    [ButtonType.ROLE] = {
        Icon = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Btn_Major_png.UI_Main_Btn_Major_png'",
        RedDotID = 8000,
    },
    [ButtonType.ADVENTURE] = {
        Icon = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Btn_Adventure_png.UI_Main_Btn_Adventure_png'",
        RedDotID = 2000,
    },
    [ButtonType.ACTIVITY] = {
        Icon = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Btn_Activity_png.UI_Main_Btn_Activity_png'",
        RedDotID = 16001,
    },
    [ButtonType.STORE] = {
        Icon = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Btn_Shop_png.UI_Main_Btn_Shop_png'",
        RedDotID = 17,
    },
    [ButtonType.BATTLE_PASS] = {
        Icon = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Btn_BattlePass_png.UI_Main_Btn_BattlePass_png'",
        RedDotID = 63,
    },

    [ButtonType.SEASON_ACTIVITY] = {
        Icon = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Btn_Activity_png.UI_Main_Btn_Activity_png'",
        RedDotID = 20001,
    },
    [ButtonType.NEW_VERSION] = {
        Icon = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Btn_Activity_png.UI_Main_Btn_Activity_png'",
    },
    [ButtonType.PRE_DOWNLOAD] = {
        Icon = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Btn_PreDownload_png.UI_Main_Btn_PreDownload_png'",
    },
    [ButtonType.MUR_SURVEY] = {
        Icon = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Btn_Questionnaire_png.UI_Main_Btn_Questionnaire_png'",
        RedDotID = 17003,
    },
    [ButtonType.DEPART_OF_LIGHT] = {
        Icon = "Texture2D'/Game/UI/Texture/Departure/UI_Departure_Img_MainPanelEntrance.UI_Departure_Img_MainPanelEntrance'",
        RedDotID = 21000,
    },
}

---GetButtonConfig
---@param Type number @see MainFunctionButtonType
---@return MainFunctionButtonConfig
local function GetButtonConfig(Type)
    return Configs[Type]
end

local function SetConfigButtonIcon(Type, Icon)
     Configs[Type].Icon = Icon
end


---@class MainFunctionDefine
local MainFunctionDefine = {
    ButtonType = ButtonType,
    GetButtonConfig = GetButtonConfig,
    SetConfigButtonIcon = SetConfigButtonIcon,
}

return MainFunctionDefine
