
local StateType = {
    None = 0,
    Fight = 1, -- 战斗中
    DiffServer = 2, -- 异服(和Major相比)
}

local StateIcon = {
    [StateType.Fight] = "PaperSprite'/Game/UI/Atlas/Friend/Frames/UI_Friends_Search_Icon_State_png.UI_Friends_Search_Icon_State_png'",
    [StateType.DiffServer] = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Chat_Icon_CorssServer_png.UI_Main_Chat_Icon_CorssServer_png'",
}

local CommPlayerDefine = {
    StateType = StateType,
    StateIcon = StateIcon,
}

return CommPlayerDefine