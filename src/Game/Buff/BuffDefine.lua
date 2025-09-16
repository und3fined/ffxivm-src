---
--- Author: v_hggzhang
--- DateTime: 2022-04-28 19:14
--- Description: Buff UI 相关的一些 Define
---

local ProtoRes = require("Protocol/ProtoRes")

local BuffDefine = {
    --BuffCell 来源
    BuffCellFrom = {
        HUDMini = 1 --血条上面的区域
    },
    BuffSkillType = {
        --Buff 来源的技能类型
        Combat = 1, --战斗技能
        Life = 2, --生活技能
        BonusState = 3, --加成状态
    },
    BuffDisplayActiveType = {
        --Buff 展示类型 增益/减益 类型
        Normal = ProtoRes.BuffDisplayType.BUFF_DISPLAY_TYPE_NULL, --普通
        Positive = ProtoRes.BuffDisplayType.BUFF_DISPLAY_TYPE_POSITIVE, --增益Buff
        Negative = ProtoRes.BuffDisplayType.BUFF_DISPLAY_TYPE_NEGATIVE --减益Buff
    },
    -- BuffActiveType = { --Buff 展示类型 增益/减益 类型
    --     Normal = ProtoRes.buff_showtype.BUFF_SHOWTYPE_NULL, --普通
    --     Positive = ProtoRes.buff_showtype.BUFF_SHOWTYPE_POSITIVE, --增益Buff
    --     Negative = ProtoRes.buff_showtype.BUFF_SHOWTYPE_NEGATIVE, --减益Buff
    -- },

    DoNotShowBuffInUIWeight = -1, -- IconDisplayWeight == -1,不显示在UI上
    MainBuffUIShowLeftTime = 60, -- MainBuff 低于60秒才显示
    LeftTimeColor = {
        FromMajor = "89BD88FF",
        FromOther = "FFFFFFFF"
    },

    -- loiafeng: 【临时做法】目前使用Buff表中Tag列的999作为是否显示动态数值的
    DynamicBuffDescTag = 999,

    --kanohchen: 【4月跑测体验】【优化】系统频道全是这个加速buff了
    SysChatMsgIgnoreBuffID = 998,
}

return BuffDefine
