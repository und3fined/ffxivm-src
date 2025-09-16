local LuaClass = require("Core/LuaClass")
local FunctionBase = require("Game/Interactive/FunctionItem/FunctionBase")

local FunctionQuit = LuaClass(FunctionBase)

function FunctionQuit:Ctor()
    self.FuncType = LuaFuncType.QUIT_FUNC
end

function FunctionQuit:OnInit(DisplayName, FuncParams)
    self:SetIconPath("Texture2D'/Game/UI/Texture/NPCTalk/UI_NPC_Icon_Leave.UI_NPC_Icon_Leave'")
end

function FunctionQuit:OnClick()
    _G.InteractiveMgr:ExitInteractive()
    _G.InteractiveMgr:ShowEntrances()
    _G.GatherMgr:SendExitGatherState()
    return true
end

return FunctionQuit
