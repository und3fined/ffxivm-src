local LuaClass = require("Core/LuaClass")
local FunctionBase = require("Game/Interactive/FunctionItem/FunctionBase")

local FunctionDeafaultTalk = LuaClass(FunctionBase)


function FunctionDeafaultTalk:Ctor()
    self.FuncType = LuaFuncType.HINT_TALK_FUNC
end

function FunctionDeafaultTalk:OnInit(DisplayName, FuncParams)
    self.DisplayName = DisplayName
end

function FunctionDeafaultTalk:OnClick()
    _G.NpcDialogMgr:PlayDialogLib(self.FuncParams.FuncValue, self.FuncParams.EntityID)
    return true
end

return FunctionDeafaultTalk
