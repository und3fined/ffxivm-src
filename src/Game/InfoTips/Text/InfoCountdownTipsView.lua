---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-08-27 09:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local AudioUtil = require("Utils/AudioUtil")

local RedTime = 10 --变红的时间
local DefaultTimeInterval = 1
local DefaultBeginTime = 15
local DefaultEndTime = 1 -- 默认结束是1，因为还有一个播放开始的时间，3,2,1 开始，就不显示0了
local DefaultRedTime = 10
local DefaultStartTitleText = nil -- 初始化的时候去赋值，目前默认使用的是 "开始"

---@class InfoCountdownTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCountdown UFImage
---@field ImgCountdownMask UFImage
---@field Panel UFCanvasPanel
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoCountdownTipsView = LuaClass(UIView, true)

function InfoCountdownTipsView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgCountdown = nil
    --self.ImgCountdownMask = nil
    --self.Panel = nil
    --self.TextSubTitle = nil
    --self.TextTitle = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

    DefaultStartTitleText = LSTR(1270011)
end

function InfoCountdownTipsView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoCountdownTipsView:OnInit()
    self.Binders = {
        {"CountDownNum", UIBinderSetText.New(self, self.TextTitle)},
        {"SubTitleText", UIBinderSetText.New(self, self.TextSubTitle)},
        {"PanelVisible", UIBinderSetIsVisible.New(self, self.Panel)},
        -- {"bShowYellow", UIBinderSetIsVisible.New(self, self.TextCountDown)},
        -- {"bShowRed", UIBinderSetIsVisible.New(self, self.TextCountDown02)}
    }
    self:ResetData()
end

function InfoCountdownTipsView:OnDestroy()
end

function InfoCountdownTipsView:OnShow()
    local Params = self.Params -- 可以为空，走自动计时
    self:BeginCountDown(Params)
end

function InfoCountdownTipsView:ResetData()
    self:CancelTimer()
    self.HaveShowRed = false
    self.TimeInterval = DefaultTimeInterval -- 时间间隔
    self.CurTime = DefaultBeginTime -- 倒计时开始当前时间
    self.EndTime = DefaultEndTime -- 倒计时结束时间
    self.FinishCallback = nil -- 完结时候的回调，当 EndShowType == 0的时候，会再播放AnimStart的时候调用，==1的时候，到达EndTime就调用
    self.RedTimeCallback = nil -- 警告时间到达时候的回调
    self.RedTime = 0 -- 警告变色的时间
    self.RedTimePlaySound = nil -- 红色后的警告声响，后续会每一秒播放一次
    self.CountDownLoopSound = nil
    -- 这里偷个懒，就没去proto面写枚举了
    -- 0 表示默认，在到达 EndTime 的时候，会再等待1秒，播放一个开始动画，其中倒计时会变成文字
    -- 1 表示到达 EndTime 的时候，直接隐藏，会自己调用AnimOut
    self.EndShowType = 0
    self.bReachEndTime = false -- 是否到达完结的时间，如果 EndShowType 是 0，那么会再等待1秒，播放开始动画
    self.bPlayShowStartAnim = false -- 是否播放倒计时结束了以后的开始动画，默认等待 1 秒，再隐藏
    self.PlayStartAnimWaitTime = 1
    self:StopLoopCountAudio()
    self:StopRedTimeAudio()
end

function InfoCountdownTipsView:StopLoopCountAudio()
    if self.LoopAudioHandle ~= nil then
        AudioUtil.StopAsyncAudioHandle(self.LoopAudioHandle)
        self.LoopAudioHandle = nil
    end
end

function InfoCountdownTipsView:StopRedTimeAudio()
    if (self.RedTimePlaySoundID ~= nil) then
        AudioUtil.StopAsyncAudioHandle(self.RedTimePlaySoundID)
        self.RedTimePlaySoundID = nil
    end
end

function InfoCountdownTipsView:OnHide()
    self:ResetData()
end

function InfoCountdownTipsView:OnRegisterUIEvent()
end

function InfoCountdownTipsView:OnRegisterGameEvent()
end

function InfoCountdownTipsView:OnRegisterBinder()
    local Params = self.Params
    if Params ~= nil then
        self.BindVM = Params.BindVM

        if (self.BindVM ~= nil) then
            self:RegisterBinders(self.BindVM, self.Binders)
        end
    end
end

function InfoCountdownTipsView:SetTitleText(InTitleText)
    if (self.TextTitle ~= nil) then
        self.TextTitle:SetText(InTitleText)
    end
end

function InfoCountdownTipsView:SetSubTitleText(InSubTitleText)
    if (self.TextSubTitle ~= nil) then
        self.TextSubTitle:SetText(InSubTitleText)
    end
end

