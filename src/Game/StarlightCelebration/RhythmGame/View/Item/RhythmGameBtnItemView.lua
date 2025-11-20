---
--- Author: Administrator
--- DateTime: 2025-07-15 20:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local RhythmGameMgr = nil
local FLOG_INFO = nil
local AnimSpeed = 1
local BaseScale = 400
local BaseMinScale = 100
local BaseLength = 300
local BaseMaxLength = 348
local BaseMinLength = 48

---@class RhythmGameBtnItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSuccess UFButton
---@field BtnSuccess_1 UFButton
---@field FTextBlock_30 UFTextBlock
---@field ImgIcon UFCanvasPanel
---@field ImgIconResultFail UFImage
---@field ImgIconResultGreet UFImage
---@field ImgIconResultLongFail UFImage
---@field ImgIconResultLongGreet UFImage
---@field ImgIconResultLongNotBad UFImage
---@field ImgIconResultLongPerfect UFImage
---@field ImgIconResultNotBad UFImage
---@field ImgIconResultPerfect UFImage
---@field ImgIcon_1 UFCanvasPanel
---@field ImgSuccessArea_1 UFImage
---@field MI_DX_Mask_StarlightCelebration_RhythmGame_1 UFImage
---@field MI_DX_Mask_StarlightCelebration_RhythmGame_2 UFImage
---@field PanelFail UFCanvasPanel
---@field PanelFrame UFCanvasPanel
---@field PanelFrame_1 UFCanvasPanel
---@field PanelGreet UFCanvasPanel
---@field PanelImgIconResultFail UFCanvasPanel
---@field PanelImgIconResultGreet UFCanvasPanel
---@field PanelImgIconResultNotBad UFCanvasPanel
---@field PanelImgIconResultPerfect UFCanvasPanel
---@field PanelLong UFCanvasPanel
---@field PanelLongRoot UFCanvasPanel
---@field PanelLongpress UFCanvasPanel
---@field PanelNormal UFCanvasPanel
---@field PanelNotBad UFCanvasPanel
---@field PanelPerfect UFCanvasPanel
---@field TextFail UFTextBlock
---@field TextGreet UFTextBlock
---@field TextNotBad UFTextBlock
---@field TextPerfect UFTextBlock
---@field AnimFail UWidgetAnimation
---@field AnimGreet UWidgetAnimation
---@field AnimHide UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLongPressLongLoop UWidgetAnimation
---@field AnimLongPressLongMove UWidgetAnimation
---@field AnimLongPressScale UWidgetAnimation
---@field AnimNormalScale UWidgetAnimation
---@field AnimNotBad UWidgetAnimation
---@field AnimPerfect UWidgetAnimation
---@field AnimReset UWidgetAnimation
---@field ValueFrameStart float
---@field ValueFrameEnd float
---@field ValueLongStart float
---@field ValueLongEnd float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RhythmGameBtnItemView = LuaClass(UIView, true)

function RhythmGameBtnItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSuccess = nil
	--self.BtnSuccess_1 = nil
	--self.FTextBlock_30 = nil
	--self.ImgIcon = nil
	--self.ImgIconResultFail = nil
	--self.ImgIconResultGreet = nil
	--self.ImgIconResultLongFail = nil
	--self.ImgIconResultLongGreet = nil
	--self.ImgIconResultLongNotBad = nil
	--self.ImgIconResultLongPerfect = nil
	--self.ImgIconResultNotBad = nil
	--self.ImgIconResultPerfect = nil
	--self.ImgIcon_1 = nil
	--self.ImgSuccessArea_1 = nil
	--self.MI_DX_Mask_StarlightCelebration_RhythmGame_1 = nil
	--self.MI_DX_Mask_StarlightCelebration_RhythmGame_2 = nil
	--self.PanelFail = nil
	--self.PanelFrame = nil
	--self.PanelFrame_1 = nil
	--self.PanelGreet = nil
	--self.PanelImgIconResultFail = nil
	--self.PanelImgIconResultGreet = nil
	--self.PanelImgIconResultNotBad = nil
	--self.PanelImgIconResultPerfect = nil
	--self.PanelLong = nil
	--self.PanelLongRoot = nil
	--self.PanelLongpress = nil
	--self.PanelNormal = nil
	--self.PanelNotBad = nil
	--self.PanelPerfect = nil
	--self.TextFail = nil
	--self.TextGreet = nil
	--self.TextNotBad = nil
	--self.TextPerfect = nil
	--self.AnimFail = nil
	--self.AnimGreet = nil
	--self.AnimHide = nil
	--self.AnimIn = nil
	--self.AnimLongPressLongLoop = nil
	--self.AnimLongPressLongMove = nil
	--self.AnimLongPressScale = nil
	--self.AnimNormalScale = nil
	--self.AnimNotBad = nil
	--self.AnimPerfect = nil
	--self.AnimReset = nil
	--self.ValueFrameStart = nil
	--self.ValueFrameEnd = nil
	--self.ValueLongStart = nil
	--self.ValueLongEnd = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RhythmGameBtnItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RhythmGameBtnItemView:OnInit()
    RhythmGameMgr = _G.RhythmGameMgr
    FLOG_INFO = _G.FLOG_INFO
    -- 添加状态标志
    self.IsAnimationStoppedReleased = false -- 标记释放操作是否已停止动画（用于长按释放判定）
    self.IsAnimationStoppedManually = false -- 标记动画是否被玩家操作停止（用于区分自然结束和手动停止）
    self.IsJudged = false -- 是否已判定
    self.PressJudged = false  -- 按下是否已判定
    self.ReleaseJudged = false  -- 松开是否已判定
    AnimSpeed = RhythmGameMgr.GameSpeed
end

function RhythmGameBtnItemView:OnDestroy()

end

function RhythmGameBtnItemView:OnShow()
    self:PlayAnimIn(self.AnimReset)
    self.TextPerfect:SetText(_G.LSTR(1710012)) -- 完美
    self.TextGreet:SetText(_G.LSTR(1710013))  -- 很棒
    self.TextNotBad:SetText(_G.LSTR(1710014))  -- 不错
    self.TextFail:SetText(_G.LSTR(1710015))  -- 失败
end

function RhythmGameBtnItemView:OnHide()
end

function RhythmGameBtnItemView:OnRegisterUIEvent()
    UIUtil.AddOnPressedEvent(self, self.BtnSuccess, self.OnClick)
    UIUtil.AddOnPressedEvent(self, self.BtnSuccess_1, self.OnPressed)
    UIUtil.AddOnReleasedEvent(self, self.BtnSuccess_1, self.OnReleased)
end

function RhythmGameBtnItemView:OnRegisterGameEvent()

end

function RhythmGameBtnItemView:OnRegisterBinder()

end

