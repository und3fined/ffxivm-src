--- 因为福利现在只有月卡，临时作为福利按钮的常量类

local MonthCardDefine = {}

local TabIndex = {
	BP = 1,
	MonthCard = 2,
}

local RedDefines = {
    Welfare = 4001,
    MonthCard = 4002,
}

local TabNewRed = {
    [TabIndex.MonthCard] = {
        Tab = RedDefines.MonthCard,
    },
}

MonthCardDefine.TabIndex = TabIndex
MonthCardDefine.TabNewRed = TabNewRed
MonthCardDefine.RedDefines = RedDefines

return MonthCardDefine