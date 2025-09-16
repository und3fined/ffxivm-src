---
--- Author: Leo
--- DateTime: 2023-10-11 11:16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local GoldSaucerCuffBlowResultItemVM = require("Game/GoldSaucerGame/View/Cuff/ItemVM/GoldSaucerCuffBlowResultItemVM")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")

local CuffDefine = GoldSaucerMiniGameDefine.CuffDefine

local TimerMgr = _G.TimerMgr

---@class CrystalTowerInteractResultItemVM : UIViewModel

local CrystalTowerInteractResultItemVM = LuaClass(UIViewModel)

---Ctor
function CrystalTowerInteractResultItemVM:Ctor()
    -- self.Pos = 0
    self.bMissVisible = false
    self.bExcellentVisible = false
    self.bProfectVisible = false
    self.bMultipleVisible = false
    self.ComboNum = 0
    self.CallBackIndex = 0
    -- self.ChooseVisibleIndex = 
end

function CrystalTowerInteractResultItemVM:IsEqualVM(Value)
    return true
end

function CrystalTowerInteractResultItemVM:UpdateVM(Value)
    if Value == nil then
        return
    end
    -- self.Pos = Value.Pos
    self.bMissVisible = Value.bMissVisible
    self.bExcellentVisible = Value.bExcellentVisible
    self.bProfectVisible = Value.bProfectVisible
    self.bMultipleVisible = Value.bMultipleVisible
    self.ComboNum = Value.ComboNum
    self.CallBackIndex = self.CallBackIndex + 1

    if self.ResetTimer ~= nil then
        TimerMgr:CancelTimer(self.ResetTimer)
    end
    self.ResetTimer = TimerMgr:AddTimer(self, function() self:ResetVM() end, 3.17)
end

function CrystalTowerInteractResultItemVM:ResetVM()
    -- self.Pos = 0
    self.bMissVisible = false
    self.bExcellentVisible = false
    self.bProfectVisible = false
    self.bMultipleVisible = false
    self.ComboNum = 0
end

function CrystalTowerInteractResultItemVM:IsEqualVM(Value)
    return true
end

return CrystalTowerInteractResultItemVM