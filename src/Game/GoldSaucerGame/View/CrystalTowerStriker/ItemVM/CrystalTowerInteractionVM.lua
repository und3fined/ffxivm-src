---
--- Author: Leo
--- DateTime: 2023-10-11 11:16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")

local ItemCfg = require("TableCfg/ItemCfg")
local GoldSaucerCuffBlowResultItemVM = require("Game/GoldSaucerGame/View/Cuff/ItemVM/GoldSaucerCuffBlowResultItemVM")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local CuffDefine = GoldSaucerMiniGameDefine.CuffDefine
local MaxSwitchIndex = 5
local SwitchWidgetIndex = {Blue = 1, Purple = 2, Yellow = 3, Gray = 4, Red = 5, StarLight = 6}
local TimerMgr = _G.TimerMgr

---@class CrystalTowerInteractionVM : UIViewModel

local CrystalTowerInteractionVM = LuaClass(UIViewModel)

---Ctor
function CrystalTowerInteractionVM:Ctor()

    self.Category = 0

end

function CrystalTowerInteractionVM:IsEqualVM(Value)
    return true
end

function CrystalTowerInteractionVM:UpdateVM(Value)
    if Value == nil then
        return
    end
    local CrystalTowerInteractionCategory = ProtoRes.CrystalTowerInteractionCategory
    if Value.Category <= CrystalTowerInteractionCategory.CT_CATEGORY_ERROR then
        self.Category = Value.Category
    elseif Value.Category == ProtoRes.CrystalTowerInteractionCategory.CT_CATEGORY_STARLIGHT then
        self.Category = SwitchWidgetIndex.StarLight
    else
        self.Category = SwitchWidgetIndex.Red
    end
end

function CrystalTowerInteractionVM:ResetVM()
    self.Category = 0
end

return CrystalTowerInteractionVM