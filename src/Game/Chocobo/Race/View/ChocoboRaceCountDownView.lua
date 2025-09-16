---
--- Author: Administrator
--- DateTime: 2023-11-03 15:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local ChocoboRaceUtil = require("Game/Chocobo/Race/ChocoboRaceUtil")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local AudioUtil = require("Utils/AudioUtil")

---@class ChocoboRaceCountDownView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSkip UFButton
---@field ImgArrived UFImage
---@field ImgCountDown1 UFImage
---@field ImgCountDown2 UFImage
---@field ImgCountDown3 UFImage
---@field ImgStart UFImage
---@field PanelCountDown UFCanvasPanel
---@field PanelNoWait UFCanvasPanel
---@field TextSkip UFTextBlock
---@field AnimArrived UWidgetAnimation
---@field AnimCountdown UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboRaceCountDownView = LuaClass(UIView, true)

function ChocoboRaceCountDownView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSkip = nil
	--self.ImgArrived = nil
	--self.ImgCountDown1 = nil
	--self.ImgCountDown2 = nil
	--self.ImgCountDown3 = nil
	--self.ImgStart = nil
	--self.PanelCountDown = nil
	--self.PanelNoWait = nil
	--self.TextSkip = nil
	--self.AnimArrived = nil
	--self.AnimCountdown = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboRaceCountDownView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboRaceCountDownView:OnInit()

end

function ChocoboRaceCountDownView:OnDestroy()

end

function ChocoboRaceCountDownView:OnShow()
    -- LSTR string: 跳过等待 >>
    self.TextSkip:SetText(_G.LSTR(430001))

    if not self.Params then
        return
    end

    UIUtil.SetIsVisible(self.PanelNoWait, false)
    if self.Params.Mode == "COUNTDOWN" then
        self:HandleCountDownMode(self.Params.EndTime)

        --if ChocoboDefine.DEBUG_RACE then
        --    self:RegisterTimer(function()
        --        local Timer = TimeUtil.GetServerTime() - self.Params.EndTime
        --        ChocoboRaceUtil.Log("ChocoboRaceCountDownView Ani LeftTime :" .. Timer)
        --    end,0,0.05,0)
        --end
    elseif self.Params.Mode == "ARRIVED" then
        self:HandleArrivedMode()
    end
end

function ChocoboRaceCountDownView:OnRegisterUIEvent()
    
end

function ChocoboRaceCountDownView:OnRegisterGameEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnSkip, self.OnClickBtnSkip)
end

function ChocoboRaceCountDownView:OnRegisterBinder()

end

function ChocoboRaceCountDownView:PlayAnimCountDown(LeftTime)
    if LeftTime == nil or LeftTime < 0 then
        return
    end
    
    local StartTime = _G.ChocoboRaceMgr.LevelSequenceAniLength - LeftTime
    if StartTime < 0 then
        StartTime = 0
    end
    
    self:PlayAnimation(self.AnimCountdown, StartTime)
end

function ChocoboRaceCountDownView:PlayAnimArrived()
    self:PlayAnimation(self.AnimArrived)
end

function ChocoboRaceCountDownView:OnClickBtnSkip()
    _G.ChocoboRaceMgr:SetGameState(ChocoboDefine.GAME_STATE_ENUM.RESULT)
    self:Hide()
end

function ChocoboRaceCountDownView:HandleCountDownMode(EndTime)
    if type(EndTime) ~= "number" then
        return
    end

    local CurrentTimeMs = TimeUtil.GetServerTimeMS()
    local EndTimeMs = EndTime * 1000
    local RemainingMs = EndTimeMs - CurrentTimeMs

    local AnimLengthMs = self.AnimCountdown:GetEndTime() * 1000  -- 动画总时长
    local CriticalPointMs = 3000  -- 动画第3秒对应结束时刻
    local MinPlayDuration = 500   -- 最小播放时长

    if RemainingMs < MinPlayDuration then
        return
    end

    local StartTimeMs = 0
    if RemainingMs > CriticalPointMs then
        -- 当剩余时间超过关键点时，等待到合适时机
        local DelayTime = (RemainingMs - CriticalPointMs) / 1000
        self:RegisterTimer(function()
            self:PlayAnimation(self.AnimCountdown)
            local AutioPath = "AkAudioEvent'/Game/WwiseAudio/Events/sound/battle/etc/SE_Bt_Etc_GS_Ride_Countdown/Play_SE_Bt_Etc_GS_Ride_Countdown.Play_SE_Bt_Etc_GS_Ride_Countdown'"
            AudioUtil.LoadAndPlayUISound(AutioPath)
        end, DelayTime)
        return
    else
        -- 计算动画起始点：确保动画播放到CriticalPointMs时刚好结束
        StartTimeMs = AnimLengthMs - RemainingMs
        StartTimeMs = math.clamp(StartTimeMs, 0, AnimLengthMs - MinPlayDuration)
    end

    -- 播放动画
    self:PlayAnimation(self.AnimCountdown, StartTimeMs / 1000)
end

function ChocoboRaceCountDownView:HandleArrivedMode()
    self:PlayAnimation(self.AnimArrived)
end

function ChocoboRaceCountDownView:OnAnimationFinished(Animation)
    if Animation == self.AnimCountdown then
        self:Hide()
    elseif Animation == self.AnimArrived then
        UIUtil.SetIsVisible(self.PanelNoWait, true)
    end
end

return ChocoboRaceCountDownView