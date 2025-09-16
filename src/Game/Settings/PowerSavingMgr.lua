-- 省电模式

local MgrBase = require("Common/MgrBase")
local LuaClass = require("Core/LuaClass")

local EventID = _G.EventID
local USettingUtil = _G.UE.USettingUtil
local UFGamePlatformMisc = _G.UE.UFGamePlatformMisc
local UKismetSystemLibrary = _G.UE.UKismetSystemLibrary

local Priority = 0x01000000
local PriorityConsole = 0x09000000

--进入省电模式后的参数设置
local PowerSavingState_MaxFPS = 15              --帧率调
local PowerSavingState_ScreenPercentage = 10    --场景分辨率
local PowerSavingState_Brightness = 0.05         --屏幕亮度

local PowerSavingMgr = LuaClass(MgrBase)

function PowerSavingMgr:OnInit()
    self.LastInputTime = 0  --秒

    self.IsEnablePowerSaving = false
    self.EnterPowerSavingTime = 0   -- 0 表示关闭，不会开启省电模式
    self.IsPowerSaving = false

    self.IsPreMouseDown = false
end

--RoleLife进入的时候，SettingsMgr会触发PowerSavingMgr:SetEnable，决定要不要允许省电模式逻辑的触发
--设置修改的时候，也会触发PowerSavingMgr:SetEnable
function PowerSavingMgr:OnBegin()
    FLOG_INFO("PowerSavingMgr:OnBegin")
    self.IsPreMouseDown = false
end

--RoleLife结束，退到选角/登录的时候，是不需要进入省电模式的
function PowerSavingMgr:OnEnd()
    FLOG_INFO("PowerSavingMgr:OnEnd")
    self.IsPreMouseDown = false
    self:SetEnable(0)
end

function PowerSavingMgr:OnShutdown()
end

function PowerSavingMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
end

