--
-- Author: Carl
-- Date: 2023-09-08 16:57:14
-- Description:幻卡奖励列表ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")

---@class MagicCardAwardItemVM : UIViewModel
local MagicCardAwardItemVM = LuaClass(UIViewModel)

function MagicCardAwardItemVM:Ctor()
    self.CollectTargetNum = 0
    self.IsGetProgress = false
    self.IsCollectedAward = false
    self.AwardID = 0
    self.AwardIcon = ""
end


function MagicCardAwardItemVM:IsEqualVM(Value)
    return Value.CollectTargetNum == self.CollectTargetNum
end

function MagicCardAwardItemVM:GetKey()
    return self.CollectTargetNum
end

function MagicCardAwardItemVM:UpdateVM(Value)
    self.CollectTargetNum = Value.CollectTargetNum
    self.IsGetProgress = Value.IsGetProgress
    self.IsCollectedAward = Value.IsCollectedAward
    self.AwardID = Value.AwardID

    local Cfg = ItemCfg:FindCfgByKey(self.AwardID)
	if Cfg then
		self.AwardIcon = UIUtil.GetIconPath(Cfg.IconID)
	end

end

return MagicCardAwardItemVM