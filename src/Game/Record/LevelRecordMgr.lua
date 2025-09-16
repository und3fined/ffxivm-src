--
-- Author: muyanli
-- Date: 2024-05-17 09:47:47
-- Description:
--
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")
local PathMgr = require("Path/PathMgr")
local LoginMgr = require("Game/Login/LoginMgr")

local ProtoRes = require("Protocol/ProtoRes")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local SaveKey = require("Define/SaveKey")
local MajorUtil = require("Utils/MajorUtil")
local USaveMgr = _G.UE.USaveMgr
local GameInstance = _G.UE.UFGameInstance.Get()
local UIViewID = _G.UIViewID

local Json = require("Core/Json")

local APIInterface="https://replaytest.fmgame.qq.com:8443/"
local Url_GetRecordList = "v1/api/replay_list"
local RecordSavePath = "Replay/"
local LogFilePath = "Saved/Logs/"
local Url_GetRecordFile= "v1/api/stream"
local FileExt= ".rep"


---@class LevelRecordMgr : MgrBase
local LevelRecordMgr = LuaClass(MgrBase)

function LevelRecordMgr:OnInit()
    self.bIsOpenReplay = CommonUtil.IsMobilePlatform() and not UE.UCommonUtil.IsShipping()--  测试环境移动平台默认开启服务器录制
    self.bIsInReplaying = false
    self.EReplayStatus = {None=0,InRecord=1,InRecordPlay=2,InRecordPause=3}
    self.RecordListData = {}
    self.PlaySpeed = 1
    self.CurrentRecordID = 0
    self.GameStartUpTime = -1
    self.LastUploadlogTime = 0
    self.UploadLogCnt = 0
    self.UploadLogNumLimit = 5   --上传日志个数限制
    self.UploadLogOpenIDNum = 7  --上传日志显示OpenID保留位数，从后开始
    self.UploadWaitTime = 3000  --每个上传文件等待时间ms
    self.OpenUploadLog = true  --是否开启日志上传
    self.UploadLogLimitCnt = 1 --日志上传次数限制
    self.UploadLogNeedCompress = true --日志上传是否开启压缩
    self.UploadLogNeedEncrypt = true --日志上传是否开启加密
    self.IsAutoUploadLog = true --是否自动上传日志
    self.ClearSaveData = true --是否清除本地USaveMgr保存的数据
    self:SwitchClientRecord(true)--  默认勾选客户端录制
    self.ReturnToLogin = true --自动回到登录界面
    self.bOpenPureUIRecord = false --纯UI操作录制
    UE4.UIRecordMgr:Get().OpenUIRecord = true --  默认开启客户端UI录制
    self.IsEnterMapTimeOut = nil --是否进入地图超时
    UE4.ULevelRecordMgr:Get().MapMsgDelayTime = 10000  --  加载地图完成消息延迟时间ms(解决地图加载过慢，导致消息走到前面yi)
    UE4.ULevelRecordMgr:Get().ClickTime = 300  --点击事件按钮按下弹起间隔事件ms(解决卡顿时按钮按下时间过长导致点击事件不触发)
    self:ChangePlaySpeed(self.PlaySpeed)
    self.LastCreateLogFileTimeStap=USaveMgr.GetInt(SaveKey.LastCreateLogFileTimeStap, 0, false)
    self:GetStartUpTime()
    USaveMgr.SetInt(SaveKey.LastCreateLogFileTimeStap, self.GameStartUpTime, false)
    UE4.UIRecordMgr:Get():AddRecordBlackList("GetLevelRecordListPanel")
    UE4.UIRecordMgr:Get():AddPosRecordWhiteList("SettingsMainPanel")
    UE4.UIRecordMgr:Get():AddPosRecordWhiteList("PanelSideWin/PanelJobs/ScrollBox")

    self.EncryptLog = true --是否开启本地日志加密
    self.EncryptLogCompress = CommonUtil.GetDeviceType() == 5 --是否开启本地日志加密压缩(模拟器默认开启)
    self.EncryptLogLimitSize = 150 --开启本地日志加密的大小限制，单位MB
    self:EncryptLogFile()
