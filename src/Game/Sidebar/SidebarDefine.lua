local UIViewID = require("Define/UIViewID")

local SidebarType = {
    Death                   = 1,   -- 死亡复活
    PWorldQuestGiveUp       = 2,   -- 副本放弃任务
    PWorldQuestKick         = 3,   -- 副本任务踢人
    FishClock               = 4,   -- 钓鱼闹钟提醒
    GatherClock             = 5,   -- 采集闹钟提醒
    MinerClock              = 6,   -- 采矿闹钟提醒
    PWorldQuestMVP          = 7,   -- 副本任务MVP
    NewbieInvite            = 8,   -- 指导者新人邀请
    ArmyInvite              = 9,   -- 公会邀请
    LinkShellInvite         = 10,  -- 通讯贝邀请
    FriendInvite            = 11,  -- 好友邀请
    TeamInvite              = 12,  -- 组队邀请
    MountInvite             = 13,  -- 坐骑邀请
    PWorldMatch             = 14,  -- 副本匹配
    Revive                  = 15,  -- 他人救助
    PWorldEnterConfirm      = 16,  -- 副本进入确认
    EntourageEnterConfirm   = 17,  -- 随从进入确认
    MagicCardMatchConfirm   = 18,  -- 幻卡对局进入确认
    PVPDuel                 = 20,  -- PVP决斗
    MeetTradeRequest        = 21,  -- 交易请求
    ChocoboBabyClaim        = 22,  -- 陆行鸟子鸟领取提醒
    ArmySignInvite          = 23,  -- 部队署名邀请
    PrivateChat             = 24,  -- 私聊
}

--侧边栏详情界面ViewID
local DetailViewIDMap = {
    [UIViewID.SidebarCommon]        = true, -- 通用详情
    [UIViewID.SidebarTeamInvite]    = true, -- 组队邀请详情
    [UIViewID.SidebarPrivateChat]   = true, -- 私聊详情
    [UIViewID.ChatInvitationWinPanel]   = true, -- 新人频道邀请
}

-- 注意保持ID连续，因为用在了table里面做逻辑
local LeftSidebarType = {
    None = 0, -- 无效
    Achievement = 1, -- 成就
    AetherCurrents = 2, -- 风脉泉
    Fate = 3, -- FATE
    FantacyCard = 4, -- 幻卡系统
    DiscoverNote = 5, -- 探索笔记
}

local DefaultItemBg = "PaperSprite'/Game/UI/Atlas/Sidebar/Frames/UI_Sidebar_Img_Ordinary_png.UI_Sidebar_Img_Ordinary_png'"

local SidebarDefine = {
    SidebarType     = SidebarType,
    DefaultItemBg   = DefaultItemBg,
    DetailViewIDMap = DetailViewIDMap,
    LeftSidebarType = LeftSidebarType,
}

return SidebarDefine