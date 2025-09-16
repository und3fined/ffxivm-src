--
-- Author: alex
-- Date: 2024-02-28 15:21
-- Description:足迹系统
--
local LSTR = _G.LSTR
local ProtoRes = require("Protocol/ProtoRes")
local FootPrint_Filter_Type = ProtoRes.FootMarkType

local LockState = {
    ["None"] = 0,
    ["Locked"] = 1, -- 未解锁
    ["WaitForUnLockLessHalf"] = 2, -- 待解锁小于等于50%
    ["WaitForUnLockMoreHalf"] = 3, -- 待解锁大于50%
}

local ParentType2MapCfgIndex = {
    [FootPrint_Filter_Type.FootMarkType_Normal] = 1,
    [FootPrint_Filter_Type.FootMarkType_Move] = 2,
    [FootPrint_Filter_Type.FootMarkType_Battle] = 3,
    [FootPrint_Filter_Type.FootMarkType_Relaxation] = 4,
    [FootPrint_Filter_Type.FootMarkType_Explore] = 5,
}

local RedDotBaseName = "Root/Menu/FootPrint" 

local AreaProgressStatus = {
    ["Closed"] = 0,
    ["Open"] = 1,
    ["Lighten"] = 2,
}

local ScheduleTextContent = {
    ["Locked"] = {
        Icon = "PaperSprite'/Game/UI/Atlas/FootPrint/Frames/UI_FootPrint_Icon_Lock_png.UI_FootPrint_Icon_Lock_png'",
        Color = "828282ff"
    },
    ["Unlock"] = {
        Icon = "PaperSprite'/Game/UI/Atlas/FootPrint/Frames/UI_FootPrint_Icon_Pug_png.UI_FootPrint_Icon_Pug_png'",
        Color = "fff3c2ff"
    }
}

local ParentTypeIconPath = {
    ["Selected"] = "PaperSprite'/Game/UI/Atlas/FootPrint/Frames/UI_FootPrint_Icon_Pug_png.UI_FootPrint_Icon_Pug_png'",
    ["Normal"] = "PaperSprite'/Game/UI/Atlas/FootPrint/Frames/UI_FootPrint_Icon_Pug2_png.UI_FootPrint_Icon_Pug2_png'"
}

local ParentTypeSelectColor = {
    ["Selected"] = "ffeebbff",
    ["Normal"] = "d1ba8eff"
}

local RegionId2Color = {
    [1] = "391e18ff",
    [2] = "e6b42cff",
    [3] = "d32c34ff",
    [4] = "5466adff",
    [9] = "40a088ff"
}

local FootPrintDefine = {
    LockState = LockState,
    ParentType2MapCfgIndex = ParentType2MapCfgIndex,
    AreaProgressStatus = AreaProgressStatus,
    RedDotBaseName = RedDotBaseName,
    ScheduleTextContent = ScheduleTextContent,
    ParentTypeIconPath = ParentTypeIconPath,
    ParentTypeSelectColor = ParentTypeSelectColor,
    RegionId2Color = RegionId2Color,
}

return FootPrintDefine