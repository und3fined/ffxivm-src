---
--- Author: Leo
--- DateTime: 2023-9-19 15:30:34
--- Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RichTextUtil = require("Utils/RichTextUtil")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
---@class JumboCactpotBuffRItemVM : UIViewModel

local JumboCactpotBuffRItemVM = LuaClass(UIViewModel)

function JumboCactpotBuffRItemVM:Ctor()
    self.Level = ""
    self.BaseReward = ""
    self.IncreaseReward = ""
end

function JumboCactpotBuffRItemVM:IsEqualVM()
    return true
end

function JumboCactpotBuffRItemVM:UpdateVM(Value)
    self.Level = string.format("%s等奖", Value.Level)
    self.BaseReward = Value.BaseReward
    if Value.IncreaseReward == "---" then
        self.IncreaseReward = Value.IncreaseReward
        return
    end
    local Content = string.format("+%s", Value.IncreaseReward)
    local RichText = RichTextUtil.GetText(Content, JumboCactpotDefine.ColorDefine.Orange)
    self.IncreaseReward = RichText
end

return JumboCactpotBuffRItemVM