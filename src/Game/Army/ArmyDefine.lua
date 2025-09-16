---@author: daniel 2023-02-03 10:05:46
---@部队的常量定义
local LSTR = _G.LSTR

local PageNums = {15, 15, 15, 15, 15}

local SidebarItemTime = 300 --单位：秒，侧边栏单项展示时间

local GroupScroeID = 19000097

-- LSTR string:%s 转正
local TimeFormat = LSTR(910006)

local DepotRenamePerermission = 8

local MemberQueryTime = 5 ---队员数据查询缓存时间

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ITEM_CLASSIFY_TYPE = ProtoRes.ITEM_CLASSIFY_TYPE
local ITEM_CLASSIFY_TYPE_ITEM_ALL = 100
local ITEM_CLASSIFY_TYPE_EQUIP_ALL = 101
local GroupPermissionClass = ProtoRes.GroupPermissionClass

---仓库状态
local DepotNumState = 
{
	Empty = 1,
    NotFull = 2,
    Full = 3,
}

--- 界面文本配置
local ArmyUITextID = 
{
    InternPerermissionTitle = 1,--- 见习分组权限标题
    InternPerermissionDesc = 2,--- 见习分组权限说明
    GainExpWay = 3, ---部队经验获取途径
}

--- 无部队Tabs
local NoArmyTabs = {
    {
        Key = 1,
        -- LSTR string:加入部队
        Name = LSTR(910076),
    },
    {
        Key = 2,
        -- LSTR string:创建部队
        Name = LSTR(910071),
        RedDotID = 15003,
    },
    -- 邀请页签暂时屏蔽
    {
        Key = 3,
        -- LSTR string:部队署名
        Name = LSTR(910359),
        RedDotID = 15002,
    },
    {
        Key = 4,
        -- LSTR string:邀请列表
        Name = LSTR(910244),
        RedDotID = 5,
    }
}
--- 在部队Tabs
local ArmyTabs = {
    {
        Key = 1,
        -- LSTR string:部队信息
        Name = LSTR(910248),
        RedDotID = 15000,
    },
    {
        Key = 2,
        -- LSTR string:部队成员
        Name = LSTR(910254),
        RedDotID = 3,
        Children = {
            {
                Key = 21,
                -- LSTR string:成员列表
                Name = LSTR(910129),
            },
            {
                Key = 22,
                -- LSTR string:申请列表
                Name = LSTR(910178),
                RedDotID = 4,
            },
            {
                Key = 23,
                -- LSTR string:分组设定
                Name = LSTR(910066),
            }
        }
    },
    {
        Key = 3,
        -- LSTR string:部队福利
        Name = LSTR(910259),
    },
    {
        Key = 4,
        -- LSTR string:部队状态
        Name = LSTR(910258),
    },
    {
        Key = 5,
        -- LSTR string:部队情报
        Name = LSTR(910371),
        RedDotID = 15007,
    }
}

--- 被邀请解锁部队Tabs
local InvitedArmyTabs = {
    {
        Key = 1,
        -- LSTR string:部队署名
        Name = LSTR(910359),
        RedDotID = 15002,
    },
    {
        Key = 2,
        -- LSTR string:邀请列表
        Name = LSTR(910244),
        RedDotID = 5,
    }
}

--- 部队动态筛选类别
local ArmyLogFilterType = {
    {
        Type = 0,
        -- LSTR string:全部
        Name = LSTR(910054),
    },
    {
        Type = 1,
        -- LSTR string:组织
        Name = LSTR(910202),
    },
    {
        Type = 2,
        -- LSTR string:编制
        Name = LSTR(910204),
    },
    {
        Type = 3,
        -- LSTR string:设置
        Name = LSTR(910219),
    },
    {
        Type = 4,
        -- LSTR string:特效
        Name = LSTR(910173),
    },
    {
        Type = 5,
        -- LSTR string:部队储物柜
        Name = LSTR(910249),
    },
}

--- 部队动态筛选枚举
local ArmyLogFilterTypeEnum = {
    Organization = 1,
    Weave = 2,
    Set = 3,
    SpecialEffect = 4,
    ArmyStore = 5,
}

