---
--- Author: Leo
--- DateTime: 2023-10-11 11:16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
---@class GoldSaucerCuffBlowResultItemVM : UIViewModel

local GoldSaucerCuffBlowResultItemVM = LuaClass(UIViewModel)

---Ctor
function GoldSaucerCuffBlowResultItemVM:Ctor()
    -- Main Part
    self.bPerfectVisible = false
    self.bExcellentVisible = false
    self.bFailVisible = false
    self.bPerfectComboVisible = false
    self.bComboVisible = false
    self.ComboNum = ""
end

function GoldSaucerCuffBlowResultItemVM:IsEqualVM(Value)
    return true
end

function GoldSaucerCuffBlowResultItemVM:UpdateVM(Value)
    if Value == nil then
        return
    end
    self.bPerfectVisible = Value.bPerfectVisible
    self.bExcellentVisible = Value.bExcellentVisible
    self.bFailVisible = Value.bFailVisible
    if Value.bPerfectComboVisible ~= nil then
        self.bPerfectComboVisible = Value.bPerfectComboVisible
    end
    if Value.bComboVisible ~= nil then
        self.bComboVisible = Value.bComboVisible
    end

    if Value.ComboNum ~= nil then
        self.ComboNum = Value.ComboNum
        self.bComboVisible = Value.bComboVisible
    end
end

function GoldSaucerCuffBlowResultItemVM:ResetVM()
    -- Main Part
    self.bPerfectVisible = false
    self.bExcellentVisible = false
    self.bFailVisible = false
    self.bPerfectComboVisible = false
    self.bComboVisible = false
    self.ComboNum = ""
end

return GoldSaucerCuffBlowResultItemVM   