function InfoCountdownTipsView:InternalCountdown()
    -- 这里是播放开始动画后，等待一秒再隐藏自己
    if (self.bPlayShowStartAnim) then
        self.PlayStartAnimWaitTime = self.PlayStartAnimWaitTime - self.TimeInterval
        if (self.PlayStartAnimWaitTime <= 0) then
            self:CancelTimer()
            self:Hide()
        end
        return
    end

    self.CurTime = self.CurTime - self.TimeInterval
 
    if (self.CurTime < 0) then
        self.CurTime = 0
    end

    local FinalShowTime = math.floor(self.CurTime)

    -- 这里是到达的倒计时之后，播放一个“开始”动画
    if (self.bReachEndTime) then
        self.TextTitle:SetText(self.StartTitleText)
        self:PlayAnimation(self.AnimStart)
        self.bPlayShowStartAnim = true
        if (self.FinishCallback ~= nil) then
            self.FinishCallback()
            self.FinishCallback = nil
        end
        self:StopLoopCountAudio()
        return
    end

    self.TextTitle:SetText(FinalShowTime)

    if (FinalShowTime <= self.RedTime and self.RedTime > 0 and not self.HaveShowRed) then
        -- 这里显示警告表现
        self.HaveShowRed = true
        if (self.RedTimeCallback ~= nil) then
            self.RedTimeCallback()
            self.RedTimeCallback = nil
        end
    end

    if (self.LastShowTime ~= FinalShowTime) then
        self.LastShowTime = FinalShowTime
        -- 播放跳动
        self:PlayAnimation(self.AnimTimeChange)

        --- self.LoopAudioHandle为仙彩音效需求
        if self.CountDownLoopSound ~= nil and self.LoopAudioHandle == nil then
            self.LoopAudioHandle = AudioUtil.LoadAndPlay2DSound(self.CountDownLoopSound)
        end

        if (self.HaveShowRed and self.RedTimePlaySound ~= nil) then
            self.RedTimePlaySoundID = AudioUtil.LoadAndPlay2DSound(self.RedTimePlaySound)
        end
    end

    if (FinalShowTime <= self.EndTime) then
        if (self.EndShowType == 0) then
            self.bReachEndTime = true -- 再过一秒，播放开始动画
            self.LastShowTime = FinalShowTime
        else
            if (self.FinishCallback ~= nil) then
                self.FinishCallback()
                self.FinishCallback = nil
            end

            self:CancelTimer()
            self:Hide()
        end
    end
end

function InfoCountdownTipsView:CancelTimer()
    if (self.CountDownTimer ~= nil) then
        self:UnRegisterTimer(self.CountDownTimer)
        self.CountDownTimer = nil
    end
end

---InfoCountdownTipsView.BeginCountDown Description of the function
---@param Params Type Description
--- Params.TimeInterval or 1 -- 检查间隔，不填写默认1
--- Params.SubTitleText -- 副标题
--- Params.BeginTime -- 默认15 秒
--- Params.EndTime -- 默认0秒
--- Params.FinishCallback
--- Params.RedTime or 10 -- 倒计时变红的警告时间，默认10秒变红
function InfoCountdownTipsView:BeginCountDown(Params)
    self:ResetData()

    if (Params == nil) then
        if (self.TextSubTitle ~= nil) then
            self.TextSubTitle:SetText("")
        end

        self.TimeInterval = DefaultTimeInterval
        self.CurTime = DefaultBeginTime
        self.EndTime = DefaultEndTime
        self.FinishCallback = nil
        self.RedTime = DefaultRedTime
        self.TextTitle:SetText(self.CurTime)
        self.CountDownTimer = self:RegisterTimer(self.InternalCountdown, self.TimeInterval, self.TimeInterval, 0)
    else
        local AutoCountdown = Params.BindVM == nil -- 如果绑定了VM，那么认为不会自动倒计时，由外部全权接管

        local SubTitleText = Params.SubTitleText or ""
        if (self.TextSubTitle ~= nil) then
            self.TextSubTitle:SetText(SubTitleText)
        end

        if (AutoCountdown) then
            self.TimeInterval = Params.TimeInterval or DefaultTimeInterval
            self.CurTime = Params.BeginTime or DefaultBeginTime -- 外部指定秒 or 15
            self.EndTime = Params.EndTime or DefaultEndTime -- 外部指定秒 or 1
            self.FinishCallback = Params.FinishCallback
            self.RedTimeCallback = Params.RedTimeCallback
            self.RedTime = Params.RedTime or 0 -- 警告变色的时间
            self.TextTitle:SetText(self.CurTime)
            local TimeDelay = Params.TimeDelay or self.TimeInterval
            self.CountDownTimer = self:RegisterTimer(self.InternalCountdown, TimeDelay, self.TimeInterval, 0)
            self.RedTimePlaySound = Params.RedTimePlaySound
            self.CountDownLoopSound = Params.CountDownLoopSound
            self.StartTitleText = Params.StartTitleText or DefaultStartTitleText
            self.PlayStartAnimWaitTime = Params.PlayStartAnimWaitTime or 1
        end
    end
end

return InfoCountdownTipsView
