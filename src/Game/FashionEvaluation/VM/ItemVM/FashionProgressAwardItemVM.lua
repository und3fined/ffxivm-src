--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:品鉴进度奖励列表ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ScoreMgr = require("Game/Score/ScoreMgr")

---@class FashionProgressAwardItemVM : UIViewModel
local FashionProgressAwardItemVM = LuaClass(UIViewModel)

function FashionProgressAwardItemVM:Ctor()
    self.IsGetProgress = false
    self.ProgressName = ""
    self.AwardID = 0
    self.AwardNum = 0
    self.AwardIcon = ""
    self.IsNewGet = false -- 是否最新获取奖励
    self.UnLockAwardIndex = 0
end


function FashionProgressAwardItemVM:IsEqualVM(Value)
    return Value ~= nil and Value.ProgressName == self.ProgressName
end

function FashionProgressAwardItemVM:UpdateVM(Value)
    self.IsGetProgress = Value.IsGetProgress
    self.AwardID = Value.AwardID
    self.AwardNum = Value.AwardNum
    if self.AwardNum >= 100000 then
        self.AwardNum = math.floor(self.AwardNum/100000).."W"
    else
        self.AwardNum = ScoreMgr.FormatScore(Value.AwardNum) or ""
    end
    self.ProgressName = Value.ProgressName
    self.IsNewGet = Value.IsNewGet
    self.UnLockAwardIndex = Value.UnLockAwardIndex
    local Cfg = ItemCfg:FindCfgByKey(self.AwardID)
	if Cfg then
		self.AwardIcon = UIUtil.GetIconPath(Cfg.IconID)
	end
end

return FashionProgressAwardItemVM