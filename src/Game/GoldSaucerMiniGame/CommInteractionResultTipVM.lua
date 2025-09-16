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

---@class CommInteractionResultTipVM : UIViewModel

local CommInteractionResultTipVM = LuaClass(UIViewModel)

---Ctor
function CommInteractionResultTipVM:Ctor()
    self.bSuccessTipVisible = false
    self.bPrettyTipVisible = false
    self.bGoodTipVisible = false
    self.bFailTipVisible = false
    self.bYellowTipVisible = false

    self.Text = ""
    self.SubText = ""

    self.bSubDataVisible = false
    self.SubTextColor = "D5D5D5FF"
end

function CommInteractionResultTipVM:IsEqualVM(Value)
    return true
end

function CommInteractionResultTipVM:UpdateVM(Value)
    if Value == nil then
        return
    end
    local bSuccessTipVisible, bPrettyTipVisible, bGoodTipVisible, bFailTipVisible, bYellowTipVisible = false, false, false, false, false
    if Value.bSuccessTipVisible ~= nil and Value.bSuccessTipVisible then
        bSuccessTipVisible = true
        bPrettyTipVisible = false
        bGoodTipVisible = false
        bFailTipVisible = false
        bYellowTipVisible = false
    elseif Value.bPrettyTipVisible ~= nil and Value.bPrettyTipVisible then
        bSuccessTipVisible = false
        bPrettyTipVisible = true
        bGoodTipVisible = false
        bFailTipVisible = false
        bYellowTipVisible = false
    elseif Value.bGoodTipVisible ~= nil and Value.bGoodTipVisible then
        bSuccessTipVisible = false
        bPrettyTipVisible = false
        bGoodTipVisible = true
        bFailTipVisible = false
        bYellowTipVisible = false
    elseif Value.bFailTipVisible ~= nil and Value.bFailTipVisible then
        bSuccessTipVisible = false
        bPrettyTipVisible = false
        bGoodTipVisible = false
        bFailTipVisible = true
        bYellowTipVisible = false
    elseif Value.bYellowTipVisible ~= nil and Value.bYellowTipVisible then
        bSuccessTipVisible = false
        bPrettyTipVisible = false
        bGoodTipVisible = false
        bFailTipVisible = false
        bYellowTipVisible = true
    end

    self.bSuccessTipVisible = bSuccessTipVisible
    self.bPrettyTipVisible = bPrettyTipVisible
    self.bGoodTipVisible = bGoodTipVisible
    self.bFailTipVisible = bFailTipVisible
    self.bYellowTipVisible = bYellowTipVisible

    if bSuccessTipVisible or bPrettyTipVisible or bGoodTipVisible or bFailTipVisible or bYellowTipVisible then
        self.Text = Value.Text
        self.SubText = Value.SubText
    end
    if Value.bSubDataVisible ~= nil then
        self.bSubDataVisible = Value.bSubDataVisible
    end
    if Value.SubTextColor ~= nil then
        self.SubTextColor = Value.SubTextColor
    end
end

function CommInteractionResultTipVM:ResetVM()
    self.bSuccessTipVisible = false
    self.bPrettyTipVisible = false
    self.bGoodTipVisible = false
    self.bFailTipVisible = false
    self.bYellowTipVisible = false

    self.Text = ""
    self.SubText = ""

    self.bSubDataVisible = false
    self.SubTextColor = "D5D5D5FF"
end

return CommInteractionResultTipVM