--设置变了，也要通知到这里，等待时间要同步遍
--模拟器 会调用过来，但强制被禁止
function PowerSavingMgr:SetEnable(EnterTime)
    local IsWithEmulatorMode = _G.SettingsMgr.IsWithEmulatorMode
    if IsWithEmulatorMode then
        self.IsEnablePowerSaving = false
        return
    end

    self.EnterPowerSavingTime = EnterTime
    -- self.EnterPowerSavingTime = 20
    if EnterTime > 0 then
        self.IsEnablePowerSaving = true
        self.IsPowerSaving = false
        self.LastInputTime = _G.TimeUtil.GetServerTime()
        self:RegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
        self:RegisterGameEvent(EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)
        self:RegisterGameEvent(EventID.EndPlaySequence, self.OnEndPlaySequence)
        -- self:RegisterGameEvent(EventID.PreprocessedMouseMove, self.OnPreprocessedMouseMove)
        self:RegisterGameEvent(EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
        
        self:StartTimer()
    else
        if self.IsEnablePowerSaving and self.IsPowerSaving then
            self:ExitPowerSavingState()
        end

        self.IsEnablePowerSaving = false
        self.IsPowerSaving = false
        self.LastInputTime = 0
        self:UnRegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
        self:UnRegisterGameEvent(EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)
        self:UnRegisterGameEvent(EventID.EndPlaySequence, self.OnEndPlaySequence)
        -- self:UnRegisterGameEvent(EventID.PreprocessedMouseMove, self.OnPreprocessedMouseMove)
        self:RegisterGameEvent(EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)

        self:CloseTimer()
    end

    FLOG_INFO("PowerSaving SetEnable EnterTime:%d LastInputTime:%d", EnterTime, self.LastInputTime)
end

function PowerSavingMgr:StartTimer()
    if not self.TickTimerHandler then
        self.TickTimerHandler = self:RegisterTimer(self.PowerSavingTick, 0, 1, 0)
    end
end

function PowerSavingMgr:CloseTimer()
    if self.TickTimerHandler then
        _G.TimerMgr:CancelTimer(self.TickTimerHandler)
		self.TickTimerHandler = nil
    end
end

--模拟器不会触发tick，不会有Enable
--
function PowerSavingMgr:PowerSavingTick()
    local CurTime = _G.TimeUtil.GetServerTime()
    if CurTime - self.LastInputTime > self.EnterPowerSavingTime then
        if self.IsPreMouseDown then
            self.LastInputTime = CurTime
            FLOG_INFO("PowerSavingMgr IsPreMouseDown = true")
        elseif _G.StoryMgr:SequenceIsPlaying() then
            self.LastInputTime = CurTime
            FLOG_INFO("PowerSavingMgr SequenceIsPlaying")
        elseif _G.AutoPathMoveMgr:IsAutoPathMovingState() then
            self.LastInputTime = CurTime
            FLOG_INFO("PowerSavingMgr autopathing")
        else
            --进入省电模式
            self:EnterPowerSavingState()
        end
    else
    end
end

function PowerSavingMgr:EnterPowerSavingState()
    FLOG_INFO("PowerSavingMgr:EnterPowerSavingState")
    _G.UIViewMgr:ShowView(_G.UIViewID.PowerSavingMode)
    self.IsPowerSaving = true

    self.LastScreenPercentage = UKismetSystemLibrary.GetConsoleVariableIntValue("r.ScreenPercentage")
    self.LastMaxFps = UKismetSystemLibrary.GetConsoleVariableIntValue("t.maxfps")
    self.LastBrightness = UFGamePlatformMisc.GetBrightness()
    FLOG_INFO("PowerSavingMgr Cur ScreenPercentage:%d maxfps:%d Brightness:%.2f"
        , self.LastScreenPercentage, self.LastMaxFps, self.LastBrightness)

    --分辨率
    USettingUtil.ExeCommand("r.ScreenPercentage", PowerSavingState_ScreenPercentage, PriorityConsole)
    --帧率
    USettingUtil.ExeCommand("t.maxfps", PowerSavingState_MaxFPS, Priority)
    --屏幕亮度
    if self.LastBrightness > PowerSavingState_Brightness then
        FLOG_INFO("PowerSavingMgr SetBrightness:%.2f", PowerSavingState_Brightness)
        UFGamePlatformMisc.SetBrightness(PowerSavingState_Brightness)
    elseif self.LastBrightness < 0 then
        FLOG_INFO("PowerSavingMgr SetBrightness:%.2f", PowerSavingState_Brightness)
        UFGamePlatformMisc.SetBrightness(PowerSavingState_Brightness)
    end
    
    FLOG_INFO("PowerSavingMgr To ScreenPercentage:%d maxfps:%d CurBrightness:%.2f - CmpValue:%.2f"
        , PowerSavingState_ScreenPercentage, PowerSavingState_MaxFPS
        , UFGamePlatformMisc.GetBrightness(), PowerSavingState_Brightness)

    self:CloseTimer()
end

function PowerSavingMgr:ExitPowerSavingState(bUIHide)
    FLOG_INFO("PowerSavingMgr:ExitPowerSavingState")
    if self.IsEnablePowerSaving and self.EnterPowerSavingTime > 0 then
        self:StartTimer()
    end

    if not bUIHide then
        FLOG_INFO("PowerSavingMgr bUIHide = true")
        self.IsPowerSaving = false
    end

    self.LastInputTime = _G.TimeUtil.GetServerTime()

    --分辨率
    if self.LastScreenPercentage ~= 75 and self.LastScreenPercentage ~= 100 then
        self.LastScreenPercentage = 75
    end
    USettingUtil.ExeCommand("r.ScreenPercentage", self.LastScreenPercentage, PriorityConsole)

    --帧率
    if self.LastMaxFps < 15 or self.LastMaxFps > 60 then
        self.LastMaxFps = 30
    end
    USettingUtil.ExeCommand("t.maxfps", self.LastMaxFps, Priority)
    
    --屏幕亮度
    local CurBrightness = UFGamePlatformMisc.GetBrightness()
    FLOG_INFO("PowerSavingMgr LastBrightness:%.2f CurBrightness:%.2f", self.LastBrightness, CurBrightness)
    if self.LastBrightness > CurBrightness then
        UFGamePlatformMisc.SetBrightness(self.LastBrightness)
    elseif self.LastBrightness < 0 then
        UFGamePlatformMisc.SetBrightness(self.LastBrightness)
    end

    FLOG_INFO("PowerSavingMgr Recover ScreenPercentage:%d maxfps:%d Brightness:%.2f CurBrightness:%.2f"
        , self.LastScreenPercentage, self.LastMaxFps, self.LastBrightness, UFGamePlatformMisc.GetBrightness())
end

---------------------------------------------------------------------------------------------
---
function PowerSavingMgr:OnPreprocessedMouseButtonDown(MouseEvent)
    -- FLOG_INFO("PowerSavingMgr:OnPreprocessedMouseButtonDown")   --todel
    self.LastInputTime = _G.TimeUtil.GetServerTime()

    self.IsPreMouseDown = true
end

function PowerSavingMgr:OnPreprocessedMouseButtonUp(MouseEvent)
    -- FLOG_INFO("PowerSavingMgr:OnPreprocessedMouseButtonUp")   --todel
    self.LastInputTime = _G.TimeUtil.GetServerTime()

    self.IsPreMouseDown = false
end

function PowerSavingMgr:OnEndPlaySequence()
    FLOG_INFO("PowerSavingMgr:OnEndPlaySequence")
    self.LastInputTime = _G.TimeUtil.GetServerTime()
    self.IsPreMouseDown = false
end

-- function PowerSavingMgr:OnPreprocessedMouseMove(InTouchEvent)
--     FLOG_INFO("PowerSavingMgr:OnPreprocessedMouseMove")
--     self.LastInputTime = _G.TimeUtil.GetServerTime()
-- end

function PowerSavingMgr:OnGameEventAppEnterForeground()
    FLOG_INFO("PowerSavingMgr:OnGameEventAppEnterForeground")
    self.LastInputTime = _G.TimeUtil.GetServerTime()
    self.IsPreMouseDown = false
end

function PowerSavingMgr:OnGameEventLoginRes(Param)
    local bReconnect = Param and Param.bReconnect
    if bReconnect and self.IsPowerSaving then
        FLOG_INFO("PowerSavingMgr bReconnect = true")
        if not _G.UIViewMgr:IsViewVisible(_G.UIViewID.PowerSavingMode) then
            self:EnterPowerSavingState()
        end
    end
end

return PowerSavingMgr