---@deprecated 部队动态筛选类别(废弃)
local LogsTabs = {
    {
        Type = 1,
        -- LSTR string:编辑日志
        Name = LSTR(910205),
        Icon = "Sprite'/Game/UI/Atlas/Army/Frames/UI_Army_Trends_Icon_Star_png.UI_Army_Trends_Icon_Star_png'",
        -- LSTR string:%s编辑了公告
        FormatStr = LSTR(910019)
    },
    {
        Type = 2,
        -- LSTR string:编辑部队信息
        Name = LSTR(910206),
        Icon = "Sprite'/Game/UI/Atlas/Army/Frames/UI_Army_Trends_Icon_Star_png.UI_Army_Trends_Icon_Star_png'",
        -- LSTR string:%s编辑了部队信息
        FormatStr = LSTR(910020)
    },
    {
        Type = 3,
        -- LSTR string:队员加入
        Name = LSTR(910271),
        Icon = "Sprite'/Game/UI/Atlas/Army/Frames/UI_Army_Trends_Icon_Star_png.UI_Army_Trends_Icon_Star_png'",
        -- LSTR string:%s加入部队
        FormatStr = LSTR(910013)
    },
    {
        Type = 4,
        -- LSTR string:队员退出
        Name = LSTR(910272),
        Icon = "Sprite'/Game/UI/Atlas/Army/Frames/UI_Army_Trends_Icon_Star_png.UI_Army_Trends_Icon_Star_png'",
        -- LSTR string:%s退出部队
        FormatStr = LSTR(910021)
    },
    {
        Type = 5,
        -- LSTR string:仓库存入
        Name = LSTR(910033),
        Icon = "Sprite'/Game/UI/Atlas/Army/Frames/UI_Army_Trends_Icon_Star_png.UI_Army_Trends_Icon_Star_png'",
        -- LSTR string:%s存入了%d个%s到%s仓库
        FormatStr = LSTR(910016)
    },
    {
        Type = 6,
        -- LSTR string:仓库取入
        Name = LSTR(910032),
        Icon = "Sprite'/Game/UI/Atlas/Army/Frames/UI_Army_Trends_Icon_Star_png.UI_Army_Trends_Icon_Star_png'",
        -- LSTR string:%s从%s仓库取出了%d个%s
        FormatStr = LSTR(910011)
    },
    {
        Type = 7,
        -- LSTR string:仓库改名
        Name = LSTR(910034),
        Icon = "Sprite'/Game/UI/Atlas/Army/Frames/UI_Army_Trends_Icon_Star_png.UI_Army_Trends_Icon_Star_png'",
        -- LSTR string:%s改名%s%s仓库为%s%s仓库
        FormatStr = LSTR(910017)
    },
    {
        Type = 8,
        -- LSTR string:仓库解锁
        Name = LSTR(910037),
        Icon = "Sprite'/Game/UI/Atlas/Army/Frames/UI_Army_Trends_Icon_Star_png.UI_Army_Trends_Icon_Star_png'",
        -- LSTR string:%s仓库已解锁
        FormatStr = LSTR(910012)
    },
}

--- 部队外界面Type
local ArmyOutUIType = {
    ArmyJoin = 1,
    ArmyCreate = 2,
    ArmySign = 3,
    ArmyInvite = 4,
}

--- 部队内界面Type
local ArmyInUIType = {
    InfoPage = 1, -- 讯息
    MemberPage = 2, ---
    WelfarePage = 3, --- 福利
    StatePage = 4, --- 状态
    InformationPage = 5, --- 情报
    BuildingPage = 6, --- 建设
    ActityPage = 7, --- 活动
}

--- 部队受限解锁界面Type
local ArmyInviteOutUIType = {
    ArmySign = 1,
    ArmyInvite = 2,
}


local ArmyMemberPageType = {
    MemberPage = 1, -- 成员列表
    ApplyJoinPage = 2, -- 申请入队列表
    CategorySettingPage = 3, -- 分组设定
}

local CategoryUIType = {
    Power = 1,
    Part = 2,
    Sort = 3,
}

local ArmyTextColor = {
    BlueHex = "6FB1E9FF",
    YellowHex = "D1BA8EFF",
    NoEnoughRedHex = "DC5868FF",
}

local ConditionIconPath = {
    TrueIcon = "PaperSprite'/Game/UI/Atlas/Army/Frames/UI_Army_Img_Checked_png.UI_Army_Img_Checked_png'",
    FalseIcon = "PaperSprite'/Game/UI/Atlas/Army/Frames/UI_Army_Img_Unchecked_png.UI_Army_Img_Unchecked_png'",
}

local DefaluBadgeBgIcon = "Texture2D'/Game/Assets/Icon/090000/UI_Icon_090449.UI_Icon_090449'"