end

function LevelRecordMgr:OnBegin()
end

function LevelRecordMgr:OnEnd()
    if nil ~= self.RecordPlayControlView then
        self.RecordPlayControlView:RemoveFromViewport()
        self.RecordPlayControlView = nil
    end
end

function LevelRecordMgr:OnShutdown()
end

function LevelRecordMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.ReplayOver, self.OnReplayOver)
    self:RegisterGameEvent(EventID.WorldPreLoad, self.OnWorldPreLoad)
	self:RegisterGameEvent(EventID.WorldPostLoad, self.OnWorldPostLoad)
end

function LevelRecordMgr:ReadLocalRecordFiles()
    self.RecordListData = {}
    local Dir=UE4.UKismetSystemLibrary.GetProjectDirectory()..RecordSavePath
    local FileList = PathMgr.GetFileList(Dir, ".*", true)
    local FileName=""
	for key, value in pairs(FileList) do
        FileName= value:gsub('.*%/', '')
        table.insert(self.RecordListData, { Type = key , Name = FileName, RecordFilePath = value } )
	end

    table.sort(self.RecordListData, function(A, B)
		return A.Name > B.Name
	end )
end

function LevelRecordMgr:StartPlayRecord(ReplayFilePath)
    self.IsEnterMapTimeOut = nil
    local function Confirm()
        if self:IsCanExecReplayCmd() then
            local bOpenPureUIRecord = UE4.ULevelRecordMgr:Get().OpenPureUIRecord
            if  bOpenPureUIRecord == true then
                self.ReturnToLogin = false
            end
            if self.ClearSaveData and not bOpenPureUIRecord then
                USaveMgr.ClearSaveFile(true, "")
            end
            self:InitRecordPlayControlView();
            UE4.ULevelRecordMgr:Get():StartPlayRecord()
            self:UpdateReplayStatu(self.EReplayStatus.InRecordPlay)
            UIViewMgr:HideView(UIViewID.GetLevelRecordListPanel)
        end
    end

    local CurrentVersionStr = UE4.ULevelRecordMgr:Get():LoadRecordAndCheckVersion(ReplayFilePath)
    local ClientVersion = _G.UE.UVersionMgr.GetAppVersion()
    local RecordWorldID=UE4.ULevelRecordMgr:Get().RecordWorldID
    local RecordServerName = LoginMgr:GetMapleNodeName(RecordWorldID)
    print(string.format("[replay info]  RecordWorldID=%d  RecordServerName=%s", RecordWorldID, RecordServerName))

    local bVersionMatch = CurrentVersionStr == ClientVersion or UE4.ULevelRecordMgr:Get().OpenPureUIRecord
    if  bVersionMatch then
        Confirm()
    elseif string.isnilorempty(CurrentVersionStr)  then
        MsgBoxUtil.ShowMsgBoxTwoOp(nil, "提示",
        "录像文件格式错误,请检查录像文件!", nil, nil,
        "取消", "继续")
    else              
        MsgBoxUtil.ShowMsgBoxTwoOp(nil, "提示",
        "录像版本和当前客户端版本不匹配,录像版本为:"..CurrentVersionStr.."\n是否继续播放？", Confirm, nil,
        "取消", "继续")
    end
end

function LevelRecordMgr:UpdateReplayStatu(ReplayStatu)
    if ReplayStatu == nil then
        ReplayStatu = UE4.ULevelRecordMgr:Get():GetReplayStatu()
    else
        UE4.ULevelRecordMgr:Get():UpdateReplayStatu(ReplayStatu)
    end
    self.bIsOpenReplay = ReplayStatu == self.EReplayStatus.InRecord
    self.bIsInReplaying = ReplayStatu == self.EReplayStatus.InRecordPlay
    _G.EventMgr:SendEvent(EventID.Update_Recording)
    _G.EventMgr:SendEvent(EventID.BlockAllInput, self.bIsInReplaying)
end

