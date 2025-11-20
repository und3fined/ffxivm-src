local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local MountSpeedUnlockInfoVM = LuaClass(UIViewModel)

function MountSpeedUnlockInfoVM:Ctor()
    self.QuestTitle = ""
    self.QuestRichText = ""
    self.ItemID = 0
    self.ID = 0
    self.PanelFlightSpeedVisible = false
end

function MountSpeedUnlockInfoVM:IsEqualVM(Value)
    return self.ID == Value.ID
end 

function MountSpeedUnlockInfoVM:UpdateVM(Value)
    self.QuestTitle = Value.Title
    self.QuestRichText =  Value.Info
    self.ItemID = Value.ItemID
    self.ID = Value.ID
    if self.ID == 3 then
        self.PanelFlightSpeedVisible = true
    else
        self.PanelFlightSpeedVisible = false
    end
end

return MountSpeedUnlockInfoVM