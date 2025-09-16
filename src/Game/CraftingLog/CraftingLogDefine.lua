local LSTR = _G.LSTR

local AmountChoicedType = {
    Subtract = 1,  -- 减少
    Add = 2, -- 增加
    Max = 3  -- 最大
}

local FilterALLType = {
    Level = 1, -- 常规
    Career = 2, -- 特殊
    Collect = 3, -- 收藏
    Time = 4 -- 历史
}

local ExplainType = {
    Ordinary = 1, -- 普通配方
    Grandmini = 2 -- 特殊配方
}
local CompelHQ = {
    UnCompel = 0, -- 非强制HQ
    Compel = 1 -- 强制
}

local CraftingLogState = {
    Picking = 1, -- 挑选
    Searching = 2, -- 搜索
    ChortcutSearch = 3, -- 快捷搜索
    InFunSearch = 4, -- 功能内搜索
    MaterialsSeaarch = 5 --点击材料列表获取
}

local MakeRecipeState = {
    Normal = 1, -- 正常
    Easy = 2 -- 简易制作
}

local MakeBtnState = {
    UnLockProf = 0, --前往转职
    Normal = 1, -- 正常
    Easy = 2, -- 简易制作
    Fast = 3 -- 快速制作
}

-- 道具不足类型
local UnEnoughType = {
    Default = 0, -- 初始化默认值 表满足所有条件
    Material = 1, -- 材料
    CrystalType = 2, -- 触媒？
    Precision = 3, -- 精度--废弃
    bNotWearDeputyWeapon = 4, --穿戴了副手武器
    Craftmanship = 5,   --作业精度
    CraftControl = 6,   --加工精度
    Prof = 7, --职业是否是本职业
    ProfLevel = 8, --职业等级
}

local CraftingLogRecipeLable = {
    General = 70041, -- 普通
    Special = 70021, -- 特殊
}

local PropStarShow =
{
    StarNormal = 0,
    Star1 = 1,
    Star2 = 2,
    Star3 = 3,
    Star4 = 4,
    Star5 = 5,
}

-- 制作数量状态
local AmountState = {
    Minimum = 1, -- 最小
    Maximum = 2, -- 最大
    Zero = 3, -- 一个都做不了
    DropUnMax = 4,
    AddUnMin = 5
}

-- 历史记录筛选
local SpaceFilterData = {
    [1] = {ID = 1, Name = LSTR(70011), Days = 7, SectionDay = 0}, --全部
    [2] = {ID = 2, Name = LSTR(80001), Days = 1, SectionDay = 0}, --1天内
    [3] = {ID = 3, Name = LSTR(80002), Days = 3, SectionDay = 1}, --1~3天内
    [4] = {ID = 4, Name = LSTR(80003), Days = 7, SectionDay = 3} --3~7天内
}

-- 策划定义的排序权重
local CareerSortData = {[30] = 1, [28] = 2, [29] = 3, [31] = 4, [33] = 5, [32] = 6, [34] = 7, [35] = 8}

--搜索文本
local SearchLabel = {
    GlobalSearch = 80004, --全局搜索
    SearchResult = 80005, --搜索结果
}

--特殊的说明类型
local SpecialExplainType = {
    Collection = 1,
    Difficulty = 2
}

local RedDotID = {
    CraftingLog = 9, --二级界面笔记
    CraftingLogProf = 10
}

local CategoryItemIDMap = {
    [28] = {[1] = 60800002, [2] = 60800010}, --28锻铁匠
    [29] = {[1] = 60800003, [2] = 60800011}, --29铸甲匠
    [30] = {[1] = 60800001, [2] = 60800009}, --30刻木匠
    [31] = {[1] = 60800004, [2] = 60800012}, --31雕金匠
    [32] = {[1] = 60800006, [2] = 60800014}, --32裁衣匠
    [33] = {[1] = 60800005, [2] = 60800013}, --33制革匠
    [34] = {[1] = 60800007, [2] = 60800015}, --34炼金术士
    [35] = {[1] = 60800008, [2] = 60800016}, --35烹调师
}

local CraftingLogDefine = {
    -- 切换页签下拉列表默认值
    NormalLastDropDownIndex = 1,
    --  最大制作上限
    NormalUpperLimitCount = 1, --9999999,
    --  最小制作下限 -1 为了确保是道具不足导致的无法制作
    NormalFloorLimitLevel = -1,
    --  等级分类 划分区间
    NormalRecipeLevel = 5,
    --  等级递增
    NormalLevelIncrement = 4,
    --  收藏等级分类 划分区间
    NormalRecipeCollectLevel = 10,
    --  收藏等级递增
    NormalCollectLevelIncrement = 9,
    --  等级划分 最低等级
    NormalLowestLevel = 1,
    --  最小制作数量
    NormalLowestMakeCount = 1,
    --  天 秒
    NormalDaySecond = 86400,
    --  作业精度提升节点
    NormalUpPoint = 100,
    --  最大收藏等级
    NormalMaxCollectLevel = 999,
    --  搜索框默认提示文本
    SearchHintLabel = 80006, --搜索配方
    --  递增阶段
    NormalIncrementStage = 2,
    --  搜索历史最大数量
    NormalMaxSearchHistoryCount = 6,

    CategoryItemIDMap = CategoryItemIDMap,
    AmountChoicedType = AmountChoicedType,
    FilterALLType = FilterALLType,
    ExplainType = ExplainType,
    CompelHQ = CompelHQ,
    CraftingLogState = CraftingLogState,
    MakeRecipeState = MakeRecipeState,
    MakeBtnState = MakeBtnState,
    UnEnoughType = UnEnoughType,
    CraftingLogRecipeLable = CraftingLogRecipeLable,
    PropStarShow = PropStarShow,
    AmountState = AmountState,
    SpaceFilterData = SpaceFilterData,
    CareerSortData = CareerSortData,
    SearchLabel = SearchLabel,
    SpecialExplainType = SpecialExplainType,
    RedDotID = RedDotID,
    --Test
    NormalToGetMakeCount = 25,
    -- 屏蔽
    NormalShield = 2,
    --简易制作立即完成可用的最小数量
    SimpleCraftMinTotalCount = 3,
    --HQ图标的路径
    HQIconPath = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Icon_Quality_High_png.UI_Icon_Quality_High_png'",
    --到达秘籍解锁版本但秘籍未兑换过或未使用过 时显示的文本
    UnUsedEsotericaText = 80007, --"暂无秘籍，请前往%s购买"
    --收藏品解锁的等级
    CollectionUnLockLevel = 40,
    GetNoSearchResult = 80008, --未搜索到相关配方
    --使用获取途径搜索后的未搜索到的结果显示为：该配方尚未解锁
    InterGetNoSearchResult = 80009, --该配方尚未解锁
    TextListEmpty = 80010,--暂无历史配方
    SpecialListEmpty = 80011,--暂未解锁特殊配方
    CollectListEmpty = 80012,--暂无收藏配方
    DefaultGameVersionNum = 200,
    MaxLevel = 50,

}

return CraftingLogDefine
