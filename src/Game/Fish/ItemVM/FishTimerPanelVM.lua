local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local BiteCountDownTimeConst = 40

---@class FishTimerPanelVM : UIViewModel
local FishTimerPanelVM = LuaClass(UIViewModel)

function FishTimerPanelVM:Ctor()
    self.IsThrowing = false
    self.IsBite = false
    -- ThrowTime绑定了钓鱼的倒计时面板，当ThrowTime等于0时会自动触发咬钩逻辑，小于0时会结束倒计时
    self.ThrowTime = -1
    self.ThrowTimePercent = 1
    self.IsStop = false
    self.PlayBiteAnim = false
    self.LastTime = 0
    self.IsInFish = false
end

function FishTimerPanelVM:OnFishDrop(BiteTime)
    self.IsThrowing = true
    self.IsBite = false
    self.ThrowTime = BiteTime
    self.ThrowTimePercent = 1
    self.IsStop = false
    self.IsInFish = true

end

function FishTimerPanelVM:OnFishBite()
    self.IsThrowing = false
    self.IsBite = true
    self.IsStop = true
    self.PlayBiteAnim = true
    self.IsInFish = true
end

function FishTimerPanelVM:OnFishLift()
    self.PlayBiteAnim = false
    self.IsInFish = false
end

function FishTimerPanelVM:OnFishEnd()
    -- 退出钓鱼状态时需要立即将ThrowTime设为负数停止倒计时
    self.ThrowTime = -1
    self.IsThrowing = true
    self.IsBite = false
    self.IsStop = true
    self.IsInFish = false
end

function FishTimerPanelVM:ClearVM()
    self.IsThrowing = false
    self.IsBite = false
    self.ThrowTimePercent = 1
    self.IsStop = false
end

function FishTimerPanelVM:IsFishing()
    return self.IsInFish
end

function FishTimerPanelVM:BiteTimeUpdateCallback(LeftTime)
    local IsStop = self.IsStop
    local Time = 0
    if IsStop then
        Time = self.LastTime
    else
        Time = LeftTime
    end
    local PercentTime = Time + BiteCountDownTimeConst - self.ThrowTime
    --咬钩时长超过BiteCountDownTimeConst时设为0
    if PercentTime < 0 then
        FLOG_INFO("[Fish]:FishTimerPanelVM:PercentTime < 0 , LeftTime = "..LeftTime.." ThrowTime = "..self.ThrowTime)
        PercentTime = 0
    end
    local Percent = 1 - PercentTime / BiteCountDownTimeConst
    self.ThrowTimePercent = Percent

    local ShowTime = self.ThrowTime - Time
    self.LastTime = Time

    return string.format("%.1f", ShowTime)
end

return FishTimerPanelVM