--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:奖励ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ScoreMgr = require("Game/Score/ScoreMgr")

---@class FashionAwardItemVM : UIViewModel
local FashionAwardItemVM = LuaClass(UIViewModel)

function FashionAwardItemVM:Ctor()
    self.Num = 0
    self.AwardID = 0
    self.AwardIcon = ""
end


function FashionAwardItemVM:IsEqualVM(Value)
    return Value ~= nil
end

function FashionAwardItemVM:UpdateVM(Value)
    self.Num = ScoreMgr.FormatScore(Value.Coins) or ""
    self.AwardID = Value.AwardID
    local Cfg = ItemCfg:FindCfgByKey(self.AwardID)
	if Cfg then
		self.AwardIcon = UIUtil.GetIconPath(Cfg.IconID)
    end
end

return FashionAwardItemVM