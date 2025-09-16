local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local SkillButtonIndexRange <const> = SkillCommonDefine.SkillButtonIndexRange

local SkillCustomDefine = {
    EButtonState = {
        Unavailable   = 1,  -- 不可操作
        Available     = 2,  -- 可操作
        Selected      = 3,  -- 选中
        Dragging      = 4,  -- 拖拽中
        Dragged       = 5,  -- 被拖拽
        ReadyToChange = 6,  -- 准备交换
    },

    TipsIDMap = {
        -- 普攻
        [SkillButtonIndexRange.Normal] = 106040,
        -- 触发技
        [SkillButtonIndexRange.Trigger_Start] = 106041,
        [SkillButtonIndexRange.Trigger_End]   = 106041,
        -- PVP极限技
        [SkillButtonIndexRange.Limit_PVP] = 106043,
    }
}

return SkillCustomDefine