function RhythmGameBtnItemView:UpdateNote(NoteData)
    if not NoteData then return end

    AnimSpeed = RhythmGameMgr.GameSpeed
    self.NoteData = NoteData
    self.IsAnimationStoppedReleased = false
    self.IsAnimationStoppedManually = false
    self.IsJudged = false -- 重置判定状态
    self.PressJudged = false  -- 重置按下判定状态
    self.ReleaseJudged = false  -- 重置松开判定状态
    self.PressJudgement = RhythmGameMgr.Judgement.MISS
    
    if NoteData.ScanLineDirection == 1 then
        self.PanelLongRoot:SetRenderTransformAngle(0)
    else
        self.PanelLongRoot:SetRenderTransformAngle(180)
    end

    if not RhythmGameMgr.DebugMode then
        UIUtil.SetIsVisible(self.FTextBlock_30, false)
    else
        UIUtil.SetIsVisible(self.FTextBlock_30, true)
        if self.DebugTimer then
            self:UnRegisterTimer(self.DebugTimer)
            self.DebugTimer = nil
        end
        local CallBack = function()
            local TextStr = ""
            if NoteData.Type == RhythmGameMgr.NoteType.CLICK then
                local CurSize = UIUtil.GetWidgetSize(self.PanelFrame)
                TextStr = tostring(math.floor(CurSize.X * 10) / 10)
            else
                local CurSize = UIUtil.GetWidgetSize(self.PanelFrame_1)
                if self.PressJudged then
                    CurSize = UIUtil.GetWidgetSize(self.PanelLong)
                end
                TextStr = tostring(math.floor(CurSize.Y * 10) / 10)
            end
            
            self.FTextBlock_30:SetText(TextStr)
        end
        
        self.DebugTimer = self:RegisterTimer(CallBack, 0, 0.05, 0)
    end
    
    self:PlayAnimation(self.AnimReset)
    if NoteData.Type == RhythmGameMgr.NoteType.CLICK then
        UIUtil.SetIsVisible(self.PanelNormal, true)
        UIUtil.SetIsVisible(self.PanelLongpress, false)
        self.BtnSuccess:SetIsEnabled(true)
        self.BtnSuccess_1:SetIsEnabled(false)
        
        UIUtil.SetIsVisible(self.ImgIconResultPerfect, true)
        UIUtil.SetIsVisible(self.ImgIconResultLongPerfect, false)
        
        UIUtil.SetIsVisible(self.ImgIconResultGreet, true)
        UIUtil.SetIsVisible(self.ImgIconResultLongGreet, false)
        
        UIUtil.SetIsVisible(self.ImgIconResultNotBad, true)
        UIUtil.SetIsVisible(self.ImgIconResultLongNotBad, false)
        
        UIUtil.SetIsVisible(self.ImgIconResultFail, true)
        UIUtil.SetIsVisible(self.ImgIconResultLongFail, false)
        
        -- （End默认值100，与判定区域相同，点击时停止播放AnimNormalScale取PanelFrame的任一尺寸与Start对比）
        self:PlayAnimNormalScale(BaseScale, BaseMinScale, AnimSpeed)
    else
        local HoldTick = NoteData.HoldTick or 480  -- 默认1333毫秒
        self.ActualLength = math.floor(BaseLength * (HoldTick / 480))
        
        --UIUtil.CanvasSlotSetSize(self.PanelLong, _G.UE.FVector2D(BaseMinLength, self.ActualLength + BaseMinLength))
        self:SetPanelLongLength(self.ActualLength)
        
        UIUtil.SetIsVisible(self.PanelNormal, false)
        UIUtil.SetIsVisible(self.PanelLongpress, true)
        UIUtil.SetIsVisible(self.PanelLongRoot, true)
        
        UIUtil.SetIsVisible(self.ImgIconResultPerfect, false)
        UIUtil.SetIsVisible(self.ImgIconResultLongPerfect, true)

        UIUtil.SetIsVisible(self.ImgIconResultGreet, false)
        UIUtil.SetIsVisible(self.ImgIconResultLongGreet, true)

        UIUtil.SetIsVisible(self.ImgIconResultNotBad, false)
        UIUtil.SetIsVisible(self.ImgIconResultLongNotBad, true)

        UIUtil.SetIsVisible(self.ImgIconResultFail, false)
        UIUtil.SetIsVisible(self.ImgIconResultLongFail, true)
        self.BtnSuccess:SetIsEnabled(false)
        self.BtnSuccess_1:SetIsEnabled(true)
        
        -- 长按（End默认值100，与判定区域相同，点击时停止播放AnimLongPressScale取PanelFrame_1的任一尺寸与Start对比）
        self:PlayAnimLongPressScale(BaseScale, BaseMinScale, AnimSpeed)
    end
end

function RhythmGameBtnItemView:OnClick()
    -- 防止重复判定
    if not self.NoteData or self.IsJudged then
        --FLOG_INFO("[RhythmGame] OnClick ignored - no note or already judged")
        return
    end

    self.IsJudged = true
    self.IsAnimationStoppedManually = true
    self:StopAnimation(self.AnimNormalScale)

    -- 禁用按钮防止多次点击
    self.BtnSuccess:SetIsEnabled(false)

    local CurSize = UIUtil.GetWidgetSize(self.PanelFrame)
    local RemainingRatio = (CurSize.X - BaseMinScale) / (BaseScale - BaseMinScale)
    
    local Judgement = RhythmGameMgr.Judgement.MISS
    if RemainingRatio <= RhythmGameMgr.JudgementWindows[RhythmGameMgr.Judgement.PERFECT] then
        Judgement = RhythmGameMgr.Judgement.PERFECT
        self:PlayAnimation(self.AnimPerfect, 0, 1, 0, AnimSpeed)
        --FLOG_INFO("[RhythmGame] Click PERFECT - Note ID: %d, Ratio: %.2f", self.NoteData.ID, RemainingRatio)
    elseif RemainingRatio <= RhythmGameMgr.JudgementWindows[RhythmGameMgr.Judgement.GREAT] then
        Judgement = RhythmGameMgr.Judgement.GREAT
        self:PlayAnimation(self.AnimGreet, 0, 1, 0, AnimSpeed)
        --FLOG_INFO("[RhythmGame] Click GREAT - Note ID: %d, Ratio: %.2f", self.NoteData.ID, RemainingRatio)
    elseif RemainingRatio <= RhythmGameMgr.JudgementWindows[RhythmGameMgr.Judgement.GOOD] then
        Judgement = RhythmGameMgr.Judgement.GOOD
        self:PlayAnimation(self.AnimNotBad, 0, 1, 0, AnimSpeed)
        --FLOG_INFO("[RhythmGame] Click GOOD - Note ID: %d, Ratio: %.2f", self.NoteData.ID, RemainingRatio)
    else
        --FLOG_INFO("[RhythmGame] Click MISS - Note ID: %d, Ratio: %.2f", self.NoteData.ID, RemainingRatio)
    end
    self:PlayAnimation(self.AnimHide, 0, 1, 0, AnimSpeed)

    RhythmGameMgr:OnClickNote(self.NoteData.ID, Judgement)
