---
--- Author: chriswang
--- DateTime: 2024-07-31 10:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local LSTR = _G.LSTR
-- local SaveKey = require("Define/SaveKey")
--@ViewModel
local SettingsVoiceResVM = require("Game/Settings/VM/SettingsVoiceResVM")

---@class SettingsDownloadWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnCancelDownload CommBtnLView
---@field BtnConfirm CommBtnLView
---@field BtnConfirm2 CommBtnLView
---@field Comm2FrameS_UIBP Comm2FrameSView
---@field PanelComplete UFCanvasPanel
---@field PanelDownload UFCanvasPanel
---@field PanelDownloading UFCanvasPanel
---@field ProBar UProgressBar
---@field RichTextBoxDesc URichTextBox
---@field RichTextSpeed URichTextBox
---@field RichTextStatus URichTextBox
---@field TextHint UFTextBlock
---@field TextHint2 UFTextBlock
---@field TextSize UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsDownloadWinView = LuaClass(UIView, true)

function SettingsDownloadWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnCancelDownload = nil
	--self.BtnConfirm = nil
	--self.BtnConfirm2 = nil
	--self.Comm2FrameS_UIBP = nil
	--self.PanelComplete = nil
	--self.PanelDownload = nil
	--self.PanelDownloading = nil
	--self.ProBar = nil
	--self.RichTextBoxDesc = nil
	--self.RichTextSpeed = nil
	--self.RichTextStatus = nil
	--self.TextHint = nil
	--self.TextHint2 = nil
	--self.TextSize = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsDownloadWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnCancelDownload)
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.BtnConfirm2)
	self:AddSubView(self.Comm2FrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsDownloadWinView:OnInit()

end

function SettingsDownloadWinView:OnDestroy()

end

function SettingsDownloadWinView:OnShow()
	self.UIMode = 1

	self.TextHint2:SetText(LSTR(110044))
	self.BtnConfirm:SetBtnName(LSTR(110032))
	self.BtnCancel:SetBtnName(LSTR(110021))
	self.BtnCancelDownload:SetBtnName(LSTR(110043))
	self.Comm2FrameS_UIBP:SetTitleText(LSTR(110066))

	if self.Params then
		self.TextSize:SetText(string.format(("%.2fM"), self.Params.PkgSize))
		local StrContent = string.format(LSTR(110031)
			, self.Params.Text)
		self.RichTextBoxDesc:SetText(StrContent)

		self:UIToPanelDownload()
		
		self.FilesInfo = _G.UE.UVersionMgr.Get():GetL10nInfo(_G.UE.EGameL10nType.Voices, self.Params.LanguageType)
		-- local AllSize = 0
		-- local FileCnt = self.FilesInfo.L10Ns:Length()
		-- for i = 1, FileCnt, 1 do
		-- 	local FileInfo = self.FilesInfo.L10Ns:Get(i)
		-- 	AllSize = AllSize + FileInfo.Size
		-- end
		-- self.FilesSize = AllSize
		
		self.ProBar:SetPercent(0)
		self.RichTextStatus:SetText("")
		self.RichTextSpeed:SetText("")
		-- UIUtil.TextBlockSetColorAndOpacityHex(self.RichTextStatus, "#D5D5D5")
		-- UIUtil.SetIsVisible(self.RichTextSpeed, false)
		-- self.TextHint:SetText(LSTR(110030))
		self.TextHint:SetText(LSTR(110027))
	else
	
		UIUtil.SetIsVisible(self.PanelDownloading, false)
		UIUtil.SetIsVisible(self.PanelComplete, false)
	end
end

function SettingsDownloadWinView:OnHide()
	if self.Result and self.Result.Downloader then
		FLOG_INFO("SettingsDownloadWinView OnHide Downloader:Cancel")
		self.Result.Downloader:Cancel()
	end

	self.Result = nil
end

function SettingsDownloadWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm.Button, self.OnConfirmBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnBtnCancelBtnClick)

	--取消下载
	UIUtil.AddOnClickedEvent(self, self.BtnCancelDownload.Button, self.OnBtnCancelDownloadClick)

	--下载完成，重启提示
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm2.Button, self.OnQuitGameBtnClick)
end

function SettingsDownloadWinView:OnRegisterGameEvent()

end

function SettingsDownloadWinView:OnRegisterBinder()

end

function SettingsDownloadWinView:UIToPanelDownload()
	UIUtil.SetIsVisible(self.PanelDownload, true)
	UIUtil.SetIsVisible(self.PanelDownloading, false)
	UIUtil.SetIsVisible(self.PanelComplete, false)
	
	self.UIMode = 1
