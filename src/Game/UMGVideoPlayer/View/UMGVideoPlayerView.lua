---
--- Author: saintzhao
--- DateTime: 2024-08-28 11:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")

local UUMGVideoPlayerUtil = _G.UE.UUMGVideoPlayerUtil

---@class UMGVideoPlayerView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BGButton UFButton
---@field CanvasPanel_0 UCanvasPanel
---@field CloseButton UButton
---@field MovieImage UImage
---@field MuteVolumeButton UButton
---@field NormalVolumeButton UButton
---@field PauseButton UButton
---@field PlayButton UButton
---@field ResumeButton UButton
---@field TimeSpan UTextBlock
---@field VideoProgressBar UProgressBar
---@field VideoSlider USlider
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local UMGVideoPlayerView = LuaClass(UIView, true)

function UMGVideoPlayerView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BGButton = nil
	--self.CanvasPanel_0 = nil
	--self.CloseButton = nil
	--self.MovieImage = nil
	--self.MuteVolumeButton = nil
	--self.NormalVolumeButton = nil
	--self.PauseButton = nil
	--self.PlayButton = nil
	--self.ResumeButton = nil
	--self.TimeSpan = nil
	--self.VideoProgressBar = nil
	--self.VideoSlider = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function UMGVideoPlayerView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function UMGVideoPlayerView:OnInit()
	self.RateStep = 0.5
	self.MaxRate = 2.0
	self.CurrentRate = 1.0
	self.VideoPath = ""
	self.IsInited = false
	self.IsPaused = false
	self.UIFadeTimerID = nil
	self.UIFadeTime = 5
	self.IsNoUIMode = false
	self.IsInMuteMode = false
	self.IsPreviewMode = false
	self.IsStandaloneMode = false
	self.TickTimerID = nil
	self.IsPlayingWhenEnterBackgroud = false
end

function UMGVideoPlayerView:OnDestroy()
	if nil ~= self.VideoPlayer then
		_G.FLOG_INFO("UMGVideoPlayerView:OnDestroy, Close VideoPlayer")
		self.VideoPlayer:Close()
		self.VideoPlayer = nil
	end
end

function UMGVideoPlayerView:OnShow()
	--UIUtil.SetIsVisible(self.ResumeButton, false)
	--if self.IsInited == false then
		self:InitVideoPlayer()
	--end
	if nil ~= self.VideoPlayer then
		self.VideoPlayer:Play()
		self:StartTickTimer()

		if self.SeekValue then
			self.VideoProgressBar:SetPercent(self.SeekValue)
			UUMGVideoPlayerUtil.OnSeek(self.VideoPlayer, self.SeekValue)
		end
		self:ChangeVideoPlayState(true)
		self:SwitchAudioPlay(false)
	else
		self:ChangeVideoPlayState(false)
	end
	self:ChangeVideoVolumeState(true)
	self:StartUIFadeTimer()
end

function UMGVideoPlayerView:OnHide()
	self:SwitchAudioPlay(true)
	self:StopTickTimer()
end

-- function UMGVideoPlayerView:Tick(_, InDeltaTime)
-- 	self:TickVideoPlay()
-- end

function UMGVideoPlayerView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CloseButton, self.OnClose)
	UIUtil.AddOnClickedEvent(self, self.PlayButton, self.OnPlay)
	UIUtil.AddOnClickedEvent(self, self.PauseButton, self.OnPause)
	UIUtil.AddOnClickedEvent(self, self.NormalVolumeButton, self.OnClickNormalVolumeButton)
	UIUtil.AddOnClickedEvent(self, self.MuteVolumeButton, self.OnClickMuteVolumeButton)
	--UIUtil.AddOnClickedEvent(self, self.ResumeButton, self.OnResume)
	UIUtil.AddOnClickedEvent(self, self.BGButton, self.OnClickBGButton)

	UIUtil.AddOnMouseCaptureBeginEvent(self, self.VideoSlider, self.OnSliderMouseCaptureBegin)
	UIUtil.AddOnValueChangedEvent(self, self.VideoSlider, self.OnSliderValueChange)
	UIUtil.AddOnMouseCaptureEndEvent(self, self.VideoSlider, self.OnSliderMouseCaptureEnd)
