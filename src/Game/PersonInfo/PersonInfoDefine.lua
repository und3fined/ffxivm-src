local LSTR = _G.LSTR

local DefaultHeadPortraitID = 10001 ---默认头像ID
local MaxPerferredProfCount = 3
local MaxGameStyleCount = 5
local InvisibleHeadIcon = "Texture2D'/Game/UI/Texture/PersonInfo/UI_Img_Invisible_Head.UI_Img_Invisible_Head'"

local ModuleType = {
    BaseInfo    = 1, ---基础信息
    EquipInfo   = 2, ---装备信息
    ProfInfo    = 3, ---职业信息
}

local ModuleListSelf = {
    {
        Type = ModuleType.BaseInfo,
        Name = LSTR(620013),
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Information_Normal.UI_Icon_Tab_Personal_Information_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Information_Select.UI_Icon_Tab_Personal_Information_Select'",
    },
    {
        Type = ModuleType.EquipInfo,
        Name = LSTR(620034),
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Equip_Normal.UI_Icon_Tab_Personal_Equip_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Equip_Select.UI_Icon_Tab_Personal_Equip_Select'",
    },
    {
        Type = ModuleType.ProfInfo,
        Name = LSTR(620033),
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Job_Normal.UI_Icon_Tab_Personal_Job_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Job_Select.UI_Icon_Tab_Personal_Job_Select'",
    },
}

local ModuleListOther = {
    {
        Type = ModuleType.BaseInfo,
        Name = LSTR(620013),
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Information_Normal.UI_Icon_Tab_Personal_Information_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Information_Select.UI_Icon_Tab_Personal_Information_Select'",
    },
    {
        Type = ModuleType.EquipInfo,
        Name = LSTR(620034),
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Equip_Normal.UI_Icon_Tab_Personal_Equip_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Equip_Select.UI_Icon_Tab_Personal_Equip_Select'",
    },
    {
        Type = ModuleType.ProfInfo,
        Name = LSTR(620033),
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Job_Normal.UI_Icon_Tab_Personal_Job_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Job_Select.UI_Icon_Tab_Personal_Job_Select'",
    },
}

local SimpleViewSource = {
    Default     = 1,    --默认
    Team        = 2,    --队伍     
    Chat        = 3,    --聊天
} 

-- 弹窗按钮类型
---配合 G个人信息.xlsx/弹窗按钮 配置表使用
local PopupBtnType = {
    Chat            = 1,    -- 聊天
    Friend          = 2,    -- 加为好友/删除好友
    Home            = 3,    -- 个人主页
    LinkShellInvite = 4,    -- 通讯贝邀请
    ArmyInvite      = 5,    -- 公会邀请
    NewbieChannel   = 6,    -- 邀请加入新人频道/移除新人频道
    BlackList       = 7,    -- 加入黑名单/移出黑名单
    Report          = 8,    -- 举  报
    TransferCaptain = 9,    -- 转让队长
    RemoveTeam      = 10,   -- 移出小队
    DestroyTeam     = 11,   -- 解散队伍
    LeaveTeam       = 12,   -- 退出队伍
    RideInvite      = 13,   -- 邀请骑乘/申请骑乘
    TeamInvite      = 14,   -- 邀请组队
    ArmyKick        = 15,   -- 部队踢人
    ArmyTransCap    = 16,   -- 转让队长
    MeetTrade       = 17,   -- 面对面交易
    ArmySign        = 18,   -- 署名邀请
}

local DataReportType = {
    IsOther                 = 0,    -- 打开他人名片
    -- 按钮功能
    ClickAmry               = 1,
    ClickHome               = 2,

    ClickAddFriend          = 3,
    ClickRemFriend          = 4,
    ClickTeamInvite         = 5,
    ClickShallInvite        = 6,

    ClickAmryInvite         = 7,
    ClickAmryRemove         = 8,
    ClickAmryTransCap       = 9,

    ClickAddBlackList       = 10,
    ClickRemBlackList       = 11,

    ClickChannelInvite      = 12,
    ClickChannelRemove      = 13,

    ClickRideInvite         = 14,
    ClickReport             = 15,
    
}

-- ID值取自于 "H红点表.xlsx|红点名字表"
local RedDotIDs = {
    PortraitInitTips = 91,
}

local RenameCardID = 66400009

local PersonInfoDefine = {
    DataReportType          = DataReportType,
    DefaultHeadPortraitID   = DefaultHeadPortraitID,
    MaxPerferredProfCount   = MaxPerferredProfCount,
    MaxGameStyleCount       = MaxGameStyleCount,
    InvisibleHeadIcon       = InvisibleHeadIcon,
    ModuleType              = ModuleType,
    ModuleListSelf          = ModuleListSelf,
    ModuleListOther         = ModuleListOther,
    SimpleViewSource        = SimpleViewSource,
    PopupBtnType            = PopupBtnType,
    RedDotIDs               = RedDotIDs,
    RenameCardID            = RenameCardID,
}

return PersonInfoDefine