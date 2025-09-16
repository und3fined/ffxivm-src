local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local MountSpeedUnlockInfoVM = LuaClass(UIViewModel)

function MountSpeedUnlockInfoVM:Ctor()
    self.QuestTitle = ""
    self.QuestRichText = ""
    self.ItemID = 0
end

function MountSpeedUnlockInfoVM:UpdateVM(Value)
    self.QuestTitle = Value.Title
    self.QuestRichText =  Value.Info
    self.ItemID = Value.ItemID
end

return MountSpeedUnlockInfoVM