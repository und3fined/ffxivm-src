
local ActivityPageCfg = require("TableCfg/ActivityPageCfg")
local ProtoRes = require("Protocol/ProtoRes")

--- 编辑部队信息Tabs
local OpsNewbieStrategyTabs = {
    {
        Index = 1, --获取页签位置用
        Key = 1,
        -- LSTR string:首选
        --Name = LSTR(920027),
        NameUKey = 920027,
        --ActivityID
    },
    {
        Index = 2, --获取页签位置用
        Key = 2,
        -- LSTR string:推荐
        --Name = LSTR(920014),
        NameUKey = 920014,
    },
    {
        Index = 3, --获取页签位置用
        Key = 3,
        -- LSTR string:进阶
        -- Name = LSTR(920025),
        NameUKey = 920025,
    },
}

--- 编辑部队信息Tabs
local PanelKey = {
    FirstChoicePanel = 1,
    RecommendPanel = 2,
    AdvancedPanel = 3,
}

--- 定义活动ID
local ActivityID = {
    OpsNewbieStrategyActivityID = 108, --新人攻略
    FirstChoiceActivityID = 24112001, --新人攻略-首选E
    RecommendActivityID = 24112002, --新人攻略-推荐
    AdvancedActivityID = 24112003, --新人攻略-进阶主界面
    AdvancedEthericActivityID = 24112004, --新人攻略-进阶-以太之光
    AdvancedExploreActivityID = 24112005, --新人攻略-进阶-大陆探索
    AdvancedGoldSauserActivityID = 24112006, --新人攻略-进阶-金碟游乐场
    AdvancedCombatActivityID = 24112007, --新人攻略-进阶-战斗职业
    AdvancedProductionActivityID = 24112008, --新人攻略-进阶-生产职业
    BraveryAwardActivityID = 24112009, --新人攻略-勇气嘉奖

}

--- 定义汇总节点ID，汇总节点ID不做为单独任务项显示在界面上 --todo后续根据策划改动频率看是否配表
local ActivitySummaryNodeID = {
    FirstChoiceActivityNodeID = 2411200101, --新人攻略-首选-汇总节点ID
    RecommendActivityNodeID = 2411200201, --新人攻略-推荐-汇总节点ID
    AdvancedEthericNodeID = 2411200401, --新人攻略-进阶主界面以太之光-汇总节点ID
    AdvancedExploreNodeID = 2411200501, --新人攻略-大陆探索-汇总节点ID
    AdvancedGoldSauserNodeID = 2411200601, --新人攻略-金碟游乐场-汇总节点ID
    AdvancedCombatNodeID = 2411200701, --新人攻略-战斗职业-汇总节点ID
    AdvancedProductionNodeID = 2411200801, --新人攻略-生产职业-汇总节点ID
}

--- 以太之光节点对应的地区ID
local AetherLightNodeAreaID = {
   [2411200402] = 2,
   [2411200405] = 3,
   [2411200408] = 1,
}

--- 以太之光节点对应的中转跳转界面数据
local AetherLightNodeJumpPanelData = {
    [2411200402] = {
        AetherLightTextUkey = 920035,
        AetherCrystalTextUkey = 920036,
    },
    [2411200405] = {
        AetherLightTextUkey = 920037,
        AetherCrystalTextUkey = 920038,
    },
    [2411200408] = {
        AetherLightTextUkey = 920039,
        AetherCrystalTextUkey = 920040,
    },
 }

--- 以太之光图标
local AetherLightIcon = {
    BigAetherLightIconPath = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060453.UI_Icon_060453'",
    BigAetherLightGrayIconPath = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060453_gray.UI_Icon_060453_gray'",
    SmallAetherLightIconPath = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060430.UI_Icon_060430'",
    SmallAetherLightGrayIconPath = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060430_gray.UI_Icon_060430_gray'",
 }

--- 复合跳转节点ID
local JumpNodeID = {
    DeepCultivation = 2411200703, --深度养成
    EquipmentUpgrade = 2411200704, --装备提升
    AllaganTomestonePoetics = 2411200705, --神典石
    TerrestrialMessengerCareerAdvancement = 2411200802, --大地使者职业提升
    SkilledCraftsmanCareerAdvancement = 2411200803, --能工巧匠职业提升
}