function LevelRecordMgr:InRecording()
    local ReplayStatu = UE4.ULevelRecordMgr:Get():GetReplayStatu()
    return ReplayStatu == self.EReplayStatus.InRecord
end

function LevelRecordMgr:InRecordState()
    local ReplayStatu = UE4.ULevelRecordMgr:Get():GetReplayStatu()
    return ReplayStatu ~= self.EReplayStatus.None
end


function LevelRecordMgr:ChangePlaySpeed(Speed)
    self.PlaySpeed = Speed
    UE4.ULevelRecordMgr:Get():ChangePlaySpeed(Speed)
end

function LevelRecordMgr:PauseOrResumeRecord()
    local ReplayStatu = UE4.ULevelRecordMgr:Get():GetReplayStatu()
    if ReplayStatu == self.EReplayStatus.InRecordPlay then
        ReplayStatu = self.EReplayStatus.InRecordPause
    elseif ReplayStatu == self.EReplayStatus.InRecordPause then
        ReplayStatu = self.EReplayStatus.InRecordPlay
    end
    UE4.ULevelRecordMgr:Get():UpdateReplayStatu(ReplayStatu)
end

function LevelRecordMgr:GetRecordList(SendData,Callback, Listener)
    _G.HttpMgr:Get(APIInterface..Url_GetRecordList,"",SendData, Callback, Listener)
end

function LevelRecordMgr:SetRecordListData(Data)
    self:ReadLocalRecordFiles()
    for key, value in pairs(Data) do
        if not table.containAttr(self.RecordListData,value.Name..FileExt,"Name") then
            table.insert(self.RecordListData, { Type = key , Name = value.Name..FileExt, RecordFilePath = value.RecordFilePath } )
        end
    end
    table.sort(self.RecordListData, function(A, B)
		return A.Name > B.Name
	end )
end

function LevelRecordMgr:GetRecordListData(Index)
    return self.RecordListData[Index]
end

function LevelRecordMgr:DowmLoadReplayFile(OnlyId, FileName, Callback, Listener)
    local SendData = {
        only_id = OnlyId
    }
    local SavePath = UE4.UKismetSystemLibrary.GetProjectDirectory() .. RecordSavePath .. FileName
    if PathMgr.ExistFile(SavePath) then
        if nil ~= Callback then
            CommonUtil.XPCall(Listener, Callback, true, SavePath)
        end
    else
        _G.HttpMgr:DownLoad(APIInterface .. Url_GetRecordFile, SavePath, SendData, Callback, Listener)
    end
end


function LevelRecordMgr:IsCanExecReplayCmd()
    local bCan=UIViewMgr:IsViewVisible(_G.LoginMgr:GetLoginMainViewId()) or UE4.ULevelRecordMgr:Get().OpenPureUIRecord
    if not bCan then
        _G.MsgTipsUtil.ShowTips("需要在登录界面执行哦！")
    end
    return bCan
end

function LevelRecordMgr:OnReplayOver()
    FLOG_INFO("Record  ReplayOver")
    local function OkBtnCallback()
        if self.ReturnToLogin == true then
            _G.LoginMgr:ReturnToLogin(false)
        end
    end
    _G.EventMgr:SendEvent(EventID.BlockAllInput, false)
    self:UpdateReplayStatu()
    UIViewMgr:HideView(UIViewID.RecordPlayControlPanel)
    self:OnWorldPreLoad()
    if not UE4.ULevelRecordMgr:Get().OpenPureUIRecord then
        MsgBoxUtil.ShowMsgBoxOneOpRight(self, nil, "录像播放完毕", OkBtnCallback, nil, {
            CloseBtnCallback = OkBtnCallback
        })
    end
end

function LevelRecordMgr:OnWorldPreLoad()
	if nil ~= self.RecordPlayControlView then
        self.RecordPlayControlView:SetVisible(false)
        self.RecordPlayControlView:InitSlider()
	end
    if self.bIsInReplaying then
        self:ChangePlaySpeed(1)
    end
end

