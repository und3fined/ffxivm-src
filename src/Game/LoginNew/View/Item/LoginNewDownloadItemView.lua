---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:57
--- Description:
---

local UIView = require("UI/UIView")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local SaveKey = require("Define/SaveKey")
local PreDownloadMgr = require("Game/LoginNew/Mgr/PreDownloadMgr")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID
local LSTR = _G.LSTR

local ESlateVisibility = _G.UE.ESlateVisibility
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING

---@class LoginNewDownloadItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDownload UFButton
---@field CommonRedDot CommonRedDotView
---@field FCanvasPanel UFCanvasPanel
---@field ImgDownload1 UFImage
---@field ImgDownloading UFImage
---@field ImgFail UFImage
---@field ImgFinish UFImage
---@field ImgInitialization UFImage
---@field ImgPause UFImage
---@field PanelDownloading UFCanvasPanel
---@field PanelFail UFCanvasPanel
---@field PanelFinish UFCanvasPanel
---@field PanelInitialization UFCanvasPanel
---@field PanelPause UFCanvasPanel
---@field PanelPreDownload UFCanvasPanel
---@field RadialProcess1 URadialImage
---@field RadialProcess2 URadialImage
---@field TextDownload1 UFTextBlock
---@field TextFail UFTextBlock
---@field TextFinish UFTextBlock
---@field TextInitialization UFTextBlock
---@field TextNum UFTextBlock
---@field TextPause UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewDownloadItemView = LuaClass(UIView, true)

function LoginNewDownloadItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDownload = nil
	--self.CommonRedDot = nil
	--self.FCanvasPanel = nil
	--self.ImgDownload1 = nil
	--self.ImgDownloading = nil
	--self.ImgFail = nil
	--self.ImgFinish = nil
	--self.ImgInitialization = nil
	--self.ImgPause = nil
	--self.PanelDownloading = nil
	--self.PanelFail = nil
	--self.PanelFinish = nil
	--self.PanelInitialization = nil
	--self.PanelPause = nil
	--self.PanelPreDownload = nil
	--self.RadialProcess1 = nil
	--self.RadialProcess2 = nil
	--self.TextDownload1 = nil
	--self.TextFail = nil
	--self.TextFinish = nil
	--self.TextInitialization = nil
	--self.TextNum = nil
	--self.TextPause = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewDownloadItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewDownloadItemView:OnInit()
    FLOG_INFO("[LoginNewDownloadItemView:OnInit] ")
    --self.Binders = {
    --    { "PreDownloadState", UIBinderSetIsVisible.New(self, self.BtnStart.ImgDisable, true)},
    --}

    self.TextNum:SetText("0%")
end

function LoginNewDownloadItemView:OnDestroy()

end

function LoginNewDownloadItemView:OnShow()
    FLOG_INFO("[LoginNewDownloadItemView:OnShow] PreDownloadState:%d", PreDownloadMgr.PreDownloadState)
    self.TextDownload1:SetText(LSTR(LoginStrID.PreDownloadName)) --预下载
    self.TextInitialization:SetText(LSTR(LoginStrID.PreDownloadInit)) --初始化
    self.TextPause:SetText(LSTR(LoginStrID.Pause)) --暂停中
    self.TextFinish:SetText(LSTR(LoginStrID.Finished)) --已完成
    self.TextFail:SetText(LSTR(LoginStrID.PreDownloadFailed)) --下载失败

    self:UpdatePreDownloadState(PreDownloadMgr.PreDownloadState)
end

function LoginNewDownloadItemView:OnHide()

end

function LoginNewDownloadItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnDownload, self.OnClickBtnDownload)
end

function LoginNewDownloadItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PreDownloadProgress, self.OnPreDownloadProgress)
    self:RegisterGameEvent(EventID.PreDownloadFinish, self.OnPreDownloadFinish)
    self:RegisterGameEvent(EventID.PreDownloadState, self.OnPreDownloadState)
end

function LoginNewDownloadItemView:OnRegisterBinder()
    --self:RegisterBinders(self.OverseaAgreementVM, self.Binders)
end

function LoginNewDownloadItemView:OnPreDownloadProgress(Progress)
    if not Progress then
        FLOG_WARNING("[LoginNewDownloadItemView:OnPreDownloadProgress] Progress invalid")
        return
    end

    local TotalSize = Progress.totalSize
    if TotalSize < 1 then
        TotalSize = 1024
    end

    local NowSize = Progress.nowSize
    if NowSize < 0 then
        NowSize = 0
    end

    local Percent = NowSize / TotalSize
    self.TextNum:SetText(string.format("%.0f%%", 100 * Percent))
    self.RadialProcess1:SetPercent(math.clamp(Percent, 0, 1))
    self.RadialProcess2:SetPercent(math.clamp(Percent, 0, 1))
    FLOG_INFO("LoginNewDownloadItemView:OnPreDownloadProgress Percent %s", Percent)
end

function LoginNewDownloadItemView:OnPreDownloadFinish(Results)
    FLOG_INFO("LoginNewDownloadItemView:OnPreDownloadFinish - bIsSuccess:%s", tostring(Results.bIsSuccess))
end

function LoginNewDownloadItemView:OnPreDownloadState(State)
    FLOG_INFO("LoginNewDownloadItemView:OnPreDownloadState State:%d", State)
    self:UpdatePreDownloadState(State)
end

