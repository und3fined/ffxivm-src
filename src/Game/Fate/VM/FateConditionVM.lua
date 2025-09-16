local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FateUtil = require("Game/Fate/FateUtil")
local LSTR = _G.LSTR

local FateConditionVM = LuaClass(UIViewModel)

function FateConditionVM:Ctor()
    self.ID = 0
    self.PanelStatus = 0
    self.ConditionText = ""
end

function FateConditionVM:OnBegin()

end

function FateConditionVM:IsEqualVM(Value)
    return self.ID == Value.ID
end

function FateConditionVM:UpdateVM(Value)
    self.ID = Value.ID
    self.PanelStatus = FateUtil.GetPanelStatus(Value)
    self.ConditionText = FateUtil.GetConditionText(Value)
    self.ShowEffect = Value.ShowEffect
end

function FateConditionVM:IsHide()
    return self.PanelStatus == 0
end

return FateConditionVM