function LevelRecordMgr:OnWorldPostLoad()
    local bInLogin = UIViewMgr:IsViewVisible(_G.LoginMgr:GetLoginMainViewId())
    if _G.LevelRecordMgr.bIsInReplaying and not bInLogin then
        local CurrentWorldName=_G.UE.UWorldMgr:Get():GetWorldName()
            self:InitRecordPlayControlView()
    end
end

function LevelRecordMgr:InitRecordPlayControlView()
	local View = self.RecordPlayControlView

	if nil == View then
		View = WidgetPoolMgr:CreateWidgetSyncByViewID(UIViewID.RecordPlayControlPanel, true, true)
		if nil == View then
			FLOG_ERROR("UIViewMgr:InitClickFeedbackView Error")
			return
		end
		self.RecordPlayControlView = View
        else
            self.RecordPlayControlView:SetVisible(true)
	end

	if not View:IsInViewport() then
		View:AddToViewport(10)
	end
end


function LevelRecordMgr:SwitchClientRecord(OpenClientRecord)
    UE4.ULevelRecordMgr:Get():SwitchClientRecord(OpenClientRecord)
    self.bIsOpenClientRecord= OpenClientRecord
end

function LevelRecordMgr:SetCurrentRecordID(RecordID)
    if self.bIsOpenReplay then
        UE4.ULevelRecordMgr:Get().CurrentRecordID = RecordID
        self.CurrentRecordID = RecordID
    end
    FLOG_INFO("CurrentRecordID:%s", tostring(RecordID))
end


function LevelRecordMgr:OpenPureUIRecord(OpenPureUIRecord)
    if OpenPureUIRecord == nil then
        OpenPureUIRecord = true
    end
    if OpenPureUIRecord == true then
        self.ReturnToLogin = false
    end
    UE4.ULevelRecordMgr:Get().OpenPureUIRecord = OpenPureUIRecord
end

