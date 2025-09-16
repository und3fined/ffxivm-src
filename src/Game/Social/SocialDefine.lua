local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")

local LSTR = _G.LSTR
local RedDotStyle = RedDotDefine.RedDotStyle

local TabType = {
    FriendList = 1,
    WeChatFriend = 2,
    QQFriend = 3,
    AddFriend = 4,
    LinkShell = 5,

    FindFriend = 10,
    ApplyList = 20,
    MyLinkShell = 30,
    JoinLinkShell = 40,
    InvitedLinkShell = 50,
}

-- ID值取自于 "H红点表.xlsx|红点名字表"
local RedDotID = {
    Social = 20,
    AddFriend = 21,
    ApplyList = 22,
    LinkShell = 23,
    MyLinkShell = 24,
}

local MainTabs = {
    {
        Key = TabType.FriendList,
        Name = LSTR(20001), --"好友列表"
    },
    {
        Key = TabType.WeChatFriend,
        Name = LSTR(20010), --"微信好友"
    },
    {
        Key = TabType.QQFriend,
        Name = LSTR(20011), --"QQ好友"
    },
    {
        Key = TabType.AddFriend,
        Name = LSTR(20002), --"添加好友"
        RedDotID = RedDotID.AddFriend,
        RedDotStyle = RedDotStyle.NumStyle,
        Children = {
            {
                Key = TabType.FindFriend,
                Name = LSTR(20003), --"寻找好友"
            },
            {
                Key = TabType.ApplyList,
                Name = LSTR(20004), --"申请列表"
                RedDotID = RedDotID.ApplyList,
                RedDotStyle = RedDotStyle.NumStyle,
            },
        }
    },
    {
        Key = TabType.LinkShell,
        Name = LSTR(20005), --"通讯贝"
        RedDotID = RedDotID.LinkShell,
        RedDotStyle = RedDotStyle.NumStyle,
        Children = {
            {
                Key = TabType.MyLinkShell,
                Name = LSTR(20006), --"我的通讯贝"
                RedDotID = RedDotID.MyLinkShell,
                RedDotStyle = RedDotStyle.NumStyle,
            },
            {
                Key = TabType.JoinLinkShell,
                Name = LSTR(20007), --"加入通讯贝"
            },
            {
                Key = TabType.InvitedLinkShell,
                Name = LSTR(20009), --"受邀通讯贝"
            },
        }
    },
}

--- 玩家列表排序
local PlayerItemSortFunc = function (lhs, rhs)
    -- 排序是否优先
    if lhs.IsSortPriority ~= rhs.IsSortPriority then
        return lhs.IsSortPriority
    end

    -- 在线状态
    local IsOnline_lhs = lhs.IsOnline
    local IsOnline_rhs = rhs.IsOnline
    if IsOnline_lhs ~= IsOnline_rhs then
        return IsOnline_lhs
    end

    if IsOnline_lhs then
        -- 在线，按上线时间排序
        return (lhs.LoginTime or 0) < (rhs.LoginTime or 0)
    else
        -- 离线，按下线时间排序
        return (lhs.LogoutTime or 0) > (rhs.LogoutTime or 0)
    end
end

local SocialDefine = {
    TabType     = TabType,
    MainTabs    = MainTabs,
    RedDotID    = RedDotID,

    PlayerItemSortFunc = PlayerItemSortFunc,
}

return SocialDefine