--- 中间跳转节点数据 ---todo 后续配表
local JumpNodePanelData = {
    [2411200703] = 
    {
        [1] = {
            ItemViewType = 0,
            -- LSTR string:获取职业经验途径
            --TitleText = LSTR(920021),
            TitleTextUKey = 920021,
        },
        [2] = {
            ItemViewType = 1,
            -- LSTR string:完成主线任务
            --ContentText = LSTR(920008),
            ContentTextUKey = 920008,
            Icon = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Main_Remain_png.UI_Icon_Hud_Main_Remain_png'",
        },
        [3] = {
            ItemViewType = 1,
            -- LSTR string:完成冒险系统每日随机任务
            --ContentText = LSTR(920009),
            ContentTextUKey = 920009,
            Icon = "Texture2D'/Game/Assets/Icon/061000/UI_Icon_061808.UI_Icon_061808'",
        },
        [4] = {
            ItemViewType = 0,
            -- LSTR string:特职信息
            --TitleText = LSTR(920018),
            TitleTextUKey = 920018,
        },
        [5] = {
            ItemViewType = 1,
            -- LSTR string:查看职业信息
            --ContentText = LSTR(920017),
            ContentTextUKey = 920017,
            Icon = "Texture2D'/Game/UI/Texture/Ops/OpsNewbieStrategy/UI_NewbieStrategy_Icon_MultipleOccupations.UI_NewbieStrategy_Icon_MultipleOccupations'",
        },
        [6] = {
            ItemViewType = 1,
            -- LSTR string:完成特职任务
            --ContentText = LSTR(920011),
            ContentTextUKey = 920011,
            Icon = "PaperSprite'/Game/UI/Atlas/MapIcon/Frames/UI_Icon_Map_Plus_Missed_png.UI_Icon_Map_Plus_Missed_png'",
        },
    }, --深度养成
    [2411200704] = 
    {
        [1] = {
            ItemViewType = 0,
            -- LSTR string:获取装备主要途径
            --TitleText = LSTR(920022),
            TitleTextUKey = 920022,
        },
        [2] = {
            ItemViewType = 1,
            -- LSTR string:神典石兑换
            --ContentText = LSTR(920019),
            ContentTextUKey = 920019,
            Icon = "Texture2D'/Game/UI/Texture/Ops/OpsNewbieStrategy/UI_NewbieStrategy_Icon_GodStone.UI_NewbieStrategy_Icon_GodStone'",
        },
        [3] = {
            ItemViewType = 1,
            -- LSTR string:市场交易
            --ContentText = LSTR(920013),
            ContentTextUKey = 920013,
            Icon = "PaperSprite'/Game/UI/Atlas/Main2nd/Frames/UI_Main2nd_Btn_Market_png.UI_Main2nd_Btn_Market_png'",
        },
        [4] = {
            ItemViewType = 1,
            -- LSTR string:商会
            --ContentText = LSTR(920007),
            ContentTextUKey = 920007,
            Icon = "PaperSprite'/Game/UI/Atlas/Main2nd/Frames/UI_Main2nd_Btn_Shop_png.UI_Main2nd_Btn_Shop_png'",
        },
    }, --装备提升
    [2411200705] = 
    {
        [1] = {
            ItemViewType = 0,
            -- LSTR string:获取神典石主要途径
            --TitleText = LSTR(920020),
            TitleTextUKey = 920020,
        },
        [2] = {
            ItemViewType = 1,
            -- LSTR string:完成冒险系统每日随机任务
            --ContentText = LSTR(920009),
            ContentTextUKey = 920009,
            Icon = "Texture2D'/Game/Assets/Icon/061000/UI_Icon_061808.UI_Icon_061808'",
        },
        [3] = {
            ItemViewType = 1,
            -- LSTR string:副本挑战
            --ContentText = LSTR(920003),
            ContentTextUKey = 920003,
            Icon = "PaperSprite'/Game/UI/Atlas/Main2nd/Frames/UI_Main2nd_Btn_PWorld_png.UI_Main2nd_Btn_PWorld_png'",
        },
    }, --神典石
    [2411200707] = 
    {
        [1] = {
            ItemViewType = 0,
            -- LSTR string:获取神典石主要途径
            --TitleText = LSTR(920020),
            TitleTextUKey = 920020,
        },
        [2] = {
            ItemViewType = 1,
            -- LSTR string:完成冒险系统每日随机任务
            --ContentText = LSTR(920009),
            ContentTextUKey = 920009,
            Icon = "Texture2D'/Game/Assets/Icon/061000/UI_Icon_061808.UI_Icon_061808'",
        },
        [3] = {
            ItemViewType = 1,
            -- LSTR string:副本挑战
            --ContentText = LSTR(920003),
            ContentTextUKey = 920003,
            Icon = "PaperSprite'/Game/UI/Atlas/Main2nd/Frames/UI_Main2nd_Btn_PWorld_png.UI_Main2nd_Btn_PWorld_png'",
        },
    }, --真理神典石
    [2411200802] = 
    {
        [1] = {
            ItemViewType = 0,
            -- LSTR string:获取职业经验途径
            --TitleText = LSTR(920021),
            TitleTextUKey = 920021,
        },
        [2] = {
            ItemViewType = 1,
            -- LSTR string:完成职业任务
            ContentTextUKey = 920043,
            Icon = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Plus_Missed_png.UI_Icon_Hud_Plus_Missed_png'",
        },
        [3] = {
            ItemViewType = 1,
            -- LSTR string:完成理符任务
            ContentTextUKey = 920041,
            Icon = "PaperSprite'/Game/UI/Atlas/Main2nd/Frames/UI_Main2nd_Btn_LeveQuest_png.UI_Main2nd_Btn_LeveQuest_png'",
        },
        [4] = {
            ItemViewType = 0,
            -- LSTR string:生产职业
            TitleTextUKey = 920042,
        },
        [5] = {
            ItemViewType = 1,
            -- LSTR string:查看职业信息
            ContentTextUKey = 920017,
            Icon = "Texture2D'/Game/UI/Texture/Ops/OpsNewbieStrategy/UI_NewbieStrategy_Icon_MultipleOccupations.UI_NewbieStrategy_Icon_MultipleOccupations'",
        },
    }, --大地使者职业提升
    [2411200803] = 
    {
        [1] = {
            ItemViewType = 0,
            -- LSTR string:获取职业经验途径
            --TitleText = LSTR(920021),
            TitleTextUKey = 920021,
        },
        [2] = {
            ItemViewType = 1,
            -- LSTR string:完成职业任务
            ContentTextUKey = 920043,
            Icon = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Plus_Missed_png.UI_Icon_Hud_Plus_Missed_png'",
        },
        [3] = {
            ItemViewType = 1,
            -- LSTR string:完成理符任务
            ContentTextUKey = 920041,
            Icon = "PaperSprite'/Game/UI/Atlas/Main2nd/Frames/UI_Main2nd_Btn_LeveQuest_png.UI_Main2nd_Btn_LeveQuest_png'",
        },
        [4] = {
            ItemViewType = 0,
            -- LSTR string:生产职业
            TitleTextUKey = 920042,
        },
        [5] = {
            ItemViewType = 1,
            -- LSTR string:查看职业信息
            ContentTextUKey = 920017,
            Icon = "Texture2D'/Game/UI/Texture/Ops/OpsNewbieStrategy/UI_NewbieStrategy_Icon_MultipleOccupations.UI_NewbieStrategy_Icon_MultipleOccupations'",
        },
    },  --能工巧将职业提升
}

