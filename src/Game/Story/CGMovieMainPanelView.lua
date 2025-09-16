---
--- Author: bowxiong
--- DateTime: 2024-10-26 10:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local CommonUtil = require("Utils/CommonUtil")
local MovieUtil = require("Utils/MovieUtil")
local UIUtil = require("Utils/UIUtil")

---@class CGMovieMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CoverImage UImage
---@field FImage1 UFImage
---@field FImage2 UFImage
---@field MovieImage UImage
---@field AnimBlendIn1 UWidgetAnimation
---@field AnimBlendIn2 UWidgetAnimation
---@field AnimBlendOut1 UWidgetAnimation
---@field AnimBlendOut2 UWidgetAnimation
---@field MediaSourcePath string
---@field MediaPlayerPath string
---@field MovieRootPath string
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CGMovieMainPanelView = LuaClass(UIView, true)

local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO

function CGMovieMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CoverImage = nil
	--self.FImage1 = nil
	--self.FImage2 = nil
	--self.MovieImage = nil
	--self.AnimBlendIn1 = nil
	--self.AnimBlendIn2 = nil
	--self.AnimBlendOut1 = nil
	--self.AnimBlendOut2 = nil
	--self.MediaSourcePath = nil
	--self.MediaPlayerPath = nil
	--self.MovieRootPath = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CGMovieMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CGMovieMainPanelView:OnInit()
end

function CGMovieMainPanelView:OnDestroy()
end

function CGMovieMainPanelView:OnShow()
	UIUtil.SetIsVisible(self.FImage1, false)
	UIUtil.SetIsVisible(self.FImage2, false)
	if not self.Params then
		return
	end
	-- 界面可能被重复打开, 需要异常处理
	if self:IsPlayerValid() then
		return
	end
	self:InitializeAllInOnePlayer()
end

function CGMovieMainPanelView:OnHide()
	-- 需要处理一下Section已经播放完但是CG还没播放完的情况
	self:FinalizeAllInOnePlayer()
end

function CGMovieMainPanelView:OnRegisterUIEvent()
end

function CGMovieMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.BeginMovieSubtitle, self.OnGameEventBeginMovieSubtitle)
	self:RegisterGameEvent(_G.EventID.EndMovieSubtitle, self.OnGameEventEndMovieSubtitle)
	self:RegisterGameEvent(_G.EventID.CGMovieStateChanged, self.OnCGMovieStateChanged)
end

function CGMovieMainPanelView:OnRegisterBinder()
end

function CGMovieMainPanelView:IsPlayerValid()
	return self.PlayerActor and CommonUtil.IsObjectValid(self.PlayerActor)
end

function CGMovieMainPanelView:SetSubtitleImage(SubtitleID, InImage)
	if SubtitleID > self.MaxSubtitleID then
		return
	end
	local SubtitleImagePath = MovieUtil.GetSubtitleImagePath(
			self.MovieType, SubtitleID, self.SubtitleCultureType)
	if SubtitleImagePath then
		UIUtil.ImageSetBrushFromAssetPath(InImage, SubtitleImagePath)
	end
end

function CGMovieMainPanelView:InitializeAllInOnePlayer()
	FLOG_INFO("[CGMovieMainPanelView] InitializeAllInOnePlayer...")
	self.bIsCGMovieReady = false
	self.bIsInitialized = true
	self.MoviePath = self.MovieRootPath..self.Params.MovieName
	self.MovieResource = MovieUtil.GetMovieResource(self.Params.MovieName)
	self.AudioCultureType = MovieUtil.GetAudioCultureType()
	self.SubtitleCultureType = MovieUtil.GetSubtitleCultureType()

	local StartTime = self.Params.StartTime or 0
	-- Subtitles
	local MovieParams = MovieUtil.GetMovieParams(self.MovieResource)
	self.bUseImage1 = true
	if MovieParams then
		self.MovieType = MovieParams[1]
		self.SubtitleOffset = MovieParams[2]
		self.MaxSubtitleID = self.SubtitleOffset + MovieUtil.GetSubtitleMaxIndex(self.MovieType, self.SubtitleCultureType)
		-- 端游字幕ID为0只有占位作用
		self.NextSubtitleID1 = self.SubtitleOffset + 1
		self.NextSubtitleID2 = self.SubtitleOffset + 2
		-- 提前设置一下图片
		self:SetSubtitleImage(self.NextSubtitleID1, self.FImage1)
		self:SetSubtitleImage(self.NextSubtitleID2, self.FImage2)
	end

	-- BGM
	self.MovieBGM = MovieUtil.GetMovieBGM(self.MovieResource, self.AudioCultureType)
	-- Create MediaPlayer
	local function OnSpawnPlayerActor(_, NewActor)
		self.PlayerActor = NewActor
		if not self:IsPlayerValid() then
			FLOG_ERROR("[CGMovieMainPanelView] Spawn AllInOnePlayerActor failed...")
			self:ContinueSequence()
			return
		end
		if not self.MovieBGM then
			FLOG_ERROR("[CGMovieMainPanelView] Invalid MovieBGM...")
			self:ContinueSequence()
			return
		end
		local bRet = self.PlayerActor:LoadSubtitleData(self.MovieType, self.SubtitleCultureType)
		if not bRet then
			-- CG动画不一定带字幕
			FLOG_ERROR("[CGMovieMainPanelView] Play CGMovie without subtitle ...")
		end
		bRet = self.PlayerActor:PlayCGAudio(self.MovieBGM, StartTime)
		if not bRet then
			-- 端游CG动画一定会带音效
			FLOG_ERROR("[CGMovieMainPanelView] Play Movie BGM failed ...")
			self:ContinueSequence()
			return
		end

		bRet = self.PlayerActor:PlayCGMovie(
			self.MoviePath, self.MediaPlayerPath, self.MediaSourcePath, self.MovieImage, StartTime)
		if not bRet then
			FLOG_ERROR("[CGMovieMainPanelView] Play CGMovie failed...")
			self:ContinueSequence()
			return
		end
		FLOG_INFO("[CGMovieMainPanelView] Play CGMovie success...")
	end
	CommonUtil.SpawnActorAsync(_G.UE.AAllInOnePlayerActor.StaticClass(), nil, nil, OnSpawnPlayerActor)
	self:PauseSequence()
