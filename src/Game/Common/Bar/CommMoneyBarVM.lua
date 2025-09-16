local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreMgr = _G.ScoreMgr

---@class CommMoneyBarVM : UIViewModel
local CommMoneyBarVM = LuaClass(UIViewModel)

function CommMoneyBarVM:Ctor()
    self.ScoreID = nil
    self.ScoreValue = nil
end

function CommMoneyBarVM:UpdateByScoreID(ScoreID)
	self.ScoreValue = ScoreMgr:GetScoreValueByID(ScoreID)
    if self.ScoreValue == nil or self.ScoreValue < 0 then
        self.ScoreValue = 0
    end
    --print("self.ScoreValue = "..table_to_string(self.ScoreValue))
    --self.ScoreValue = 1231497.52314
end

return CommMoneyBarVM