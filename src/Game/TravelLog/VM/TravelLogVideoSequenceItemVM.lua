---
--- Author: sammrli
--- DateTime: 2024-02-02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class TravelLogVideoSequenceItemVM : UIViewModel
local TravelLogVideoSequenceItemVM = LuaClass(UIViewModel)

function TravelLogVideoSequenceItemVM:Ctor()
    self.Index = 0
    self.SequenceID = 0
    self.Text = ""
    self.Path = ""
    self.Selected = false
    self.MapID = 0
    self.ColorHex = "ffeebb"
    self.IsNoContent = nil
end

function TravelLogVideoSequenceItemVM:UpdateVM(Value)
    self.Index = Value.Index
    self.SequenceID = Value.SequenceID
    self.Text = Value.Text
    self.Path = Value.Path
    self.Selected = Value.Selected
    self.MapID = Value.MapID

    self.IsNoContent = string.isnilorempty(Value.Text)

    self:UpdateColorHex()
end

function TravelLogVideoSequenceItemVM:SetSelected(Value)
    self.Selected = Value
    self:UpdateColorHex()
end

function TravelLogVideoSequenceItemVM:UpdateColorHex()
    if self.Selected then
        self.ColorHex = "313131"
    else
        self.ColorHex = "ffeebb"
    end
end

return TravelLogVideoSequenceItemVM