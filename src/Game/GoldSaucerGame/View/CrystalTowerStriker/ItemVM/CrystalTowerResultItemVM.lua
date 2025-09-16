---
--- Author: Leo
--- DateTime: 2023-10-11 11:16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
---@class CrystalTowerResultItemVM : UIViewModel

local CrystalTowerResultItemVM = LuaClass(UIViewModel)

---Ctor
function CrystalTowerResultItemVM:Ctor()
    -- Main Part
    self.VarName = ""
    self.Value = ""
    self.bIsNewRecord = false
    self.bIsPerfectChallenge = false
end

function CrystalTowerResultItemVM:IsEqualVM(Value)
    return true
end

function CrystalTowerResultItemVM:UpdateVM(Data)
    if Data == nil then
        return
    end
    self.VarName = Data.VarName
    self.Value = Data.Value
    local ShowNewRecord = Data.bIsNewRecord
    self.bIsNewRecord = ShowNewRecord
    self.bIsPerfectChallenge = ShowNewRecord
end

return CrystalTowerResultItemVM