end

function RhythmGameBtnItemView:OnPressed()
    self.PressJudgement = RhythmGameMgr.Judgement.MISS  -- 记录按下时的判定
    -- 防止重复判定
    if not self.NoteData or self.PressJudged then
        --FLOG_INFO("[RhythmGame] OnPressed ignored - no note or already judged")
        return
    end

    self.PressJudged = true
    self.IsAnimationStoppedManually = true

    -- 禁用按钮防止多次操作
    self.BtnSuccess_1:SetIsEnabled(false)

    if not self:IsAnimationPlaying(self.AnimLongPressLongLoop) then
        self:PlayAnimation(self.AnimLongPressLongLoop, 0, 0, 0, AnimSpeed)
        --FLOG_INFO("[RhythmGame] LongPress START - Note ID: %d", self.NoteData.ID)
    end
    
    local LongMoveSpeed = (self.NoteData.HoldTick * self.NoteData.MsPerTick) or 1000
    self:PlayAnimLongPressLongMove(self.ActualLength or 300, 0, LongMoveSpeed / 1000 * AnimSpeed)

    self:StopAnimation(self.AnimLongPressScale)
    local CurSize = UIUtil.GetWidgetSize(self.PanelFrame_1)
    local RemainingRatio = (CurSize.X - BaseMinScale) / (BaseScale - BaseMinScale)

    if RemainingRatio <= RhythmGameMgr.JudgementWindows[RhythmGameMgr.Judgement.PERFECT] then
        self.PressJudgement = RhythmGameMgr.Judgement.PERFECT
        self:PlayAnimation(self.AnimPerfect, 0, 1, 0, AnimSpeed)
        --FLOG_INFO("[RhythmGame] LongPress PERFECT - Note ID: %d, Ratio: %.2f", self.NoteData.ID, RemainingRatio)
    elseif RemainingRatio <= RhythmGameMgr.JudgementWindows[RhythmGameMgr.Judgement.GREAT] then
        self.PressJudgement = RhythmGameMgr.Judgement.GREAT
        self:PlayAnimation(self.AnimGreet, 0, 1, 0, AnimSpeed)
        --FLOG_INFO("[RhythmGame] LongPress GREAT - Note ID: %d, Ratio: %.2f", self.NoteData.ID, RemainingRatio)
    elseif RemainingRatio <= RhythmGameMgr.JudgementWindows[RhythmGameMgr.Judgement.GOOD] then
        self.PressJudgement = RhythmGameMgr.Judgement.GOOD
        self:PlayAnimation(self.AnimNotBad, 0, 1, 0, AnimSpeed)
        --FLOG_INFO("[RhythmGame] LongPress GOOD - Note ID: %d, Ratio: %.2f", self.NoteData.ID, RemainingRatio)
    else
        --FLOG_INFO("[RhythmGame] LongPress MISS - Note ID: %d, Ratio: %.2f", self.NoteData.ID, RemainingRatio)
    end

    RhythmGameMgr:OnPressedNote(self.NoteData.ID, self.PressJudgement)
end

