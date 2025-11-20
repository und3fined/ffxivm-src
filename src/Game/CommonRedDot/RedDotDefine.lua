---@author: Star 2024-03-14 15:05:46
---@红点的常量定义

local RedDotStyle = 
{
    NormalStyle = 1, ---普通红点
    NumStyle = 2, ---数字红点
    TextStyle = 3, ---文本红点
    SecondStyle = 4, ---原弱红点样式
}

--- todo GM样式测试用，策划确认样式后删除
local RedDotIsPointStyle = false

local RedDotIsYellow = true

local ListRedDotStyleType = 
{
    TopAndBottom = 1,
    LeftAndRight = 2,
}

local ListRedDotPosType = 
{
    Top = 1,
    Bottom = 2,
    Left = 3,
    Right = 4,
}

local ListRedDotPosMap = 
{
    [ListRedDotStyleType.TopAndBottom] = {Mini = ListRedDotPosType.Top, Max = ListRedDotPosType.Bottom},
    [ListRedDotStyleType.LeftAndRight] = {Mini = ListRedDotPosType.Left,Max = ListRedDotPosType.Right},
}

local BorderRedDotPath = "Common/CommonRedDot/CommonBorderRedDot_UIBP"

local RedDotDefine = {
    RedDotStyle = RedDotStyle,
    RedDotIsYellow = RedDotIsYellow,
    RedDotIsPointStyle = RedDotIsPointStyle,
    ListRedDotStyleType = ListRedDotStyleType,
    ListRedDotPosType = ListRedDotPosType,
    ListRedDotPosMap = ListRedDotPosMap,
    BorderRedDotPath = BorderRedDotPath,
}

return RedDotDefine