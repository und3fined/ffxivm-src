---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:59
--- Description:
---

local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local DateTimeTools = require("Common/DateTimeTools")
local PreDownloadMgr = require("Game/LoginNew/Mgr/PreDownloadMgr")
local TimeUtil = require("Utils/TimeUtil")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID

local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local LSTR = _G.LSTR
local ESlateVisibility = _G.UE.ESlateVisibility

---@class LoginNewPreDownloadWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDownload CommBtnLView
---@field BtnNot CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field ImgBanner UFImage
---@field ImgBannerFail UFImage
---@field ImgBannerLoad UFImage
---@field PanelBanner UFCanvasPanel
---@field PanelBtn UFCanvasPanel
---@field PanelProbar UFCanvasPanel
---@field PanelState UFCanvasPanel
---@field ProgBarExp UProgressBar
---@field RichText URichTextBox
---@field RichTextTips URichTextBox
---@field TextPrepare UFTextBlock
---@field TextSpeed2 UFTextBlock
---@field ToggleButton UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewPreDownloadWinView = LuaClass(UIView, true)

function LoginNewPreDownloadWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDownload = nil
	--self.BtnNot = nil
	--self.Comm2FrameM_UIBP = nil
	--self.ImgBanner = nil
	--self.ImgBannerFail = nil
	--self.ImgBannerLoad = nil
	--self.PanelBanner = nil
	--self.PanelBtn = nil
	--self.PanelProbar = nil
	--self.PanelState = nil
	--self.ProgBarExp = nil
	--self.RichText = nil
	--self.RichTextTips = nil
	--self.TextPrepare = nil
	--self.TextSpeed2 = nil
	--self.ToggleButton = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewPreDownloadWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnDownload)
	self:AddSubView(self.BtnNot)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewPreDownloadWinView:OnInit()
	self.Comm2FrameM_UIBP.FText_Title:SetText(LSTR(LoginStrID.PreDownloadTitle))
	self.BtnNot.TextContent:SetText(LSTR(LoginStrID.PreDownloadNo))
	self.BtnDownload.TextContent:SetText(LSTR(LoginStrID.PreDownloadYes))

	self.ImgBannerLoad:SetVisibility(ESlateVisibility.Collapsed)
	self.ImgBannerFail:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
	self.PanelState:SetVisibility(ESlateVisibility.SelfHitTestInvisible)

	self.TextSpeed2:SetText("")
end

function LoginNewPreDownloadWinView:OnDestroy()

end

function LoginNewPreDownloadWinView:OnShow()
	FLOG_INFO("[LoginNewPreDownloadWinView:OnShow] " )
	if PreDownloadMgr.PreDownloadConfig then
		self.Comm2FrameM_UIBP.FText_Title:SetText(PreDownloadMgr.PreDownloadConfig.TitleText)
		self.RichText:SetText(PreDownloadMgr.PreDownloadConfig.ContentText)
		self:ShowBannerByUrl(PreDownloadMgr.PreDownloadConfig.BannerUrl)

		-- 还原状态
		if PreDownloadMgr.DownloadProgress then
			FLOG_INFO("LoginNewPreDownloadWinView:OnPreDownloadProgress OnShow: %d/%d", PreDownloadMgr.DownloadProgress.nowSize, PreDownloadMgr.DownloadProgress.totalSize)
			self:OnPreDownloadProgress(PreDownloadMgr.DownloadProgress)
		end
		self:OnPreDownloadState(PreDownloadMgr.PreDownloadState)
	end
end

function LoginNewPreDownloadWinView:OnHide()
	local ImageDownloader = self.ImageDownloader
	if ImageDownloader and ImageDownloader:IsValid() then
		ImageDownloader:Stop()
	end
end

function LoginNewPreDownloadWinView:OnRegisterUIEvent()
	FLOG_INFO("[LoginNewPreDownloadWinView:OnRegisterUIEvent] " )
	UIUtil.AddOnClickedEvent(self, self.BtnNot, self.OnClickBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnDownload, self.OnClickBtnDownload)
	UIUtil.AddOnClickedEvent(self, self.ToggleButton, self.OnClickToggleBtn)
end

function LoginNewPreDownloadWinView:OnRegisterGameEvent()
	FLOG_INFO("[LoginNewPreDownloadWinView:OnRegisterGameEvent] " )
	self:RegisterGameEvent(EventID.PreDownloadProgress, self.OnPreDownloadProgress)
	self:RegisterGameEvent(EventID.PreDownloadFinish, self.OnPreDownloadFinish)
	self:RegisterGameEvent(EventID.PreDownloadState, self.OnPreDownloadState)
