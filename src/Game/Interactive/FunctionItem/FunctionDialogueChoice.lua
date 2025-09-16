
local LuaClass = require("Core/LuaClass")
local FunctionBase = require("Game/Interactive/FunctionItem/FunctionBase")
local QuestHelper = require("Game/Quest/QuestHelper")

local FunctionDialogueChoice = LuaClass(FunctionBase)

function FunctionDialogueChoice:Ctor()
    self.FuncType = LuaFuncType.DIALOGUE_CHOICE_FUNC
end

function FunctionDialogueChoice:OnInit(DisplayName, FuncParams)
    self.ChoiceIndex = FuncParams.ChoiceIndex
end

function FunctionDialogueChoice:OnClick()
    --FLOG_WARNING("FunctionDialogueChoice:OnClick()")
    _G.StoryMgr.ChooseMenuChoice(self.ChoiceIndex)
end

return FunctionDialogueChoice
