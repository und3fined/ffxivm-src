---
--- Author: Leo
--- DateTime: 2023-03-30 18:28:42
--- Description: 采集笔记系统
---

local RichTextUtil = require("Utils/RichTextUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local LSTR = _G.LSTR

local RedDotName = "Root/Collectables"
local MinUnLockLevel = 40
local MinLifeProfID = ProtoCommon.prof_type.PROF_TYPE_BLACKSMITH
local MinEarthHandsProfID = ProtoCommon.prof_type.PROF_TYPE_MINER
local LockStateTipsText = LSTR(770002)

local MaxRecordBasisText = RichTextUtil.GetText(LSTR(770023), "D1BA8EFF") .. RichTextUtil.GetTexture("PaperSprite'/Game/UI/Atlas/Collectables/Frames/UI_Collectables_Icon_02_png.UI_Collectables_Icon_02_png'", 60,60, -20) or ""   
local MaxRecordNameBasisText = RichTextUtil.GetText(LSTR(770024), "D1BA8EFF")


local Color = {
    White = "#FFFFFF",
    Grey = "#C0C0C0",
}

local WarnTipsParams = {
    SkillfulHandsProfession = {
        Title = LSTR(770015),
        Message = LSTR(770020),
    },
    EarthMessengerProfession = {
        Title = LSTR(770015),
        Message = LSTR(770019),
    }
}

local DropFilterTabData = {
    { ID = 1, Name = LSTR(770006), MinValue = 131, MaxValue = 140, OpenLevel = 130 },
    { ID = 2, Name = LSTR(770005), MinValue = 121, MaxValue = 130, OpenLevel = 120 },
    { ID = 3, Name = LSTR(770004), MinValue = 111, MaxValue = 120, OpenLevel = 110 },
    { ID = 4, Name = LSTR(770003), MinValue = 101, MaxValue = 110, OpenLevel = 100 },
    { ID = 5, Name = LSTR(770012), MinValue = 91, MaxValue = 100, OpenLevel = 90 },
    { ID = 6, Name = LSTR(770011), MinValue = 81, MaxValue = 90, OpenLevel = 80 },
    { ID = 7, Name = LSTR(770010), MinValue = 77, MaxValue = 80, OpenLevel = 70 },
    { ID = 8, Name = LSTR(770009), MinValue = 61, MaxValue = 70, OpenLevel = 60 },
    { ID = 9, Name = LSTR(770008), MinValue = 51, MaxValue = 60, OpenLevel = 50 },
    { ID = 10, Name = LSTR(770007), MinValue = 41, MaxValue = 50, OpenLevel = 40 },
}

--- 决定着显示哪些职业和优先级
local OrderProfessData = {
    [30] = { Order = 1, SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_CRP_Select.UI_Icon_Tab_Job_CRP_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_CRP_Normal.UI_Icon_Tab_Job_CRP_Normal'" },  -- "刻木匠"
    [28] = { Order = 2, SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_BSM_Select.UI_Icon_Tab_Job_BSM_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_BSM_Normal.UI_Icon_Tab_Job_BSM_Normal'" },  -- "锻铁匠"
    [29] = { Order = 3, SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_ARM_Select.UI_Icon_Tab_Job_ARM_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_ARM_Normal.UI_Icon_Tab_Job_ARM_Normal'" },   -- "铸甲匠"
    [31] = { Order = 4, SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_GSM_Select.UI_Icon_Tab_Job_GSM_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_GSM_Normal.UI_Icon_Tab_Job_GSM_Normal'" },  -- "雕金匠"
    [33] = { Order = 5, SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_LTW_Select.UI_Icon_Tab_Job_LTW_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_LTW_Normal.UI_Icon_Tab_Job_LTW_Normal'" },   -- "制革匠"
    [32] = { Order = 6, SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_WVR_Select.UI_Icon_Tab_Job_WVR_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_WVR_Normal.UI_Icon_Tab_Job_WVR_Normal'" },  -- "裁衣匠"
    [34] = { Order = 7, SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_ALC_Select.UI_Icon_Tab_Job_ALC_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_ALC_Normal.UI_Icon_Tab_Job_ALC_Normal'" },   -- "炼金术士"
    [35] = { Order = 8, SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_CUL_Select.UI_Icon_Tab_Job_CUL_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_CUL_Normal.UI_Icon_Tab_Job_CUL_Normal'" },   -- "烹调师"
    [36] = { Order = 9, SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_MIN_Select.UI_Icon_Tab_Job_MIN_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_MIN_Normal.UI_Icon_Tab_Job_MIN_Normal'" },   -- "采矿工"
    [37] = { Order = 10, SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_BTN_Select.UI_Icon_Tab_Job_BTN_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_BTN_Normal.UI_Icon_Tab_Job_BTN_Normal'" },  -- "园艺工"
    [38] = { Order = 11, SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_FSH_Select.UI_Icon_Tab_Job_FSH_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_FSH_Normal.UI_Icon_Tab_Job_FSH_Normal'" },  -- "捕鱼人"
} 


local CollectablesDefine = {
    DropFilterTabData = DropFilterTabData,
    Color = Color,
    WarnTipsParams = WarnTipsParams,
    OrderProfessData = OrderProfessData,
    RedDotName = RedDotName,
    MinUnLockLevel = MinUnLockLevel,
    MinLifeProfID = MinLifeProfID,
    MinEarthHandsProfID = MinEarthHandsProfID,
    LockStateTipsText = LockStateTipsText,
    MaxRecordBasisText = MaxRecordBasisText,
    MaxRecordNameBasisText = MaxRecordNameBasisText,
}

return CollectablesDefine


--[[       收藏品多语言id 内容注释
    770001,    --%s级
    770002,    --%s职业未到达40级，收藏品交易未开启
    770003,    --101 ~ 110级
    770004,    --111 ~ 120级 
    770005,    --121 ~ 130级
    770006,    --131 ~ 140级
    770007,    --41 ~ 50级
    770008,    --51 ~ 60级
    770009,    --61 ~ 70级
    770010,    --71 ~ 80级
    770011,    --81 ~ 90级
    770012,    --91 ~ 100级
    770013,    --刷新记录
    770014,    --取 消
    770015,    --提示
    770016,    --无效玩家
    770017,    --暂无最高记录
    770018,    --确 认
    770019,    --确定要领取报酬吗？\n大地白票的持有数量已到达上限无法获得全额报酬
    770020,    --确定要领取报酬吗？\n巧手白票的持有数量已到达上限无法获得全额报酬
    770021,    --收藏品交易
    770022,    --选择收藏品交换
    770023,    --收藏价值记录:
    770024,    --记录保持者：
    770025,    --报酬
    770026,    --道具
    770027,    --等级
    770028,    --收藏价值
    770029,    --工票报酬
    770030,    --持有数量
    770031,    --未持有相应道具，快去获取吧
    770032,    --持有数量已达到上限，无法获得全额报酬
]]--