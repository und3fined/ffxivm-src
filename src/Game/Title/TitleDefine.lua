local LSTR = _G.LSTR
local RedDotName = "Root/Title"
local AchievementIconPath = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_903704.UI_Icon_903704'"
local ActivityIconPath = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_903714.UI_Icon_903714'"

local ConditionType =
{
    Achievement = 1,     -- 成就
    Activity = 2,        -- 运营活动
}

local ButtonStyle = {
    InUse = 1,
    UnUse = 2,
    Lock = 3,
}

local OpenTitleState ={
    Open = 1,
    Close = 2,
}

local AppendTitleType = {
	{ ID = 9998, Sort = -2 , TypeName = LSTR(710009), Icon = "" },
    { ID = 9999, Sort = -1 , TypeName = LSTR(710002), Icon = "" },
    { ID = 99, Sort = 99, TypeName = LSTR(710018), Icon = "" },     -- "运营活动"
}

local TitleDefine = {
    ButtonStyle = ButtonStyle,
    OpenTitleState = OpenTitleState,
    AppendTitleType = AppendTitleType,
    RedDotName = RedDotName,
    AchievementIconPath = AchievementIconPath,
    ActivityIconPath = ActivityIconPath,
    ConditionType = ConditionType,
}

return TitleDefine



--[[       称号多语言id 内容注释
    710001,    --使用
    710002,    --全部
    710003,    --取消使用
    710004,    --当前称号： 
    710005,    --当前称号： 无
    710006,    --成就：
    710007,    --成就：未知成就
    710008,    --搜索称号
    710009,    --收藏
    710010,    --暂无收藏称号
    710011,    --暂无称号
    710012,    --未找到成就信息！
    710013,    --未找到称号信息！
    710014,    --未搜索到称号
    710015,    --未解锁
    710016,    --称号设置成功
    710017,    --称号
]]--
