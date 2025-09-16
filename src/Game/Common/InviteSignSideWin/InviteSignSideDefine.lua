local InviteMenu = {
    Nearby  = 1,
    Friend  = 2,
    Tribe   = 3,
}

local InviteItemType = {
    ArmySignInvite  = 1,
    ArmyInvite  = 2,
}

local InviteItemIcon = {
    [InviteItemType.ArmySignInvite]  = "Texture2D'/Game/UI/Texture/Army/UI_Army_Btn_InviteSign.UI_Army_Btn_InviteSign'",
    [InviteItemType.ArmyInvite]  = "Texture2D'/Game/UI/Texture/Army/UI_Army_Btn_Invite.UI_Army_Btn_Invite'",
}


local MenuValues = {
    [InviteMenu.Nearby] = {
        Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_NearbyNormal_png.UI_Chat_Tab_Icon_NearbyNormal_png'",
        IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_NearbySelect_png.UI_Chat_Tab_Icon_NearbySelect_png'",
        MenuID = InviteMenu.Nearby,
    },
    [InviteMenu.Friend] = {
        Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_PrivateChatNormal_png.UI_Chat_Icon_PrivateChatNormal_png'",
        IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_PrivateChatSelect_png.UI_Chat_Icon_PrivateChatSelect_png'",
        MenuID = InviteMenu.Friend,
    },
    [InviteMenu.Tribe] = {
        Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_ArmyNormal_png.UI_Chat_Tab_Icon_ArmyNormal_png'",
        IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_ArmySelect_png.UI_Chat_Tab_Icon_ArmySelect_png'",
        MenuID = InviteMenu.Tribe,
    }
}

local InviteSignSideDefine = {
    InviteMenu     = InviteMenu,     --- 邀请页签类型
    InviteItemType = InviteItemType, --- 邀請Item类型
    InviteItemIcon = InviteItemIcon, --- 邀请Item按钮Icon
    MenuValues     = MenuValues,     --- 邀请页签数据
}



return InviteSignSideDefine