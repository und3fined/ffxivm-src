---
--- Author: Leo
--- DateTime: 2024-2-19 11:16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local UIBindableList = require("UI/UIBindableList")

local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local LSTR = _G.LSTR
---@class CrystalTowerInteractResultVM : UIViewModel

local CrystalTowerInteractResultVM = LuaClass(UIViewModel)

---Ctor
function CrystalTowerInteractResultVM:Ctor()
    self.bNotInEndRound = true
    self.bInEndRound = false
    
end

function CrystalTowerInteractResultVM:IsEqualVM(Value)
    return true
end

function CrystalTowerInteractResultVM:UpdateVM(Value)
    if Value == nil then
        return
    end

end

function CrystalTowerInteractResultVM:Reset()

end

function CrystalTowerInteractResultVM:SetbInEndRound(bInEndRound)
    self.bNotInEndRound = true
    self.bInEndRound = bInEndRound
end


return CrystalTowerInteractResultVM   