local LuaClass = require("Core/LuaClass")
local FunctionBase = require("Game/Interactive/FunctionItem/FunctionBase")
local QuestHelper = require("Game/Quest/QuestHelper")

local FunctionNpcBranch = LuaClass(FunctionBase)

function FunctionNpcBranch:Ctor()
    self.FuncType = LuaFuncType.DIALOGUE_CHOICE_FUNC
end

function FunctionNpcBranch:OnInit(DisplayName, FuncParams)
    self.ChoiceIndex = FuncParams.ChoiceIndex
end

function FunctionNpcBranch:OnClick()
    --FLOG_WARNING("FunctionNpcBranch:OnClick()")
    _G.NpcDialogMgr:ChooseMenuChoice(self.ChoiceIndex)
end

return FunctionNpcBranch
