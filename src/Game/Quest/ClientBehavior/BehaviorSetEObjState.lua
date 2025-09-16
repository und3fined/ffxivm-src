
local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")
local QuestHelper = require("Game/Quest/QuestHelper")

---@class BehaviorSetEObjState
local BehaviorSetEObjState = LuaClass(BehaviorBase, true)

function BehaviorSetEObjState:Ctor(_, Properties)
    self.EObjID = tonumber(Properties[1]) or 0
    self.State = tonumber(Properties[3]) or 0
end

function BehaviorSetEObjState:DoStartBehavior()
    if self.EObjID > 0 then
        local QuestRegister = _G.QuestMgr.QuestRegister
        if self.State > 0 then
            QuestRegister:RegisterEObjState(self.EObjID, self.State)
            _G.UE.UActorManager:Get():SetEObjStateByResID(self.EObjID, self.State)
        else
            QuestRegister:UnRegisterEObjState(self.EObjID)
        end
    else
        QuestHelper.PrintQuestWarning("BehaviorSetEObjState invalid EObj %d state %d", self.EObjID, self.State)
    end
end

return BehaviorSetEObjState