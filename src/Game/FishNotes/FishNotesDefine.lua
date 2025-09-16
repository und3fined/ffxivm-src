---
--- Author: anypkvcai
--- DateTime: 2023-04-11 11:36
--- Description:
---
local LSTR = _G.LSTR
local ProtoRes = require("Protocol/ProtoRes")

--local FactionName = {LSTR(180008),LSTR(180009),LSTR(180010),LSTR(180011),LSTR(180012)}

local ClockTimeText = {
    Now = LSTR(180013), --已开启
    Day = LSTR(180014), --%d天后开启
    Hour = LSTR(180015), --%d小时后开启
    Minute = LSTR(180016), --%d分钟后开启
    Second = LSTR(180017), --%d秒后开启
}

local TimeLimitText = {
    Now = _G.LSTR(180066),--"活跃中"
    Day = "%dd",
    Hour = "%dh",
    Minute = "%dm",
    Second = "%ds",
}

local TimeValue = {
    Day = 86400,
    Hour = 3600,
    Minute = 60,
}

local Color = {
    ClockTextNormal = "#FFFFFF",--白色9C9788FF
    ClockTextNow = "#D1BA8EFF",--橙色
    AreaNameNormal = "#9C9788FF", --区域正常颜色
    PlaceNameSelect = "#D5D5D5FF", --区域与地点选中颜色
    PlaceNameNormal = "#D5D5D5FF", --地点正常颜色
}

local DetailWindowsLength = 10
local WindowDayStartTime = 1
local WindowDayEndTime = 24
local WeathInterval = 8 * 3600
local WeathTryBorder = 31
local SelectFishIndexDefault = 0
local SelectClockIndexDefault = 0
local WindowItemLength = 10
local WeathAozyImterval = 8
local WeathAozyImtervalDouble = 16
local HourTime = 60000
local FishNoteType = 1
local FactionDefaultValue = 2
local DayAllHourValue = 24
local GridColumn = 4
local SelectDefaultIndex = 1

local FishRartyEnum = {
    King = 3,
    Queen = 4
}

local FishLocationTreeType = {
    Area = 0,
    Place = 1
}

local FishWindowTimeTreeType = {
    Time = 0,
    Window = 1
}

local FishingholeInitType = { 
    Location = 1, 
    Fish = 2 
}

local FishAreaType = {
    Area = "Area",
    Place = "Place"
}

local FishSlotNotCanPink = "PaperSprite'/Game/UI/Atlas/FishNotes/Frames/UI_FishNotes_Img_SlotGreen_png.UI_FishNotes_Img_SlotGreen_png'"
local FishSlotCanPink = "PaperSprite'/Game/UI/Atlas/FishNotes/Frames/UI_FishNotes_Img_SlotPink_png.UI_FishNotes_Img_SlotPink_png'"

local FishingholeTabClockIcon = "PaperSprite'/Game/UI/Atlas/FishNotes/Frames/UI_FishNotes_Tab_ClockNormal_png.UI_FishNotes_Tab_ClockNormal_png'"
local FishingholeTabClockSelectIcon = "PaperSprite'/Game/UI/Atlas/FishNotes/Frames/UI_FishNotes_Tab_ClockSelect_png.UI_FishNotes_Tab_ClockSelect_png'"

local FishingholeTabFactionIcon = {
    "Texture2D'/Game/Assets/Icon/Area/UI_Icon_Area_EasternRegion.UI_Icon_Area_EasternRegion'",
    "Texture2D'/Game/Assets/Icon/Area/UI_Icon_Area_GyrAbania.UI_Icon_Area_GyrAbania'",
    "Texture2D'/Game/Assets/Icon/Area/UI_Icon_Area_LaNoscea.UI_Icon_Area_LaNoscea'",
    "Texture2D'/Game/Assets/Icon/Area/UI_Icon_Area_Shgard.UI_Icon_Area_Shgard'",
    "Texture2D'/Game/Assets/Icon/Area/UI_Icon_Area_Thanalan.UI_Icon_Area_Thanalan'",
    "Texture2D'/Game/Assets/Icon/Area/UI_Icon_Area_TheBlackShroud.UI_Icon_Area_TheBlackShroud'",
}

local FishBaitSkillIcon = {
    [1] = "PaperSprite'/Game/UI/Atlas/FishNotes/Frames/UI_FishNotes_Icon_Skill_png.UI_FishNotes_Icon_Skill_png'",
    [2] = "PaperSprite'/Game/UI/Atlas/FishNotes/Frames/UI_FishNotes_Icon_Skill2_png.UI_FishNotes_Icon_Skill2_png'",
}

local FishBaitPointIcon = {
    [1] = "PaperSprite'/Game/UI/Atlas/FishNotesNew/Frames/UI_FishNotes_Img_Blue_png.UI_FishNotes_Img_Blue_png'",
    [2] = "PaperSprite'/Game/UI/Atlas/FishNotesNew/Frames/UI_FishNotes_Img_Red_png.UI_FishNotes_Img_Red_png'",
    [3] = "PaperSprite'/Game/UI/Atlas/FishNotesNew/Frames/UI_FishNotes_Img_Yellow_png.UI_FishNotes_Img_Yellow_png'"
}

