--
-- Author: Alex
-- Date: 2023-10-12 19:32
-- Description:金蝶小游戏 孤树无援
--

local LuaClass = require("Core/LuaClass")
local MiniGameBaseVM = require("Game/GoldSaucerMiniGame/MiniGameBaseVM")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameState = GoldSaucerMiniGameDefine.MiniGameStageType

---@class MiniGameOutOnALimbVM
local MiniGameOutOnALimbVM = LuaClass(MiniGameBaseVM)

---Ctor
function MiniGameOutOnALimbVM:Ctor()
    self.bShowDifficultyPanel = true -- 是否显示选择难度界面
    self.bShowCutPanel = false -- 是否显示砍伐界面
    self.bActBtnEnable = true -- 动作按钮是否生效

    self.TextTipsTitle = "" -- 界面功能提示
    self.YellowPointerAngle = -45 -- 正常指针角度
    self.RedPointerAngle = -45 -- 失败后标准指针角度
    self.GreyPointerAngle = -45 -- 上一次指针位置
    self.RewardGot = "" -- 获取奖励数量
    self.RewardAdd = "" -- 增加奖励数量
    self.bShowRewardAdd = false -- 是否显示奖励增加界面
    self.bShowObtainPanel = false -- 是否显示奖励界面
    --self.bTopTipsShow = false -- 小游戏tips

    self.bKeyTime = false -- 游戏紧张时刻(小于3s)
    self.bShowCutTimePanel = false -- 显示砍伐时间面板
end

--- 更新小游戏VM
function MiniGameOutOnALimbVM:OnUpdateVM()
end

--- 刷新时间显示
function MiniGameOutOnALimbVM:OnUpdateTimeShow()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    local TotalTime = GameInst:GetRemainSeconds()
    if self.GameState == MiniGameState.DifficultySelect then
        self.bKeyTime = false
        return
    end
    local StageLimit = GoldSaucerMiniGameDefine.TimeStageLimit
    if TotalTime > StageLimit.Urgent then
        self.bKeyTime = false
    else
        self.bKeyTime = true 
    end
end

return MiniGameOutOnALimbVM