---
--- Author: Leo
--- DateTime: 2024-2-19 11:16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local TextColor = { TwoToSixCombo = "#D5D5D5", SevenToFifColor = " #D1BA8E", OverSixteen = "#D1906D"  }
local ComboStageCfg = {FirstStage = 2, SecondStage = 7, EndStage = 16}
---@class GoldSaucerMonsterTossShootingResultTipVM : UIViewModel

local GoldSaucerMonsterTossShootingResultTipVM = LuaClass(UIViewModel)

---Ctor
function GoldSaucerMonsterTossShootingResultTipVM:Ctor()
    -- Main Part
    self.bSuccessTipVisible = false
    self.bFailTipVisible = false
    self.ComboTipText = ""
    self.bComboTipVisible = false
    self.ComboTipColor = TextColor.TwoToSixCombo
    self.bImgLineVisible = false

end

function GoldSaucerMonsterTossShootingResultTipVM:IsEqualVM(Value)
    return true
end

function GoldSaucerMonsterTossShootingResultTipVM:UpdateVM(Value)
    if Value == nil or Value.ComboNum == nil then
        return
    end
    self.bSuccessTipVisible = Value.bSuccessTipVisible
    self.bFailTipVisible = Value.bFailTipVisible
    self.ComboTipText = Value.ComboTipText
    self.bComboTipVisible = Value.bComboTipVisible
    if Value.ComboNum >= ComboStageCfg.EndStage then
        self.ComboTipColor = TextColor.OverSixteen
    elseif Value.ComboNum >= ComboStageCfg.SecondStage then
        self.ComboTipColor = TextColor.SevenToFifColor
    elseif Value.ComboNum >= ComboStageCfg.FirstStage then
        self.ComboTipColor = TextColor.TwoToSixCombo
    end
    self.bImgLineVisible = Value.bSuccessTipVisible
end

function GoldSaucerMonsterTossShootingResultTipVM:Reset()
    -- Main Part
    self.bSuccessTipVisible = false
    self.bFailTipVisible = false
    self.ComboTipText = ""
    self.bComboTipVisible = false
    self.ComboTipColor = TextColor.TwoToSixCombo
    self.bImgLineVisible = false
end

return GoldSaucerMonsterTossShootingResultTipVM   