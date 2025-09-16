--@author star
--@date 2024--06--04

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyBonusStateGetType = ArmyDefine.ArmyBonusStateGetType


---@Class ArmySpecialEffectsGetItemVM : UIViewModel

local ArmySpecialEffectsGetItemVM = LuaClass(UIViewModel)

function ArmySpecialEffectsGetItemVM:Ctor()
    self.ID = nil
    self.IsSeleceted = nil
    self.Name = nil
    self.Desc = nil
    self.Icon = nil
    self.Num = nil
    self.Level = nil
    self.Cost = nil
    self.IsGrey = nil
    self.Grade = nil
    self.IsUnlock = nil
    self.UnLockLv = nil
    self.IsPremission = nil
    self.bUsed = nil
    self.SaleValue = nil
end

function ArmySpecialEffectsGetItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function ArmySpecialEffectsGetItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.IsSeleceted = false
    self.Name = Value.Name
    self.Desc = Value.Desc
    self.Icon = Value.Icon
    self.Num = Value.Num
    self.Level = Value.Level
    self.UnLockLv = Value.UnLockLv
    self.Cost = Value.Cost
    self.GetType = Value.GetType
    self.IsUsed = Value.IsUsed
    self.bUsed = Value.bUsed
    self.IsPremission = Value.IsPremission
    if self.IsUsed then
        self.bUsed = true
    end
    self.IsGrey = self.Num == 0
    self.Grade = self:ToRomanNumUKeybyNum(self.Level)
    self.IsUnlock = Value.IsUnlock
    self.UsedIndex = Value.UsedIndex
    self.SaleValue = Value.SaleValue
    if self.GetType ==  ArmyBonusStateGetType.Buy or self.GetType ==  ArmyBonusStateGetType.UnOpen then
        local Cost = self.Cost
        if self.SaleValue then
            Cost = self.Cost * ((100 - self.SaleValue)/100)
        end
        -- LSTR string:单价:
        self.CostStr = string.format("%s %d", LSTR(910077), Cost)
    elseif self.GetType ==  ArmyBonusStateGetType.AetherWheel then
        -- LSTR string:以太转轮开启
        self.CostStr = LSTR(910038)
    end
    -- LSTR string:持有:
    self.HaveStr = string.format("%s %d", LSTR(910143), self.Num)
end

function ArmySpecialEffectsGetItemVM:AdapterOnGetWidgetIndex()
    return self.ID
end

function ArmySpecialEffectsGetItemVM:ToRoman(Num)
    local RomanNumerals = {
        {1000, "M"},
        {900, "CM"},
        {500, "D"},
        {400, "CD"},
        {100, "C"},
        {90, "XC"},
        {50, "L"},
        {40, "XL"},
        {10, "X"},
        {9, "IX"},
        {5, "V"},
        {4, "IV"},
        {1, "I"}
    }

    local RomanNumeral = ""
    for _, Numeral in ipairs(RomanNumerals) do
        while Num >= Numeral[1] do
            RomanNumeral = RomanNumeral .. Numeral[2]
            Num = Num - Numeral[1]
        end
    end

    return RomanNumeral
end

---多语言罗马数字，部分地区会使用阿拉伯数字，策划确认只有3级
function ArmySpecialEffectsGetItemVM:ToRomanNumUKeybyNum(Num)
    if Num == 1 then
        -- LSTR string:I
        return LSTR(910279)
    elseif Num == 2 then
        -- LSTR string:II
        return LSTR(910280)
    elseif Num >= 3 then
        -- LSTR string:III
        return LSTR(910281)
    else
        return ""
    end
end

function ArmySpecialEffectsGetItemVM:SetIsUnlock(IsUnlock)
    self.IsUnlock = IsUnlock
end

function ArmySpecialEffectsGetItemVM:GetIsUnlock()
    return self.IsUnlock
end

function ArmySpecialEffectsGetItemVM:SetGetType(GetType)
    self.GetType = GetType
end

function ArmySpecialEffectsGetItemVM:GetGetType()
    return self.GetType
end

return ArmySpecialEffectsGetItemVM