local NewbieStrategyStrParamType = {
    StrategyJump  = 1,  --攻略网站跳转/待接入
    PluralJump = 2,   --复合跳转
    Icon = 3, --图标
    ShieldCrystalID = 4, --屏蔽的水晶id
}

---部分图标着色不同，在这里配置
local NewbieStrategyNodeIconColor = {
    NormalColor  = "7D664BFF",  --正常颜色
    AetherLightColor = "ffffffff",   --以太之光节点颜色
}
--- 纯显示节点类型
local ShowNodeType = {
    ActivityData = 1, ---活动整体显示数据（活动未解锁提示等）
}

--- 进阶活动大图标/策划表示不会改，不进表
local NewbieStrategyNodeBigIcon = {
    [24112004] = "Texture2D'/Game/UI/Texture/Ops/OpsNewbieStrategy/UI_NewbieStrategy_Img_LightofEther.UI_NewbieStrategy_Img_LightofEther'",--新人攻略-进阶-以太之光
    [24112005] = "Texture2D'/Game/UI/Texture/Ops/OpsNewbieStrategy/UI_NewbieStrategy_Img_ContinentalExploration.UI_NewbieStrategy_Img_ContinentalExploration'",--新人攻略-进阶-大陆探索
    [24112006] = "Texture2D'/Game/UI/Texture/Ops/OpsNewbieStrategy/UI_NewbieStrategy_Img_GoldSauser.UI_NewbieStrategy_Img_GoldSauser'",--新人攻略-进阶-金碟游乐场
    [24112007] = "Texture2D'/Game/UI/Texture/Ops/OpsNewbieStrategy/UI_NewbieStrategy_Img_JobCombat.UI_NewbieStrategy_Img_JobCombat'",--新人攻略-进阶-战斗职业
    [24112008] = "Texture2D'/Game/UI/Texture/Ops/OpsNewbieStrategy/UI_NewbieStrategy_Img_Crafter.UI_NewbieStrategy_Img_Crafter'",--新人攻略-进阶-生产职业
}

