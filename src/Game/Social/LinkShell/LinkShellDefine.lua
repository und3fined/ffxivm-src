---@author: wallencai(蔡文超)
---@Date 2022-07-15
---@通讯贝系统的常量定义

local ProtoCS = require("Protocol/ProtoCS")
local ProtoCS_LinkShells = ProtoCS.GroupChat.LinkShells

local MaxActNum = 3
local MaxScreenActNum = 3

--通讯贝列表item类型（列表会根据类型值大小进行排序）
local ItemType = {
    Empty = 1,
    Joined = 2, ---已加入的通讯贝
    Invited = 3, ---被邀请的通讯贝
}

local RECRUITING_SET = ProtoCS_LinkShells.RECRUITING_SET
local RecruitSetConfig = {
    { 
        Key = RECRUITING_SET.OPEN, 
        NameUkey = 40001, -- "公开招募"
    },
    { 
        Key = RECRUITING_SET.AUDIT, 
        NameUkey = 40002, --"审核允许"
    },
    { 
        Key = RECRUITING_SET.INVITE, 
        NameUkey = 40003, --"仅限邀请"
    }
}

local MemGroupType = {
    Admin = 1,
    Normal = 2,
}

local MemGroupTypeConfig = {
    [MemGroupType.Admin] = { 
        NameUkey = 40010, -- "管理员"
    },
    [MemGroupType.Normal] = { 
        NameUkey = 40011, --"参与者"
    }
}

local LINKSHELL_IDENTIFY = ProtoCS_LinkShells.LINKSHELL_IDENTIFY
local IdentifyToMemType = {
    [LINKSHELL_IDENTIFY.CREATOR] = MemGroupType.Admin,
    [LINKSHELL_IDENTIFY.MANAGER] = MemGroupType.Admin,
    [LINKSHELL_IDENTIFY.NORMAL] = MemGroupType.Normal,
    [LINKSHELL_IDENTIFY.IDENTIFY_UNKNOWN] = MemGroupType.Normal,
}

local IdentifyIconConfig = 
{
    [LINKSHELL_IDENTIFY.CREATOR] = "PaperSprite'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_Golden_png.UI_NewFriend_Icon_Golden_png'",
    [LINKSHELL_IDENTIFY.MANAGER] = "PaperSprite'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_Silvery_png.UI_NewFriend_Icon_Silvery_png'",
}

local LINKSHELL_EVENT = ProtoCS_LinkShells.LINKSHELL_EVENT
local EventDescFmtConfig = {
    [LINKSHELL_EVENT.JOIN_LINKSHELL]        = 40012, --"玩家%s加入了通讯贝"
    [LINKSHELL_EVENT.LEAVE_LINKSHELL]       = 40013, --"玩家%s退出了通讯贝"
    [LINKSHELL_EVENT.SET_MANAGE_LINKSHELL]  = 40014, --"玩家%s被管理员%s任命为管理员"
    [LINKSHELL_EVENT.TRANSFER_CREATOR]      = 40015, --"创建人%s向玩家%s转移了创建人权限"
    [LINKSHELL_EVENT.MODIFY_LINKSHELL_NAME] = 40016, --"玩家%s修改了通讯贝信息"
    [LINKSHELL_EVENT.MODIFY_MANIFESTO]      = 40016, --"玩家%s修改了通讯贝信息"
    [LINKSHELL_EVENT.MOVE_IN_BLACKLIST]     = 40017, --"管理员%s将玩家%s加入了通讯贝黑名单"
    [LINKSHELL_EVENT.DEL_MANAGE_LINKSHELL]  = 40018, --"管理员%s被%s罢免管理员"
}

---可设置模块类型，用于获取 “T通讯贝.xlsx|通讯贝未设置提示” 配置信息
local SetModuleType = {
    Act = 1,
    Manifesto = 2,
    News = 3,
    Notice = 4,
} 

local LinkShellDefine = {
    MaxActNum = MaxActNum,
    MaxScreenActNum = MaxScreenActNum,
    ItemType = ItemType,
    RecruitSetConfig = RecruitSetConfig,
    MemGroupType = MemGroupType,
    MemGroupTypeConfig = MemGroupTypeConfig,
    IdentifyToMemType = IdentifyToMemType,
    IdentifyIconConfig = IdentifyIconConfig,
    EventDescFmtConfig = EventDescFmtConfig,
    SetModuleType = SetModuleType,

    RECRUITING_SET = RECRUITING_SET,
    LINKSHELL_IDENTIFY = LINKSHELL_IDENTIFY,
    LINKSHELL_EVENT = LINKSHELL_EVENT,
}

return LinkShellDefine