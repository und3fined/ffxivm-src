
local MaxCache = 50

-- 弹幕类型
local DanmakuType = {
    PrivateChat     = "private_chat",   -- 私聊 
    TeamChat        = "team_chat",      -- 队伍频道聊天
}

local MsgStatus = {
    Waiting = 0, -- 等待
    Displaying = 1, -- 显示中
    Displayed = 2, -- 显示完毕
}

local DanmakuDefine = {
    MsgStatus = MsgStatus,
    MaxCache = MaxCache,
    DanmakuType = DanmakuType,
}

return DanmakuDefine