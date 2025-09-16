--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-02-24 19:41:15
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-02-24 20:11:53
FilePath: \Script\Game\Common\Frame\Define\CommonSelectSideBarDefine.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LSTR = _G.LSTR
local ProtoCommon = require("Protocol/ProtoCommon")
local UIViewID = require("Define/UIViewID")

--- 侧边栏主界面类型(快捷释放/ 地图设置)
local PanelType = {
    EasyToUse = 1,
    MapSetting = 2,
}

--- 侧边栏页面Size
local PanelSize = {
    [PanelType.EasyToUse] = 850
}

local EasyToUseTabType = {
    Emoji = 1,
    ItemUse = 2,
    Companion = 3,
    FashionDeco = 4,
    Mount = 5
}
-- TabItemEx:
-- {
--     {
--         Type = 1,                         -- 和Index相同
--         Title = LSTR(123456),             -- 显示Title
--         NormalIcon = "PaperSprite'/Game/UI/Atlas/FashionDeco/Frames/UI_FashionDeco_Icon_Handheld_Noraml_png.UI_FashionDeco_Icon_Handheld_Noraml_png'",    -- 非选中时页签Icon
--         SelectedIcon = "PaperSprite'/Game/UI/Atlas/FashionDeco/Frames/UI_FashionDeco_Icon_Handheld_Select_png.UI_FashionDeco_Icon_Handheld_Select_png'",  -- 选中后页签Icon
--         ChildWidget = "NewBag/BagPropsSideFrame_UIBP",      -- 被挂载Bp路径
--         HelpInfoID = 10086 -- 帮助说明ID 不填则隐藏帮助按钮
--         ModuleID =  ProtoCommon.ModuleID.ModuleIDDailyRand, -- 用来控制解锁 默认解锁
--         CheckOpenFunc = function() .... end     -- return boolean -- 额外解锁条件 控制页签解锁(页签显示) 默认解锁
--         TabIsShowFunc = function() .... end     -- return boolean -- 页签是否显示在侧边栏 默认展示
--     },
-- }

--- TabData
local EasyToUseSelectData= {
    {
        Type = EasyToUseTabType.Emoji,
        Title = LSTR(210001),
        NormalIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_EmoAct_Noraml.UI_Icon_EmoAct_Noraml'",
        SelectedIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_EmoAct_Select.UI_Icon_EmoAct_Select'",
        ChildWidget = "EmoAct/EmoActMainPanel_UIBP",
        HelpInfoID = -1,
        HelpInfoViewID = UIViewID.EmoActRulesWin,
    },
    {
        Type = EasyToUseTabType.ItemUse,
        Title = LSTR(990130),
        NormalIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_Bag_Noraml.UI_Icon_Bag_Noraml'",
        SelectedIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_Bag_Select.UI_Icon_Bag_Select'",
        ChildWidget = "NewBag/BagPropsSideFrame_UIBP",
    },
    {
        Type = EasyToUseTabType.Companion,
        Title = LSTR(120020),
        NormalIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_Companion_Noraml.UI_Icon_Companion_Noraml'",
        SelectedIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_Companion_Select.UI_Icon_Companion_Select'",
        ChildWidget = "Companion/CompanionListPanel_UIBP",
        ModuleID = ProtoCommon.ModuleID.ModuleIDCompanion,
    },
    {
        Type = EasyToUseTabType.FashionDeco,
        Title = LSTR(1030011),
        NormalIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_FashionDeco_Normal.UI_Icon_FashionDeco_Normal'",
        SelectedIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_FashionDeco_Select.UI_Icon_FashionDeco_Select'",
        ChildWidget = "FashionDeco/FashionDecoSideFrameWin_UIBP",
        ModuleID = ProtoCommon.ModuleID.ModuleIDFashionDecorate,
        HelpInfoID = 11093
    },
    {
        Type = EasyToUseTabType.Mount,
        Title = LSTR(1090020),
        NormalIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_Mount_Noraml.UI_Icon_Mount_Noraml'",
        SelectedIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_Mount_Select.UI_Icon_Mount_Select'",
        ChildWidget = "Mount/MountMainPanel_UIBP",
        ModuleID = ProtoCommon.ModuleID.ModuleIDMount,
    },
}


local MapSettingTabType = {
    Basic = 1, -- 基础显示设置
    Gameplay = 2, -- 玩法标记显示设置
}

local MapSettingSelectData = {
    {
        Type = MapSettingTabType.Basic,
        Title = LSTR(700049),
        NormalIcon = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_SetWin_tab01_png.UI_Map_Icon_SetWin_tab01_png'",
        SelectedIcon = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_SetWin_tab01_Select_png.UI_Map_Icon_SetWin_tab01_Select_png'",
        ChildWidget = "Map/WorldMapSettingPanel_UIBP",
    },
    {
        Type = MapSettingTabType.Gameplay,
        Title = LSTR(700050),
        NormalIcon = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_SetWin_tab02_png.UI_Map_Icon_SetWin_tab02_png'",
        SelectedIcon = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_SetWin_tab02_Select_png.UI_Map_Icon_SetWin_tab02_Select_png'",
        ChildWidget = "Map/WorldMapSettingPanel_UIBP",
        TabIsShowFunc = function()
            if _G.AetherCurrentsMgr:IsAetherCurrentSysOpen()
                or _G.WildBoxMoundMgr:IsOpenAnyBox()
                or _G.DiscoverNoteMgr:IsActiveAnyPerfectPoint() then
                return true
            end

            return false
        end
    },
}


local PanelTabData = {
    [PanelType.EasyToUse]  = EasyToUseSelectData,
    [PanelType.MapSetting] = MapSettingSelectData,
}

local CommonSelectSideBarDefine = {
    PanelType = PanelType,
    PanelSize = PanelSize,
    PanelTabData = PanelTabData,
    EasyToUseTabType = EasyToUseTabType,
    MapSettingTabType = MapSettingTabType,
}

return CommonSelectSideBarDefine