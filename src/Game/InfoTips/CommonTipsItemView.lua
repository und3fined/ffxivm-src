--
-- Author: anypkvcai
-- Date: 2020-12-08 15:37:35
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local AudioUtil = require("Utils/AudioUtil")
local TimeUtil = require("Utils/TimeUtil")

local AnimationCallbackTime = 3000
local PlayOffsetTime = 1000

---@class CommonTipsItemView : UIView
local CommonTipsItemView = LuaClass(UIView, true)

function CommonTipsItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.RichTextContent = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonTipsItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonTipsItemView:OnInit()
    self.AnimationCallbackTime = AnimationCallbackTime
    self.CanPlayOffset = true
    self.HasPlayOffset = false
end

function CommonTipsItemView:OnDestroy()
end

function CommonTipsItemView:OnShow()
    if nil == self.Params then
        return
    end
    self.CanPlayOffset = true
    local SoundName = self.Params.SoundName
    if nil ~= SoundName and string.len(SoundName) > 0 then
        AudioUtil.LoadAndPlay2DSound(SoundName) -- 系统通知声音一般不常用, 使用LRU策略
    end

    if nil ~= self.RichTextContent then
        self.RichTextContent:SetText(self.Params.Content)
    end

    self.BeginTime = TimeUtil.GetLocalTimeMS()
    self.AniCallback = self.Params.AniCallback
    self.AnimationCallbackTime = self.Params.ShowTime or AnimationCallbackTime
end

function CommonTipsItemView:OnHide()
    self.CanPlayOffset = true
    self.HasPlayOffset = false
end

function CommonTipsItemView:OnRegisterUIEvent()
end

function CommonTipsItemView:OnRegisterGameEvent()
end

function CommonTipsItemView:OnRegisterTimer()
    self:RegisterTimer(self.OnTimer, 0, 0.1, 0)
end

function CommonTipsItemView:OnRegisterBinder()
end

function CommonTipsItemView:OnTimer()
    local CurTimeStamp = TimeUtil.GetLocalTimeMS()

    if (self.HasPlayOffset) then
        if CurTimeStamp - self.BeginTime >= PlayOffsetTime then
            if nil ~= self.AniCallback then
                self.AniCallback(self)
                self.AniCallback = nil
            end
        end
    else
        if CurTimeStamp - self.BeginTime >= self.AnimationCallbackTime then
            if nil ~= self.AniCallback then
                self.CanPlayOffset = false
                self.AniCallback(self)
                self.AniCallback = nil
            end
        end
    end
end

function CommonTipsItemView:PlayOffsetAnimation()
    if (not self.CanPlayOffset) then
        return
    end
    if nil ~= self.AniOffset then
        self.BeginTime = TimeUtil.GetLocalTimeMS()
        self:PlayAnimation(self.AniOffset)
        self.HasPlayOffset = true
    end
end

return CommonTipsItemView
