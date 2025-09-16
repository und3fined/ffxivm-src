local ProtoRes = require("Protocol/ProtoRes")
local BattlePassDefine = {}
local LSTR = _G.LSTR

local TabIndex = {
    LevelReward = 1,
    Task = 2,
    BigReward = 3,
}

local GradeType = {
    Basic = 1,  -- 基础
    Middle = 2, -- 进阶
    Best = 3,   -- 至臻
}

local TaskType = {
    All = -1,
    Weekly = 3,
    Challenge = 4,
}

local ItemShowType = {
    Model = 1,
    Mount = 2,
    Companion = 3,
}
BattlePassDefine.RedDotID = {
    LevelReward = 65,
    Task = 66,
    Week = 67,
    Challenge = 68,
    WeekSign = 69,
}

BattlePassDefine.TabList = {
    {
    ID = TabIndex.LevelReward, 
    Name = LSTR(850044), 
    RedDotID = BattlePassDefine.RedDotID.LevelReward, 
    IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_BP_Marauder_Normal.UI_Icon_Tab_BP_Marauder_Normal'",
    SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_BP_Marauder_Select.UI_Icon_Tab_BP_Marauder_Select'",
    -- ChildWidget = "BattlePass/BattlePassMain_UIBP"
    },
    {
    ID = TabIndex.Task, 
    Name = LSTR(850045), 
    RedDotID = BattlePassDefine.RedDotID.Task, 
    IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Task_Noraml.UI_Icon_Tab_Bag_Goods_Task_Noraml'",
    SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Task_Select.UI_Icon_Tab_Bag_Goods_Task_Select'",
    ChildWidget = "BattlePass/BattlePassTaskPanel_UIBP"
    },
    {
    ID = TabIndex.BigReward, 
    Name = LSTR(850046), 
    IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_BP_Packs_Normal.UI_Icon_Tab_BP_Packs_Normal'",
    SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_BP_Packs_Select.UI_Icon_Tab_BP_Packs_Select'",
    ChildWidget = "BattlePass/BattlePassGrandPrizePanel_UIBP"
    },
}

BattlePassDefine.ScanDest = {
    LevelRewardPanel = 1,
    TaskPanel = 2,
    BigRewardPanel = 3,
    AdvancePanel = 4,
}



BattlePassDefine.TabIndex = TabIndex
BattlePassDefine.TaskType = TaskType
BattlePassDefine.GradeType = GradeType
BattlePassDefine.ItemShowType = ItemShowType

return BattlePassDefine