function RhythmGameBtnItemView:OnReleased()
    -- 防止重复操作
    if not self.NoteData or self.ReleaseJudged or self.IsAnimationStoppedReleased then
        --FLOG_INFO("[RhythmGame] OnReleased ignored - no note, not judged or already released")
        return
    end

    self.ReleaseJudged = true  -- 标记松开已判定
    -- 如果按下时已经是MISS，则不触发抬起的判定
    if self.PressJudgement == RhythmGameMgr.Judgement.MISS then
        --FLOG_INFO("[RhythmGame] OnReleased skipped for MISSED note - Note ID: %d", self.NoteData.ID)
        self.IsAnimationStoppedReleased = true
        return
    end

    self.IsAnimationStoppedReleased = true
    self:StopAnimation(self.AnimLongPressLongLoop)
    self:StopAnimation(self.AnimLongPressScale)
    self:StopAnimation(self.AnimLongPressLongMove)
    --FLOG_INFO("[RhythmGame] LongPress END - Note ID: %d", self.NoteData.ID)

    local CurSize = UIUtil.GetWidgetSize(self.PanelLong)
    local RemainingRatio = (CurSize.Y - BaseMinLength) / (self.ActualLength or 300)

    if self:IsAnimationPlaying(self.AnimPerfect) then
        self:PlayAnimToEnd(self.AnimPerfect)
    end
    if self:IsAnimationPlaying(self.AnimGreet) then
        self:PlayAnimToEnd(self.AnimGreet)
    end
    if self:IsAnimationPlaying(self.AnimNotBad) then
        self:PlayAnimToEnd(self.AnimNotBad)
    end
    
    local Judgement = RhythmGameMgr.Judgement.MISS
    if RemainingRatio <= RhythmGameMgr.JudgementWindows[RhythmGameMgr.Judgement.PERFECT] then
        Judgement = RhythmGameMgr.Judgement.PERFECT
        self:PlayAnimation(self.AnimPerfect, 0, 1, 0, AnimSpeed)
        --FLOG_INFO("[RhythmGame] LongRelease PERFECT - Note ID: %d, Ratio: %.2f", self.NoteData.ID, RemainingRatio)
    elseif RemainingRatio <= RhythmGameMgr.JudgementWindows[RhythmGameMgr.Judgement.GREAT] then
        Judgement = RhythmGameMgr.Judgement.GREAT
        self:PlayAnimation(self.AnimGreet, 0, 1, 0, AnimSpeed)
        --FLOG_INFO("[RhythmGame] LongRelease GREAT - Note ID: %d, Ratio: %.2f", self.NoteData.ID, RemainingRatio)
    elseif RemainingRatio <= RhythmGameMgr.JudgementWindows[RhythmGameMgr.Judgement.GOOD] then
        Judgement = RhythmGameMgr.Judgement.GOOD
        self:PlayAnimation(self.AnimNotBad, 0, 1, 0, AnimSpeed)
        --FLOG_INFO("[RhythmGame] LongRelease GOOD - Note ID: %d, Ratio: %.2f", self.NoteData.ID, RemainingRatio)
    else
        --FLOG_INFO("[RhythmGame] LongRelease MISS - Note ID: %d, Ratio: %.2f", self.NoteData.ID, RemainingRatio)
    end
    self:PlayAnimation(self.AnimHide, 0, 1, 0, AnimSpeed)
    RhythmGameMgr:OnReleasedNote(self.NoteData.ID, Judgement)
end

