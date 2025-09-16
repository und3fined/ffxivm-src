--
-- Author: Carl
-- Date: 2023-11-08 16:57:14
-- Description:幻卡大赛排名ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local MagicCardTourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local MajorUtil = require("Utils/MajorUtil")

---@class MagicCardTourneyRankItemVM : UIViewModel
---@field Rank number @积分排名
---@field PlayerName string @玩家名字
---@field Score number @大赛积分
---@field IsPlayerSelf boolean @是否本地玩家
---
local MagicCardTourneyRankItemVM = LuaClass(UIViewModel)

function MagicCardTourneyRankItemVM:Ctor()
    self.Rank = 0
    self.PlayerName = ""
    self.Score = 0
    self.IsPlayerSelf = false
    self.IsCupIconVisible = false
    self.RoleID = 0
    self.CupIcon = ""
end

function MagicCardTourneyRankItemVM:IsEqualVM(Value)
	return Value and Value.RoleID == self.RoleID
end

function MagicCardTourneyRankItemVM:UpdateVM(Value)
    if Value == nil then
        return
    end
    self.RoleID = Value.RoleID 
    self.IsPlayerSelf = MajorUtil.IsMajorByRoleID(self.RoleID)
    self.Rank = Value.Rank
    self.IsCupIconVisible = true
    self.Score = Value.Score
    if self.Rank <=3 then
        self.CupIcon = MagicCardTourneyDefine.CupIconPath[self.Rank] or ""
    else
        self.CupIcon = MagicCardTourneyDefine.CupIconPath[4]
    end
    _G.RoleInfoMgr:QueryRoleSimple(
        self.RoleID,
        function(_, RoleVM)
            if RoleVM then
                self.PlayerName = RoleVM.Name
            end
        end
    )

end

return MagicCardTourneyRankItemVM