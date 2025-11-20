local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local LSTR = _G.LSTR

---@class HouseLandPurchaseTheTermListItemVM : UIViewModel
local HouseLandPurchaseTheTermListItemVM = LuaClass(UIViewModel)

---Ctor
function HouseLandPurchaseTheTermListItemVM:Ctor()
    self.Name = nil
    self.IsSelect = false
    self.PhaseID = nil
    self.Color = nil
end

function HouseLandPurchaseTheTermListItemVM:IsEqualVM(Value)
    return nil ~= self.PhaseID and Value.PhaseID == self.PhaseID
end


function HouseLandPurchaseTheTermListItemVM:UpdateVM(Value, Param)
    self.Name = Value.Name
    self.IsSelect = Value.IsSelect
    self.PhaseID = Value.PhaseID
    if Value.IsSelect then
        self.Color = "FFF4D0FF"
    else
        self.Color = "D5D5D57F"
    end
end

return HouseLandPurchaseTheTermListItemVM
