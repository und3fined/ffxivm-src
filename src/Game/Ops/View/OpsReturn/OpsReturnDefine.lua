local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local EquipmentPartList = ProtoCommon.equip_part

local OpsReturnDefine = {}

OpsReturnDefine.ActivityID = 25070301

OpsReturnDefine.PageType = {
    Welfare = 1,
    ContentPush = 2,
    Task = 3,
}

OpsReturnDefine.PageTitle = {
    [OpsReturnDefine.PageType.Welfare] = 1680021, --回归冒险者福利
    [OpsReturnDefine.PageType.ContentPush] =  1680022, --回归玩法推荐
    [OpsReturnDefine.PageType.Task] = 1680023 --回归冒险者任务
}

OpsReturnDefine.ReturnTaskStage = {
    Frist = 1,
    Second = 2,
    Third = 3,
}

OpsReturnDefine.ActivityNodeType = {
    MailNodeID = 1,  -- 邮件ID
    VideoNodeID = 2, -- 视频ID
}

OpsReturnDefine.ActivityNodeID = {
    [OpsReturnDefine.ActivityNodeType.MailNodeID] = 2507030101, --回归冒险者福利
    [OpsReturnDefine.ActivityNodeType.VideoNodeID] = 2507030137, --视频
}

OpsReturnDefine.TagIDToNodeID = {
    [1] = 2507030131,   -- 标签1
    [2] = 2507030132,   -- 标签2
    [4] = 2507030133,   -- 标签4
    [8] = 2507030134,   -- 标签8
    [16] = 2507030135,  -- 标签16
    [32] = 2507030136,  -- 标签32
}

OpsReturnDefine.RedDotType = {
    PageTypeWelfare = 1,
    PageTypeContentPush = 2,
    PageTypeTask = 3,
    Stage1 = 4,
    Stage2 = 5,
    Stage3 = 6,
    SignTask = 7,
    StageTask1 = 8,
    StageTask2 = 8,
    StageTask3 = 8,
}

OpsReturnDefine.RedDotID = {
    [OpsReturnDefine.RedDotType.PageTypeWelfare] = 26000,
    [OpsReturnDefine.RedDotType.PageTypeContentPush] =  26001, 
    [OpsReturnDefine.RedDotType.PageTypeTask] = 26002,
    [OpsReturnDefine.RedDotType.Stage1] = 26003,
    [OpsReturnDefine.RedDotType.Stage2] = 26004,
    [OpsReturnDefine.RedDotType.Stage3] = 26005,
    [OpsReturnDefine.RedDotType.SignTask] = 26006,
    [OpsReturnDefine.RedDotType.StageTask1] = 26007,
    [OpsReturnDefine.RedDotType.StageTask2] = 26008,
    [OpsReturnDefine.RedDotType.StageTask3] = 26009,
}


return OpsReturnDefine