--- 全局配置类别
local GlobalCfgType = {
    NameMinLimit = 1, -- 部队名称最小长度
    NameMaxLimit = 2, -- 部队名称最大长度
    ShortNameMinLimit = 3, -- 部队简称最小长度
    ShortNameMaxLimit = 4, -- 部队简称最大长度
    EditNoticeMinLimit = 5, -- 部队公告最小长度
    EditNoticeMaxLimit = 6, -- 部队公告最大长度
    RecruitSloganMinLimit = 7, -- 招募标语最小长度
    RecruitSloganMaxLimit = 8, -- 招募标语最大长度
    CreateArmyScoreType = 9, -- 创建部队所需积分类型
    CreateArmyNeedGold = 10, -- 创建部队所需金币
    DynamicLogsMaxLimit = 11, -- 动态日志最大数量
    ArmyUpgradeScoreType = 14, -- 部队升级所需积分类型
    RoleInvitedMaxLimit = 15, -- 角色收到部队邀请最大数量
    TransferLeaderTimeInterval = 16, -- 转让部队长时间间隔
    NewLeaderJoinedTimeMinLimit = 17, -- 新部队长加入部队最小时间
    InviteRecordValidity = 18, -- 邀请有效期
    ApplyMsgMaxLimit = 19, -- 申请入队留言最大长度
    CategoryClassifyMaxLimit = 20, -- 分组分类最大数量
    CategoryNameMinLimit = 21, -- 分组名称最小长度
    CategoryNameMaxLimit = 22, -- 分组名称最大长度
    CreateArmyAgainTimeInterval = 23, -- 再次创建部队时间间隔
    EditEmblemTimeInterval = 24, -- 编辑部队徽章时间间隔
    EditNameTimeInterval = 25, -- 编辑部队名称时间间隔
    EditShortNameTimeInterval = 26, -- 编辑部队简称时间间隔
    DefaultPermissions = 27, -- 默认权限
    DefaultMajorCategoryName = 28, -- 部队默认分组1名字
    DefaultMinorCategoryName = 29, -- 部队默认分组2名字
    CategoryUpNeedTime = 30, -- N小时后从见习晋升为成员
    ToGroupScoreRate = 31, -- 每获得M点个人战绩，则增加N点公会战绩
    GroupStorePageNum = 32, -- 仓库数量
    GroupStoreDefaultGridNum = 33, -- 仓库默认容量
    GroupStoreExtraGridNum = 34,-- 仓库可扩容数量
    GroupScoreMax = 35, -- 公会战绩上限
    GroupStoreNameCategoryMin = 36, -- 仓库名字最少字符数量
    GroupStoreNameCategoryMax = 37,-- 仓库名字最多字符数量
    GroupGiftScoreMax = 38, -- 礼物价值上限
    GroupShopId = 39,--部队商店id
    GlobalCfgGroupApplyCD = 40,-- 申请加入部队的CD
    GlobalCfgGroupOpenLevel = 41,-- 部队系统解锁等级
    GlobalCfgGroupBonusStateNum = 42, --【加成状态】可持有数量
    GlobalCfgGroupBonusStateUpNum = 43,--【加成状态】可生效数量
    GlobalCfgMoneyBagDepositMaxNum = 44,---【金币储物柜】可存入金币总上限
    GlobalCfgMoneyBagSingleDepositMinNum = 45,---【金币储物柜】单笔可存入金币最小数量
    GlobalCfgMoneyBagResID = 46, ---【金币储物柜】金币储物柜货币资源id
    GlobalCfgGroupDefaultMemberNum = 47, ---部队默认成员数量
    GlobalCfgGroupInvitePopupTime = 48, ---【部队邀请】N小时后，不需要弹窗提示
    GlobalCfgGroupSignNum = 49, ---【署名】署名人数
    GlobalCfgGroupSignInviteValidTime = 50, ---【署名】署名邀请有效时长
    GlobalCfgGroupExpExchangeFriendExpRate = 51, ---【友好关系】部队等级经验转换为友好关系经验的比例
    GlobalCfgCompanySealNumExchangeFriendExpRate = 52, ---【友好关系】军票数量转换为友好关系经验的比例
    GlobalCfgGrandCompanyChangeCD = 53, ---国防联军转换CD
    GlobalCfgGrandCompanyChangeCost = 54, ---国防联军转换花费(资源ID,资源数量)
}