end

function LoginNewPreDownloadWinView:OnRegisterBinder()

end

function LoginNewPreDownloadWinView:ShowBannerByUrl(BannerUrl)
	FLOG_INFO("[LoginNewPreDownloadWinView:ShowBannerByUrl] BannerUrl:" .. BannerUrl)
	if string.isnilorempty(BannerUrl) then
		return
	end

	self.ImgBannerLoad:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
	self.ImgBannerFail:SetVisibility(ESlateVisibility.Collapsed)
	self.PanelState:SetVisibility(ESlateVisibility.SelfHitTestInvisible)

	---@type UImageDownloader
	local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("BannerUrl", true, 5)
	ImageDownloader.OnSuccess:Add(ImageDownloader,
			function(_, texture)
				if texture then
					FLOG_INFO("[LoginNewPreDownloadWinView:ShowBannerByUrl] Download success")
					UIUtil.ImageSetBrushResourceObject(self.ImgBanner, texture)
					UIUtil.SetIsVisible(self.ImgBanner, true)

					self.ImgBannerLoad:SetVisibility(ESlateVisibility.Collapsed)
					self.ImgBannerFail:SetVisibility(ESlateVisibility.Collapsed)
					self.PanelState:SetVisibility(ESlateVisibility.Collapsed)
				end
			end
	)
	ImageDownloader.OnFail:Add(ImageDownloader,
			function()
				FLOG_ERROR("[LoginNewPreDownloadWinView:ShowBannerByUrl] Download failed...")
				self.ImgBannerLoad:SetVisibility(ESlateVisibility.Collapsed)
				self.ImgBannerFail:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
				self.PanelState:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
			end
	)
	ImageDownloader:Start(BannerUrl, "", true)
	self.ImageDownloader = ImageDownloader
end

function LoginNewPreDownloadWinView:OnClickToggleBtn()
	--local IsChecked = self.ToggleButton:GetChecked()
	if PreDownloadMgr.PreDownloadState == LoginNewDefine.PreDownloadState.Downloading then
		PreDownloadMgr:DownloadPause()
	else
		PreDownloadMgr:DownloadResume()
	end
end

function LoginNewPreDownloadWinView:OnClickBtnCancel()
	FLOG_INFO("[LoginNewPreDownloadWinView:OnClickBtnCancel] " )
	self:Hide()
end

function LoginNewPreDownloadWinView:OnClickBtnDownload()
	FLOG_INFO("[LoginNewPreDownloadWinView:OnClickBtnDownload] " )

	-- TODO 空间判断

	--if not PreDownloadMgr.PufferDownloader then
	--	local PufferTaskCreateResult = PreDownloadMgr:InitDownload()
	--end

	PreDownloadMgr:DownloadStart()
end

function LoginNewPreDownloadWinView:OnPreDownloadProgress(Progress)
	if not Progress then
		FLOG_WARNING("[LoginNewPreDownloadWinView:OnPreDownloadProgress] Progress invalid")
		return
	end

	local TempProgress = {}
	TempProgress.nowSize = Progress.nowSize
	TempProgress.totalSize = Progress.totalSize
	PreDownloadMgr.DownloadProgress = TempProgress

	local MBSize = 1024 * 1024

	--local Speed = _G.UE.UPufferMgr:Get():GetCurrentSpeed()
	--if Speed < 0.01 then
	--	Speed = 0.1
	--end

	local TotalSize = Progress.totalSize
	if TotalSize < 1 then
		TotalSize = 1024
	end

	local NowSize = Progress.nowSize
	if NowSize < 0 then
		NowSize = 0
	end
	self.ProgBarExp:SetPercent(NowSize / TotalSize)

	--local LeftTime = (TotalSize - NowSize) / (Speed * 60)
	--LeftTime = math.ceil(LeftTime)
	--FLOG_INFO("LoginNewPreDownloadWinView:OnClickBtnDownload OnPufferTaskProgress NowSize: %d, TotalSize:%d, Speed:%.2f, LeftTime:%.2f", NowSize, Progress.totalSize, Speed, LeftTime)
	--local Content = string.format(LSTR('<span color="#D5D5D5FF">预计更新</><span color="#BEAC8C">%d分钟</>'), LeftTime)
	self.TextPrepare:SetText(LSTR(LoginStrID.Downloading))

	local SpeedText = string.format("%.1fMB/%.1fMB", NowSize / MBSize, TotalSize / MBSize)
	self.TextSpeed2:SetText(SpeedText)
	FLOG_INFO("LoginNewPreDownloadWinView:OnPreDownloadProgress Progress %s, %d/%d", SpeedText, Progress.nowSize, Progress.totalSize)
