--
-- Author: Alex
-- Date: 2025-02-18 20:10
-- Description:范围监测
--

local TriggerGamePlayType = {
    ["None"] = 0,
    ["DiscoverNoteClueEffect"] = 1, -- 探索线索光效范围
    ["WildBox"] = 2, -- 野外宝箱
    ["Band"] = 3, -- 乐团
    ["MysterMerchant"] = 4, -- 神秘商人
    ["DiscoverNoteTutorial"] = 5, -- 探索笔记引导
    ["AetherCurrentTutorial"] = 6, -- 风脉泉引导
}

local AuthenticationType = {
    ["None"] = 0,
    ["Entity"] = 1, -- 游戏实体
    ["Editor"] = 2, -- 编辑器数据
    ["Custom"] = 3, -- 模块自定义
}

local RangeCheckTriggerDefine = {
   TriggerGamePlayType = TriggerGamePlayType,
   AuthenticationType = AuthenticationType,
}

return RangeCheckTriggerDefine