local UnitedArmyTabs = {
    {
        ID = 1,
        -- LSTR string:黑涡团
        Name = LSTR(910275),
        BigIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Img_Flag_HeiWo.UI_Army_Img_Flag_HeiWo'",
        SmallIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Image_HeiWo.UI_Army_Image_HeiWo'",
        BGIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Img_BigFlag_HeiWo.UI_Army_Img_BigFlag_HeiWo'",
        --- 固定图片不走表了，直接配置在这
        BigBGIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Img_BG_HeiWo.UI_Army_Img_BG_HeiWo'",
        LineIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Img_HeiWo_Line.UI_Army_Img_HeiWo_Line'",
        MaskColor = "181a1c80",
        AnimFlagIcon = "MaterialInstanceConstant'/Game/UMG/UI_Effect/Material/MI_DX_Flag/MI_DX_Flag_Army_HeiWo_2.MI_DX_Flag_Army_HeiWo_2'",
    },
    {
        ID = 2,
        -- LSTR string:双蛇党
        Name = LSTR(910079),
        BigIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Img_Flag_ShuangShe.UI_Army_Img_Flag_ShuangShe'",
        SmallIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Image_ShuangShe.UI_Army_Image_ShuangShe'",
        BGIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Img_BigFlag_ShuangShe.UI_Army_Img_BigFlag_ShuangShe'",
        --- 固定图片不走表了，直接配置在这
        BigBGIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Img_BG_ShuangShe.UI_Army_Img_BG_ShuangShe'",
        LineIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Img_ShuangShe_Line.UI_Army_Img_ShuangShe_Line'",
        MaskColor = "13151180",
        AnimFlagIcon = "MaterialInstanceConstant'/Game/UMG/UI_Effect/Material/MI_DX_Flag/MI_DX_Flag_ShuangShe_2.MI_DX_Flag_ShuangShe_2'",
    },
    {
        ID = 3,
        -- LSTR string:恒辉队
        Name = LSTR(910124),
        BigIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Img_Flag_HengHui.UI_Army_Img_Flag_HengHui'",
        SmallIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Image_HengHui.UI_Army_Image_HengHui'",
        BGIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Img_BigFlag_HengHui.UI_Army_Img_BigFlag_HengHui'",
        --- 固定图片不走表了，直接配置在这
        BigBGIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Img_BG_HengHui.UI_Army_Img_BG_HengHui'",
        LineIcon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Img_HengHui_Line.UI_Army_Img_HengHui_Line'",
        MaskColor = "1c1a1a80",
        AnimFlagIcon = "MaterialInstanceConstant'/Game/UMG/UI_Effect/Material/MI_DX_Flag/MI_DX_Flag_HengHui_2.MI_DX_Flag_HengHui_2'",
    },
}
---ID保持和一级权限一致,方便获取数据
local ArmyWelfareTabs = {
    {
        ID = 1,
        -- LSTR string:部队储物柜
        Name = LSTR(910249),
        Icon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Icon_Welfare_02.UI_Army_Icon_Welfare_02'"
    },
    {
        ID = 3,
        -- LSTR string:部队特效
        Name = LSTR(910257),
        Icon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Icon_Welfare_03.UI_Army_Icon_Welfare_03'"
    },
    {
        ID = 4,
        -- LSTR string:部队商店
        Name = LSTR(910252),
        Icon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Icon_Welfare_01.UI_Army_Icon_Welfare_01'"
    },
    {
        ID = 13,
        -- LSTR string:部队房屋
        Name = LSTR(910256),
        Icon = "Texture2D'/Game/UI/Texture/Army/UI_Army_Icon_Welfare_04.UI_Army_Icon_Welfare_04'"
    },
}

---部队福利枚举
local ArmyWelfarePageId = {
    Store = 1, --- 部队仓库
    SE = 3, --- 部队特效
    Shop = 4, --- 部队商城
    House = 13, --- 部队房屋
}

--- 默认分组
local DefineCategorys = {
    -- LSTR string:部队长
    LeaderName = LSTR(910264),
    -- LSTR string:成员
    MemName = LSTR(910128),
}

--- 编辑名称类别
local ArmyEditTextType = {
    ArmyName = 0, -- 部队名称
    ShortName = 1, -- 简称
    RecruitSlogan = 2, -- 招募标语
    Notice = 3,
}

--- 徽章类别
local ArmyBadgeType = {
    Implied = 0,
    Shield = 1,
    ShieldBg = 2 -- 盾纹背景
}

--- 分组排序 ShowIndex
---@param A any
---@param B any
local ArmyCategorySortFunc = function(A, B)
    return A.ShowIndex < B.ShowIndex
end

--- 部队升级权限类型
local ArmyUpLevelPerermissionType = {
    ArmyStorageLocker = 1, --- 仓库数量增加
    ArmyMemberNumUp = 2, ---扩大招募，部队人数增加
    ArmySELevel = 3, ---特效购买等级
    ArmyShopLevel = 4, ---商店等级
}

