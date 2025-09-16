---
--- Author: Administrator
--- DateTime: 2023-09-13 14:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
local EventID = require("Define/EventID")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")
local EmotionCfg = require("TableCfg/EmotionCfg")
local CommonUtil = require("Utils/CommonUtil")

local ShowTime = 4.0 -- 显示时间

---@class FateEmoTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBanner UFImage
---@field ImgBar UFImage
---@field ImgEmoj UFImage
---@field ImgPic UFImage
---@field RichTextMeet URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateEmoTipsItemView = LuaClass(UIView, true)

function FateEmoTipsItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgBanner = nil
    --self.ImgBar = nil
    --self.ImgEmoj = nil
    --self.ImgPic = nil
    --self.RichTextMeet = nil
    --self.AnimIn = nil
    --self.AnimOut = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateEmoTipsItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateEmoTipsItemView:OnInit()
    self.Interval = 0.02 --调整频率
    self.ScreenLocation = _G.UE.FVector2D()
    self.DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self) --获取视口大小
    self.DPIScale = (self.DPIScale == 0) and 1 or self.DPIScale
end

---注册计时器
function FateEmoTipsItemView:OnRegisterTimer()
end

---计时器(实时调整Tips的位置)
function FateEmoTipsItemView:OnTimer()
    self.PlayTime = self.PlayTime + self.Interval
    if (self.PlayTime <= ShowTime) then
        if (not self:UpdatePos(self.Data.EntityID)) then
            self:InternalProcessHide()        
        end
        return
    end

    self:InternalProcessHide()
end

function FateEmoTipsItemView:InternalProcessHide()
    if (self.TimerID ~=nil) then
        self:UnRegisterTimer(self.TimerID)
    end
    self.TimerID = nil
    self.ScreenLocation = _G.UE.FVector2D(0)
    self.bActive = false
    self.PlayTime = 0
    if (self.FinishCallback ~= nil and self.FinishCallbackView ~= nil) then
        self.FinishCallback(self.FinishCallbackView, self.Data.EntityID, self)
    end
end

function FateEmoTipsItemView:ResetData()
    self.Data = nil
    self.ScreenLocation = _G.UE.FVector2D(0)
    self.PlayTime = 0
    self.FinishCallbackView = nil
    self.FinishCallback = nil
end

function FateEmoTipsItemView:UpdateInfo(InParams, InFinishCallbackView, InFinishCallback)
    self:ResetData()
    self.Data = InParams
    self.bActive = true
    self.PlayTime = 0 --当前显示了多久
    self.TimerID = self:RegisterTimer(self.OnTimer, 0.1, self.Interval, -1)
    self:UpdatePos(self.Data.EntityID)
    self:SetIcon(self.Data.EmotionID)
    if self.RichTextMeet ~= nil then
        self.RichTextMeet:SetText(self.Data.TipsDesc)
    end

    self.FinishCallbackView = InFinishCallbackView
    self.FinishCallback = InFinishCallback
end

function FateEmoTipsItemView:SetText(InEmotionID, InEntityID)
    self:NoTargetTips()
end

--- 无选中目标
function FateEmoTipsItemView:NoTargetTips()
    local MyName = ActorUtil.GetActorName(self.Data.EntityID)
    local EmotionDesc = self.Data.TipsText
    EmotionDesc = self:MatchStringPatern(EmotionDesc)
    if string.isnilorempty(EmotionDesc) then
        UIUtil.SetIsVisible(self, false)
        return
    end

    local TipsDesc = string.format('<span color="#%s">%s</>', "FFFFFF", EmotionDesc) --头顶气泡字体的颜色
    local ChatDesc = string.format('<span color="%s">%s</>', "#c6c6c6", EmotionDesc)
     --附近聊天字体颜色
    MyName = string.format('<span color="#%s">%s</>', "7ecef4", MyName) --修改自己名字的颜色
    if self.RichTextMeet ~= nil then
        self.RichTextMeet:SetText(TipsDesc) ---将文本信息显示在人物头顶
    end
    if nil ~= self.ChatTimeID then
        _G.TimerMgr:CancelTimer(self.ChatTimeID)
        self.ChatTimeID = nil
    end
end

--- 设置显示的情感动作图标
function FateEmoTipsItemView:SetIcon(EmotionID)
    local Emotion = EmotionCfg:FindCfgByKey(EmotionID)
    if self.ImgEmoj and not string.isnilorempty(Emotion.IconPath) then
        UIUtil.ImageSetBrushFromAssetPath(self.ImgEmoj, EmotionUtils.GetEmoActIconPath(Emotion.IconPath))
    end
end

---将UI显示在人物头顶
function FateEmoTipsItemView:UpdatePos(InEntityID)
    if InEntityID == nil then
        return false
    end
    local FromActor = ActorUtil.GetActorByEntityID(InEntityID)
    if FromActor == nil then
        _G.FLOG_ERROR("无法获取Npc， EntityID : %s", InEntityID)
        return false
    end

    local HeadLocation =  FromActor:Cast(_G.UE.ABaseCharacter):GetSocketLocationByName("head_M")

    --将UI固定在名字上方
    UIUtil.ProjectWorldLocationToScreen(HeadLocation, self.ScreenLocation)
    local BubbleSize = self:GetDesiredSize()
    self.ScreenLocation = self.ScreenLocation / self.DPIScale
    local CorrectScreeLocation = _G.UE.FVector2D(
        self.ScreenLocation.X - BubbleSize.X * 0.22,
        self.ScreenLocation.Y - BubbleSize.Y
    )
    self.Slot:SetPosition(CorrectScreeLocation)

    return true
end

function FateEmoTipsItemView:OnGameEventPostEmotionEnd(InParams)
end

function FateEmoTipsItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PostEmotionEnd, self.OnGameEventPostEmotionEnd)
end

--- 获取主角与屏幕的距离、视角 (这里没有找到弹簧臂)
function FateEmoTipsItemView:GetDistance(CharacterID)
    local FromActor = ActorUtil.GetActorByEntityID(CharacterID)
    FromActor = FromActor:Cast(_G.UE.ABaseCharacter)
    if FromActor ~= nil then
        local WorldPosition = _G.UE.FVector()
        local WorldDirection = _G.UE.FVector()
        local RotationAt = _G.UE.FVector()
        local DistanceLocation

        UIUtil.DeprojectScreenToWorld(self.ScreenLocation, WorldPosition, WorldDirection)
        DistanceLocation = _G.UE.UKismetMathLibrary.Vector_Distance(WorldPosition, FromActor:K2_GetActorLocation())
        RotationAt = _G.UE.UKismetMathLibrary.FindLookAtRotation(WorldPosition, FromActor:K2_GetActorLocation())

        return DistanceLocation, math.abs(RotationAt.Pitch)
    end
    return 0, 0
end

return FateEmoTipsItemView
