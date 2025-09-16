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


local RedDotDefine = {
    RedDotStyle = RedDotStyle,
    RedDotIsYellow = RedDotIsYellow,
    RedDotIsPointStyle = RedDotIsPointStyle,
}

return RedDotDefine