local ArmyRedDotID = {
    [ProtoCS.GroupRedDotType.GroupRedDotTypeApply] = 4,
    [ProtoCS.GroupRedDotType.GroupRedDotTypeInvite] = 5,
    [ProtoCS.GroupRedDotType.GroupRedDotTypeBag] = 6,
    [ProtoCS.GroupRedDotType.GroupRedDotTypeSignInvite] = 15006,
    [ProtoCS.GroupRedDotType.GroupRedDotTypeSignFull] = 15005,
    Army = 2,
    ArmyMemberTab = 3,
    ArmyInfo = 15000,
    ArmyRecruit = 15001,
    ArmyCreate = 15003,
    ArmyCreateRemind = 15004,
    ArmyInformationEditRemind = 15008,
}

local GrandCompanyType = {
    HeiWo = 1,
    ShuangShe = 2,
    HengHui = 3, 
}

--- 编辑部队信息Tabs
local ArmyInfoEditTabs = {
    {
        Key = 1,
        -- LSTR string:基础信息
        Name = LSTR(910092),
    },
    {
        Key = 2,
        -- LSTR string:队徽
        Name = LSTR(910273),
    },
}

local ArmyPermissionsClassData = 
{
    [GroupPermissionClass.GRAND_PERMISSION_CLASS_InfoEdit] =
    {
        -- LSTR string:信息权限编辑
        Name = LSTR(910044),
        Icon = "Sprite'/Game/UI/Atlas/Army/Frames/UI_Army_Member_Class_Icon_Sign6_png.UI_Army_Member_Class_Icon_Sign6_png"
    },
    [GroupPermissionClass.GRAND_PERMISSION_CLASS_STORE] =
    {
        -- LSTR string:储物柜权限
        Name = LSTR(910052),
        Icon = "Sprite'/Game/UI/Atlas/Army/Frames/UI_Army_Member_Class_Icon_Sign10_png.UI_Army_Member_Class_Icon_Sign10_png"
    },
    [GroupPermissionClass.GRAND_PERMISSION_CLASS_MemberManage] =
    {
        -- LSTR string:成员管理权限
        Name = LSTR(910130),
        Icon = "Sprite'/Game/UI/Atlas/Army/Frames/UI_Army_Member_Class_Icon_Sign12_png.UI_Army_Member_Class_Icon_Sign12_png"
    },
}

local ArmyErrorCode = 
{
    ArmyMemberFull = 145005,
    ArmyDisband = 145038,
    CodeJoinedGroup = 145027,
    CodeInOtherGroup = 145009,
    CodeCreateAuthFailed = 145007,
    UseGroupBonusStateTypeError = 145044,
    UseGroupBonusStateNumError = 145043,
    ArmyCreateSameName = 145019,
    NoArmyPleaseJoin = 145026,
    NoPermisstion =  145010,
}

----部队特效获取类型
local ArmyBonusStateGetType = 
{
    Buy = 1, ---购买
    AetherWheel = 2,---以太转轮
    UnOpen = 3,---暂未开放
}

----部队日志类型（新）,需要和服务器保持一致
local ArmyLogType = 
{   
    --- 创建部队
    LogTypeCreateGroup            = 1,  
    --- 部队升级
    LogTypeGroupLevelUp           = 2,  
    --- 部队权限解锁
    LogTypePermissionUnlock       = 3,  
    --- 编辑部队公告
    LogTypeEditGroupNotice        = 4,  
    --- 编辑部队名称
    LogTypeEditGroupName          = 5,  
    --- 编辑部队简称
    LogTypeEditGroupAlias         = 6,  
    --- 编辑部队徽
    LogTypeEditGroupEmblem        = 7,  
    --- 新增阶级
    LogTypeCategoryAdd            = 8,  
    --- 删除阶级
    LogTypeCategoryDelete         = 9,  
    --- 编辑阶级名字
    LogTypeCategoryEditName       = 10, 
    --- 编辑阶级的权限
    LogTypeCategoryEditPermission = 11, 
    --- 队员加入
    LogTypeJoin                   = 12, 
    --- 队员退出
    LogTypeQuit                   = 13, 
    ---【部队仓库】存物品;参数顺序:角色id,道具资源id、道具数量
    LogTypeDepositItem            = 14,
    ---【部队仓库】取物品;参数顺序:角色id,道具资源id、道具数量
    LogTypeFetchItem              = 15, 
    ---设置成员的阶级
    LogTypeSetMemberCategory      = 16, 
    --【加成状态】获得
    LogTypeBonusStateObtain       = 17,
    --【加成状态】使用
    LogTypeBonusStateUse          = 18,
    --【加成状态】取消
    LogTypeBonusStateStop         = 19,
    --【金币储物柜】存
    LogTypeMoneyBagDeposit        = 20,
    --【金币储物柜】取
    LogTypeMoneyBagWithdraw       = 21,
    -- 转国防联军
    LogTypeGrandCompanyChanged    = 22,
    -- 修改部队情报数据
    LogTypeInformatioinChanged    = 23,
}