end

function CGMovieMainPanelView:FinalizeAllInOnePlayer()
	-- 不重复触发FinalizeAllInOnePlayer
	if not self.bIsInitialized then
		return
	end
	FLOG_INFO("[CGMovieMainPanelView] FinalizeAllInOnePlayer...")
	self.bIsInitialized = false
	self:ContinueSequence()
	if not self:IsPlayerValid() then
		return
	end
	-- 异常退出, 记录一下当前播放进度
	if _G.StoryMgr:IsCGMoviePlaying() then
		local MediaPlayTime = self.PlayerActor:GetMediaPlayTime()
		_G.StoryMgr:CacheCGMoviePlayTime(MediaPlayTime)
	end
	self.PlayerActor:StopCGMovie()
	CommonUtil.DestroyActor(self.PlayerActor)
	self.PlayerActor = nil
end

function CGMovieMainPanelView:PauseSequence()
	-- 先停掉Sequence, 等CG动画和音频加载完成后恢复
	if not self.bIsCGMovieReady and not self.bWaitForCGMovie then
		-- FLOG_INFO("[CGMovieMainPanelView] PauseSequence...")
		-- _G.StoryMgr:PauseSequence(true)
		self.bWaitForCGMovie = true
	end
end

function CGMovieMainPanelView:ContinueSequence()
	if self.bWaitForCGMovie then
		-- FLOG_INFO("[CGMovieMainPanelView] ContinueSequence...")
		-- _G.StoryMgr:ContinueSequence()
		self.bWaitForCGMovie = false
	end
end

function CGMovieMainPanelView:OnGameEventBeginMovieSubtitle(Params)
	if not self.MovieType or not self.SubtitleCultureType then
		return
	end
	local SubtitleIndex = Params.IntParam1 + self.SubtitleOffset
	-- Play animation blend in.
	self:SetSubtitleImage(SubtitleIndex, self.bUseImage1 and self.FImage1 or self.FImage2)
	self:PlayAnimation(self.bUseImage1 and self.AnimBlendIn1 or self.AnimBlendIn2)
	UIUtil.SetIsVisible(self.bUseImage1 and self.FImage1 or self.FImage2, true)
	self.bUseImage1 = not self.bUseImage1
end

function CGMovieMainPanelView:OnGameEventEndMovieSubtitle(Params)
	if not self.MovieType or not self.SubtitleCultureType then
		return
	end
	-- Play animation blend out.
	if self.bUseImage1 then
		self:PlayAnimation(self.AnimBlendOut2)
	else
		self:PlayAnimation(self.AnimBlendOut1)
	end
end

function CGMovieMainPanelView:OnCGMovieStateChanged(Params)
	-- 不重复触发FinalizeAllInOnePlayer
	if not self.bIsInitialized then
		return
	end
	FLOG_INFO("[CGMovieMainPanelView] OnCGMovieStateChanged...")
	self.bIsCGMovieReady = Params.BoolParam1
	if not self.bIsCGMovieReady then
		-- CGMovie已经关闭或者播放结束了
		-- 目前暂时还是先用UI盖住, 等Section结束之后在关闭UI
		-- self:Hide()
	else
		-- CGMovie加载完成
		self:ContinueSequence()
	end
end

function CGMovieMainPanelView:OnAnimationFinished(Anim)
	if Anim == self.AnimBlendOut1 then
		UIUtil.SetIsVisible(self.FImage1, false)
		self.NextSubtitleID1 = self.NextSubtitleID1 + 2
		self:SetSubtitleImage(self.NextSubtitleID1, self.FImage1)
	elseif Anim == self.AnimBlendOut2 then
		UIUtil.SetIsVisible(self.FImage2, false)
		self.NextSubtitleID2 = self.NextSubtitleID2 + 2
		self:SetSubtitleImage(self.NextSubtitleID2, self.FImage2)
	end
end

return CGMovieMainPanelView