local UnlockTipsID = 141001

local OperationPageActionType = {
    FirstChoiceActivityMenu = 1, --新人攻略-首选-页签点击
    RecommendActivityMenu = 2, --新人攻略-推荐-页签点击
    AdvancedActivityMenu = 3, --新人攻略-进阶-页签点击
    AdvancedEtheric = 4, --新人攻略-进阶主界面以太之光-点击
    AdvancedGoldSauser = 5, --新人攻略-金碟游乐场-点击
    AdvancedExplore = 6, --新人攻略-大陆探索-点击
    AdvancedCombat = 7, --新人攻略-战斗职业-点击
    AdvancedProduction = 8, --新人攻略-生产职业-点击
    BraveryAwardActivity = 9, --新人攻略-勇气嘉奖-点击打开界面
    InfoBtnCkicked = 10, --新人攻略-活动规则界面点击
    StrategyBtnCkicked = 11, --新人攻略-攻略按钮点击 -- 功能暂未开发
    JumpToBtnCkicked = 12, --新人攻略-前往按钮点击
    SecondWinJumpToBtnCkicked = 13, --新人攻略-二级界面前往按钮点击
}

---新人攻略页签下标（活动中心的）
local OpsNewbieStrategyMenuIndex = 3

local ShowAppStoreRatingNodeID = 2411200104

local OpsNewbieStrategyDefine = 
{
    OpsNewbieStrategyTabs = OpsNewbieStrategyTabs,
    PanelKey = PanelKey,
    ActivityID = ActivityID,
    ActivitySummaryNodeID = ActivitySummaryNodeID,
    AetherLightNodeAreaID = AetherLightNodeAreaID,
    AetherLightIcon = AetherLightIcon,
    JumpNodeID = JumpNodeID,
    JumpNodePanelData = JumpNodePanelData,
    OpsNewbieStrategyMenuIndex = OpsNewbieStrategyMenuIndex,
    NewbieStrategyStrParamType = NewbieStrategyStrParamType,
    AetherLightNodeJumpPanelData = AetherLightNodeJumpPanelData,
    ShowNodeType = ShowNodeType,
    NewbieStrategyNodeIconColor = NewbieStrategyNodeIconColor,
    NewbieStrategyNodeBigIcon = NewbieStrategyNodeBigIcon,
    OperationPageActionType = OperationPageActionType,
    UnlockTipsID = UnlockTipsID,
    ShowAppStoreRatingNodeID = ShowAppStoreRatingNodeID,
}

return OpsNewbieStrategyDefine