----部队税率说明id
local ArmyMoneyBagHelpTextID = 
{
    TRADE_MAERKET_PARAM_TAX_DESC_WITH_MONTHCARD = 11059, --无月卡时税率说明
    TRADE_MAERKET_PARAM_TAX_DESC_WITHOUT_MONTHCARD = 11060, --有月卡时税率说明
}

----部队界面跳转id
local ArmySkipPanelID = 
{
    CreatePanel = 1, --创建界面
    InvitePanel = 2, --邀请界面
    InviteSignPanel = 3, --邀请署名界面
}

----部队界面交互功能id
local ArmyPanelInteractID = 
{
    SEPanel = 1, --特效界面
    InfoEditWin = 2, --信息编辑界面
    ShopPanel = 3, --商店界面
    CreatePanel = 4, --创建界面
    TransferWin = 5, -- 转移国防联军弹窗
}

----部队界面路径
local ArmyPanelPath = 
{
    ArmyInfoPanel = "Army/ArmyInfoPage_UIBP", --信息编辑界面
    ArmyCreatePanel = "Army/ArmyCreatePanel_UIBP", --部队创建界面
    ArmyJoinPanel = "Army/ArmyJoinPanel_UIBP", --部队加入界面
    ArmyMemberPanel = "Army/ArmyMemberPanel_UIBP", --部队成员界面
    ArmyWelfarePanel = "Army/ArmyWelfarePanel_UIBP", --部队福利界面
    ArmyStatePanel = "Army/ArmyStatePanel_UIBP", --部队状态界面
    ArmySignDataPanel = "Army/ArmySignInfoPage_UIBP", --部队署名数据界面
    ArmySignInvitePanel = "Army/ArmySignPage_UIBP", --部队署名邀请界面
    ArmyInformationPanel = "Army/ArmyInformationPanel_UIBP", --部队情报界面
    ArmyEmptyPanel = "Army/ArmyEmptyPage_UIBP", --部队空界面
}

----部队转国防联军拦截对话id
local ArmyDialoglibID = 2099609

---请求部队展示信息的界面类型
local ArmyInfoType = 
{
    Info = 1,---信息界面
    JoinInfo = 2,---查看部队界面
    Profile = 3,---情报界面
}

---打开查看部队界面的来源界面
local ArmyOpenJoinInfoType = 
{
    JoinPanel = 1,---加入界面
    InvitePanel = 2,---邀请界面
    OuterPanel = 3,---外部调用
}

--- 部队情报编辑Tabs
local EditArmyInformationTabs = {
    {
        Key = 1,
        -- LSTR string:招募信息
        Name = LSTR(910135),
    },
    {
        Key = 2,
        -- LSTR string:活动信息
        Name = LSTR(910396),
    },
}

local ArmySignJoinTipsID = 145071

local ArmyFlagTextColors = 
{
	Dark = {
		LeaderNameColor = "313131FF",
		LineColor = "000000FF",
		ContentColor = "313131FF",
		IDColor = "313131FF",
		LeaderTextColor = "6C6964FF",
	},
	Nomal = {
		LeaderNameColor = "D5D5D5FF",
		LineColor = "FFFFFFFF",
		ContentColor = "828282FF",
		IDColor = "D5D5D5FF",
		LeaderTextColor = "828282FF",
	},
}

local ArmyTipsID = {
    DataUpdate = 145056,--个人/系统提示/数据发生变动，请刷新重试
    InvitedNoOnline = 145072,--个人/系统提示/邀请失败, 对方不在线                                                                                                                
    InvitedJoinArmy = 145073,--个人/系统提示/邀请失败, 对方已有部队                                                                                                                
    InvitedArmyCreating = 145074,--个人/系统提示/邀请失败, 对方在创建部队状态中                                                                                                                
    InvitedSignOther = 145075,--个人/系统提示/邀请失败, 对方在署名部队状态中                                                                                                                
    InvitedAgreed = 145076,--个人/系统提示/对方已同意你的署名邀请                                                                                                                
    InvitedWaitAgree = 145077,--个人/系统提示/请等待对方确认已有邀请                                                                                                                
    InvitedSucceed = 145078,--个人/系统提示/已发送邀请，请等待对方确认    
    InvitedJoinSelfArmy = 145079,--个人/系统提示/对方已在你的部队中    
    SaveSucceed = 145080,--个人/系统提示/保存成功     
    InvitedInvalidated = 145085,--个人/系统提示/该邀请已失效
    InputCheck = 145088,--个人/系统提示/输入内容识别中
    NoOpenArmyStore = 145093,-- 个人/系统提示/完成35级土神泰坦   
}

