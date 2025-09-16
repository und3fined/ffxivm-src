--
-- Author: ZhengJanChuan
-- Date: 2024-12-16 15:50
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BattlePassRewardSlotVM = require("Game/BattlePass/VM/Item/BattlePassRewardSlotVM")
local BattlePassDefine = require("Game/BattlePass/BattlePassDefine")

local Path1 = "PaperSprite'/Game/UI/Atlas/BattlePass/Frames/UI_BattlePass_Icon_RewardNumber01_png.UI_BattlePass_Icon_RewardNumber01_png'"
local Path2 = "PaperSprite'/Game/UI/Atlas/BattlePass/Frames/UI_BattlePass_Icon_RewardNumber02_png.UI_BattlePass_Icon_RewardNumber02_png'"

---@class BattlePassRewardListItemVM : UIViewModel
local BattlePassRewardListItemVM = LuaClass(UIViewModel)

---Ctor
function BattlePassRewardListItemVM:Ctor()
    self.Lv = 0
    self.IsCurLv = false
    self.BaseReward = BattlePassRewardSlotVM.New()
    self.AdvanceReward = BattlePassRewardSlotVM.New()
end

function BattlePassRewardListItemVM:OnInit()
end

function BattlePassRewardListItemVM:OnBegin()
end

function BattlePassRewardListItemVM:OnEnd()
end

function BattlePassRewardListItemVM:OnShutdown()
end

function BattlePassRewardListItemVM:UpdateVM(Value)
    local CurLevel = _G.BattlePassMgr:GetBattlePassLevel()
    local Grade = _G.BattlePassMgr:GetBattlePassGrade()
    self.Lv = Value.Lv
    self.IsCurLv = Value.IsCurLv
    self.BaseReward:UpdateVM(Value.BaseReward)
    self.AdvanceReward:UpdateVM(Value.AdvanceReward)
    self.LvIcon = Value.IsCurLv and Path2 or Path1
    self.LvColor = Value.IsCurLv and "#313131" or "#D5D5D5"
    local BasicReward = _G.BattlePassMgr:GotLevelReward(self.Lv, BattlePassDefine.GradeType.Basic)
    local MiddleReward = _G.BattlePassMgr:GotLevelReward(self.Lv, BattlePassDefine.GradeType.Middle)
    if Grade == BattlePassDefine.GradeType.Basic then
        self.IsAvailable = CurLevel >=  self.Lv and not BasicReward
    else
        self.IsAvailable = CurLevel >=  self.Lv and (not BasicReward or not MiddleReward)
    end

end

--要返回当前类
return BattlePassRewardListItemVM