end

function SettingsDownloadWinView:OnConfirmBtnClick()
	if self.UIMode == 1 then --点击下载， 变成下载中
		local Size = self.Params and self.Params.PkgSize or 0
		if Size > 30 and not _G.UE.UGCloudMgr.Get():IsWifiConnected() then
			local function OkBtnCallback()
				self:UIToPanelDownloading()
			end
			
			local function OkBtnCancelback()
				self:Hide()
			end

			local TipContent = string.format(LSTR(110028)
				, self.Params.PkgSize)
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(110026), TipContent, OkBtnCallback, OkBtnCancelback)
		else
			self:UIToPanelDownloading()
		end
	else
		self:Hide()
	end
end

function SettingsDownloadWinView:OnBtnCancelBtnClick()
	self:Hide()
end

--切换到下载界面，并且开始下载
function SettingsDownloadWinView:UIToPanelDownloading()
	UIUtil.SetIsVisible(self.PanelDownload, false)
	UIUtil.SetIsVisible(self.PanelDownloading, true)
	UIUtil.SetIsVisible(self.PanelComplete, false)
	
	self.UIMode = 2
	
	if self.FilesInfo then
		local PufferTask = _G.UE.FPufferTask()
		PufferTask.SrcUnits = _G.UE.TArray(_G.UE.FPufferTaskUnit)
		PufferTask.bAutoDownload = true

		local CurDownLoadPak = ""
		local FileCnt = self.FilesInfo.L10Ns:Length()
		for i = 1, FileCnt, 1 do
			local FileInfo = self.FilesInfo.L10Ns:Get(i)
			if string.find(FileInfo.Name, "pak") then
				local Dir = _G.UE.UPufferMgr.Get():GetPufferDownloadDir()
				CurDownLoadPak = string.format("%s/%s", Dir, FileInfo.Name)
				FLOG_INFO("setting DownLoad pak: %s", CurDownLoadPak)
			end

			local TaskUnit = _G.UE.FPufferTaskUnit()
			TaskUnit.Mode = _G.UE.EPufferTaskMode.Filename
			TaskUnit.Src = FileInfo.Name
			TaskUnit.Priority = 0
			
			PufferTask.SrcUnits:Add(TaskUnit)
		end

		local function OnPufferTaskProgress(Delegate, Downloader, Progress)
			-- int64 nowSize = 0;
			-- int64 totalSize = 0;
			local Speed = _G.UE.UPufferMgr:Get():GetCurrentSpeed()
			if Speed < 0.01 then
				Speed = 0.1
			end
		
			local TotalSize = Progress.totalSize
			if TotalSize < 1 then
				TotalSize = 1024
			end
		
			local NowSize = Progress.nowSize
			if NowSize < 0 then
				NowSize = 0
			end

			local MBSize = 1024 * 1024
		
			local LeftTime = (TotalSize - NowSize) / (Speed * 60)
			LeftTime = math.ceil(LeftTime)
			FLOG_INFO("setting OnPufferTaskProgress NowSize: %d, TotalSize:%d, Speed:%.2f, LeftTime:%.2f"
				, NowSize, Progress.totalSize, Speed, LeftTime)

			if not self.ProBar then
				return
			end
			
			self.ProBar:SetPercent(NowSize / TotalSize)
		
			local Content = string.format(LSTR('<span color="#D5D5D5FF">预计更新</><span color="#BEAC8C">%d分钟</>'), LeftTime)
			self.RichTextStatus:SetText(Content)
			
			-- UIUtil.SetIsVisible(self.RichTextSpeed, true)
			local Content = string.format(LSTR('<span color="#D1BA8E">%.1fMB/s </><span color="#828282">%.1fMB/%.1fMB</>')
				, Speed / MBSize, NowSize / MBSize, TotalSize / MBSize)
			self.RichTextSpeed:SetText(Content)
		
			-- self.TextHint:SetText(LSTR(110027))
		end

		local function OnFinished(Delegate, Downloader, Results)
			-- bool bIsSuccess = false;
			-- TArray<FPufferTaskUnitRecord> ErrorUnits;
			FLOG_INFO("setting OnFinished bIsSuccess:%s", tostring(Results.bIsSuccess))
		
			if Results.bIsSuccess then
				UIUtil.SetIsVisible(self.PanelDownload, false)
				UIUtil.SetIsVisible(self.PanelDownloading, false)
				UIUtil.SetIsVisible(self.PanelComplete, true)
				
				self.UIMode = 3
				FLOG_INFO("setting MountPak %s", CurDownLoadPak)
				_G.UE.UVersionMgr.Get():MountPak(CurDownLoadPak, 1000, false, false)

				SettingsVoiceResVM:RecordDownLoad(SettingsVoiceResVM.CurrentSelectIndex)
				SettingsVoiceResVM:RefreshLanguageList()
				_G.EventMgr:SendEvent(_G.EventID.OnVoicePkgDownLoad)
				self:Hide()
			else	--下载出错
				local Cnt = Results.ErrorUnits:Length()
				local ErrorCode = 0
				for i = 1, Cnt, 1 do
					local ErrorUnit = Results.ErrorUnits:Get(i)
					ErrorCode = ErrorUnit.Result.ErrorCode
					break
				end

				self:Hide()
				if not ErrorCode or ErrorCode == 0 then	--没找到错误码，但还是下载出错的
					_G.MsgBoxUtil.ShowMsgBoxOneOpRight(nil, LSTR(110026), LSTR(110036))
				else	--有错误码
					local Content = string.format(LSTR(110037), ErrorCode)
					_G.MsgBoxUtil.ShowMsgBoxOneOpRight(nil, LSTR(110026), Content)
				end
			end
		end

		local OnFinishDelegate = CommonUtil.GetDelegatePair(OnFinished, true)
		local OnProgressDelegate = CommonUtil.GetDelegatePair(OnPufferTaskProgress, true)
		local Result = _G.UE.UPufferMgr:Get():CreateDownloader(PufferTask, OnFinishDelegate, OnProgressDelegate, nil)
		if Result.InitStatus == _G.UE.ELaunchPufferTaskStatus.DOWNLOADED then
			UIUtil.SetIsVisible(self.PanelDownload, false)
			UIUtil.SetIsVisible(self.PanelDownloading, false)
			UIUtil.SetIsVisible(self.PanelComplete, true)
			
			self.UIMode = 3
			FLOG_INFO("setting MountPak2 %s", CurDownLoadPak)
			_G.UE.UVersionMgr.Get():MountPak(CurDownLoadPak, 1000, false, false)
			
			SettingsVoiceResVM:RecordDownLoad(SettingsVoiceResVM.CurrentSelectIndex)
			SettingsVoiceResVM:RefreshLanguageList()
			_G.EventMgr:SendEvent(_G.EventID.OnVoicePkgDownLoad)
			self:Hide()
		elseif Result.InitStatus == _G.UE.ELaunchPufferTaskStatus.INVALID then
			_G.MsgBoxUtil.ShowMsgBoxOneOpRight(nil, LSTR(110026), LSTR(110023))
		elseif Result.InitStatus == _G.UE.ELaunchPufferTaskStatus.PUFFER_NOT_INIT then
			_G.MsgBoxUtil.ShowMsgBoxOneOpRight(nil, LSTR(110026), LSTR(110015))
		elseif Result.InitStatus == _G.UE.ELaunchPufferTaskStatus.SUCCESS then
		end

		self.Result = Result
	end
