local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ScoreMgr = _G.ScoreMgr

---@class CommMoneyBarVM : UIViewModel
local CommMoneySlotVM = LuaClass(UIViewModel)

function CommMoneySlotVM:Ctor()
    self.ScoreID = nil
    self.ScoreValue = nil
end

function CommMoneySlotVM:UpdateByScoreID(ScoreID)
    self.ScoreID = ScoreID

    local Value = ScoreMgr:GetScoreValueByID(ScoreID)
    if Value == nil or Value < 0 then
        Value = 0
    end

    self.ScoreValue = Value
end

return CommMoneySlotVM