function RhythmGameBtnItemView:OnAnimationFinished(Animation)
    -- 点按和长按超时
    if Animation == self.AnimNormalScale then
        if not self.IsAnimationStoppedManually and not self.IsJudged then
            self.IsJudged = true
            self:PlayAnimation(self.AnimFail, 0, 1, 0, AnimSpeed)
            self:PlayAnimation(self.AnimHide, 0, 1, 0, AnimSpeed)

            --FLOG_INFO("[RhythmGame] %s TIMEOUT MISS - Note ID: %d", "Click" , self.NoteData.ID)
            RhythmGameMgr:OnClickNote(self.NoteData.ID, RhythmGameMgr.Judgement.MISS)
        end
        self.IsAnimationStoppedManually = false
    elseif Animation == self.AnimLongPressScale then
        if not self.IsAnimationStoppedManually and not self.PressJudged then
            self.PressJudged = true
            self:PlayAnimation(self.AnimFail, 0, 1, 0, AnimSpeed)
            self:PlayAnimation(self.AnimHide, 0, 1, 0, AnimSpeed)

            --FLOG_INFO("[RhythmGame] %s TIMEOUT MISS - Note ID: %d", "LongPress", self.NoteData.ID)
            RhythmGameMgr:OnPressedNote(self.NoteData.ID, RhythmGameMgr.Judgement.MISS)
            RhythmGameMgr:OnReleasedNote(self.NoteData.ID, RhythmGameMgr.Judgement.MISS)
        end
        self.IsAnimationStoppedManually = false
    -- 拖尾超时
    elseif Animation == self.AnimLongPressLongMove then
        -- 如果长按持续时间结束但还未松开 或者 动画结束没有按下操作
        --if not self.ReleaseJudged or (not self.IsAnimationStoppedReleased and not self.PressJudged) then
        
        -- 如果长按移动没有操作，需要自动进行判定，按【完美】结算
        if not self.IsAnimationStoppedReleased then
            self.ReleaseJudged = true
            self.PressJudged = true
            
            self.IsAnimationStoppedReleased = true
            self:StopAnimation(self.AnimLongPressLongLoop)
            self:StopAnimation(self.AnimLongPressScale)
            self:StopAnimation(self.AnimLongPressLongMove)
            
            if self:IsAnimationPlaying(self.AnimPerfect) then
                self:PlayAnimToEnd(self.AnimPerfect)
            end
            if self:IsAnimationPlaying(self.AnimGreet) then
                self:PlayAnimToEnd(self.AnimGreet)
            end
            if self:IsAnimationPlaying(self.AnimNotBad) then
                self:PlayAnimToEnd(self.AnimNotBad)
            end
            
            self:PlayAnimation(self.AnimPerfect, 0, 1, 0, AnimSpeed)
            self:PlayAnimation(self.AnimHide, 0, 1, 0, AnimSpeed)

            --FLOG_INFO("[RhythmGame] LongMove TIMEOUT PERFECT - Note ID: %d", self.NoteData.ID)
            RhythmGameMgr:OnReleasedNote(self.NoteData.ID, RhythmGameMgr.Judgement.PERFECT)
        --else
        --    self.ReleaseJudged = true
        --    self.PressJudged = true
        --    self:PlayAnimation(self.AnimFail, 0, 1, 0, AnimSpeed)
        --    self:PlayAnimation(self.AnimHide, 0, 1, 0, AnimSpeed)
        --
        --    --FLOG_INFO("[RhythmGame] LongMove TIMEOUT MISS - Note ID: %d", self.NoteData.ID)
        --    RhythmGameMgr:OnReleasedNote(self.NoteData.ID, RhythmGameMgr.Judgement.MISS)
        end
        self.IsAnimationStoppedReleased = false
    -- 结束，开始回收Note
    elseif Animation == self.AnimHide then
        --FLOG_INFO("[RhythmGame] Note REMOVED - ID: %d", self.NoteData.ID)
        RhythmGameMgr:RemoveActiveNote(self.NoteData.ID)
        self.NoteData = nil -- 清除音符数据
    end
end

function RhythmGameBtnItemView:PauseGame()
    if self:IsAnimationPlaying(self.AnimNormalScale) then
        self.AnimNormalScalePauseTimePoint = self:PauseAnimation(self.AnimNormalScale)
    end
    if self:IsAnimationPlaying(self.AnimLongPressScale) then
        self.AnimLongPressScalePauseTimePoint = self:PauseAnimation(self.AnimLongPressScale)
    end
end

function RhythmGameBtnItemView:ResumeGame()
    if self.AnimNormalScalePauseTimePoint then
        self:PlayAnimation(self.AnimNormalScale, self.AnimNormalScalePauseTimePoint, 1, 0, AnimSpeed)
    end
    if self.AnimLongPressScalePauseTimePoint then
        self:PlayAnimation(self.AnimLongPressScale, self.AnimLongPressScalePauseTimePoint, 1, 0, AnimSpeed)
    end
    self.AnimNormalScalePauseTimePoint = nil
    self.AnimLongPressScalePauseTimePoint = nil
end

return RhythmGameBtnItemView