local IconArrow = {
    Select = "PaperSprite'/Game/UI/Atlas/FishNotes/Frames/UI_FishNotes_Icon_ArrowSelect_png.UI_FishNotes_Icon_ArrowSelect_png'",
    Normal = "PaperSprite'/Game/UI/Atlas/FishNotes/Frames/UI_FishNotes_Icon_ArrowNormal_png.UI_FishNotes_Icon_ArrowNormal_png'"
}

local ClockTabIcon = { 
    {
        Index = 1,
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_FishNotes_AlarmClock_Normal.UI_Icon_Tab_FishNotes_AlarmClock_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_FishNotes_AlarmClock_Select.UI_Icon_Tab_FishNotes_AlarmClock_Select'"
    },
    {
        Index = 2,
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_FishNotes_Active_Normal.UI_Icon_Tab_FishNotes_Active_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_FishNotes_Active_Select.UI_Icon_Tab_FishNotes_Active_Select'"
    },
}

local DropData = {
        {  Name = LSTR(70011), },--"全部"
        {  Name = LSTR(180096), },--"鱼王类"
        {  Name = LSTR(180097), },--"普通鱼"
    }

local UnkonwText = 180006 --未知
local FishLockAreaName = "？？？？？"
local FishLockPlaceName = LSTR(180029)--未发现的钓场
local StatusBuffTimeText = 180030--%d分
local FishUnlockTipsText = 180098--"听说有人在%s见到过，可以去%s地区碰碰运气"
local SearchEmptyText = 180032--暂无搜索结果，请重新搜索
local InheritTipsText = 180033--鱼类传承录: %s
local ClockEmptyTipsText = 180035--暂无设置钓鱼时间提醒
local ClockActiveEmptyTipsText = 180103--已解锁钓场中暂无活跃中鱼类
local ClockActiveTipsText = 180036--钓鱼提醒功能暂未激活 1元购买激活
--local LockedFishInfo = LSTR(180038)--该鱼暂未解锁，无法查看详情
local ClockInvailidTipsText = 180039--闹钟功能未激活
local ClockSetSucceedText = 180040--钓鱼提醒设置成功
local ClockSetTitle = 180041--闹钟提醒
local UnlimitedText = {
    Time = LSTR(180069),--"该鱼类出现无时间要求"
    Weather = LSTR(180070),--"该鱼类出现无天气要求"
    both = LSTR(180042),--全天可钓
}
local FactionRedDotID = 9001


local FishNotesDefine = {
    --FactionName = FactionName,
    ClockTimeText = ClockTimeText,
    InheritTipsText = InheritTipsText,
    UnkonwText = UnkonwText,
    ClockEmptyTipsText = ClockEmptyTipsText,
    ClockActiveEmptyTipsText = ClockActiveEmptyTipsText,
    ClockActiveTipsText = ClockActiveTipsText,
    ClockSetTitle = ClockSetTitle,
    DetailWindowsLength = DetailWindowsLength,
    WindowDayStartTime = WindowDayStartTime,
    WindowDayEndTime = WindowDayEndTime,
    WeathInterval = WeathInterval,
    WeathTryBorder = WeathTryBorder,
    FishSlotNotCanPink = FishSlotNotCanPink,
    FishSlotCanPink = FishSlotCanPink,
    FishRartyEnum = FishRartyEnum,
    SelectFishIndexDefault = SelectFishIndexDefault,
    SelectClockIndexDefault = SelectClockIndexDefault,
    FishLocationTreeType = FishLocationTreeType,
    FishWindowTimeTreeType = FishWindowTimeTreeType,
    FishingholeTabClockIcon = FishingholeTabClockIcon,
    FishingholeTabFactionIcon = FishingholeTabFactionIcon,
    FishingholeTabClockSelectIcon = FishingholeTabClockSelectIcon,
    FishUnlockTipsText = FishUnlockTipsText,
    SearchEmptyText = SearchEmptyText,
    FishNoteType = FishNoteType,
    FishAreaType = FishAreaType,
    FishLockAreaName = FishLockAreaName,
    FishLockPlaceName = FishLockPlaceName,
    FactionDefaultValue = FactionDefaultValue,
    FishingholeInitType = FishingholeInitType,
    WindowItemLength = WindowItemLength,
    WeathAozyImterval = WeathAozyImterval,
    StatusBuffTimeText = StatusBuffTimeText,
    HourTime = HourTime,
    Color = Color,
    TimeValue = TimeValue,
    TimeLimitText = TimeLimitText,
    DayAllHourValue = DayAllHourValue,
    WeathAozyImtervalDouble = WeathAozyImtervalDouble,
    FishBaitSkillIcon = FishBaitSkillIcon,
    FishBaitPointIcon = FishBaitPointIcon,
    IconArrow = IconArrow,
    ClockTabIcon = ClockTabIcon,
    DropData = DropData,
    UnlimitedText = UnlimitedText,
    ClockInvailidTipsText = ClockInvailidTipsText,
    ClockSetSucceedText = ClockSetSucceedText,
    GridColumn = GridColumn,
    --LockedFishInfo = LockedFishInfo,
    FactionRedDotID = FactionRedDotID,
    SelectDefaultIndex = SelectDefaultIndex,
}

return FishNotesDefine