end

function UMGVideoPlayerView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
	self:RegisterGameEvent(EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
end

function UMGVideoPlayerView:OnRegisterBinder() 

end

function UMGVideoPlayerView:SetStandaloneMode(bFlag)
	self.IsStandaloneMode = bFlag
end

function UMGVideoPlayerView:SetVideoPath(Path)
	self.VideoPath = Path
end

function UMGVideoPlayerView:SetSeekValue(Value)
	self.SeekValue = Value
end

function UMGVideoPlayerView:SetPlayMovieEndCallBack(View, MovieEndCallBack)
	self.View = View
	self.PlayMovieEndCallBack = MovieEndCallBack
end

function UMGVideoPlayerView:InitVideoPlayer()
	if self.VideoPath ~= "" then
		if self.IsStandaloneMode then
			UIUtil.ImageSetBrushFromAssetPath(self.MovieImage, "Material'/Game/Movies/MediaAssets/MiniUMGVideo_MP_Video_Mat.MiniUMGVideo_MP_Video_Mat'" )
			self.VideoPlayer = UUMGVideoPlayerUtil.GetUMGVideoMediaPlayer(
				"FileMediaSource'/Game/Movies/MediaAssets/MiniUMGVideo.MiniUMGVideo'",
				--"./GameMovies/LayOut.mp4",
				self.VideoPath,
				"MediaPlayer'/Game/Movies/MediaAssets/MiniUMGVideo_MP.MiniUMGVideo_MP'")
		else
			self.VideoPlayer = UUMGVideoPlayerUtil.GetUMGVideoMediaPlayer(
				"FileMediaSource'/Game/Movies/MediaAssets/UMGVideo.UMGVideo'",
				self.VideoPath,
				"MediaPlayer'/Game/Movies/MediaAssets/UMGVideo_MP.UMGVideo_MP'")
		end
		if nil == self.VideoPlayer then
			_G.FLOG_ERROR("UMGVideoPlayerView:OnShow, VideoPlayer is nil!")
		else
			self.VideoPlayer.OnEndReached:Add(self, self.PlayMovieEnd)
		end
		self.IsInited = true
	end
end

function UMGVideoPlayerView:PlayMovieEnd()
	--_G.FLOG_INFO("UMGVideoPlayerView:PlayMovieEnd")
	if self.PlayMovieEndCallBack ~= nil then
		self.PlayMovieEndCallBack(self.View)
		return
	end
	--UIUtil.SetIsVisible(self.ResumeButton, true, true)
	self:ChangeVideoPlayState(false)
end

function UMGVideoPlayerView:OnClose()
	self:SwitchAudioPlay(true)
	self:ClearUIFadeTimer()
	UIUtil.SetIsVisible(self, false)
end

function UMGVideoPlayerView:OnPlay()
	--_G.FLOG_INFO("UMGVideoPlayerView:OnPlay")
	if nil ~= self.VideoPlayer then
		self.VideoPlayer:Play()
		self.IsPaused = false
		self:ChangeVideoPlayState(true)
		if not self.IsInMuteMode then
			self:SetVolume(true)
		end
	end
	self:ResetUIFadeTimer()
end

function UMGVideoPlayerView:OnPause()
	--_G.FLOG_INFO("UMGVideoPlayerView:OnPause")
	if nil ~= self.VideoPlayer then
		self.VideoPlayer:Pause()
		--UIUtil.SetIsVisible(self.ResumeButton, true, true)
		self.IsPaused = true
		self:ChangeVideoPlayState(false)
		self:SetVolume(false)
	end
	self:ResetUIFadeTimer()
end

function UMGVideoPlayerView:OnClickNormalVolumeButton()
	if not self.IsPreviewMode then
		self:ChangeVideoVolumeState(false)
	end
	self:ResetUIFadeTimer()
end

function UMGVideoPlayerView:OnClickMuteVolumeButton()
	if not self.IsPreviewMode then
		self:ChangeVideoVolumeState(true)
	end
	self:ResetUIFadeTimer()
end

function UMGVideoPlayerView:OnResume()
	--_G.FLOG_INFO("UMGVideoPlayerView:OnResume")
	if nil ~= self.VideoPlayer then
		self.VideoPlayer:Play()
		--UIUtil.SetIsVisible(self.ResumeButton, false)
		self:ChangeVideoPlayState(true)
		self.IsPaused = false
	end
end

function UMGVideoPlayerView:OnRewind()
	--_G.FLOG_INFO("UMGVideoPlayerView:OnRewind")
	if nil ~= self.VideoPlayer then
		self.VideoPlayer:Rewind()
		--UIUtil.SetIsVisible(self.ResumeButton, false)
		self:ChangeVideoPlayState(true)
		self.IsPaused = false
	end
end

function UMGVideoPlayerView:OnChangeRate()
	if nil ~= self.VideoPlayer then
		self.CurrentRate = self.CurrentRate + self.RateStep
        if (self.CurrentRate > self.MaxRate) then
            self.CurrentRate = 1.0
		end
        self.VideoPlayer:SetRate(self.CurrentRate)
		--UIUtil.SetIsVisible(self.ResumeButton, false)
		self:ChangeVideoPlayState(true)
	end
end

function UMGVideoPlayerView:OnSliderValueChange(_, Value)
	--_G.FLOG_INFO("UMGVideoPlayerView:OnSliderValueChange, Value = %s", tostring(Value))
	UUMGVideoPlayerUtil.OnSeek(self.VideoPlayer, Value)
	--self.VideoSlider:SetValue(Value)
	self.VideoProgressBar:SetPercent(Value)
	if self.IsPaused == false then
		--UIUtil.SetIsVisible(self.ResumeButton, false)
		self:ChangeVideoPlayState(true)
	end
	self:ResetUIFadeTimer()
end

function UMGVideoPlayerView:StartTickTimer()
	if nil == self.TickTimerID then
		self.TickTimerID = self:RegisterTimer(self.TickVideoPlay, 0, 0.02, 0)
	end
end

function UMGVideoPlayerView:StopTickTimer()
	if nil ~= self.TickTimerID then
		TimerMgr:CancelTimer(self.TickTimerID)
		self.TickTimerID = nil
	end
end

function UMGVideoPlayerView:OnSliderMouseCaptureBegin()
	--_G.FLOG_INFO("UMGVideoPlayerView:OnSliderMouseCaptureBegin")
	self:StopTickTimer()
end

---拖动松手回调
function UMGVideoPlayerView:OnSliderMouseCaptureEnd()
	--_G.FLOG_INFO("UMGVideoPlayerView:OnSliderMouseCaptureEnd")
	self:StartTickTimer()
end

function UMGVideoPlayerView:OnClickBGButton()
	if self.IsNoUIMode then
		return
	end
	if UIUtil.IsVisible(self.CanvasPanel_0) then
		self:HideAllUI()
	else
		self:ShowAllUI()
	end
	self:ResetUIFadeTimer()
end

function UMGVideoPlayerView:GetSeekValue()
	self.VideoSlider:GetValue() 
end

function UMGVideoPlayerView:TickVideoPlay()
	local IsVideoPlaying = UUMGVideoPlayerUtil.IsVideoPlaying(self.VideoPlayer)
	--_G.FLOG_INFO("UMGVideoPlayerView:TickVideoPlay, IsVideoPlaying = %s", tostring(IsVideoPlaying))
	self.IsPaused = not IsVideoPlaying
	self:ChangeVideoPlayState(IsVideoPlaying) 
	UUMGVideoPlayerUtil.TickVideoPlay(self.VideoPlayer, self.VideoSlider, self.VideoProgressBar, self.TimeSpan)
end

function UMGVideoPlayerView:SetVolume(bIsOpen)
	if self.IsPreviewMode then
		bIsOpen = false
	end
	if bIsOpen == true then
		UUMGVideoPlayerUtil.SetNativeVolume(self.VideoPlayer, _G.CgMgr.G_VideoVolume)
	else
		UUMGVideoPlayerUtil.SetNativeVolume(self.VideoPlayer, 0)
	end
end

function UMGVideoPlayerView:ChangeVideoPlayState(IsPlay)
	if IsPlay then
		UIUtil.SetIsVisible(self.PlayButton, false)
		UIUtil.SetIsVisible(self.PauseButton, true, true)
	else
		UIUtil.SetIsVisible(self.PauseButton, false)
		UIUtil.SetIsVisible(self.PlayButton, true, true)
	end
end

function UMGVideoPlayerView:ChangeVideoVolumeState(IsOpen)
	if self.IsPreviewMode then
		IsOpen = false
	end
	if IsOpen then
		UIUtil.SetIsVisible(self.MuteVolumeButton, false)
		UIUtil.SetIsVisible(self.NormalVolumeButton, true, true)
	else
		UIUtil.SetIsVisible(self.NormalVolumeButton, false)
		UIUtil.SetIsVisible(self.MuteVolumeButton, true, true)
	end
	self:SetVolume(IsOpen)
	self.IsInMuteMode = not IsOpen
end

function UMGVideoPlayerView:HideAllUI()
	UIUtil.SetIsVisible(self.CanvasPanel_0, false)
end

function UMGVideoPlayerView:ShowAllUI()
	UIUtil.SetIsVisible(self.CanvasPanel_0, true)
end

function UMGVideoPlayerView:StartUIFadeTimer()
	if nil == self.UIFadeTimerID then
		self.UIFadeTimerID = self:RegisterTimer(self.HideAllUI, self.UIFadeTime, 1, 1)
	end
end

function UMGVideoPlayerView:ClearUIFadeTimer()
	if nil ~= self.UIFadeTimerID then
		TimerMgr:CancelTimer(self.UIFadeTimerID)
		self.UIFadeTimerID = nil
	end
end

function UMGVideoPlayerView:ResetUIFadeTimer()
	self:ClearUIFadeTimer()
	self:StartUIFadeTimer()
end

function UMGVideoPlayerView:SetNoUIMode(IsNoUI)
	self.IsNoUIMode = IsNoUI
end

function UMGVideoPlayerView:SetPreviewMode(IsPreview)
	self.IsPreviewMode = IsPreview
	if IsPreview then
		self:ChangeVideoVolumeState(false)
		self:PlayBGM(true)
	end
end

function UMGVideoPlayerView:PlayBGM(Flag)
	if Flag then
		_G.UE.UBGMMgr.Get():Resume()
		_G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Ambient_Sound, 1)
	else
		_G.UE.UBGMMgr.Get():Pause()
		_G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Ambient_Sound, 0)
	end
end

function UMGVideoPlayerView:SwitchAudioPlay(IsPlayBGM)
	if self.IsPreviewMode then
		IsPlayBGM = true
	end
	if not IsPlayBGM then
		if not self.IsInMuteMode then
			self:SetVolume(true)
		end
	else
		self:SetVolume(false)
	end

	self:PlayBGM(IsPlayBGM)
end

function UMGVideoPlayerView:OnGameEventAppEnterBackground(Params)
	_G.FLOG_INFO("UMGVideoPlayerView:OnGameEventAppEnterBackground")
	self.IsPlayingWhenEnterBackgroud = not self.IsPaused
	self:OnPause()
end

function UMGVideoPlayerView:OnGameEventAppEnterForeground(Params)
	_G.FLOG_INFO("UMGVideoPlayerView:OnGameEventAppEnterForeground")
	if self.IsPlayingWhenEnterBackgroud then
		self:OnPlay()
	end
end

return UMGVideoPlayerView