---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-03-26 10:38
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
local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")

local DefaultTimeInterval = 1
local DefaultBeginTime = 10
local DefaultEndTime = 1 -- 默认结束是1，因为还有一个播放开始的时间，3,2,1 开始，就不显示0了
local DefaultRedTime = 3

---@class InfoCountdownTipsForPVPView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNum UFImage
---@field Panel UFCanvasPanel
---@field PanelText UFCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimStart UWidgetAnimation
---@field AnimTimeChange UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoCountdownTipsForPVPView = LuaClass(UIView, true)

function InfoCountdownTipsForPVPView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNum = nil
	--self.Panel = nil
	--self.PanelText = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut = nil
	--self.AnimStart = nil
	--self.AnimTimeChange = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

    DefaultStartTitleText = LSTR(1270011)
end

function InfoCountdownTipsForPVPView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoCountdownTipsForPVPView:OnInit()
    self:ResetData()
    self.ImgCountPathTable = {}
    self.ImgCountPathTable[1] = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_Num1.UI_PVPMain_Img_Num1'"
    self.ImgCountPathTable[2] = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_Num2.UI_PVPMain_Img_Num2'"
    self.ImgCountPathTable[3] = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_Num3.UI_PVPMain_Img_Num3'"
    self.ImgCountPathTable[4] = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_Num4.UI_PVPMain_Img_Num4'"
    self.ImgCountPathTable[5] = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_Num5.UI_PVPMain_Img_Num5'"
    self.ImgCountPathTable[6] = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_Num6.UI_PVPMain_Img_Num6'"
    self.ImgCountPathTable[7] = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_Num7.UI_PVPMain_Img_Num7'"
    self.ImgCountPathTable[8] = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_Num8.UI_PVPMain_Img_Num8'"
    self.ImgCountPathTable[9] = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_Num9.UI_PVPMain_Img_Num9'"
    self.ImgCountPathTable[10] = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_Num10.UI_PVPMain_Img_Num10'"
end

function InfoCountdownTipsForPVPView:OnDestroy()
end

function InfoCountdownTipsForPVPView:OnShow()
    local Params = self.Params -- 可以为空，走自动计时
    self:BeginCountDown(Params)
end

function InfoCountdownTipsForPVPView:ResetData()
    self:CancelTimer()
    if (self.CountDownSoundHandle ~= nil) then
        AudioUtil.StopAsyncAudioHandle(self.CountDownSoundHandle)
    end
end

function InfoCountdownTipsForPVPView:OnHide()
    self:ResetData()
end

function InfoCountdownTipsForPVPView:OnRegisterUIEvent()
end

function InfoCountdownTipsForPVPView:OnRegisterGameEvent()
end

function InfoCountdownTipsForPVPView:OnRegisterBinder()

end

function InfoCountdownTipsForPVPView:InternalCountdown()
    self.CurTime = self.CurTime - self.TimeInterval
    self:RefreshCountDownImg()
    if (self.CurTime <= 0) then
        -- 重置数据，隐藏
        self:ResetData()
        self:Hide()
    end
end

function InfoCountdownTipsForPVPView:CancelTimer()
    if (self.CountDownTimer ~= nil) then
        self:UnRegisterTimer(self.CountDownTimer)
        self.CountDownTimer = nil
    end
end

---InfoCountdownTipsForPVPView.BeginCountDown Description of the function
---@param Params Type Description
--- Params.TimeInterval or 1 -- 检查间隔，不填写默认1
--- Params.BeginTime -- 默认10 秒
--- Params.EndTime -- 默认1秒
--- Params.RedTime or 10 -- 倒计时变红的警告时间，默认10秒变红
function InfoCountdownTipsForPVPView:BeginCountDown(Params)
    self:ResetData()

    if (Params == nil) then
        self.TimeInterval = DefaultTimeInterval
        self.CurTime = DefaultBeginTime
        self.EndTime = DefaultEndTime
        self.RedTime = DefaultRedTime
        self.CountDownLoopSound = nil
    else
        self.TimeInterval = Params.TimeInterval or DefaultTimeInterval
        self.CurTime = Params.BeginTime or DefaultBeginTime -- 外部指定秒 or 默认10秒
        self.EndTime = Params.EndTime or DefaultEndTime -- 外部指定秒 or 1
        self.RedTime = Params.RedTime or DefaultRedTime
        self.CountDownLoopSound = Params.CountDownLoopSound or nil
    end

    self.CountDownTimer = self:RegisterTimer(self.InternalCountdown, self.TimeInterval, self.TimeInterval, 0)
    self:RefreshCountDownImg()
    self.CountDownSoundHandle = AudioUtil.LoadAndPlay2DSound(PVPColosseumDefine.AudioPath.CountDown)
end

function InfoCountdownTipsForPVPView:RefreshCountDownImg()
    local TargetPath = self.ImgCountPathTable[self.CurTime]
    if (TargetPath ~= nil) then
        UIUtil.ImageSetBrushFromAssetPath(self.ImgNum, TargetPath)
        self:PlayAnimation(self.AnimTimeChange)
    end
end

return InfoCountdownTipsForPVPView