function LevelRecordMgr:GetHideOpenID()
    local OpenID = LoginMgr:GetOpenID() or 0
    local OpenIDStr = OpenID .. ""

    if LoginMgr:GetIsResearchLogin() then
        return self:GetSubstringBeforeFirstDigit(OpenIDStr)
    end

    local startPos = #OpenIDStr - self.UploadLogOpenIDNum
    if startPos <= 0 then
        startPos = 1
    end
    local result = string.sub(OpenIDStr, startPos, #OpenIDStr)
    return result
end

function LevelRecordMgr:GetSubstringBeforeFirstDigit(input)
    if input ==nil then
        input = ""
    end
    local startPos, endPos = string.find(input, "%d")

    if startPos then
        if startPos == 1 then
            return input
        end
        return string.sub(input, 1, startPos - 1)
    else
        return input
    end
end


function LevelRecordMgr:UpLoadLogFiles(Num,UploadMode,RetryTimes,NeedRetryTips,IsAutoUpload)
    if Num == nil then Num = 5 end
    if RetryTimes == nil then RetryTimes = 3 end
    if NeedRetryTips == nil then NeedRetryTips = false end
    if IsAutoUpload == nil then IsAutoUpload = false end

    local LastUploadLogFileTimeStap = USaveMgr.GetInt(SaveKey.LastUploadLogFileTimeStap, 0, false)
    local Utc8TimeDiff=8*3600
    local LogFileList = {}
    local FileName = ""
    -- local Dir=PathMgr.PathToAbsolutePath(UE4.UKismetSystemLibrary.GetProjectDirectory()..LogFilePath)--TDM自己读文件的接口只支持绝对路径  IOS在UE内读取文件只支持相对路径
    local Dir=UE4.UKismetSystemLibrary.GetProjectDirectory()..LogFilePath
    local FileList = PathMgr.GetFileList(Dir, ".log", false)

    for key, value in pairs(FileList) do
        local  CreationTime = PathMgr.GetFileCreationTime(value)
        local  LastModificationTime = PathMgr.GetFileLastModificationTime(value)
        if LastModificationTime>os.time() then
           LastModificationTime = CreationTime
        end
        table.insert(LogFileList, { FilePath = value, LastModificationTime = LastModificationTime } )
	end

    Num = math.min(Num,#LogFileList)
    local UploadNum = 1

    table.sort(LogFileList, function(A, B)
		return A.LastModificationTime > B.LastModificationTime
	end )
    local  UserName=self:GetHideOpenID()
    local  LastModificationTime = 0
    for i = 2, Num, 1 do
        LastModificationTime = LogFileList[i].LastModificationTime
        if LastModificationTime> LastUploadLogFileTimeStap then
            LastModificationTime=LastModificationTime+Utc8TimeDiff
            if i == 2 then
                LastModificationTime=self.LastCreateLogFileTimeStap
            end
            FileName=UE4.UCommonUtil.GetOutputTime(LastModificationTime,"-",2).."-"..UserName.."-FGame.log"
            UE4.ULevelRecordMgr:Get():UploadLogFile(LogFileList[i].FilePath,FileName,UserName,LastModificationTime,RetryTimes,NeedRetryTips,UploadMode,self.UploadLogNeedCompress,self.UploadLogNeedEncrypt)
            UploadNum=UploadNum+1
        end
    end
    if UploadNum >0 and not IsAutoUpload then
        _G.NetworkImplMgr:StartWaiting(9999,UploadNum*self.UploadWaitTime,LSTR(110011))
    end
    self:GetStartUpTime()
    _G.TimerMgr:AddTimer(nil, function()
        if LogFileList and #LogFileList>0 then
            USaveMgr.SetInt(SaveKey.LastUploadLogFileTimeStap, LogFileList[1].LastModificationTime, false)
        end
    end, 0,UploadNum)
end

function LevelRecordMgr:GetLogFileList()
    local Dir = UE4.UKismetSystemLibrary.GetProjectDirectory() .. LogFilePath
    local FileList = PathMgr.GetFileList(Dir, ".log", false)

    local LogFileList = {}
    for key, value in pairs(FileList) do
        table.insert(LogFileList, value)
    end
    table.sort(LogFileList, function(A, B)
        return A > B
    end)
    return LogFileList
end

function LevelRecordMgr:GetStartUpTime()
    if self.GameStartUpTime == -1 then
        self.GameStartUpTime = UE4.ULevelRecordMgr:Get():GetStartUpTime()
    end
    return self.GameStartUpTime
end

function LevelRecordMgr:GetLogName()
    local  UserName=self:GetHideOpenID()
    local Name=UE4.UCommonUtil.GetOutputTime(self:GetStartUpTime(),"-",2).."-"..UserName
    return Name
end

function LevelRecordMgr:UpLoadLog(UploadMode,RetryTimes,NeedRetryTips)
    if not self.OpenUploadLog then
        _G.MsgTipsUtil.ShowTips(LSTR(10017))
        return
    end
    if self.UploadLogCnt >= self.UploadLogLimitCnt then
        _G.MsgTipsUtil.ShowTips(LSTR(110012))
        return
    end
    
    if UploadMode == nil then UploadMode = 1 end
    if RetryTimes == nil then RetryTimes = 2 end
    if NeedRetryTips == nil then NeedRetryTips = true end

    if  LoginMgr:GetIsResearchLogin() then
        UploadMode = 2  --  研发测试登录日志上传到内部服务器
    end

    local UserName=self:GetHideOpenID()
    -- local Dir=PathMgr.PathToAbsolutePath(UE4.UKismetSystemLibrary.GetProjectDirectory()..LogFilePath,false)
    local Dir=UE4.UKismetSystemLibrary.GetProjectDirectory()..LogFilePath
    local Path = Dir.."FGame.log"
    local BackPath = Dir.."Temp/FGame_backup.log"
    local LogName=self:GetLogName().."-FGame.log"

    -- local CDtime = 10
    -- local remianTime = os.time() - self.LastUploadlogTime
    -- if remianTime < CDtime then
    --     _G.MsgTipsUtil.ShowTips(string.format(LSTR("上传日志CD中,还剩%ss"), CDtime - remianTime))
    --     return
    -- end
    self.LastUploadlogTime=os.time()
    if CommonUtil.IsMobilePlatform() then
        UE4.ULevelRecordMgr:Get():UploadLogFile(Path,LogName,UserName,self:GetStartUpTime(),RetryTimes,NeedRetryTips,UploadMode,self.UploadLogNeedCompress,self.UploadLogNeedEncrypt) 
    else
        local result = PathMgr.CopyFileForce(BackPath,Path)
        UE4.ULevelRecordMgr:Get():UploadLogFile(BackPath,LogName,UserName,self:GetStartUpTime(),RetryTimes,NeedRetryTips,UploadMode,self.UploadLogNeedCompress,self.UploadLogNeedEncrypt)
    end
    self:UpLoadLogFiles(self.UploadLogNumLimit,UploadMode)
    if self.UploadLogCnt == nil then
        self.UploadLogCnt = 1
    else
        self.UploadLogCnt = self.UploadLogCnt + 1
    end
end

function LevelRecordMgr:UpLoadLogResult(Result, NeedRetryTips, RespStr)
    if not NeedRetryTips then
        return
    end
    _G.NetworkImplMgr:StopWaiting(9999)
    local Suc = Result and string.isnilorempty(RespStr)
    if not Suc then
        function Confirm()
            self:UpLoadLog()
        end
        MsgBoxUtil.ShowMsgBoxTwoOp(nil, LSTR(10004),
        LSTR(10058), Confirm, nil,
        LSTR(10028), LSTR(10027))
    end
    if string.isnilorempty(RespStr) then
        _G.MsgTipsUtil.ShowTips(LSTR(110011))
    else
        FLOG_ERROR("UpLoadLogError,server return：" .. RespStr)
    end
end

function LevelRecordMgr:AutoUpLoadLogs()
    if self.IsAutoUploadLog and CommonUtil.IsMobilePlatform() and not UE.UCommonUtil.IsShipping() then
        self:UpLoadLogFiles(self.UploadLogNumLimit,2,2,false,true)
    end
end

function LevelRecordMgr:EncryptLogFile()
    local _ <close> = CommonUtil.MakeProfileTag("LevelRecordMgr:EncryptLogFile")
    if not self.EncryptLog or not CommonUtil.IsMobilePlatform() then
        return
    end
    local LogFileList = self:GetLogFileList()
    if #LogFileList >= 2 then
        UE4.ULevelRecordMgr:Get():EncryptLog(LogFileList[2], self.EncryptLogCompress,self.EncryptLogLimitSize)
    end
end

function LevelRecordMgr:SaveWidget(Widget,Text,Type)
    UE4.UIRecordMgr:Get():SaveWidget(Widget,Text,Type)
end

local TutorialCfg = require("TableCfg/TutorialCfg")
local TutorialUtil = require("Game/Tutorial/TutorialUtil")

function LevelRecordMgr:Test(Param1,Param2)
    -- local cfg = TutorialCfg:FindCfgByID(44)
    -- local ViewID = UIViewMgr:GetViewIDByName("Main2nd/Main2ndPanelNew_UIBP")
    -- local View = UIViewMgr:FindVisibleView(ViewID)
    -- local WidgetPath = TutorialCfg:GetTutorialWidgetPath(44)
    -- local Widget = TutorialUtil:GetTutorialWidget(View, WidgetPath)
    -- TutorialUtil:HandleClickGuideWidget(cfg, Widget)

    local cfg = TutorialCfg:FindCfgByID(44)
    local ViewID = UIViewMgr:GetViewIDByName("Main2nd/Main2ndPanelNew_UIBP")
    local View = UIViewMgr:FindVisibleView(ViewID)
    local WidgetPath = TutorialCfg:GetTutorialWidgetPath(44)
    local Widget = TutorialUtil:GetTutorialWidget(View, WidgetPath)
    TutorialUtil:HandleClickGuideWidget(cfg, Widget)
    FLOG_ERROR("LevelRecordMgr:Test")
end

return LevelRecordMgr