local ArmyConditionEnum = 
{
    IsJoin = 1,             --有没有加入部队
    IsLeader = 2,           --是否是部队长
    IsHavePermisstion = 3,  --是否有对应权限（不用同时判断是否有部队，无部队任何权限都会返回假）
    IsUnlock = 4,           --是否已开启部队系统
    IsUnlockSE = 5,         --部队已开启部队特效
    IsUnlockShop = 6,       --部队已开启部队商店
}

local ItemTabs = {
	{
		Type = ITEM_CLASSIFY_TYPE_ITEM_ALL, Name = LSTR(990013), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Noraml.UI_Icon_Tab_Bag_Equip_All_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Select.UI_Icon_Tab_Bag_Equip_All_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_PROP, Name = LSTR(990005), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Props_Noraml.UI_Icon_Tab_Bag_Goods_Props_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Props_Select.UI_Icon_Tab_Bag_Goods_Props_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_FOOD_DRUG, Name = LSTR(990014), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Medicine_Noraml.UI_Icon_Tab_Bag_Goods_Medicine_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Medicine_Select.UI_Icon_Tab_Bag_Goods_Medicine_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_MATERIAL, Name = LSTR(990015), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Market_Material_Noraml.UI_Icon_Tab_Bag_Market_Material_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Market_Material_Select.UI_Icon_Tab_Bag_Market_Material_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_FISH, Name = LSTR(990016), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Fish_Noraml.UI_Icon_Tab_Bag_Goods_Fish_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Fish_Select.UI_Icon_Tab_Bag_Goods_Fish_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_TASK, Name = LSTR(990017), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Task_Noraml.UI_Icon_Tab_Bag_Goods_Task_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Task_Select.UI_Icon_Tab_Bag_Goods_Task_Select'",

	},
}

local EquipTabs = {
	{
		Type = ITEM_CLASSIFY_TYPE_EQUIP_ALL, Name = LSTR(990018), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Noraml.UI_Icon_Tab_Bag_Equip_All_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Select.UI_Icon_Tab_Bag_Equip_All_Select'",
	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_MAIN_HAND, Name = LSTR(990019), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Master_Noraml.UI_Icon_Tab_Bag_Equip_Master_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Master_Select.UI_Icon_Tab_Bag_Equip_Master_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_DEPUTY_HAND, Name = LSTR(990020), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Deputies_Noraml.UI_Icon_Tab_Bag_Equip_Deputies_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Deputies_Select.UI_Icon_Tab_Bag_Equip_Deputies_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_HEAD, Name = LSTR(990021), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Head_Noraml.UI_Icon_Tab_Bag_Equip_Head_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Head_Select.UI_Icon_Tab_Bag_Equip_Head_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_BODY, Name = LSTR(990022), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Body_Noraml.UI_Icon_Tab_Bag_Equip_Body_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Body_Select.UI_Icon_Tab_Bag_Equip_Body_Select'",
	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_ARM, Name = LSTR(990023), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Hand_Noraml.UI_Icon_Tab_Bag_Equip_Hand_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Hand_Select.UI_Icon_Tab_Bag_Equip_Hand_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_LEG, Name = LSTR(990024), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Leg_Noraml.UI_Icon_Tab_Bag_Equip_Leg_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Leg_Select.UI_Icon_Tab_Bag_Equip_Leg_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_FOOT, Name = LSTR(990025), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Foot_Noraml.UI_Icon_Tab_Bag_Equip_Foot_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Foot_Select.UI_Icon_Tab_Bag_Equip_Foot_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_ERR, Name = LSTR(990026), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Eardrops_Noraml.UI_Icon_Tab_Bag_Equip_Eardrops_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Eardrops_Select.UI_Icon_Tab_Bag_Equip_Eardrops_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_NECK, Name = LSTR(990027), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Neck_Noraml.UI_Icon_Tab_Bag_Equip_Neck_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Neck_Select.UI_Icon_Tab_Bag_Equip_Neck_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_FINESSE, Name = LSTR(990028), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Finesse_Noraml.UI_Icon_Tab_Bag_Equip_Finesse_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Finesse_Select.UI_Icon_Tab_Bag_Equip_Finesse_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_RING, Name = LSTR(990029), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Ring_Noraml.UI_Icon_Tab_Bag_Equip_Ring_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Ring_Select.UI_Icon_Tab_Bag_Equip_Ring_Select'",

	},
}