end

--取消下载
function SettingsDownloadWinView:OnBtnCancelDownloadClick()
	if self.UIMode == 2 then
		if self.Result and self.Result.Downloader then
			FLOG_INFO("---------- setting Cancel Download")
			self.Result.Downloader:Cancel()
		end

		self:UIToPanelDownload()
		self:Hide()
	end
end

--重启游戏的提示
function SettingsDownloadWinView:OnQuitGameBtnClick()
	-- print("-----------")
	-- FLOG_INFO("self.Params :%s", table.tostring(self.Params))
	-- FLOG_INFO("self.Params.Idx :%s", tostring(self.Params.Idx))
	-- FLOG_INFO("self.Params.SaveKey :%s", self.Params.SaveKey)
	-- if self.Params and self.Params.Idx and self.Params.SaveKey then
	-- 	FLOG_INFO("setting download ok, savekey:%s", self.Params.SaveKey)
	-- 	local SaveKeyID = SaveKey[self.Params.SaveKey]
	-- 	_G.UE.USaveMgr.SetInt(SaveKeyID, self.Params.Idx, true)

	-- end

	_G.EventMgr:SendEvent(_G.EventID.OnVoicePkgDownLoad)
	self:Hide()
    -- CommonUtil.QuitGame()
end

return SettingsDownloadWinView
