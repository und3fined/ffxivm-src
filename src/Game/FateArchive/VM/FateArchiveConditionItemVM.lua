local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FateUtil = require("Game/Fate/FateUtil")
local LSTR = _G.LSTR
local FateDefine = require("Game/Fate/FateDefine")

local FateArchiveConditionItemVM = LuaClass(UIViewModel)

function FateArchiveConditionItemVM:Ctor()
    self.ID = 0
    self.PanelStatus = 1
    self.ConditionText = ""
end

function FateArchiveConditionItemVM:OnBegin()
end

function FateArchiveConditionItemVM:IsEqualVM(Value)
    return self.ID == Value.ID
end

function FateArchiveConditionItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.PanelStatus = FateUtil.GetPanelStatus(Value)
    self.ConditionText = FateUtil.GetConditionText(Value)
end

function FateArchiveConditionItemVM:IsHide()
    return self.PanelStatus == FateDefine.HiddenCondiState.Hide
end

return FateArchiveConditionItemVM
