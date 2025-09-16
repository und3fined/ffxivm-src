--
-- Author: Alex
-- Date: 2023-10-12 19:36
-- Description:金蝶小游戏基础VM
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
--local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameState = GoldSaucerMiniGameDefine.MiniGameStageType
local TimeUtil = require("Utils/TimeUtil")
local LSTR = _G.LSTR

---@class MiniGameBaseVM
local MiniGameBaseVM = LuaClass(UIViewModel)

---Ctor
function MiniGameBaseVM:Ctor()
    self.MiniGame = nil
    self.GameName = "" -- 游戏名称
    self.GoldPanelTitle = LSTR(360007) -- 默认货币栏title
    self.RoundRemainChances = "" -- 剩余次数显示
    self.DifficultyIconPath = "" -- 游戏难度图标路径

    self.ProgressCounter = 0 -- 进度玩法计数器
    self.LastProgress = 0 --上一次玩法进度
    self.Progress = 0 --当前玩法获取进度

    self.GameState = nil -- 游戏阶段状态

    self.TimeMinutesText = "" -- 时间分钟部分
    self.TimeSecondsText = "" -- 时间秒数部分
    self.TotalTimeTextTitle = "" -- 标题部分整体时间显示
    self.TotalTimeText = "" -- 整体时间显示
    self.bShowPanelCountDown = false -- 控制时间面板是否显示

    --self.bForceEmotionBtnHide = true -- 控制小游戏界面聊天面板情感动作按钮显隐

    self.TopTipsText = ""
    self.TopTipsTitle = ""
    self.bShowDifficultyMark = true

    self.ReconnectSuccess = false -- 是否重连成功
end

--- 创建VM并绑定GameInst
function MiniGameBaseVM:CreateVM(Value)
	self.MiniGame = Value
	self.GameName = Value:GetName()
    self:UpdateVM()
    --self:SetNoCheckValueChange("GameState", true)
end

--- 更新小游戏VM
function MiniGameBaseVM:UpdateVM()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
	self.RoundRemainChances = tostring(GameInst:GetRemainChances())
    local TimeSecondsInteger = GameInst:GetRemainSecondsInteger()
    local InitTimeText = TimeUtil.GetTimeFormat("%M:%S", TimeSecondsInteger)
    self.TotalTimeTextTitle = InitTimeText
    self.TotalTimeText = InitTimeText
    local Type = GameInst:GetGameType()
    local Difficulty = GameInst:GetDifficulty()
    local DifficultyIconPathList = MiniGameClientConfig[Type].DifficultyIconPath
    if DifficultyIconPathList then
        self.DifficultyIconPath = DifficultyIconPathList[Difficulty]
    end

    --- 进度
    local CurProgress = GameInst:GetAchieveRewardProgress()
    self.LastProgress = self.Progress
    self.Progress = 1 - CurProgress
    self.ProgressCounter = GameInst:GetProgressCounter()
    --- 表现处理放到View内

    self.GameState = GameInst:GetGameState()

    local TopTipsParams = GameInst:GetTopTipsContent()
    if TopTipsParams then
        self.TopTipsText = TopTipsParams.Content or  ""
        self.TopTipsTitle = TopTipsParams.Title or ""
        self.bShowDifficultyMark = TopTipsParams.bShowDifficultyMark
    end
    self:OnUpdateVM()
end

--- 刷新时间显示
function MiniGameBaseVM:UpdateTimeShow()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    local TotalTime = GameInst:GetRemainSeconds()
    local TimeSecondsInteger = GameInst:GetRemainSecondsInteger()
    local Minutes = math.floor(TimeSecondsInteger / 60)
    local MinutesText = tostring(Minutes)
    local SecondsText = tostring(TimeSecondsInteger - Minutes * 60) 
    self.TimeMinutesText = MinutesText
    self.TimeSecondsText = SecondsText
    self.TotalTimeTextTitle = TimeUtil.GetTimeFormat("%M:%S", TimeSecondsInteger)
    if self.GameState == MiniGameState.DifficultySelect then
        self.TotalTimeText = TimeUtil.GetTimeFormat("%M:%S", TimeSecondsInteger)
        return
    end
    local StageLimit = GoldSaucerMiniGameDefine.TimeStageLimit
    if TotalTime > StageLimit.Normal then
        self.TotalTimeText = TimeUtil.GetTimeFormat("%M:%S", TimeSecondsInteger)
    else
        self.TotalTimeText = string.format("%.2f", TotalTime)
    end
    self:OnUpdateTimeShow()
end

--- 子类派生方法
function MiniGameBaseVM:OnUpdateVM()
end

function MiniGameBaseVM:OnUpdateTimeShow()
end

return MiniGameBaseVM