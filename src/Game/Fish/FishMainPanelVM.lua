local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FishMainPanelVM : UIViewModel
local FishMainPanelVM = LuaClass(UIViewModel)

function FishMainPanelVM:Ctor()
    self.bBiteTimerPanel = false
    self.bFishThingTips = false
    self.bFishAreaPanel = true
end

function FishMainPanelVM:OnFishDrop()
    self.bBiteTimerPanel = true
end

function FishMainPanelVM:OnFishLift()
    self.bFishThingTips = true
end

function FishMainPanelVM:OnFishEnd()

end

function FishMainPanelVM:SetFishAreaPanel(bShow)
    self.bFishAreaPanel = bShow
end

return FishMainPanelVM