end

function LoginNewPreDownloadWinView:OnPreDownloadFinish(Results)
	--FLOG_INFO("LoginNewPreDownloadWinView:OnPreDownloadFinish - bIsSuccess:%s", tostring(Results.bIsSuccess))
end

function LoginNewPreDownloadWinView:OnPreDownloadState(State)
	FLOG_INFO("LoginNewPreDownloadWinView:OnPreDownloadState State:%d", State)
	if State == LoginNewDefine.PreDownloadState.Normal then
		self.PanelBtn:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
		self.PanelProbar:SetVisibility(ESlateVisibility.Collapsed)
		self.RichTextTips:SetVisibility(ESlateVisibility.Collapsed)
	elseif State == LoginNewDefine.PreDownloadState.Init then
		self.TextPrepare:SetText(LSTR(LoginStrID.PreDownloadInit))
		self.PanelBtn:SetVisibility(ESlateVisibility.Collapsed)
		self.PanelProbar:SetVisibility(ESlateVisibility.Visible)
		self.RichTextTips:SetVisibility(ESlateVisibility.Collapsed)
	elseif State ==LoginNewDefine.PreDownloadState.Downloading then
		self.ToggleButton:SetChecked(false)
		self.TextPrepare:SetText(LSTR(LoginStrID.Downloading))
		self.PanelBtn:SetVisibility(ESlateVisibility.Collapsed)
		self.PanelProbar:SetVisibility(ESlateVisibility.Visible)
		self.RichTextTips:SetVisibility(ESlateVisibility.Collapsed)
	elseif State == LoginNewDefine.PreDownloadState.Pause then
		self.ToggleButton:SetChecked(true)
		self.TextPrepare:SetText(LSTR(LoginStrID.PreDownloadResume))
		self.PanelBtn:SetVisibility(ESlateVisibility.Collapsed)
		self.PanelProbar:SetVisibility(ESlateVisibility.Visible)
		self.RichTextTips:SetVisibility(ESlateVisibility.Collapsed)
	elseif State == LoginNewDefine.PreDownloadState.Finish then
		self.TextPrepare:SetText(LSTR(LoginStrID.PreDownloadFinish))
		self.PanelBtn:SetVisibility(ESlateVisibility.Collapsed)
		self.PanelProbar:SetVisibility(ESlateVisibility.Collapsed)
		self.RichTextTips:SetVisibility(ESlateVisibility.SelfHitTestInvisible)

		self:SetNewVersionDate()
		-- 新版本提示时间刷新
		if self.CheckDateTimeID then
			self:UnRegisterTimer(self.CheckDateTimeID)
			self.CheckDateTimeID = nil
		end
		self.CheckDateTimeID = self:RegisterTimer(self.OnTimerCheckDate, 0, 3, 0)
	elseif State == LoginNewDefine.PreDownloadState.Error then
		self.TextPrepare:SetText(LSTR(LoginStrID.PreDownloadFailed))
		self.PanelBtn:SetVisibility(ESlateVisibility.Collapsed)
		self.PanelProbar:SetVisibility(ESlateVisibility.Visible)
		self.RichTextTips:SetVisibility(ESlateVisibility.Collapsed)
		PreDownloadMgr:DownloadPause()
	end
end

function LoginNewPreDownloadWinView:SetNewVersionDate()
	local TargetTime = PreDownloadMgr.PreDownloadConfig.NewVersionTime
	--local LocalTime = _G.UE.UTimerMgr:Get().GetLocalTime()
	local ServerTime = TimeUtil.GetServerTime()
	local IntervalTime = TargetTime - ServerTime
	if IntervalTime < 0 then
		self.RichTextTips:SetText(LSTR(LoginStrID.PreDownloadNewVer))
		if self.CheckDateTimeID then
			self:UnRegisterTimer(self.CheckDateTimeID)
			self.CheckDateTimeID = nil
		end
	else
		local Format = "dd:hh"
		if IntervalTime < 86400 then
			Format = "hh:mm"
		end
		local DateFormat = DateTimeTools.TimeFormat(TargetTime - ServerTime, Format, true)
		self.RichTextTips:SetText(string.format(LSTR(LoginStrID.PreDownloadNewVer2), DateFormat))
	end
end

function LoginNewPreDownloadWinView:OnTimerCheckDate()
	self:SetNewVersionDate()
end

return LoginNewPreDownloadWinView