---@author: wallencai(蔡文超) 2022-07-12 15:21:46
---@好友的常量定义

local LSTR = _G.LSTR

local AllGroupID = -1
local AllGroupName = LSTR(30001) --"全部好友"
local DefaultGroupID = 0
local DefaultGroupName = LSTR(30002) -- "无分组"
local BlackGroupID = 999999
local BlackGroupName = LSTR(30003) --"黑名单"

local FindType = {
    AllRecommond = 1,
    RecentTeam = 2,
    RecentChat = 3,
}

local FindDropDownData = {
    {
        Type = FindType.AllRecommond, 
        Name = LSTR(30004), --"推荐好友"
    },
    {
        Type = FindType.RecentTeam, 
        Name = LSTR(30005), --"近期组队"
        MaxNum = 10,
    },
    {
        Type = FindType.RecentChat, 
        Name = LSTR(30006), --"近期聊天"
        MaxNum = 10,
    },
}

local MaxRecentTeamNum = 10 
local MaxRecentChatNum = 10 

local ScreenTabType = {
    Prof = 1,
    PlayStyle = 2,
}

local ScreenTabs = {
    {
        Key = ScreenTabType.Prof, 
        Name = LSTR(30007), --"职业"
    },
    {
        Key = ScreenTabType.PlayStyle, 
        Name = LSTR(30008), --"游戏风格"
    }
}

local AddSource = {
    PersonCard = 1, -- 个人铭牌
    PersonHome = 2, -- 个人主页
    MainUITeam = 3, -- 主界面组队
    PrivateChat = 4, -- 私聊
    FriendTab = 5, -- 好友页签
    Activity = 6, -- 活动添加
}

local ListState = {
    Normal = 1, -- 正常状态
    NoFriend = 2, -- 无好友状态(好友&黑名单成员)
    ListEmpty = 3, -- 列表空状态
    SearchEmpty = 4, -- 搜索空状态
}

local FriendDefine = {
    AllGroupID = AllGroupID,
    AllGroupName = AllGroupName,
    DefaultGroupID = DefaultGroupID,
    DefaultGroupName = DefaultGroupName,
    BlackGroupID = BlackGroupID,
    BlackGroupName = BlackGroupName,

    FindType = FindType,
    FindDropDownData = FindDropDownData,
    MaxRecentTeamNum = MaxRecentTeamNum,
    MaxRecentChatNum = MaxRecentChatNum,

    ScreenTabType = ScreenTabType,
    ScreenTabs = ScreenTabs,

    AddSource = AddSource,
    ListState = ListState,
}

return FriendDefine
