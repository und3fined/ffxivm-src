---
--- Author: Leo
--- DateTime: 2023-9-19 15:30:34
--- Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LSTR = _G.LSTR
---@class JumboCactpotBuffLItemVM : UIViewModel

local JumboCactpotBuffLItemVM = LuaClass(UIViewModel)

function JumboCactpotBuffLItemVM:Ctor()
    self.IDStage = ""
    self.Level = {}
    self.RewardBonus = ""
    self.Ranking = ""
    self.bIsFinish = false
    self.bIsSelect = false
    self.bNoFinish = true
    self.NoFinishText = ""
    self.Progress = 0
    self.Percent = 0
end

function JumboCactpotBuffLItemVM:IsEqualVM()
    return true
end

function JumboCactpotBuffLItemVM:UpdateVM(Value)
    self.IDStage = Value.IDStage
    self.Level = Value.Level
    self.Ranking = Value.Ranking

    self.RewardBonus = Value.RewardBonus

    self.NoFinishText = Value.Progress

    if self.NoFinishText == LSTR(240036) then -- 达成
        self.bIsFinish = true
    else
        self.bIsFinish = false
    end
    self.bNoFinish = not self.bIsFinish
    self.Percent = Value.Percent
  
end

return JumboCactpotBuffLItemVM