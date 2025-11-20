
local LSTR = _G.LSTR

local CommonBoxDefine = {
    BtnType = {
        Left = 0,
        Right = 1,
        Middle = 2,
        One = 3,
    },

    BtnUniformType = {
        NoOp = 0,
        OneOpLeft = 1,
        OneOpRight = 2,
        TwoOp = 3,
        ThreeOp = 7,
        OneOp = 8,
    },

    BtnStyleType = {
        Blue = 0,
        Yellow = 1,
        Red = 2,
    },

    -- 见通用消耗框Wiki
    CostStyle = {
        Cost = 0,
        Instead = 1,
        Simple = 2,
    },

    TextAlignment = {
        Left = 0,
        Middle = 1,
        Right = 2
    },

    NeverMindText = LSTR(10020),
}

CommonBoxDefine.BtnInitialName = {
    [CommonBoxDefine.BtnType.Left] = LSTR(10003),
    [CommonBoxDefine.BtnType.Right] = LSTR(10002),
    [CommonBoxDefine.BtnType.Middle] = LSTR(10015),
    [CommonBoxDefine.BtnType.One] = LSTR(10002),
}


return CommonBoxDefine