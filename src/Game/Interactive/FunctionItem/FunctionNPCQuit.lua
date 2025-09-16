
local LuaClass = require("Core/LuaClass")
local FunctionBase = require("Game/Interactive/FunctionItem/FunctionBase")

local FunctionNPCQuit = LuaClass(FunctionBase)


function FunctionNPCQuit:Ctor()
    self.FuncType = LuaFuncType.NPCQUIT_FUNC
end

function FunctionNPCQuit:OnInit(DisplayName, FuncParams)
    self:SetIconPath("Texture2D'/Game/UI/Texture/NPCTalk/UI_NPC_Icon_Leave.UI_NPC_Icon_Leave'")
end

function FunctionNPCQuit:OnClick()
    _G.InteractiveMgr:ClearCustomData()
    _G.NpcDialogMgr:PlayDialogLib(self.FuncParams.FuncValue, -1)

    return true
end

return FunctionNPCQuit