local ArmyStoreOpenConditionID = 20411

local ArmyDefine = {
    Zero = 0,
    One = 1,
    LeaderCID = 1,
    CEditIdx = 2,
    PartCount = 2,
    Half = 2,
    Minutes = 60,
    Hour = 3600,
    Day = 86400,
    Month = 2592000,
    QueryStateTimeOut = 10000,
    QueryOverTime = 3,
    QueryWaitTime = 20,
    ItemSpace = 15,
    SortOffsetX = 135,
    ClassItemHeight = 90,
    ArmyInfoCacheTime = 1800,
    Ten = 10,
    SpaceAsc = 32,
    UnderlineAsc = 95,
    ShowMaxClassNum = 5,
    ScreenOffsetY = 50,
    PageNums = PageNums,
    MainLogsCount = 3,
    NoArmyTabs = NoArmyTabs,
    ArmyBadgeType = ArmyBadgeType,
    ArmyTabs = ArmyTabs,
    ArmyOutUIType = ArmyOutUIType,
    ArmyInUIType = ArmyInUIType,
    CategoryUIType = CategoryUIType,
    ArmyMemberPageType = ArmyMemberPageType,
    UnitedArmyTabs = UnitedArmyTabs,
    DefineCategorys = DefineCategorys,
    ArmyEditTextType = ArmyEditTextType,
    ArmyLogFilterType = ArmyLogFilterType,
    LogsTabs = LogsTabs,
    ArmyCategorySortFunc = ArmyCategorySortFunc,
    GlobalCfgType = GlobalCfgType,
    DefaluBadgeBgIcon = DefaluBadgeBgIcon,
    ArmyTextColor = ArmyTextColor,
    ConditionIconPath = ConditionIconPath,
    SidebarItemTime = SidebarItemTime,
    GroupScroeID = GroupScroeID,
    TimeFormat = TimeFormat,
    ArmyUpLevelPerermissionType = ArmyUpLevelPerermissionType,
    ArmyWelfareTabs = ArmyWelfareTabs,
    ArmyWelfarePageId = ArmyWelfarePageId,
    DepotRenamePerermission = DepotRenamePerermission,
    DepotNumState = DepotNumState,
    ArmyUITextID = ArmyUITextID,
    ArmyRedDotID = ArmyRedDotID,
    GrandCompanyType = GrandCompanyType,
    ArmyInfoEditTabs = ArmyInfoEditTabs,
    ArmyPermissionsClassData = ArmyPermissionsClassData,
    ArmyErrorCode = ArmyErrorCode,
    ArmyLogFilterTypeEnum = ArmyLogFilterTypeEnum,
    ArmyBonusStateGetType = ArmyBonusStateGetType,
    ArmyLogType = ArmyLogType,
    ArmyMoneyBagHelpTextID = ArmyMoneyBagHelpTextID,
    ArmySkipPanelID = ArmySkipPanelID,
    ArmyPanelInteractID = ArmyPanelInteractID,
    MemberQueryTime = MemberQueryTime,
    ArmyPanelPath = ArmyPanelPath,
    ArmyDialoglibID = ArmyDialoglibID,
    ArmyInfoType = ArmyInfoType,
    ArmyOpenJoinInfoType = ArmyOpenJoinInfoType,
    EditArmyInformationTabs = EditArmyInformationTabs,
    InvitedArmyTabs = InvitedArmyTabs,
    ArmyInviteOutUIType = ArmyInviteOutUIType,
    ArmySignJoinTipsID = ArmySignJoinTipsID,
    ArmyFlagTextColors = ArmyFlagTextColors,
    ArmyTipsID = ArmyTipsID,
    ArmyConditionEnum = ArmyConditionEnum,
    ItemTabs = ItemTabs,
	EquipTabs = EquipTabs,
	ITEM_CLASSIFY_TYPE_ITEM_ALL = ITEM_CLASSIFY_TYPE_ITEM_ALL,
	ITEM_CLASSIFY_TYPE_EQUIP_ALL = ITEM_CLASSIFY_TYPE_EQUIP_ALL,
    ArmyStoreOpenConditionID = ArmyStoreOpenConditionID,
}

return ArmyDefine