function LoginNewDownloadItemView:OnClickBtnDownload()
    UIViewMgr:ShowView(UIViewID.LoginPreDownload)

    --- 红点处理
    local State = PreDownloadMgr.PreDownloadState
    if State == LoginNewDefine.PreDownloadState.Normal then
        -- 每天刷新一次红点
        if PreDownloadMgr.PreDownloadRedClick == "" then
            local ClickDate = TimeUtil.GetTimeFormat("%Y-%m-%d", TimeUtil.GetServerTime())
            PreDownloadMgr.PreDownloadRedClick = ClickDate
            FLOG_INFO("LoginNewDownloadItemView:OnClickBtnDownload Normal -- Clear red point:%s", ClickDate)
            _G.UE.USaveMgr.SetString(SaveKey.PreDownloadRedDot, ClickDate, true)
        else

        end
    elseif State == LoginNewDefine.PreDownloadState.Finish then
        -- 刷新一次红点
        if PreDownloadMgr.PreDownloadRedClick == "" then
            local ClickDate = TimeUtil.GetTimeFormat("%Y-%m-%d", TimeUtil.GetServerTime())
            PreDownloadMgr.PreDownloadRedClick = ClickDate
            FLOG_INFO("LoginNewDownloadItemView:OnClickBtnDownload Finish -- Clear red point:%s", ClickDate)
            _G.UE.USaveMgr.SetString(SaveKey.PreDownloadRedDot, ClickDate, true)
        end
    elseif State == LoginNewDefine.PreDownloadState.Error then
        -- 每次登录刷新一次红点
        if not PreDownloadMgr.PreDownloadErrorRedDot then
            PreDownloadMgr.PreDownloadErrorRedDot = true
            FLOG_INFO("LoginNewDownloadItemView:OnClickBtnDownload Error -- Clear red point")
        end
    end
end

function LoginNewDownloadItemView:UpdatePreDownloadState(State)
    FLOG_INFO("LoginNewDownloadItemView:UpdatePreDownloadState State:%d", State)
    self.PanelPreDownload:SetVisibility(State == LoginNewDefine.PreDownloadState.Normal and ESlateVisibility.HitTestInvisible or ESlateVisibility.Collapsed)
    self.PanelInitialization:SetVisibility(State == LoginNewDefine.PreDownloadState.Init and ESlateVisibility.HitTestInvisible or ESlateVisibility.Collapsed)
    self.PanelDownloading:SetVisibility(State == LoginNewDefine.PreDownloadState.Downloading and ESlateVisibility.HitTestInvisible or ESlateVisibility.Collapsed)
    self.PanelPause:SetVisibility(State == LoginNewDefine.PreDownloadState.Pause and ESlateVisibility.HitTestInvisible or ESlateVisibility.Collapsed)
    self.PanelFinish:SetVisibility(State == LoginNewDefine.PreDownloadState.Finish and ESlateVisibility.HitTestInvisible or ESlateVisibility.Collapsed)
    self.PanelFail:SetVisibility(State == LoginNewDefine.PreDownloadState.Error and ESlateVisibility.HitTestInvisible or ESlateVisibility.Collapsed)

    --- 红点处理
    if State == LoginNewDefine.PreDownloadState.Normal then
        -- 每天刷新一次红点
        if PreDownloadMgr.PreDownloadRedClick == "" then
            FLOG_WARNING("LoginNewDownloadItemView:OnPreDownloadState Normal ++ New red point")
            self.CommonRedDot:SetVisible(ESlateVisibility.SelfHitTestInvisible)
        else
            local CurrentDate = TimeUtil.GetTimeFormat("%Y-%m-%d", TimeUtil.GetServerTime())
            if CurrentDate ~= PreDownloadMgr.PreDownloadRedClick then
                FLOG_WARNING("LoginNewDownloadItemView:OnPreDownloadState Normal ++ Last red point:%s", PreDownloadMgr.PreDownloadRedClick)
                self.CommonRedDot:SetVisible(ESlateVisibility.SelfHitTestInvisible)
            else
                FLOG_INFO("LoginNewDownloadItemView:OnPreDownloadState Normal -- No red point")
                self.CommonRedDot:SetVisible(ESlateVisibility.Collapsed)
            end
        end
    elseif State == LoginNewDefine.PreDownloadState.Init then

    elseif State == LoginNewDefine.PreDownloadState.Downloading then
        --self:OnPreDownloadProgress(PreDownloadMgr.DownloadProgress)
    elseif State == LoginNewDefine.PreDownloadState.Pause then
        self:OnPreDownloadProgress(PreDownloadMgr.DownloadProgress)
    elseif State == LoginNewDefine.PreDownloadState.Finish then
        -- 刷新一次红点
        if PreDownloadMgr.PreDownloadRedClick == "" then
            FLOG_WARNING("LoginNewDownloadItemView:OnPreDownloadState Finish ++ New red point")
            self.CommonRedDot:SetVisible(ESlateVisibility.SelfHitTestInvisible)
        else
            FLOG_WARNING("LoginNewDownloadItemView:OnPreDownloadState Finish -- Last red point:%s", PreDownloadMgr.PreDownloadRedClick)
            self.CommonRedDot:SetVisible(ESlateVisibility.Collapsed)
        end
    elseif State == LoginNewDefine.PreDownloadState.Error then
        -- 每次登录刷新一次红点
        if PreDownloadMgr.PreDownloadErrorRedDot then
            FLOG_WARNING("LoginNewDownloadItemView:OnPreDownloadState Error -- No red point")
            self.CommonRedDot:SetVisible(ESlateVisibility.Collapsed)
        else
            FLOG_WARNING("LoginNewDownloadItemView:OnPreDownloadState Error ++ New red point")
            self.CommonRedDot:SetVisible(ESlateVisibility.SelfHitTestInvisible)
        end
    end
end

return LoginNewDownloadItemView