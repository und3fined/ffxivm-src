---
--- Author: Administrator
--- DateTime: 2023-10-07 20:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local GoldSauserMgr = require("Game/Gate/GoldSauserMgr")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local AudioUtil = require("Utils/AudioUtil")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PlayStyleCountDownTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBG UFImage
---@field TextCountDown UFTextBlock
---@field TextCountDown02 UFTextBlock
---@field AnimCountDownNormal UWidgetAnimation
---@field AnimCountDownWarning UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PlayStyleCountDownTipsView = LuaClass(UIView, true)

function PlayStyleCountDownTipsView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBG = nil
	--self.TextCountDown = nil
	--self.TextCountDown02 = nil
	--self.AnimCountDownNormal = nil
	--self.AnimCountDownWarning = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PlayStyleCountDownTipsView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PlayStyleCountDownTipsView:OnInit()
    self.Binders = {
        {"CountDownNum", UIBinderSetText.New(self, self.TextCountDown)},
        {"CountDownNum", UIBinderSetText.New(self, self.TextCountDown02)},
        {"bShowYellow", UIBinderSetIsVisible.New(self, self.TextCountDown)},
        {"bShowRed", UIBinderSetIsVisible.New(self, self.TextCountDown02)},
        {"ImgBGPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgBG)},
        {"bShowRed", UIBinderValueChangedCallback.New(self, nil, self.OnShowRedChanged)}
    }
end

function PlayStyleCountDownTipsView:OnDestroy()
end

function PlayStyleCountDownTipsView:OnShow()
    self.bVisible = true
    self.AudioHandle = nil
    UIUtil.SetIsVisible(self.ImgBG, true)
    local Params = self.Params               -------- 要不走传参 要不走绑定，二选一
    if Params ~= nil then                    --- {Time = xxx, ShowRedTime = xxx} 倒计时总秒数, 到多少秒时数字变红
        self:BeginCountDown(Params)
    end

end

function PlayStyleCountDownTipsView:OnShowRedChanged(NewValue, OldValue)
    if self.Params ~= nil then
        return
    end
    self:PlayAnimation(self.AnimCountDownWarning, 0, 0)
    self:StopAnimation(self.AnimCountDownNormal)
end

function PlayStyleCountDownTipsView:OnHide()
    if self.CountDownTimer ~= nil then
        self:UnRegisterTimer(self.CountDownTimer)
        self.CountDownTimer = nil
    end
    if self.AudioHandle ~= nil then
        AudioUtil.StopAsyncAudioHandle(self.AudioHandle)
        self.AudioHandle = nil
    end
    
    self:PlayAnimation(self.AnimCountDownNormal, 0, 0)
    self.Params = nil
end

function PlayStyleCountDownTipsView:OnRegisterUIEvent()
end

function PlayStyleCountDownTipsView:OnRegisterGameEvent()
end

function PlayStyleCountDownTipsView:OnRegisterBinder()
    self:RegisterBinders(GoldSauserMgr.GoldSauserVM, self.Binders)
end

--- @type 不走绑定直接传参
function PlayStyleCountDownTipsView:BeginCountDown(Params)
    local ReaminTime = Params.Time
    if ReaminTime == nil then
        return
    end
    local ShowRedTime = Params.ShowRedTime
    if not ShowRedTime then
        return
    end

    if (self.CountDownTimer ~= nil) then
        self:UnRegisterTimer(self.CountDownTimer)
        self.CountDownTimer = nil
    end

    local Interval = 0.2
    local BgImgPath = GoldSauserDefine.BgImgPath
	local LastShowTime = -1
    local function CountDownFunc()
        if not self.bVisible then
            return
        end
        local ShowTime = math.floor(ReaminTime)
		if (LastShowTime == -1) then
			LastShowTime = ShowTime
		end
		
        local bShowYellowTip, BgPath
        if ReaminTime > ShowRedTime then
            bShowYellowTip = true
            BgPath = BgImgPath.YellowBg
        else
            bShowYellowTip = false
            BgPath = BgImgPath.RedBg
        end
        UIUtil.SetIsVisible(self.TextCountDown, bShowYellowTip)
        UIUtil.SetIsVisible(self.TextCountDown02, not bShowYellowTip)
        self.TextCountDown:SetText(ShowTime)
        self.TextCountDown02:SetText(ShowTime)
        UIUtil.ImageSetBrushFromAssetPath(self.ImgBG, BgPath)
		if (LastShowTime ~= ShowTime) then
			LastShowTime = ShowTime
            if ReaminTime > ShowRedTime then
                self:PlayAnimation(self.AnimCountDownNormal)
                self:StopAnimation(self.AnimCountDownWarning)
            else
                self:PlayAnimation(self.AnimCountDownWarning)
            end
            if Params.bJumboLottory and not self.AudioHandle then -- 仙彩开奖倒计时加音效
                self.AudioHandle = AudioUtil.LoadAndPlayUISound(JumboCactpotDefine.JumboCeremoneyAudioAssetPath.CountDown)
            end
		end
        ReaminTime = ReaminTime - Interval
        if ReaminTime <= 0.5 and self.CountDownTimer ~= nil then
            self:UnRegisterTimer(self.CountDownTimer)
            self.CountDownTimer = nil

            AudioUtil.StopAsyncAudioHandle(self.AudioHandle)
            self.AudioHandle = nil
            self:Hide()
        end
    end
    self:StopAnimation(self.AnimCountDownWarning)
    self.CountDownTimer = self:RegisterTimer(CountDownFunc, 0, Interval, 0)
end

-- function PlayStyleCountDownTipsView:ChangVisible(bVisible)
--     self.bVisible = bVisible
--     UIUtil.SetIsVisible(self.ImgBG, bVisible)
--     UIUtil.SetIsVisible(self.TextCountDown, false)
--     UIUtil.SetIsVisible(self.TextCountDown02, false)
-- end


return PlayStyleCountDownTipsView
