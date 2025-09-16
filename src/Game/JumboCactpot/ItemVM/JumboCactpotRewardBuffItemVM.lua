---
--- Author: Leo
--- DateTime: 2023-9-19 15:30:34
--- Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")

---@class JumboCactpotRewardBuffItemVM : UIViewModel

local JumboCactpotRewardBuffItemVM = LuaClass(UIViewModel)

function JumboCactpotRewardBuffItemVM:Ctor()
    self.bBuffVisible = false
    self.RewardBuff01 = ""
    self.RewardBuff02 = ""
    self.RewardBuff03 = ""
    self.RewardBuff04 = ""
    self.RewardBuff05 = ""
    self.TextColor = "#313131"

end

function JumboCactpotRewardBuffItemVM:IsEqualVM()
    return true
end

function JumboCactpotRewardBuffItemVM:UpdateVM(Value)
    self.bBuffVisible = Value.bBuffVisible 
    self.RewardBuff01 = Value.RewardBuff01 == 0 and "--" or string.format("+%s", UIBinderSetTextFormatForMoney:GetText(Value.RewardBuff01))
    self.RewardBuff02 = Value.RewardBuff02 == 0 and "--" or string.format("+%s", UIBinderSetTextFormatForMoney:GetText(Value.RewardBuff02))
    self.RewardBuff03 = Value.RewardBuff03 == 0 and "--" or string.format("+%s", UIBinderSetTextFormatForMoney:GetText(Value.RewardBuff03))
    self.RewardBuff04 = Value.RewardBuff04 == 0 and "--" or string.format("+%s", UIBinderSetTextFormatForMoney:GetText(Value.RewardBuff04))
    self.RewardBuff05 = Value.RewardBuff05 == 0 and "--" or string.format("+%s", UIBinderSetTextFormatForMoney:GetText(Value.RewardBuff05))
    self.TextColor = Value.TextColor
end

return JumboCactpotRewardBuffItemVM